# Brief — Microsoft vendor agent, step 2: prices, sizing and the estimate workbook

Work only inside `C:\magic\ms-vendor-agent`, on a new local branch `elias/step2-pricing` created
from the finished step-1 branch. Never push. Read `PROGRESS.md` from step 1 before starting, and
keep writing to it the same way: for each stage, plan + how it is verified, then the result.

There is no Docker on this laptop. Verify with `uv run pytest` and by running the app with
`uv run uvicorn`. Network calls to `prices.azure.com` are allowed for the ingestion test only;
every other test uses recorded fixtures.

## Goal of step 2

The agent can price Azure correctly, hand back an estimate a presales engineer can send, and
pass MAGIC's operator check so it can be published:

- `price_get` — list prices for Azure meters, with source and date.
- `sizing_calc` — from a workload description (vCPU, memory, OS, hours, count, region) to the
  right VM sizes and disks. Code only, no LLM.
- An **estimate workbook** (.xlsx) produced by `sizing_calc` and by `design_propose`.
- `design_propose` (first version) — MAGIC's operator check fails "Designs a solution" without
  it (finding 2 of step 1). Scope for now: Azure infrastructure only. Input: workloads as in
  `sizing_calc`, region, availability need (single zone / zone-redundant / with DR region),
  pricing models. Output, in the `vendor-agent/1` envelope: the solution part (chosen services
  and sizes by role: compute, storage, network, backup, DR), assumptions, gaps and caveats, the
  estimate totals, and the workbook link. The LLM writes the narrative and caveats only; every
  size and number comes from `sizing_calc` and `lookup`. No diagram yet (that is step 3).
- Managed identity support for Azure OpenAI, so the deployed app needs no key.

## Fixes from the first live golden run (v0.1.1, 26 Oct 2026)

Baseline against the live agent with `--judge model`: passed 5/30, cited 30/30, facts 59/117,
source hit 10/30, forbidden statements 0/30. Six answers scored 0 facts (azure-07, azure-09,
m365-01, m365-05, lic-03, lic-04) — m365-01 answered correctly in a manual test the same night,
so a zero may be a judge or retrieval failure rather than a wrong answer. Fix before anything
else in this step:

- `run_golden.py`: save in the JSON, per question, the answer text, the citations, the passages'
  URLs that were retrieved, and a per-fact verdict (`present` / `missing` / `judge_error` with the
  error). Count judge errors separately from missing facts in the summary line. Never send
  temperature, top_p or max_tokens from the judge either.
- `advice_explain` prompt: ask for a complete answer — every condition, prerequisite, limit and
  exception the passages state — before brevity; keep the citation rules.
- `advice_explain`: merge duplicate citations by URL.
- Re-run the 30 questions with `--judge model` at the end of the step and record the table in
  PROGRESS.md next to the baseline.

## Rules from MAGIC's client that every new skill must follow

Found in step 1 (`magic3-platform/modules/tools/services/authority/src/vendors.py`):

- **Forbidden field names.** MAGIC refuses to send any request field whose name contains
  customer, client, company, organization, contact, e-mail, phone, price, discount, margin,
  deal, person or people. No input schema may use such names, at any depth. Use for example
  `pricing_models` (allowed: it does not contain "price"), `region`, `workloads`, `os`; never
  `price_list`, `deal_size`, `customer_region`, `contact_email`. Add a test that walks every
  skill's input schema and fails on any forbidden substring.
- Schema defaults are stripped by MAGIC before sending, so every default must be applied by the
  agent itself.
- Every skill must be listed in the card extension `urn:magic:vendor-agent:1` with its schema,
  and in `skills[]` with at least one example.
- Answers follow the envelope already built in step 1 (`contract`, `status`, `warnings`,
  `files`, `result`, `refusal`); generated files go in `files` as links.

Every number in every answer carries: value, currency, unit, source URL, `effectiveStartDate` from
Microsoft, and the date we fetched it. A number without provenance is a bug.

## Facts about the source — read before designing

Azure Retail Prices API (public, no authentication):

- Endpoint `https://prices.azure.com/api/retail/prices`, use `api-version=2023-01-01-preview`
  (needed for savings plan prices and the full meter set).
- OData `$filter` on: `armRegionName`, `Location`, `meterId`, `meterName`, `productid`, `skuId`,
  `productName`, `skuName`, `serviceName`, `serviceId`, `serviceFamily`, `priceType`,
  `armSkuName`. **Filter values are case-sensitive** in this api-version.
- 1,000 items per page; follow `NextPageLink` until it is null.
- Item fields include `currencyCode`, `retailPrice`, `unitPrice`, `unitOfMeasure`, `type`
  (`Consumption`, `Reservation`, `DevTestConsumption`), `reservationTerm`, `savingsPlan[]`
  (`unitPrice`, `retailPrice`, `term`), `effectiveStartDate`, `isPrimaryMeterRegion`, plus the ids
  and names above.
- USD prices are Microsoft retail list prices. Other currencies (`currencyCode='EUR'` etc.) are
  "for reference". **Check at build time whether AED and SAR are accepted**; if not, store USD and
  convert in the workbook with a rate the user supplies, clearly labelled.
- Prices are list prices, not CSP/EA/MCA agreement prices. Every estimate says so.
- Windows VM meters include the Windows licence. Azure Hybrid Benefit price = the matching Linux
  meter price for the same size and region. Implement AHB this way and label it.

## What to build

