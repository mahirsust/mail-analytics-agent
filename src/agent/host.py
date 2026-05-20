"""FastAPI entry point.

Endpoints
---------
POST /chat          Sync agent call (25 s budget, SSE-streamed).
POST /jobs          Async agent call — enqueues work, returns 202.
GET  /jobs/{job_id} Poll async job status.
"""

from fastapi import FastAPI
from fastapi.responses import JSONResponse

app = FastAPI(title="mail-analytics-agent", version="0.1.0")


@app.get("/healthz")
async def health() -> JSONResponse:
    return JSONResponse({"status": "ok"})


@app.post("/chat")
async def chat() -> JSONResponse:
    # TODO: Piece 7 — wire Semantic Kernel orchestrator + SSE streaming
    raise NotImplementedError


@app.post("/jobs")
async def create_job() -> JSONResponse:
    # TODO: Piece 7 — enqueue to Azure Storage Queue, return 202
    raise NotImplementedError


@app.get("/jobs/{job_id}")
async def get_job(job_id: str) -> JSONResponse:
    # TODO: Piece 7 — poll job status from queue/store
    raise NotImplementedError
