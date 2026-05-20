"""Email Analytics MCP server entry point.

Registers all 12 analytics tools and starts the MCP server.
Tools query Azure AI Search — never Microsoft Graph directly.

Tool performance tiers
-----------------------
fast  — completes in <500 ms; safe for /chat sync lane.
slow  — may take seconds; auto-escalated to /jobs async lane.
"""

# TODO: Piece 4 — implement MCP server with all 12 tools
