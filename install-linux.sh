#!/usr/bin/env bash

set -Eeuo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
stamp="$(date +%Y%m%d-%H%M%S)"
install_packages=false
sync_plugins=true
path_has_local_bin=false
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
nvim_version="v0.12.4"

if [[ ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
  path_has_local_bin=true
fi

usage() {
  cat <<'EOF'
Usage: bash install-linux.sh [options]

Options:
  --packages  Install the C++/Neovim toolchain with the detected package manager.
  --no-sync   Link configuration without downloading Neovim plugins.
  -h, --help  Show this help.

The script installs checksum-verified Neovim 0.12.4 under ~/.local when the
system version is missing or older than 0.11.2. Existing configuration is moved
to a timestamped backup before links are created.
EOF
}

while (($# > 0)); do
  case "$1" in
    --packages)
      install_packages=true
      ;;
    --no-sync)
      sync_plugins=false
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

run_as_root() {
  if ((EUID == 0)); then
    "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  elif command -v doas >/dev/null 2>&1; then
    doas "$@"
  else
    printf 'Root access is required to install packages (sudo or doas).\n' >&2
    return 1
  fi
}

install_dev_packages() {
  if command -v apt-get >/dev/null 2>&1; then
    run_as_root apt-get update
    run_as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y \
      build-essential ca-certificates clang clangd clang-format clang-tidy \
      cmake curl fd-find git gzip ninja-build nodejs npm python3 python3-pip \
      python3-venv ripgrep tar tmux unzip
  elif command -v dnf >/dev/null 2>&1; then
    run_as_root dnf install -y \
      ca-certificates clang clang-tools-extra cmake curl fd-find gcc gcc-c++ \
      git gzip ninja-build nodejs npm python3 python3-pip ripgrep tar tmux unzip
  elif command -v pacman >/dev/null 2>&1; then
    run_as_root pacman -Syu --needed --noconfirm \
      base-devel ca-certificates clang cmake curl fd git gzip ninja nodejs npm \
      python python-pip ripgrep tar tmux unzip
  elif command -v zypper >/dev/null 2>&1; then
    run_as_root zypper --non-interactive install \
      ca-certificates clang clang-tools cmake curl fd gcc gcc-c++ git gzip \
      ninja nodejs npm python3 python3-pip ripgrep tar tmux unzip
  else
    printf 'Unsupported package manager. Install the tools listed in nvim/README.md manually.\n' >&2
    return 1
  fi
}

link_config() {
  local source="$1"
  local destination="$2"
  local parent
  parent="$(dirname -- "$destination")"
  mkdir -p -- "$parent"

  if [[ -L "$destination" ]] && [[ "$(readlink -f -- "$destination")" == "$(readlink -f -- "$source")" ]]; then
    printf 'Already linked: %s\n' "$destination"
    return
  fi

  local backup=""
  if [[ -e "$destination" || -L "$destination" ]]; then
    backup="${destination}.pre-dotfiles-${stamp}.bak"
    mv -- "$destination" "$backup"
    printf 'Backed up: %s -> %s\n' "$destination" "$backup"
  fi

  if ! ln -s -- "$source" "$destination"; then
    if [[ -n "$backup" && ! -e "$destination" && ! -L "$destination" ]]; then
      mv -- "$backup" "$destination"
    fi
    return 1
  fi
  printf 'Linked: %s -> %s\n' "$destination" "$source"
}

nvim_binary_is_supported() {
  "$1" --headless --clean \
    "+lua if vim.fn.has('nvim-0.11.2') == 0 then vim.cmd('cquit 1') end" \
    +qa >/dev/null 2>&1
}

nvim_is_supported() {
  command -v nvim >/dev/null 2>&1 && nvim_binary_is_supported "$(command -v nvim)"
}

verify_sha256() {
  local file="$1"
  local expected="$2"
  if command -v sha256sum >/dev/null 2>&1; then
    printf '%s  %s\n' "$expected" "$file" | sha256sum -c -
  elif command -v shasum >/dev/null 2>&1; then
    printf '%s  %s\n' "$expected" "$file" | shasum -a 256 -c -
  else
    printf 'sha256sum or shasum is required to verify Neovim.\n' >&2
    return 1
  fi
}

install_neovim() {
  local asset checksum
  case "$(uname -m)" in
    x86_64 | amd64)
      asset="nvim-linux-x86_64.tar.gz"
      checksum="012bf3fcac5ade43914df3f174668bf64d05e049a4f032a388c027b1ebd78628"
      ;;
    aarch64 | arm64)
      asset="nvim-linux-arm64.tar.gz"
      checksum="ceb7e88c6b681f0515d135dcdfad54f5eb4373b25ce6172197cd9a69c758063f"
      ;;
    *)
      printf 'No official Neovim binary configured for architecture: %s\n' "$(uname -m)" >&2
      return 1
      ;;
  esac

  command -v curl >/dev/null 2>&1 || {
    printf 'curl is required to install Neovim. Re-run with --packages or install curl.\n' >&2
    return 1
  }
  command -v tar >/dev/null 2>&1 || {
    printf 'tar is required to install Neovim. Re-run with --packages or install tar.\n' >&2
    return 1
  }

  local temp_dir install_dir backup
  temp_dir="$(mktemp -d)"
  trap "rm -rf -- '$temp_dir'" EXIT
  install_dir="$HOME/.local/opt/nvim"
  backup="${install_dir}.pre-dotfiles-${stamp}.bak"

  printf 'Downloading Neovim %s for %s...\n' "$nvim_version" "$(uname -m)"
  curl -fL --retry 3 \
    "https://github.com/neovim/neovim/releases/download/${nvim_version}/${asset}" \
    -o "$temp_dir/nvim.tar.gz"
  verify_sha256 "$temp_dir/nvim.tar.gz" "$checksum"
  mkdir -p -- "$temp_dir/nvim" "$HOME/.local/opt" "$HOME/.local/bin"
  tar -xzf "$temp_dir/nvim.tar.gz" -C "$temp_dir/nvim" --strip-components=1
  if ! nvim_binary_is_supported "$temp_dir/nvim/bin/nvim"; then
    printf 'Downloaded Neovim cannot run on this system (glibc may be too old).\n' >&2
    return 1
  fi

  if [[ -e "$install_dir" || -L "$install_dir" ]]; then
    mv -- "$install_dir" "$backup"
    printf 'Backed up: %s -> %s\n' "$install_dir" "$backup"
  fi
  mv -- "$temp_dir/nvim" "$install_dir"

  if [[ -e "$HOME/.local/bin/nvim" || -L "$HOME/.local/bin/nvim" ]]; then
    mv -- "$HOME/.local/bin/nvim" "$HOME/.local/bin/nvim.pre-dotfiles-${stamp}.bak"
  fi
  ln -s -- "$install_dir/bin/nvim" "$HOME/.local/bin/nvim"
  printf 'Installed Neovim: %s\n' "$HOME/.local/bin/nvim"

  rm -rf -- "$temp_dir"
  trap - EXIT
}

