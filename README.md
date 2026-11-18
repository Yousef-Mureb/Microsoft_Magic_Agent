# ms-vendor-agent

The Microsoft vendor agent for MAGIC, in the contract `vendor-agent/1` over A2A 1.0
(Agent-to-Agent, the protocol MAGIC reaches a vendor agent by). Six skills:

| Skill | What it does | Model |
|---|---|---|
| `vendor_describe` | The agent's profile, read by MAGIC's operator check | no |
| `design_propose` | A first Azure infrastructure design for workloads: services and sizes by role, availability, gaps, caveats, totals, the Excel estimate and the diagram | summary and caveats only |
| `design_figure` | The design as an Azure architecture diagram with Microsoft's official icons, SVG and PNG | no |
| `advice_explain` | Answers about Microsoft products and licensing from Microsoft Learn, with quotes and sources | yes |
| `price_get` | Azure list prices per pricing model, each with source URL and dates | no |
| `sizing_calc` | VM sizes and disks for workloads, alternatives, totals per pricing model, the Excel estimate | no |

Prices are Microsoft's retail list prices from the Azure Retail Prices API, refreshed nightly,
never CSP, EA or MCA agreement prices. No diagrams, licensing rules or Microsoft 365 seat prices
yet.

Before changing anything, read [AGENTS.md](AGENTS.md). The state of the work is in
[PROGRESS.md](PROGRESS.md); the briefs are [BRIEF-step1.md](BRIEF-step1.md) and
[BRIEF-step2.md](BRIEF-step2.md).

## How it works

```text
MAGIC (tools authority)  --A2A JSON-RPC, x-api-key-->  /a2a/microsoft
                                                         |
                                            contract.py: {"skill", "request"} -> envelope
                                                         |
                                   skills/: vendor_describe | advice_explain
                                                                   |
                                    knowledge/retriever.py: passages for the question
                                      (step 1: Microsoft Learn MCP server, live)
                                                                   |
                                    llm/client.py: Azure OpenAI answers from the passages
                                                                   |
                                    citations checked against the passages; none -> refusal
```

The card at `/.well-known/agent-card.json` tells MAGIC the endpoint, the key header and one
JSON schema per skill (extension `urn:magic:vendor-agent:1`). The same card is served at
`/.well-known/agent.json`.

## Running it

