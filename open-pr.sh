#!/usr/bin/env bash
# Prep the xai-org/plugin-marketplace PR for skill-vetter.
# Forks + clones the catalog, adds our entry, runs xAI's own validator,
# pushes to YOUR fork. Stops before opening the PR — you submit that.
set -euo pipefail

WORK="${TMPDIR:-/tmp}/ss-xai-pr"
rm -rf "$WORK"; mkdir -p "$WORK"; cd "$WORK"

echo "=== 1/5 fork + clone xai-org/plugin-marketplace (gh as solidstatecc) ==="
gh repo fork xai-org/plugin-marketplace --clone
cd plugin-marketplace
git checkout -b add-skill-vetter

echo "=== 2/5 append the skill-vetter catalog entry ==="
python3 - <<'PY'
import json
p=".grok-plugin/marketplace.json"
d=json.load(open(p))
entry={
  "name":"skill-vetter",
  "description":"Vet a third-party agent skill before you install or run it: provenance, license, pinning, and dangerous capabilities (shell, network, secrets, file writes), with a RUN / REVIEW / DO NOT RUN verdict. Read-only.",
  "category":"security",
  "source":{"source":"url","url":"https://github.com/solidstatecc/skill-vetter.git","sha":"49cfbe7d0dc324ac68d2ae73ab37cba2316fdfbf"},
  "homepage":"https://solidstate.cc",
  "keywords":["skill-vetter","vet","audit","provenance","supply chain","security","skills"],
  "domains":["solidstate.cc"]
}
d["plugins"]=[x for x in d["plugins"] if x.get("name")!="skill-vetter"]
d["plugins"].append(entry)
json.dump(d,open(p,"w"),indent=2); open(p,"a").write("\n")
print("  appended skill-vetter @ 49cfbe7d")
PY

echo "=== 3/5 regenerate component index (fetches pinned sources) ==="
python3 scripts/generate-plugin-index.py

echo "=== 4/5 validate catalog (xAI's own validator) ==="
python3 scripts/validate-catalog.py

echo "=== 5/5 commit + push to your fork ==="
git add -A
git commit -m "Add skill-vetter (Solid State): vet a third-party skill before you run it"
git push -u origin add-skill-vetter

echo ""
echo "=================================================================="
echo "PREP DONE. Validator passed. Pushed to your fork."
echo "Open the PR (you review + submit in the browser):"
echo ""
echo "  cd \"$WORK/plugin-marketplace\" && gh pr create --repo xai-org/plugin-marketplace --web"
echo "=================================================================="
