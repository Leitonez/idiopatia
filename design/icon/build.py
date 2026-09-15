import subprocess, os, sys
from PIL import Image

TEMPLATE = '''<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#1FB7A6"/>
      <stop offset="1" stop-color="#0D5C63"/>
    </linearGradient>
    <linearGradient id="metal" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#F4F6F8"/>
      <stop offset="0.5" stop-color="#C9D1D9"/>
      <stop offset="1" stop-color="#8B98A5"/>
    </linearGradient>
    <linearGradient id="metalDark" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#B8C2CC"/>
      <stop offset="1" stop-color="#7C8894"/>
    </linearGradient>
    <radialGradient id="diaphragm" cx="0.4" cy="0.35" r="0.7">
      <stop offset="0" stop-color="#5B6B7A"/>
      <stop offset="1" stop-color="#1F2A35"/>
    </radialGradient>
    <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
      <feGaussianBlur in="SourceAlpha" stdDeviation="14"/>
      <feOffset dx="0" dy="18" result="o"/>
      <feComponentTransfer><feFuncA type="linear" slope="0.35"/></feComponentTransfer>
      <feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
  </defs>

  <rect width="1024" height="1024" fill="url(#bg)"/>

  <g transform="translate({tx},{ty})" filter="url(#shadow)">
{under}
    <!-- tubo flexível: gancho do "?" descendo até a haste -->
    <path d="M 341 372
             A 175 175 0 1 1 557 529
             C 530 536 512 570 512 620
             L 512 700"
          fill="none" stroke="#FFFFFF" stroke-width="46" stroke-linecap="round" stroke-linejoin="round"/>

    <!-- haste metálica do auscultador -->
    <path d="M 512 705 L 512 748" fill="none" stroke="url(#metalDark)" stroke-width="28" stroke-linecap="round"/>
    <rect x="490" y="700" width="44" height="18" rx="6" fill="url(#metalDark)"/>

    <!-- auscultador (o ponto do "?") -->
    <circle cx="512" cy="806" r="76" fill="url(#metal)"/>
    <circle cx="512" cy="806" r="54" fill="url(#diaphragm)"/>
    <circle cx="512" cy="806" r="12" fill="#C9D1D9"/>

{over}
  </g>
</svg>
'''

ARM = 'fill="none" stroke="url(#metal)" stroke-width="{w}" stroke-linecap="round"'
YOKE = '    <circle cx="341" cy="372" r="{r}" fill="url(#metalDark)"/>'
def olive(cx, cy, rot=0):
    return f'    <ellipse cx="{cx}" cy="{cy}" rx="15" ry="22" transform="rotate({rot} {cx} {cy})" fill="#1F2A35"/>'

VERSIONS = {
  "v1_olivas_cima": dict(tx=36, ty=-6, under="", over="\n".join([
      '    <!-- binaural: braços sobem e curvam para dentro -->',
      '    <path d="M 341 372 C 295 350 245 320 240 262" ' + ARM.format(w=30) + '/>',
      '    <path d="M 341 372 C 345 330 338 285 312 246" ' + ARM.format(w=30) + '/>',
      YOKE.format(r=24),
      '    <ellipse cx="243" cy="250" rx="22" ry="26" fill="#1F2A35"/>',
      '    <ellipse cx="306" cy="236" rx="22" ry="26" fill="#1F2A35"/>'])),
  "v2_pendurado": dict(tx=26, ty=-13, under="", over="\n".join([
      '    <!-- binaural em Y pendurado -->',
      '    <path d="M 341 372 C 300 400 276 470 298 522" ' + ARM.format(w=26) + '/>',
      '    <path d="M 341 372 C 382 400 406 470 384 522" ' + ARM.format(w=26) + '/>',
      YOKE.format(r=24), olive(306,542,-23), olive(376,542,23)])),
  "v2b_pendurado_longo": dict(tx=26, ty=-13, under="", over="\n".join([
      '    <!-- binaural em Y pendurado, hastes mais compridas -->',
      '    <path d="M 341 372 C 296 410 268 500 296 570" ' + ARM.format(w=26) + '/>',
      '    <path d="M 341 372 C 386 410 414 500 386 570" ' + ARM.format(w=26) + '/>',
      YOKE.format(r=24), olive(304,591,-22), olive(378,591,22)])),
  "v3_flecha": dict(tx=36, ty=-6,
      under="\n".join([
      '    <!-- binaural em ponta de flecha: farpas retas subindo da junção, desenhadas sob o tubo -->',
      '    <path d="M 341 372 L 242 273" ' + ARM.format(w=26) + '/>',
      '    <path d="M 341 372 L 448 282" ' + ARM.format(w=26) + '/>']),
      over="\n".join([YOKE.format(r=24), olive(233,264,-45), olive(457,274,50)])),
}

names = sys.argv[1:] or list(VERSIONS)
for name in names:
    v = VERSIONS[name]
    open(f"icon_{name}.svg","w").write(TEMPLATE.format(**v))
    subprocess.run(["timeout","60","google-chrome","--headless=new","--disable-gpu","--no-sandbox","--hide-scrollbars",
                    "--window-size=1024,1024",f"--screenshot=icon_{name}.png",f"file://{os.getcwd()}/icon_{name}.svg"],
                   capture_output=True)
