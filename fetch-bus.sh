#!/usr/bin/env bash
# 버스친구 — 사천시 버스 API 데이터 받기 (내 PC에서 실행)
#   & "C:\Program Files\Git\bin\bash.exe" fetch-bus.sh
cd "$(dirname "$0")"
K=$(tr -d '\r\n ' < tago.key)
C=38060
B=https://apis.data.go.kr/1613000
O=bus-data; rm -rf "$O"; mkdir -p "$O"
get(){ # 파일이름 서비스 기능 조건
  curl -s -m 25 "$B/$2/$3?serviceKey=$K&_type=json&numOfRows=1000&pageNo=1&$4" -o "$O/$1.json"
  printf '%-28s %s\n' "$1" "$(head -c 110 "$O/$1.json" | tr -d '\r\n')"
}
ids(){ grep -oE "\"$1\":\"?[^\",}]+" "${@:2}" 2>/dev/null | sed 's/.*://; s/"//g' | sort -u; }

echo "== 노선 찾기 =="
for n in 230 230-1 111 228 501; do get "route_$n" BusRouteInfoInqireService getRouteNoList "cityCode=$C&routeNo=$n"; done
echo "== 노선별 정류장 · 정보 · 버스 위치 =="
for id in $(ids routeid "$O"/route_*.json); do
  get "stops_$id"  BusRouteInfoInqireService getRouteAcctoThrghSttnList "cityCode=$C&routeId=$id"
  get "info_$id"   BusRouteInfoInqireService getRouteInfoIem "cityCode=$C&routeId=$id"
  get "buses_$id"  BusLcInfoInqireService getRouteAcctoBusLcList "cityCode=$C&routeId=$id"
done
echo "== 집 근처 정류장 (삼정그린코아 · 세븐일레븐) =="
get near_home BusSttnInfoInqireService getCrdntPrxmtSttnList "gpsLati=35.075265&gpsLong=128.071717"
for nd in $(ids nodeid "$O/near_home.json"); do
  get "arr_$nd"  ArvlInfoInqireService getSttnAcctoArvlPrearngeInfoList "cityCode=$C&nodeId=$nd"
  get "thru_$nd" BusSttnInfoInqireService getSttnThrghRouteList "cityCode=$C&nodeid=$nd"
done
echo
echo "완료: bus-data 폴더에 $(ls "$O" | wc -l)개 파일. Claude에게 '다 받았어'라고 말해주세요."
