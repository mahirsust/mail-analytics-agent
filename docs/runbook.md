# Runbook

## Health check

```bash
curl https://<agent-host>/healthz
```

## Trigger a manual index sync

```bash
az containerapp job start \
  --name ca-mail-analytics-worker \
  --resource-group rg-mail-analytics-agent-dev
```

## Check job queue depth

```bash
az storage queue show \
  --account-name stmailanalyticsdev \
  --name agent-jobs \
  --query approximateMessageCount
```

## View logs

```bash
az monitor app-insights query \
  --app appi-mail-analytics-agent \
  --analytics-query "traces | order by timestamp desc | take 100"
```
