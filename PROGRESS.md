# Microsoft vendor agent — progress

# Step 3a — diagrams with official icons, complete designs, forum exclusion

The brief is [BRIEF-step3.md](BRIEF-step3.md) (given as `ms-agent-step3-brief.md`, committed under
the name of the earlier briefs). Work happens on the local branch `elias/step3-diagrams`, created
from `main` (0.2.3) on 27 October 2026; nothing is pushed. Elias asked to run the stages without
waiting and to commit per stage.

## Step 3a — acceptance

| Brief's check | State | Evidence |
|---|---|---|
State as of 27 October 2026: implemented, verified on this laptop and committed on
`elias/step3-diagrams`; **not deployed, not pushed**.

| Brief's check | State | Evidence |
|---|---|---|
| 1. pytest passes, with the icon hash, forbidden-field and operator-check tests | done | 181 passed, 1 deselected (live); stage 5 |
| 2. `design_figure` for the DMT pilot: SVG and PNG in `out/` | done | `out/dmt-pilot.svg`, `out/dmt-pilot.png` (stage 5) |
| 3. `design_propose` for the DMT pilot: App Gateway WAF v2, OS disks, Key Vault, Log Analytics, Defender, Bastion, Backup, ASR to uaecentral, all priced; workbook and diagram links | done | Every line priced with provenance, no gaps (stage 5); `out/dmt-pilot.xlsx` |
| 4. A test that no citation URL contains `/answers/` | done | `tests/test_sources.py` (stage 4) |
| 5. Five golden questions that cited forums, re-run locally | partly | Live retrieval: forum results found and none kept (stage 4); answers not scored, no model here |
| 6. Version 0.3.0; deploy notes | done | stage 5, `docs/DEPLOYMENT.md` |

Stages: 0 facts; 1 official icons; 2 `design_figure`; 3 complete, fully priced designs; 4 sources
(forum exclusion); 5 verification, version, deploy notes.

## Stage 3a.0 — the brief's facts (done)

Plan: before building, check the facts the stages rest on: where the icons are published and on
what terms; whether the new services have meters in the Retail Prices API for UAE North and UAE
Central. Verified by reading the pages and the API (read only).

Result. No fact is wrong enough to stop; four differ in detail and are handled:

1. **Icons.** https://learn.microsoft.com/azure/architecture/icons/ (updated 2026-10-09) links
   `https://arch-center.azureedge.net/icons/Azure_Public_Service_Icons_V24.zip` (V24, July 2026
   update, 716 entries, 714 SVGs). The page's rules are: use the icons in architecture diagrams,
   training materials or documentation; "Don't crop, flip, or rotate icons. Don't distort or
   change icon shape in any way. Don't use Microsoft product icons to represent your product or
   service." It does not mention recolouring (the brief does); we do not recolour either.
   **Entra:** https://learn.microsoft.com/entra/architecture/architecture-icons publishes its own
   set (`Microsoft Entra architecture icons - Oct 2023.zip`, same terms); the Azure set has no
   plain "Microsoft Entra ID" icon, so `entra_id` comes from there. **Microsoft 365:** the Learn
   page publishes Visio and PowerPoint templates only (fwlinks), no SVG set; skipped, as the brief
   allows (3a draws Azure infrastructure only).
2. **Standard Load Balancer** has no meter under `armRegionName 'uaenorth'`: its meters are
   published under `armRegionName 'Global'` (Standard Included LB Rules and Outbound Rules 0.025
   USD/hour; Standard Data Processed 0.005 USD/GB). Ingestion adds a Global scope for it.