if [[ "$install_packages" == true ]]; then
  install_dev_packages
fi

export PATH="$HOME/.local/bin:$PATH"

if ! nvim_is_supported; then
  install_neovim
fi

link_config "$repo_root/nvim" "$config_home/nvim"
link_config "$repo_root/tmux/tmux.conf" "$HOME/.tmux.conf"

if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
  link_config "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi

nvim_bin="$(command -v nvim)"
if [[ "$sync_plugins" == true ]]; then
  if command -v git >/dev/null 2>&1; then
    printf 'Restoring LazyVim plugins from the lock file...\n'
    "$nvim_bin" --headless "+Lazy! restore" +qa
  else
    printf 'Skipping plugin sync because git is not installed.\n' >&2
  fi
fi

printf '\nInstalled configuration. Tool availability:\n'
for tool in nvim git clangd clang-format cmake ninja tmux rg fd node npm python3; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf '  [ok]      %s\n' "$tool"
  else
    printf '  [missing] %s\n' "$tool"
  fi
done

if [[ "$path_has_local_bin" == false ]]; then
  printf '\nAdd ~/.local/bin to PATH in your login shell.\n'
fi

printf '\nStart from a project directory with: nvim .\n'
printf 'Reload tmux configuration with: tmux source-file ~/.tmux.conf\n'
