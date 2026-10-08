// lazycompany.app/Myriatale/ → 게임(Myriatale) 사이트로 중계한다.
// 게임은 따로 배포되는 Cloudflare Pages 프로젝트(simulator)에 있고, 여기서는 주소만 이어 준다.
// - /Myriatale, /myriatale… 처럼 대소문자가 다르거나 끝의 / 가 없으면 /Myriatale/… 로 보낸다(게임 파일이 상대 경로라 / 가 필요).
// - 게임의 로그인·AI 통로(/Myriatale/api/…)도 그대로 중계한다. 게임 서버는 "같은 사이트에서 온 요청"만 받으므로,
//   이 사이트에서 온 요청인지 여기서 확인한 뒤 Origin을 게임 주소로 바꿔 보낸다.
// - 그 밖의 주소는 홈페이지(site/) 그대로.
const UPSTREAM = 'https://simulator-c36.pages.dev';
const BASE = '/Myriatale';

export async function onRequest(context) {
  const {request} = context;
  const url = new URL(request.url);
  const lower = url.pathname.toLowerCase();
  if (lower !== '/myriatale' && !lower.startsWith('/myriatale/')) return context.next();

  // 주소 모양 맞추기: 정확히 /Myriatale/ 로 시작하게
  if (!url.pathname.startsWith(BASE + '/')) {
    const rest = url.pathname.slice(BASE.length);
    url.pathname = BASE + (rest.startsWith('/') ? rest : '/' + rest);
    return Response.redirect(url.toString(), 301);
  }

  const origin = request.headers.get('Origin');
  if (origin && origin !== url.origin) return new Response('Forbidden', {status: 403});

  const target = new URL(url.pathname.slice(BASE.length) + url.search, UPSTREAM);
  const headers = new Headers(request.headers);
  headers.delete('host');
  if (origin) headers.set('Origin', UPSTREAM);
  const init = {method: request.method, headers, redirect: 'manual'};
  if (request.method !== 'GET' && request.method !== 'HEAD') init.body = await request.arrayBuffer();

  const res = await fetch(target, init);
  const out = new Response(res.body, res); // 스트리밍(글이 한 줄씩 나오는 AI 응답)도 그대로 흘려보낸다
  const loc = out.headers.get('Location');
  if (loc) {
    try {
      const l = new URL(loc, UPSTREAM);
      if (l.origin === UPSTREAM) out.headers.set('Location', BASE + l.pathname + l.search);
    } catch {}
  }
  return out;
}
