"""Async job worker.

Dequeues messages from Azure Storage Queue and runs the agent loop
without an HTTP timeout constraint. Used for slow operations:
  - cluster_by_topic
  - summarize_period
  - classify_emails (large periods)
  - initial onboarding index sync
"""

# TODO: Piece 7 — implement queue consumer + agent loop
