# mail-analytics-agent

An AI agent on Azure that performs **email automation** and **email analytics**
on a Microsoft 365 mailbox using Model Context Protocol (MCP).

## What it does

- **Email automation** — read, summarize, classify, draft replies, flag threads, schedule meetings.
- **Email analytics** — answer natural-language questions about your mailbox:
  - *"How many emails did I get from the finance team last week?"*
  - *"What's my average response time to customer emails?"*
  - *"Which threads have been waiting for my reply the longest?"*
  - *"Cluster my unread inbox by topic and tell me what's urgent."*

## Stack

| Layer | Technology |
|---|---|
| Agent brain | Azure AI Foundry + GPT-4o |
| Agent framework | Semantic Kernel (Python) |
| API host | FastAPI on Azure Container Apps |
| Email source | Microsoft Graph via M365 MCP server |
| Analytics index | Azure AI Search (synced from Graph) |
| Auth | Entra ID with On-Behalf-Of (OBO) |
| Region | Sweden Central (EU Data Boundary) |

## Getting started

### Prerequisites

- Python 3.11+
- [uv](https://docs.astral.sh/uv/) — `pip install uv`
- [Azure Developer CLI](https://learn.microsoft.com/azure/developer/azure-developer-cli/) — `winget install microsoft.azd`
- Azure subscription with permissions to create resources
- Microsoft 365 account (for mailbox access)

### Local development

```bash
# Clone and enter the repo
git clone https://github.com/<org>/mail-analytics-agent
cd mail-analytics-agent

# Install dependencies
uv sync --all-extras

# Copy env template and fill in values
cp .env.example .env

# Run the agent host locally
uv run uvicorn src.agent.host:app --reload --port 8000
```

### Provision Azure infrastructure

```bash
azd auth login
azd provision    # creates all Azure resources in Sweden Central
azd deploy       # builds and pushes containers
```

## Project structure

```
mail-analytics-agent/
├── src/
│   ├── agent/                   # FastAPI host + Semantic Kernel orchestrator
│   ├── job_worker/              # Async job worker (dequeues long-running tasks)
│   ├── mcp_clients/             # MCP client wrappers (M365 + Analytics)
│   ├── mcp_servers/
│   │   └── email_analytics_server/  # Custom MCP server (12 analytics tools)
│   └── index_sync/              # Cron job: Graph delta → AI Search
├── infra/                       # Bicep infrastructure-as-code
├── tests/
│   ├── unit/
│   ├── integration/
│   └── evals/                   # Baseline + adversarial (prompt injection) evals
├── prompts/                     # System prompt for the agent
└── docs/                        # Architecture, runbook, threat model, ADRs
```

## API

```
POST /chat          Sync (25s budget), SSE-streamed response
POST /jobs          Explicit async, returns {job_id, poll_url}
GET  /jobs/{id}     Poll job status
```

## Security

- Agent accesses only the calling user's mailbox (Entra OBO, delegated permissions).
- Email is treated as **untrusted data**, never as instructions (Prompt Shields enabled).
- All email sends are **draft-only** by default — human approves in Outlook.
- Every tool call is audit-logged to Application Insights.

## Build plan

| Piece | Status |
|---|---|
| 1. Project scaffolding | 🔄 In progress |
| 2. Infrastructure (Bicep) | ⏭️ |
| 3. Index sync worker | ⏭️ |
| 4. Email Analytics MCP server | ⏭️ |
| 5. Containerize & push | ⏭️ |
| 6. Wire up M365 MCP | ⏭️ |
| 7. Agent orchestrator + async | ⏭️ |
| 8. Safety + observability + evals | ⏭️ |
| 9. Deployment + CI/CD | ⏭️ |
