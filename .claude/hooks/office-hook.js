// Sends every Claude Code hook event to the office server.
// Never blocks Claude: exits 0 quickly even if the server is not running.
const http = require("http");
const port = Number(process.env.OFFICE_PORT || 4747);

let raw = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", (c) => (raw += c));
process.stdin.on("end", () => {
  let body;
  try {
    const e = JSON.parse(raw || "{}");
    body = JSON.stringify({
      hook: e.hook_event_name,
      session: e.session_id,
      tool: e.tool_name,
      input: e.tool_input,
      toolUseId: e.tool_use_id,
      agentType: e.agent_type,
      agentId: e.agent_id,
      prompt: e.prompt,
    });
  } catch {
    process.exit(0);
  }
  const req = http.request(
    { host: "127.0.0.1", port, path: "/event", method: "POST", timeout: 800,
      headers: { "content-type": "application/json", "content-length": Buffer.byteLength(body) } },
    (res) => { res.resume(); res.on("end", () => process.exit(0)); }
  );
  req.on("error", () => process.exit(0));
  req.on("timeout", () => { req.destroy(); process.exit(0); });
  req.end(body);
});
setTimeout(() => process.exit(0), 1500);
