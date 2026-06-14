#!/usr/bin/env bash
# Re-push the skill-vetter SKILL.md fix, then re-pin xAI PR #41 to the new commit.
set -euo pipefail
SV="/Users/ThorEngelstad/Library/CloudStorage/Dropbox-CalibreStudio/Thor Elias Engelstad/__Visionaire/_Visionaire Labs/__Solid State/GITHUB-NEW/skill-vetter"

echo "=== 1/2 commit + push the SKILL.md frontmatter fix ==="
cd "$SV"
git add -A
git commit -m "fix(skill-vetter): frontmatter description was invalid YAML (mid-value colon)"
git push
NEWSHA=$(git rev-parse HEAD)
echo "  new skill-vetter SHA: $NEWSHA"

echo "=== 2/2 re-pin PR #41 to the fixed commit ==="
WORK="${TMPDIR:-/tmp}/ss-xai-pr-fix"; rm -rf "$WORK"; mkdir -p "$WORK"; cd "$WORK"
git clone https://github.com/solidstatecc/plugin-marketplace.git
cd plugin-marketplace
git checkout add-skill-vetter
python3 - "$NEWSHA" <<'PY'
import json,sys
sha=sys.argv[1]
p=".grok-plugin/marketplace.json"
d=json.load(open(p))
for e in d["plugins"]:
    if e.get("name")=="skill-vetter":
        e["source"]["sha"]=sha
json.dump(d,open(p,"w"),indent=2); open(p,"a").write("\n")
print("  repinned skill-vetter ->", sha)
PY
python3 scripts/generate-plugin-index.py
python3 scripts/validate-catalog.py
git add -A
git commit -m "skill-vetter: repin to fixed frontmatter commit"
git push
echo ""
echo "=== DONE. skill-vetter fixed; PR #41 now pins the corrected commit. ==="
