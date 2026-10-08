#!/bin/sh
# body.html(미리보기용) → site/index.html(실제 사이트용)
cd "$(dirname "$0")"
{ cat head-seo.html; sed -n '2,/^<\/style>/p' body.html; printf '</head>\n<body>\n'; sed -n '/^<\/style>/,$p' body.html | tail -n +2; printf '</body>\n</html>\n'; } > site/index.html
# 미리보기(Artifact)는 외부 폰트 파일을 못 불러오므로 폰트를 파일 안에 넣는다
python3 -c 'import base64;b=base64.b64encode(open("site/fonts/Cafe24Dongdong.woff","rb").read()).decode();s=open("body.html").read().replace("url(\"fonts/Cafe24Dongdong.woff\")","url(\"data:font/woff;base64,"+b+"\")");open("preview.html","w").write(s)' 
