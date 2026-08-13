const utf8Setup = [
  "$utf8 = [Text.UTF8Encoding]::new($false)",
  "[Console]::InputEncoding = $utf8",
  "[Console]::OutputEncoding = $utf8",
  "$OutputEncoding = $utf8",
].join("; ")

const hasEncodingSetup = /\[Console\]::(?:Input|Output)Encoding\s*=/

export default async () => ({
  "tool.execute.before": async (
    input: { tool: string },
    output: { args: { command?: unknown } },
  ) => {
    if (input.tool !== "bash" || typeof output.args.command !== "string") return
    if (hasEncodingSetup.test(output.args.command)) return
    output.args.command = `${utf8Setup}; ${output.args.command}`
  },
})
