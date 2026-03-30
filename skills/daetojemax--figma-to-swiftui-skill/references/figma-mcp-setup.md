# Figma MCP Reference

Assumes Figma MCP server is already connected and working.

## Remote vs Desktop MCP

**Remote MCP** (mcp.figma.com) — the standard setup. Requires fileKey and nodeId from Figma URLs.

**Desktop MCP** — connects to the Figma desktop app directly:
- No fileKey needed (uses currently open file)
- Supports selection-based prompting (select node in Figma, then call tool)
- Requires Figma desktop app running
- Only works with currently open file

## Troubleshooting

get_design_context returns empty:
- Verify nodeId exists in the file
- Try get_metadata first to confirm structure
- Check file permissions

Assets not downloading:
- MCP serves assets via localhost during active session
- If localhost URL fails, session may have expired
- Re-run get_design_context to refresh

Response too large:
- Use get_metadata first for node structure
- Fetch child nodes individually
- Focus on one section at a time
