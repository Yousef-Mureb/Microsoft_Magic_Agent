# Brief — Microsoft vendor agent, step 1: skeleton that answers

Work only inside `C:\magic\ms-vendor-agent`. Do not touch `magic3-platform` or
`magic3-product` except to **read** them for conventions. Ask before every file
you create or change. Never run `git push`.

## Goal of step 1

A running container that exposes the `vendor-agent/1` contract over A2A and can
already answer a Microsoft question with citations. No pricing, sizing, diagrams
or RFP parsing yet. When step 1 is done, Magic can call `vendor_describe` and
`advice_explain` and get correct, cited answers.

## Context you must read first

1. `C:\magic\magic3-platform\AGENTS.md` and `README.md` — the client's house
   style. Our repo follows the same writing rules: English, no abbreviations in
   code or docs, state what you will do and how it is verified before each stage.
2. Search `magic3-platform` for `vendor-agent/1`, `a2a`, `agent card`,
   `x-api-key` and read how Magic **calls** a vendor agent (the client side). Our
   server must match it exactly. Report what you found before writing code.
3. The Lenovo agent card I will paste when you ask for it. Our card copies its
   structure: `supportedInterfaces` (JSON-RPC and HTTP+JSON), `capabilities`
   with the `urn:magic:vendor-agent:1` extension carrying one JSON schema per
   skill, `securitySchemes` with `x-api-key`, and `skills[]` with id, name,
   description, tags, examples.

## What to build

Language: Python 3.12, FastAPI, Pydantic v2, `uv` for dependencies. One
container. Layout:

```
ms-vendor-agent/
  README.md                 what it is, how to run, how to call it
  AGENTS.md                 rules for AI tools working in this repo (copy the
                            spirit of the platform one, adapted to this repo)
  pyproject.toml
  Dockerfile                multi-stage, non-root user, port 8080
  src/ms_agent/
    main.py                 FastAPI app: /a2a/microsoft (JSON-RPC),
                            /a2a/microsoft/rest (HTTP+JSON), /healthz,
                            /.well-known/agent.json
    card.py                 builds the agent card from the skill registry
    contract.py             vendor-agent/1 envelope: {"skill", "request"},
                            request_id and role echoed, error shape, usage block
    auth.py                 x-api-key check against keys loaded at start
                            (environment variable in dev, Key Vault later)
    skills/
      __init__.py           registry: id -> handler + input schema
      vendor_describe.py    profile: vendor, product lines, skills, version,
                            data dates
      advice_explain.py     answer a question with citations
    knowledge/
      learn_mcp.py          client for the Microsoft Learn MCP server
                            (learn.microsoft.com/api/mcp): search + fetch
      retriever.py          interface `retrieve(question) -> [passages]`;
                            step 1 implementation = Learn MCP only; a comment
                            marks where Azure AI Search plugs in at step 2
    llm/
      client.py             Azure OpenAI chat + embeddings via the official
                            `openai` SDK, endpoint/deployment from environment,
                            key from environment now, managed identity later
    settings.py             all configuration from environment variables, with
                            a documented .env.example (no real values)
  tests/
    test_contract.py        envelope validation, request_id/role echo, errors
    test_card.py            card is valid JSON and lists both skills with schemas
    test_vendor_describe.py
    test_advice_explain.py  uses a fake retriever and fake LLM; asserts that an
                            answer without at least one citation is rejected
  evaluations/
    golden_questions.yaml   30 Microsoft questions with expected key facts and
                            expected source domains (I will supply them; create
                            the file with 3 placeholder examples and the schema)
    run_golden.py           calls advice_explain for each, scores: citation
                            present, expected facts present; prints a table
  .github/workflows/
    ci.yml                  lint (ruff), tests (pytest), docker build on PR
```

Behaviour rules baked in from day one:

- Every `advice_explain` answer returns `answer`, `citations[]` (url, title,
  quote) and `usage` (prompt_tokens, completion_tokens, seconds). If the model
  produces no citation, the skill returns an error, not an answer.
- Every response echoes `request_id` and `role` if they were sent.
- No secret in any file. `.env.example` has names only. `.gitignore` excludes
  `.env`.
- Logs are structured JSON with request_id, skill, duration, tokens; never the
  request body.

## How it is verified (do these and show me the output)

1. `uv run pytest` passes.
2. `docker build` succeeds; `docker run -p 8080:8080` with a dev key answers:
   - `GET /healthz` → 200
   - `GET /.well-known/agent.json` → valid card with 2 skills
   - `POST /a2a/microsoft/rest` with `{"skill":"vendor_describe","request":{}}`
     and the key → profile JSON
   - same without the key → 401
3. With a real Azure OpenAI endpoint in `.env` (I will provide it in the
   terminal, not in a file you create), `advice_explain` with the question
   "Which Microsoft 365 plans are required before a customer can buy Microsoft
   365 Copilot?" returns an answer with at least one `learn.microsoft.com`
   citation.
4. `uv run python evaluations/run_golden.py` runs over the placeholder
   questions and prints the score table.

## Out of scope for step 1

Pricing, sizing, licensing rules, diagrams, estimates, Azure AI Search,
Container Apps deployment files, Key Vault integration. Leave clearly marked
extension points, nothing more.

## Working agreement

Before each stage (layout, contract, skills, tests, CI) tell me in five lines
what you will do and how we will know it worked. Then do only that. If you
discover that Magic's client side expects something different from the Lenovo
card, stop and tell me before adapting.