```
src/ms_agent/
  pricing/
    ingest.py          pulls the Retail Prices API for a configured set of regions
                       (default: uaenorth, uaecentral, westeurope, northeurope, eastus) and
                       service families (Compute, Storage, Networking, Databases); pages through
                       NextPageLink; retries with backoff; writes to the price store
    store.py           price store behind an interface: SQLite for dev and tests,
                       PostgreSQL in Azure (SQLAlchemy 2.x, same schema); table of meters with
                       every field above + fetched_at; index on (armSkuName, armRegionName, type)
    lookup.py          price_for(arm_sku, region, os, pricing_model) where pricing_model is
                       payg | ri_1y | ri_3y | sp_1y | sp_3y | ahb; returns a Price with provenance
    vm_catalog.py      VM size specs (vCPU, memory GiB, family, generation, premium disk support)
                       from a JSON snapshot in data/vm_sizes_<region>.json; a script
                       scripts/refresh_vm_sizes.ps1 regenerates it with
                       `az vm list-skus -l <region> --resource-type virtualMachines`
                       (the Retail Prices API has no specs)
  sizing/
    vm.py              choose the cheapest size that meets vCPU and memory within allowed
                       families (default D, E, F, B; configurable), current generation preferred;
                       return the top 3 alternatives with the reason each was ranked
    disks.py           managed disks by type and size (Standard HDD/SSD, Premium SSD) priced per
                       month from the store
    estimate.py        an Estimate = list of lines (service, sku, region, quantity, unit, hours,
                       unit price per pricing model, monthly, yearly) + assumptions + sources
  estimate_workbook.py openpyxl workbook with sheets:
                       Summary (totals per pricing model side by side: PAYG, 1y RI, 3y RI,
                       1y SP, 3y SP, AHB where it applies), Lines, Assumptions, Sources,
                       Disclaimer ("list prices, not your agreement price; fetched on …").
                       Formulas, not pasted values, so a presales engineer can edit quantities.
  files.py             file store interface: local folder in dev (served at /files/<id>),
                       Azure Blob with a 24-hour read-only SAS link in Azure
  skills/
    price_get.py       input: codes or arm_sku_names or service + product filter, region,
                       pricing models; output: lines with provenance
    sizing_calc.py     input: list of workloads {name, vcpu, memory_gb, os, count,
                       hours_per_month (default 730), disks[]}, region, pricing models,
                       ahb (bool); output: chosen sizes, alternatives, estimate totals, workbook link
  llm/client.py        add managed identity: if AZURE_OPENAI_API_KEY is empty, use
                       DefaultAzureCredential with AZURE_CLIENT_ID (user-assigned identity) and
                       the scope https://cognitiveservices.azure.com/.default
jobs/
  refresh_prices.py    entry point for the Container Apps scheduled job (nightly)
data/
  vm_sizes_uaenorth.json   snapshot (create with the script if az is installed; otherwise a small
                           hand-made fixture of 10 common sizes, clearly marked as a fixture)
```

Add both skills to the registry so they appear on the agent card with their JSON schemas and
examples, in the same style as the Lenovo card's `price_get` and `sizing_calc`.

## How it is verified (show me the output)

1. `uv run pytest` passes, including:
   - pagination follows `NextPageLink` (recorded fixture with 3 pages);
   - case-sensitive filter strings are built exactly (`serviceName eq 'Virtual Machines'`);
   - monthly = hourly unit price × hours × quantity, to the cent;
   - AHB price equals the Linux meter price for the same size and region;
   - savings plan and reservation prices are read from the right fields;
   - every price object has source URL, effectiveStartDate and fetched_at;
   - the workbook opens, has the five sheets, and its Summary totals are formulas that evaluate to
     the same totals as the Python estimate.
2. Live ingestion test (network, run once, marked `@pytest.mark.live`): fetch
   `serviceName eq 'Virtual Machines' and armRegionName eq 'uaenorth' and armSkuName eq 'Standard_D4s_v5'`
   and print the PAYG Linux, PAYG Windows, 1-year reservation and 1-year savings plan prices.
3. `sizing_calc` via the REST endpoint for: 6 web servers 4 vCPU/16 GB Linux, 2 SQL servers
   8 vCPU/64 GB Windows with AHB, region uaenorth, 3-year savings plan — returns sizes, totals and a
   workbook link; open the workbook and show me the Summary sheet as a table.
4. Report in PROGRESS.md whether AED/SAR currency codes were accepted by the API.
5. `design_propose` via JSON-RPC `SendMessage`, exactly as MAGIC's client sends it, for the
   same workloads as check 3 with zone-redundant availability — returns a completed task whose
   `result` artifact has the envelope with roles, sizes, totals, caveats and the workbook link.
6. The forbidden-field-name test passes for every skill on the card.
7. A local run of MAGIC's operator check logic (read it from `vendors.py`, reproduce it in
   `tests/test_operator_check.py`) passes: card found, `vendor_describe` profile valid,
   `design_propose` present.

## Out of scope for step 2

CSP and Microsoft 365 seat prices (needs the Partner Center price list — step 4), Azure AI Search,
design_propose beyond Azure infrastructure (Microsoft 365, security, Dynamics), design_change,
diagrams, licensing rules, Postgres deployment in Azure (the store interface must
be ready for it, no more), any change outside this repository.

## Working agreement

Same as step 1: plan and verification per stage in PROGRESS.md, then do only that stage, commit at
the end of each stage on `elias/step2-pricing`, never push. Stop and write the reason in
PROGRESS.md if the API behaves differently from the facts above.
