#!/bin/zsh
# Re-publish the Playbook page with the latest PDF from ~/Claude/clients/playbook.
# usage: ./sync.sh     (same URL: https://roselawlesspro-dev.github.io/playbook/)
set -e; cd "$(dirname "$0")"
SRC=~/Claude/clients/playbook/Personal-Brand-Playbook.pdf
TMP=$(mktemp -d)
cp "$SRC" Personal-Brand-Playbook.pdf
sips -s format png Personal-Brand-Playbook.pdf --out $TMP/c.png >/dev/null
sips -s format jpeg -s formatOptions 85 -Z 1200 $TMP/c.png --out cover.jpg >/dev/null
cp cover.jpg ../playbook-cover.jpg
~/.local/bin/ffmpeg -v error -y -f lavfi -i color=c=0x160E0D:s=1200x630 -i cover.jpg \
  -filter_complex "[1]scale=-2:630[c];[0][c]overlay=(W-w)/2:0" -frames:v 1 og.jpg
git add -A
git diff --cached --quiet && { echo "No change."; exit 0; }
git -c user.name="Rose Lawless" -c user.email="roselawlesspro-dev@users.noreply.github.com" \
  commit -q -m "Update Playbook PDF $(date +%Y-%m-%d_%H%M)"
git push -q && echo "Published. Live in ~1 minute."
