# 버스친구 2.2

## 배포 (처음도, 업데이트도 이것 하나)
```bash
unzip -o bus-app-repo.zip -d grandma-bus && cd grandma-bus
bash deploy.sh
```
끝나면 나오는 QR을 폰 카메라로 찍어서 설치하세요. 다음부터는 파일을 고친 뒤 `bash deploy.sh` 만 다시 실행하면 돼요.

## 키 파일 (깃에는 안 올라가요 → GitHub 시크릿으로만 들어가요)
- `tago.key` : 공공데이터포털 서비스키 (실시간 버스) — 이미 들어 있음
- `google-tts.key` : 구글 AI 목소리 키 — 넣으면 AI 목소리가 기본으로 켜져요
- `ks.b64`, `bus-release.keystore` : 앱 서명 키 — 잃어버리면 업데이트 때 앱을 지웠다 다시 깔아야 해요

## 폴더
- `docs/` 웹앱 (GitHub Pages) · `android/` 안드로이드 앱 · `worker/` (선택) 웹용 프록시

## 시간표 바꾸기
`docs/index.html` 안의 `ROUTES` 부분만 고치고 `bash deploy.sh`
