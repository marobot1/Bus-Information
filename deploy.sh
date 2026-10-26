#!/usr/bin/env bash
# 버스친구 — 한 번에 배포 (처음 올릴 때도, 업데이트할 때도 이것만 실행)
#   bash deploy.sh
# 끝나면 QR 코드가 나와요. 폰 카메라로 찍으면 설치 파일(APK)이 받아져요.
set -e
cd "$(dirname "$0")"
REPO="${REPO:-grandma-bus}"
need(){ command -v "$1" >/dev/null 2>&1 || { echo "[!] $1 이(가) 필요해요 → $2"; exit 1; }; }
need git "sudo apt install -y git"
need gh  "sudo apt install -y gh"
gh auth status >/dev/null 2>&1 || gh auth login -w -p https
OWNER=$(gh api user -q .login); FULL="$OWNER/$REPO"

# 1) 코드 저장
[ -d .git ] || git init -q -b main
git add -A
git -c user.name="$OWNER" -c user.email="$OWNER@users.noreply.github.com" commit -qm "업데이트 $(date '+%Y-%m-%d %H:%M')" || echo "- 바뀐 파일 없음"

# 2) GitHub 저장소 (없으면 만들기)
gh repo view "$FULL" >/dev/null 2>&1 || gh repo create "$FULL" --public --source=. --remote=origin
git remote get-url origin >/dev/null 2>&1 || git remote add origin "https://github.com/$FULL.git"

# 3) 비밀 값 → GitHub 시크릿 (저장소 코드에는 안 올라가요)
[ -s ks.b64 ]         && gh secret set KEYSTORE_B64   -R "$FULL" < ks.b64
[ -s tago.key ]       && gh secret set TAGO_KEY       -R "$FULL" < tago.key
[ -s google-tts.key ] && gh secret set GOOGLE_TTS_KEY -R "$FULL" < google-tts.key
[ -s kakao.key ]      && gh secret set KAKAO_KEY      -R "$FULL" < kakao.key

# 4) GitHub에만 있는 변경을 먼저 합치고 → 올리기 → APK 자동 빌드
if git fetch -q origin main 2>/dev/null; then
  git -c user.name="$OWNER" -c user.email="$OWNER@users.noreply.github.com" merge -q origin/main -X ours --allow-unrelated-histories -m "GitHub 변경 합치기" || true
fi
git push -u origin main
gh api -X POST "repos/$FULL/pages" -f "source[branch]=main" -f "source[path]=/docs" >/dev/null 2>&1 || true

echo "- 앱 만드는 중 (약 5분)…"
SHA=$(git rev-parse HEAD); RUN=""
for i in $(seq 1 30); do
  RUN=$(gh run list -R "$FULL" -w apk.yml --commit "$SHA" -L 1 --json databaseId -q '.[0].databaseId' 2>/dev/null || true)
  [ -n "$RUN" ] && break; sleep 4
done
[ -z "$RUN" ] && { echo "[!] 빌드를 못 찾았어요: https://github.com/$FULL/actions"; exit 1; }
gh run watch "$RUN" -R "$FULL" --exit-status || { echo "[!] 빌드 실패 → gh run view $RUN -R $FULL --log-failed"; exit 1; }

URL="https://github.com/$FULL/releases/latest/download/busfriend.apk"
echo; echo "완성! 폰 카메라로 QR을 찍으면 설치 파일이 받아져요:"
if command -v qrencode >/dev/null; then qrencode -t ansiutf8 "$URL"; elif command -v npx >/dev/null; then npx -y qrcode-terminal "$URL" || true; fi
echo "$URL"
echo "웹 버전: https://$OWNER.github.io/$REPO/"
