#!/usr/bin/env bash
# 버스친구 — TAGO API 4개가 키로 열리는지 확인
cd "$(dirname "$0")"
K=$(tr -d '\r\n ' < tago.key)
for s in "버스노선정보:BusRouteInfoInqireService" "버스정류소정보:BusSttnInfoInqireService" "버스도착정보:ArvlInfoInqireService" "버스위치정보:BusLcInfoInqireService"; do
  n=${s%%:*}; svc=${s#*:}
  r=$(curl -s -m 20 "https://apis.data.go.kr/1613000/$svc/getCtyCodeList?serviceKey=$K&_type=json")
  if echo "$r" | grep -q '"resultCode":"00"'; then echo "[OK]   $n"
  elif echo "$r" | grep -q 'NOT_REGISTERED'; then echo "[안됨] $n  ← 활용신청 안 됐거나 아직 반영 전"
  else echo "[??]   $n  $(echo "$r" | head -c 120 | tr -d '\r\n')"; fi
done
