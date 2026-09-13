#!/bin/sh
# Lokal fallback för GitHub Actions-cronen: hämtar senaste valresultatet
# och pushar till repot så att GitHub Pages serverar färskt data.
# Körs var 5:e minut av launchd (se ~/Library/LaunchAgents/se.val2026.update.plist).
set -e
cd /Users/davidandersson/val2026

git pull --rebase -q origin master
curl -fsS --retry 2 --max-time 30 -o data/RD_P.json \
  https://resultat.val.se/data/resultat/val2026/RD_P.json
python3 -c "import json; json.load(open('data/RD_P.json'))"

git add data/RD_P.json
git diff --cached --quiet && exit 0
git -c commit.gpgsign=false commit -q -m "Uppdatera valresultat (lokal cron)"
git push -q origin master
echo "$(date '+%H:%M:%S') pushade nytt data"
