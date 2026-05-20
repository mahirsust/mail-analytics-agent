"""Azure AI Search indexer.

Upserts extracted email documents into the search index.
Each document is partitioned by user_id to ensure index isolation.
Batch size is controlled by INDEX_SYNC_BATCH_SIZE env var.
"""

# TODO: Piece 3 — implement AI Search upsert with user_id partitioning
