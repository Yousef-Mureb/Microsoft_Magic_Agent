# Working rules for this repository

Read this file before you change anything here. It applies to every person and to every tool.
The rules follow the spirit of `magic3-platform/AGENTS.md`, the client's house style, adapted to
one small service that lives outside the platform.

## Rule 1 — Everything is written in English, without abbreviations

Documents, comments, identifiers and commit messages are technically and linguistically
correct English. Write concisely but spell words out; expand an acronym the first time it
appears in a document. Discussion may happen in any language; only the result is bound.

## Rule 2 — Instructions for agents live in this file and nowhere else

No tool-specific configuration directory or instruction file is committed. A rule that is
missing is added here, not kept in a private copy. Checks are ordinary commands anyone can run:
`uv run ruff check .`, `uv run pytest`, `uv run python evaluations/run_golden.py --fake`.

## Rule 3 — The contract is MAGIC's, not ours

The agent answers in `vendor-agent/1` over A2A 1.0, exactly as MAGIC's client reads it
(`magic3-platform/modules/tools/contracts/current/vendors.md` and
`modules/tools/services/authority/src/vendors.py`). When this repository and that client
disagree, the client is right and this repository is corrected; the Lenovo agent card
(`lenovo-agent-card.json`) is the worked example of the same contract. A change to the
envelope, the card or the skill schemas is a contract change and is named as such in the
commit and in `PROGRESS.md`.

## Rule 4 — An answer without a citation is an error

`advice_explain` returns an answer only when at least one citation points at a page the
retriever returned for that question. Anything else is a refusal with a code. Do not weaken
this to make a test pass or a demo look better.

## Rule 5 — No secret in any file

Keys and endpoints come from environment variables (`.env` in development, ignored by git;
Azure Key Vault and managed identity later). `.env.example` holds names only. A real value in a
commit stays in the history for good.

## Rule 6 — Logs are structured and never hold the request

Every skill call writes one JSON line: request number, skill, status, duration, tokens. The
question, the part and the answer are never logged.

## Rule 7 — State what you will do, then do only that

Before a substantial stage, write in `PROGRESS.md` what will be done and how it will be
verified; after it, write what was verified and what remains. Keep the user's acceptance
criteria distinct from the technical plan. Report delivery, not activity: a test that passes is
evidence, not the deliverable. Distinguish what is implemented, verified, committed and
deployed. Do not push and do not touch `main`; work on a branch named `elias/<topic>`.

## Rule 8 — Extension points are marked, not built

Azure AI Search, streaming, push notifications, diagrams, licensing rules and Microsoft 365
seat prices are later steps. Where they plug in, a short comment says so. Nothing speculative
is built ahead of a brief that asks for it.

## Rule 9 — A number without provenance is a bug

Every price in an answer or a workbook carries value, currency, unit, source URL, Microsoft's
`effectiveStartDate` and the date it was fetched, and is a list price, said as such. Sizes and
numbers come from code (`pricing/`, `sizing/`); a model may only word them, and its words are
checked against them.
