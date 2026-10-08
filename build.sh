#!/bin/sh
# 원본(body.html, sim-body.html) → 실제 사이트(site/) + 미리보기(preview.html, sim-preview.html)
cd "$(dirname "$0")"
wrap(){ # $1=head $2=body $3=out
  { cat "$1"; sed -n '2,/^<\/style>/p' "$2"; printf '</head>\n<body>\n'; sed -n '/^<\/style>/,$p' "$2" | tail -n +2; printf '</body>\n</html>\n'; } > "$3"
}
wrap head-seo.html body.html site/index.html
mkdir -p site/simulator
wrap sim-head.html sim-body.html site/simulator/index.html
# 미리보기(Artifact)는 외부 폰트 파일을 못 불러오므로 폰트를 파일 안에 넣는다
python3 -c 'import base64;b=base64.b64encode(open("site/fonts/Cafe24Dongdong.woff","rb").read()).decode();s=open("body.html").read().replace("url(\"fonts/Cafe24Dongdong.woff\")","url(\"data:font/woff;base64,"+b+"\")");open("preview.html","w").write(s)'
