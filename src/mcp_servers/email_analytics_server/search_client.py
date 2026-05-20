"""Azure AI Search client wrapper.

Provides typed query helpers used by the analytics tools.
All queries are scoped to the calling user's partition (user_id filter).
Result rows are capped at settings.agent_max_result_rows.
"""

# TODO: Piece 4 — implement AI Search wrapper with user-scoped queries
