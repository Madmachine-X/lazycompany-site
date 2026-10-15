# 카페24 동동(650KB, 한글 1만여 자)에서 사이트에 실제로 쓰인 글자만 뽑아 작은 woff2로 만든다.
# 페이지 문구를 바꾸면 build.sh가 다시 실행하면서 새 글자도 자동으로 들어간다.
import glob
from fontTools import subset
text = "".join(open(p, encoding="utf-8").read() for p in sorted(glob.glob("*body.html") + glob.glob("*head*.html")))
chars = {c for c in text if 0xAC00 <= ord(c) <= 0xD7A3 or 0x3131 <= ord(c) <= 0x3163 or ord(c) in (0x2018, 0x2019, 0x201C, 0x201D, 0x2026)}
chars |= {chr(c) for c in range(0x20, 0x7F)}
opts = subset.Options(); opts.flavor = "woff2"; opts.layout_features = ["*"]; opts.name_IDs = ["*"]; opts.notdef_outline = True
font = subset.load_font("site/fonts/Cafe24Dongdong.woff", opts)
s = subset.Subsetter(opts); s.populate(text="".join(chars)); s.subset(font)
subset.save_font(font, "site/fonts/Cafe24Dongdong-sub.woff2", opts)
print(len(chars), "glyphs")
