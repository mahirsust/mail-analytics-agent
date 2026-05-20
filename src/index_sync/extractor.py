"""Metadata + embedding extractor.

For each raw Graph message, extracts:
  - sender, recipients, subject, timestamps, folder, has_attachments
  - body excerpt (first 500 chars, stripped of HTML)
  - embedding vector (via Azure OpenAI text-embedding-3-small)
  - classification labels (to be filled by analytics MCP later)

Output schema matches the Azure AI Search index definition.
"""

# TODO: Piece 3 — implement metadata extraction + embedding generation
