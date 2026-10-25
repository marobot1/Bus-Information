// (선택) Cloudflare Worker 프록시 — 웹앱(GitHub Pages)에서 TAGO API가 CORS로 막힐 때만 쓰세요.
// 설치 앱(APK)은 이게 필요 없어요.
// 배포: npx wrangler deploy worker/tago-proxy.js --name bus-proxy
//       npx wrangler secret put TAGO_KEY --name bus-proxy   (공공데이터포털 Decoding 키)
// 앱 설정의 "프록시 주소"에 https://bus-proxy.<내계정>.workers.dev 를 넣으면 돼요.
const OK = /^\/(BusSttnInfoInqireService|BusRouteInfoInqireService|ArvlInfoInqireService|BusLcInfoInqireService)\/[A-Za-z]+$/;
export default {
  async fetch(req, env) {
    const u = new URL(req.url);
    if (req.method === "OPTIONS") return new Response(null, { headers: { "access-control-allow-origin": "*", "access-control-allow-methods": "GET" } });
    if (!OK.test(u.pathname)) return new Response("not found", { status: 404 });
    u.searchParams.delete("serviceKey");
    const target = "https://apis.data.go.kr/1613000" + u.pathname + "?serviceKey=" + encodeURIComponent(env.TAGO_KEY) + "&" + u.searchParams.toString();
    const r = await fetch(target, { cf: { cacheTtl: 15, cacheEverything: true } });
    const h = new Headers(r.headers);
    h.set("access-control-allow-origin", "*");
    return new Response(r.body, { status: r.status, headers: h });
  }
};
