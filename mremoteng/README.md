# mRemoteNG

This machine intentionally uses the community fork at
[`robertpopa22/mRemoteNG`](https://github.com/robertpopa22/mRemoteNG), **not**
the official upstream repository at `mRemoteNG/mRemoteNG` and not the WinGet
package sourced from upstream.

## Installed build

- Version: `1.82.0` x64, framework-dependent MSI
- Release: <https://github.com/robertpopa22/mRemoteNG/releases/tag/v1.82.0>
- Installer: <https://github.com/robertpopa22/mRemoteNG/releases/download/v1.82.0/mRemoteNG-v1.82.0-x64.msi>
- SHA-256: `16e49b126e7448beda313672225251325f1d2d7f94dbce402d3be684864e949c`
- Install path: `%ProgramFiles%\mRemoteNG`

The checksum above matches the digest published by the fork's GitHub Release.
The MSI is not Authenticode-signed. Do not replace or upgrade this installation
through `winget install mRemoteNG.mRemoteNG`, because that selects the official
upstream package. Future upgrades should use a reviewed release from the same
community fork and verify its published SHA-256 first.

## Local configuration

The local configuration is deliberately not tracked in Git. Active settings
belong under `%APPDATA%\mRemoteNG` for each Windows account. Connection files,
logs, hostnames, usernames, and encrypted passwords must remain outside this
repository; `.gitignore` also excludes common mRemoteNG connection and settings
filenames as a second line of defense.
