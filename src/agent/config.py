"""Application configuration via pydantic-settings.

All values are read from environment variables (or .env file in dev).
Never hardcode secrets here — pull them from Key Vault at runtime.
"""

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    # Azure identity
    azure_tenant_id: str
    azure_client_id: str
    azure_client_secret: str = ""  # empty in prod (managed identity)

    # Azure AI Foundry
    azure_ai_foundry_endpoint: str
    azure_openai_deployment: str = "gpt-4o"
    azure_openai_api_version: str = "2024-12-01-preview"

    # Azure AI Search
    azure_search_endpoint: str
    azure_search_index_name: str = "mail-index"
    azure_search_api_key: str = ""  # empty in prod (managed identity)

    # Azure Key Vault
    azure_keyvault_url: str

    # Azure Storage Queue
    azure_storage_account_name: str
    azure_storage_queue_name: str = "agent-jobs"
    azure_storage_connection_string: str = ""  # empty in prod (managed identity)

    # Azure AI Content Safety
    azure_content_safety_endpoint: str = ""
    azure_content_safety_key: str = ""

    # Graph / M365 MCP
    graph_scope: str = "https://graph.microsoft.com/.default"
    m365_mcp_server_url: str = "http://localhost:3000"

    # Agent host
    agent_host_port: int = 8000
    agent_sync_timeout_seconds: int = 25
    agent_max_result_rows: int = 1000

    # Application Insights
    applicationinsights_connection_string: str = ""

    # Index sync
    index_sync_lookback_days: int = 90
    index_sync_batch_size: int = 50

    # Runtime
    environment: str = "dev"
    log_level: str = "INFO"


settings = Settings()  # type: ignore[call-arg]
