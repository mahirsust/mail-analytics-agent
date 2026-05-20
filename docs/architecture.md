# Architecture

See `mail-analytics-agent-plan.md` section 4 for the full architecture diagram.

## Key design decisions

- **Azure AI Search as analytics store** — not Graph directly (quota-limited for aggregations).
- **Dual API lanes** — `/chat` sync (25s) and `/jobs` async with automatic escalation.
- **Two MCP servers** — published M365 MCP for mailbox ops; custom Email Analytics MCP for index queries.
- **Index sync as a separate Container App job** — runs on cron, decoupled from the agent.
- **OBO auth** — agent acts as the user, scoped to their mailbox only.

## ADRs

See `docs/adr/` for individual Architecture Decision Records.
