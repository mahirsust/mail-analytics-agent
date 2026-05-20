"""Microsoft Graph delta query pager.

Uses the Graph /me/mailFolders/inbox/messages/delta endpoint to
fetch only new or changed messages since the last sync (delta link).
Handles OData paging and stores the delta link between runs.
"""

# TODO: Piece 3 — implement Graph delta query with pagination
