# Brief — Microsoft vendor agent, step 3a: architecture diagrams with official icons, and complete designs

Work only inside `C:\magic\ms-vendor-agent`, on a new local branch `elias/step3-diagrams` created
from `main` (v0.2.3). Never push. Read `PROGRESS.md` first and keep writing to it the same way:
for each stage, the plan and how it is verified, then the result. Commit at the end of each stage.
Do not wait for me between stages; stop and write the reason in PROGRESS.md only if a fact below
turns out to be wrong.

Step 3 is split: **3a (this brief)** = diagrams + complete, fully priced designs + forum exclusion.
3b (next brief) = Azure AI Search knowledge base.

## Why — findings from the first real proposal (DMT pilot, 26 Oct 2026)

MAGIC produced a proposal with our agent. The approach was right, but:
1. The diagrams were generic boxes, not Azure architecture diagrams.
2. HTTP APIs sat behind Standard Load Balancer; a senior architect uses Application Gateway WAF v2
   (or API Management) for HTTP.
3. OS disks, load balancer / gateway, Azure Backup were "not priced": MAGIC reported "Microsoft
   price inquiries returned no matching meters". They are all in the Retail Prices API — our gap.
4. No baseline services (Key Vault, Log Analytics, Defender for Cloud, Bastion), no DR region.
5. v5 sizes were chosen although Dasv6/Dasv7 exist in UAE North.
6. Microsoft Q&A forum answers (`learn.microsoft.com/answers/...`) were cited as evidence.

## Stage 1 — official icons

- Download Microsoft's **Azure Architecture Icons** (current version, from
  https://learn.microsoft.com/azure/architecture/icons/) and keep only the SVGs we use in
  `src/ms_agent/diagram/icons/azure/` with the original file names. Record the version, download
  URL and date in `src/ms_agent/diagram/icons/SOURCE.md`, plus Microsoft's terms from that page
  (icons may be used in architecture diagrams; they must not be cropped, flipped, rotated,
  distorted or recoloured). Same for Microsoft 365 / Entra icons if a source is published on Learn;
  if not, write that in PROGRESS.md and skip them.
- `icons.py`: a map from our role/service names to icon files, e.g. `vm`, `vmss`, `disk`,
  `vnet`, `subnet`, `nsg`, `app_gateway`, `load_balancer`, `front_door`, `api_management`,
  `container_apps`, `app_service`, `aks`, `sql_db`, `sql_mi`, `postgres`, `storage`,
  `key_vault`, `log_analytics`, `monitor`, `defender`, `bastion`, `backup_vault`,
  `recovery_vault`, `vpn_gateway`, `expressroute`, `firewall`, `entra_id`, `openai`/`foundry`,
  `ai_search`, `iot_hub`, `digital_twins`.
- Test: every name in the map resolves to an existing file; no icon is modified (hash check
  against the downloaded originals).

## Stage 2 — `design_figure` skill

- Input: the `design` object that `design_propose` returns (roles, sizes, counts, zones, region,
  DR region, network/front door/backup/security services) **or** the same request
  `design_propose` takes (then it calls the design code first). No forbidden field names.
- Output: an **SVG** (primary) and a **PNG** (for documents), both stored with the file store and
  returned in `files` as links; the envelope `result` carries a short caption and a legend of the
  services drawn.
- Drawing is **deterministic code from the design data — the LLM draws nothing**. Layout in the
  style of Microsoft reference architectures:
  - outer box: subscription/region (label "UAE North"), DR region as a second box when present;
  - inside: VNet box, subnet boxes (front, app, data, management), availability-zone columns
    with the VMs placed in their zone;
  - front door at the top (Application Gateway WAF / Front Door / API Management) with users or
    "on-premises / customer network" outside, connected by arrows; VPN/ExpressRoute when given;
  - shared services in a side band: Key Vault, Log Analytics/Monitor, Defender, Backup vault, Entra ID;
  - each node: official icon + service name + size/count (e.g. "2 × D4as_v6, zones 1–2").
- Icons are inlined into the SVG with every internal `id` prefixed per use so gradients don't
  collide; no external references, no scripts.
- PNG: use a renderer that installs from wheels on Windows and Linux (check `resvg-py` first; else
  CairoSVG in the container only and record the choice). The Dockerfile must include whatever it needs.
- Add the skill to the card and the `urn:magic:vendor-agent:1` extension with schema and example.
- `design_propose` gains a `diagram` entry in `files` (it calls `design_figure` itself).

## Stage 3 — complete designs (`design_propose` and `sizing_calc`)

- **Front door by traffic type:** HTTP/HTTPS workloads → Application Gateway WAF v2 (default) or
  API Management when the request says APIs are published to third parties; non-HTTP → Standard
  Load Balancer. Caveat text explains the choice.
- **Baseline always included and priced:** OS disk per VM (Premium SSD P10 for Linux, P15 for
  Windows unless given), Key Vault, Log Analytics (assumed GB/day per VM, stated), Defender for
  Servers Plan 2 per VM, Azure Bastion (Basic), Azure Backup (protected-instance fee by disk size
  band + backup storage with an assumed retention, stated).
- **DR:** when availability = "with DR region", use the Azure region pair (uaenorth → uaecentral),
  and price Azure Site Recovery per protected VM plus replica disks.
- **Sizes:** prefer the newest generation available in the region (v6/v7 over v5) when it meets the
  need at equal or lower price; keep the top-3 alternatives. B-series only when the workload is
  marked dev/test.
- **Pricing the new meters** from the Retail Prices API (add the needed `serviceName`s to the
  ingestion: Application Gateway, Load Balancer, Backup, Key Vault, Log Analytics, Microsoft
  Defender for Cloud, Azure Bastion, Azure Site Recovery, API Management). Every line keeps full
  provenance (source URL, effectiveStartDate, fetched_at). If a meter really is missing, the line
  says so by name — never a vague "no matching meters".
- Workbook: new lines appear on Lines with formulas; Assumptions lists every assumed quantity.

## Stage 4 — sources

- `advice_explain` and every LLM caveat: drop passages and citations from
  `learn.microsoft.com/answers/` (forum). Allowed: Learn docs, azure.microsoft.com pricing and
  product pages, Microsoft Product Terms, Microsoft licensing pages. When two sources conflict,
  prefer the newer one and say so.

## How it is verified (show me the output)

1. `python -m pytest` passes, including the icon hash check, the forbidden-field-name test and the
   operator-check test.
2. `design_figure` for the DMT pilot design: 2 API workers + 2 processing workers (Linux, 4 vCPU/16 GB
   and 8 vCPU/32 GB), HTTP APIs, uaenorth, zone-redundant, with DR region — write the SVG and PNG to
   `out/` and tell me the paths; I will open them.
3. `design_propose` for the same request returns: App Gateway WAF v2 (not Standard LB), OS disks,
   Key Vault, Log Analytics, Defender, Bastion, Backup, ASR to uaecentral — all priced with
   provenance — and links to the workbook and the diagram.
4. A test that no citation URL contains `/answers/`.
5. Re-run 5 golden questions that cited forums before (azure-08, m365-05 and three others from the
   last JSON) locally and record the result.
6. Version 0.3.0 in `pyproject.toml`; PROGRESS.md has the deploy notes (new env vars, if any).

## Out of scope for 3a

Azure AI Search knowledge base (3b), Microsoft 365 / CSP seat prices, `bom_from_spec`,
`design_change`, PPTX output, any change outside this repository.
