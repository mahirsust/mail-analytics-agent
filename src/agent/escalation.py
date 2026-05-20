"""Sync → async escalation logic.

Escalates a /chat request to a background job when:
  1. A tool declares performance="slow".
  2. The agent loop exceeds AGENT_SYNC_TIMEOUT_SECONDS.
  3. It is the user's first call (triggers index sync).
"""

# TODO: Piece 7 — implement escalation logic