3. **Azure Backup** has one VM meter, "Azure VM Protected Instance", 10.0 USD/month. The size
   bands are not in the API; the Backup pricing page
   (https://azure.microsoft.com/pricing/details/backup/) states them: an instance up to 50 GB,
   over 50 GB up to 500 GB, and over 500 GB charged for each 500 GB increment (its amounts are
   filled in by script and could not be read). The 10.0 meter is the 50–500 GB band; a larger disk
   counts one unit per started 500 GB; an instance of 50 GB or less is priced as the 50–500 GB
   band, said as conservative.
4. **Tiered and capacity meters.** Log Analytics "Analytics Logs Data Ingestion" is 0.0 for the
   first 5 GB and 3.29 USD/GB from 5 GB; Application Gateway WAF v2 is a fixed 0.475 USD/hour plus
   0.019 USD per capacity-unit hour. Both need stated quantity assumptions.

Found in UAE North (consumption meters): Application Gateway 27, Backup 38, Key Vault 16, Log
Analytics 6, Microsoft Defender for Cloud 43 (Servers Plan 2 node 0.02 USD/hour), Azure Bastion 20
(Basic gateway 0.19 USD/hour), Azure Site Recovery 2 (VM replicated to Azure 25.0 USD/month), API
Management 29. **UAE Central** (the DR pair, restricted access) has ASR (25.0) and managed disk
prices (P10 27.9552 USD/month), and VM prices for `D4as_v5` but **none for `D4as_v7`**: recovery
machines there must be sizes UAE Central prices, not necessarily the primary's.

No `.env` on this laptop and no earlier golden-run JSON in the repository: check 5 cannot use the
chat model here (see stage 4).

## Stage 3a.1 — official icons

Plan: `scripts/fetch_icons.py` downloads the Azure V24 zip and the Entra zip, extracts only the
SVGs the diagrams use, with their original file names and bytes, into
`src/ms_agent/diagram/icons/azure/` (and `.../entra/`), and writes `icons/originals.json` (each
file's path in the zip and SHA-256 as read from the zip) and `icons/SOURCE.md` (version, URLs, date,
the zips' SHA-256, Microsoft's terms as written). `diagram/icons.py` maps our names (`vm`, `vmss`,
`disk`, ... `digital_twins`, plus `users`, `on_premises`, `subscription`, `waf`, `site_recovery`) to
files. Verified by `tests/test_icons.py`: every name resolves to a file; every file's SHA-256 equals
the original's; nothing else is in the folders.

Result (done): 37 icons: 36 from the Azure V24 zip, the Entra ID icon from the Entra zip. Names
mapped: the brief's 33 (`vm` ... `digital_twins`; `openai` and `foundry` both) plus `waf`,
`users`, `on_premises` (Local Network Gateway, the customer's side of a VPN), `subscription` and
`site_recovery` (Azure Site Recovery has no icon of its own; it is the Recovery Services vault's).
Where a file sits in several category folders of the zip, one copy is taken (they are the same
icon). The icons hold no `<style>`, `<image>`, script or external reference; each has 1 to 8 `id`s,
which stage 2 prefixes per use. `SOURCE.md` holds versions, URLs, sizes, `Last-Modified`, both
zips' SHA-256 and the terms as worded on the pages. `.gitattributes` marks the icons `-text`:
this laptop has `core.autocrlf=true`, which would otherwise rewrite line endings on checkout and
break the hash check. Tests (`tests/test_icons.py`, 4): every name resolves; every file's SHA-256
equals the original's; the folders hold only the mapped originals; nothing runs or fetches.
Evidence: 4 passed; ruff clean.

## Stage 3a.2 — `design_figure`

Plan: `diagram/model.py` defines the `design` object: region, DR region, availability, zones,
and components (icon kind, service name, detail such as "2 × D4as_v6, zones 1–2", placement:
outside, front, app, data, management, shared, dr; zones used). It has no field name MAGIC refuses
(the whole `design_propose` result does: `list_price_notice`, `lines_without_price`), so
`design_propose` returns this compact `design`, and `design_figure` takes it, or the request
`design_propose` takes and designs first. `diagram/svg.py` draws deterministically, in the style of
Microsoft reference architectures: region box with its subscription label, DR region box, VNet,
subnet rows (front, app, data, management) with availability-zone columns, the front door at the
top with users or the customer network outside and arrows, shared services in a side band; each
node is the official icon (inlined, every `id` prefixed per use), the service name and the detail.
`diagram/png.py` renders the PNG with resvg-py (wheels for Windows and Linux; checked) and the
Dockerfile installs a font (`fonts-dejavu-core`), since the slim image has none. Both files go to
the file store and to `files`; the result has a caption and a legend. The skill is on the card;
`design_propose` adds the diagram to its `files`. Verified by tests: the SVG passes MAGIC's
`safe_svg` (no script, no external reference), every icon is inlined with unique `id`s and its
drawing unchanged, zones and DR are drawn, the PNG is a PNG, the schema has no forbidden field.

Result (done):

- **Renderer:** resvg-py 0.5.0, wheels for `win_amd64` and `manylinux` x86_64/aarch64 (cp310-abi3),
  no system library; CairoSVG was not needed. PNG at twice the SVG's size.
- **Layout**, from the design data only: region box "Azure subscription · UAE North (uaenorth)"
  with the Subscriptions icon; VNet box; subnet rows (Front-end subnet, Application subnet, Data
  subnet, AzureBastionSubnet, each with the Subnet icon), drawn only when something is in them;
  availability-zone columns across the app and data rows, a machine node per zone with its share
  ("1 × D4as_v7"); users or the customer network outside with arrows to the front door, and from
  the front door to the HTTP workloads; shared services in a side band; the DR region as a second
  box with a dashed "replication" arrow. A sample render was checked by eye (PNG) and the label
  and arrow placement adjusted once.
- **Icons inline:** each icon's own `<svg>` is placed with `x`, `y`, `width`, `height`; every `id`
  and every `url(#…)` and `href="#…"` inside is prefixed per use (`i7-…`); the drawing is unchanged
  (a test un-prefixes a copy and compares it, attribute by attribute, with Microsoft's file).
- **The `design` object** (`diagram/model.py`): region, region name, availability, zones, DR
  region and components (kind, name, detail, placement, zones, size, count, web). `design_propose`
  now returns it as `result.design`, with `result.diagram` (`svg`, `png` links) and
  `diagram_caption`, and adds the SVG and PNG to `files` after the workbook. Each solution item
  carries its icon `kind` and `placement`, so services added in stage 3 are drawn without new
  drawing code. `design_core` (sizing and DR) is shared by both skills.
- **`design_figure`** (**contract, additive**: new skill on the card with its schema and example):
  `design` or the `design_propose` request (`workloads` ...), exactly one; result `caption`,
  `legend`, `diagram`, `design`; `files` SVG then PNG; `partial` with a warning when the PNG or the
  file store is missing.
- **Container:** `fonts-dejavu-core` installed in the runtime stage (one `RUN`, no `--mount`); CI
  checks the six skills.

Tests, `tests/test_diagram.py` (8): deterministic, passes MAGIC's `safe_svg` unchanged, no
script, image, style or external reference; ids unique and every reference resolves; an inlined
icon equals Microsoft's after un-prefixing; zones, subnets, shared band and DR drawn, one node per
zone; PNG signature and size; `design_figure` from a request (SVG then PNG links, caption,
legend); `design_propose` returns a `design` with no forbidden key and `design_figure` takes it
back; one source only. Plus the font in the Dockerfile. Evidence: 152 passed, 1 deselected; ruff
clean. The DMT pilot drawing is check 2, at the end (stage 5), when the design is complete.

## Stage 3a.3 — complete, fully priced designs

Plan:

- **Ingestion:** `MS_AGENT_PRICE_SERVICES` (default: Application Gateway, Backup, Key Vault, Log
  Analytics, Microsoft Defender for Cloud, Azure Bastion, Azure Site Recovery, API Management) is
  ingested per region after the families, and Load Balancer under `armRegionName 'Global'`, where
  Microsoft publishes it (stage 0). Fixtures re-recorded for these meters and for UAE Central.
- **Lookup:** `meter_price(store, region, service, product, sku, meter, tier)` gives any meter with
  provenance; a missing meter is an error that names service, product, SKU and meter.
- **Workloads** gain `traffic` (`http`, `tcp`, `internal`), `environment` (`production`,
  `dev_test`) and `os_disk`. B-series only for `dev_test`. Every VM gets an OS disk line (Premium SSD
  P10 Linux, P15 Windows, unless given): in `sizing_calc` and `design_propose`.
- **`design_propose`** adds, priced, each on its own estimate line with its assumed quantity on the
  Assumptions sheet: the front door by traffic (HTTP: Application Gateway WAF v2, fixed + 20
  capacity units; `third_party_apis: true`: API Management Standard v2, 1 unit; TCP: Standard Load
  Balancer, rules + 100 GB processed), Key Vault (100,000 operations a month), Log Analytics
  (0.5 GB a day per VM, the 5 GB a month free not deducted), Defender for Servers Plan 2 per VM,
  Azure Bastion Basic, Azure Backup (protected instance per started 500 GB of the VM's disks, and
  GRS backup storage at 1.5 × the protected size); with a DR region, the region pair (uaenorth →
  uaecentral), Azure Site Recovery per protected VM and replica disks priced in the DR region; the
  recovery VMs listed (same size if the DR region prices it, else the cheapest same-family size it
  does price) and not priced. Network, security, monitoring, backup and DR items carry their icon
  and placement, so the diagram shows them. Optional `connectivity` (`vpn`, `expressroute`) draws
  the customer network and the gateway, named as not priced.
- **Caveats** explain the front door choice and every assumption.

Verified by tests on recorded meters: each new line with its value, unit, provenance and assumed
quantity; the front door by traffic; B-series only for dev/test; OS disks in `sizing_calc`;
ASR and replica disks in the DR region; a missing meter named; workbook formulas still give the
Python totals with the new lines; the hand-checked totals updated.

Result (done):

- **Ingestion:** `ingest()` takes `services` (per region, after the families, replacing those
  services' rows so each is stored once) and `global_services` (Load Balancer under `Global`); the
  job reads `MS_AGENT_PRICE_SERVICES` and `MS_AGENT_PRICE_GLOBAL_SERVICES` (new settings, defaults
  as planned; `--service` on the command line). Fixtures: `scripts/record_service_fixtures.py`
  recorded 315 items into `tests/fixtures/retail_services.json` (the eight services in UAE North,
  Load Balancer Global, and for UAE Central ASR, disks and the test catalog's VM meters); step 2's
  recorded file is unchanged, so its hand-checked prices hold.
- **Meters used** (exact names; UAE North unless said): Application Gateway / Application Gateway
  WAF v2 / Standard / "Standard Fixed Cost" 0.475 and "Standard Capacity Units" 0.019 per hour; API
  Management / Standard v2 / "Standard v2 Unit" 0.9589 per hour; Load Balancer / Standard /
  "Standard Included LB Rules and Outbound Rules" 0.025 per hour and "Standard Data Processed"
  0.005 per GB (Global); Key Vault / Standard / "Operations" 0.0396 per 10K; Log Analytics /
  Analytics Logs / "Analytics Logs Data Ingestion" from 5 GB, 3.29 per GB; Microsoft Defender for
  Servers / Standard P2 / "Standard P2 Node" 0.02 per hour; Azure Bastion / Basic / "Basic Gateway"
  0.19 per hour; Backup / Azure VM / "Azure VM Protected Instance" 10.0 per month and Backup /
  Standard / "Standard GRS Data Stored" 0.0591 per GB-month; Azure Site Recovery / Azure / "VM
  Replicated to Azure" 25.0 per month (UAE Central); replica disks in UAE Central (P10 27.9552).
- **Workloads:** `traffic`, `environment`, `os_disk` (contract, additive, in `sizing_calc` and
  `design_propose`); B-series only for `dev_test` (a production workload limited to B is refused
  `no_size`, saying why); an OS disk line per workload in both skills.
- **`design_propose`:** `third_party_apis` and `connectivity` (contract, additive); new roles
  `security` and `monitoring`; every baseline item `priced: true` with its line; Entra ID and the
  VNet named "no charge"; VPN Gateway / ExpressRoute, when asked, drawn and named as not priced;
  the region pair as DR region, ASR and replica disks priced there, the recovery machines listed
  (substituted, with a caveat, when the DR region does not price the size). Caveats explain the
  front door. A missing meter is a gap naming it, e.g. "Not priced: No meter 'Basic Gateway'
  (service 'Azure Bastion', product 'Azure Bastion', SKU 'Basic') in uaenorth in the price
  store."
- **Hand-checked totals** (recorded prices): `sizing_calc` for step 2's workloads now 1117.51 USD
  a month at the 3-year savings plan (905.55 + OS disks 129.02 + 82.94); `design_propose` for the
  same workloads, zone-redundant, internal traffic: 1967.17 (+ Key Vault 0.40, Log Analytics
  121.67 GB × 3.29 = 400.29, Defender 87.60 + 29.20, Bastion 138.70, Backup instances 60.00 + 20.00,
  backup storage 1920 GB × 0.0591 = 113.47). Two expected values I first wrote by hand were wrong
  (200.15, 45.38); the code's 200.13 and 45.39 are right (60.83 × 3.29 = 200.1307,
  768 × 0.0591 = 45.3888) and the tests say so.

Tests: `tests/test_baseline.py` (9): App Gateway for HTTP and not a load balancer, API Management
for third-party APIs, Standard Load Balancer for TCP from the Global meters; every line with
provenance and every assumed quantity on the Assumptions sheet; backup bands; a missing meter
named; the workbook formulas over the new lines equal the totals; the diagram draws the complete
design with VPN; B-series by environment. Updated: `test_sizing.py` (OS disks, B-series, a given
OS disk), `test_sizing_calc.py`, `test_design_propose.py` (roles, region pair, a substituted
recovery machine), `test_ingest.py` (store holds more regions). Evidence: 163 passed, 1 deselected;
ruff clean. The suite now takes about a minute (workbooks and PNGs are rendered in many tests).

## Stage 3a.4 — sources: no forum answers

Plan: `knowledge/sources.py` decides what may be evidence: Learn documentation
(`learn.microsoft.com`, not `/answers/`), `azure.microsoft.com` (pricing and product pages), and
`www.microsoft.com` licensing pages and Product Terms (`/licensing/`). The retriever drops every
other passage before the model sees it; `advice_explain` drops a citation that is not allowed even
if the model gives one; `design_propose` drops a model caveat that names a URL that is not allowed.
The prompt says to prefer the newer of two conflicting sources and say so. Verified by tests (no
citation URL contains `/answers/`; a question whose only passages are forum answers is refused
`no_sources`) and by asking Learn live, for golden questions, which forum pages it returns.

Result (done):

- `knowledge/sources.py`: `allowed_source` (Learn except `/answers`, `azure.microsoft.com`,
  `www.microsoft.com` under `/licensing/`) and `forum`. The Learn retriever skips forum results
  before counting, so they do not take the place of documentation passages; `advice_explain`
  filters the passages of any retriever and drops a citation that is not allowed; `design_propose`
  drops a model caveat that names a page which is not allowed (`caveat_dropped`). A forum URL with
  a number in it is already caught by the number guard, which replaces the model's words
  (`narrative_replaced`). The `advice_explain` prompt gains rule 5: prefer the newer of two
  conflicting passages and say that the sources differ.
- **Check 4:** `tests/test_sources.py::test_no_citation_url_contains_answers` (a forum passage and
  a documentation passage retrieved, the model cites both: one citation, the documentation page;
  the forum text never reached the model). Also: 11 URLs classified; only forum passages →
  `no_sources`; the retriever skips forum results before its limit; a design caveat with a forum
  URL is not used, both ways.
- **Check 5, live retrieval, 27 October 2026.** The 30 golden questions asked of Learn's MCP search:
  18 questions returned forum answers among their 10 results (38 in all), and **none reaches the
  model now** (kept forum passages: 0). The five re-run:

| Question | Forum results of 10 | Passages kept (documentation only) |
|---|---|---|
| azure-08 | 3 | 6 |
| m365-05 | 2 | 8 |
| m365-02 | 4 | 6 |
| lic-03 | 5 | 5 |
| lic-04 | 5 | 5 |

  (azure-08 and m365-05 named by the brief; m365-02, lic-03 and lic-04 have the most forum
  results. lic-03 and lic-04 are two of the six questions that scored 0 facts in the baseline: half
  of what Learn returned for them was forum answers.) **Not run:** the answers and their model-judge
  scores. There is no Azure OpenAI configuration on this laptop and no earlier golden JSON in the
  repository ("the last JSON" of the brief was not found); to finish check 5, run
  `uv run python evaluations/run_golden.py --only azure-08,m365-05,m365-02,lic-03,lic-04 --judge model --json evaluations/results/step3-forum.json`
  with the `AZURE_OPENAI_*` values set.

Evidence: 180 passed, 1 deselected; ruff clean.

## Stage 3a.5 — verification, version 0.3.0, deploy notes

Plan: a live ingestion of UAE North and UAE Central (Compute, Storage, the baseline services,
Load Balancer Global); the DMT pilot through the app (in process, live store, the real 1,092-size
catalog, no model): `design_figure` writing SVG and PNG to `out/` (ignored by git), and
`design_propose`; version 0.3.0; deploy notes; every check.

Result (done):

- **Ingestion**, 27 October 2026 (22:14 UTC on the 26th): 21 scopes, none failed (UAE North
  Compute 13,535 and Storage 1,604; UAE Central Compute 9,181 and Storage 1,116; the eight services
  in both regions; Load Balancer Global 12), 17 s.
- **The DMT pilot request:** API workers 2 × Linux 4 vCPU / 16 GB, `traffic: http`; processing
  workers 2 × Linux 8 vCPU / 32 GB; `uaenorth`; `availability: with_dr`.
- **Check 2:** `design_figure` complete; `out/dmt-pilot.svg` (41,748 bytes) and
  `out/dmt-pilot.png` (176,091 bytes). Caption: "Azure architecture in UAE North, across
  availability zones, with a disaster recovery region; disaster recovery to UAE Central: 4 virtual
  machines and 9 other services, drawn with Microsoft's Azure architecture icons." Checked by eye:
  users → Application Gateway WAF v2 → the two API workers (zones 1 and 2; the processing workers,
  internal, get no arrow); AzureBastionSubnet; shared services (Entra ID, Key Vault, Defender for
  Cloud, Log Analytics, Recovery Services vault); UAE Central box with Azure Site Recovery and the
  recovery machines. One cosmetic flaw: an arrow head lands on the "Availability zone 2" label.
- **Check 3:** `design_propose` complete; files workbook, SVG, PNG; **gaps: none**. Lines,
  pay-as-you-go per month, each with meter, `effectiveStartDate`, `fetched_at` and source URL:

| Service | SKU | Quantity | USD a month |
|---|---|---|---|
| Virtual Machines | D4as_v5 | 2 | 309.52 |
| Managed Disks | P10 LRS (OS) | 2 | 43.01 |
| Virtual Machines | D8as_v5 | 2 | 619.04 |
| Managed Disks | P10 LRS (OS) | 2 | 43.01 |
| Application Gateway | WAF v2 fixed | 1 | 346.75 |
| Application Gateway | WAF v2 capacity units | 20 | 277.40 |
| Key Vault | Standard operations (10K) | 10 | 0.40 |
| Log Analytics | Analytics Logs ingestion (GB) | 60.83 | 200.13 |
| Defender for Cloud | Servers Plan 2 | 2 + 2 | 29.20 + 29.20 |
| Azure Bastion | Basic | 1 | 138.70 |
| Backup | Azure VM protected instance | 2 + 2 | 20.00 + 20.00 |
| Backup | GRS storage (GB) | 768 | 45.39 |
| Azure Site Recovery | VM replicated to Azure (uaecentral) | 4 | 100.00 |
| Managed Disks | P10 LRS replica (uaecentral) | 2 + 2 | 55.91 + 55.91 |

  Totals per month (with 20 capacity units; see the follow-up below for the default of 2): PAYG 2,333.57; 1y RI 1,978.01; 3y RI 1,771.79; 1y SP 2,036.43; 3y SP 1,887.86
  USD. Caveats: list prices; why Application Gateway WAF v2 and not a Standard Load Balancer; UAE
  Central restricted access with the access-request link; zones and pairs from Learn with the date.
  Recovery machines D4as_v5 and D8as_v5 (UAE Central prices both).
- **A fact against the brief's finding 5 (for a decision).** The DMT design got v5 sizes again,
  and the rule the brief sets ("prefer the newest generation when it meets the need at equal or
  lower price") is why: in UAE North, live prices, Dasv6 and Dasv7 cost **more** than Dasv5 at
  pay-as-you-go, both reservations and the 1-year savings plan (D4as 0.224 against 0.212 USD/hour,
  +5.7 %; D8as +5.4 %), and **less** only at the 3-year savings plan (0.10528 against 0.11024). Leading
  with pay-as-you-go, the answer chooses D4as_v5 and says "D4as_v7 ... 8.76 USD (5.7 %) more than
  D4as_v5"; leading with `pricing_models: ["sp_3y"]`, it chooses D4as_v7 and D8as_v7 (totals then
  PAYG 2,384.67, 3y SP 1,865.45). If v6/v7 should win within a margin (for example 6 %), that is a
  rule change to decide; it is not made.
- **Sources, one widening beyond the brief's list (for a decision).** The fake golden run fell to
  28/30: the golden set itself expects Microsoft 365 product pages on `www.microsoft.com`
  (m365-02, m365-03) and a `news.microsoft.com` announcement (azure-02, the Saudi Arabia East
  region). Both are first-party Microsoft pages, not forums, so `allowed_source` admits all of
  `www.microsoft.com` and `news.microsoft.com`; forums, community sites and other hosts stay
  out. Back to 30/30. If the list must stay as the brief wrote it, the golden sources of those
  three questions need changing instead.
- **Version 0.3.0** (`uv.lock` updated). **Deploy notes** in `docs/DEPLOYMENT.md`: two new
  settings with defaults (`MS_AGENT_PRICE_SERVICES`, `MS_AGENT_PRICE_GLOBAL_SERVICES`); run the
  job for `uaenorth` and `uaecentral` after the redeploy; the image adds `fonts-dejavu-core`,
  resvg-py and the icons; no new secret or role; MAGIC must check and publish again for
  `design_figure`.

Evidence: 181 passed, 1 deselected (live); the icon hash, forbidden-field and operator-check
tests among them; ruff clean; `run_golden.py --fake` 30/30.

## Follow-up, 27 October 2026: capacity units as input, private connections named

Elias asked: Application Gateway capacity units as a request input (default 2 for pilots), still
stated in the answer and on the Assumptions sheet; VPN Gateway and ExpressRoute listed by name as
"drawn, not priced" in the result and the workbook.

Result (done; still 0.3.0, not deployed):

- **Contract (additive):** `design_propose` (and `design_figure`) take `gateway_capacity_units`
  (integer, 0 to 1,000, default 2; no forbidden word, checked by the field-name test). The line says
  "Application Gateway WAF v2 capacity units: 2 every hour, assumed (request input
  gateway_capacity_units; default 2, for a pilot)", and the Assumptions sheet repeats it with the
  advice to size production from the expected load. The previous fixed 20 is gone.
- **Drawn, not priced:** with `connectivity` `vpn` or `expressroute`, the result has
  `not_priced: [{"service": "Azure VPN Gateway", "status": "drawn, not priced", "item": ...}]`, the
  gap reads "Drawn, not priced: Azure VPN Gateway (site-to-site VPN from the customer network).",
  the solution item carries `status: "drawn, not priced"`, and the workbook names it twice: a
  "Drawn, not priced" block on the Summary sheet under the workloads, and a line on the Assumptions
  sheet ("Drawn, not priced: Azure VPN Gateway (...); the estimate leaves it out."). It is in no
  total.
- **DMT pilot, live prices, re-run:** capacity units 2 → 27.74 USD a month (was 20 → 277.40); every
  total 249.66 lower: PAYG 2,083.91; 1y RI 1,728.35; 3y RI 1,522.13; 1y SP 1,786.77; 3y SP 1,638.20;
  no gaps. `out/dmt-pilot.*` rewritten.
- Tests: the default (2 → 27.74) and the assumption text; the input (20 → 277.40) on the line and
  the Assumptions sheet; a negative value refused; VPN Gateway and ExpressRoute listed by name in
  `not_priced`, the gaps, the Summary and the Assumptions sheets, and in no line. Evidence: 184
  passed, 1 deselected; ruff clean; `run_golden.py --fake` 30/30.

## Remaining after step 3a

- Golden answers for azure-08, m365-05, m365-02, lic-03, lic-04 with `--judge model` (stage 4).
- Two decisions above: generation preference across pricing models; the source list.
- Not verified here: the container build with the font (no Docker), PNG text rendering on Linux.
- Not priced: VPN Gateway and ExpressRoute (drawn and named as gaps when asked), public IP
  addresses, bandwidth, Bastion outbound data beyond 5 GB.
- Step 3b: the Azure AI Search knowledge base.

# Step 2 and its follow-ups (history)

The current state of the task. Step 2's brief is [BRIEF-step2.md](BRIEF-step2.md); step 1's
record follows below, unchanged. Step 2 happens on the local branch `elias/step2-pricing`,
created from `elias/step1-skeleton`; nothing is pushed. Elias asked on 26 October 2026 to run the
stages without waiting between them, to commit at the end of each stage, and added three
requirements to the brief: merge duplicate citations by URL in `advice_explain` (the live agent
cited the same page three times), keep the Dockerfile free of BuildKit `--mount` lines (Azure
Container Registry builds without BuildKit), and never send `temperature`, `top_p` or
`max_tokens` to the model. Every tool runs as `python -m` (see the launcher note of step 1).

## Step 2 — objective and acceptance

The agent prices Azure from the Azure Retail Prices API and hands back an estimate workbook a
presales engineer can send: `price_get`, `sizing_calc`, the `.xlsx` estimate, managed identity
for Azure OpenAI. Every number carries value, currency, unit, source URL, Microsoft's
`effectiveStartDate` and the date it was fetched.

| Brief's check | State | Evidence |
|---|---|---|
State as of 26 October 2026: implemented, verified on this laptop and committed on
`elias/step2-pricing`; **not deployed, not pushed**.

| Brief's check | State | Evidence |
|---|---|---|
| 1. `uv run pytest` passes, with the seven listed tests | done | 115 passed, 1 deselected (the live test); each listed test named in stage 7 |
| 2. Live ingestion test for `Standard_D4s_v5` in `uaenorth` | done | Linux 0.235, Windows 0.419, 1-year reservation 1272.0 per term, 1-year savings plan 0.1770725 USD/hour (stage 7) |
| 3. `sizing_calc` over REST for the six web and two SQL servers, Summary as a table | done | On live prices: 6 × D4as_v5, 2 × E8as_v5; 3-year savings plan 905.55 USD a month; Summary in stage 7 |
| 4. AED and SAR accepted by the API? | done | Yes, both (stage 0) |
| 5. `design_propose` over JSON-RPC `SendMessage`, zone-redundant | done | Completed task, roles, sizes, totals, caveats, workbook link (stage 7); the summary is the plain one, as no model is configured here |
| 6. Forbidden-field-name test for every skill on the card | done | `tests/test_operator_check.py` (stage 6) |
| 7. MAGIC's operator check reproduced in `tests/test_operator_check.py` | done | All seven checks pass (stage 6) |
| Golden fixes: evidence per question, judge errors apart, complete answers, merged citations | done | stage 1; it also found that `--judge model` was ignored with `--url` |
| Golden re-run with `--judge model`, next to the baseline | **not run** | No Azure OpenAI configuration on this laptop (no `.env`); see "Remaining" |
| Elias: duplicate citations merged by URL | done | stage 1 |
| Elias: no `--mount` in the Dockerfile | done | `tests/test_container.py` (stage 6) |
| Elias: no `temperature`, `top_p`, `max_tokens` | done | Asserted on the wire for the agent, the golden judge, the managed identity path; `design_propose` uses the same client |

The brief was extended after stage 0 was committed (`design_propose`, the golden-run fixes "before
anything else", the forbidden-field test, the operator check, checks 5 to 7). The stages were
re-planned: 0 context and the source's facts; 1 golden-run fixes; 2 the price store and
ingestion; 3 price lookup, the VM catalog and `price_get`; 4 sizing, the estimate, the workbook,
the file store and `sizing_calc`; 5 `design_propose`; 6 managed identity, card, forbidden-field
test, operator check, container and documents; 7 the live checks and the golden re-run.

## Stage 0 — context and the source's facts (done)

Plan: read the brief, step 1's record and the platform client, and check the Azure Retail
Prices API against the brief's facts with a handful of read-only requests before designing.
Verified when every fact the design rests on was seen in a real answer.

Result. The API behaves as the brief says, so the work did not stop. Seen on 26 October 2026
with `api-version=2023-01-01-preview`, filter
`serviceName eq 'Virtual Machines' and armRegionName eq 'uaenorth' and armSkuName eq 'Standard_D4s_v5'`:

| Fact | Seen |
|---|---|
| Answer shape | `BillingCurrency`, `CustomerEntityId`, `CustomerEntityType`, `Items`, `NextPageLink`, `Count`; 11 items, `NextPageLink` null |
| Filter values are case-sensitive | `'virtual machines'` gives 0 items, `'Virtual Machines'` 11 |
| Windows includes the licence | `Virtual Machines Dsv5 Series Windows` 0.419 USD/hour, the Linux meter `Virtual Machines Dsv5 Series` 0.235 |
| Savings plan | `savingsPlan` only on the Linux consumption item: 1 year 0.1770725, 3 years 0.1217535 USD/hour |
| Reservations | `type: Reservation`, `reservationTerm` `1 Year` 1272.0, `3 Years` 2444.0; `unitOfMeasure` says `1 Hour`, but the price is the whole term |
| Other items | `DevTestConsumption`, `Spot` and `Low Priority` meters share the `armSkuName`; the lookup excludes them |
| Managed disks | `Premium SSD Managed Disks`, `Standard SSD Managed Disks`, `Standard HDD Managed Disks`; the price is the meter `<tier> LRS Disk` in `1/Month`; `armSkuName` is often empty, so disks are found by product and SKU name; `... Disk Mount` (shared disks) and `Disk Operations` are other meters |
| **AED and SAR** | **Both accepted**: `currencyCode='AED'` answers `BillingCurrency: AED` (D4s_v5 Windows 1.538903 AED/hour), `'SAR'` answers SAR (1.57301). EUR too. Microsoft calls non-USD prices "for reference" |

Design consequences:

1. A reservation is a price per term. Its monthly cost per instance is the term price divided by
   12 or 36, whatever the hours; a savings plan and pay-as-you-go are hourly.
2. Reservations and savings plans cover compute only; the Windows licence is billed on top at
   its own rate. The licence rate is the Windows meter minus the Linux meter for the same size
   and region, so a Windows machine without Azure Hybrid Benefit is two estimate lines (compute,
   and licence); with Azure Hybrid Benefit it is the compute line alone, at the Linux meter
   price, as the brief asks. Both are labelled.
3. AED and SAR are accepted, so no exchange rate is needed: USD stays the stored and default
   currency (Microsoft's list price), other currencies are ingested when configured and every
   answer in them carries the warning that Microsoft gives them for reference.

Findings in MAGIC's client (`vendors.py`) that shape the design (Rule 3: the client is right):

1. **Files.** MAGIC fetches a file the envelope names only from the agent's own origin
   (`A2aAgent.fetch`: "The agent named a file on another host" otherwise), with the client key.
   An Azure Blob SAS link is on another host and would never be kept. So the workbook link is
   always `<public URL>/files/<id>` on the agent, which checks the key; in Azure the file lives
   in Blob Storage and the agent reads it from there. A 24-hour read-only SAS link is still made
   in Azure and returned as `direct_url` for a person, next to the link MAGIC uses.
2. **Field names.** MAGIC refuses a request whose field names contain `price`, `customer` and
   others. The schemas use `pricing_models`, `arm_sku_names`, `codes`, `workloads`; no field
   contains a forbidden word, and a test checks it against MAGIC's own expression.
3. **Files in the answer.** MAGIC reads the envelope's `files` (`url`, `name`, `media_type`)
   and the `url` parts of any artifact. The workbook goes in both: the envelope and an artifact
   named `files`.
4. **Reading a workbook.** MAGIC's document reader takes the cell values (`<v>`) from the sheet
   XML. A formula written by openpyxl has none until Excel recalculates, so a reader would see
   blanks. The workbook keeps the formulas and also stores each formula's computed value.

Local facts: no Docker and no Azure CLI on this laptop. The VM size snapshot is therefore the
hand-made fixture the brief allows, marked as one; `scripts/refresh_vm_sizes.ps1` regenerates it
where `az` exists.

## Stage 1 — golden-run fixes (done)

Plan: the brief's fixes from the first live golden run (baseline with `--judge model`: passed
5/30, cited 30/30, facts 59/117, source hit 10/30, forbidden 0/30). `run_golden.py` saves per
question the answer, the citations, the retrieved passage URLs and a verdict per fact
(`present`, `missing`, `judge_error` with the error), and counts judge errors apart;
`advice_explain` asks for a complete answer before a brief one, merges citations by URL, and
returns the retrieved passage URLs. Verified by `tests/test_golden.py` and new tests in
`tests/test_advice_explain.py`, the whole suite, and the fake golden run.

Result:

1. **A bug that distorts the baseline.** With `--url`, `run_golden.py` never built the model
   judge: `--judge model` was silently ignored and the keyword judge (60 % of words in common)
   scored the live run. The baseline of 59/117 facts is therefore a keyword-judge score, not a
   model-judge one. Now `--judge model` builds the judge from the environment's Azure OpenAI in
   both modes and refuses to run without it. A test proves it is used with `--url`.
2. The model judge used to turn any failure (HTTP error, an answer that is not JSON) into "fact
   missing". Now that is `judge_error` with the error text, counted apart; the summary line reads
   `facts 117/117 (missing 0, judge errors 0)`. The judge goes through the agent's chat client,
   and a test reads its request off the wire: no `temperature`, `top_p` or `max_tokens`.
3. `--json` keeps per question `answer`, `citations` (url, title, quote), `passage_urls`,
   `facts` and `forbidden` with a verdict and error each.
4. `advice_explain`: the prompt now says to state every condition, prerequisite, limit and
   exception the passages give (numbers, editions, regions, dates) before keeping it short, and
   to cite each page once. Citations are merged by canonical URL; a page cited three times is one
   citation with the first verbatim quote, and passages from the same page count together.
   **Contract (additive):** the result gains `passage_urls`, the URLs the retriever returned, so
   the golden run can tell a retrieval miss from an answer miss.

Evidence: 50 passed; ruff clean on the changed files; `run_golden.py --fake`:
`passed 30/30   cited 30/30   facts 117/117 (missing 0, judge errors 0)   source hit 30/30   forbidden said 0`.
The live re-run is stage 7.

## Stage 2 — price store and ingestion

Plan: add the dependencies of step 2 (SQLAlchemy 2, openpyxl, azure-identity,
azure-storage-blob); `pricing/store.py`, a `PriceStore` over SQLAlchemy with one table of meters
(every field of the brief, `savingsPlan` as JSON, the meter's source URL, `fetched_at`; index on
`armSkuName, armRegionName, type`), SQLite by default, the same schema on PostgreSQL by URL;
`pricing/ingest.py`, which builds the case-sensitive filters, follows `NextPageLink` until null,
retries HTTP 429, 5xx and transport errors with backoff (honouring `Retry-After`), and replaces
the rows of one region, service family and currency in one transaction; `jobs/refresh_prices.py`,
the entry point of the nightly job. Verified by `tests/test_ingest.py` with a recorded fixture of
three pages: pagination, exact filter strings, retry, the replace, every stored row with source
URL, `effectiveStartDate` and `fetched_at`; and the live test (`@pytest.mark.live`, skipped
unless asked).

Result (done): SQLAlchemy 2.1.6, openpyxl 3.1.5, azure-identity, azure-storage-blob added with
`uv add`; `uv.lock` updated. `pricing/store.py` (`PriceStore` protocol, `SqlPriceStore`),
`pricing/ingest.py` (`build_filter`, `RetailPricesClient`, `ingest_scope`, `ingest`),
`jobs/refresh_prices.py` (`--region`, `--family`, `--currency`; exit 1 when a scope failed). A
scope is replaced in one transaction, so a failed pull leaves the previous prices. Each meter's
`source_url` is a query that returns that meter again
(`...&$filter=meterId eq '<id>' and armRegionName eq '<region>' and priceType eq '<type>'`).

Recorded fixtures: `scripts/record_price_fixtures.py` recorded, once, 141 real items for
`uaenorth` into `tests/fixtures/retail_uaenorth.json`: the VM meters of the 21 sizes of the VM
catalog (committed here with it, described in stage 3) and the managed disk meters. The
three-page pagination fixture is those recorded items paged in the API's own format (absolute
`NextPageLink` with `$skip`, null on the last page). Two facts seen while recording: B-series,
F-series and `D4s_v3` have **no reservation meters** in UAE North; and a product
`Dasv5 Series Cloud Services` also carries `serviceName 'Virtual Machines'`, so the lookup must
require a product name starting with `Virtual Machines`.

Tests, `tests/test_ingest.py` (11, plus the live one): exact filter strings
(`serviceName eq 'Virtual Machines' and ...`, a quote doubled); the filter on the wire unchanged
with `api-version=2023-01-01-preview`; three pages followed through `NextPageLink`; a repeated
link stops the run; 429 with `Retry-After: 2` then 503 are retried (waits 2.0 s and 2.0 s), 400
is not, retries end; `currencyCode='AED'`; every stored meter has source URL,
`effectiveStartDate` and `fetched_at`; reservation term prices and savings plan prices kept from
their own fields (1272.0 / 2444.0; 0.1770725 / 0.1217535); a scope replaced whole, others kept;
a failed scope reported with the old prices kept. 61 passed, 1 deselected (live), ruff clean.
Live run: stage 7.

## Stage 3 — price lookup, VM catalog and `price_get`

Plan: `pricing/lookup.py` with `price_for(store, arm_sku, region, os, pricing_model)` for `payg`,
`ri_1y`, `ri_3y`, `sp_1y`, `sp_3y`, `ahb`, returning a `Price` (value as a decimal, currency,
unit, basis hourly / monthly / term, label, and every source meter with URL,
`effectiveStartDate`, `fetched_at` and the field read); reservations and savings plans are
compute only, so `windows_licence` gives the licence's hourly rate (Windows meter minus Linux
meter) with both meters as sources; `ahb` is the Linux meter, labelled; `disk_price` for managed
disks. Only `Virtual Machines ...` products, no Spot, Low Priority or Dev/Test meters.
`pricing/vm_catalog.py` reads `data/vm_sizes_<region>.json`; `scripts/refresh_vm_sizes.ps1`
regenerates it with `az vm list-skus`. `skills/price_get.py` (by `arm_sku_names`, `codes`
(meter or SKU ids), or `service_name` / `product_name`; `region`, `os`, `pricing_models`,
`currency`), registered. Verified by `tests/test_lookup.py` and `tests/test_price_get.py` on the
recorded fixtures: AHB equals the Linux meter; reservation and savings plan prices from their
own fields; every price with source URL, `effectiveStartDate` and `fetched_at`; the skill's
refusals and warnings.

Result (done). `Price` holds the value as a `Decimal` exactly as the API wrote it, and each
`Source` names the field read (`retailPrice` or `savingsPlan[3 Years].retailPrice`). From the
recorded meters: D4s_v5 Linux 0.235, Windows 0.419, 1-year reservation 1272.0 per term, 3-year
2444.0, 1-year savings plan 0.1770725, 3-year 0.1217535, licence 0.184 USD/hour; Premium SSD P10
21.504 USD/month. **Contract (additive):** new skill `price_get`, on the card with its schema
and an example. Input fields: `arm_sku_names`, `codes`, `service_name`, `product_name`,
`region` (default `uaenorth`), `os`, `pricing_models` (default `["payg"]`), `currency` (default
`USD`); every default is applied by the agent. Output: `lines` (each with `value`, `currency`,
`unit`, `basis`, `pricing_model`, `label`, `source_url`, `effective_start_date`, `fetched_at`,
`sources[]`, and `component` `vm` / `compute` / `windows_licence` for sizes), `not_found`,
`list_price_notice`. `partial` when some lines were not found; refusals `no_price`,
`prices_not_configured`, `prices_not_loaded`; warnings `windows_licence_separate`,
`ahb_not_applicable`, `reference_currency`, `truncated`. The store is opened at start; when it
cannot be, the agent still starts and the pricing skills refuse. Tests use an in-memory SQLite
store, so no file is written. The CI container check now asserts the three skills by name.

Evidence: `tests/test_lookup.py` (10) and `tests/test_price_get.py` (6); 77 passed, 1 deselected
(live); ruff clean.

## Stage 4 — sizing, estimate, workbook, file store, `sizing_calc`

Plan: `sizing/vm.py` ranks the catalog's sizes that meet vCPU and memory within the allowed
families (default D, E, F, B), current generation first, then the monthly cost per machine under
the headline pricing model (sizes without that price are excluded, with the reason), and gives
the choice and the next three with the reason for each rank; `sizing/disks.py` picks the
smallest disk tier that holds the size asked and prices it per month; `sizing/estimate.py` makes
the lines (a Windows machine without Azure Hybrid Benefit is a compute line and a licence line),
monthly per line rounded to the cent (hourly × hours × quantity; monthly × quantity; term ÷
months × quantity), totals per pricing model, assumptions and sources;
`estimate_workbook.py` writes Summary, Lines, Assumptions, Sources and Disclaimer, every total a
formula over the Lines sheet, with each formula's value cached for readers that do not
calculate; `files.py` keeps files 24 hours (local folder in development, Azure Blob with a
24-hour read-only SAS in Azure) and the agent serves them at `/files/<id>` with the key;
`skills/sizing_calc.py` returns the sizes, the alternatives, the totals and the workbook link in
the envelope's `files` and an artifact named `files`. Verified by tests: monthly = hourly ×
hours × quantity to the cent; the workbook opens, has the five sheets, and its Summary formulas,
evaluated by a small evaluator in the tests, give the Python totals; the file route; the skill.

Result (done).

- **Ranking, one change from the plan.** The first smoke run chose `B4ms` for the web servers,
  0.18 USD a month cheaper than `D4as_v5` at the 3-year savings plan, but `B4ms` has no
  reservation in UAE North, so the two reservation totals silently left out six machines. A size
  priced under every pricing model now ranks before one with gaps (after "current generation
  first"), and the reason says so ("Cheapest current-generation size priced under every pricing
  model ..."; a size with gaps: "it has no 1-year reservation, 3-year reservation price in
  uaenorth"). With `families: ["B"]` the B size is still chosen, and its reason names the gaps.
- **Columns.** The estimate always has PAYG, 1y RI, 3y RI, 1y SP, 3y SP; `pricing_models[0]`
  is the model sizes are ranked on and the headline. With `ahb: false` and a Windows workload an
  AHB column is added (pay-as-you-go, licence brought by the customer); with `ahb: true` every
  Windows machine is priced at the Linux meter in every column, labelled on its line and in the
  assumptions.
- **Workbook.** Lines: per pricing model unit price, unit, monthly
  (`=ROUND(unit*hours*quantity,2)`, `=ROUND(unit*quantity,2)` or
  `=ROUND(unit/36*quantity,2)`) and yearly (`=monthly*12`). Summary: `=SUM(Lines!...)` per
  model, the leading model's figures, and the workloads with the reason for each size.
  Assumptions, Sources (meter, product, type, field read, `effectiveStartDate`, fetched at,
  URL), Disclaimer ("List prices, not your agreement price; fetched on 2026-10-26."). The
  formulas' values are written into the file too, and Excel recalculates on opening.
- **Files.** Local folder or Azure Blob, 24 hours; `/files/<id>` with the key (401 without);
  the envelope's `files` and an artifact `files` both carry the link; in Azure a user delegation
  SAS (read only, 24 hours) is returned as `direct_url`. Without a file store the answer is
  `partial`, with the estimate and the warning `workbook_not_stored`.
- **Contract (additive):** new skill `sizing_calc` on the card; `Outcome` and the envelope can
  now carry `files`; a task with files has a second artifact `files`.

Hand-checked totals for the verification workloads (recorded prices, AHB, 730 hours): 6 ×
`D4as_v5` and 2 × `E8as_v5`; 3-year savings plan 0.11024 × 730 × 6 = 482.85 plus 0.28952 × 730 ×
2 = 422.70, total 905.55 USD a month; PAYG 1746.16; 1y RI 1077.50; 3y RI 689.77; 1y SP 1186.98.
Without AHB the SQL servers' PAYG is 1354.88, the Windows meter 0.928 × 730 × 2.

Evidence: `tests/test_sizing.py` (8), `tests/test_workbook.py` (6), `tests/test_files.py` (3),
`tests/test_sizing_calc.py` (5) and the evaluator `tests/xlsx_formulas.py`; 99 passed, 1
deselected; ruff clean.

## Stage 5 — `design_propose` (first version, Azure infrastructure)

Plan: `skills/design_propose.py` takes the workloads of `sizing_calc`, `region`, `availability`
(`single_zone`, `zone_redundant`, `with_dr`: zone-redundant plus a disaster recovery region),
`dr_region` (default: the region's pair), `pricing_models`, `ahb`, `families`, `currency`. The
sizes, the estimate and the workbook come from the same code as `sizing_calc`; zone redundancy
needs at least two machines per workload, so a count of one is raised to two and that is said.
The answer is the solution by role (compute, storage, network, backup, DR), assumptions, gaps
(what is named but not priced: load balancer, backup, Site Recovery, a DR region the store cannot
price), caveats, the totals and the workbook link. The model writes only the summary and the
caveats, from the design's facts; an answer whose summary holds a number that is not among those
facts is not used, and a plain summary built by the code replaces it (`narrative_replaced`);
without a model the plain summary is used (`narrative_not_written`). The model request goes
through `chat_arguments`, so no `temperature`, `top_p` or `max_tokens`. Verified by
`tests/test_design_propose.py` with a fake model: roles, sizes, totals, zones, the number guard,
no model, DR.

Result (done). **Contract (additive):** new skill `design_propose` on the card, second in the
registry after `vendor_describe`. Its result is `summary`, `availability`, `dr_region`,
`solution` (`compute`, `storage`, `network`, `backup`, `dr`; each item says whether it is
`priced`), `gaps`, `caveats`, then everything `sizing_calc` returns (headline, totals, lines,
assumptions, sources, VM catalog, workbook). Decisions:

- Zones: `uaenorth`, `westeurope`, `northeurope`, `eastus` are treated as zonal and the pairs
  `uaenorth`/`uaecentral`, `westeurope`/`northeurope`, `eastus`/`westus` are used for DR, from
  Microsoft's list of Azure regions; another region is designed without the zone claim. This
  table was written from knowledge, not read live in this session; a check against Learn is
  listed under "Remaining".
- Network, load balancer, backup and Site Recovery are named, not priced (their meters are not
  part of this step's lookups); each is a gap. They do not make the answer partial; a missing
  price, a DR region that could not be sized, or a missing workbook do.
- The DR region is sized with the same code; recovery machines are listed as created at
  failover and not added to the estimate. With the recorded fixtures only `uaenorth` has prices
  and a VM snapshot, so the default pair `uaecentral` gives the gap "was not sized" and a
  partial answer, and `dr_region: "uaenorth"` (test only) sizes it.
- The number guard compares the numbers of the model's summary and caveats with those of the
  facts sent to it (sizes such as `D4as_v5` included); one number that is not there replaces the
  model's words with the plain summary. A model failure or an answer that is not the JSON asked
  for falls back the same way; the design never fails because of the model.

Evidence: `tests/test_design_propose.py` (6, one of them over JSON-RPC `SendMessage` exactly as
MAGIC sends it, with zone redundancy); 105 passed, 1 deselected; ruff clean.

## Stage 6 — managed identity, operator check, field names, container, documents

Plan: managed identity in `llm/client.py` (empty key: `DefaultAzureCredential` with
`AZURE_CLIENT_ID`, scope `https://cognitiveservices.azure.com/.default`); `vendor_describe` says
what the agent now does; `tests/test_operator_check.py` reproduces MAGIC's operator check and
walks every skill's schema for forbidden field names; the Dockerfile carries `data/` and
`jobs/`, writes only under `/tmp`, and has no `--mount`, with a test that reads it; CI checks
the five skills; README, `.env.example`, AGENTS.md and the deployment record are brought up to
date; version 0.2.0. Verified by the tests named and the whole suite. (This plan was written
together with the result.)

Result (done):

- **Managed identity.** `AzureOpenAIClient` takes a key or a token provider; `from_settings`
  uses the key when it is set, else `managed_identity_token_provider(AZURE_CLIENT_ID)`. A model
  is now "configured" with endpoint and deployment alone. Tests: without a key the request
  carries `Authorization: Bearer <token>` and no `api-key`, and still no `temperature`, `top_p`
  or `max_tokens`; `DefaultAzureCredential` is built with `managed_identity_client_id` and asked
  for the Cognitive Services scope. Not verified against Azure.
- **Operator check (brief check 7).** `tests/test_operator_check.py` copies, from MAGIC's
  `vendors.py`, the card fetch without a key, the JSON-RPC 1.0 endpoint on the card's host, the
  tools from the extension's schemas, `SendMessage` with `x-api-key`, bearer and
  `a2a-version: 1.0`, and the checks in order: answers, speaks A2A, accepts the key, describes
  itself, speaks `vendor-agent/1`, designs a solution, answers in time (30 s). All pass; a wrong
  key fails "Accepts the key" with HTTP 401. Also: action names match `[a-z][a-z0-9_]{0,63}`,
  the profile fits MAGIC's limits (summary 160, advisory 300, at most four `can` lines).
- **Field names (brief check 6).** Every property of every skill's schema, at any depth
  (`properties`, `items`, `anyOf`, `$defs`), checked against MAGIC's own `FORBIDDEN_KEY`
  expression: none matches.
- **Profile.** `can`: design, size, list prices, Learn answers; the advisory names list prices
  and the nightly refresh; `knowledge` adds the Azure Retail Prices API.
- **Container.** `data/` and `jobs/` copied; `MS_AGENT_PRICE_DB_URL=sqlite:////tmp/prices.sqlite3`
  and `MS_AGENT_FILES_DIR=/tmp/ms-agent-files`, because `/app` is not writable by the agent user;
  no BuildKit `--mount` and no `# syntax=` line, which `tests/test_container.py` asserts. Not
  built (no Docker here).
- AGENTS.md: rule 8 updated; rule 9, "a number without provenance is a bug". The deployment
  record lists what a step 2 redeploy needs (PostgreSQL shared by the app and the job, the
  scheduled job, Blob Storage and its roles, the identity's client id, a new check and publish
  in MAGIC). Version 0.2.0 (`uv.lock` updated).

Evidence: 115 passed, 1 deselected (live); ruff clean; `run_golden.py --fake` 30/30.

## Stage 7 — live checks

Plan: the live test (check 2); a real ingestion of `uaenorth` Compute and Storage into a SQLite
store outside the repository; the agent under `uvicorn` against it; `sizing_calc` over REST
(check 3) with the workbook downloaded and its Summary shown; `design_propose` over JSON-RPC as
MAGIC sends it (check 5); the golden re-run with `--judge model` if a model is configured.

Result.

**Check 1**, the seven tests the brief lists, by name: pagination
`test_pagination_follows_next_page_link_through_three_pages`; exact filters
`test_the_filter_is_built_exactly_in_the_apis_case`; monthly to the cent
`test_monthly_is_the_hourly_price_times_hours_times_quantity_to_the_cent`; AHB
`test_azure_hybrid_benefit_equals_the_linux_meter_for_the_same_size_and_region`; savings plan and
reservation fields `test_reservations_are_read_from_the_reservation_meter_as_a_term_price`,
`test_savings_plans_are_read_from_the_savings_plan_field_of_the_linux_meter`; provenance
`test_every_price_object_has_source_url_effective_start_date_and_fetched_at`; the workbook
`test_the_workbook_opens_with_the_five_sheets`,
`test_summary_totals_are_formulas_that_evaluate_to_the_python_totals`.

**Check 2**, `python -m pytest -m live` (1 passed, 2.9 s):

```text
11 meters stored for Standard_D4s_v5 in uaenorth
linux    payg   0.235 USD per 1 Hour  (effective 2021-11-01T00:00:00Z, fetched 2026-10-25T22:25:56Z)
windows  payg   0.419 USD per 1 Hour  (effective 2021-11-01T00:00:00Z, fetched 2026-10-25T22:25:56Z)
linux    ri_1y  1272.0 USD per 1 Year  (effective 2026-06-01T00:00:00Z, fetched 2026-10-25T22:25:56Z)
linux    sp_1y  0.1770725 USD per 1 Hour  (effective 2021-11-01T00:00:00Z, fetched 2026-10-25T22:25:56Z)
```

Ingestion: `jobs/refresh_prices.py --region uaenorth --family Compute --family Storage` stored
13,535 Compute and 1,604 Storage meters in 24 s, no failure. Times are UTC (02:26 on 26 October
in the UAE), so the workbook says "fetched on 2026-10-25".

**Check 3**, `sizing_calc` over REST against `uvicorn` on the live store: `complete` in 0.6 s,
warning `vm_catalog_fixture` only. 6 × `Standard_D4as_v5` (alternatives D4s_v5 +8.40 USD,
E4s_v5, D8as_v5) and 2 × `Standard_E8as_v5` with AHB (alternatives E8s_v5 +2.96 USD, D16s_v5,
E16s_v5). Workbook link `http://127.0.0.1:8080/files/<id>`: 401 without the key, the file with
it; sheets Summary, Lines, Assumptions, Sources, Disclaimer. Summary, as stored in the file
(every total is a formula, `=SUM(Lines!J2:J3)` and so on):

| Pricing model | PAYG | 1y RI | 3y RI | 1y SP | 3y SP |
|---|---|---|---|---|---|
| Monthly (USD) | 1,746.16 | 1,077.50 | 689.77 | 1,186.98 | 905.55 |
| Yearly (USD) | 20,953.92 | 12,930.00 | 8,277.24 | 14,243.76 | 10,866.60 |
| Lines without a price | 0 | 0 | 0 | 0 | 0 |

Leading pricing model: 3-year savings plan, 905.55 a month, 10,866.60 a year. "List prices, not
your agreement price; fetched on 2026-10-25." No AHB column, because AHB is applied to the SQL
servers in every column. The live totals equal the hand-checked ones of stage 4 (the recorded
prices are the same day's).

**Check 5**, `design_propose` over JSON-RPC `SendMessage` with `x-api-key`, bearer and
`a2a-version: 1.0`, zone-redundant: task `TASK_STATE_COMPLETED`, envelope `complete`; compute
6 × D4as_v5 and 2 × E8as_v5 "across availability zones 1, 2 and 3"; network (virtual network,
Standard Load Balancer, zone-redundant, not priced); backup (not priced); the same totals; gaps
"Not priced: Azure Load Balancer ..." and "Not priced: Azure Backup ..."; caveats (list prices,
AHB eligibility, gaps, hand-made VM snapshot); the workbook link in the result and in the
artifact `files`. The summary is the plain one (`narrative_not_written`): no model here.

**Golden re-run: not run.** There is no Azure OpenAI configuration on this laptop, and the
deployed agent is still 0.1.1. The baseline (5/30 passed, 59/117 facts) was scored by the keyword
judge, not the model judge (stage 1, finding 1), so the next run with `--judge model` is the first
real model-judge score and is not comparable with it.

## Remaining after step 2

- **Golden re-run** with `--judge model`: put the `AZURE_OPENAI_*` values in `.env` and run
  `uv run python evaluations/run_golden.py --judge model --json evaluations/results/step2.json`
  (in process, 0.2.0), or deploy 0.2.0 and add `--url <agent> --key <client key>`. Record the
  table here next to the baseline.
- **Not verified against Azure:** managed identity for Azure OpenAI, Blob Storage and its SAS
  link, the container build (no Docker here), the model-written summary of `design_propose`.
- **Deployment** needs PostgreSQL shared by the app and the nightly job (with SQLite in `/tmp`,
  each container has its own empty store), the scheduled job, a storage account; listed in
  `docs/DEPLOYMENT.md`. Then MAGIC must check and publish the agent again.
- **VM catalog:** only `uaenorth` has a snapshot (real since 0.2.1); run
  `scripts/refresh_vm_sizes.ps1` for the other priced regions. Without one, sizing there refuses
  `region_not_supported`, and the default DR pair `uaecentral` is reported as a gap.
- **Not priced yet:** load balancer, public IP, bandwidth, backup, Site Recovery (the meters are
  ingested under Networking and Storage, but no lookup reads them).
- Prices in AED or SAR need `MS_AGENT_PRICE_CURRENCIES=USD,AED,SAR` before the job runs.
- `price_get` and `sizing_calc` answer within the request; a long design is a step 3 extension
  point for streaming.

## Step 2 follow-ups, 0.2.1 (26 October 2026)

Elias's instructions of 26 October: the real VM list, the region data read from Microsoft Learn,
the PostgreSQL driver, version 0.2.1, one commit per part, nothing pushed.

### Part 1 — the real VM size list (done)

Plan: `data/vm_sizes_uaenorth.json` is now the output of `az vm list-skus -l uaenorth` of 26
October 2026 (1,092 sizes, shape `{region, source, generated, sizes: [{name, family, vcpus,
memory_gb, premium_io, hyperv_generations, accelerated_networking}]}`). Read that shape; remove
the "hand-made fixture" warning from answers; keep a small fixture only in the tests; on equal
price prefer the newest generation (v7, v6, then v5). Verified by tests on the real file, the
test fixture and the tie rule, and by sizing the verification workloads on the live UAE North
prices.

Result:

- `vm_catalog.py` reads the `az` shape. Azure's `family` (`StandardDsv6Family`) is kept as
  `quota_family`; sizing uses the series letters of the name (`D`) and the generation `_v<n>`
  (none is 1). It reads `utf-8-sig`, since PowerShell may write a byte order mark.
  `refresh_vm_sizes.ps1` now writes this same shape.
- **Ranking rule changed, as asked:** price first, then the newest generation on a tie
  (before: current generation first, then price). A size priced under every pricing model still
  ranks before one with gaps, so the side-by-side columns stay complete.
- **Two exclusions the real list needed** (not in the instruction; my decision, easy to revert):
  Arm64 sizes (`D4ps_v6`, `E8pds_v6`: Windows and most x64 software do not run on them, and they
  are often the cheapest) and the 221 constrained-core sizes (`E8-4s_v5`: the parent's price with
  fewer active cores, for per-core licensing) are never chosen automatically. Each is listed
  under `excluded` with its reason (at most ten listed, then a count).
- The warning `vm_catalog_fixture` and its assumption and caveat are gone. The assumption now
  names the source and date: "VM specifications come from `az vm list-skus` for uaenorth, read on
  2026-10-26. Arm64 and constrained-core sizes are not chosen automatically." `vm_catalog` in the
  result is `{region, source, generated, sizes}`.
- Tests: `tests/fixtures/vm_sizes_uaenorth.json` holds 24 sizes copied from the real file (the 21
  the recorded prices cover, plus D4s_v6, D4ps_v6 and E8-4s_v5); the test settings point at it.
  New tests read the real file (1,092 sizes; D4s_v6 4 vCPU, 16 GiB, v6, `StandardDsv6Family`;
  newest D generation 7; Arm64 and constrained flags), check that the fixture is a part of it,
  and check the tie rule (D4as_v7, v6, v5 at the same cost rank 7, 6, 5; a cheaper v5 still
  wins) and the exclusions.
- Speed: with 1,092 sizes the first run took 14.4 s, because each candidate was read from the
  store once per pricing model. A per-sizing cache of the store's answers brought it to 2.0 s
  with the same totals.

Live check, the verification workloads on the live UAE North prices of 25 October 22:26 UTC,
3-year savings plan, AHB: the web servers now get **Standard_B4as_v2** (72.67 USD a month per
machine; B v2 has reservations in UAE North, so it is priced under every model), with the
warning `burstable_size`; next are D4as_v7 and D4as_v6 at 76.85. The SQL servers get
**Standard_E8as_v7** (201.74; it ties with E8as_v6 and the newer generation wins). Totals per
month: PAYG 1,651.26, 1y RI 973.00, 3y RI 626.72, 1y SP 1,186.28, 3y SP 839.52 USD (before,
with the 21-size fixture: 3y SP 905.55). **For a decision:** B is in the default families, as
the brief says; for steady production load, `families: ["D", "E"]` or
`MS_AGENT_VM_FAMILIES=D,E,F` would give D4as_v7.

Evidence: 117 passed, 1 deselected; ruff clean.

### Part 2 — region facts read from Microsoft Learn (done)

Plan: replace the zone and pair table of `design_propose`, written from memory, with data read
through the Microsoft Learn MCP server from the regions list and the region pairs pages, for
`uaenorth`, `uaecentral`, `westeurope`, `northeurope`, `eastus`, `eastus2`, `swedencentral`;
store it with the source URLs and the date read; `design_propose` cites it. Verified by tests:
UAE North has 3 availability zones; UAE Central has none and is restricted access; they are a
pair.

Result:

- `scripts/refresh_regions.py` fetches
  `https://learn.microsoft.com/azure/reliability/regions-list` and
  `https://learn.microsoft.com/azure/reliability/regions-paired` with `microsoft_docs_fetch`,
  parses the first table of each (the "All" tab), and writes `data/azure_regions.json` (read
  2026-10-26 19:47 UTC). It refuses to write when the two pages disagree on a pair. With
  `--save-pages` it keeps the two pages, byte for byte, in `tests/fixtures/` for the parser tests.
  The parser and the loader are `src/ms_agent/regions.py`.
- What the pages say, for the seven regions:

| Region | Zones | Access | Paired with |
|---|---|---|---|
| UAE North (Dubai) | 3 | open | UAE Central (restricted) |
| UAE Central (Abu Dhabi) | none | **restricted** | UAE North |
| West Europe | 3 | open | North Europe |
| North Europe | 3 | open | West Europe |
| East US | 3 | open | West US |
| East US 2 | 4, marked "coming soon" on the page | open | Central US |
| Sweden Central | 3 | open | Sweden South (restricted) |

  My memory table had the pairs right, but it lacked UAE Central's restricted access, East US 2
  and Sweden Central. East US 2's "4 (coming soon)" is stored as printed, with that note.
- `design_propose`: zones come from the data ("across availability zones 1, 2 and 3"; for a
  region without zones, "one zone: the region has no availability zones", with a caveat); the
  default DR region is the stored pair. Each compute item carries `zones_source`; the result has
  `region_facts` (the facts of the primary and DR regions, and the two sources with their read
  dates). The caveats always end with the code's own cited caveats, whatever the model writes:
  "Availability zones and region pairs are from Microsoft Learn (regions-list, regions-paired),
  read on 2026-10-26." For DR to a restricted region: "UAE Central is a restricted-access region
  (regions-list URL): the subscription needs an access request before it can be used for
  disaster recovery (access request URL)." The facts sent to the model include them, so the
  number guard accepts their numbers.
- Tests, `tests/test_regions.py`: the three facts asked; all seven regions with sources and read
  date; the parser on the saved pages agrees with the stored data; pages that disagree on a pair
  are refused. `tests/test_design_propose.py`: the design cites the facts and sources; the
  restricted-access caveat for DR to UAE Central; a region without zones.

Evidence: 125 passed, 1 deselected; ruff clean.

### Part 3 — the PostgreSQL driver (done)

Plan: add `psycopg[binary]` so `MS_AGENT_PRICE_DB_URL=postgresql+psycopg://...` works; the tests
keep SQLite. Verified by a test that the URL builds a SQLAlchemy engine with the `psycopg`
driver, without reaching a database.

Result: `uv add "psycopg[binary]>=3.2"` installed psycopg 3.3.6 with its binary package (and
`tzdata`); `uv.lock` updated. `tests/test_store_postgres.py`: a `postgresql+psycopg://` URL gives
dialect `postgresql`, driver `psycopg`; an unreachable PostgreSQL store (127.0.0.1, port 1,
`connect_timeout=2`) makes `open_price_store` return None, so the agent starts and the pricing
skills refuse `prices_not_configured`. `store.py`, `.env.example` and the deployment record no
longer say the driver is missing. **Not verified:** a real PostgreSQL database (none here); the
first run creates the table and its indexes there, as on SQLite.

Evidence: 127 passed, 1 deselected; ruff clean.

### Version 0.2.1 (done)

`pyproject.toml` 0.2.1, `uv.lock` updated, the version test and the deployment record follow.
Final checks: 127 passed, 1 deselected (live); ruff clean; `run_golden.py --fake` 30/30. Four
commits on `elias/step2-pricing` (real VM list, region facts, PostgreSQL driver, this one);
nothing pushed, nothing deployed. The golden re-run with `--judge model` is still open (no Azure
OpenAI configuration on this laptop).

## The vendor logo, 0.2.2 (27 October 2026, branch `elias/logo`)

Plan (Elias's instruction): serve `src/ms_agent/static/microsoft-logo.png` (given, not to be
modified) publicly at `/logo.png` as `image/png`; `vendor_describe` returns
`logo_url = MS_AGENT_PUBLIC_URL + "/logo.png"`, on the card's host as MAGIC requires; the
Dockerfile carries the file; tests; version 0.2.2. Verified by tests.

Result (done):

- `GET /logo.png` answers the file's bytes, `image/png`, `cache-control: public, max-age=86400`,
  with no key, like the card. `vendor_describe` returns `logo_url`, built from
  `MS_AGENT_PUBLIC_URL`, so it is on the same host as the card's JSON-RPC endpoint.
- Image: the build stage already copies all of `src/` and the runtime stage copies `/app/src`, so
  the file travels with the package; the Dockerfile now says so, and a test pins both lines.
- The image file is unchanged: git blob `a3d5d7f894dd5edcb4f5ade01378a83a668d61c9` (PNG, 270 × 169),
  asserted by `tests/test_logo.py`.
- **Finding, for a decision.** MAGIC's operator check (`vendors.py`, last changed 20 October 2026)
  fetches `logo_url` from the agent's host (with the key; a public route is fine) and keeps it
  only when it is a plain SVG (`safe_svg`: an `<svg>` root, no script, no external reference).
  A PNG is therefore not kept: the optional check "Sends its logo" fails and MAGIC shows the
  agent's name instead. Publishing is not blocked (`required=False`). To show a logo, MAGIC needs
  an SVG, at `logo_url` or inline as `logo_svg`, or MAGIC's client must change to accept PNG.
  `tests/test_operator_check.py` now reproduces this optional check and records that it fails
  for the PNG, while every required check passes.

Evidence: 131 passed, 1 deselected; ruff clean. Nothing pushed, nothing deployed.

## The SVG logo, 0.2.3 (27 October 2026, branch `elias/logo-svg` from `elias/logo`)

Plan (Elias's instruction): MAGIC keeps only SVG logos. Add `src/ms_agent/static/microsoft-logo.svg`
with exactly the given content; serve it without a key at `/logo.svg` as `image/svg+xml`; keep
`/logo.png`; `vendor_describe` returns `logo_svg` (the file's text) and `logo_url` =
`MS_AGENT_PUBLIC_URL + "/logo.svg"`. Copy MAGIC's `safe_svg` into the tests and check the SVG
passes it unchanged. Version 0.2.3. MAGIC's `safe_svg` and its tests (`test_vendors.py`: four
refused pictures, one kept) were read first.

Result (done):

- The SVG file is exactly the given 298 bytes (no trailing newline); a test compares it byte for
  byte. `GET /logo.svg` answers it as `image/svg+xml` with no key; `GET /logo.png` is unchanged
  (same bytes, git blob `a3d5d7f8…`).
- `vendor_describe`: `logo_svg` is the file's text, read as bytes and decoded so no newline is
  translated; `logo_url` is `<public URL>/logo.svg`, on the card's host. MAGIC takes `logo_svg`
  first and fetches `logo_url` only without it, so either way it gets the SVG.
- `tests/magic_safe_svg.py` is MAGIC's `safe_svg` and `MAX_LOGO` copied unchanged (vendors.py,
  commit ac47ab154). A one-off comparison of the function's source in both files, by `ast`,
  gave "same source: True". Running MAGIC's own function from its file on our SVG returned it
  unchanged; on the PNG it returned None. One nuance against the instruction's summary: `safe_svg`
  does not refuse every `<style>`, only one with `@import` or an external `url(`. Our SVG has no
  style either way.
- Tests: `/logo.svg` 200 `image/svg+xml` without a key; `logo_svg` equals the file; `logo_url` on
  the card's host; our SVG passes `safe_svg` unchanged, inline and as fetched; the PNG does not;
  the copied `safe_svg` refuses MAGIC's own four bad pictures and `<html/>`. The operator-check
  reproduction now follows MAGIC's order (`logo_svg`, else the fetched `logo_url`) with the copied
  `safe_svg`: **every check passes, the optional "Sends its logo" too**.

Evidence: 139 passed, 1 deselected; ruff clean; `run_golden.py --fake` 30/30. Nothing pushed,
nothing deployed.

# Step 1 — progress (history)

The current state of the task. The brief is [BRIEF-step1.md](BRIEF-step1.md). Work happens on
the local branch `elias/step1-skeleton`; nothing is pushed. Elias asked on 25 October 2026 to
run the stages without waiting between them, so the stages below were planned, built and
verified in one session and committed in sequence at the end; this file is in every commit.

## Objective

A running container that exposes the `vendor-agent/1` contract over A2A (Agent-to-Agent, the
protocol MAGIC uses to reach a vendor agent) and answers a Microsoft question with citations.
Two skills: `vendor_describe` and `advice_explain`. Acceptance is the "How it is verified" list
of the brief; the parts that need Docker or a real Azure OpenAI endpoint are replaced here by
`uv run pytest`, `uv run uvicorn` and fakes, as Elias asked.

## Acceptance, as of 25 October 2026

| Brief's check | State | Evidence |
|---|---|---|
| 1. `uv run pytest` passes | done | 39 passed (`uv run python -m pytest -q`; see the launcher note below) |
| 2. `docker build`, `docker run`, the four HTTP checks | partly | No Docker on this laptop. The Dockerfile is written, not built. The four checks ran against `uvicorn` instead: `/healthz` 200; the card with 2 skills; `vendor_describe` with the key gives the profile; without the key 401 (stage 5 below) |
| 3. Real Azure OpenAI answers the Copilot question with a `learn.microsoft.com` citation | not run | Skipped on Elias's instruction; the model is exercised through fakes. The Learn retriever was run live once: 8 passages from `learn.microsoft.com` for that question (stage 3) |
| 4. `run_golden.py` prints the score table | done | 30 real questions, `--fake` run passes 30/30 (stage 4) |

## Stage 0 — context read (done)

What the platform's client side expects, from `magic3-platform/modules/tools/contracts/current/vendors.md`
and `modules/tools/services/authority/src/vendors.py` (the only code that calls a vendor agent):

| Topic | What MAGIC does | Where |
|---|---|---|
| Finding the card | `GET` the address itself when it ends in `.json`, else `<address>/.well-known/agent-card.json`, then `<origin>/.well-known/agent-card.json`. No key is sent. The card must have a `skills` list. | `A2aAgent.card`, `CARD_PATH` |
| Endpoint | The `supportedInterfaces` entry with `protocolBinding: "JSONRPC"` and `protocolVersion: "1.0"`; it must be on the card's own host. The `HTTP+JSON` interface is never called. | `A2aAgent._read` |
| Key | Sent in the header the card's `apiKeySecurityScheme` names (`x-api-key`), and as `Authorization: Bearer <key>`; also the header `a2a-version: 1.0`. HTTP 401 or 403 means "key refused". | `A2aAgent._headers`, `rpc` |
| Request | JSON-RPC 2.0 `SendMessage` with `params.message = {messageId, role: "ROLE_USER", parts: [{"data": {"skill", "request"}}], metadata: {skill}}` and `params.configuration.acceptedOutputModes = ["application/json"]`. | `A2aAgent.call` |
| Answer | `result` is a task or `{"task": task}`. A task has `id`, `status.state` (`TASK_STATE_COMPLETED`, `_WORKING`, `_SUBMITTED`, `_INPUT_REQUIRED`, `_FAILED`, `_AUTH_REQUIRED`), `status.message.parts[].text` for a sentence to a person, and `artifacts[]`; the artifact named `result` holds one data part with the envelope. A working task is polled with `GetTask {id}` every 2 seconds and cancelled with `CancelTask` after 180 seconds. | `A2aAgent.call`, `_a2a_result` |
| Envelope | `{"contract": "vendor-agent/1", "status": "complete" or "partial" or "failed", "warnings": [{code, message}], "files": [], "result": {...}, "refusal": {code, message, question?}}`. `status: failed` makes the answer an error for the model; the refusal's words stay in the answer. | `_a2a_result`, `Vendors.ask` |
| Streaming | Only when the card says `capabilities.streaming: true`, by `SendStreamingMessage` over server-sent events; otherwise `SendMessage` and polling. | `A2aAgent.call`, `streamed` |
| Skill schemas | From the card extension `urn:magic:vendor-agent:1`, `params.schemas[<skill id>]`; without it, from the skill's `examples`. Defaults in a schema are stripped from the request before sending, so the vendor applies them. | `A2aAgent.tools`, `without_defaults` |
| `vendor_describe` | Called at the operator's check with an empty request. Its `result` must have `name` or `vendor`; read also: `summary`, `product_lines`, `can`, `region`, `data_date`, `agent_version`, `maintained_by`, `endorsed_by_vendor`, `request_retention_days`, `contract_versions` (must contain `vendor-agent/1`), `advisory`, `logo_svg` or `logo_url` (same host). | `profile_of`, `Vendors.check` |
| `request_id` | The authority adds a random `request_id` to every request; the vendor echoes it. Field names containing customer, client, company, organization, contact, e-mail, phone, price, discount, margin, deal, person or people are refused before the request leaves. | `Vendors.ask`, `FORBIDDEN_KEY` |

The Lenovo card (`lenovo-agent-card.json`) matches this client: JSON-RPC and HTTP+JSON
interfaces, `apiKey` scheme on `x-api-key`, the extension with one schema per skill, skills
with `id`, `name`, `description`, `tags`, `examples`, `inputModes`, `outputModes`. Its
`vendor_describe` schema is an empty object with optional `request_id` and `role`; its
`advice_explain` schema is `question` (3 to 1000 characters, required), optional `part`,
`request_id`, `role`, `additionalProperties: false`. **No contract difference between the
Lenovo card and MAGIC's client was found, so the work did not stop.**

Differences between the brief and what MAGIC actually does, and what was decided:

1. The brief names the card route `/.well-known/agent.json`; MAGIC fetches
   `/.well-known/agent-card.json` and never the other. Both routes serve the same card.
2. The operator's check marks "Designs a solution" as failed when `design_propose` is missing.
   Step 1 has no `design_propose` (out of scope in the brief), so the agent can be checked and
   `advice_explain` tested, but a MAGIC operator cannot publish it until step 2 adds a
   `design_propose`. Recorded, not built.
3. The Lenovo card says `streaming: true`. Step 1 answers within one request, so the card says
   `streaming: false` and `pushNotifications: false`; MAGIC then sends `SendMessage` and reads
   the finished task. Nothing is lost at step 1; streaming is an extension point for step 2.
4. MAGIC never calls the HTTP+JSON interface; it is kept for `curl` and for the golden run.

Local environment facts: there is no Docker and no `uv` on this laptop; Python 3.13 is the
system Python. `uv` 0.13.5 was unpacked from its wheel into `.tools/` (ignored by git), with its
cache and its managed Python 3.12.15 under `.tools/` too, so nothing is written outside this
folder. Two side effects of `uv python install` outside the folder were found: a shim
`~/.local/bin/python3.12.exe`, which was deleted again, and a registry entry
`HKCU\Software\Python\Astral` that registers the managed Python; it is harmless and was left
in place.

Launcher note: this laptop refuses to run the small launcher executables that `uv` and `pip`
generate (`.venv\Scripts\python.exe` as `uv` makes it, `pytest.exe`, `uvicorn.exe`): "Access is
denied", while the real interpreter and `ruff.exe` run. The cause was not identified (reading
the AppLocker and code-integrity event logs was not permitted in this session). Two
workarounds, both inside the folder: the virtual environment is created with the standard
library's `python -m venv` and then filled by `uv sync`, and the commands are
`uv run python -m pytest` and `uv run python -m uvicorn ...`, which run the same programs as
`uv run pytest` and `uv run uvicorn`. The README says so; CI uses the plain commands.

The Microsoft Learn MCP server at `https://learn.microsoft.com/api/mcp` was probed read-only:
it speaks MCP (Model Context Protocol) `2025-06-18` over Streamable HTTP, answers with
server-sent events and a session header, and offers `microsoft_docs_search` (ten passages of
`title`, `content`, `contentUrl`), `microsoft_docs_fetch` and `microsoft_code_sample_search`.

## Stage 1 — layout (done)

Plan: create the repository skeleton of the brief: `pyproject.toml` with `uv`, `.gitignore`,
`.env.example` with names only, `README.md`, `AGENTS.md`, `settings.py`, `log.py`, the
packages. The golden questions move to `evaluations/`. Verified when `uv sync` resolves and
installs the dependencies, `uv run ruff check .` passes and `git status` shows no secret file.

Result: `uv sync` installed FastAPI 0.162, Pydantic 2.14, openai 3.37, httpx 0.28 into
`.venv` under Python 3.12.15; `uv.lock` is committed. `ruff check .` passes. `.env` is ignored;
`.env.example` holds names only. Ruff's line length is 120, as the platform's code is written.

## Stage 2 — contract (done)

Plan: `contract.py` with the envelope (`{"skill", "request"}` in, the `vendor-agent/1` answer
out), echo of `request_id` and `role`, the refusal shape, the usage block; `auth.py` with the
`x-api-key` check; `card.py`; `main.py` with the four routes and the JSON-RPC methods
`SendMessage`, `GetTask`, `CancelTask`. Verified by `tests/test_contract.py` and
`tests/test_card.py`.

Result: 17 tests in `test_contract.py` (healthz, 401 without or with a wrong key on both
bindings, the bearer form, refusal to start without keys, envelope shape, echo of
`request_id` and `role` on success and on refusal, `unknown_skill`, `bad_request` naming the
field, an unknown field refused, malformed bodies, `SendMessage` giving a completed task whose
`result` artifact carries the envelope, a text part holding the JSON, `GetTask` and
`CancelTask`, a refused skill as `TASK_STATE_FAILED` with the refusal in the artifact, the
JSON-RPC error codes, and the log line that holds the request number and never the question)
and 6 in `test_card.py` (both card routes, two skills with schemas, `advice_explain` requiring
`question` with `additionalProperties: false`, the JSON-RPC endpoint on the card's host,
`x-api-key`, the same top-level, capability, skill and interface keys as the Lenovo card, and
the same `advice_explain` fields as Lenovo's). Decisions: a refusal is an envelope with
`status: failed`, HTTP 200, never an HTTP error, because MAGIC reads the refusal from the
artifact; the only HTTP errors are 401 for the key and 400 for a body that is not JSON. The
`usage` block sits at the envelope's top level, next to `result`.

## Stage 3 — skills and knowledge (done)

Plan: `skills/vendor_describe.py`, `skills/advice_explain.py`, `knowledge/learn_mcp.py`,
`knowledge/retriever.py`, `llm/client.py`. An answer without at least one citation that points
at a retrieved page is refused with `no_citation`. Verified by `tests/test_vendor_describe.py`
and `tests/test_advice_explain.py` with a fake retriever and a fake model.

Result: 4 tests for the profile (name, vendor, `contract_versions`, product lines, skills,
version, today's `data_date`, echo, no model or retriever needed) and 12 for `advice_explain`:
answer, citations and usage on success; the model sees only the question, the part and the
numbered passages; no citation is `no_citation` with no result; a citation to a page that was
not retrieved is dropped (`citation_dropped` warning) and alone leads to `no_citation`; the
same page in another spelling (locale segment, fragment, case) still counts; a quote that is
not verbatim in the passage is replaced by the passage's opening with a `quote_not_verbatim`
warning; `no_sources`, `sources_unavailable`, `model_not_configured`, `bad_model_output`,
`bad_request`. Live check of the retriever, once, read-only: the Copilot question of the brief
gave 8 passages from `learn.microsoft.com`, the first four from "Microsoft Copilot" (service
description) and "License options for Microsoft Copilot". The Learn client keeps a session,
re-initializes once on HTTP 404, and reads both JSON and event-stream answers.

## Stage 4 — tests and golden run (done)

Plan: the whole suite under `uv run pytest`; `evaluations/run_golden.py` reads
`expected_facts`, `must_not_say` and `sources` of the 30 questions, scores each answer and
prints a table; it runs end to end with fakes (`--fake`) and against a running agent (`--url`).

Result: 39 passed in 0.5 s. `run_golden.py` validates the file's structure with Pydantic
(`id`, `domain`, `difficulty`, `question`, `expected_facts`, `must_not_say`, `sources` with
`url`, `title`, `checked`, `notes`; anything else fails the run), asks each question, and
scores: cited, cited on a Microsoft domain, an expected source hit (by canonical URL), expected
facts present, forbidden statements said, seconds, pass. Judges: `--judge keyword` (default,
no model: a fact counts at 60 % of its content words, a forbidden statement only word for word,
because words in common cannot tell "no availability zones" from "three availability zones")
and `--judge model` (the chat model, in substance). The `--fake` run builds the passages and
the answers from the file itself and proves the plumbing, not the agent:

```text
passed 30/30   cited 30/30   facts 117/117   source hit 30/30
```

The real run (`uv run python evaluations/run_golden.py`, or `--url` against a running agent)
needs Azure OpenAI and was not run.

## Stage 5 — CI and container (done, container not built)

Plan: `.github/workflows/ci.yml` (ruff, pytest, the fake golden run, docker build and the four
HTTP checks against the container on pull request) and the multi-stage `Dockerfile` (uv image
builds the environment, `python:3.12-slim` runs it as a non-root user, port 8080, health
check). Verified by reading, since Docker is absent; the server is started with `uvicorn` and
the four checks of the brief run against it.

Result, against `uv run python -m uvicorn ms_agent.main:create_app --factory --port 8080` with
`MS_AGENT_API_KEYS=dev-key`:

```text
GET /healthz -> 200 {'status': 'ok', 'version': '0.1.0'}
GET /.well-known/agent-card.json -> 200 skills: ['vendor_describe', 'advice_explain'] endpoint: http://127.0.0.1:8080/a2a/microsoft
GET /.well-known/agent.json -> 200 same card: True
POST rest vendor_describe with key -> 200 complete Microsoft vendor agent data_date 2026-10-25
POST rest vendor_describe without key -> 401 {'error': 'unauthorized', 'message': 'Send a valid client key in x-api-key.'}
POST jsonrpc SendMessage -> 200 TASK_STATE_COMPLETED artifact: result request_id echoed: r-1
POST rest advice_explain without Azure OpenAI -> 200 failed {'code': 'model_not_configured', ...}
```

The server's log lines are JSON with `request_id`, `skill`, `status`, `duration_ms`,
`prompt_tokens`, `completion_tokens`, `refusal`, and no request field. The Dockerfile and the
workflow are unverified on this laptop; the first pull request will run them.

## Remaining after step 1

- Verification 2 of the brief (`docker build`, `docker run`) is not run on this laptop.
- Verification 3 (a real Azure OpenAI endpoint answering the Copilot question) is not run; the
  model client is exercised only through fakes. To run it: put the `AZURE_OPENAI_*` values and
  `MS_AGENT_API_KEYS` in `.env`, start the server, and send the `advice_explain` example from
  the README, or run `uv run python evaluations/run_golden.py` for the 30 questions.
- `design_propose` is needed before a MAGIC operator can publish the agent (stage 0, finding 2).
- The keyword judge of the golden run is a stand-in; the model judge is the one to use when a
  model is configured.
- Step 2 extension points are marked in `knowledge/retriever.py` (Azure AI Search),
  `card.py` (streaming, push notifications), `auth.py` (Key Vault) and `llm/client.py`
  (managed identity).

## 0.1.1 — reasoning-model fix (26 October 2026)

Finding: the deployed agent failed against the real deployment `gpt-6.1-sol` with HTTP 400,
"Unsupported value: 'temperature' does not support 0.0 with this model". `llm/client.py` sent
`temperature=0.0` on every chat call.

Change: the chat request is built in one place, `chat_arguments`, and carries no `temperature`,
`top_p` or `max_tokens`. An optional token cap, `AZURE_OPENAI_MAX_COMPLETION_TOKENS`, is sent as
`max_completion_tokens` only. It is unset by default, because a reasoning model counts its hidden
reasoning tokens against it. The version is 0.1.1. `/healthz`, the card and `vendor_describe` read
it from the package metadata, and the Learn client now reads it there too instead of a literal.

Verified: `tests/test_llm_client.py` reads the request off the wire through a mock HTTP
transport. It asserts there is no `temperature`, `max_tokens` or `top_p`, that a cap travels as
`max_completion_tokens`, and that `/healthz` and the card report the pyproject version. 43 passed,
ruff clean, fake golden run 30/30. Not verified: a call against the real `gpt-6.1-sol`. The
request still asks for `response_format: json_object`. If that deployment also refuses it, the
next 400 will say so.