Requirements: Python 3.12 and [uv](https://docs.astral.sh/uv/). Copy `.env.example` to `.env`
and fill in at least `MS_AGENT_API_KEYS`; `advice_explain` also needs the `AZURE_OPENAI_*`
variables.

```bash
uv sync
uv run pytest
uv run uvicorn ms_agent.main:create_app --factory --port 8080
```

On a machine where launcher executables are blocked (some corporate laptops), use
`uv run python -m pytest` and `uv run python -m uvicorn ...`; they are the same programs.

The pricing skills need prices in the store first. The nightly job (a Container Apps scheduled
job in Azure) is the same command you run by hand:

```bash
uv run python jobs/refresh_prices.py                                      # the settings' regions and families
uv run python jobs/refresh_prices.py --region uaenorth --family Compute --family Storage
uv run python -m pytest -m live                                           # the one test that reaches prices.azure.com
```

VM specifications come from `data/vm_sizes_<region>.json`; `scripts/refresh_vm_sizes.ps1
-Region uaenorth` regenerates one with the Azure CLI (`az vm list-skus`). The repository holds
`uaenorth` (1,092 sizes, 26 October 2026); the tests use a 24-size part of it in
`tests/fixtures/`. Sizing never picks Arm64 or constrained-core sizes, and on equal price it
takes the newest generation.

With Docker:

```bash
docker build -t ms-vendor-agent .
docker run -p 8080:8080 -e MS_AGENT_API_KEYS=dev-key ms-vendor-agent
```

## Calling it

```bash
curl http://localhost:8080/healthz
curl http://localhost:8080/.well-known/agent-card.json

# HTTP+JSON binding: the data part in, the envelope out
curl -H 'x-api-key: dev-key' -H 'content-type: application/json' \
  -d '{"skill":"vendor_describe","request":{}}' http://localhost:8080/a2a/microsoft/rest

curl -H 'x-api-key: dev-key' -H 'content-type: application/json' \
  -d '{"skill":"advice_explain","request":{"question":"Which Microsoft 365 plans are required before a customer can buy Microsoft 365 Copilot?"}}' \
  http://localhost:8080/a2a/microsoft/rest
```

MAGIC itself uses the JSON-RPC binding, `SendMessage` with one data part:

```bash
curl -H 'x-api-key: dev-key' -H 'content-type: application/json' -d '{
  "jsonrpc": "2.0", "id": "1", "method": "SendMessage",
  "params": {"message": {"messageId": "m1", "role": "ROLE_USER",
                         "parts": [{"data": {"skill": "vendor_describe", "request": {}}}]}}
}' http://localhost:8080/a2a/microsoft
```

The answer is a finished task whose artifact named `result` holds the envelope:

```json
{"contract": "vendor-agent/1", "status": "complete", "warnings": [], "files": [],
 "result": {"answer": "...", "citations": [{"url": "...", "title": "...", "quote": "..."}], "passages_considered": 8},
 "refusal": null, "usage": {"prompt_tokens": 1200, "completion_tokens": 180, "seconds": 4.2},
 "request_id": "<echoed>", "role": "<echoed>"}
```

A refusal is `status: "failed"` with `refusal: {code, message}`. Codes: `bad_request`,
`unknown_skill`, `no_sources`, `sources_unavailable`, `model_not_configured`,
`bad_model_output`, `no_citation`, `prices_not_configured`, `prices_not_loaded`, `no_price`,
`no_size`, `region_not_supported`, `internal_error`. A request without a valid key is HTTP 401.

Sizing and a design, with the estimate workbook:

```bash
curl -H 'x-api-key: dev-key' -H 'content-type: application/json' -d '{"skill": "sizing_calc", "request": {
  "workloads": [{"name": "web servers", "vcpu": 4, "memory_gb": 16, "os": "linux", "count": 6},
                {"name": "SQL servers", "vcpu": 8, "memory_gb": 64, "os": "windows", "count": 2}],
  "region": "uaenorth", "pricing_models": ["sp_3y"], "ahb": true}}' http://localhost:8080/a2a/microsoft/rest
```

The answer's `files` (and, over JSON-RPC, the task's artifact `files`) holds the workbook's link,
`<MS_AGENT_PUBLIC_URL>/files/<id>`, on the agent's own host, because MAGIC fetches files only
from there; it needs the key and lasts 24 hours. The workbook has the sheets Summary, Lines,
Assumptions, Sources and Disclaimer, with formulas, so quantities and hours can be edited.
`design_propose` takes the same workloads plus `availability` (`single_zone`,
`zone_redundant`, `with_dr`).

## Evaluations

`evaluations/golden_questions.yaml` holds 30 Microsoft questions with expected facts, phrases
the answer must not contain, and expected sources. `evaluations/run_golden.py` asks each and
prints a score table:

```bash
uv run python evaluations/run_golden.py --fake                 # plumbing and scoring, no network
uv run python evaluations/run_golden.py                        # real Learn and Azure OpenAI from .env
uv run python evaluations/run_golden.py --url http://localhost:8080 --key dev-key
```

## Layout

```text
src/ms_agent/
  main.py          FastAPI application, JSON-RPC and HTTP+JSON bindings, health, card
  card.py          the agent card from the skill registry
  contract.py      the vendor-agent/1 envelope, refusals, usage
  auth.py          the x-api-key check
  settings.py      configuration from the environment
  log.py           structured JSON logs
  skills/          registry and the five skills
  knowledge/       Learn MCP client and the retriever interface
  llm/             Azure OpenAI client (key or managed identity)
  pricing/         Retail Prices ingestion, the price store, lookup by pricing model, VM catalog
  sizing/          VM size choice, disks, the estimate
  estimate_workbook.py   the .xlsx estimate
  files.py         made files: local folder or Azure Blob, served at /files/<id>
jobs/              refresh_prices.py, the nightly price refresh
data/              VM size snapshots per region
scripts/           refresh_vm_sizes.ps1, record_price_fixtures.py
tests/             pytest, with fakes and recorded Retail Prices answers
evaluations/       golden questions and the scorer
```
