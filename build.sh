#!/bin/sh
# 원본(body.html, sim-body.html) → 실제 사이트(site/) + 미리보기(preview.html, sim-preview.html)
cd "$(dirname "$0")"
wrap(){ # $1=head $2=body $3=out
  { cat "$1"; sed -n '2,/^<\/style>/p' "$2"; printf '</head>\n<body>\n'; sed -n '/^<\/style>/,$p' "$2" | tail -n +2; printf '</body>\n</html>\n'; } > "$3"
}
wrap head-seo.html body.html site/index.html
# 미리보기(Artifact)는 외부 폰트 파일을 못 불러오므로 폰트를 파일 안에 넣는다
python3 -c 'import base64;b=base64.b64encode(open("site/fonts/Cafe24Dongdong.woff","rb").read()).decode();s=open("body.html").read().replace("url(\"fonts/Cafe24Dongdong.woff\")","url(\"data:font/woff;base64,"+b+"\")");open("preview.html","w").write(s)'
# 노션 CRM 소개 페이지 (lazycompany.app/crm/)
mkdir -p site/crm
wrap crm-head.html crm-body.html site/crm/index.html
mkdir -p site/crm/en
wrap crm-head-en.html crm-body.html site/crm/en/index.html
python3 -c 'import base64;b=base64.b64encode(open("site/fonts/Cafe24Dongdong.woff","rb").read()).decode();s=open("crm-body.html").read().replace("url(\"/fonts/Cafe24Dongdong.woff\")","url(\"data:font/woff;base64,"+b+"\")");open("crm-preview.html","w").write(s)'
# Myriatale(스토리 게임) 소개 페이지 (lazycompany.app/Myriatale/, 게임은 /Myriatale/play/)
mkdir -p site/Myriatale/en
wrap myr-head.html myr-body.html site/Myriatale/index.html
wrap myr-head-en.html myr-body.html site/Myriatale/en/index.html
python3 -c 'import base64,re;f=lambda p:base64.b64encode(open(p,"rb").read()).decode();s=open("myr-body.html").read().replace("url(\"/fonts/Cafe24Dongdong.woff\")","url(\"data:font/woff;base64,"+f("site/fonts/Cafe24Dongdong.woff")+"\")");s=re.sub(r"/Myriatale/img/([\w-]+)\.webp",lambda m:"data:image/webp;base64,"+f("site/Myriatale/img/"+m.group(1)+".webp"),s);s=s.replace("/Myriatale/video/poster.jpg","data:image/jpeg;base64,"+f("site/Myriatale/video/poster.jpg")).replace("/Myriatale/video/intro.mp4","data:video/mp4;base64,"+f("site/Myriatale/video/intro.mp4"));open("myr-preview.html","w").write("<meta charset=\"utf-8\">\n"+s)'
