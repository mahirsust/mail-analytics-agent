"""Index sync worker entry point.

Cron-scheduled Container App job. On each run:
  1. Calls graph_pager to pull new/changed messages via Graph delta query.
  2. Calls extractor to pull metadata + generate embeddings.
  3. Calls indexer to upsert documents into Azure AI Search.
"""

# TODO: Piece 3 — implement index sync orchestration
