### A Pluto.jl notebook ###
# v0.20.16

using Markdown
using InteractiveUtils

# ╔═╡ 09511395-916f-4106-be2e-3c16a37ec40b
begin
	import Pkg
	Pkg.develop(path=joinpath(@__DIR__, "MCPresPluto.jl"))
	using MCPresPluto, PlutoUI, Base64
	nothing
end

# ╔═╡ e519f227-38c6-4107-83e9-9d796e561afc
slide_setup(
	author = "Adrien Florio",
	place = "MINT Sommer",
	date = "08.07.26",
	colour = :bleunuit
)

# ╔═╡ c100d5b9-904e-4c3c-9700-294cf743fef7
blank_slide(let
	img = LocalResource(joinpath(@__DIR__, "imgs", "title-1.svg"))
	@htl("<div style=\"text-align:center\">$img</div>")
end)

# ╔═╡ 7b793d26-5ce7-4257-99f6-556fee67908c
# @live from scales-quantum-cosmos.jl
blank_slide() do
    # Local images embedded as data URIs so the scene is fully self-contained:
    # it works in the notebook view, in slide mode (where the slide is moved into
    # a Shadow DOM and relative paths would break), and in static HTML/PDF export.
    function _datauri(name)
        path = joinpath(@__DIR__, "imgs-web", name)
        ext  = lowercase(splitext(name)[2])
        mime = ext == ".png" ? "image/png" : "image/jpeg"
        "data:$(mime);base64,$(base64encode(read(path)))"
    end
    _imgnames = ["human.jpg", "hair.jpg", "cell.jpeg", "virus.jpeg", "protein.png",
                 "atom.jpg", "bielfeld-gutersloh.png", "germany.png", "earth.jpg",
                 "moon.jpg", "sun.jpg"]
    _imgs_json = "{" * join(["\"$(n)\":\"$(_datauri(n))\"" for n in _imgnames], ",") * "}"

    _scene = raw"""
<div id="tic-root">
  <header>
    <h1><span class="q">The Very Small</span> &nbsp;⟷&nbsp; <span class="c">The Very Large</span></h1>
    <p>Each step <b>inward</b> (left) mirrors a step <b>outward</b> (right) — the same factor in opposite directions.</p>
  </header>

  <div class="stage">
    <div class="panel left" id="panelL">
      <div class="tag">Zoom in · matter</div>
      <div class="imgwrap" id="wrapL"></div>
      <div class="readout"><div class="col"><div class="name" id="nameL"></div><div class="sub" id="subL"></div><a class="reflink" id="refL" target="_blank" rel="noopener"></a></div><div class="size" id="sizeL"></div></div>
    </div>

    <div class="divider"></div>

    <div class="panel right" id="panelR">
      <div class="tag">Zoom out · space</div>
      <div class="imgwrap" id="wrapR"></div>
      <div class="readout"><div class="size" id="sizeR"></div><div class="col"><div class="name" id="nameR"></div><div class="sub" id="subR"></div><a class="reflink" id="refR" target="_blank" rel="noopener"></a></div></div>
    </div>
  </div>

  <div class="controls">
    <div class="ticks" id="ticks"></div>
    <div class="sliderrow">
      <button class="nav" id="prev" title="Step toward human scale">◀</button>
      <input type="range" id="slider" min="0" max="3000" value="0">
      <button class="nav" id="next" title="Step outward">▶</button>
    </div>
    <div class="hint">Drag the slider, use <b>◀ ▶</b>, or click a label. Pairs marked <b>≈</b> are the classic order-of-magnitude analogies.</div>
  </div>
</div>

<style>
  #tic-root{
    --bg:#05060d;
    --ink:#eef2ff;
    --muted:#8b93b8;
    --accentL:#6ad7ff;   /* quantum / cold */
    --accentR:#ffb24a;   /* cosmic / warm */
    --line:#1c2238;
    width:100%; height:100%; min-height:70vh;
    background:radial-gradient(1200px 800px at 50% -10%, #11162b 0%, var(--bg) 60%);
    color:var(--ink);
    font-family:'Cabin','Inter',system-ui,-apple-system,"Segoe UI",Roboto,Helvetica,Arial,sans-serif;
    overflow:hidden;display:flex;flex-direction:column;border-radius:10px;
  }
  #tic-root *{box-sizing:border-box;margin:0;padding:0}
  #tic-root header{text-align:center;padding:16px 16px 8px;flex:0 0 auto}
  #tic-root header h1{font-size:clamp(19px,2.5vw,32px);font-weight:700;letter-spacing:.4px;color:var(--ink)}
  #tic-root header h1 .q{color:var(--accentL)} #tic-root header h1 .c{color:var(--accentR)}
  #tic-root header p{color:var(--muted);font-size:clamp(12px,1.2vw,15px);margin-top:4px}

  #tic-root .stage{flex:1 1 auto;display:flex;padding:0 18px;min-height:0}
  #tic-root .panel{position:relative;flex:1 1 50%;border:1px solid var(--line);border-radius:16px;
    overflow:hidden;background:#000;box-shadow:0 0 40px rgba(0,0,0,.6) inset}
  #tic-root .panel.left{border-color:#1d3a4a} #tic-root .panel.right{border-color:#4a3a1d}

  #tic-root .divider{flex:0 0 64px;position:relative;display:flex;align-items:center;justify-content:center}
  #tic-root .divider::before{content:"";position:absolute;top:8%;bottom:8%;left:50%;width:2px;
    transform:translateX(-50%);background:linear-gradient(var(--accentL),#ffffff44,var(--accentR));
    box-shadow:0 0 18px #ffffff55}

  #tic-root .imgwrap{position:absolute;inset:0;overflow:hidden}
  #tic-root .layer{position:absolute;inset:0;display:flex;align-items:center;justify-content:center;
    will-change:transform,opacity;backface-visibility:hidden}
  #tic-root .layer .imgbox{width:82%;height:82%;border-radius:10px;overflow:hidden;
    box-shadow:0 0 60px rgba(0,0,0,.7)}
  #tic-root .layer .imgbox img{width:100%;height:100%;object-fit:cover;display:block;
    transform-origin:center;user-select:none;-webkit-user-drag:none;max-width:none;max-height:none}
  #tic-root .layer .contentbox{width:88%;height:88%;border-radius:10px;overflow:hidden;
    box-shadow:0 0 60px rgba(0,0,0,.7);position:relative;display:flex;align-items:center;justify-content:center}
  #tic-root .layer .contentbox.nuc{background:radial-gradient(circle at 50% 45%, #1a1030, #05060d 70%)}
  #tic-root .layer .contentbox svg{width:70%;height:70%;max-width:70%;max-height:70%}

  /* distance diagrams */
  #tic-root .diagram{position:relative;width:100%;height:100%;
    background:radial-gradient(circle at 50% 50%, #0a1230 0%, #03040c 75%)}
  #tic-root .diagram.space{background:#02030a}
  #tic-root .diagram.space::before{content:"";position:absolute;inset:0;opacity:.7;
    background-image:radial-gradient(1.2px 1.2px at 12% 22%,#fff,transparent),
      radial-gradient(1px 1px at 28% 68%,#cfe,transparent),
      radial-gradient(1.4px 1.4px at 47% 38%,#fff,transparent),
      radial-gradient(1px 1px at 62% 80%,#fff,transparent),
      radial-gradient(1.2px 1.2px at 78% 28%,#ffd,transparent),
      radial-gradient(1px 1px at 88% 62%,#fff,transparent),
      radial-gradient(1px 1px at 38% 88%,#fff,transparent)}
  #tic-root .dline{position:absolute;left:9%;right:9%;top:50%;height:0;border-top:2px dashed #ffffff80;transform:translateY(-50%)}
  #tic-root .dline::before,#tic-root .dline::after{content:"";position:absolute;top:-4px;width:0;height:0;
    border-top:4px solid transparent;border-bottom:4px solid transparent}
  #tic-root .dline::before{left:-2px;border-right:7px solid #ffffff80}
  #tic-root .dline::after{right:-2px;border-left:7px solid #ffffff80}
  #tic-root .dbody{position:absolute;top:50%;transform:translateY(-50%);border-radius:50%;
    aspect-ratio:1/1;overflow:hidden;box-shadow:0 0 24px #000a}
  #tic-root .dbody img{width:100%;height:100%;object-fit:cover;display:block;max-width:none;max-height:none}
  #tic-root .dstar{position:absolute;top:50%;transform:translate(-50%,-50%);border-radius:50%;
    background:radial-gradient(circle,#fff 0%,#cfe8ff 30%,#5aa6ff 60%,transparent 72%);
    filter:drop-shadow(0 0 8px #9cf)}
  #tic-root .dcap{position:absolute;font-size:clamp(9px,1vw,12px);color:#cdd6ff;text-align:center;
    transform:translateX(-50%);white-space:nowrap;text-shadow:0 1px 3px #000}
  #tic-root .dpill{position:absolute;left:50%;top:12%;transform:translateX(-50%);
    font-size:clamp(11px,1.25vw,15px);font-weight:600;color:#fff;background:#0009;
    border:1px solid #ffffff33;padding:4px 10px;border-radius:20px;white-space:nowrap;backdrop-filter:blur(3px)}

  #tic-root .tag{position:absolute;top:14px;left:14px;z-index:5;font-size:12px;letter-spacing:2px;
    font-weight:700;text-transform:uppercase;padding:6px 10px;border-radius:8px;
    background:#0008;backdrop-filter:blur(4px)}
  #tic-root .left .tag{color:var(--accentL);border:1px solid #1d3a4a}
  #tic-root .right .tag{color:var(--accentR);border:1px solid #4a3a1d}

  #tic-root .readout{position:absolute;bottom:14px;left:14px;right:14px;z-index:5;
    display:flex;justify-content:space-between;align-items:flex-end;gap:10px;pointer-events:none}
  #tic-root .readout .col{display:flex;flex-direction:column;gap:3px}
  #tic-root .right .readout .col{align-items:flex-end;text-align:right}
  #tic-root .readout .name{font-size:clamp(17px,2.1vw,28px);font-weight:700;line-height:1}
  #tic-root .readout .sub{font-size:clamp(11px,1.15vw,14px);color:#c9d1f5}
  #tic-root .reflink{pointer-events:auto;display:none;font-size:clamp(9.5px,1vw,12px);margin-top:2px;
    text-decoration:none;background:#0009;border:1px solid #ffffff33;padding:2px 7px;border-radius:6px;
    backdrop-filter:blur(3px);width:fit-content}
  #tic-root .left .reflink{color:var(--accentL)} #tic-root .right .reflink{color:var(--accentR)}
  #tic-root .reflink:hover{background:#ffffff22}
  #tic-root .readout .size{font-variant-numeric:tabular-nums;font-size:clamp(12px,1.3vw,16px);
    color:var(--muted);background:#0008;padding:3px 8px;border-radius:8px;backdrop-filter:blur(4px)}
  #tic-root .left .name{color:var(--accentL)} #tic-root .right .name{color:var(--accentR)}

  #tic-root .controls{flex:0 0 auto;padding:14px 24px 20px;display:flex;flex-direction:column;align-items:center;gap:10px}
  #tic-root .ticks{width:min(1000px,94%);display:flex;justify-content:space-between;font-size:10.5px;
    color:var(--muted);letter-spacing:.3px}
  #tic-root .ticks span{flex:1;text-align:center;cursor:pointer;transition:color .2s;padding:0 2px}
  #tic-root .ticks span.active{color:var(--ink);font-weight:700}
  #tic-root .sliderrow{width:min(1000px,94%);display:flex;align-items:center;gap:16px}
  #tic-root input[type=range]{-webkit-appearance:none;appearance:none;flex:1;height:6px;border-radius:6px;
    background:linear-gradient(90deg,var(--accentL),#ffffff66,var(--accentR));outline:none;cursor:pointer}
  #tic-root input[type=range]::-webkit-slider-thumb{-webkit-appearance:none;appearance:none;width:22px;height:22px;
    border-radius:50%;background:#fff;border:3px solid #0a0d1a;box-shadow:0 0 12px #fff8;cursor:grab}
  #tic-root input[type=range]::-moz-range-thumb{width:22px;height:22px;border-radius:50%;background:#fff;
    border:3px solid #0a0d1a;box-shadow:0 0 12px #fff8;cursor:grab}
  #tic-root button.nav{background:#121734;color:var(--ink);border:1px solid var(--line);border-radius:10px;
    width:46px;height:40px;font-size:18px;cursor:pointer;transition:background .15s,transform .1s}
  #tic-root button.nav:hover{background:#1b2350} #tic-root button.nav:active{transform:scale(.94)}
  #tic-root .hint{color:var(--muted);font-size:12px;text-align:center}
  #tic-root .hint b{color:var(--ink)}
</style>

<script>
(function(){
  const root = document.getElementById("tic-root");
  if(!root || root._ticInit) return;
  root._ticInit = true;

  // Local images, embedded as data URIs by the Julia cell.
  const IMGS = __IMGS_JSON__;
  function lsrc(name){return IMGS[name];}

  // Inline SVG for the atomic nucleus (cannot be photographed) — a packed cluster of nucleons.
  const NUCLEUS_SVG = `<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
    <defs>
      <radialGradient id="p" cx="35%" cy="30%"><stop offset="0%" stop-color="#ff9a8b"/><stop offset="100%" stop-color="#c0392b"/></radialGradient>
      <radialGradient id="n" cx="35%" cy="30%"><stop offset="0%" stop-color="#9ad0ff"/><stop offset="100%" stop-color="#2c6fb3"/></radialGradient>
    </defs>
    ${(() => {
      const pos=[[100,100],[80,86],[120,86],[86,118],[114,118],[100,74],[72,104],[128,104],[100,126],[88,98],[112,98],[100,112]];
      return pos.map((c,i)=>`<circle cx="${c[0]}" cy="${c[1]}" r="15" fill="url(#${i%2?'n':'p'})" stroke="#0a0d1a" stroke-width="1.5"/>`).join('');
    })()}
  </svg>`;

  // Distance diagram: two bodies separated by a labelled gap.
  function distance({a, b, pill, space}){
    const bodyHtml = (o)=> o.star
      ? `<div class="dstar" style="left:${o.xpc}%;width:${o.size}%;aspect-ratio:1/1"></div>`
      : `<div class="dbody" style="left:${o.xpc}%;width:${o.size}%;transform:translate(-50%,-50%)"><img src="${lsrc(o.img)}" alt=""></div>`;
    const capHtml = (o)=> `<div class="dcap" style="left:${o.xpc}%;top:78%">${o.label}</div>`;
    return `<div class="diagram ${space?'space':''}">
      <div class="dline"></div>
      ${bodyHtml(a)}${bodyHtml(b)}
      ${capHtml(a)}${capHtml(b)}
      <div class="dpill">${pill}</div>
    </div>`;
  }

  // LEFT = zoom IN through matter.  Index 0 is the shared 1 m human.
  const LEFT = [
    {name:"Human",   local:"human.jpg",   exp:0.23, sub:"a person · ≈1.7 m"},
    {name:"Hair",    local:"hair.jpg",    exp:-4.1, sub:"a human hair · ≈0.08 mm"},
    {name:"Cell",    local:"cell.jpeg",   exp:-5.7, sub:"a living cell · ≈2 µm"},
    {name:"Virus",   local:"virus.jpeg",  exp:-6.8, sub:"a virus · ≈150 nm"},
    {name:"Protein", local:"protein.png", exp:-8.5, sub:"a protein / DNA · ≈3 nm"},
    {name:"Atom",    local:"atom.jpg", z:0.85, exp:-10.0,sub:"an atom · ≈0.1 nm",
      ref:"https://journals.aps.org/prl/abstract/10.1103/PhysRevLett.110.213001",
      refLabel:"Stodolna et al., PRL 110, 213001 (2013)"},
    {name:"Nucleus", content:NUCLEUS_SVG, nuc:true,          exp:-15.0,sub:"an atomic nucleus · ≈1 fm"},
  ];

  // RIGHT = zoom OUT through space.  Index 0 is the shared 1 m human (same image).
  const RIGHT = [
    {name:"Human",         local:"human.jpg", exp:0.23, sub:"a person · ≈1.7 m"},
    {name:"Bielefeld→Gütersloh", local:"bielfeld-gutersloh.png", fit:"contain", z:1.25, exp:4.18, sub:"two neighbouring towns · ≈15 km"},
    {name:"Germany",       local:"germany.png", fit:"contain", z:1.25, exp:5.94, sub:"north–south Germany · ≈880 km"},
    {name:"Earth",         local:"earth.jpg",  exp:7.10, sub:"the whole planet · ≈12,700 km"},
    {name:"To the Moon", exp:8.58, sub:"distance to the Moon · ≈384,000 km",
      content:distance({space:true,
        a:{img:"earth.jpg", size:24, xpc:20, label:"Earth"},
        b:{img:"moon.jpg", size:13, xpc:80, label:"Moon"},
        pill:"≈ 384,000 km · 30 Earths apart"})},
    {name:"To the Sun", exp:11.17, sub:"≈ distance to the Sun · 1 AU",
      content:distance({space:true,
        a:{img:"earth.jpg", size:9, xpc:16, label:"Earth"},
        b:{img:"sun.jpg", size:34, xpc:78, label:"Sun"},
        pill:"≈ 1 AU · 150 million km · 8 light-minutes"})},
    {name:"To Proxima", exp:16.60, sub:"≈ distance to the nearest star · 4.2 ly",
      content:distance({space:true,
        a:{img:"sun.jpg", size:18, xpc:17, label:"our Sun"},
        b:{star:true, size:5, xpc:83, label:"Proxima Centauri"},
        pill:"≈ 4.2 light-years · 40 trillion km"})},
  ];

  const N = LEFT.length;       // 7
  const K = 6.5;               // visual zoom factor per rung
  const SMAX = 3000;

  function buildLayers(wrapId, data){
    const wrap = root.querySelector('#'+wrapId);
    return data.map(d=>{
      const layer = document.createElement('div');
      layer.className='layer';
      if(d.content){
        const box=document.createElement('div');
        box.className='contentbox'+(d.nuc?' nuc':'');
        box.innerHTML=d.content;
        layer.appendChild(box);
      } else {
        const box=document.createElement('div'); box.className='imgbox';
        const img=document.createElement('img');
        img.src=lsrc(d.local); img.alt=d.name; img.loading='eager';
        if(d.z) img.style.transform='scale('+d.z+')';   // per-image zoom (<1 = zoomed out)
        if(d.fit) img.style.objectFit=d.fit;            // 'contain' shows the whole image
        box.appendChild(img); layer.appendChild(box);
      }
      wrap.appendChild(layer);
      return layer;
    });
  }
  const layersL = buildLayers('wrapL', LEFT);
  const layersR = buildLayers('wrapR', RIGHT);

  const ticks = root.querySelector('#ticks');
  const tickEls = LEFT.map((d,i)=>{
    const s=document.createElement('span');
    s.innerHTML = i===0 ? "Human" : `${LEFT[i].name} ⟷ ${RIGHT[i].name}`;
    s.onclick = ()=> animateTo(i);
    ticks.appendChild(s);
    return s;
  });

  const clamp=(v,a,b)=>Math.max(a,Math.min(b,v));
  const lerp=(a,b,t)=>a+(b-a)*t;

  function paint(layers, t, dir){
    layers.forEach((layer,i)=>{
      const d = t - i;
      const scale = Math.pow(K, dir*d);          // dir=+1 dive in, dir=-1 fly out
      const op = clamp(1 - Math.abs(d), 0, 1);
      layer.style.opacity = op.toFixed(3);
      layer.style.transform = `scale(${scale.toFixed(4)})`;
      layer.style.filter = op<1 ? `blur(${((1-op)*6).toFixed(1)}px)` : 'none';
      layer.style.zIndex = op>0.5?2:1;
    });
  }

  function fmt(exp){
    const e=Math.floor(exp), mant=Math.pow(10,exp-e);
    const sup=String(e).replace(/-/,'⁻').replace(/[0-9]/g,d=>"⁰¹²³⁴⁵⁶⁷⁸⁹"[d]);
    return `${mant.toFixed(1)} × 10${sup} m`;
  }

  const nameL=root.querySelector('#nameL'), subL=root.querySelector('#subL'), sizeL=root.querySelector('#sizeL');
  const nameR=root.querySelector('#nameR'), subR=root.querySelector('#subR'), sizeR=root.querySelector('#sizeR');
  const refL=root.querySelector('#refL'), refR=root.querySelector('#refR');
  function setRef(el,d){
    if(d.ref){el.href=d.ref; el.textContent='↗ '+(d.refLabel||'reference'); el.style.display='inline-block';}
    else {el.style.display='none';}
  }

  function render(t){
    paint(layersL, t, +1);
    paint(layersR, t, -1);
    const near=Math.round(t);
    const i0=clamp(Math.floor(t),0,N-2), f=t-i0;
    nameL.textContent=LEFT[near].name;  subL.textContent=LEFT[near].sub;
    nameR.textContent=RIGHT[near].name; subR.textContent=RIGHT[near].sub;
    setRef(refL, LEFT[near]); setRef(refR, RIGHT[near]);
    sizeL.innerHTML=fmt(lerp(LEFT[i0].exp, LEFT[i0+1].exp, f));
    sizeR.innerHTML=fmt(lerp(RIGHT[i0].exp, RIGHT[i0+1].exp, f));
    tickEls.forEach((el,i)=> el.classList.toggle('active', i===near));
  }

  const slider=root.querySelector('#slider');
  let current=0;
  slider.addEventListener('input',()=>{current=(slider.value/SMAX)*(N-1);render(current);});

  let raf=null;
  function animateTo(level){
    cancelAnimationFrame(raf);
    const target=clamp(level,0,N-1), start=current, dur=700, t0=performance.now();
    (function step(now){
      const p=clamp((now-t0)/dur,0,1);
      const e=p<.5?2*p*p:1-Math.pow(-2*p+2,2)/2;
      current=lerp(start,target,e);
      slider.value=(current/(N-1))*SMAX;
      render(current);
      if(p<1) raf=requestAnimationFrame(step);
    })(performance.now());
  }
  root.querySelector('#next').onclick=()=>animateTo(Math.round(current)+1);
  root.querySelector('#prev').onclick=()=>animateTo(Math.round(current)-1);

  render(0);
})();
</script>
"""

    HTML(replace(_scene, "__IMGS_JSON__" => _imgs_json))
end

# ╔═╡ 9c46d5dd-e463-46b7-915f-5c91fd48f659
# @live from double-slit.jl
blank_slide() do
    # Canvas-only scene (no external images), so it is fully self-contained and
    # works in the notebook view, in slide mode (where the slide is moved into a
    # Shadow DOM), and in static HTML/PDF export. Scoped for the deck:
    #   - all CSS prefixed under #ds-root
    #   - JS wrapped in an IIFE that queries within `root` (not `document`) so it
    #     survives MCPresPluto moving the slide into its Shadow DOM
    #   - the global arrow-key handler is removed (arrows drive deck navigation);
    #     the ◀ ▶ buttons and clickable dots still switch sub-scenes
    #   - font switched to Cabin
    # raw"""...""" avoids Julia $-interpolation / backslash clashes with the
    # scene's JS template literals (${...}) and < comparisons.
    _scene = raw"""
<div id="ds-root">
  <header>
    <h1>The <span class="a">Double-Slit</span> Experiment</h1>
    <p id="subtitle"></p>
  </header>

  <div class="stage">
    <div class="panel" id="panel">
      <canvas id="cv"></canvas>
      <div class="tag" id="tag"></div>

      <div class="qctrl" id="qctrl">
        <div class="toggle" id="obsToggle">
          <span class="lab">👁 Observe which slit</span>
          <span class="switch"></span>
        </div>
        <div class="counter">electrons: <b id="ecount">0</b></div>
      </div>

      <div class="speedctrl" id="speedctrl">
        <button class="qbtn" id="sceneReset">↻ Reset</button>
        <span>slow</span>
        <input type="range" id="speed" min="0.075" max="6" step="0.025" value="0.075">
        <span>fast</span>
      </div>
    </div>
  </div>

  <div class="controls">
    <div class="caption" id="caption">
      <div class="ct" id="capTitle"></div>
      <div class="cs" id="capSub"></div>
    </div>
    <div class="dots" id="dots"></div>
  </div>
</div>

<style>
  #ds-root{
    --bg:#05060d;
    --ink:#eef2ff;
    --muted:#8b93b8;
    --warm:#ffb24a;     /* classical particles */
    --cool:#6ad7ff;     /* waves / quantum */
    --elec:#7CFFB2;     /* electrons */
    --warn:#ff5470;     /* observation / collapse */
    --line:#1c2238;
    /* Fill the slide box exactly in slide mode (parent has a definite height,
       so height:100% wins and aspect-ratio is ignored). In the notebook editor
       the parent height is auto, height:100% collapses, and aspect-ratio then
       derives a landscape height from the cell width. Either way max-height:100%
       keeps us inside MCPresPluto's 4:3 slide box (no min-height to overflow it). */
    width:100%; height:100%; max-height:100%; aspect-ratio:4 / 3;
    background:radial-gradient(1200px 800px at 50% -10%, #11162b 0%, var(--bg) 60%);
    color:var(--ink);
    font-family:'Cabin','Inter',system-ui,-apple-system,"Segoe UI",Roboto,Helvetica,Arial,sans-serif;
    overflow:hidden;display:flex;flex-direction:column;border-radius:10px;
  }
  #ds-root *{box-sizing:border-box;margin:0;padding:0}
  #ds-root header{text-align:center;padding:14px 16px 6px;flex:0 0 auto}
  #ds-root header h1{font-size:clamp(19px,2.5vw,32px);font-weight:700;letter-spacing:.4px}
  #ds-root header h1 .a{color:var(--cool)}
  #ds-root header p{color:var(--muted);font-size:clamp(12px,1.2vw,15.5px);margin-top:5px;min-height:1.2em;
    transition:opacity .3s}

  #ds-root .stage{flex:1 1 auto;display:flex;padding:0 18px;min-height:0}
  #ds-root .panel{position:relative;flex:1 1 100%;border:1px solid var(--line);border-radius:16px;
    overflow:hidden;background:#000;box-shadow:0 0 40px rgba(0,0,0,.6) inset}
  #ds-root canvas{display:block;width:100%;height:100%}

  /* scene tag (top-left) */
  #ds-root .tag{position:absolute;top:14px;left:14px;z-index:5;font-size:12px;letter-spacing:2px;
    font-weight:700;text-transform:uppercase;padding:6px 11px;border-radius:8px;
    background:#0008;backdrop-filter:blur(4px);border:1px solid var(--line);transition:color .3s,border-color .3s}

  /* caption (centered, in the bottom controls bar) */
  #ds-root .caption{max-width:min(720px,94%);margin:0 auto;
    background:#0009;border:1px solid #ffffff22;border-radius:12px;padding:10px 16px;
    backdrop-filter:blur(5px);text-align:center;transition:opacity .3s}
  #ds-root .caption .ct{font-size:clamp(13px,1.5vw,17px);font-weight:700;line-height:1.25}
  #ds-root .caption .cs{font-size:clamp(11px,1.2vw,13.5px);color:#c9d1f5;margin-top:4px;line-height:1.35}
  #ds-root .caption b.warm{color:var(--warm)} #ds-root .caption b.cool{color:var(--cool)}
  #ds-root .caption b.elec{color:var(--elec)} #ds-root .caption b.warn{color:var(--warn)}

  /* scene-3 control cluster — a compact row near the slit, clear of the screen */
  #ds-root .qctrl{position:absolute;top:14px;left:42%;transform:translateX(-50%);z-index:6;display:none;
    flex-direction:row;gap:10px;align-items:center}
  #ds-root .toggle{display:flex;align-items:center;gap:10px;background:#0009;border:1px solid #ffffff22;
    border-radius:30px;padding:6px 8px 6px 14px;backdrop-filter:blur(5px);cursor:pointer;user-select:none}
  #ds-root .toggle .lab{font-size:13px;font-weight:600;color:var(--ink)}
  #ds-root .switch{position:relative;width:46px;height:24px;border-radius:14px;background:#2a3150;transition:background .2s;flex:0 0 auto}
  #ds-root .switch::after{content:"";position:absolute;top:2px;left:2px;width:20px;height:20px;border-radius:50%;
    background:#fff;transition:transform .2s}
  #ds-root .toggle.on .switch{background:var(--warn)}
  #ds-root .toggle.on .switch::after{transform:translateX(22px)}
  #ds-root .toggle.on .lab{color:var(--warn)}
  #ds-root .counter{font-size:12px;color:var(--muted);background:#0008;border:1px solid var(--line);
    border-radius:8px;padding:4px 10px;backdrop-filter:blur(4px)}
  #ds-root .counter b{color:var(--ink);font-variant-numeric:tabular-nums}
  #ds-root .qbtn{font-size:12px;color:var(--ink);background:#121734;border:1px solid var(--line);
    border-radius:8px;padding:5px 12px;cursor:pointer;transition:background .15s}
  #ds-root .qbtn:hover{background:#1b2350}

  /* speed control (scene 1 & 3) */
  #ds-root .speedctrl{position:absolute;bottom:16px;right:16px;z-index:6;display:none;align-items:center;gap:8px;
    background:#0009;border:1px solid #ffffff22;border-radius:10px;padding:6px 12px;backdrop-filter:blur(5px)}
  #ds-root .speedctrl span{font-size:11px;color:var(--muted)}
  #ds-root .speedctrl input{width:80px}

  /* bottom controls: caption + scene selector, centered and pushed low */
  #ds-root .controls{flex:0 0 auto;padding:6px 24px 8px;display:flex;flex-direction:column;align-items:center;gap:10px}
  #ds-root .dots{display:flex;gap:18px;align-items:center}
  #ds-root .dot{display:flex;flex-direction:column;align-items:center;gap:6px;cursor:pointer;opacity:.55;transition:opacity .2s}
  #ds-root .dot.active{opacity:1}
  #ds-root .dot .pip{width:11px;height:11px;border-radius:50%;background:#39406a;transition:background .2s,box-shadow .2s}
  #ds-root .dot.active .pip{background:var(--cool);box-shadow:0 0 12px var(--cool)}
  #ds-root .dot .dl{font-size:11.5px;color:var(--muted);letter-spacing:.3px}
  #ds-root .dot.active .dl{color:var(--ink);font-weight:700}
</style>

<script>
(function(){
"use strict";
/* ============================================================================
   THE DOUBLE-SLIT EXPERIMENT  —  3 navigable scenes
     1) classical balls  -> two bands (no interference)
     2) waves            -> interference fringes
     3) electrons        -> fringes build up dot-by-dot; "observe" collapses them
   2-D side view of the beam, with the detection screen drawn as a TILTED 3-D
   panel (receding to the right) so the bands clearly live on a surface.
   ========================================================================== */

const root = document.getElementById('ds-root');
if(!root || root._dsInit) return;
root._dsInit = true;
const $ = sel => root.querySelector(sel);

const cv  = $('#cv');
const ctx = cv.getContext('2d');
const panel = $('#panel');

let W = 0, H = 0, DPR = 1;
let G = {};              // geometry, recomputed on resize

function computeGeom(){
  G.sourceX  = W*0.085;
  G.barrierX = W*0.42;
  G.screenX  = W*0.80;                 // beam ends here; tilted screen starts here (same as 2-D)
  G.cy       = H*0.50;
  G.slitGap  = H*0.20;                 // centre-to-centre between the two slits
  G.slitHalf = H*0.035;                // half-height of each opening
  G.slitTop  = G.cy - G.slitGap/2;
  G.slitBot  = G.cy + G.slitGap/2;
  G.yTop     = H*0.10;                 // active vertical range
  G.yBot     = H*0.90;
  G.ratio    = (G.screenX - G.sourceX)/(G.barrierX - G.sourceX); // source→slit→screen projection
  // tilted detection-screen panel (a 3-D card receding to the right)
  G.scNx       = G.screenX;                          // near (front) edge x
  G.scFx       = G.screenX + (W - G.screenX)*0.93;   // far edge x
  G.scCy       = (G.yTop + G.yBot)/2;
  G.scNearHalf = (G.yBot - G.yTop)/2;
  G.scFarHalf  = G.scNearHalf*0.58;                  // foreshortened far edge
  G.scFarTop   = G.scCy - G.scFarHalf;
}

function resize(){
  const r = panel.getBoundingClientRect();
  DPR = Math.min(window.devicePixelRatio||1, 2);
  W = r.width; H = r.height;
  cv.width  = Math.round(W*DPR);
  cv.height = Math.round(H*DPR);
  ctx.setTransform(DPR,0,0,DPR,0,0);
  computeGeom();
  scenes.forEach(s=> s.onResize && s.onResize());
}
new ResizeObserver(resize).observe(panel);

const clamp=(v,a,b)=>Math.max(a,Math.min(b,v));
const lerp =(a,b,u)=>a+(b-a)*u;

/* ----------------------------- shared drawing ----------------------------- */
function clearBG(){
  ctx.fillStyle = '#04050b';
  ctx.fillRect(0,0,W,H);
  const g = ctx.createLinearGradient(0,0,W,0);
  g.addColorStop(0,'#070a18'); g.addColorStop(1,'#04050b');
  ctx.fillStyle = g; ctx.fillRect(0,0,W,H);
}
function quad(a,b,c,d,fill,stroke,lw){
  ctx.beginPath(); ctx.moveTo(a[0],a[1]); ctx.lineTo(b[0],b[1]);
  ctx.lineTo(c[0],c[1]); ctx.lineTo(d[0],d[1]); ctx.closePath();
  if(fill){ ctx.fillStyle=fill; ctx.fill(); }
  if(stroke){ ctx.strokeStyle=stroke; ctx.lineWidth=lw||1; ctx.stroke(); }
}
// point on the tilted screen panel: u = vertical fraction [0..1], d = depth [0..1]
function screenPt(u,d){
  const Ny = G.yTop + u*(G.yBot-G.yTop);          // full-height edge
  const Fy = G.scFarTop + u*(2*G.scFarHalf);      // foreshortened edge
  // foreshortened edge on the LEFT (at the beam), full-height edge on the RIGHT
  return [ lerp(G.scNx,G.scFx,d), lerp(Fy,Ny,d) ];
}

function drawBarrier(accent){
  const x = G.barrierX, bw = Math.max(7, W*0.012);
  ctx.fillStyle = 'rgba(180,190,225,0.92)';
  ctx.fillRect(x-bw/2, 0,                 bw, G.slitTop-G.slitHalf);
  ctx.fillRect(x-bw/2, G.slitTop+G.slitHalf, bw, (G.slitBot-G.slitHalf)-(G.slitTop+G.slitHalf));
  ctx.fillRect(x-bw/2, G.slitBot+G.slitHalf, bw, H-(G.slitBot+G.slitHalf));
  ctx.save();
  ctx.shadowColor = accent; ctx.shadowBlur = 12;
  ctx.strokeStyle = accent+''; ctx.globalAlpha = .5;
  [ [G.slitTop-G.slitHalf,G.slitTop+G.slitHalf],
    [G.slitBot-G.slitHalf,G.slitBot+G.slitHalf] ].forEach(([a,b])=>{
    ctx.beginPath(); ctx.moveTo(x, a); ctx.lineTo(x, b);
    ctx.lineWidth = bw; ctx.stroke();
  });
  ctx.restore();
}

// the tilted detection screen (a 3-D panel receding to the right)
function drawScreenPanel(accent){
  const a=screenPt(0,0), b=screenPt(0,1), c=screenPt(1,1), d=screenPt(1,0);
  quad(a,b,c,d, 'rgba(8,11,22,0.95)', 'rgba(120,130,170,0.5)', 1.5);
  // brighter front edge (where the beam lands)
  ctx.strokeStyle = accent+'99'; ctx.lineWidth = 2.5;
  ctx.beginPath(); ctx.moveTo(a[0],a[1]); ctx.lineTo(d[0],d[1]); ctx.stroke();
}

// SHARED interference pattern (waves + electrons make the exact same fringes).
const WAVE = { lambdaFrac:0.03, slitWidthFrac:0.028 };
function fringeI(y){
  const lambda=H*WAVE.lambdaFrac, k=2*Math.PI/lambda;
  const ea=Math.PI*(H*WAVE.slitWidthFrac)/lambda;
  const dx=G.screenX-G.barrierX;
  const r1=Math.hypot(dx,y-G.slitTop), r2=Math.hypot(dx,y-G.slitBot);
  const u1=ea*(y-G.slitTop)/r1, E1=u1===0?1:Math.sin(u1)/u1;
  const u2=ea*(y-G.slitBot)/r2, E2=u2===0?1:Math.sin(u2)/u2;
  return (E1*E1 + E2*E2 + 2*E1*E2*Math.cos(k*(r1-r2)))/4;
}

// Render the interference pattern as bands ON the tilted screen panel.
function drawBands(build){
  if(build<=0) return;
  const rows=120;
  for(let i=0;i<rows;i++){
    const u0=i/rows, u1=(i+1)/rows;
    const yc=G.yTop+((i+0.5)/rows)*(G.yBot-G.yTop);
    const v=clamp(fringeI(yc),0,1)*build;
    const col='rgb('+Math.round(6+v*96)+','+Math.round(10+v*200)+','+Math.round(20+v*235)+')';
    quad(screenPt(u0,0),screenPt(u0,1),screenPt(u1,1),screenPt(u1,0), col, null, 0);
  }
}

/* =========================================================================
   SCENE 1 — CLASSICAL BALLS
   ========================================================================= */
const sceneBalls = {
  tag:'1 · Classical balls',
  tagColor:'var(--warm)',
  subtitle:'Fire little balls (or paint pellets) at a wall with two slits. What lands on the screen behind it?',
  capTitle:'Particles make <b class="warm">two stripes</b>.',
  capSub:'Each ball goes through <b class="warm">one</b> slit or the other, then flies straight on. The pile-up on the screen is just two bumps — one behind each opening.',
  accent:'#ffb24a',
  balls:[], dots:[], acc:0,
  onEnter(){ this.reset(); speedSlider(true); },
  onLeave(){ speedSlider(false); },
  onResize(){},
  reset(){ this.balls.length=0; this.dots.length=0; this.acc=0; },
  spawn(){
    const A = (G.slitGap/2 + G.slitHalf*2.4)/(G.barrierX-G.sourceX);
    const tan = (Math.random()*2-1)*A;
    this.balls.push({x:G.sourceX, y:G.cy, tan, state:'fly', a:1});
  },
  step(dt){
    this.acc += dt*SPEED;
    const interval = 0.045;
    while(this.acc > interval){ this.acc -= interval; if(this.balls.length<200) this.spawn(); }
    const vx = W*0.42*SPEED*dt;
    for(const b of this.balls){
      if(b.state==='fly'){
        const nx = b.x + vx;
        if(b.x < G.barrierX && nx >= G.barrierX){
          const yb = G.cy + (G.barrierX-G.sourceX)*b.tan;
          const inTop = Math.abs(yb-G.slitTop) <= G.slitHalf;
          const inBot = Math.abs(yb-G.slitBot) <= G.slitHalf;
          if(!(inTop||inBot)){ b.state='absorb'; }
        }
        b.x = nx;
        b.y = G.cy + (b.x-G.sourceX)*b.tan;
        if(b.x >= G.screenX){
          if(b.y>=G.yTop && b.y<=G.yBot)
            this.dots.push({u:clamp((b.y-G.yTop)/(G.yBot-G.yTop),0,1), d:Math.sqrt(Math.random())});
          b.state='dead';
        }
      } else if(b.state==='absorb'){
        b.a -= dt*3; if(b.a<=0) b.state='dead';
      }
    }
    this.balls = this.balls.filter(b=>b.state!=='dead');
    if(this.dots.length>6000) this.dots.splice(0,this.dots.length-6000);
  },
  draw(){
    clearBG();
    drawScreenPanel(this.accent);
    // hits accumulate as dots on the tilted screen -> two stripes
    ctx.fillStyle=this.accent;
    for(const dd of this.dots){ const p=screenPt(dd.u,dd.d); ctx.beginPath(); ctx.arc(p[0],p[1],1.5,0,7); ctx.fill(); }
    drawBarrier(this.accent);
    ctx.fillStyle = this.accent;
    ctx.beginPath(); ctx.arc(G.sourceX, G.cy, Math.max(6,H*0.014), 0, 7); ctx.fill();
    const r = Math.max(2.6, H*0.0075);
    for(const b of this.balls){
      ctx.globalAlpha = b.state==='absorb'? b.a*0.7 : 1;
      ctx.fillStyle = b.state==='absorb' ? '#7a7f99' : this.accent;
      ctx.beginPath(); ctx.arc(b.x, b.y, r, 0, 7); ctx.fill();
    }
    ctx.globalAlpha = 1;
  }
};

/* =========================================================================
   SCENE 2 — WAVES (live interference field)
   ========================================================================= */
const sceneWaves = {
  tag:'2 · Waves',
  tagColor:'var(--cool)',
  subtitle:'Now send a wave at the same wall — water ripples, sound, light. Each slit becomes a new source of ripples.',
  capTitle:'Waves make <b class="cool">many stripes</b> — interference.',
  capSub:'A wave passes through <b class="cool">both</b> slits at once. Where two crests meet they add up (bright); where a crest meets a trough they cancel (dark). The result is a pattern of <b class="cool">many</b> bands.',
  accent:'#6ad7ff',
  RS:3, cols:0, rows:0,
  ds:null, r1:null, r2:null, dy1:null, dy2:null, side:null,
  off:null, octx:null, img:null,
  time:0, k:0, w:0, c:0, Dsb:0, softW:0, lambda:0, ea:0, dsScreen:0,
  onEnter(){ this.onResize(); this.reset(); speedSlider(true); },
  onLeave(){ speedSlider(false); },
  reset(){ this.time=0; },
  onResize(){
    if(!W) return;
    const RS=this.RS;
    this.cols=Math.max(2,Math.ceil(W/RS));
    this.rows=Math.max(2,Math.ceil(H/RS));
    const N=this.cols*this.rows;
    this.ds=new Float32Array(N); this.r1=new Float32Array(N);
    this.r2=new Float32Array(N); this.dy1=new Float32Array(N);
    this.dy2=new Float32Array(N); this.side=new Uint8Array(N);
    for(let j=0;j<this.rows;j++){
      for(let i=0;i<this.cols;i++){
        const idx=j*this.cols+i;
        const x=(i+0.5)*RS, y=(j+0.5)*RS;
        this.ds[idx]=x-G.sourceX;
        this.dy1[idx]=y-G.slitTop; this.dy2[idx]=y-G.slitBot;
        this.r1[idx]=Math.hypot(x-G.barrierX,y-G.slitTop);
        this.r2[idx]=Math.hypot(x-G.barrierX,y-G.slitBot);
        this.side[idx]= x<G.barrierX ?1:0;
      }
    }
    if(!this.off){ this.off=document.createElement('canvas'); this.octx=this.off.getContext('2d'); }
    this.off.width=this.cols; this.off.height=this.rows;
    this.img=this.octx.createImageData(this.cols,this.rows);
    const lambda=H*WAVE.lambdaFrac;
    this.lambda=lambda;
    this.k=2*Math.PI/lambda;
    this.c=W*0.34;
    this.w=this.c*this.k;
    this.ea=Math.PI*(H*WAVE.slitWidthFrac)/lambda;
    this.Dsb=G.barrierX-G.sourceX;
    this.softW=lambda*0.9;
    this.dsScreen=G.screenX-G.sourceX;
  },
  step(dt){
    const frac=(SPEED-0.075)/(6-0.075);
    const eff=0.075+frac*(2.445-0.075);
    this.time+=dt*eff;
  },
  draw(){
    const cols=this.cols, rows=this.rows, k=this.k, ea=this.ea;
    const ph=this.w*this.time, ct=this.c*this.time;
    const avail=ct-this.Dsb;
    const kOff=k*this.Dsb;
    const softW=this.softW, data=this.img.data;
    let p=0;
    for(let idx=0; idx<cols*rows; idx++){
      let s=0, A=0;
      if(this.side[idx]){
        const ds=this.ds[idx];
        if(ds>=0){
          const g=clamp((ct-ds)/softW,0,1);
          if(g>0){ const aL=0.60*g; s=aL*Math.sin(k*ds-ph); A=aL; }
        }
      } else if(avail>0){
        const d1=this.r1[idx], d2=this.r2[idx];
        const u1=ea*this.dy1[idx]/d1, E1=u1===0?1:Math.sin(u1)/u1;
        const u2=ea*this.dy2[idx]/d2, E2=u2===0?1:Math.sin(u2)/u2;
        const g1=clamp((avail-d1)/softW,0,1), g2=clamp((avail-d2)/softW,0,1);
        const a1=0.5*E1*g1, a2=0.5*E2*g2;
        s = a1*Math.sin(k*d1-ph+kOff) + a2*Math.sin(k*d2-ph+kOff);
        A = Math.sqrt(a1*a1 + a2*a2 + 2*a1*a2*Math.cos(k*(d1-d2)));
      }
      let val = 1.5*A*A + 0.5*(s>0?s:0);
      if(val>1) val=1; else if(val<0) val=0;
      data[p++]=6+val*96; data[p++]=10+val*200; data[p++]=20+val*235; data[p++]=255;
    }
    this.octx.putImageData(this.img,0,0);
    clearBG();
    ctx.save();
    ctx.imageSmoothingEnabled=true; ctx.imageSmoothingQuality='high';
    ctx.drawImage(this.off,0,0,W,H);
    ctx.restore();
    drawBarrier(this.accent);
    const pr=Math.max(5,H*0.012)*(1+0.18*Math.sin(ph));
    ctx.fillStyle=this.accent;
    ctx.beginPath(); ctx.arc(G.sourceX,G.cy,pr,0,7); ctx.fill();
    // tilted screen lights up with the bands as the waves arrive
    const reach=(ct-(this.Dsb+(G.screenX-G.barrierX)))/(H*0.5);
    drawScreenPanel(this.accent);
    drawBands(clamp(reach,0,1));
  }
};

/* =========================================================================
   SCENE 3 — ELECTRONS (dot-by-dot build-up + observe toggle)
   ========================================================================= */
const sceneElectrons = {
  tag:'3 · Electrons',
  tagColor:'var(--elec)',
  subtitle:'Electrons are tiny lumps of matter. Fire them one at a time — and watch what the screen remembers.',
  capTitle:'Matter builds the <b class="cool">wave pattern</b> — one dot at a time.',
  capSub:'Each electron lands as a single dot, yet thousands of dots form interference fringes. Unobserved, every electron travels <b class="elec">both paths at once</b>. Ask <b class="warn">"which slit?"</b> and the fringes vanish — back to two stripes.',
  accent:'#7CFFB2',
  dots:[], flying:[], count:0, acc:0, observed:false,
  onEnter(){ speedSlider(true); qctrl(true); this.reset(); },
  onLeave(){ speedSlider(false); qctrl(false); },
  onResize(){},
  reset(){ this.dots.length=0; this.flying.length=0; this.count=0;
           $('#ecount').textContent='0'; },
  sampleY(){
    const ratio=G.ratio, c1=G.cy+(G.slitTop-G.cy)*ratio, c2=G.cy+(G.slitBot-G.cy)*ratio;
    if(this.observed){
      const hw=G.slitHalf*ratio;
      const c=Math.random()<0.5?c1:c2;
      return c + (Math.random()*2-1)*hw;
    }
    for(let tries=0;tries<300;tries++){
      const y=G.yTop+Math.random()*(G.yBot-G.yTop);
      if(Math.random()<fringeI(y)) return y;
    }
    return G.cy;
  },
  fire(){
    const y=this.sampleY();
    const u=clamp((y-G.yTop)/(G.yBot-G.yTop),0,1);
    // landing depth across the tilted panel (biased to the wide far edge so the
    // physical dot density stays even); fixed now so the trajectory lands ON it.
    const d=Math.sqrt(Math.random());
    const slit = this.observed ? (y<G.cy?0:1) : (Math.random()<0.5?0:1);
    this.flying.push({t:0, y, u, d, slit, observed:this.observed});
  },
  step(dt){
    this.acc+=dt*SPEED;
    const interval=0.11;
    while(this.acc>interval){ this.acc-=interval; if(this.flying.length<32) this.fire(); }
    const sp=1.6*SPEED;
    for(const f of this.flying){
      f.t += dt*sp;
      if(f.t>=1){
        this.dots.push({u:f.u, d:f.d});
        this.count++;
        f.dead=true;
      }
    }
    this.flying=this.flying.filter(f=>!f.dead);
    $('#ecount').textContent=this.count;
    if(this.dots.length>14000) this.dots.splice(0,this.dots.length-14000);
  },
  draw(){
    clearBG();
    drawScreenPanel(this.accent);
    ctx.fillStyle=this.accent;
    for(const dd of this.dots){ const p=screenPt(dd.u,dd.d); ctx.beginPath(); ctx.arc(p[0],p[1],1.8,0,7); ctx.fill(); }
    drawBarrier(this.observed? '#ff5470' : this.accent);
    if(this.observed){
      for(const sy of [G.slitTop,G.slitBot]){
        ctx.strokeStyle='#ff5470'; ctx.lineWidth=2; ctx.globalAlpha=.9;
        ctx.beginPath(); ctx.arc(G.barrierX, sy, G.slitHalf*1.9, 0, 7); ctx.stroke();
      }
      ctx.globalAlpha=1;
    }
    for(const f of this.flying){ this.drawElectron(f); }
    ctx.fillStyle=this.accent;
    ctx.beginPath(); ctx.arc(G.sourceX,G.cy,Math.max(5,H*0.012),0,7); ctx.fill();
  },
  blob(px,py,rx,ry,color){
    ctx.save();
    ctx.translate(px,py); ctx.scale(rx,ry);
    const g=ctx.createRadialGradient(0,0,0,0,0,1);
    g.addColorStop(0,color); g.addColorStop(0.55,color+'cc'); g.addColorStop(1,color+'00');
    ctx.fillStyle=g; ctx.beginPath(); ctx.arc(0,0,1,0,7); ctx.fill();
    ctx.restore();
  },
  drawElectron(f){
    const sy=f.slit===0?G.slitTop:G.slitBot;
    const sx=G.barrierX, t=f.t;
    const L=(a,b,u)=>a+(b-a)*u;
    const spanRy = G.slitGap/2 + G.slitHalf*1.7;
    const startR = Math.max(4, H*0.013);
    const bigRx  = Math.max(6, H*0.018);
    const smallR = Math.max(2.6, H*0.008);
    // exact landing point on the tilted screen panel (so nothing overshoots it)
    const land = screenPt(f.u, f.d);
    if(!f.observed){
      ctx.globalAlpha=0.16; ctx.lineWidth=1.3; ctx.strokeStyle=this.accent;
      for(const slitY of [G.slitTop,G.slitBot]){
        ctx.beginPath(); ctx.moveTo(G.sourceX,G.cy);
        ctx.lineTo(sx,slitY); ctx.lineTo(land[0],land[1]); ctx.stroke();
      }
      ctx.globalAlpha=1;
      let px,py,rx,ry;
      if(t<0.5){ const u=t/0.5;
        px=L(G.sourceX,sx,u); py=G.cy; rx=L(startR,bigRx,u); ry=L(startR,spanRy,u);
      } else { const u=(t-0.5)/0.5;
        px=L(sx,land[0],u); py=L(G.cy,land[1],u); rx=L(bigRx,smallR,u); ry=L(spanRy,smallR,u);
      }
      this.blob(px,py,rx,ry,this.accent);
    } else {
      if(t<0.5){ const u=t/0.5;
        const px=L(G.sourceX,sx,u), rx=L(startR,bigRx,u), ry=L(startR,spanRy,u);
        this.blob(px,G.cy,rx,ry,this.accent);
      } else { const u=(t-0.5)/0.5;
        const flash=Math.max(0,1-u/0.35);
        if(flash>0){ ctx.globalAlpha=flash; ctx.fillStyle='#ff5470';
          ctx.beginPath(); ctx.arc(sx,sy,G.slitHalf*2.6,0,7); ctx.fill(); ctx.globalAlpha=1; }
        ctx.globalAlpha=.4; ctx.strokeStyle='#ff5470'; ctx.lineWidth=1.3;
        ctx.beginPath(); ctx.moveTo(sx,sy); ctx.lineTo(land[0],land[1]); ctx.stroke();
        ctx.globalAlpha=1;
        const px=L(sx,land[0],u), py=L(sy,land[1],u);
        ctx.fillStyle=this.accent; ctx.beginPath(); ctx.arc(px,py,smallR,0,7); ctx.fill();
      }
    }
  }
};

/* ----------------------------- scene manager ------------------------------ */
const scenes=[sceneBalls, sceneWaves, sceneElectrons];
let cur=0, last=performance.now();

const els = {
  subtitle:$('#subtitle'),
  tag:$('#tag'),
  capTitle:$('#capTitle'),
  capSub:$('#capSub'),
  caption:$('#caption'),
};

function speedSlider(show){ $('#speedctrl').style.display = show?'flex':'none'; }
function qctrl(show){ $('#qctrl').style.display = show?'flex':'none'; }
let SPEED = 0.075;
$('#speed').addEventListener('input',e=> SPEED=parseFloat(e.target.value));

const dotsWrap=$('#dots');
const labels=['Balls','Waves','Electrons'];
const dotEls=labels.map((l,i)=>{
  const d=document.createElement('div'); d.className='dot';
  d.innerHTML=`<span class="pip"></span><span class="dl">${l}</span>`;
  d.onclick=()=>go(i); dotsWrap.appendChild(d); return d;
});

function applySceneUI(s){
  els.subtitle.textContent=s.subtitle;
  els.tag.textContent=s.tag; els.tag.style.color=s.tagColor; els.tag.style.borderColor=s.tagColor+'55';
  els.capTitle.innerHTML=s.capTitle;
  els.capSub.innerHTML=s.capSub;
  dotEls.forEach((d,i)=>d.classList.toggle('active',i===cur));
}

function go(i){
  i=clamp(i,0,scenes.length-1);
  if(i===cur){ return; }
  scenes[cur].onLeave && scenes[cur].onLeave();
  cur=i;
  scenes[cur].onResize && scenes[cur].onResize();
  scenes[cur].onEnter && scenes[cur].onEnter();
  applySceneUI(scenes[cur]);
}

// Scenes are switched only via the Balls / Waves / Electrons labels.
// No ◀ ▶ buttons and no arrow-key handler — arrows are reserved for deck navigation.

const obsToggle=$('#obsToggle');
obsToggle.onclick=()=>{
  sceneElectrons.observed=!sceneElectrons.observed;
  obsToggle.classList.toggle('on',sceneElectrons.observed);
  sceneElectrons.reset();
};
$('#sceneReset').onclick=()=>{ const s=scenes[cur]; s.reset && s.reset(); };

function loop(now){
  let dt=(now-last)/1000; last=now;
  dt=Math.min(dt,0.05);
  const s=scenes[cur];
  s.step(dt);
  s.draw();
  requestAnimationFrame(loop);
}

resize();
scenes[0].onResize && scenes[0].onResize();
scenes[0].onEnter && scenes[0].onEnter();
applySceneUI(scenes[0]);
requestAnimationFrame(loop);
})();
</script>
"""

    HTML(_scene)
end

# ╔═╡ 1e7fbf4b-5a2f-4382-8c44-843d386706b7
# @live from binary-base2.jl
blank_slide() do
    # Self-contained DOM scene (no external assets). Scoped for the deck:
    #   - all CSS prefixed under #bb-root
    #   - JS wrapped in an IIFE; document.getElementById -> gid() queries within
    #     `root` so it survives MCPresPluto's Shadow DOM in slide mode
    #   - the global arrow-key handler is removed (arrows drive deck navigation);
    #     scenes switch via the Counting / Adding labels
    #   - font switched to Cabin; sized to the 4:3 slide box
    # raw"""...""" avoids Julia $-interpolation clashing with the JS ${...} literals.
    _scene = raw"""
<div id="bb-root">
  <!-- Hidden canvas: makes MCPresPluto keep this slide IN-PLACE (light DOM) in
       slide mode — the same path the canvas-based double-slit slide takes —
       instead of moving it into the Shadow DOM, where Pluto's cloned global CSS
       breaks the scene (clicks dead / mis-sized). The canvas is otherwise unused. -->
  <canvas width="0" height="0" style="display:none" aria-hidden="true"></canvas>
  <header>
    <h1>Counting &amp; Adding in <span class="a">Base 2</span></h1>
    <p id="subtitle"></p>
  </header>

  <div class="stage">
    <div class="panel" id="panel">
      <div class="tag" id="tag"></div>

      <!-- ===================== SCENE 1: COUNTING ===================== -->
      <div class="scene" id="scene1">
        <div class="s1ctrl">
          <button class="stepbtn" id="s1minus">- 1</button>
          <button class="stepbtn" id="s1plus">+ 1</button>
          <button class="stepbtn play" id="s1play">&#9654; Count</button>
        </div>

        <div class="s1wrap">
          <div class="bitrow" id="bitrow"></div>
          <div class="sumline" id="s1sum"></div>
          <div class="readout">
            <div>
              <div class="bignum"><span class="bincode" id="binBig">0000</span></div>
              <div class="numlab">binary</div>
            </div>
            <div class="bignum eq">=</div>
            <div>
              <div class="bignum"><span class="deccode" id="decBig">0</span></div>
              <div class="numlab">decimal</div>
            </div>
          </div>
        </div>
      </div>

      <!-- ===================== SCENE 2: ADDITION ===================== -->
      <div class="scene" id="scene2">
        <div class="s2top">
          <div class="picker a">
            <label>A</label>
            <input type="range" id="inA" min="0" max="15" step="1" value="6">
            <span class="val" id="valA">6</span>
          </div>
          <div class="picker b">
            <label>B</label>
            <input type="range" id="inB" min="0" max="15" step="1" value="7">
            <span class="val" id="valB">7</span>
          </div>
          <button class="stepbtn" id="addStep">Step &#9654;</button>
          <button class="stepbtn play" id="addAuto">Add it &#9889;</button>
          <button class="stepbtn" id="addReset">&#8635;</button>
        </div>

        <div class="add" id="addGrid"></div>
        <div class="s2status" id="s2status"></div>
      </div>
    </div>
  </div>

  <div class="controls">
    <div class="caption" id="caption">
      <div class="ct" id="capTitle"></div>
      <div class="cs" id="capSub"></div>
    </div>
    <div class="dots" id="dots"></div>
  </div>
</div>

<style>
  #bb-root{
    --bg:#05060d; --ink:#eef2ff; --muted:#8b93b8;
    --warm:#ffb24a;     /* the "1" / on */
    --cool:#6ad7ff;     /* place values / accents */
    --elec:#7CFFB2;     /* result / success */
    --warn:#ff5470;     /* carry */
    --line:#1c2238;
    /* Fill the slide box exactly in slide mode (definite parent height); in the
       notebook editor aspect-ratio derives a landscape height from the width.
       max-height keeps us inside MCPresPluto's 4:3 box (no vh min-height). */
    width:100%; height:100%; max-height:100%; aspect-ratio:4 / 3;
    background:radial-gradient(1200px 800px at 50% -10%, #11162b 0%, var(--bg) 60%);
    color:var(--ink);
    font-family:'Cabin','Inter',system-ui,-apple-system,"Segoe UI",Roboto,Helvetica,Arial,sans-serif;
    overflow:hidden;display:flex;flex-direction:column;border-radius:10px;
  }
  #bb-root *{box-sizing:border-box;margin:0;padding:0}
  #bb-root header{text-align:center;padding:14px 16px 6px;flex:0 0 auto}
  #bb-root header h1{font-size:clamp(19px,2.5vw,32px);font-weight:700;letter-spacing:.4px}
  #bb-root header h1 .a{color:var(--cool)}
  #bb-root header p{color:var(--muted);font-size:clamp(12px,1.2vw,15.5px);margin-top:5px;min-height:1.2em;transition:opacity .3s}

  #bb-root .stage{flex:1 1 auto;display:flex;padding:0 18px;min-height:0}
  #bb-root .panel{position:relative;flex:1 1 100%;border:1px solid var(--line);border-radius:16px;
    overflow:hidden;background:#000;box-shadow:0 0 40px rgba(0,0,0,.6) inset;
    display:flex;align-items:center;justify-content:center}

  /* scene tag (top-left) */
  #bb-root .tag{position:absolute;top:14px;left:14px;z-index:5;font-size:12px;letter-spacing:2px;
    font-weight:700;text-transform:uppercase;padding:6px 11px;border-radius:8px;
    background:#0008;backdrop-filter:blur(4px);border:1px solid var(--line);transition:color .3s,border-color .3s}

  /* caption (centered, in the bottom controls bar) */
  #bb-root .caption{max-width:min(720px,94%);margin:0 auto;
    background:#0009;border:1px solid #ffffff22;border-radius:12px;padding:10px 16px;
    backdrop-filter:blur(5px);text-align:center;transition:opacity .3s}
  #bb-root .caption .ct{font-size:clamp(13px,1.5vw,17px);font-weight:700;line-height:1.25}
  #bb-root .caption .cs{font-size:clamp(11px,1.2vw,13.5px);color:#c9d1f5;margin-top:4px;line-height:1.35}
  #bb-root .caption b.warm{color:var(--warm)} #bb-root .caption b.cool{color:var(--cool)}
  #bb-root .caption b.elec{color:var(--elec)} #bb-root .caption b.warn{color:var(--warn)}

  /* each scene fills the panel */
  #bb-root .scene{position:absolute;inset:0;display:none;align-items:center;justify-content:center;
    flex-direction:column;padding:46px 18px 14px}
  #bb-root .scene.active{display:flex}

  /* ---------- shared bit / cell styling ---------- */
  #bb-root .bit{
    --sz:clamp(34px,5.5vw,80px);
    width:var(--sz);height:var(--sz);border-radius:16px;
    display:flex;align-items:center;justify-content:center;
    font-size:calc(var(--sz)*0.5);font-weight:800;font-variant-numeric:tabular-nums;
    border:2px solid #2a3150;background:#0d1226;color:#566089;
    transition:all .25s cubic-bezier(.2,.8,.3,1);user-select:none;position:relative;
  }
  #bb-root .bit.on{
    border-color:var(--warm);color:#1a1206;
    background:radial-gradient(120% 120% at 50% 0%, #ffd089 0%, var(--warm) 70%);
    box-shadow:0 0 26px -2px var(--warm);transform:translateY(-2px);
  }
  #bb-root .bit.click{cursor:pointer}
  #bb-root .bit.click:hover{border-color:var(--warm);box-shadow:0 0 16px -4px var(--warm)}
  #bb-root .place{font-size:clamp(10px,1.1vw,14px);color:var(--cool);font-weight:700;
    text-align:center;margin-top:5px;letter-spacing:.3px}
  #bb-root .placefade{color:var(--muted);font-weight:500;font-size:clamp(10px,1.1vw,12px);margin-top:2px}

  /* scene 1 layout */
  #bb-root .s1wrap{display:flex;flex-direction:column;align-items:center;gap:4px}
  #bb-root .bitrow{display:flex;gap:clamp(8px,1.4vw,18px);align-items:flex-start}
  #bb-root .bitcol{display:flex;flex-direction:column;align-items:center}
  #bb-root .readout{display:flex;align-items:center;gap:clamp(12px,2.4vw,36px);margin-top:16px;flex-wrap:wrap;justify-content:center}
  #bb-root .bignum{font-size:clamp(28px,4.4vw,60px);font-weight:800;line-height:1;font-variant-numeric:tabular-nums}
  #bb-root .bignum .eq{color:var(--muted);font-weight:400;margin:0 .15em}
  #bb-root .bincode{color:var(--warm)} #bb-root .deccode{color:var(--elec)}
  #bb-root .numlab{font-size:12px;color:var(--muted);letter-spacing:2px;text-transform:uppercase;text-align:center;margin-top:6px}
  #bb-root .sumline{font-size:clamp(12px,1.5vw,17px);color:#c9d1f5;margin-top:13px;min-height:1.4em;text-align:center;font-variant-numeric:tabular-nums}
  #bb-root .sumline .t{color:var(--warm);font-weight:700}

  /* scene 1 controls */
  #bb-root .s1ctrl{position:absolute;top:14px;right:14px;z-index:6;display:flex;gap:8px;align-items:center}
  #bb-root .stepbtn{font-size:13px;color:var(--ink);background:#121734;border:1px solid var(--line);
    border-radius:9px;padding:7px 14px;cursor:pointer;transition:background .15s;font-weight:600}
  #bb-root .stepbtn:hover{background:#1b2350}
  #bb-root .stepbtn.play.on{background:#3a2a12;border-color:var(--warm);color:var(--warm)}

  /* scene 2 layout: the addition "worksheet" */
  #bb-root .add{display:grid;grid-template-columns:auto repeat(5,var(--cell));gap:0 clamp(6px,1vw,12px);
    --cell:clamp(34px,5vw,80px);align-items:center;justify-items:center;font-variant-numeric:tabular-nums}
  #bb-root .add .lab{justify-self:end;color:var(--muted);font-size:clamp(11px,1.3vw,15px);
    font-weight:600;padding-right:10px;white-space:nowrap}
  #bb-root .add .lab b{color:var(--cool)}
  #bb-root .add .carry{height:clamp(20px,2.4vw,32px);display:flex;align-items:center;justify-content:center;
    font-size:clamp(13px,1.7vw,22px);font-weight:800;color:var(--warn);opacity:0;transition:opacity .3s,transform .3s;transform:translateY(6px)}
  #bb-root .add .carry.show{opacity:1;transform:translateY(0)}
  #bb-root .add .place2{color:var(--cool);font-size:clamp(10px,1.1vw,13px);font-weight:700;height:20px}
  #bb-root .cell{
    --sz:clamp(30px,4.4vw,72px);width:var(--sz);height:var(--sz);border-radius:13px;
    display:flex;align-items:center;justify-content:center;
    font-size:calc(var(--sz)*0.5);font-weight:800;
    border:2px solid #2a3150;background:#0d1226;color:#566089;transition:all .3s}
  #bb-root .cell.one{border-color:var(--warm);color:#1a1206;
    background:radial-gradient(120% 120% at 50% 0%, #ffd089 0%, var(--warm) 70%);box-shadow:0 0 18px -4px var(--warm)}
  #bb-root .cell.res.one{border-color:var(--elec);color:#06150d;
    background:radial-gradient(120% 120% at 50% 0%, #b6ffd9 0%, var(--elec) 70%);box-shadow:0 0 18px -3px var(--elec)}
  #bb-root .cell.active{outline:3px solid var(--cool);outline-offset:3px}
  #bb-root .cell.empty{border:none;background:none;box-shadow:none}
  #bb-root .rule{grid-column:2 / -1;height:3px;background:#2a3150;border-radius:3px;margin:6px 0;align-self:stretch;justify-self:stretch;width:100%}
  #bb-root .plus{justify-self:end;color:var(--warm);font-weight:800;font-size:clamp(16px,2.4vw,32px)}

  /* scene 2 controls */
  #bb-root .s2top{position:absolute;top:14px;right:14px;z-index:6;display:flex;gap:10px;align-items:center;flex-wrap:wrap;justify-content:flex-end}
  #bb-root .picker{display:flex;align-items:center;gap:8px;background:#0009;border:1px solid #ffffff22;
    border-radius:10px;padding:6px 12px;backdrop-filter:blur(5px)}
  #bb-root .picker label{font-size:12px;color:var(--muted)}
  #bb-root .picker .val{font-size:15px;font-weight:800;font-variant-numeric:tabular-nums;min-width:1.4em;text-align:center}
  #bb-root .picker.a .val{color:var(--warm)} #bb-root .picker.b .val{color:var(--cool)}
  #bb-root .picker input{width:90px}
  #bb-root .s2status{font-size:clamp(12px,1.6vw,19px);margin-top:16px;min-height:1.5em;text-align:center;color:#c9d1f5;font-variant-numeric:tabular-nums}
  #bb-root .s2status .r{color:var(--elec);font-weight:800}
  #bb-root .s2status .c{color:var(--warn);font-weight:800}

  /* bottom controls: caption + scene selector, centered and pushed low */
  #bb-root .controls{flex:0 0 auto;padding:6px 24px 8px;display:flex;flex-direction:column;align-items:center;gap:10px}
  #bb-root .dots{display:flex;gap:18px;align-items:center}
  #bb-root .dot{display:flex;flex-direction:column;align-items:center;gap:6px;cursor:pointer;opacity:.55;transition:opacity .2s}
  #bb-root .dot.active{opacity:1}
  #bb-root .dot .pip{width:11px;height:11px;border-radius:50%;background:#39406a;transition:background .2s,box-shadow .2s}
  #bb-root .dot.active .pip{background:var(--cool);box-shadow:0 0 12px var(--cool)}
  #bb-root .dot .dl{font-size:11.5px;color:var(--muted);letter-spacing:.3px}
  #bb-root .dot.active .dl{color:var(--ink);font-weight:700}
</style>

<script>
(function(){
"use strict";
const root = document.getElementById('bb-root');
if(!root || root._bbInit) return;
root._bbInit = true;
const gid = id => root.querySelector('#'+id);
/* ============================================================================
   COUNTING & ADDING IN BASE 2  —  2 navigable scenes
     1) Counting: 4 clickable bits (8 4 2 1), live binary<->decimal, auto-count
     2) Addition: pick A and B (0..15), watch the column-by-column add with carries
   Same house style as the double-slit slide. Sets up classical logic / gates.
   ========================================================================== */

const PLACES = [8,4,2,1];                  // most-significant first
const POWLAB = ['2³','2²','2¹','2⁰'];

/* ----------------------------- shared UI refs ----------------------------- */
const els = {
  subtitle:gid('subtitle'),
  tag:gid('tag'),
  capTitle:gid('capTitle'),
  capSub:gid('capSub'),
};

/* =========================================================================
   SCENE 1 — COUNTING IN BINARY
   ========================================================================= */
const S1 = {
  tag:'1 · Counting',
  tagColor:'var(--cool)',
  subtitle:'We only have two digits: 0 and 1. Click the boxes — each one is worth twice the one to its right.',
  capTitle:'Every number is a sum of <b class="cool">powers of two</b>.',
  capSub:'Each box is a <b class="warm">bit</b>: off = 0, on = 1. A box that is <b class="warm">on</b> adds its value (8, 4, 2 or 1). Add the lit boxes and you get the decimal number — that is all "base 2" means.',
  value:0, bits:[0,0,0,0], cells:[], playing:false, timer:null,
  build(){
    const row=gid('bitrow');
    row.innerHTML='';
    this.cells=[];
    PLACES.forEach((p,i)=>{
      const col=document.createElement('div'); col.className='bitcol';
      const bit=document.createElement('div'); bit.className='bit click';
      bit.textContent='0';
      bit.onclick=()=>{ this.bits[i]^=1; this.sync(); };
      const place=document.createElement('div'); place.className='place';
      place.innerHTML=p+' <span style="opacity:.6">('+POWLAB[i]+')</span>';
      col.appendChild(bit); col.appendChild(place);
      row.appendChild(col);
      this.cells.push(bit);
    });
    this.sync();
  },
  set(v){ v=((v%16)+16)%16; this.bits=PLACES.map(p=>(v&p)?1:0); this.sync(); },
  sync(){
    let v=0, parts=[];
    PLACES.forEach((p,i)=>{
      const on=this.bits[i];
      this.cells[i].textContent=on?'1':'0';
      this.cells[i].classList.toggle('on',!!on);
      if(on){ v+=p; parts.push(p); }
    });
    this.value=v;
    gid('binBig').textContent=this.bits.join('');
    gid('decBig').textContent=v;
    const sum=gid('s1sum');
    if(parts.length===0){ sum.innerHTML='Nothing lit → <span class="t">0</span>'; }
    else { sum.innerHTML=parts.join(' <span style="color:var(--muted)">+</span> ')+
            ' <span style="color:var(--muted)">=</span> <span class="t">'+v+'</span>'; }
  },
  togglePlay(){
    this.playing=!this.playing;
    const btn=gid('s1play');
    btn.classList.toggle('on',this.playing);
    btn.textContent=this.playing?'⏸ Pause':'▶ Count';
    if(this.playing){ this.timer=setInterval(()=>this.set(this.value+1),750); }
    else { clearInterval(this.timer); }
  },
  onEnter(){ this.build(); },
  onLeave(){ if(this.playing) this.togglePlay(); },
};

gid('s1plus').onclick =()=>S1.set(S1.value+1);
gid('s1minus').onclick=()=>S1.set(S1.value-1);
gid('s1play').onclick =()=>S1.togglePlay();

/* =========================================================================
   SCENE 2 — ADDING IN BINARY (with carries)
   ========================================================================= */
const S2 = {
  tag:'2 · Adding',
  tagColor:'var(--elec)',
  subtitle:'Add two numbers the same way you learned in school — right to left — but the only rule is 1 + 1 = 10 (carry the 1).',
  capTitle:'Add column by column; <b class="warn">1 + 1 carries</b> to the next.',
  capSub:'In each column add the two bits plus any <b class="warn">carry</b>. 0+0=0, 1+0=1, and <b class="warn">1+1 = "0 carry 1"</b>. The carry slides left into the next column — exactly like carrying the 10 in ordinary addition.',
  a:6, b:7, NB:4,            // NB input bits; result needs NB+1
  step:-1, autoTimer:null,
  // DOM cell stores: carry row (NB+1), A row, B row, result row
  cells:{carry:[],a:[],b:[],res:[]},
  build(){
    const g=gid('addGrid');
    g.style.setProperty('--cell','clamp(46px,7.5vw,86px)');
    g.innerHTML='';
    const COLS=this.NB+1;                    // result width (extra column on the left)
    this.cells={carry:[],a:[],b:[],res:[]};

    const placeOf=(colFromLeft)=> Math.pow(2, COLS-1-colFromLeft); // value of column

    // --- row 0: carries (label + COLS) ---
    g.appendChild(mk('lab','carry →'));
    for(let c=0;c<COLS;c++){ const e=mk('carry',''); this.cells.carry.push(e); g.appendChild(e); }
    // --- row 1: place labels ---
    g.appendChild(mk('lab',''));
    for(let c=0;c<COLS;c++){ g.appendChild(mk('place2', placeOf(c))); }
    // --- row 2: A ---
    g.appendChild(labHTML('<b>A</b> = '+this.a));
    for(let c=0;c<COLS;c++){ const e=cellEl(); this.cells.a.push(e); g.appendChild(e); }
    // --- row 3: B ---
    g.appendChild(plusLab());
    for(let c=0;c<COLS;c++){ const e=cellEl(); this.cells.b.push(e); g.appendChild(e); }
    // --- rule line ---
    const r=document.createElement('div'); r.className='rule'; g.appendChild(r);
    // --- row 4: result ---
    g.appendChild(labHTML('<b style="color:var(--elec)">Sum</b>'));
    for(let c=0;c<COLS;c++){ const e=cellEl(); e.classList.add('res'); this.cells.res.push(e); g.appendChild(e); }

    this.reset();

    function mk(cls,txt){ const e=document.createElement('div'); e.className=cls; e.textContent=txt; return e; }
    function labHTML(html){ const e=document.createElement('div'); e.className='lab'; e.innerHTML=html; return e; }
    function plusLab(){ const e=document.createElement('div'); e.className='plus'; e.textContent='+'; return e; }
    function cellEl(){ const e=document.createElement('div'); e.className='cell'; return e; }
  },
  bitsOf(v,cols){ const out=[]; for(let i=cols-1;i>=0;i--) out.push((v>>i)&1); return out; }, // MSB..LSB
  reset(){
    clearInterval(this.autoTimer); this.autoTimer=null;
    gid('addAuto').classList.remove('on');
    gid('addAuto').textContent='Add it ⚡';
    this.step=-1;
    const COLS=this.NB+1;
    const ab=this.bitsOf(this.a,COLS), bb=this.bitsOf(this.b,COLS);
    for(let c=0;c<COLS;c++){
      paint(this.cells.a[c], ab[c]);
      paint(this.cells.b[c], bb[c]);
      // hide the always-zero top A/B box so the extra column reads as "room for carry"
      this.cells.a[c].classList.toggle('empty', c===0);
      this.cells.b[c].classList.toggle('empty', c===0);
      this.cells.res[c].className='cell res';
      this.cells.res[c].textContent='';
      this.cells.carry[c].textContent='';
      this.cells.carry[c].classList.remove('show');
    }
    gid('s2status').innerHTML=
      'A = <b style="color:var(--warm)">'+this.a+'</b> ('+this.a.toString(2).padStart(this.NB,'0')+
      ')  +  B = <b style="color:var(--cool)">'+this.b+'</b> ('+this.b.toString(2).padStart(this.NB,'0')+
      ')  —  press <b>Step</b> or <b>Add it</b>.';
    function paint(el,bit){ el.textContent=bit; el.classList.toggle('one',bit===1); }
  },
  // advance one column (right to left). step counts columns done.
  next(){
    const COLS=this.NB+1;
    if(this.step>=COLS-1){ this.finish(); return false; }
    this.step++;
    const col=COLS-1-this.step;               // index from left of the column being processed
    const ab=this.bitsOf(this.a,COLS), bb=this.bitsOf(this.b,COLS);
    // carry coming into this column was written into this.cells.carry[col] already (or 0)
    const cin = this.cells.carry[col].textContent==='1' ? 1 : 0;
    const sum = ab[col]+bb[col]+cin;
    const bit = sum & 1;
    const cout= sum >> 1;
    // highlight current column
    [...this.cells.a,...this.cells.b,...this.cells.res].forEach(e=>e.classList.remove('active'));
    this.cells.a[col].classList.add('active');
    this.cells.b[col].classList.add('active');
    this.cells.res[col].classList.add('active');
    // write result bit
    this.cells.res[col].textContent=bit;
    this.cells.res[col].classList.toggle('one',bit===1);
    // write carry-out into the column to the left
    if(col-1>=0){
      this.cells.carry[col-1].textContent=cout? '1':'';
      this.cells.carry[col-1].classList.toggle('show',cout===1);
    }
    const pv=Math.pow(2,this.step);
    const cinTxt = cin? ' + carry <span class="c">1</span>' : '';
    let line='Column '+pv+': <b style="color:var(--warm)">'+ab[col]+'</b> + <b style="color:var(--cool)">'+bb[col]+'</b>'+cinTxt+
             ' = '+sum+' → write <span class="r">'+bit+'</span>';
    if(cout) line+=', carry <span class="c">1</span> left';
    gid('s2status').innerHTML=line;
    if(this.step>=COLS-1){ setTimeout(()=>this.finish(),10); }
    return true;
  },
  finish(){
    [...this.cells.a,...this.cells.b,...this.cells.res].forEach(e=>e.classList.remove('active'));
    clearInterval(this.autoTimer); this.autoTimer=null;
    gid('addAuto').classList.remove('on');
    gid('addAuto').textContent='Add it ⚡';
    const tot=this.a+this.b;
    const COLS=this.NB+1;
    gid('s2status').innerHTML=
      '<b style="color:var(--warm)">'+this.a+'</b> + <b style="color:var(--cool)">'+this.b+'</b> = '+
      '<span class="r">'+tot+'</span>  =  <span class="r">'+tot.toString(2).padStart(COLS,'0')+'</span> in binary.';
  },
  auto(){
    if(this.autoTimer){ // pause
      clearInterval(this.autoTimer); this.autoTimer=null;
      gid('addAuto').classList.remove('on');
      gid('addAuto').textContent='Add it ⚡';
      return;
    }
    if(this.step>=this.NB){ this.reset(); }
    gid('addAuto').classList.add('on');
    gid('addAuto').textContent='⏸';
    this.autoTimer=setInterval(()=>{ if(!this.next()){ } },900);
  },
  onEnter(){ this.build(); },
  onLeave(){ clearInterval(this.autoTimer); this.autoTimer=null; },
};

gid('inA').addEventListener('input',e=>{
  S2.a=+e.target.value; gid('valA').textContent=S2.a; S2.reset();
});
gid('inB').addEventListener('input',e=>{
  S2.b=+e.target.value; gid('valB').textContent=S2.b; S2.reset();
});
gid('addStep').onclick =()=>S2.next();
gid('addAuto').onclick =()=>S2.auto();
gid('addReset').onclick=()=>S2.reset();

/* ----------------------------- scene manager ------------------------------ */
const scenes=[S1,S2];
const sceneEls=[gid('scene1'),gid('scene2')];
let cur=0;

const dotsWrap=gid('dots');
const labels=['Counting','Adding'];
const dotEls=labels.map((l,i)=>{
  const d=document.createElement('div'); d.className='dot';
  d.innerHTML=`<span class="pip"></span><span class="dl">${l}</span>`;
  d.onclick=()=>go(i); dotsWrap.appendChild(d); return d;
});

function applySceneUI(s){
  els.subtitle.textContent=s.subtitle;
  els.tag.textContent=s.tag; els.tag.style.color=s.tagColor; els.tag.style.borderColor=s.tagColor+'55';
  els.capTitle.innerHTML=s.capTitle;
  els.capSub.innerHTML=s.capSub;
  dotEls.forEach((d,i)=>d.classList.toggle('active',i===cur));
  sceneEls.forEach((e,i)=>e.classList.toggle('active',i===cur));
}

function go(i){
  i=Math.max(0,Math.min(scenes.length-1,i));
  if(i===cur) return;
  scenes[cur].onLeave && scenes[cur].onLeave();
  cur=i;
  scenes[cur].onEnter && scenes[cur].onEnter();
  applySceneUI(scenes[cur]);
}

// Scenes are switched only via the Counting / Adding labels — no nav buttons
// and no arrow-key handler (arrows are reserved for deck navigation).

/* boot */
scenes[0].onEnter && scenes[0].onEnter();
applySceneUI(scenes[0]);
})();
</script>
"""

    HTML(_scene)
end

# ╔═╡ fceb9b41-4f02-43d1-abda-8a869976377a
# @live from cannon-bits.jl
blank_slide() do
    # Canvas-only scene (no external images), so it is fully self-contained and
    # works in the notebook view, in slide mode (the <canvas> keeps the slide
    # in-place in the light DOM), and in static HTML/PDF export. Scoped for the
    # deck like double-slit.jl:
    #   - all CSS prefixed under #cb-root
    #   - JS wrapped in an IIFE that queries within `root` (not `document`)
    #   - the global arrow-key handler is removed (arrows drive deck navigation);
    #     the ◀ ▶ buttons and clickable dots still switch sub-scenes
    #   - the base-2 worksheet is position:absolute in the root (was fixed)
    #   - font switched to Cabin
    # raw"""...""" avoids Julia $-interpolation / backslash clashes with the
    # scene's JS.
    _scene = raw"""
<div id="cb-root">
  <header>
    <h1>Bits as <span class="a">Cannonballs</span></h1>
    <p id="subtitle"></p>
  </header>

  <div class="stage">
    <div class="panel" id="panel">
      <canvas id="cv"></canvas>
      <div class="tag" id="tag"></div>
      <div class="sctrl" id="sctrl"></div>
      <div class="readout" id="readout"></div>
    </div>
  </div>

  <div class="controls">
    <div class="dots" id="dots"></div>
    <div class="navrow">
      <button class="nav" id="prev" title="Previous (&#8592;)">&#9664;</button>
      <button class="nav" id="next" title="Next (&#8594;)">&#9654;</button>
    </div>
    <div class="hint">Use <b>&#9664; &#9654;</b> or the dots to move between panels &middot; fire the cannon to send a bit.</div>
  </div>

  <div class="wsheet" id="wsheet">
    <div class="wsh-head"><b>binary addition</b><span class="wsh-badge" id="wshBadge">0/6</span></div>
    <table class="wsh-grid">
      <tr class="wsh-carry"><td class="wsh-lab">carry</td><td id="wsC4"></td><td id="wsC2"></td><td></td></tr>
      <tr><td class="wsh-lab">A</td><td></td><td id="wsA2"></td><td id="wsA1"></td></tr>
      <tr><td class="wsh-lab">+B</td><td></td><td id="wsB2"></td><td id="wsB1"></td></tr>
      <tr class="wsh-rule"><td></td><td colspan="3"><hr></td></tr>
      <tr class="wsh-sum"><td class="wsh-lab">Sum</td><td id="wsS4"></td><td id="wsS2"></td><td id="wsS1"></td></tr>
    </table>
  </div></div>

<style>
  #cb-root{
    --bg:#05060d;
    --ink:#eef2ff;
    --muted:#8b93b8;
    --warm:#ffb24a;     /* the "1" / up slit */
    --cool:#6ad7ff;     /* the "0" / down slit */
    --elec:#7CFFB2;     /* gates / operations */
    --warn:#ff5470;     /* carry (later) */
    --line:#1c2238;
  }
  #cb-root *{box-sizing:border-box;margin:0;padding:0}
  
  #cb-root{
    background:radial-gradient(1200px 800px at 50% -10%, #11162b 0%, var(--bg) 60%);
    color:var(--ink);
    font-family:'Cabin','Inter',system-ui,-apple-system,"Segoe UI",Roboto,Helvetica,Arial,sans-serif;
    position:relative;overflow:hidden;display:flex;flex-direction:column;
    /* Fill the slide box exactly in slide mode (parent has a definite height,
       so height:100% wins and aspect-ratio is ignored). In the notebook editor
       the parent height is auto, height:100% collapses, and aspect-ratio then
       derives a landscape height from the cell width. */
    width:100%;height:100%;max-height:100%;aspect-ratio:4 / 3;border-radius:10px;
  }
  #cb-root header{text-align:center;padding:14px 16px 6px;flex:0 0 auto}
  #cb-root header h1{font-size:clamp(19px,2.5vw,32px);font-weight:700;letter-spacing:.4px}
  #cb-root header h1 .a{color:var(--cool)}
  #cb-root header p{color:var(--muted);font-size:clamp(12px,1.2vw,15.5px);margin-top:5px;min-height:1.2em;transition:opacity .3s}

  #cb-root .stage{flex:1 1 auto;display:flex;padding:0 18px;min-height:0}
  #cb-root .panel{position:relative;flex:1 1 100%;border:1px solid var(--line);border-radius:16px;
    overflow:hidden;background:#000;box-shadow:0 0 40px rgba(0,0,0,.6) inset;}
  #cb-root canvas{position:absolute;inset:0;width:100%;height:100%;display:block}

  #cb-root .tag{position:absolute;top:14px;left:14px;z-index:5;font-size:12px;letter-spacing:2px;
    font-weight:700;text-transform:uppercase;padding:6px 11px;border-radius:8px;
    background:#0008;backdrop-filter:blur(4px);border:1px solid var(--line);transition:color .3s,border-color .3s}

  #cb-root .sctrl{position:absolute;top:14px;right:14px;z-index:6;display:flex;gap:8px;align-items:center;flex-wrap:wrap;justify-content:flex-end}
  #cb-root .stepbtn{font-size:13px;color:var(--ink);background:#121734;border:1px solid var(--line);
    border-radius:9px;padding:7px 14px;cursor:pointer;transition:background .15s;font-weight:600}
  #cb-root .stepbtn:hover{background:#1b2350}
  #cb-root .stepbtn.up{border-color:#ffb24a55;color:#ffd089}
  #cb-root .stepbtn.dn{border-color:#6ad7ff55;color:#bdecff}

  #cb-root .readout{position:absolute;left:16px;bottom:16px;z-index:5;font-size:clamp(13px,1.6vw,18px);
    color:#c9d1f5;font-variant-numeric:tabular-nums;min-height:1.4em;transition:opacity .3s}
  #cb-root .readout b.w{color:var(--warm)} #cb-root .readout b.c{color:var(--cool)} #cb-root .readout b.e{color:var(--elec)}
  #cb-root .panel.wsmode .readout{display:none}

  #cb-root .controls{flex:0 0 auto;padding:12px 24px 18px;display:flex;flex-direction:column;align-items:center;gap:9px}
  #cb-root .dots{display:flex;gap:18px;align-items:center}
  #cb-root .dot{display:flex;flex-direction:column;align-items:center;gap:6px;cursor:pointer;opacity:.55;transition:opacity .2s}
  #cb-root .dot.active{opacity:1}
  #cb-root .dot .pip{width:11px;height:11px;border-radius:50%;background:#39406a;transition:background .2s,box-shadow .2s}
  #cb-root .dot.active .pip{background:var(--cool);box-shadow:0 0 12px var(--cool)}
  #cb-root .dot .dl{font-size:11.5px;color:var(--muted);letter-spacing:.3px}
  #cb-root .dot.active .dl{color:var(--ink);font-weight:700}
  #cb-root .navrow{display:flex;align-items:center;gap:16px}
  #cb-root button.nav{background:#121734;color:var(--ink);border:1px solid var(--line);border-radius:10px;
    width:46px;height:40px;font-size:18px;cursor:pointer;transition:background .15s,transform .1s}
  #cb-root button.nav:hover{background:#1b2350} #cb-root button.nav:active{transform:scale(.94)}
  #cb-root button.nav:disabled{opacity:.3;cursor:default}
  #cb-root .hint{color:var(--muted);font-size:12px;text-align:center}
  #cb-root .hint b{color:var(--ink)}

  /* base-2 worksheet (adder panel only) — HTML element, can overlap the controls */
  #cb-root .wsheet{position:absolute;left:22px;bottom:12px;z-index:30;display:none;
    background:rgba(11,16,32,0.94);border:1px solid var(--line);border-radius:11px;
    padding:8px 12px 9px;font-family:'Cabin','Inter',system-ui,sans-serif}
  #cb-root .wsheet.show{display:block}
  #cb-root .wsh-head{display:flex;justify-content:space-between;align-items:center;gap:22px;margin-bottom:4px}
  #cb-root .wsh-head b{font-size:12px;font-weight:700;color:var(--ink)}
  #cb-root .wsh-badge{font-size:11px;font-weight:700;color:var(--elec)}
  #cb-root .wsh-grid{border-collapse:collapse;font-variant-numeric:tabular-nums}
  #cb-root .wsh-grid td{width:24px;height:22px;text-align:center;font-size:15px;font-weight:800;color:var(--ink)}
  #cb-root .wsh-grid td.wsh-lab{width:auto;text-align:right;padding-right:8px;font-size:11px;font-weight:600;color:var(--muted)}
  #cb-root .wsh-grid tr.wsh-carry td{height:16px;font-size:12px;color:var(--warn)}
  #cb-root .wsh-grid tr.wsh-sum td{color:var(--elec)}
  #cb-root .wsh-grid tr.wsh-sum td.wsh-lab{color:var(--elec)}
  #cb-root .wsh-grid td.wa{color:var(--warm)!important} #cb-root .wsh-grid td.wz{color:var(--muted)!important}
  #cb-root .wsh-grid hr{border:none;border-top:1.5px solid #3a4160;margin:1px 0}
</style>

<script>
(function(){
"use strict";
const root = document.getElementById('cb-root');
if(!root || root._cbInit) return;
root._cbInit = true;
const $ = sel => root.querySelector(sel);
/* ============================================================================
   BITS AS CANNONBALLS  —  reversible logic on slit-paths
     1) Bit      : one shot, up slit = 1 / down slit = 0; rides that lane.
     2) NOT       : a crossover swaps the lanes — same ball, opposite value.
   Reuses the double-slit look (glowing source, barrier with two slits).
   ========================================================================== */

const cv = $('#cv');
const ctx = cv.getContext('2d');
const panel = $('#panel');

let W=0,H=0,DPR=1,G={};
const lerp=(a,b,u)=>a+(b-a)*u;
const smooth=u=>u*u*(3-2*u);

function computeGeom(){
  G.sx   = W*0.10;
  G.cy   = H*0.50;
  G.bx   = W*0.40;
  G.bw   = Math.max(7, W*0.010);
  G.rx   = W*0.87;
  G.gap  = H*0.34;
  G.sH   = Math.max(10, H*0.05);
  G.sTop = G.cy - G.gap/2;
  G.sBot = G.cy + G.gap/2;
  G.gateX= W*0.635;
  G.cw   = Math.max(52, W*0.085);
  // two-channel geometry (CNOT and beyond): control on top, target below
  G.cyC  = H*0.31; G.cyT = H*0.69; G.gap2 = H*0.15;
  G.sH2  = Math.max(8, H*0.034);
  G.cTop = G.cyC - G.gap2/2; G.cBot = G.cyC + G.gap2/2;
  G.tTop = G.cyT - G.gap2/2; G.tBot = G.cyT + G.gap2/2;
  // three-channel geometry (Toffoli): control1, control2, target
  G.t3a=H*0.20; G.t3b=H*0.48; G.t3c=H*0.76; G.gap3=H*0.12; G.sH3=Math.max(7,H*0.026);
  G.a1T=G.t3a-G.gap3/2; G.a1B=G.t3a+G.gap3/2;
  G.a2T=G.t3b-G.gap3/2; G.a2B=G.t3b+G.gap3/2;
  G.a3T=G.t3c-G.gap3/2; G.a3B=G.t3c+G.gap3/2;
  // 2-bit adder: 6 bit channels, 6 gate columns
  const aTop=H*0.10, aBot=H*0.80; G.adCy=[];
  for(let i=0;i<6;i++) G.adCy.push(aTop+i*(aBot-aTop)/5);
  G.adLG=Math.max(20,H*0.052); G.adSH=Math.max(5,H*0.016);
  G.adGW=Math.max(13,(G.rx-G.bx)*0.028);
  G.adGX=[0.12,0.27,0.42,0.57,0.72,0.87].map(f=>G.bx+(G.rx-G.bx)*f);
}
function resize(){
  const r=panel.getBoundingClientRect();
  DPR=Math.min(window.devicePixelRatio||1,2);
  W=r.width;H=r.height;
  cv.width=Math.round(W*DPR);cv.height=Math.round(H*DPR);
  ctx.setTransform(DPR,0,0,DPR,0,0);
  computeGeom();
}
new ResizeObserver(resize).observe(panel);

const C={warm:'#ffb24a',cool:'#6ad7ff',elec:'#7CFFB2',muted:'#8b93b8',ink:'#eef2ff'};
const ySlit=v=>v?G.sTop:G.sBot;
const colOf=v=>v?C.warm:C.cool;

/* ----------------------------- shared drawing ----------------------------- */
function clearBG(){
  const g=ctx.createLinearGradient(0,0,W,0);
  g.addColorStop(0,'#070a18');g.addColorStop(1,'#04050b');
  ctx.fillStyle=g;ctx.fillRect(0,0,W,H);
}
function rrect(x,y,w,h,r){
  ctx.beginPath();ctx.moveTo(x+r,y);
  ctx.arcTo(x+w,y,x+w,y+h,r);ctx.arcTo(x+w,y+h,x,y+h,r);
  ctx.arcTo(x,y+h,x,y,r);ctx.arcTo(x,y,x+w,y,r);ctx.closePath();
}
function drawLanes(hasGate){
  ctx.save();ctx.setLineDash([5,8]);ctx.lineWidth=1.5;
  const x0=G.gateX-G.cw, x1=G.gateX+G.cw;
  [[G.sTop,C.warm],[G.sBot,C.cool]].forEach(p=>{
    ctx.strokeStyle=p[1]+'40';
    if(hasGate){
      ctx.beginPath();ctx.moveTo(G.bx+G.bw/2,p[0]);ctx.lineTo(x0,p[0]);ctx.stroke();
      ctx.beginPath();ctx.moveTo(x1,p[0]);ctx.lineTo(G.rx,p[0]);ctx.stroke();
    }else{
      ctx.beginPath();ctx.moveTo(G.bx+G.bw/2,p[0]);ctx.lineTo(G.rx,p[0]);ctx.stroke();
    }
  });
  ctx.restore();
}
function drawBarrier(){
  const x=G.bx;
  ctx.fillStyle='rgba(180,190,225,0.92)';
  ctx.fillRect(x-G.bw/2,0,G.bw,G.sTop-G.sH);
  ctx.fillRect(x-G.bw/2,G.sTop+G.sH,G.bw,(G.sBot-G.sH)-(G.sTop+G.sH));
  ctx.fillRect(x-G.bw/2,G.sBot+G.sH,G.bw,H-(G.sBot+G.sH));
  ctx.save();ctx.shadowBlur=12;
  [[G.sTop,C.warm],[G.sBot,C.cool]].forEach(p=>{
    ctx.shadowColor=p[1];ctx.strokeStyle=p[1];ctx.globalAlpha=.55;ctx.lineWidth=G.bw;
    ctx.beginPath();ctx.moveTo(x,p[0]-G.sH);ctx.lineTo(x,p[0]+G.sH);ctx.stroke();
  });
  ctx.restore();
  ctx.font='700 13px Cabin,Inter,system-ui';ctx.textAlign='center';
  ctx.fillStyle=C.warm;ctx.fillText('1',x-24,G.sTop+5);
  ctx.fillStyle=C.cool;ctx.fillText('0',x-24,G.sBot+5);
}
function drawCannon(){
  ctx.save();ctx.shadowColor=C.warm;ctx.shadowBlur=18;
  ctx.beginPath();ctx.arc(G.sx,G.cy,Math.max(7,H*0.014),0,7);ctx.fillStyle=C.warm;ctx.fill();
  ctx.restore();
  ctx.font='11px Cabin,Inter,system-ui';ctx.fillStyle=C.muted;ctx.textAlign='center';
  ctx.fillText('cannon',G.sx,G.cy+H*0.05);
}
function drawReadout(landed){
  [[G.sTop,C.warm,'1',1],[G.sBot,C.cool,'0',0]].forEach(z=>{
    const on=landed===z[3];
    const r=Math.max(13,H*0.028);
    ctx.beginPath();ctx.arc(G.rx,z[0],r,0,7);
    ctx.fillStyle=on?z[1]:'#0d1226';
    if(on){ctx.save();ctx.shadowColor=z[1];ctx.shadowBlur=20;ctx.fill();ctx.restore();}else ctx.fill();
    ctx.lineWidth=2;ctx.strokeStyle=z[1]+(on?'':'66');ctx.stroke();
    ctx.font='800 15px Cabin,Inter,system-ui';ctx.textAlign='center';
    ctx.fillStyle=on?'#10131f':z[1];ctx.fillText(z[2],G.rx,z[0]+5);
  });
  ctx.font='11px Cabin,Inter,system-ui';ctx.fillStyle=C.muted;ctx.textAlign='center';
  ctx.fillText('readout',G.rx,G.sBot+H*0.05);
}
function drawNOTgate(){
  const x0=G.gateX-G.cw, x1=G.gateX+G.cw;
  const pad=Math.max(30,H*0.085);
  const yT=G.sTop-pad, yB=G.sBot+pad, r=14;
  const L=Math.max(34,W*0.05), m=Math.max(16,H*0.045);
  const tT=G.sTop-m, tB=G.sBot+m, mcy=(tT+tB)/2, mry=(tB-tT)/2;
  const mxL=x0-L, mxR=x1+L;
  // tube fills + box fill (slight tint, so it can become a black box later)
  ctx.save();ctx.fillStyle='rgba(12,16,30,0.30)';
  ctx.fillRect(mxL,tT,x0-mxL,tB-tT);
  ctx.fillRect(x1,tT,mxR-x1,tB-tT);
  rrect(x0,yT,x1-x0,yB-yT,r);ctx.fill();
  ctx.restore();
  ctx.save();
  ctx.strokeStyle=C.elec;ctx.lineWidth=2.5;ctx.shadowColor=C.elec;ctx.shadowBlur=8;ctx.lineJoin='round';ctx.lineCap='round';
  // box border — open at both throats (tT..tB) where the tubes join
  ctx.beginPath();
  ctx.moveTo(x0,tT);
  ctx.lineTo(x0,yT+r);ctx.arcTo(x0,yT,x0+r,yT,r);
  ctx.lineTo(x1-r,yT);ctx.arcTo(x1,yT,x1,yT+r,r);
  ctx.lineTo(x1,tT);
  ctx.stroke();
  ctx.beginPath();
  ctx.moveTo(x0,tB);
  ctx.lineTo(x0,yB-r);ctx.arcTo(x0,yB,x0+r,yB,r);
  ctx.lineTo(x1-r,yB);ctx.arcTo(x1,yB,x1,yB-r,r);
  ctx.lineTo(x1,tB);
  ctx.stroke();
  // tube walls + open rims
  ctx.beginPath();
  ctx.moveTo(x0,tT);ctx.lineTo(mxL,tT);ctx.moveTo(x0,tB);ctx.lineTo(mxL,tB);
  ctx.moveTo(x1,tT);ctx.lineTo(mxR,tT);ctx.moveTo(x1,tB);ctx.lineTo(mxR,tB);
  ctx.stroke();
  ctx.beginPath();ctx.ellipse(mxL,mcy,7,mry,0,0,7);ctx.stroke();
  ctx.beginPath();ctx.ellipse(mxR,mcy,7,mry,0,0,7);ctx.stroke();
  ctx.restore();
  // the crossover inside the box
  ctx.save();
  ctx.strokeStyle=C.elec;ctx.lineWidth=3;ctx.lineCap='round';
  ctx.beginPath();ctx.moveTo(x0,G.sTop);ctx.lineTo(x1,G.sBot);ctx.stroke();
  ctx.beginPath();ctx.moveTo(x0,G.sBot);ctx.lineTo(x1,G.sTop);ctx.stroke();
  ctx.restore();
}

/* ----- parametric helpers for multi-channel scenes (CNOT, ...) ----- */
function mkbtn(text,cls,onclick){
  const b=document.createElement('button');
  b.className='stepbtn'+(cls?' '+cls:'');b.textContent=text;b.onclick=onclick;return b;
}
function crossYabs(x,yIn,yOut){
  const a=G.gateX-G.cw, b=G.gateX+G.cw;
  if(x<=a) return yIn; if(x>=b) return yOut;
  return lerp(yIn,yOut,(x-a)/(b-a));
}
/* one qubit = one shape: circle, square or triangle (cannon + end state) */
function shapeAt(cx,cy,rad,shape){
  ctx.beginPath();
  if(shape==='square'){ const s=rad*1.75; ctx.rect(cx-s/2,cy-s/2,s,s); }
  else if(shape==='triangle'){ const s=rad*2.15, h=s*0.866;
    ctx.moveTo(cx,cy-2*h/3); ctx.lineTo(cx+s/2,cy+h/3); ctx.lineTo(cx-s/2,cy+h/3); ctx.closePath(); }
  else { ctx.arc(cx,cy,rad,0,7); }
}
function drawCannonAt(y,shape,col){
  col=col||C.warm;
  ctx.save();ctx.shadowColor=col;ctx.shadowBlur=16;
  shapeAt(G.sx,y,Math.max(6,H*0.014),shape);ctx.fillStyle=col;ctx.fill();
  ctx.restore();
}
function drawBarrierMulti(slits,sH){
  const x=G.bx;
  ctx.fillStyle='rgba(180,190,225,0.92)';
  let prev=0;
  slits.forEach(s=>{ ctx.fillRect(x-G.bw/2,prev,G.bw,(s.y-sH)-prev); prev=s.y+sH; });
  ctx.fillRect(x-G.bw/2,prev,G.bw,H-prev);
  ctx.save();ctx.shadowBlur=10;
  slits.forEach(s=>{ ctx.shadowColor=s.color;ctx.strokeStyle=s.color;ctx.globalAlpha=.55;ctx.lineWidth=G.bw;
    ctx.beginPath();ctx.moveTo(x,s.y-sH);ctx.lineTo(x,s.y+sH);ctx.stroke(); });
  ctx.restore();
  ctx.font='700 12px Cabin,Inter,system-ui';ctx.textAlign='center';
  slits.forEach(s=>{ if(s.lab){ctx.fillStyle=s.color;ctx.fillText(s.lab,x-22,s.y+4);} });
}
function drawLanesMulti(){
  ctx.save();ctx.setLineDash([5,8]);ctx.lineWidth=1.5;
  const x0=G.gateX-G.cw, x1=G.gateX+G.cw, sx=G.bx+G.bw/2;
  [[G.cTop,C.warm],[G.cBot,C.cool]].forEach(p=>{ctx.strokeStyle=p[1]+'40';
    ctx.beginPath();ctx.moveTo(sx,p[0]);ctx.lineTo(G.rx,p[0]);ctx.stroke();});
  [[G.tTop,C.warm],[G.tBot,C.cool]].forEach(p=>{ctx.strokeStyle=p[1]+'40';
    ctx.beginPath();ctx.moveTo(sx,p[0]);ctx.lineTo(x0,p[0]);ctx.stroke();
    ctx.beginPath();ctx.moveTo(x1,p[0]);ctx.lineTo(G.rx,p[0]);ctx.stroke();});
  ctx.restore();
}
function drawReadoutPair(yA,yB,landed,shape){
  const rr=Math.max(11,(yB-yA)*0.22);
  [[yA,C.warm,'1',1],[yB,C.cool,'0',0]].forEach(z=>{
    const on=landed===z[3];
    shapeAt(G.rx,z[0],rr,shape);ctx.fillStyle=on?z[1]:'#0d1226';
    if(on){ctx.save();ctx.shadowColor=z[1];ctx.shadowBlur=18;ctx.fill();ctx.restore();}else ctx.fill();
    ctx.lineWidth=2;ctx.strokeStyle=z[1]+(on?'':'66');ctx.stroke();
    ctx.font='800 13px Cabin,Inter,system-ui';ctx.textAlign='center';ctx.fillStyle=on?'#10131f':z[1];
    ctx.fillText(z[2],G.rx,z[0]+5);
  });
}
/* generic gate box on an arbitrary lane pair; crosses only when active */
function drawGateBox(yA,yB,active,label){
  const x0=G.gateX-G.cw, x1=G.gateX+G.cw, laneGap=yB-yA;
  const pad=Math.max(26,laneGap*0.34), m=Math.max(14,laneGap*0.20), r=14;
  const yT=yA-pad, yBo=yB+pad, L=Math.max(34,W*0.05);
  const tT=yA-m, tB=yB+m, mcy=(tT+tB)/2, mry=(tB-tT)/2, mxL=x0-L, mxR=x1+L;
  ctx.save();ctx.fillStyle='rgba(12,16,30,0.30)';
  ctx.fillRect(mxL,tT,x0-mxL,tB-tT);ctx.fillRect(x1,tT,mxR-x1,tB-tT);
  rrect(x0,yT,x1-x0,yBo-yT,r);ctx.fill();ctx.restore();
  ctx.save();
  ctx.strokeStyle=C.elec;ctx.lineWidth=2.5;ctx.shadowColor=C.elec;ctx.shadowBlur=8;ctx.lineJoin='round';ctx.lineCap='round';
  ctx.beginPath();ctx.moveTo(x0,tT);ctx.lineTo(x0,yT+r);ctx.arcTo(x0,yT,x0+r,yT,r);
  ctx.lineTo(x1-r,yT);ctx.arcTo(x1,yT,x1,yT+r,r);ctx.lineTo(x1,tT);ctx.stroke();
  ctx.beginPath();ctx.moveTo(x0,tB);ctx.lineTo(x0,yBo-r);ctx.arcTo(x0,yBo,x0+r,yBo,r);
  ctx.lineTo(x1-r,yBo);ctx.arcTo(x1,yBo,x1,yBo-r,r);ctx.lineTo(x1,tB);ctx.stroke();
  ctx.beginPath();
  ctx.moveTo(x0,tT);ctx.lineTo(mxL,tT);ctx.moveTo(x0,tB);ctx.lineTo(mxL,tB);
  ctx.moveTo(x1,tT);ctx.lineTo(mxR,tT);ctx.moveTo(x1,tB);ctx.lineTo(mxR,tB);ctx.stroke();
  ctx.beginPath();ctx.ellipse(mxL,mcy,7,mry,0,0,7);ctx.stroke();
  ctx.beginPath();ctx.ellipse(mxR,mcy,7,mry,0,0,7);ctx.stroke();
  ctx.restore();
  if(active){
    ctx.save();ctx.strokeStyle=C.elec;ctx.lineWidth=3;ctx.lineCap='round';
    ctx.beginPath();ctx.moveTo(x0,yA);ctx.lineTo(x1,yB);ctx.stroke();
    ctx.beginPath();ctx.moveTo(x0,yB);ctx.lineTo(x1,yA);ctx.stroke();ctx.restore();
  }else{
    ctx.save();ctx.setLineDash([5,8]);ctx.lineWidth=1.6;
    ctx.strokeStyle=C.warm+'66';ctx.beginPath();ctx.moveTo(x0,yA);ctx.lineTo(x1,yA);ctx.stroke();
    ctx.strokeStyle=C.cool+'66';ctx.beginPath();ctx.moveTo(x0,yB);ctx.lineTo(x1,yB);ctx.stroke();ctx.restore();
  }
}
/* control dot on the control 1-lane + linkage down to the target box */
function drawControlLink(active){
  const x=G.gateX, yDot=G.cTop;
  const boxTop=G.tTop-Math.max(26,(G.tBot-G.tTop)*0.34);
  ctx.save();
  ctx.strokeStyle=active?C.elec:'#7CFFB244';ctx.lineWidth=2.5;ctx.lineCap='round';
  if(active){ctx.shadowColor=C.elec;ctx.shadowBlur=8;}
  ctx.beginPath();ctx.moveTo(x,yDot);ctx.lineTo(x,boxTop);ctx.stroke();
  ctx.beginPath();ctx.arc(x,yDot,7,0,7);
  ctx.fillStyle=active?C.elec:'#0c101e';ctx.fill();
  ctx.strokeStyle=active?C.elec:'#7CFFB288';ctx.stroke();
  ctx.restore();
}
/* dashed lanes for an arbitrary list of channels (gated ones split at the box) */
function drawChannelLanes(channels){
  ctx.save();ctx.setLineDash([5,8]);ctx.lineWidth=1.5;
  const x0=G.gateX-G.cw, x1=G.gateX+G.cw, sx=G.bx+G.bw/2;
  channels.forEach(ch=>{
    [[ch.yT,C.warm],[ch.yB,C.cool]].forEach(p=>{ctx.strokeStyle=p[1]+'40';
      if(ch.gated){ctx.beginPath();ctx.moveTo(sx,p[0]);ctx.lineTo(x0,p[0]);ctx.stroke();
        ctx.beginPath();ctx.moveTo(x1,p[0]);ctx.lineTo(G.rx,p[0]);ctx.stroke();}
      else{ctx.beginPath();ctx.moveTo(sx,p[0]);ctx.lineTo(G.rx,p[0]);ctx.stroke();}});
  });
  ctx.restore();
}
/* one vertical linkage tapping several control dots; bright only when active */
function drawControlLinks(dotYs,ons,active,boxTop){
  const x=G.gateX, top=Math.min.apply(null,dotYs);
  ctx.save();
  ctx.strokeStyle=active?C.elec:'#7CFFB244';ctx.lineWidth=2.5;ctx.lineCap='round';
  if(active){ctx.shadowColor=C.elec;ctx.shadowBlur=8;}
  ctx.beginPath();ctx.moveTo(x,top);ctx.lineTo(x,boxTop);ctx.stroke();
  ctx.restore();
  dotYs.forEach((y,i)=>{const on=ons[i];ctx.save();
    ctx.beginPath();ctx.arc(x,y,7,0,7);
    if(on){ctx.shadowColor=C.elec;ctx.shadowBlur=8;}
    ctx.fillStyle=on?C.elec:'#0c101e';ctx.fill();
    ctx.lineWidth=2.5;ctx.strokeStyle=on?C.elec:'#7CFFB288';ctx.stroke();ctx.restore();});
}

/* path the ball follows along the lanes, with optional crossover at the gate */
function laneY(x,vin,vout,hasGate){
  if(!hasGate || vin===vout) return ySlit(vin);
  const a=G.gateX-G.cw, b=G.gateX+G.cw;
  if(x<=a) return ySlit(vin);
  if(x>=b) return ySlit(vout);
  return lerp(ySlit(vin),ySlit(vout),(x-a)/(b-a));
}

/* =========================================================================
   GENERIC SCENE (parametrised by hasNOT)
   ========================================================================= */
function makeScene(cfg){
  return {
    tag:cfg.tag, tagColor:cfg.tagColor, subtitle:cfg.subtitle,
    capTitle:cfg.capTitle, capSub:cfg.capSub, hasNOT:cfg.hasNOT,
    ball:null, landed:null, vin:null,
    fire(v){
      this.landed=null; this.vin=v;
      this.ball={vin:v, vout:this.hasNOT?(1-v):v, x:G.sx, y:G.cy, phase:'toSlit'};
      $('#readout').innerHTML='Firing&hellip;';
    },
    reset(){ this.ball=null; this.landed=null; this.vin=null;
      $('#readout').innerHTML=cfg.idle; },
    step(dt){
      const b=this.ball; if(!b) return;
      const vx=W*0.42*dt;
      if(b.phase==='toSlit'){
        const tx=G.bx, ty=ySlit(b.vin);
        const dx=tx-G.sx, dy=ty-G.cy, L=Math.hypot(dx,dy)||1;
        b.x+=dx/L*vx; b.y+=dy/L*vx;
        if(b.x>=G.bx){ b.x=G.bx; b.y=ty; b.phase='lane'; }
      } else {
        b.x+=vx; b.y=laneY(b.x,b.vin,b.vout,this.hasNOT);
        if(b.x>=G.rx){
          this.landed=b.vout; this.ball=null;
          $('#readout').innerHTML=cfg.result(b.vin,b.vout);
        }
      }
    },
    draw(){
      clearBG();
      drawLanes(this.hasNOT);
      drawReadout(this.landed);
      if(this.hasNOT) drawNOTgate();
      drawBarrier();
      drawCannon();
      const b=this.ball;
      if(b){
        ctx.save();ctx.shadowColor=colOf(b.x<G.gateX?b.vin:b.vout);ctx.shadowBlur=14;
        ctx.beginPath();ctx.arc(b.x,b.y,Math.max(5,H*0.012),0,7);
        ctx.fillStyle=colOf(b.x<G.gateX?b.vin:b.vout);ctx.fill();ctx.restore();
      }
    },
    buildControls(el){
      el.innerHTML='';const self=this;
      el.append(
        mkbtn('Fire ▲ (1)','up',()=>self.fire(1)),
        mkbtn('Fire ▼ (0)','dn',()=>self.fire(0)),
        mkbtn('↻','',()=>self.reset())
      );
    },
    onEnter(){ this.buildControls($('#sctrl')); this.reset(); },
    onLeave(){ this.ball=null; },
  };
}

const S1=makeScene({
  tag:'1 · Bit', tagColor:'var(--warm)',
  subtitle:'Fire one ball at a wall with two slits. Which slit it goes through IS the bit.',
  capTitle:'A bit is <b class="warm">which slit</b> the ball took.',
  capSub:'Aim <b class="warm">up</b> and the ball goes through the top slit &mdash; we call that <b class="warm">1</b>. Aim <b class="cool">down</b>, bottom slit, <b class="cool">0</b>. After the slit it rides that lane to the readout.',
  hasNOT:false,
  idle:'Press <b class="w">Fire &#9650;</b> or <b class="c">Fire &#9660;</b> to send a bit.',
  result:(vin,vout)=>'The ball took the '+(vout?'<b class="w">up</b> slit &rarr; bit = <b class="w">1</b>':'<b class="c">down</b> slit &rarr; bit = <b class="c">0</b>'),
});

const S2=makeScene({
  tag:'2 · NOT gate', tagColor:'var(--elec)',
  subtitle:'A gate is a switch on the lanes. The simplest one just crosses them over.',
  capTitle:'<b class="elec">NOT</b> swaps the lanes &mdash; same ball, flipped bit.',
  capSub:'The crossover sends an <b class="warm">up</b> ball out on the <b class="cool">down</b> lane and vice-versa. Nothing is created or destroyed: one ball in, one ball out. That &ldquo;count stays the same&rdquo; rule is what makes it <b class="elec">reversible</b>.',
  hasNOT:true,
  idle:'Fire a bit and watch the <b class="e">NOT</b> gate flip it.',
  result:(vin,vout)=>'In <b class="'+(vin?'w':'c')+'">'+vin+'</b> &rarr; <b class="e">NOT</b> &rarr; out <b class="'+(vout?'w':'c')+'">'+vout+'</b>',
});

/* =========================================================================
   SCENE 3 — CNOT: a control bit decides whether NOT fires on the target
   ========================================================================= */
const S3={
  tag:'3 · CNOT gate', tagColor:'var(--elec)',
  subtitle:'Two bits now. A control bit decides whether the NOT fires on the target.',
  capTitle:'<b class="elec">CNOT</b>: flip the target only if the control is <b class="warm">1</b>.',
  capSub:'The top bit is the <b class="elec">control</b>. If its ball rides the <b class="warm">up&nbsp;(1)</b> lane it trips the switch and the <b class="cool">target</b> box crosses; if the control is <b class="cool">0</b> the target sails straight through. The control itself is never changed — two balls in, two balls out.',
  cin:1, tin:0, cball:null, tball:null, cLanded:null, tLanded:null, _sync:null,
  setReadout(t){ $('#readout').innerHTML=t; },
  buildControls(el){
    el.innerHTML='';const self=this;
    const cB=mkbtn('','',()=>{self.cin^=1;self._sync();self.reset();});
    const tB=mkbtn('','',()=>{self.tin^=1;self._sync();self.reset();});
    el.append(cB,tB,mkbtn('Run ⚡','',()=>self.run()),mkbtn('↻','',()=>self.reset()));
    this._sync=function(){
      cB.textContent='control '+(self.cin?'▲ 1':'▼ 0');cB.className='stepbtn '+(self.cin?'up':'dn');
      tB.textContent='target '+(self.tin?'▲ 1':'▼ 0');tB.className='stepbtn '+(self.tin?'up':'dn');
    };this._sync();
  },
  reset(){ this.cball=this.tball=null;this.cLanded=this.tLanded=null;
    this.setReadout('Set the <b class="e">control</b> and <b class="w">target</b>, then press <b>Run</b>.'); },
  run(){
    this.cLanded=this.tLanded=null;
    const active=this.cin===1, tout=active?(1-this.tin):this.tin;
    this.cball={x:G.sx,y:G.cyC,sy:(this.cin?G.cTop:G.cBot),vin:this.cin,phase:'toSlit'};
    this.tball={x:G.sx,y:G.cyT,syIn:(this.tin?G.tTop:G.tBot),syOut:(tout?G.tTop:G.tBot),vin:this.tin,vout:tout,phase:'toSlit'};
    this.setReadout('Running&hellip;');
  },
  _result(){
    if(this.cball||this.tball)return;
    if(this.cLanded==null&&this.tLanded==null)return;
    const cin=this.cLanded,tout=this.tLanded;
    this.setReadout('control <b class="'+(cin?'w':'c')+'">'+cin+'</b> (unchanged) &nbsp;·&nbsp; target <b class="'+(this.tin?'w':'c')+'">'+this.tin+'</b> &rarr; <b class="e">CNOT</b> &rarr; <b class="'+(tout?'w':'c')+'">'+tout+'</b>');
  },
  step(dt){
    const vx=W*0.42*dt;
    let b=this.cball;
    if(b){
      if(b.phase==='toSlit'){const dx=G.bx-G.sx,dy=b.sy-G.cyC,L=Math.hypot(dx,dy)||1;b.x+=dx/L*vx;b.y+=dy/L*vx;if(b.x>=G.bx){b.x=G.bx;b.y=b.sy;b.phase='lane';}}
      else{b.x+=vx;b.y=b.sy;if(b.x>=G.rx){this.cLanded=b.vin;this.cball=null;this._result();}}
    }
    b=this.tball;
    if(b){
      if(b.phase==='toSlit'){const dx=G.bx-G.sx,dy=b.syIn-G.cyT,L=Math.hypot(dx,dy)||1;b.x+=dx/L*vx;b.y+=dy/L*vx;if(b.x>=G.bx){b.x=G.bx;b.y=b.syIn;b.phase='lane';}}
      else{b.x+=vx;b.y=crossYabs(b.x,b.syIn,b.syOut);if(b.x>=G.rx){this.tLanded=b.vout;this.tball=null;this._result();}}
    }
  },
  draw(){
    clearBG();
    drawLanesMulti();
    drawReadoutPair(G.cTop,G.cBot,this.cLanded,'square');
    drawReadoutPair(G.tTop,G.tBot,this.tLanded,'circle');
    drawGateBox(G.tTop,G.tBot,this.cin===1,'NOT');
    drawControlLink(this.cin===1);
    drawBarrierMulti([{y:G.cTop,color:C.warm,lab:'1'},{y:G.cBot,color:C.cool,lab:'0'},
                      {y:G.tTop,color:C.warm,lab:'1'},{y:G.tBot,color:C.cool,lab:'0'}],G.sH2);
    drawCannonAt(G.cyC,'square',colOf(this.cin));drawCannonAt(G.cyT,'circle',colOf(this.tin));
    ctx.font='11px Cabin,Inter,system-ui';ctx.fillStyle=C.muted;ctx.textAlign='center';
    ctx.fillText('control',G.sx,G.cTop-12);
    ctx.fillText('target',G.sx,G.tBot+18);
    const drawB=(b,vbefore,vafter)=>{const v=b.x<G.gateX?vbefore:vafter,col=colOf(v);
      ctx.save();ctx.shadowColor=col;ctx.shadowBlur=14;ctx.beginPath();
      ctx.arc(b.x,b.y,Math.max(5,H*0.011),0,7);ctx.fillStyle=col;ctx.fill();ctx.restore();};
    if(this.cball)drawB(this.cball,this.cin,this.cin);
    if(this.tball)drawB(this.tball,this.tin,this.tball.vout);
  },
  onEnter(){ this.buildControls($('#sctrl')); this.reset(); },
  onLeave(){ this.cball=this.tball=null; },
};

/* =========================================================================
   SCENE 4 — TOFFOLI (CCNOT): target flips only if BOTH controls are 1
   ========================================================================= */
const S4={
  tag:'4 · Toffoli gate', tagColor:'var(--elec)',
  subtitle:'Three bits. The target flips only when BOTH controls are 1.',
  capTitle:'<b class="elec">Toffoli</b>: flip the target only if <b class="warm">both</b> controls are 1.',
  capSub:'The <b class="cool">target</b> box crosses only when the <b>square</b> and <b>triangle</b> are both on their <b class="warm">up&nbsp;(1)</b> lane &mdash; one switch wired as an <b class="elec">AND</b>. Still reversible: three balls in, three balls out.',
  c1:1, c2:1, tin:0, b1:null, b2:null, b3:null, l1:null, l2:null, l3:null, _sync:null,
  setReadout(t){ $('#readout').innerHTML=t; },
  active(){ return this.c1===1 && this.c2===1; },
  buildControls(el){
    el.innerHTML='';const self=this;
    const cA=mkbtn('','',()=>{self.c1^=1;self._sync();self.reset();});
    const cB=mkbtn('','',()=>{self.c2^=1;self._sync();self.reset();});
    const tB=mkbtn('','',()=>{self.tin^=1;self._sync();self.reset();});
    el.append(cA,cB,tB,mkbtn('Run ⚡','',()=>self.run()),mkbtn('↻','',()=>self.reset()));
    this._sync=function(){
      cA.textContent='▲ '+(self.c1?'1':'0');cA.className='stepbtn '+(self.c1?'up':'dn');
      cB.textContent='■ '+(self.c2?'1':'0');cB.className='stepbtn '+(self.c2?'up':'dn');
      tB.textContent='● '+(self.tin?'1':'0');tB.className='stepbtn '+(self.tin?'up':'dn');
    };this._sync();
  },
  reset(){ this.b1=this.b2=this.b3=null;this.l1=this.l2=this.l3=null;
    this.setReadout('Set the two <b class="e">controls</b> (■ ▲) and the <b class="w">target</b> (●), then press <b>Run</b>.'); },
  run(){
    this.l1=this.l2=this.l3=null;const act=this.active(),tout=act?(1-this.tin):this.tin;
    this.b1={x:G.sx,y:G.t3a,sy:(this.c1?G.a1T:G.a1B),vin:this.c1,cy:G.t3a,phase:'toSlit'};
    this.b2={x:G.sx,y:G.t3b,sy:(this.c2?G.a2T:G.a2B),vin:this.c2,cy:G.t3b,phase:'toSlit'};
    this.b3={x:G.sx,y:G.t3c,syIn:(this.tin?G.a3T:G.a3B),syOut:(tout?G.a3T:G.a3B),vin:this.tin,vout:tout,cy:G.t3c,phase:'toSlit'};
    this.setReadout('Running&hellip;');
  },
  _result(){
    if(this.b1||this.b2||this.b3)return;
    if(this.l1==null&&this.l2==null&&this.l3==null)return;
    const tout=this.l3;
    this.setReadout('controls <b class="'+(this.l1?'w':'c')+'">'+this.l1+'</b> <b class="'+(this.l2?'w':'c')+'">'+this.l2+'</b> (unchanged) &nbsp;·&nbsp; target <b class="'+(this.tin?'w':'c')+'">'+this.tin+'</b> &rarr; <b class="e">Toffoli</b> &rarr; <b class="'+(tout?'w':'c')+'">'+tout+'</b>');
  },
  step(dt){
    const vx=W*0.42*dt;
    const moveStraight=(b,set)=>{
      if(b.phase==='toSlit'){const dx=G.bx-G.sx,dy=b.sy-b.cy,L=Math.hypot(dx,dy)||1;b.x+=dx/L*vx;b.y+=dy/L*vx;if(b.x>=G.bx){b.x=G.bx;b.y=b.sy;b.phase='lane';}return false;}
      b.x+=vx;b.y=b.sy;if(b.x>=G.rx){set(b.vin);return true;}return false;
    };
    if(this.b1&&moveStraight(this.b1,v=>this.l1=v)){this.b1=null;this._result();}
    if(this.b2&&moveStraight(this.b2,v=>this.l2=v)){this.b2=null;this._result();}
    const b=this.b3;
    if(b){
      if(b.phase==='toSlit'){const dx=G.bx-G.sx,dy=b.syIn-b.cy,L=Math.hypot(dx,dy)||1;b.x+=dx/L*vx;b.y+=dy/L*vx;if(b.x>=G.bx){b.x=G.bx;b.y=b.syIn;b.phase='lane';}}
      else{b.x+=vx;b.y=crossYabs(b.x,b.syIn,b.syOut);if(b.x>=G.rx){this.l3=b.vout;this.b3=null;this._result();}}
    }
  },
  draw(){
    clearBG();
    drawChannelLanes([{yT:G.a1T,yB:G.a1B,gated:false},{yT:G.a2T,yB:G.a2B,gated:false},{yT:G.a3T,yB:G.a3B,gated:true}]);
    drawReadoutPair(G.a1T,G.a1B,this.l1,'triangle');
    drawReadoutPair(G.a2T,G.a2B,this.l2,'square');
    drawReadoutPair(G.a3T,G.a3B,this.l3,'circle');
    drawGateBox(G.a3T,G.a3B,this.active(),'NOT');
    const boxTop=G.a3T-Math.max(26,(G.a3B-G.a3T)*0.34);
    drawControlLinks([G.a1T,G.a2T],[this.c1===1,this.c2===1],this.active(),boxTop);
    drawBarrierMulti([{y:G.a1T,color:C.warm,lab:'1'},{y:G.a1B,color:C.cool,lab:'0'},
                      {y:G.a2T,color:C.warm,lab:'1'},{y:G.a2B,color:C.cool,lab:'0'},
                      {y:G.a3T,color:C.warm,lab:'1'},{y:G.a3B,color:C.cool,lab:'0'}],G.sH3);
    drawCannonAt(G.t3a,'triangle',colOf(this.c1));drawCannonAt(G.t3b,'square',colOf(this.c2));drawCannonAt(G.t3c,'circle',colOf(this.tin));
    ctx.font='11px Cabin,Inter,system-ui';ctx.fillStyle=C.muted;ctx.textAlign='center';
    ctx.fillText('control',G.sx,G.a1T-12);ctx.fillText('control',G.sx,G.a2T-12);
    ctx.fillText('target',G.sx,G.a3B+18);
    const drawB=(b,vb,va)=>{const v=b.x<G.gateX?vb:va,col=colOf(v);
      ctx.save();ctx.shadowColor=col;ctx.shadowBlur=14;ctx.beginPath();
      ctx.arc(b.x,b.y,Math.max(5,H*0.011),0,7);ctx.fillStyle=col;ctx.fill();ctx.restore();};
    if(this.b1)drawB(this.b1,this.c1,this.c1);
    if(this.b2)drawB(this.b2,this.c2,this.c2);
    if(this.b3)drawB(this.b3,this.tin,this.b3.vout);
  },
  onEnter(){ this.buildControls($('#sctrl')); this.reset(); },
  onLeave(){ this.b1=this.b2=this.b3=null; },
};

/* =========================================================================
   SCENE 5 — THE 2-BIT ADDER: six bits, a switchyard of 3 Toffoli + 3 CNOT
   wires: 0:a0 1:b0 2:c1(=0) 3:a1 4:b1 5:c2(=0)   outputs s0=b0 s1=b1 s2=c2
   ========================================================================= */
const S5={
  tag:'5 · 2-bit adder', tagColor:'var(--elec)',
  subtitle:'Chain the gates into a machine that adds two 2-bit numbers.',
  capTitle:'The whole <b class="elec">adder</b>: gates chained into a switchyard.',
  capSub:'Six bits flow left&rarr;right &mdash; the numbers <b class="warm">A</b> and <b class="cool">B</b> plus two blank <b>carry</b> bits. Three Toffolis and three CNOTs route the balls so the output lanes spell <b class="e">A + B</b>. Count them: six balls in, six out &mdash; still reversible.',
  A:2, B:1, stage:0, prog:0, running:false, landed:null, sim:null, _sync:null,
  labels:['a0','b0','c1','a1','b1','c2'],
  gates:[{c:[0,1],tg:2},{c:[0],tg:1},{c:[3,4],tg:5},{c:[3],tg:4},{c:[2,4],tg:5},{c:[2],tg:4}],
  STAGE:[
    {t:'The workspace: six bits, no gates yet.',
     s:'<b class="warm">a0, a1</b> are the bits of number <b class="warm">A</b>; <b class="cool">b0, b1</b> are number <b class="cool">B</b>; <b>c1, c2</b> are blank <b>carry</b> bits (start at 0). Fire &mdash; each ball flies straight to its readout. Nothing is added yet.'},
    {t:'Ones column &mdash; write the carry.',
     s:'The first <b class="elec">Toffoli</b> sets c1 = a0 AND b0: the carry out of the ones column.'},
    {t:'Ones column &mdash; write the sum (half adder done).',
     s:'A <b class="elec">CNOT</b> turns b0 into a0 XOR b0 = <b class="elec">s0</b>. Try <b class="warm">1</b>+<b class="warm">1</b>: sum 0, carry 1.'},
    {t:'Twos column &mdash; write its carry.',
     s:'A second <b class="elec">Toffoli</b> sets c2 = a1 AND b1.'},
    {t:'Twos column &mdash; partial sum.',
     s:'A <b class="elec">CNOT</b> folds a1 into b1 (a1 XOR b1) &mdash; not finished until the carry arrives.'},
    {t:'Carry the 1 &mdash; into the twos column.',
     s:'A <b class="elec">Toffoli</b> adds the ones-column carry c1 into c2 (when b1 is set).'},
    {t:'Final sum bit &mdash; the adder is complete.',
     s:'The last <b class="elec">CNOT</b> folds c1 into b1 = <b class="elec">s1</b>. Output lanes now spell <b class="elec">A + B</b>. Six balls in, six out.'}
  ],
  setStage(s){
    this.stage=s;
    this.prog=0;this.running=false;this.landed=null;this.simulate();
    this.setReadout(s===0?'Set <b class="w">A</b> and <b class="c">B</b>, then <b>Run</b> the six straight shots.':'Press <b>Run</b> to fire through the '+s+' gate'+(s>1?'s':'')+' built so far.');
    if(this._sync)this._sync();
  },
  setReadout(t){ $('#readout').innerHTML=t; },
  bitLane(i,v){ return v?(G.adCy[i]-G.adLG/2):(G.adCy[i]+G.adLG/2); },
  simulate(){
    const A=this.A,B=this.B,a0=A&1,a1=(A>>1)&1,b0=B&1,b1=(B>>1)&1;
    const inVals=[a0,b0,0,a1,b1,0], vals=inVals.slice();
    const events=[[],[],[],[],[],[]],gact=[],gctrl=[],ng=this.stage;
    this.gates.forEach((g,gi)=>{
      if(gi>=ng){gact.push(false);gctrl.push(g.c.map(()=>0));return;}
      const cvals=g.c.map(ci=>vals[ci]);gctrl.push(cvals);
      const active=cvals.every(v=>v===1);gact.push(active);
      if(active){const t=g.tg;events[t].push({x:G.adGX[gi],to:1-vals[t]});vals[t]^=1;}
    });
    this.sim={inVals,outVals:vals,events,gact,gctrl};
  },
  laneY(i,x){
    const w=2*G.adGW;let v=this.sim.inVals[i];
    for(const e of this.sim.events[i]){
      if(x>=e.x+w/2){v=e.to;continue;}
      if(x>e.x-w/2){const t=(x-(e.x-w/2))/w;return lerp(this.bitLane(i,v),this.bitLane(i,e.to),t);}
      return this.bitLane(i,v);
    }
    return this.bitLane(i,v);
  },
  valAt(i,x){let v=this.sim.inVals[i];for(const e of this.sim.events[i]){if(x>=e.x)v=e.to;else break;}return v;},
  buildControls(el){
    el.innerHTML='';const self=this;
    const aB=mkbtn('','up',()=>{self.A=(self.A+1)%4;self._sync();self.reset();});
    const bB=mkbtn('','dn',()=>{self.B=(self.B+1)%4;self._sync();self.reset();});
    const buildB=mkbtn('','',()=>{self.setStage((self.stage+1)%7);});
    el.append(aB,bB,buildB,mkbtn('Run ⚡','',()=>self.run()),mkbtn('↻','',()=>self.reset()));
    this._sync=()=>{aB.textContent='A = '+self.A;bB.textContent='B = '+self.B;buildB.textContent='Build ▶ '+self.stage+'/6';};this._sync();
  },
  reset(){ this.prog=0;this.running=false;this.landed=null;this.simulate();
    this.setReadout(this.stage===0?'Set <b class="w">A</b> and <b class="c">B</b>, then <b>Run</b> the six straight shots.':'Press <b>Run</b> to fire through the '+this.stage+' gate'+(this.stage>1?'s':'')+' built so far.'); },
  run(){ this.simulate();this.prog=0;this.running=true;this.landed=null;this.setReadout('Running&hellip;'); },
  step(dt){
    if(!this.running)return;
    this.prog+=dt*0.38;
    if(this.prog>=1){this.prog=1;this.running=false;this.landed=this.sim.outVals;
      const o=this.sim.outVals,s0=o[1],s1=o[4],s2=o[5];
      if(this.stage===0) this.setReadout('A = <b class="w">'+this.A+'</b>, B = <b class="c">'+this.B+'</b> &mdash; six straight shots, nothing added yet.');
      else if(this.stage===6) this.setReadout('<b class="w">'+this.A+'</b> + <b class="c">'+this.B+'</b> = <b class="e">'+(this.A+this.B)+'</b> &nbsp; (s&#8322;s&#8321;s&#8320; = '+s2+s1+s0+')');
      else this.setReadout('Built <b>'+this.stage+'/6</b> gates &mdash; partial result on the output lanes.');}
  },
  drawGate(g,gi){
    const x=G.adGX[gi],tg=g.tg,cy=G.adCy[tg],lg=G.adLG;
    const top=cy-lg/2,bot=cy+lg/2,gw=G.adGW,pad=Math.max(5,lg*0.32);
    const x0=x-gw,x1=x+gw,yT=top-pad,yB=bot+pad,active=this.sim.gact[gi];
    const ctrlYs=g.c.map(ci=>this.bitLane(ci,1)),cyMin=Math.min.apply(null,ctrlYs.concat([yT]));
    ctx.save();ctx.strokeStyle=active?C.elec:'#7CFFB244';ctx.lineWidth=2;if(active){ctx.shadowColor=C.elec;ctx.shadowBlur=6;}
    ctx.beginPath();ctx.moveTo(x,cyMin);ctx.lineTo(x,yT);ctx.stroke();ctx.restore();
    g.c.forEach((ci,k)=>{const cyD=this.bitLane(ci,1),on=this.sim.gctrl[gi][k]===1;
      ctx.save();ctx.beginPath();ctx.arc(x,cyD,5,0,7);if(on){ctx.shadowColor=C.elec;ctx.shadowBlur=6;}
      ctx.fillStyle=on?C.elec:'#0c101e';ctx.fill();ctx.lineWidth=2;ctx.strokeStyle=on?C.elec:'#7CFFB288';ctx.stroke();ctx.restore();});
    const r=6,L=Math.max(12,gw*0.95),m=Math.max(6,lg*0.18);
    const tT=top-m,tB=bot+m,mcy=(tT+tB)/2,mry=(tB-tT)/2,mxL=x0-L,mxR=x1+L;
    const sc=active?C.elec:'#7CFFB255';
    ctx.save();ctx.fillStyle='rgba(8,11,20,0.9)';
    ctx.fillRect(mxL,tT,x0-mxL,tB-tT);ctx.fillRect(x1,tT,mxR-x1,tB-tT);
    rrect(x0,yT,x1-x0,yB-yT,r);ctx.fill();ctx.restore();
    ctx.save();ctx.strokeStyle=sc;ctx.lineWidth=1.6;ctx.lineJoin='round';ctx.lineCap='round';
    if(active){ctx.shadowColor=C.elec;ctx.shadowBlur=5;}
    ctx.beginPath();ctx.moveTo(x0,tT);ctx.lineTo(x0,yT+r);ctx.arcTo(x0,yT,x0+r,yT,r);
    ctx.lineTo(x1-r,yT);ctx.arcTo(x1,yT,x1,yT+r,r);ctx.lineTo(x1,tT);ctx.stroke();
    ctx.beginPath();ctx.moveTo(x0,tB);ctx.lineTo(x0,yB-r);ctx.arcTo(x0,yB,x0+r,yB,r);
    ctx.lineTo(x1-r,yB);ctx.arcTo(x1,yB,x1,yB-r,r);ctx.lineTo(x1,tB);ctx.stroke();
    ctx.beginPath();
    ctx.moveTo(x0,tT);ctx.lineTo(mxL,tT);ctx.moveTo(x0,tB);ctx.lineTo(mxL,tB);
    ctx.moveTo(x1,tT);ctx.lineTo(mxR,tT);ctx.moveTo(x1,tB);ctx.lineTo(mxR,tB);ctx.stroke();
    ctx.beginPath();ctx.ellipse(mxL,mcy,5,mry,0,0,7);ctx.stroke();
    ctx.beginPath();ctx.ellipse(mxR,mcy,5,mry,0,0,7);ctx.stroke();
    ctx.restore();
    ctx.save();ctx.lineCap='round';
    if(active){ctx.strokeStyle=C.elec;ctx.lineWidth=2.5;
      ctx.beginPath();ctx.moveTo(x0,top);ctx.lineTo(x1,bot);ctx.stroke();
      ctx.beginPath();ctx.moveTo(x0,bot);ctx.lineTo(x1,top);ctx.stroke();}
    else{ctx.lineWidth=2;ctx.strokeStyle=C.warm+'aa';ctx.beginPath();ctx.moveTo(x0,top);ctx.lineTo(x1,top);ctx.stroke();
      ctx.strokeStyle=C.cool+'aa';ctx.beginPath();ctx.moveTo(x0,bot);ctx.lineTo(x1,bot);ctx.stroke();}
    ctx.restore();
  },
  draw(){
    clearBG();
    const sx0=G.bx+G.bw/2, rr=Math.max(8,G.adLG*0.30);
    ctx.save();ctx.setLineDash([4,7]);ctx.lineWidth=1.3;
    for(let i=0;i<6;i++){
      ctx.strokeStyle=C.warm+'30';ctx.beginPath();ctx.moveTo(sx0,this.bitLane(i,1));ctx.lineTo(G.rx,this.bitLane(i,1));ctx.stroke();
      ctx.strokeStyle=C.cool+'30';ctx.beginPath();ctx.moveTo(sx0,this.bitLane(i,0));ctx.lineTo(G.rx,this.bitLane(i,0));ctx.stroke();
    }ctx.restore();
    for(let i=0;i<6;i++){
      [[1,C.warm],[0,C.cool]].forEach(p=>{const y=this.bitLane(i,p[0]),on=this.landed&&this.landed[i]===p[0];
        ctx.beginPath();ctx.arc(G.rx,y,rr,0,7);ctx.fillStyle=on?p[1]:'#0d1226';
        if(on){ctx.save();ctx.shadowColor=p[1];ctx.shadowBlur=14;ctx.fill();ctx.restore();}else ctx.fill();
        ctx.lineWidth=1.6;ctx.strokeStyle=p[1]+(on?'':'55');ctx.stroke();});
    }
    if(this.stage===6){ctx.font='800 12px Cabin,Inter,system-ui';ctx.fillStyle=C.elec;ctx.textAlign='left';
      [[1,'s0'],[4,'s1'],[5,'s2']].forEach(p=>ctx.fillText(p[1],G.rx+rr+7,G.adCy[p[0]]+4));}
    this.gates.forEach((g,gi)=>{if(gi<this.stage)this.drawGate(g,gi);});
    const slits=[];for(let i=0;i<6;i++){slits.push({y:this.bitLane(i,1),color:C.warm});slits.push({y:this.bitLane(i,0),color:C.cool});}
    drawBarrierMulti(slits,G.adSH);
    for(let i=0;i<6;i++) drawCannonAt(G.adCy[i],'circle',colOf(this.sim.inVals[i]));
    ctx.font='10px Cabin,Inter,system-ui';ctx.fillStyle=C.muted;ctx.textAlign='center';
    for(let i=0;i<6;i++) ctx.fillText(this.labels[i],G.sx,G.adCy[i]-G.adLG/2-7);
    if(this.running||(this.prog>0&&this.prog<1)){
      for(let i=0;i<6;i++){
        let x,y,v;
        if(this.prog<0.18){const u=this.prog/0.18;x=lerp(G.sx,G.bx,u);y=lerp(G.adCy[i],this.bitLane(i,this.sim.inVals[i]),u);v=this.sim.inVals[i];}
        else{const u=(this.prog-0.18)/0.82;x=lerp(G.bx,G.rx,u);y=this.laneY(i,x);v=this.valAt(i,x);}
        const col=colOf(v);
        ctx.save();ctx.shadowColor=col;ctx.shadowBlur=12;ctx.beginPath();ctx.arc(x,y,Math.max(4,H*0.0095),0,7);ctx.fillStyle=col;ctx.fill();ctx.restore();
      }
    }
    this.updateSheet();
  },
  updateSheet(){
    const A=this.A,B=this.B,st=this.stage;
    const a0=A&1,a1=(A>>1)&1,b0=B&1,b1=(B>>1)&1;
    const s0=a0^b0,c1=a0&b0,tt=a1+b1+c1,s1=tt&1,c2=tt>>1,s2=c2;
    // reveal each digit as the ball-front passes the gate that computes it;
    // idle (just built / after a run) -> front at the readout, so all built digits show.
    const front=this.running?((this.prog<0.18)?G.bx:lerp(G.bx,G.rx,(this.prog-0.18)/0.82)):G.rx;
    const shown=gi=>(gi<st)&&(front>=G.adGX[gi]);
    const $=id=>root.querySelector('#'+id);
    const badge=$('wshBadge'); if(!badge) return; badge.textContent=st+'/6';
    const setd=(id,val,cls)=>{const e=$(id);if(e){e.textContent=val;e.className=cls||'';}};
    setd('wsA2',a1,'wa'); setd('wsA1',a0,'wa');
    setd('wsB2',b1,b1?'wa':'wz'); setd('wsB1',b0,b0?'wa':'wz');
    setd('wsC2',shown(0)?c1:''); setd('wsC4',shown(4)?c2:'');
    setd('wsS1',shown(1)?s0:'·',shown(1)?'':'wz');
    setd('wsS2',shown(5)?s1:'·',shown(5)?'':'wz');
    setd('wsS4',shown(5)?s2:'·',shown(5)?'':'wz');
  },
  onEnter(){ $('#panel').classList.add('wsmode');$('#wsheet').classList.add('show');this.buildControls($('#sctrl'));this.setStage(0); },
  onLeave(){ $('#panel').classList.remove('wsmode');$('#wsheet').classList.remove('show');this.running=false;this.prog=0; },
};

/* ----------------------------- scene manager ------------------------------ */
const scenes=[S1,S2,S3,S4,S5];
const labels=['Bit','NOT','CNOT','Toffoli','Adder'];
let cur=0;

const els={
  subtitle:$('#subtitle'),
  tag:$('#tag'),
  prev:$('#prev'),
  next:$('#next'),
};
const dotsWrap=$('#dots');
const dotEls=labels.map((l,i)=>{
  const d=document.createElement('div');d.className='dot';
  d.innerHTML='<span class="pip"></span><span class="dl">'+l+'</span>';
  d.onclick=()=>go(i);dotsWrap.appendChild(d);return d;
});
function applySceneUI(s){
  els.subtitle.innerHTML=s.subtitle;
  els.tag.textContent=s.tag;els.tag.style.color=s.tagColor;els.tag.style.borderColor=s.tagColor+'55';
  dotEls.forEach((d,i)=>d.classList.toggle('active',i===cur));
  els.prev.disabled=cur===0;els.next.disabled=cur===scenes.length-1;
}
function go(i){
  i=Math.max(0,Math.min(scenes.length-1,i));
  if(i===cur){return;}
  scenes[cur].onLeave&&scenes[cur].onLeave();
  cur=i;
  scenes[cur].onEnter&&scenes[cur].onEnter();
  applySceneUI(scenes[cur]);
}
els.prev.onclick=()=>go(cur-1);
els.next.onclick=()=>go(cur+1);

/* ------------------------------- main loop -------------------------------- */
let last=performance.now();
function frame(now){
  const dt=Math.min(0.05,(now-last)/1000);last=now;
  scenes[cur].step(dt);
  scenes[cur].draw();
  requestAnimationFrame(frame);
}
resize();
scenes[0].onEnter();
applySceneUI(scenes[0]);
requestAnimationFrame(frame);
})();
</script>
"""

    HTML(_scene)
end

# ╔═╡ 07c68981-18b4-46ce-9e38-4940f734d348
# @live from cannon-bits-quantum.jl
blank_slide() do
    # Canvas-only scene, self-contained; scoped for the deck like cannon-bits.jl:
    #   - all CSS prefixed under #cbq-root
    #   - JS wrapped in an IIFE that queries within `root` (not `document`)
    #   - the global arrow-key handler is removed (arrows drive deck navigation)
    #   - the explanatory caption box and the canvas cloud legends are removed
    #   - font switched to Cabin
    _scene = raw"""
<div id="cbq-root">
  <header>
    <h1><span class="a">Qubits</span> as Cannonballs</h1>
    <p id="subtitle"></p>
  </header>

  <div class="stage">
    <div class="panel" id="panel">
      <canvas id="cv"></canvas>
      <div class="tag" id="tag"></div>
      <div class="sctrl" id="sctrl"></div>
      <div class="readout" id="readout"></div>
    </div>
  </div>

  <div class="controls">
    <div class="dots" id="dots"></div>
    <div class="navrow">
      <button class="nav" id="prev" title="Previous (&#8592;)">&#9664;</button>
      <button class="nav" id="next" title="Next (&#8594;)">&#9654;</button>
    </div>
    <div class="hint">Use <b>&#9664; &#9654;</b> or the dots to move between panels &middot; fire the cannon to send a qubit.</div>
  </div>

  <div class="wsheet" id="wsheet">
    <div class="wsh-head"><b>binary addition</b><span class="wsh-badge" id="wshBadge">0/6</span></div>
    <table class="wsh-grid">
      <tr class="wsh-carry"><td class="wsh-lab">carry</td><td id="wsC4"></td><td id="wsC2"></td><td></td></tr>
      <tr><td class="wsh-lab">A</td><td></td><td id="wsA2"></td><td id="wsA1"></td></tr>
      <tr><td class="wsh-lab">+B</td><td></td><td id="wsB2"></td><td id="wsB1"></td></tr>
      <tr class="wsh-rule"><td></td><td colspan="3"><hr></td></tr>
      <tr class="wsh-sum"><td class="wsh-lab">Sum</td><td id="wsS4"></td><td id="wsS2"></td><td id="wsS1"></td></tr>
    </table>
  </div></div>

<style>
  #cbq-root{
    --bg:#05060d;
    --ink:#eef2ff;
    --muted:#8b93b8;
    --warm:#ffb24a;     /* the "1" / up slit */
    --cool:#6ad7ff;     /* the "0" / down slit */
    --elec:#7CFFB2;     /* gates / operations */
    --warn:#ff5470;     /* carry (later) */
    --mist:#b9a8ff;     /* superposition / cloud */
    --line:#1c2238;
  }
  #cbq-root *{box-sizing:border-box;margin:0;padding:0}
  
  #cbq-root{
    background:radial-gradient(1200px 800px at 50% -10%, #11162b 0%, var(--bg) 60%);
    color:var(--ink);
    font-family:'Cabin','Inter',system-ui,-apple-system,"Segoe UI",Roboto,Helvetica,Arial,sans-serif;
    position:relative;overflow:hidden;display:flex;flex-direction:column;
    /* Fill the slide box exactly in slide mode (parent has a definite height,
       so height:100% wins and aspect-ratio is ignored). In the notebook editor
       the parent height is auto, height:100% collapses, and aspect-ratio then
       derives a landscape height from the cell width. */
    width:100%;height:100%;max-height:100%;aspect-ratio:4 / 3;border-radius:10px;
  }
  #cbq-root header{text-align:center;padding:14px 16px 6px;flex:0 0 auto}
  #cbq-root header h1{font-size:clamp(19px,2.5vw,32px);font-weight:700;letter-spacing:.4px}
  #cbq-root header h1 .a{color:var(--cool)}
  #cbq-root header p{color:var(--muted);font-size:clamp(12px,1.2vw,15.5px);margin-top:5px;min-height:1.2em;transition:opacity .3s}

  #cbq-root .stage{flex:1 1 auto;display:flex;padding:0 18px;min-height:0}
  #cbq-root .panel{position:relative;flex:1 1 100%;border:1px solid var(--line);border-radius:16px;
    overflow:hidden;background:#000;box-shadow:0 0 40px rgba(0,0,0,.6) inset;}
  #cbq-root canvas{position:absolute;inset:0;width:100%;height:100%;display:block}

  #cbq-root .tag{position:absolute;top:14px;left:14px;z-index:5;font-size:12px;letter-spacing:2px;
    font-weight:700;text-transform:uppercase;padding:6px 11px;border-radius:8px;
    background:#0008;backdrop-filter:blur(4px);border:1px solid var(--line);transition:color .3s,border-color .3s}

  #cbq-root .sctrl{position:absolute;top:14px;right:14px;z-index:6;display:flex;gap:8px;align-items:center;flex-wrap:wrap;justify-content:flex-end}
  #cbq-root .stepbtn{font-size:13px;color:var(--ink);background:#121734;border:1px solid var(--line);
    border-radius:9px;padding:7px 14px;cursor:pointer;transition:background .15s;font-weight:600}
  #cbq-root .stepbtn:hover{background:#1b2350}
  #cbq-root .stepbtn.up{border-color:#ffb24a55;color:#ffd089}
  #cbq-root .stepbtn.dn{border-color:#6ad7ff55;color:#bdecff}
  #cbq-root .stepbtn.mist{border-color:#b9a8ff66;color:#d7ccff}

  #cbq-root .readout{position:absolute;left:16px;bottom:16px;z-index:5;font-size:clamp(13px,1.6vw,18px);
    color:#c9d1f5;font-variant-numeric:tabular-nums;min-height:1.4em;transition:opacity .3s}
  #cbq-root .readout b.w{color:var(--warm)} #cbq-root .readout b.c{color:var(--cool)} #cbq-root .readout b.e{color:var(--elec)} #cbq-root .readout b.m{color:var(--mist)}
  #cbq-root .panel.wsmode .readout{display:none}

  #cbq-root .controls{flex:0 0 auto;padding:12px 24px 18px;display:flex;flex-direction:column;align-items:center;gap:9px}
  #cbq-root .dots{display:flex;gap:18px;align-items:center}
  #cbq-root .dot{display:flex;flex-direction:column;align-items:center;gap:6px;cursor:pointer;opacity:.55;transition:opacity .2s}
  #cbq-root .dot.active{opacity:1}
  #cbq-root .dot .pip{width:11px;height:11px;border-radius:50%;background:#39406a;transition:background .2s,box-shadow .2s}
  #cbq-root .dot.active .pip{background:var(--cool);box-shadow:0 0 12px var(--cool)}
  #cbq-root .dot .dl{font-size:11.5px;color:var(--muted);letter-spacing:.3px}
  #cbq-root .dot.active .dl{color:var(--ink);font-weight:700}
  #cbq-root .navrow{display:flex;align-items:center;gap:16px}
  #cbq-root button.nav{background:#121734;color:var(--ink);border:1px solid var(--line);border-radius:10px;
    width:46px;height:40px;font-size:18px;cursor:pointer;transition:background .15s,transform .1s}
  #cbq-root button.nav:hover{background:#1b2350} #cbq-root button.nav:active{transform:scale(.94)}
  #cbq-root button.nav:disabled{opacity:.3;cursor:default}
  #cbq-root .hint{color:var(--muted);font-size:12px;text-align:center}
  #cbq-root .hint b{color:var(--ink)}

  /* base-2 worksheet (adder panel only) — HTML element, can overlap the controls */
  #cbq-root .wsheet{position:absolute;left:22px;bottom:12px;z-index:30;display:none;
    background:rgba(11,16,32,0.94);border:1px solid var(--line);border-radius:11px;
    padding:8px 12px 9px;font-family:'Cabin','Inter',system-ui,sans-serif}
  #cbq-root .wsheet.show{display:block}
  #cbq-root .wsh-head{display:flex;justify-content:space-between;align-items:center;gap:22px;margin-bottom:4px}
  #cbq-root .wsh-head b{font-size:12px;font-weight:700;color:var(--ink)}
  #cbq-root .wsh-badge{font-size:11px;font-weight:700;color:var(--elec)}
  #cbq-root .wsh-grid{border-collapse:collapse;font-variant-numeric:tabular-nums}
  #cbq-root .wsh-grid td{width:24px;height:22px;text-align:center;font-size:15px;font-weight:800;color:var(--ink)}
  #cbq-root .wsh-grid td.wsh-lab{width:auto;text-align:right;padding-right:8px;font-size:11px;font-weight:600;color:var(--muted)}
  #cbq-root .wsh-grid tr.wsh-carry td{height:16px;font-size:12px;color:var(--warn)}
  #cbq-root .wsh-grid tr.wsh-sum td{color:var(--elec)}
  #cbq-root .wsh-grid tr.wsh-sum td.wsh-lab{color:var(--elec)}
  #cbq-root .wsh-grid td.wa{color:var(--warm)!important} #cbq-root .wsh-grid td.wz{color:var(--muted)!important}
  #cbq-root .wsh-grid hr{border:none;border-top:1.5px solid #3a4160;margin:1px 0}
</style>

<script>
(function(){
"use strict";
const root = document.getElementById('cbq-root');
if(!root || root._cbqInit) return;
root._cbqInit = true;
const $ = sel => root.querySelector(sel);
/* ============================================================================
   QUBITS AS CANNONBALLS  —  quantum version of the slit-path deck
     1) Qubit    : one shot, up slit = 1 / down slit = 0 — OR BOTH at once
                   (superposition), drawn as a "mist" cloud holding |1> and |0>.
                   Measuring it collapses the cloud to a single answer.
     2+) NOT / CNOT / Toffoli / adder  (still classical for now; converted next).
   Mist/cloud notation after Economou & Barnes, "Hello Quantum World!".
   ========================================================================== */

const cv = $('#cv');
const ctx = cv.getContext('2d');
const panel = $('#panel');

let W=0,H=0,DPR=1,G={};
const lerp=(a,b,u)=>a+(b-a)*u;
const smooth=u=>u*u*(3-2*u);

function computeGeom(){
  G.sx   = W*0.10;
  G.cy   = H*0.50;
  G.bx   = W*0.40;
  G.bw   = Math.max(7, W*0.010);
  G.rx   = W*0.87;
  G.gap  = H*0.34;
  G.sH   = Math.max(10, H*0.05);
  G.sTop = G.cy - G.gap/2;
  G.sBot = G.cy + G.gap/2;
  G.gateX= W*0.635;
  G.cw   = Math.max(52, W*0.085);
  // two-channel geometry (CNOT and beyond): control on top, target below
  G.cyC  = H*0.31; G.cyT = H*0.69; G.gap2 = H*0.15;
  G.sH2  = Math.max(8, H*0.034);
  G.cTop = G.cyC - G.gap2/2; G.cBot = G.cyC + G.gap2/2;
  G.tTop = G.cyT - G.gap2/2; G.tBot = G.cyT + G.gap2/2;
  // three-channel geometry (Toffoli): control1, control2, target
  G.t3a=H*0.20; G.t3b=H*0.48; G.t3c=H*0.76; G.gap3=H*0.12; G.sH3=Math.max(7,H*0.026);
  G.a1T=G.t3a-G.gap3/2; G.a1B=G.t3a+G.gap3/2;
  G.a2T=G.t3b-G.gap3/2; G.a2B=G.t3b+G.gap3/2;
  G.a3T=G.t3c-G.gap3/2; G.a3B=G.t3c+G.gap3/2;
  // 2-bit adder: 6 bit channels, 6 gate columns
  const aTop=H*0.10, aBot=H*0.80; G.adCy=[];
  for(let i=0;i<6;i++) G.adCy.push(aTop+i*(aBot-aTop)/5);
  G.adLG=Math.max(20,H*0.052); G.adSH=Math.max(5,H*0.016);
  G.adGW=Math.max(13,(G.rx-G.bx)*0.028);
  G.adGX=[0.12,0.27,0.42,0.57,0.72,0.87].map(f=>G.bx+(G.rx-G.bx)*f);
}
function resize(){
  const r=panel.getBoundingClientRect();
  DPR=Math.min(window.devicePixelRatio||1,2);
  W=r.width;H=r.height;
  cv.width=Math.round(W*DPR);cv.height=Math.round(H*DPR);
  ctx.setTransform(DPR,0,0,DPR,0,0);
  computeGeom();
}
new ResizeObserver(resize).observe(panel);

const C={warm:'#ffb24a',cool:'#6ad7ff',elec:'#7CFFB2',muted:'#8b93b8',ink:'#eef2ff',mist:'#b9a8ff'};
const ySlit=v=>v?G.sTop:G.sBot;
const colOf=v=>v?C.warm:C.cool;

/* ----------------------------- shared drawing ----------------------------- */
function clearBG(){
  const g=ctx.createLinearGradient(0,0,W,0);
  g.addColorStop(0,'#070a18');g.addColorStop(1,'#04050b');
  ctx.fillStyle=g;ctx.fillRect(0,0,W,H);
}
function rrect(x,y,w,h,r){
  ctx.beginPath();ctx.moveTo(x+r,y);
  ctx.arcTo(x+w,y,x+w,y+h,r);ctx.arcTo(x+w,y+h,x,y+h,r);
  ctx.arcTo(x,y+h,x,y,r);ctx.arcTo(x,y,x+w,y,r);ctx.closePath();
}
function drawLanes(hasGate){
  ctx.save();ctx.setLineDash([5,8]);ctx.lineWidth=1.5;
  const x0=G.gateX-G.cw, x1=G.gateX+G.cw;
  [[G.sTop,C.warm],[G.sBot,C.cool]].forEach(p=>{
    ctx.strokeStyle=p[1]+'40';
    if(hasGate){
      ctx.beginPath();ctx.moveTo(G.bx+G.bw/2,p[0]);ctx.lineTo(x0,p[0]);ctx.stroke();
      ctx.beginPath();ctx.moveTo(x1,p[0]);ctx.lineTo(G.rx,p[0]);ctx.stroke();
    }else{
      ctx.beginPath();ctx.moveTo(G.bx+G.bw/2,p[0]);ctx.lineTo(G.rx,p[0]);ctx.stroke();
    }
  });
  ctx.restore();
}
function drawBarrier(){
  const x=G.bx;
  ctx.fillStyle='rgba(180,190,225,0.92)';
  ctx.fillRect(x-G.bw/2,0,G.bw,G.sTop-G.sH);
  ctx.fillRect(x-G.bw/2,G.sTop+G.sH,G.bw,(G.sBot-G.sH)-(G.sTop+G.sH));
  ctx.fillRect(x-G.bw/2,G.sBot+G.sH,G.bw,H-(G.sBot+G.sH));
  ctx.save();ctx.shadowBlur=12;
  [[G.sTop,C.warm],[G.sBot,C.cool]].forEach(p=>{
    ctx.shadowColor=p[1];ctx.strokeStyle=p[1];ctx.globalAlpha=.55;ctx.lineWidth=G.bw;
    ctx.beginPath();ctx.moveTo(x,p[0]-G.sH);ctx.lineTo(x,p[0]+G.sH);ctx.stroke();
  });
  ctx.restore();
  ctx.font='700 13px Cabin,Inter,system-ui';ctx.textAlign='center';
  ctx.fillStyle=C.warm;ctx.fillText('1',x-24,G.sTop+5);
  ctx.fillStyle=C.cool;ctx.fillText('0',x-24,G.sBot+5);
}
function drawCannon(){
  ctx.save();ctx.shadowColor=C.warm;ctx.shadowBlur=18;
  ctx.beginPath();ctx.arc(G.sx,G.cy,Math.max(7,H*0.014),0,7);ctx.fillStyle=C.warm;ctx.fill();
  ctx.restore();
  ctx.font='11px Cabin,Inter,system-ui';ctx.fillStyle=C.muted;ctx.textAlign='center';
  ctx.fillText('cannon',G.sx,G.cy+H*0.05);
}
function drawReadout(landed){
  [[G.sTop,C.warm,'1',1],[G.sBot,C.cool,'0',0]].forEach(z=>{
    const on=landed===z[3];
    const r=Math.max(13,H*0.028);
    ctx.beginPath();ctx.arc(G.rx,z[0],r,0,7);
    ctx.fillStyle=on?z[1]:'#0d1226';
    if(on){ctx.save();ctx.shadowColor=z[1];ctx.shadowBlur=20;ctx.fill();ctx.restore();}else ctx.fill();
    ctx.lineWidth=2;ctx.strokeStyle=z[1]+(on?'':'66');ctx.stroke();
    ctx.font='800 15px Cabin,Inter,system-ui';ctx.textAlign='center';
    ctx.fillStyle=on?'#10131f':z[1];ctx.fillText(z[2],G.rx,z[0]+5);
  });
  ctx.font='11px Cabin,Inter,system-ui';ctx.fillStyle=C.muted;ctx.textAlign='center';
  ctx.fillText('readout',G.rx,G.sBot+H*0.05);
}

/* fuzzy probability blob (double-slit slide style): radial-gradient ellipse */
function blob(px,py,rx,ry,color){
  ctx.save();
  ctx.translate(px,py);ctx.scale(rx,ry);
  const g=ctx.createRadialGradient(0,0,0,0,0,1);
  g.addColorStop(0,color);g.addColorStop(0.55,color+'cc');g.addColorStop(1,color+'00');
  ctx.fillStyle=g;ctx.beginPath();ctx.arc(0,0,1,0,7);ctx.fill();
  ctx.restore();
}
/* scalloped cumulus silhouette: a solid elliptical body + bumpy rim puffs.
   Filling the union of these subpaths gives the classic fluffy-cloud outline. */
function cloudPath(cx,cy,rx,ry){
  const big=Math.max(rx,ry);
  const n=Math.max(12,Math.round((rx+ry)/13));
  ctx.beginPath();
  ctx.ellipse(cx,cy,rx*0.80,ry*0.80,0,0,Math.PI*2);          // solid body
  for(let i=0;i<n;i++){
    const a=(i/n)*Math.PI*2;
    const br=(0.22+0.06*Math.sin(a*3+0.6))*big;              // irregular bumps
    const bx=cx+Math.cos(a)*rx*0.80, by=cy+Math.sin(a)*ry*0.80;
    ctx.moveTo(bx+br,by);ctx.arc(bx,by,br,0,Math.PI*2);       // rim puff
  }
}
/* mist cell positions: the two basis configs sit compactly inside the cloud */
function mistCellY(v){ const sep=Math.max(13,H*0.028)*1.55; return G.cy + (v? -sep : sep); }
/* faint guide paths: source -> each slit -> each cloud cell (both at once) */
function drawSuperPaths(alpha){
  ctx.save();ctx.globalAlpha=alpha;ctx.lineWidth=1.3;ctx.setLineDash([3,5]);
  [[G.sTop,C.warm,1],[G.sBot,C.cool,0]].forEach(p=>{
    ctx.strokeStyle=p[1];ctx.beginPath();
    ctx.moveTo(G.sx,G.cy);ctx.lineTo(G.bx,p[0]);ctx.lineTo(G.rx,mistCellY(p[2]));ctx.stroke();
  });
  ctx.restore();
}
/* guide paths through a NOT gate: each branch rides its lane, crosses at the
   gate, and lands in the OPPOSITE cloud cell (1->0, 0->1). */
function drawSuperPathsNOT(alpha){
  ctx.save();ctx.globalAlpha=alpha;ctx.lineWidth=1.3;ctx.setLineDash([3,5]);
  const a=G.gateX-G.cw, b=G.gateX+G.cw;
  [[G.sTop,G.sBot,1],[G.sBot,G.sTop,0]].forEach(p=>{
    ctx.strokeStyle=colOf(p[2]);ctx.beginPath();
    ctx.moveTo(G.sx,G.cy);ctx.lineTo(a,p[0]);ctx.lineTo(b,p[1]);
    ctx.lineTo(G.rx,mistCellY(1-p[2]));ctx.stroke();
  });
  ctx.restore();
}

/* -------- QUANTUM: the "mist" cloud readout (Economou & Barnes notation) -----
   A superposition is one cloud holding both basis configurations |1> and |0>,
   stacked on the up/down slit lanes and split by a bar. `intensity` fades the
   cloud out as it collapses; `measured` (0/1/null) is the surviving outcome;
   `collapse` (0..1) drives the collapse animation. */
function drawMistCloud(intensity, measured, collapse){
  const xr=G.rx, r=Math.max(13,H*0.028), cyMid=G.cy, sep=r*1.55;
  const y1=mistCellY(1), y0=mistCellY(0);     // 1 (warm) up, 0 (cool) down — compact
  const crx=r+58, cry=sep+r+26;
  intensity=Math.max(0,Math.min(1,intensity));
  // soft fluffy cloud body (filled scalloped silhouette + glow, no hard border)
  if(intensity>0.002){
    ctx.save();
    ctx.globalAlpha=intensity;
    const R=Math.max(crx,cry);
    const grd=ctx.createRadialGradient(xr,cyMid,r*0.4,xr,cyMid,R*1.05);
    grd.addColorStop(0,'rgba(198,184,255,0.32)');
    grd.addColorStop(0.6,'rgba(180,164,255,0.16)');
    grd.addColorStop(1,'rgba(180,164,255,0)');
    ctx.shadowColor='rgba(185,168,255,0.55)';ctx.shadowBlur=22;
    cloudPath(xr,cyMid,crx,cry);ctx.fillStyle=grd;ctx.fill();
    // a second pass with no shadow for a denser core
    ctx.shadowBlur=0;cloudPath(xr,cyMid,crx*0.96,cry*0.96);ctx.fillStyle=grd;ctx.fill();
    ctx.restore();
    // bar between the two basis configurations (Hello Quantum World notation)
    ctx.save();ctx.globalAlpha=intensity*0.85;
    ctx.strokeStyle='rgba(205,194,255,0.75)';ctx.lineWidth=1.6;
    const bw=crx*0.6;
    ctx.beginPath();ctx.moveTo(xr-bw,cyMid);ctx.lineTo(xr+bw,cyMid);ctx.stroke();
    ctx.restore();
  }
  // the two basis cells; both glow while in mist, one survives on collapse
  [[y1,C.warm,'1',1],[y0,C.cool,'0',0]].forEach(z=>{
    const chosen = measured===z[3];
    let a = intensity*0.92;          // cell brightness inside the mist
    let rr = r;
    if(collapse>0){
      a  = chosen ? 1 : intensity*0.92;
      rr = chosen ? r*(1+0.16*collapse) : r*(1-0.3*collapse);
    }
    a=Math.max(0,a);
    ctx.save();
    ctx.globalAlpha=a;
    ctx.beginPath();ctx.arc(xr,z[0],rr,0,7);
    ctx.fillStyle=z[1];
    if(chosen||intensity>0.4){ctx.shadowColor=z[1];ctx.shadowBlur=chosen?20:14;}
    ctx.fill();
    ctx.lineWidth=2;ctx.strokeStyle=z[1];ctx.stroke();
    ctx.font='800 15px Cabin,Inter,system-ui';ctx.textAlign='center';ctx.fillStyle='#10131f';
    ctx.fillText(z[2],xr,z[0]+5);
    ctx.restore();
  });
}

function drawNOTgate(){
  const x0=G.gateX-G.cw, x1=G.gateX+G.cw;
  const pad=Math.max(30,H*0.085);
  const yT=G.sTop-pad, yB=G.sBot+pad, r=14;
  const L=Math.max(34,W*0.05), m=Math.max(16,H*0.045);
  const tT=G.sTop-m, tB=G.sBot+m, mcy=(tT+tB)/2, mry=(tB-tT)/2;
  const mxL=x0-L, mxR=x1+L;
  // tube fills + box fill (slight tint, so it can become a black box later)
  ctx.save();ctx.fillStyle='rgba(12,16,30,0.30)';
  ctx.fillRect(mxL,tT,x0-mxL,tB-tT);
  ctx.fillRect(x1,tT,mxR-x1,tB-tT);
  rrect(x0,yT,x1-x0,yB-yT,r);ctx.fill();
  ctx.restore();
  ctx.save();
  ctx.strokeStyle=C.elec;ctx.lineWidth=2.5;ctx.shadowColor=C.elec;ctx.shadowBlur=8;ctx.lineJoin='round';ctx.lineCap='round';
  // box border — open at both throats (tT..tB) where the tubes join
  ctx.beginPath();
  ctx.moveTo(x0,tT);
  ctx.lineTo(x0,yT+r);ctx.arcTo(x0,yT,x0+r,yT,r);
  ctx.lineTo(x1-r,yT);ctx.arcTo(x1,yT,x1,yT+r,r);
  ctx.lineTo(x1,tT);
  ctx.stroke();
  ctx.beginPath();
  ctx.moveTo(x0,tB);
  ctx.lineTo(x0,yB-r);ctx.arcTo(x0,yB,x0+r,yB,r);
  ctx.lineTo(x1-r,yB);ctx.arcTo(x1,yB,x1,yB-r,r);
  ctx.lineTo(x1,tB);
  ctx.stroke();
  // tube walls + open rims
  ctx.beginPath();
  ctx.moveTo(x0,tT);ctx.lineTo(mxL,tT);ctx.moveTo(x0,tB);ctx.lineTo(mxL,tB);
  ctx.moveTo(x1,tT);ctx.lineTo(mxR,tT);ctx.moveTo(x1,tB);ctx.lineTo(mxR,tB);
  ctx.stroke();
  ctx.beginPath();ctx.ellipse(mxL,mcy,7,mry,0,0,7);ctx.stroke();
  ctx.beginPath();ctx.ellipse(mxR,mcy,7,mry,0,0,7);ctx.stroke();
  ctx.restore();
  // the crossover inside the box
  ctx.save();
  ctx.strokeStyle=C.elec;ctx.lineWidth=3;ctx.lineCap='round';
  ctx.beginPath();ctx.moveTo(x0,G.sTop);ctx.lineTo(x1,G.sBot);ctx.stroke();
  ctx.beginPath();ctx.moveTo(x0,G.sBot);ctx.lineTo(x1,G.sTop);ctx.stroke();
  ctx.restore();
}

/* ----- parametric helpers for multi-channel scenes (CNOT, ...) ----- */
function mkbtn(text,cls,onclick){
  const b=document.createElement('button');
  b.className='stepbtn'+(cls?' '+cls:'');b.textContent=text;b.onclick=onclick;return b;
}
function crossYabs(x,yIn,yOut){
  const a=G.gateX-G.cw, b=G.gateX+G.cw;
  if(x<=a) return yIn; if(x>=b) return yOut;
  return lerp(yIn,yOut,(x-a)/(b-a));
}
/* one qubit = one shape: circle, square or triangle (cannon + end state) */
function shapeAt(cx,cy,rad,shape){
  ctx.beginPath();
  if(shape==='square'){ const s=rad*1.75; ctx.rect(cx-s/2,cy-s/2,s,s); }
  else if(shape==='triangle'){ const s=rad*2.15, h=s*0.866;
    ctx.moveTo(cx,cy-2*h/3); ctx.lineTo(cx+s/2,cy+h/3); ctx.lineTo(cx-s/2,cy+h/3); ctx.closePath(); }
  else if(shape==='diamond'){ const s=rad*1.34; ctx.moveTo(cx,cy-s);ctx.lineTo(cx+s,cy);ctx.lineTo(cx,cy+s);ctx.lineTo(cx-s,cy);ctx.closePath(); }
  else if(shape==='pentagon'||shape==='hexagon'){ const sides=shape==='pentagon'?5:6, rr=rad*1.2, off=shape==='pentagon'?-Math.PI/2:0;
    for(let i=0;i<sides;i++){const a=off+i*2*Math.PI/sides, x=cx+Math.cos(a)*rr, y=cy+Math.sin(a)*rr; i?ctx.lineTo(x,y):ctx.moveTo(x,y);} ctx.closePath(); }
  else { ctx.arc(cx,cy,rad,0,7); }
}
function drawCannonAt(y,shape,col){
  col=col||C.warm;
  ctx.save();ctx.shadowColor=col;ctx.shadowBlur=16;
  shapeAt(G.sx,y,Math.max(6,H*0.014),shape);ctx.fillStyle=col;ctx.fill();
  ctx.restore();
}
function drawBarrierMulti(slits,sH){
  const x=G.bx;
  ctx.fillStyle='rgba(180,190,225,0.92)';
  let prev=0;
  slits.forEach(s=>{ ctx.fillRect(x-G.bw/2,prev,G.bw,(s.y-sH)-prev); prev=s.y+sH; });
  ctx.fillRect(x-G.bw/2,prev,G.bw,H-prev);
  ctx.save();ctx.shadowBlur=10;
  slits.forEach(s=>{ ctx.shadowColor=s.color;ctx.strokeStyle=s.color;ctx.globalAlpha=.55;ctx.lineWidth=G.bw;
    ctx.beginPath();ctx.moveTo(x,s.y-sH);ctx.lineTo(x,s.y+sH);ctx.stroke(); });
  ctx.restore();
  ctx.font='700 12px Cabin,Inter,system-ui';ctx.textAlign='center';
  slits.forEach(s=>{ if(s.lab){ctx.fillStyle=s.color;ctx.fillText(s.lab,x-22,s.y+4);} });
}
function drawLanesMulti(){
  ctx.save();ctx.setLineDash([5,8]);ctx.lineWidth=1.5;
  const x0=G.gateX-G.cw, x1=G.gateX+G.cw, sx=G.bx+G.bw/2;
  [[G.cTop,C.warm],[G.cBot,C.cool]].forEach(p=>{ctx.strokeStyle=p[1]+'40';
    ctx.beginPath();ctx.moveTo(sx,p[0]);ctx.lineTo(G.rx,p[0]);ctx.stroke();});
  [[G.tTop,C.warm],[G.tBot,C.cool]].forEach(p=>{ctx.strokeStyle=p[1]+'40';
    ctx.beginPath();ctx.moveTo(sx,p[0]);ctx.lineTo(x0,p[0]);ctx.stroke();
    ctx.beginPath();ctx.moveTo(x1,p[0]);ctx.lineTo(G.rx,p[0]);ctx.stroke();});
  ctx.restore();
}
function drawReadoutPair(yA,yB,landed,shape){
  const rr=Math.max(11,(yB-yA)*0.22);
  [[yA,C.warm,'1',1],[yB,C.cool,'0',0]].forEach(z=>{
    const on=landed===z[3];
    shapeAt(G.rx,z[0],rr,shape);ctx.fillStyle=on?z[1]:'#0d1226';
    if(on){ctx.save();ctx.shadowColor=z[1];ctx.shadowBlur=18;ctx.fill();ctx.restore();}else ctx.fill();
    ctx.lineWidth=2;ctx.strokeStyle=z[1]+(on?'':'66');ctx.stroke();
    ctx.font='800 13px Cabin,Inter,system-ui';ctx.textAlign='center';ctx.fillStyle=on?'#10131f':z[1];
    ctx.fillText(z[2],G.rx,z[0]+5);
  });
}
/* generic gate box on an arbitrary lane pair; crosses only when active */
function drawGateBox(yA,yB,active,label){
  const x0=G.gateX-G.cw, x1=G.gateX+G.cw, laneGap=yB-yA;
  const pad=Math.max(26,laneGap*0.34), m=Math.max(14,laneGap*0.20), r=14;
  const yT=yA-pad, yBo=yB+pad, L=Math.max(34,W*0.05);
  const tT=yA-m, tB=yB+m, mcy=(tT+tB)/2, mry=(tB-tT)/2, mxL=x0-L, mxR=x1+L;
  ctx.save();ctx.fillStyle='rgba(12,16,30,0.30)';
  ctx.fillRect(mxL,tT,x0-mxL,tB-tT);ctx.fillRect(x1,tT,mxR-x1,tB-tT);
  rrect(x0,yT,x1-x0,yBo-yT,r);ctx.fill();ctx.restore();
  ctx.save();
  ctx.strokeStyle=C.elec;ctx.lineWidth=2.5;ctx.shadowColor=C.elec;ctx.shadowBlur=8;ctx.lineJoin='round';ctx.lineCap='round';
  ctx.beginPath();ctx.moveTo(x0,tT);ctx.lineTo(x0,yT+r);ctx.arcTo(x0,yT,x0+r,yT,r);
  ctx.lineTo(x1-r,yT);ctx.arcTo(x1,yT,x1,yT+r,r);ctx.lineTo(x1,tT);ctx.stroke();
  ctx.beginPath();ctx.moveTo(x0,tB);ctx.lineTo(x0,yBo-r);ctx.arcTo(x0,yBo,x0+r,yBo,r);
  ctx.lineTo(x1-r,yBo);ctx.arcTo(x1,yBo,x1,yBo-r,r);ctx.lineTo(x1,tB);ctx.stroke();
  ctx.beginPath();
  ctx.moveTo(x0,tT);ctx.lineTo(mxL,tT);ctx.moveTo(x0,tB);ctx.lineTo(mxL,tB);
  ctx.moveTo(x1,tT);ctx.lineTo(mxR,tT);ctx.moveTo(x1,tB);ctx.lineTo(mxR,tB);ctx.stroke();
  ctx.beginPath();ctx.ellipse(mxL,mcy,7,mry,0,0,7);ctx.stroke();
  ctx.beginPath();ctx.ellipse(mxR,mcy,7,mry,0,0,7);ctx.stroke();
  ctx.restore();
  if(active){
    ctx.save();ctx.strokeStyle=C.elec;ctx.lineWidth=3;ctx.lineCap='round';
    ctx.beginPath();ctx.moveTo(x0,yA);ctx.lineTo(x1,yB);ctx.stroke();
    ctx.beginPath();ctx.moveTo(x0,yB);ctx.lineTo(x1,yA);ctx.stroke();ctx.restore();
  }else{
    ctx.save();ctx.setLineDash([5,8]);ctx.lineWidth=1.6;
    ctx.strokeStyle=C.warm+'66';ctx.beginPath();ctx.moveTo(x0,yA);ctx.lineTo(x1,yA);ctx.stroke();
    ctx.strokeStyle=C.cool+'66';ctx.beginPath();ctx.moveTo(x0,yB);ctx.lineTo(x1,yB);ctx.stroke();ctx.restore();
  }
}
/* control dot on the control 1-lane + linkage down to the target box */
function drawControlLink(active){
  const x=G.gateX, yDot=G.cTop;
  const boxTop=G.tTop-Math.max(26,(G.tBot-G.tTop)*0.34);
  ctx.save();
  ctx.strokeStyle=active?C.elec:'#7CFFB244';ctx.lineWidth=2.5;ctx.lineCap='round';
  if(active){ctx.shadowColor=C.elec;ctx.shadowBlur=8;}
  ctx.beginPath();ctx.moveTo(x,yDot);ctx.lineTo(x,boxTop);ctx.stroke();
  ctx.beginPath();ctx.arc(x,yDot,7,0,7);
  ctx.fillStyle=active?C.elec:'#0c101e';ctx.fill();
  ctx.strokeStyle=active?C.elec:'#7CFFB288';ctx.stroke();
  ctx.restore();
}
/* dashed lanes for an arbitrary list of channels (gated ones split at the box) */
function drawChannelLanes(channels){
  ctx.save();ctx.setLineDash([5,8]);ctx.lineWidth=1.5;
  const x0=G.gateX-G.cw, x1=G.gateX+G.cw, sx=G.bx+G.bw/2;
  channels.forEach(ch=>{
    [[ch.yT,C.warm],[ch.yB,C.cool]].forEach(p=>{ctx.strokeStyle=p[1]+'40';
      if(ch.gated){ctx.beginPath();ctx.moveTo(sx,p[0]);ctx.lineTo(x0,p[0]);ctx.stroke();
        ctx.beginPath();ctx.moveTo(x1,p[0]);ctx.lineTo(G.rx,p[0]);ctx.stroke();}
      else{ctx.beginPath();ctx.moveTo(sx,p[0]);ctx.lineTo(G.rx,p[0]);ctx.stroke();}});
  });
  ctx.restore();
}
/* one vertical linkage tapping several control dots; bright only when active */
function drawControlLinks(dotYs,ons,active,boxTop){
  const x=G.gateX, top=Math.min.apply(null,dotYs);
  ctx.save();
  ctx.strokeStyle=active?C.elec:'#7CFFB244';ctx.lineWidth=2.5;ctx.lineCap='round';
  if(active){ctx.shadowColor=C.elec;ctx.shadowBlur=8;}
  ctx.beginPath();ctx.moveTo(x,top);ctx.lineTo(x,boxTop);ctx.stroke();
  ctx.restore();
  dotYs.forEach((y,i)=>{const on=ons[i];ctx.save();
    ctx.beginPath();ctx.arc(x,y,7,0,7);
    if(on){ctx.shadowColor=C.elec;ctx.shadowBlur=8;}
    ctx.fillStyle=on?C.elec:'#0c101e';ctx.fill();
    ctx.lineWidth=2.5;ctx.strokeStyle=on?C.elec:'#7CFFB288';ctx.stroke();ctx.restore();});
}

/* path the ball follows along the lanes, with optional crossover at the gate */
function laneY(x,vin,vout,hasGate){
  if(!hasGate || vin===vout) return ySlit(vin);
  const a=G.gateX-G.cw, b=G.gateX+G.cw;
  if(x<=a) return ySlit(vin);
  if(x>=b) return ySlit(vout);
  return lerp(ySlit(vin),ySlit(vout),(x-a)/(b-a));
}

/* =========================================================================
   SCENE 1 — QUBIT: up (1), down (0), or BOTH at once (superposition / mist)
   ========================================================================= */
const S1={
  tag:'1 · Qubit', tagColor:'var(--mist)',
  subtitle:'Fire one ball at the two slits. Now it can take the up slit, the down slit — or both at once.',
  capTitle:'A qubit can be <b class="warm">1</b>, <b class="cool">0</b>, or a <b class="mist">mist</b> of both.',
  capSub:'A classical bit must pick one slit. A <b class="mist">qubit</b> can go through <b class="warm">both slits at once</b> — a <b class="mist">superposition</b>. We draw that as a <b class="mist">cloud</b> holding both possibilities, <b class="warm">1</b> and <b class="cool">0</b>, until we <b>measure</b> — then it collapses to a single answer.',
  ball:null, ghosts:null, landed:null, mist:false, collapse:0, measured:null,
  setReadout(t){ $('#readout').innerHTML=t; },
  reset(){
    this.ball=null;this.ghosts=null;this.landed=null;this.mist=false;this.collapse=0;this.measured=null;
    this.setReadout('Fire a definite <b class="w">1</b> / <b class="c">0</b>, or <b class="m">both</b> for a superposition.');
  },
  fire(v){
    this.reset();
    this.ball={vin:v,x:G.sx,y:G.cy,phase:'toSlit'};
    this.setReadout('Firing&hellip;');
  },
  fireSuper(){
    this.reset();
    this.ball={sup:true,t:0};
    this.setReadout('Firing through <b class="m">both</b> slits at once&hellip;');
  },
  measure(){
    if(!this.mist||this.collapse>0) return;
    this.measured = Math.random()<0.5 ? 0 : 1;
    this.collapse = 0.0001;
    this.setReadout('Measuring&hellip;');
  },
  step(dt){
    const vx=W*0.42*dt;
    const b=this.ball;
    if(b){
      if(b.sup){
        b.t += dt*0.6;
        if(b.t>=1){
          this.ball=null; this.mist=true;
          this.setReadout('Superposition: <b class="w">1</b> and <b class="c">0</b> at once — a <b class="m">cloud</b>. Press <b>Measure</b> to look.');
        }
      } else {
        if(b.phase==='toSlit'){
          const tx=G.bx, ty=ySlit(b.vin), dx=tx-G.sx, dy=ty-G.cy, L=Math.hypot(dx,dy)||1;
          b.x+=dx/L*vx; b.y+=dy/L*vx;
          if(b.x>=G.bx){ b.x=G.bx; b.y=ty; b.phase='lane'; }
        } else {
          b.x+=vx; b.y=ySlit(b.vin);
          if(b.x>=G.rx){
            this.landed=b.vin; this.ball=null;
            this.setReadout(b.vin
              ? 'The ball took the <b class="w">up</b> slit &rarr; qubit = <b class="w">1</b> (definite).'
              : 'The ball took the <b class="c">down</b> slit &rarr; qubit = <b class="c">0</b> (definite).');
          }
        }
      }
    }
    if(this.collapse>0 && this.collapse<1){
      this.collapse=Math.min(1,this.collapse+dt*1.6);
      if(this.collapse>=1){
        this.mist=false; this.landed=this.measured;
        this.setReadout('Measured <b class="'+(this.measured?'w':'c')+'">'+this.measured+'</b> — the <b class="m">cloud</b> collapsed to one answer. Fire <b class="m">both</b> again to retry.');
      }
    }
  },
  draw(){
    clearBG();
    drawLanes(false);
    if(this.mist || this.collapse>0){
      const inten = this.collapse>0 ? (1-this.collapse) : 1;
      drawMistCloud(inten, this.measured, this.collapse);
    } else {
      drawReadout(this.landed);
    }
    drawBarrier();
    drawCannon();
    const b=this.ball;
    if(b){
      if(b.sup){
        const t=b.t;
        drawSuperPaths(0.18);
        const startR=Math.max(4,H*0.013), bigRx=Math.max(7,H*0.02);
        const spanRy=G.gap/2+G.sH, coreR=Math.max(4,H*0.011);
        const cloudRy=mistCellY(0)-G.cy+Math.max(13,H*0.028);
        if(t<0.5){
          // one fuzzy wave-packet fans out to cover BOTH slits at once
          const u=t/0.5, px=lerp(G.sx,G.bx,u);
          blob(px,G.cy,lerp(startR,bigRx,u),lerp(startR,spanRy,u),C.mist);
        } else {
          // past the slits: the two paths ride the lanes and merge into the cloud
          const u=(t-0.5)/0.5, px=lerp(G.bx,G.rx,u);
          blob(px,G.cy,bigRx*(1-0.45*u),lerp(spanRy,cloudRy,u),C.mist);
          blob(px,lerp(G.sTop,mistCellY(1),u),coreR*1.7,coreR*1.7,C.warm);
          blob(px,lerp(G.sBot,mistCellY(0),u),coreR*1.7,coreR*1.7,C.cool);
        }
      } else {
        ctx.save();ctx.shadowColor=colOf(b.vin);ctx.shadowBlur=14;
        ctx.beginPath();ctx.arc(b.x,b.y,Math.max(5,H*0.012),0,7);
        ctx.fillStyle=colOf(b.vin);ctx.fill();ctx.restore();
      }
    }
  },
  buildControls(el){
    el.innerHTML='';const self=this;
    el.append(
      mkbtn('Fire ▲ (1)','up',()=>self.fire(1)),
      mkbtn('Fire ▼ (0)','dn',()=>self.fire(0)),
      mkbtn('Fire ◐ both','mist',()=>self.fireSuper()),
      mkbtn('Measure','',()=>self.measure()),
      mkbtn('↻','',()=>self.reset())
    );
  },
  onEnter(){ this.buildControls($('#sctrl')); this.reset(); },
  onLeave(){ this.ball=null; this.ghosts=null; },
};

/* =========================================================================
   GENERIC SCENE (parametrised by hasNOT) — used by the classical NOT scene
   ========================================================================= */
function makeScene(cfg){
  return {
    tag:cfg.tag, tagColor:cfg.tagColor, subtitle:cfg.subtitle,
    capTitle:cfg.capTitle, capSub:cfg.capSub, hasNOT:cfg.hasNOT,
    ball:null, landed:null, vin:null,
    fire(v){
      this.landed=null; this.vin=v;
      this.ball={vin:v, vout:this.hasNOT?(1-v):v, x:G.sx, y:G.cy, phase:'toSlit'};
      $('#readout').innerHTML='Firing&hellip;';
    },
    reset(){ this.ball=null; this.landed=null; this.vin=null;
      $('#readout').innerHTML=cfg.idle; },
    step(dt){
      const b=this.ball; if(!b) return;
      const vx=W*0.42*dt;
      if(b.phase==='toSlit'){
        const tx=G.bx, ty=ySlit(b.vin);
        const dx=tx-G.sx, dy=ty-G.cy, L=Math.hypot(dx,dy)||1;
        b.x+=dx/L*vx; b.y+=dy/L*vx;
        if(b.x>=G.bx){ b.x=G.bx; b.y=ty; b.phase='lane'; }
      } else {
        b.x+=vx; b.y=laneY(b.x,b.vin,b.vout,this.hasNOT);
        if(b.x>=G.rx){
          this.landed=b.vout; this.ball=null;
          $('#readout').innerHTML=cfg.result(b.vin,b.vout);
        }
      }
    },
    draw(){
      clearBG();
      drawLanes(this.hasNOT);
      drawReadout(this.landed);
      if(this.hasNOT) drawNOTgate();
      drawBarrier();
      drawCannon();
      const b=this.ball;
      if(b){
        ctx.save();ctx.shadowColor=colOf(b.x<G.gateX?b.vin:b.vout);ctx.shadowBlur=14;
        ctx.beginPath();ctx.arc(b.x,b.y,Math.max(5,H*0.012),0,7);
        ctx.fillStyle=colOf(b.x<G.gateX?b.vin:b.vout);ctx.fill();ctx.restore();
      }
    },
    buildControls(el){
      el.innerHTML='';const self=this;
      el.append(
        mkbtn('Fire ▲ (1)','up',()=>self.fire(1)),
        mkbtn('Fire ▼ (0)','dn',()=>self.fire(0)),
        mkbtn('↻','',()=>self.reset())
      );
    },
    onEnter(){ this.buildControls($('#sctrl')); this.reset(); },
    onLeave(){ this.ball=null; },
  };
}

/* =========================================================================
   SCENE 2 — NOT on a qubit: the gate flips EVERY branch of the cloud at once
   ========================================================================= */
const S2={
  tag:'2 · NOT gate', tagColor:'var(--elec)',
  subtitle:'The same crossover gate — but now it can act on a whole cloud at once.',
  capTitle:'<b class="elec">NOT</b> flips <b class="mist">every branch</b> of the superposition at once.',
  capSub:'A definite bit just swaps lanes, as before. But fire <b class="mist">both</b> and the gate flips <b class="warm">1</b>&rarr;<b class="cool">0</b> <i>and</i> <b class="cool">0</b>&rarr;<b class="warm">1</b> in a single pass — the whole <b class="mist">cloud</b> is transformed together. The balanced cloud maps back to itself, yet each branch really did flip: a first taste of <b class="mist">quantum parallelism</b>.',
  ball:null, landed:null, mist:false, collapse:0, measured:null,
  setReadout(t){ $('#readout').innerHTML=t; },
  reset(){
    this.ball=null;this.landed=null;this.mist=false;this.collapse=0;this.measured=null;
    this.setReadout('Fire a definite <b class="w">1</b>/<b class="c">0</b>, or <b class="m">both</b>, through the <b class="e">NOT</b>.');
  },
  fire(v){
    this.reset();
    this.ball={vin:v,vout:1-v,x:G.sx,y:G.cy,phase:'toSlit'};
    this.setReadout('Firing&hellip;');
  },
  fireSuper(){
    this.reset();
    this.ball={sup:true,t:0};
    this.setReadout('Sending <b class="m">both</b> branches through the <b class="e">NOT</b>&hellip;');
  },
  measure(){
    if(!this.mist||this.collapse>0) return;
    this.measured = Math.random()<0.5 ? 0 : 1;
    this.collapse = 0.0001;
    this.setReadout('Measuring&hellip;');
  },
  step(dt){
    const vx=W*0.42*dt;
    const b=this.ball;
    if(b){
      if(b.sup){
        b.t += dt*0.5;
        if(b.t>=1){
          this.ball=null; this.mist=true;
          this.setReadout('<b class="e">NOT</b> flipped <b>both</b> branches at once (<b class="w">1</b>&harr;<b class="c">0</b>). Still a <b class="m">cloud</b> — <b>Measure</b> to look.');
        }
      } else {
        if(b.phase==='toSlit'){
          const tx=G.bx, ty=ySlit(b.vin), dx=tx-G.sx, dy=ty-G.cy, L=Math.hypot(dx,dy)||1;
          b.x+=dx/L*vx; b.y+=dy/L*vx;
          if(b.x>=G.bx){ b.x=G.bx; b.y=ty; b.phase='lane'; }
        } else {
          b.x+=vx; b.y=laneY(b.x,b.vin,b.vout,true);
          if(b.x>=G.rx){
            this.landed=b.vout; this.ball=null;
            this.setReadout('In <b class="'+(b.vin?'w':'c')+'">'+b.vin+'</b> &rarr; <b class="e">NOT</b> &rarr; out <b class="'+(b.vout?'w':'c')+'">'+b.vout+'</b> (definite).');
          }
        }
      }
    }
    if(this.collapse>0 && this.collapse<1){
      this.collapse=Math.min(1,this.collapse+dt*1.6);
      if(this.collapse>=1){
        this.mist=false; this.landed=this.measured;
        this.setReadout('Measured <b class="'+(this.measured?'w':'c')+'">'+this.measured+'</b> — the cloud collapsed. Fire <b class="m">both</b> again to retry.');
      }
    }
  },
  draw(){
    clearBG();
    drawLanes(true);
    if(this.mist || this.collapse>0){
      const inten = this.collapse>0 ? (1-this.collapse) : 1;
      drawMistCloud(inten, this.measured, this.collapse);
    } else {
      drawReadout(this.landed);
    }
    drawNOTgate();
    drawBarrier();
    drawCannon();
    const b=this.ball;
    if(b){
      if(b.sup){
        const t=b.t;
        drawSuperPathsNOT(0.18);
        const startR=Math.max(4,H*0.013), bigRx=Math.max(7,H*0.02);
        const spanRy=G.gap/2+G.sH, coreR=Math.max(4,H*0.011);
        const cloudRy=mistCellY(0)-G.cy+Math.max(13,H*0.028);
        if(t<0.30){
          // wave-packet fans out to cover BOTH slits at once
          const u=t/0.30, px=lerp(G.sx,G.bx,u);
          blob(px,G.cy,lerp(startR,bigRx,u),lerp(startR,spanRy,u),C.mist);
        } else {
          // both branches ride the lanes, CROSS at the gate, merge into the cloud
          const u=(t-0.30)/0.70, x=lerp(G.bx,G.rx,u);
          const xc=G.rx-(G.rx-G.bx)*0.14;
          blob(x,G.cy,bigRx*(1-0.4*u),lerp(spanRy,cloudRy,Math.min(1,u*1.15)),C.mist);
          [[G.sTop,G.sBot,1],[G.sBot,G.sTop,0]].forEach(p=>{
            let y=crossYabs(x,p[0],p[1]);
            const val = x<G.gateX ? p[2] : 1-p[2];
            if(x>xc){ const k=(x-xc)/(G.rx-xc); y=lerp(y,mistCellY(val),k); }
            blob(x,y,coreR*1.7,coreR*1.7,colOf(val));
          });
        }
      } else {
        const col=colOf(b.x<G.gateX?b.vin:b.vout);
        ctx.save();ctx.shadowColor=col;ctx.shadowBlur=14;
        ctx.beginPath();ctx.arc(b.x,b.y,Math.max(5,H*0.012),0,7);
        ctx.fillStyle=col;ctx.fill();ctx.restore();
      }
    }
  },
  buildControls(el){
    el.innerHTML='';const self=this;
    el.append(
      mkbtn('Fire ▲ (1)','up',()=>self.fire(1)),
      mkbtn('Fire ▼ (0)','dn',()=>self.fire(0)),
      mkbtn('Fire ◐ both','mist',()=>self.fireSuper()),
      mkbtn('Measure','',()=>self.measure()),
      mkbtn('↻','',()=>self.reset())
    );
  },
  onEnter(){ this.buildControls($('#sctrl')); this.reset(); },
  onLeave(){ this.ball=null; },
};

/* =========================================================================
   SCENE 3 — CNOT: a control bit decides whether NOT fires on the target
   ========================================================================= */
/* one cell of a configuration: a shape (square=control, circle=target) + value */
function drawCell(shape,x,y,rr,val,glow,intensity){
  const col=colOf(val);
  ctx.save();
  if(glow||intensity>0.4){ctx.shadowColor=col;ctx.shadowBlur=glow?18:12;}
  shapeAt(x,y,rr,shape);ctx.fillStyle=col;ctx.fill();
  ctx.lineWidth=2;ctx.strokeStyle=col;ctx.stroke();
  ctx.shadowBlur=0;ctx.fillStyle='#10131f';const fz=Math.max(8,Math.round(rr*1.0));ctx.font='800 '+fz+'px Cabin,Inter,system-ui';ctx.textAlign='center';
  ctx.fillText(String(val),x,y+fz*0.35);
  ctx.restore();
}
/* the joint output cloud: N configurations (each ▪control + ●target), stacked
   and separated by bars. Labelled "entangled" only when the caller says so. */
function drawJointCloud(configs, measured, collapse, intensity, entangled){
  const N=configs.length, xr=G.rx, cyMid=G.cy;
  const r=Math.max(9, N>2?H*0.020:H*0.024), dx=Math.max(15,W*0.022);
  const rowSep = N>1 ? Math.min(H*0.115, (H*0.34)/N) : 0;
  const totalH=(N-1)*rowSep;
  const rows=configs.map((cf,i)=>({cv:cf.c,tv:cf.t,y:cyMid-totalH/2+i*rowSep}));
  const crx=dx+r+26, cry=totalH/2+r+24;
  intensity=Math.max(0,Math.min(1,intensity));
  if(intensity>0.002){
    ctx.save();ctx.globalAlpha=intensity;
    const R=Math.max(crx,cry);
    const grd=ctx.createRadialGradient(xr,cyMid,r*0.4,xr,cyMid,R*1.05);
    grd.addColorStop(0,'rgba(198,184,255,0.30)');grd.addColorStop(0.6,'rgba(180,164,255,0.15)');grd.addColorStop(1,'rgba(180,164,255,0)');
    ctx.shadowColor='rgba(185,168,255,0.5)';ctx.shadowBlur=22;
    cloudPath(xr,cyMid,crx,cry);ctx.fillStyle=grd;ctx.fill();
    ctx.shadowBlur=0;cloudPath(xr,cyMid,crx*0.96,cry*0.96);ctx.fillStyle=grd;ctx.fill();
    ctx.restore();
    ctx.save();ctx.globalAlpha=intensity*0.8;ctx.strokeStyle='rgba(205,194,255,0.7)';ctx.lineWidth=1.5;
    for(let i=1;i<N;i++){const by=(rows[i-1].y+rows[i].y)/2;ctx.beginPath();ctx.moveTo(xr-crx*0.6,by);ctx.lineTo(xr+crx*0.6,by);ctx.stroke();}
    ctx.restore();
  }
  rows.forEach((row,idx)=>{
    const chosen=measured===idx;
    let a=intensity*0.92, sc=1;
    if(collapse>0){a=chosen?1:intensity*0.92;sc=chosen?1+0.10*collapse:1-0.3*collapse;}
    a=Math.max(0,a);
    ctx.save();ctx.globalAlpha=a;
    ctx.strokeStyle='rgba(205,194,255,0.4)';ctx.lineWidth=1.2;
    ctx.beginPath();ctx.moveTo(xr-dx,row.y);ctx.lineTo(xr+dx,row.y);ctx.stroke();
    drawCell('square',xr-dx,row.y,r*sc,row.cv,chosen,intensity);
    drawCell('circle',xr+dx,row.y,r*sc,row.tv,chosen,intensity);
    ctx.restore();
  });
}
/* control link in superposition (mist) style: both control values tap the gate */
function drawQControlLink(){
  const x=G.gateX, boxTop=G.tTop-Math.max(26,(G.tBot-G.tTop)*0.34);
  ctx.save();ctx.setLineDash([4,5]);ctx.strokeStyle=C.mist;ctx.globalAlpha=0.85;ctx.lineWidth=2;
  ctx.beginPath();ctx.moveTo(x,G.cTop);ctx.lineTo(x,boxTop);ctx.stroke();ctx.setLineDash([]);
  ctx.beginPath();ctx.arc(x,G.cTop,6,0,7);ctx.globalAlpha=0.7;ctx.fillStyle=C.mist;ctx.fill();
  ctx.globalAlpha=0.95;ctx.lineWidth=2;ctx.strokeStyle=C.mist;ctx.stroke();
  ctx.restore();
}

const S3={
  tag:'3 · CNOT gate', tagColor:'var(--elec)',
  subtitle:'Two qubits. Each can be 0, 1, or a cloud of both — and the gate can tie them together.',
  capTitle:'<b class="elec">CNOT</b> on a superposed control makes an <b class="mist">entangled</b> cloud.',
  capSub:'With a definite control it is the old story: control <b class="warm">1</b> flips the <b>target</b>, control <b class="cool">0</b> leaves it. Put the <b class="mist">control</b> in a cloud of both and the gate acts on each branch at once — the result is one cloud of two <i>linked</i> pairs, so measuring either qubit decides the other: <b class="mist">entanglement</b>. Superpose the <b class="mist">target</b> too and you get a bigger cloud — but if the control is definite, the qubits stay independent (a plain superposition, not entangled).',
  cin:1, tin:0, cball:null, tball:null, cLanded:null, tLanded:null, _sync:null,
  sup:null, mist:false, collapse:0, measured:null,
  setReadout(t){ $('#readout').innerHTML=t; },
  configList(){
    const cv=this.cin===2?[1,0]:[this.cin];
    const tv=this.tin===2?[1,0]:[this.tin];
    const out=[];
    cv.forEach(c=>tv.forEach(t=>out.push({c, t:t^c})));
    out.sort((a,b)=> b.c-a.c || b.t-a.t);
    return out;
  },
  quantum(){ return this.cin===2 || this.tin===2; },
  entangled(){ return this.cin===2 && this.tin<2; },
  buildControls(el){
    el.innerHTML='';const self=this;
    const cB=mkbtn('','',()=>{self.cin=(self.cin+1)%3;self._sync();self.reset();});
    const tB=mkbtn('','',()=>{self.tin=(self.tin+1)%3;self._sync();self.reset();});
    el.append(cB,tB,mkbtn('Run ⚡','',()=>self.run()),mkbtn('Measure','',()=>self.measure()),mkbtn('↻','',()=>self.reset()));
    this._sync=function(){
      cB.textContent='control '+(self.cin===2?'◐ both':(self.cin?'▲ 1':'▼ 0'));
      cB.className='stepbtn '+(self.cin===2?'mist':(self.cin?'up':'dn'));
      tB.textContent='target '+(self.tin===2?'◐ both':(self.tin?'▲ 1':'▼ 0'));
      tB.className='stepbtn '+(self.tin===2?'mist':(self.tin?'up':'dn'));
    };this._sync();
  },
  reset(){ this.cball=this.tball=null;this.cLanded=this.tLanded=null;this.sup=null;this.mist=false;this.collapse=0;this.measured=null;
    this.setReadout(this.quantum()
      ? 'At least one qubit is a <b class="m">cloud</b>. Press <b>Run</b>, then <b>Measure</b>.'
      : 'Set the <b class="e">control</b> and <b class="w">target</b>, then press <b>Run</b>.'); },
  run(){
    this.measured=null;this.collapse=0;this.mist=false;
    if(this.quantum()){ this.cball=this.tball=null;this.cLanded=this.tLanded=null;this.sup={t:0};this.setReadout('Running all branches&hellip;');return; }
    this.cLanded=this.tLanded=null;
    const active=this.cin===1, tout=active?(1-this.tin):this.tin;
    this.cball={x:G.sx,y:G.cyC,sy:(this.cin?G.cTop:G.cBot),vin:this.cin,phase:'toSlit'};
    this.tball={x:G.sx,y:G.cyT,syIn:(this.tin?G.tTop:G.tBot),syOut:(tout?G.tTop:G.tBot),vin:this.tin,vout:tout,phase:'toSlit'};
    this.setReadout('Running&hellip;');
  },
  measure(){ if(!this.mist||this.collapse>0)return; this.measured=Math.floor(Math.random()*this.configList().length); this.collapse=0.0001; this.setReadout('Measuring&hellip;'); },
  _result(){
    if(this.cball||this.tball)return;
    if(this.cLanded==null&&this.tLanded==null)return;
    const cin=this.cLanded,tout=this.tLanded;
    this.setReadout('control <b class="'+(cin?'w':'c')+'">'+cin+'</b> (unchanged) &nbsp;·&nbsp; target <b class="'+(this.tin?'w':'c')+'">'+this.tin+'</b> &rarr; <b class="e">CNOT</b> &rarr; <b class="'+(tout?'w':'c')+'">'+tout+'</b>');
  },
  step(dt){
    if(this.sup){ this.sup.t+=dt*0.5; if(this.sup.t>=1){ this.sup=null; this.mist=true;
      const cfgs=this.configList(), ent=this.entangled();
      const list=cfgs.map(c=>'▪'+c.c+'●'+c.t).join(' &nbsp;|&nbsp; ');
      this.setReadout((ent?'<b class="m">Entangled!</b> ':'<b class="m">Superposition.</b> ')+'The cloud holds '+list+'. <b>Measure</b> to collapse'+(ent?' — the two always agree.':'.')); } }
    if(this.collapse>0 && this.collapse<1){ this.collapse=Math.min(1,this.collapse+dt*1.6);
      if(this.collapse>=1){ const cfgs=this.configList(), c=cfgs[this.measured]||cfgs[0], ent=this.entangled();
        this.setReadout('Measured ▪<b class="'+(c.c?'w':'c')+'">'+c.c+'</b> ●<b class="'+(c.t?'w':'c')+'">'+c.t+'</b>'+(ent?' — measuring one fixed the other. <b class="m">Entanglement</b>.':'.')); } }
    const vx=W*0.42*dt;
    let b=this.cball;
    if(b){
      if(b.phase==='toSlit'){const dx=G.bx-G.sx,dy=b.sy-G.cyC,L=Math.hypot(dx,dy)||1;b.x+=dx/L*vx;b.y+=dy/L*vx;if(b.x>=G.bx){b.x=G.bx;b.y=b.sy;b.phase='lane';}}
      else{b.x+=vx;b.y=b.sy;if(b.x>=G.rx){this.cLanded=b.vin;this.cball=null;this._result();}}
    }
    b=this.tball;
    if(b){
      if(b.phase==='toSlit'){const dx=G.bx-G.sx,dy=b.syIn-G.cyT,L=Math.hypot(dx,dy)||1;b.x+=dx/L*vx;b.y+=dy/L*vx;if(b.x>=G.bx){b.x=G.bx;b.y=b.syIn;b.phase='lane';}}
      else{b.x+=vx;b.y=crossYabs(b.x,b.syIn,b.syOut);if(b.x>=G.rx){this.tLanded=b.vout;this.tball=null;this._result();}}
    }
  },
  drawQuantum(){
    drawLanesMulti();
    const cfgs=this.configList(), ent=this.entangled();
    if(this.mist || this.collapse>0){ const inten=this.collapse>0?(1-this.collapse):1; drawJointCloud(cfgs,this.measured,this.collapse,inten,ent); }
    drawGateBox(G.tTop,G.tBot,this.cin!==0,'NOT');
    if(this.cin===2) drawQControlLink(); else drawControlLink(this.cin===1);
    drawBarrierMulti([{y:G.cTop,color:C.warm,lab:'1'},{y:G.cBot,color:C.cool,lab:'0'},
                      {y:G.tTop,color:C.warm,lab:'1'},{y:G.tBot,color:C.cool,lab:'0'}],G.sH2);
    drawCannonAt(G.cyC,'square',this.cin===2?C.mist:colOf(this.cin));
    drawCannonAt(G.cyT,'circle',this.tin===2?C.mist:colOf(this.tin));
    ctx.font='11px Cabin,Inter,system-ui';ctx.fillStyle=C.muted;ctx.textAlign='center';
    ctx.fillText('control',G.sx,G.cTop-12);ctx.fillText('target',G.sx,G.tBot+18);
    if(this.sup){
      const t=this.sup.t, coreR=Math.max(4,H*0.011), startR=Math.max(4,H*0.012), spanRyC=G.gap2/2+G.sH2;
      const cS=this.cin===2, tS=this.tin===2, gateL=G.gateX-G.cw;
      const cvals=cS?[1,0]:[this.cin], tvals=tS?[1,0]:[this.tin];
      const crisp=(px,py,col,al)=>{ctx.save();ctx.globalAlpha=al;ctx.shadowColor=col;ctx.shadowBlur=14;
        ctx.beginPath();ctx.arc(px,py,Math.max(5,H*0.011),0,7);ctx.fillStyle=col;ctx.fill();ctx.restore();};
      const fuzz=(px,py,col,al)=>{ctx.save();ctx.globalAlpha=al;blob(px,py,coreR*1.7,coreR*1.7,col);ctx.restore();};
      if(t<0.30){
        // approach: each qubit goes to its slit(s). superposed => fans (mist); definite => crisp ball.
        const u=t/0.30, px=lerp(G.sx,G.bx,u), gr=Math.max(7,H*0.017);
        if(cS) blob(px,G.cyC,lerp(startR,gr,u),lerp(startR,spanRyC,u),C.mist);
        else   crisp(px,lerp(G.cyC,this.cin?G.cTop:G.cBot,u),colOf(this.cin),1);
        if(tS) blob(px,G.cyT,lerp(startR,gr,u),lerp(startR,spanRyC,u),C.mist);
        else   crisp(px,lerp(G.cyT,this.tin?G.tTop:G.tBot,u),colOf(this.tin),1);
      } else {
        // travel: cores ride their lanes (target crosses at the gate), then dissolve
        // into the joint cloud over the last stretch (crossfade as k: 0 -> 1).
        const u=(t-0.30)/0.70, x=lerp(G.bx,G.rx,u);
        const xc=G.rx-(G.rx-G.bx)*0.16, k=x>xc?(x-xc)/(G.rx-xc):0, a=1-k;
        cvals.forEach(cv=>{ const y=cv?G.cTop:G.cBot; cS?fuzz(x,y,colOf(cv),a):crisp(x,y,colOf(cv),a); });
        if(x<=gateL){
          tvals.forEach(tv=>{ const y=tv?G.tTop:G.tBot; tS?fuzz(x,y,colOf(tv),a):crisp(x,y,colOf(tv),a); });
        } else if(!cS){
          // definite control: target just shifts by the control value (flip iff control=1)
          tvals.forEach(tv=>{ const tY=tv?G.tTop:G.tBot, lv=tv^this.cin, oY=lv?G.tTop:G.tBot;
            const y=this.cin?crossYabs(x,tY,oY):tY, val=x<G.gateX?tv:lv;
            tS?fuzz(x,y,colOf(val),a):crisp(x,y,colOf(val),a); });
        } else {
          // superposed control: every target branch splits (stay + flip) => entangling
          tvals.forEach(tv=>{ const tY=tv?G.tTop:G.tBot, oY=(1-tv)?G.tTop:G.tBot;
            fuzz(x,tY,colOf(tv),a*0.95);
            const yc=crossYabs(x,tY,oY), val=x<G.gateX?tv:1-tv;
            fuzz(x,yc,colOf(val),a*0.95); });
        }
        if(k>0) drawJointCloud(cfgs,null,0,k,ent);
      }
    }
  },
  draw(){
    clearBG();
    if(this.quantum()){ this.drawQuantum(); return; }
    drawLanesMulti();
    drawReadoutPair(G.cTop,G.cBot,this.cLanded,'square');
    drawReadoutPair(G.tTop,G.tBot,this.tLanded,'circle');
    drawGateBox(G.tTop,G.tBot,this.cin===1,'NOT');
    drawControlLink(this.cin===1);
    drawBarrierMulti([{y:G.cTop,color:C.warm,lab:'1'},{y:G.cBot,color:C.cool,lab:'0'},
                      {y:G.tTop,color:C.warm,lab:'1'},{y:G.tBot,color:C.cool,lab:'0'}],G.sH2);
    drawCannonAt(G.cyC,'square',colOf(this.cin));drawCannonAt(G.cyT,'circle',colOf(this.tin));
    ctx.font='11px Cabin,Inter,system-ui';ctx.fillStyle=C.muted;ctx.textAlign='center';
    ctx.fillText('control',G.sx,G.cTop-12);
    ctx.fillText('target',G.sx,G.tBot+18);
    const drawB=(b,vbefore,vafter)=>{const v=b.x<G.gateX?vbefore:vafter,col=colOf(v);
      ctx.save();ctx.shadowColor=col;ctx.shadowBlur=14;ctx.beginPath();
      ctx.arc(b.x,b.y,Math.max(5,H*0.011),0,7);ctx.fillStyle=col;ctx.fill();ctx.restore();};
    if(this.cball)drawB(this.cball,this.cin,this.cin);
    if(this.tball)drawB(this.tball,this.tin,this.tball.vout);
  },
  onEnter(){ this.buildControls($('#sctrl')); this.reset(); },
  onLeave(){ this.cball=this.tball=null;this.sup=null; },
};

/* =========================================================================
   SCENE 4 — TOFFOLI (CCNOT): target flips only if BOTH controls are 1
   ========================================================================= */
/* generic joint cloud: N configurations, each a row of M shape-cells
   (used by Toffoli with ▲ ■ ●; auto-sizes for up to 8 rows) */
function drawConfigCloud(configs, shapes, measured, collapse, intensity, entangled, legend){
  const N=configs.length, M=shapes.length, xr=G.rx, cyMid=G.cy;
  const rowSep = N>1 ? Math.min(H*0.10, (H*0.58)/N) : 0;
  const r = N>1 ? Math.min(H*0.022, rowSep*0.42) : H*0.022;
  const cdx = r*2.4;
  const totalH=(N-1)*rowSep, x0=xr-(M-1)*cdx/2;
  const rows=configs.map((vals,i)=>({vals,y:cyMid-totalH/2+i*rowSep}));
  const crx=(M-1)*cdx/2 + r + 24, cry=totalH/2 + r + 22;
  intensity=Math.max(0,Math.min(1,intensity));
  if(intensity>0.002){
    ctx.save();ctx.globalAlpha=intensity;
    const R=Math.max(crx,cry);
    const grd=ctx.createRadialGradient(xr,cyMid,r*0.4,xr,cyMid,R*1.05);
    grd.addColorStop(0,'rgba(198,184,255,0.30)');grd.addColorStop(0.6,'rgba(180,164,255,0.15)');grd.addColorStop(1,'rgba(180,164,255,0)');
    ctx.shadowColor='rgba(185,168,255,0.5)';ctx.shadowBlur=22;
    cloudPath(xr,cyMid,crx,cry);ctx.fillStyle=grd;ctx.fill();
    ctx.shadowBlur=0;cloudPath(xr,cyMid,crx*0.96,cry*0.96);ctx.fillStyle=grd;ctx.fill();
    ctx.restore();
    ctx.save();ctx.globalAlpha=intensity*0.78;ctx.strokeStyle='rgba(205,194,255,0.62)';ctx.lineWidth=1.3;
    for(let i=1;i<N;i++){const by=(rows[i-1].y+rows[i].y)/2;ctx.beginPath();ctx.moveTo(xr-crx*0.62,by);ctx.lineTo(xr+crx*0.62,by);ctx.stroke();}
    ctx.restore();
  }
  rows.forEach((row,idx)=>{
    const chosen=measured===idx;
    let a=intensity*0.92, sc=1;
    if(collapse>0){a=chosen?1:intensity*0.92;sc=chosen?1+0.10*collapse:1-0.3*collapse;}
    a=Math.max(0,a);
    ctx.save();ctx.globalAlpha=a;
    ctx.strokeStyle='rgba(205,194,255,0.32)';ctx.lineWidth=1.1;
    ctx.beginPath();ctx.moveTo(x0,row.y);ctx.lineTo(x0+(M-1)*cdx,row.y);ctx.stroke();
    for(let m=0;m<M;m++) drawCell(shapes[m], x0+m*cdx, row.y, r*sc, row.vals[m], chosen, intensity);
    ctx.restore();
  });
}

const TOF_SHAPES=['triangle','square','circle'], TOF_LEGEND='▲■ controls  ● target';
const S4={
  tag:'4 · Toffoli gate', tagColor:'var(--elec)',
  subtitle:'Three qubits. The target flips only when BOTH controls are 1 — and each can be a cloud.',
  capTitle:'<b class="elec">Toffoli</b>: flip the target only if <b class="warm">both</b> controls are 1.',
  capSub:'It is an <b class="elec">AND</b>-controlled flip: the <b>target ●</b> crosses only when the <b>triangle ▲</b> and <b>square ■</b> are both <b class="warm">1</b>. Put the controls in a <b class="mist">cloud</b> and the gate writes that AND into the target, entangling all three. Superpose only the target and nothing links up — just a bigger superposition.',
  c1:1, c2:1, tin:0, b1:null, b2:null, b3:null, l1:null, l2:null, l3:null, _sync:null,
  sup:null, mist:false, collapse:0, measured:null,
  setReadout(t){ $('#readout').innerHTML=t; },
  active(){ return this.c1===1 && this.c2===1; },
  quantum(){ return this.c1===2||this.c2===2||this.tin===2; },
  configList(){
    const av=this.c1===2?[1,0]:[this.c1], bv=this.c2===2?[1,0]:[this.c2], tvv=this.tin===2?[1,0]:[this.tin];
    const out=[]; av.forEach(a=>bv.forEach(b=>tvv.forEach(t=>out.push([a,b,t^(a&b)]))));
    out.sort((p,q)=> q[0]-p[0] || q[1]-p[1] || q[2]-p[2]);
    return out;
  },
  entangled(){
    const cfg=this.configList(), proj=[new Set(),new Set(),new Set()];
    cfg.forEach(c=>c.forEach((v,i)=>proj[i].add(v)));
    return cfg.length !== proj[0].size*proj[1].size*proj[2].size;
  },
  buildControls(el){
    el.innerHTML='';const self=this;
    const cyc=p=>()=>{self[p]=(self[p]+1)%3;self._sync();self.reset();};
    const cA=mkbtn('','',cyc('c1')), cB=mkbtn('','',cyc('c2')), tB=mkbtn('','',cyc('tin'));
    el.append(cA,cB,tB,mkbtn('Run ⚡','',()=>self.run()),mkbtn('Measure','',()=>self.measure()),mkbtn('↻','',()=>self.reset()));
    const lab=(sym,s)=>sym+' '+(s===2?'◐':(s?'1':'0')), cls=s=>'stepbtn '+(s===2?'mist':(s?'up':'dn'));
    this._sync=function(){
      cA.textContent=lab('▲',self.c1);cA.className=cls(self.c1);
      cB.textContent=lab('■',self.c2);cB.className=cls(self.c2);
      tB.textContent=lab('●',self.tin);tB.className=cls(self.tin);
    };this._sync();
  },
  reset(){ this.b1=this.b2=this.b3=null;this.l1=this.l2=this.l3=null;this.sup=null;this.mist=false;this.collapse=0;this.measured=null;
    this.setReadout(this.quantum()
      ? 'At least one qubit is a <b class="m">cloud</b>. Press <b>Run</b>, then <b>Measure</b>.'
      : 'Set the two <b class="e">controls</b> (▲ ■) and the <b class="w">target</b> (●), then press <b>Run</b>.'); },
  measure(){ if(!this.mist||this.collapse>0)return; this.measured=Math.floor(Math.random()*this.configList().length); this.collapse=0.0001; this.setReadout('Measuring&hellip;'); },
  run(){
    this.measured=null;this.collapse=0;this.mist=false;
    if(this.quantum()){ this.b1=this.b2=this.b3=null;this.l1=this.l2=this.l3=null;this.sup={t:0};this.setReadout('Running all branches&hellip;');return; }
    this.l1=this.l2=this.l3=null;const act=this.active(),tout=act?(1-this.tin):this.tin;
    this.b1={x:G.sx,y:G.t3a,sy:(this.c1?G.a1T:G.a1B),vin:this.c1,cy:G.t3a,phase:'toSlit'};
    this.b2={x:G.sx,y:G.t3b,sy:(this.c2?G.a2T:G.a2B),vin:this.c2,cy:G.t3b,phase:'toSlit'};
    this.b3={x:G.sx,y:G.t3c,syIn:(this.tin?G.a3T:G.a3B),syOut:(tout?G.a3T:G.a3B),vin:this.tin,vout:tout,cy:G.t3c,phase:'toSlit'};
    this.setReadout('Running&hellip;');
  },
  _result(){
    if(this.b1||this.b2||this.b3)return;
    if(this.l1==null&&this.l2==null&&this.l3==null)return;
    const tout=this.l3;
    this.setReadout('controls <b class="'+(this.l1?'w':'c')+'">'+this.l1+'</b> <b class="'+(this.l2?'w':'c')+'">'+this.l2+'</b> (unchanged) &nbsp;·&nbsp; target <b class="'+(this.tin?'w':'c')+'">'+this.tin+'</b> &rarr; <b class="e">Toffoli</b> &rarr; <b class="'+(tout?'w':'c')+'">'+tout+'</b>');
  },
  step(dt){
    if(this.sup){ this.sup.t+=dt*0.5; if(this.sup.t>=1){ this.sup=null; this.mist=true;
      const cfgs=this.configList(), ent=this.entangled();
      const list=cfgs.map(c=>'▲'+c[0]+'■'+c[1]+'●'+c[2]).join(' &nbsp;|&nbsp; ');
      this.setReadout((ent?'<b class="m">Entangled!</b> ':'<b class="m">Superposition.</b> ')+'Cloud of '+cfgs.length+': '+list+'. <b>Measure</b> to collapse.'); } }
    if(this.collapse>0 && this.collapse<1){ this.collapse=Math.min(1,this.collapse+dt*1.6);
      if(this.collapse>=1){ const cfgs=this.configList(), c=cfgs[this.measured]||cfgs[0], ent=this.entangled();
        this.setReadout('Measured ▲<b class="'+(c[0]?'w':'c')+'">'+c[0]+'</b> ■<b class="'+(c[1]?'w':'c')+'">'+c[1]+'</b> ●<b class="'+(c[2]?'w':'c')+'">'+c[2]+'</b>'+(ent?' — one measurement fixed all three. <b class="m">Entanglement</b>.':'.')); } }
    const vx=W*0.42*dt;
    const moveStraight=(b,set)=>{
      if(b.phase==='toSlit'){const dx=G.bx-G.sx,dy=b.sy-b.cy,L=Math.hypot(dx,dy)||1;b.x+=dx/L*vx;b.y+=dy/L*vx;if(b.x>=G.bx){b.x=G.bx;b.y=b.sy;b.phase='lane';}return false;}
      b.x+=vx;b.y=b.sy;if(b.x>=G.rx){set(b.vin);return true;}return false;
    };
    if(this.b1&&moveStraight(this.b1,v=>this.l1=v)){this.b1=null;this._result();}
    if(this.b2&&moveStraight(this.b2,v=>this.l2=v)){this.b2=null;this._result();}
    const b=this.b3;
    if(b){
      if(b.phase==='toSlit'){const dx=G.bx-G.sx,dy=b.syIn-b.cy,L=Math.hypot(dx,dy)||1;b.x+=dx/L*vx;b.y+=dy/L*vx;if(b.x>=G.bx){b.x=G.bx;b.y=b.syIn;b.phase='lane';}}
      else{b.x+=vx;b.y=crossYabs(b.x,b.syIn,b.syOut);if(b.x>=G.rx){this.l3=b.vout;this.b3=null;this._result();}}
    }
  },
  drawLinks(){
    const x=G.gateX, boxTop=G.a3T-Math.max(26,(G.a3B-G.a3T)*0.34);
    const anySup=this.c1===2||this.c2===2, bothOne=this.c1===1&&this.c2===1;
    ctx.save();ctx.lineWidth=2.5;ctx.lineCap='round';
    ctx.strokeStyle=anySup?C.mist:(bothOne?C.elec:'#7CFFB244');
    if(bothOne){ctx.shadowColor=C.elec;ctx.shadowBlur=8;}
    ctx.beginPath();ctx.moveTo(x,Math.min(G.a1T,G.a2T));ctx.lineTo(x,boxTop);ctx.stroke();ctx.restore();
    [[G.a1T,this.c1],[G.a2T,this.c2]].forEach(d=>{const s=d[1],col=s===2?C.mist:(s===1?C.elec:'#7CFFB2');
      ctx.save();ctx.beginPath();ctx.arc(x,d[0],6,0,7);
      ctx.globalAlpha=s===0?0.3:0.9;if(s!==0){ctx.shadowColor=col;ctx.shadowBlur=6;}
      ctx.fillStyle=s===0?'#0c101e':col;ctx.fill();
      ctx.globalAlpha=0.95;ctx.lineWidth=2;ctx.strokeStyle=col;ctx.stroke();ctx.restore();});
  },
  drawQuantum(){
    drawChannelLanes([{yT:G.a1T,yB:G.a1B,gated:false},{yT:G.a2T,yB:G.a2B,gated:false},{yT:G.a3T,yB:G.a3B,gated:true}]);
    const cfgs=this.configList(), ent=this.entangled();
    if(this.mist||this.collapse>0){ const inten=this.collapse>0?(1-this.collapse):1;
      drawConfigCloud(cfgs,TOF_SHAPES,this.measured,this.collapse,inten,ent,TOF_LEGEND); }
    const canFlip=(this.c1!==0)&&(this.c2!==0);
    drawGateBox(G.a3T,G.a3B,canFlip,'NOT');
    this.drawLinks();
    drawBarrierMulti([{y:G.a1T,color:C.warm,lab:'1'},{y:G.a1B,color:C.cool,lab:'0'},
                      {y:G.a2T,color:C.warm,lab:'1'},{y:G.a2B,color:C.cool,lab:'0'},
                      {y:G.a3T,color:C.warm,lab:'1'},{y:G.a3B,color:C.cool,lab:'0'}],G.sH3);
    drawCannonAt(G.t3a,'triangle',this.c1===2?C.mist:colOf(this.c1));
    drawCannonAt(G.t3b,'square',this.c2===2?C.mist:colOf(this.c2));
    drawCannonAt(G.t3c,'circle',this.tin===2?C.mist:colOf(this.tin));
    ctx.font='11px Cabin,Inter,system-ui';ctx.fillStyle=C.muted;ctx.textAlign='center';
    ctx.fillText('control',G.sx,G.a1T-12);ctx.fillText('control',G.sx,G.a2T-12);ctx.fillText('target',G.sx,G.a3B+18);
    if(this.sup){
      const t=this.sup.t, coreR=Math.max(4,H*0.010), startR=Math.max(4,H*0.011), spanRy=G.gap3/2+G.sH3;
      const c1S=this.c1===2,c2S=this.c2===2,tS=this.tin===2,gateL=G.gateX-G.cw;
      const av=c1S?[1,0]:[this.c1], bv=c2S?[1,0]:[this.c2], tv=tS?[1,0]:[this.tin];
      const alwaysFlip=(this.c1===1)&&(this.c2===1), canFlip2=(this.c1!==0)&&(this.c2!==0);
      const crisp=(px,py,col,al)=>{ctx.save();ctx.globalAlpha=al;ctx.shadowColor=col;ctx.shadowBlur=13;ctx.beginPath();ctx.arc(px,py,Math.max(4,H*0.010),0,7);ctx.fillStyle=col;ctx.fill();ctx.restore();};
      const fuzz=(px,py,col,al)=>{ctx.save();ctx.globalAlpha=al;blob(px,py,coreR*1.7,coreR*1.7,col);ctx.restore();};
      if(t<0.30){
        const u=t/0.30, px=lerp(G.sx,G.bx,u), gr=Math.max(6,H*0.015);
        if(c1S) blob(px,G.t3a,lerp(startR,gr,u),lerp(startR,spanRy,u),C.mist); else crisp(px,lerp(G.t3a,this.c1?G.a1T:G.a1B,u),colOf(this.c1),1);
        if(c2S) blob(px,G.t3b,lerp(startR,gr,u),lerp(startR,spanRy,u),C.mist); else crisp(px,lerp(G.t3b,this.c2?G.a2T:G.a2B,u),colOf(this.c2),1);
        if(tS)  blob(px,G.t3c,lerp(startR,gr,u),lerp(startR,spanRy,u),C.mist); else crisp(px,lerp(G.t3c,this.tin?G.a3T:G.a3B,u),colOf(this.tin),1);
      } else {
        const u=(t-0.30)/0.70, x=lerp(G.bx,G.rx,u);
        const xc=G.rx-(G.rx-G.bx)*0.16, k=x>xc?(x-xc)/(G.rx-xc):0, a=1-k;
        av.forEach(v=>{const y=v?G.a1T:G.a1B; c1S?fuzz(x,y,colOf(v),a):crisp(x,y,colOf(v),a);});
        bv.forEach(v=>{const y=v?G.a2T:G.a2B; c2S?fuzz(x,y,colOf(v),a):crisp(x,y,colOf(v),a);});
        if(x<=gateL){ tv.forEach(v=>{const y=v?G.a3T:G.a3B; tS?fuzz(x,y,colOf(v),a):crisp(x,y,colOf(v),a);}); }
        else if(alwaysFlip){ tv.forEach(v=>{const lv=1-v,y=crossYabs(x,v?G.a3T:G.a3B,lv?G.a3T:G.a3B),val=x<G.gateX?v:lv; tS?fuzz(x,y,colOf(val),a):crisp(x,y,colOf(val),a);}); }
        else if(canFlip2){ tv.forEach(v=>{const sy=v?G.a3T:G.a3B; fuzz(x,sy,colOf(v),a*0.92);
          const ly=(1-v)?G.a3T:G.a3B, yc=crossYabs(x,sy,ly), val=x<G.gateX?v:1-v; fuzz(x,yc,colOf(val),a*0.92);}); }
        else { tv.forEach(v=>{const y=v?G.a3T:G.a3B; tS?fuzz(x,y,colOf(v),a):crisp(x,y,colOf(v),a);}); }
        if(k>0) drawConfigCloud(cfgs,TOF_SHAPES,null,0,k,ent,TOF_LEGEND);
      }
    }
  },
  draw(){
    clearBG();
    if(this.quantum()){ this.drawQuantum(); return; }
    drawChannelLanes([{yT:G.a1T,yB:G.a1B,gated:false},{yT:G.a2T,yB:G.a2B,gated:false},{yT:G.a3T,yB:G.a3B,gated:true}]);
    drawReadoutPair(G.a1T,G.a1B,this.l1,'triangle');
    drawReadoutPair(G.a2T,G.a2B,this.l2,'square');
    drawReadoutPair(G.a3T,G.a3B,this.l3,'circle');
    drawGateBox(G.a3T,G.a3B,this.active(),'NOT');
    const boxTop=G.a3T-Math.max(26,(G.a3B-G.a3T)*0.34);
    drawControlLinks([G.a1T,G.a2T],[this.c1===1,this.c2===1],this.active(),boxTop);
    drawBarrierMulti([{y:G.a1T,color:C.warm,lab:'1'},{y:G.a1B,color:C.cool,lab:'0'},
                      {y:G.a2T,color:C.warm,lab:'1'},{y:G.a2B,color:C.cool,lab:'0'},
                      {y:G.a3T,color:C.warm,lab:'1'},{y:G.a3B,color:C.cool,lab:'0'}],G.sH3);
    drawCannonAt(G.t3a,'triangle',colOf(this.c1));drawCannonAt(G.t3b,'square',colOf(this.c2));drawCannonAt(G.t3c,'circle',colOf(this.tin));
    ctx.font='11px Cabin,Inter,system-ui';ctx.fillStyle=C.muted;ctx.textAlign='center';
    ctx.fillText('control',G.sx,G.a1T-12);ctx.fillText('control',G.sx,G.a2T-12);
    ctx.fillText('target',G.sx,G.a3B+18);
    const drawB=(b,vb,va)=>{const v=b.x<G.gateX?vb:va,col=colOf(v);
      ctx.save();ctx.shadowColor=col;ctx.shadowBlur=14;ctx.beginPath();
      ctx.arc(b.x,b.y,Math.max(5,H*0.011),0,7);ctx.fillStyle=col;ctx.fill();ctx.restore();};
    if(this.b1)drawB(this.b1,this.c1,this.c1);
    if(this.b2)drawB(this.b2,this.c2,this.c2);
    if(this.b3)drawB(this.b3,this.tin,this.b3.vout);
  },
  onEnter(){ this.buildControls($('#sctrl')); this.reset(); },
  onLeave(){ this.b1=this.b2=this.b3=null;this.sup=null; },
};

/* =========================================================================
   SCENE 5 — THE 2-BIT ADDER: six bits, a switchyard of 3 Toffoli + 3 CNOT
   wires: 0:a0 1:b0 2:c1(=0) 3:a1 4:b1 5:c2(=0)   outputs s0=b0 s1=b1 s2=c2
   ========================================================================= */
/* the parallel result: a cloud of every A+B sum (adder, quantum mode) */
function drawSumCloud(probs, measured, collapse, intensity){
  const N=probs.length, xr=W*0.86, cyMid=G.cy;
  const rowSep = N>1 ? Math.min(H*0.085,(H*0.60)/N) : 0;
  const fs = Math.max(10, Math.min(15, N>1?rowSep*0.62:15));
  const totalH=(N-1)*rowSep;
  const rows=probs.map((p,i)=>({p,y:cyMid-totalH/2+i*rowSep}));
  const crx=Math.max(50,W*0.064), cry=totalH/2+fs+16;
  intensity=Math.max(0,Math.min(1,intensity));
  if(intensity>0.002){
    ctx.save();ctx.globalAlpha=intensity;
    const R=Math.max(crx,cry);
    const grd=ctx.createRadialGradient(xr,cyMid,fs,xr,cyMid,R*1.05);
    grd.addColorStop(0,'rgba(198,184,255,0.30)');grd.addColorStop(0.6,'rgba(180,164,255,0.15)');grd.addColorStop(1,'rgba(180,164,255,0)');
    ctx.shadowColor='rgba(185,168,255,0.5)';ctx.shadowBlur=22;
    cloudPath(xr,cyMid,crx,cry);ctx.fillStyle=grd;ctx.fill();
    ctx.shadowBlur=0;cloudPath(xr,cyMid,crx*0.96,cry*0.96);ctx.fillStyle=grd;ctx.fill();
    ctx.restore();
    if(N>1){ctx.save();ctx.globalAlpha=intensity*0.6;ctx.strokeStyle='rgba(205,194,255,0.5)';ctx.lineWidth=1;
      for(let i=1;i<N;i++){const by=(rows[i-1].y+rows[i].y)/2;ctx.beginPath();ctx.moveTo(xr-crx*0.6,by);ctx.lineTo(xr+crx*0.6,by);ctx.stroke();}ctx.restore();}
  }
  ctx.font='700 '+fs+'px Cabin,Inter,system-ui';ctx.textBaseline='middle';
  rows.forEach((row,idx)=>{
    const chosen=measured===idx; let a=intensity*0.95;
    if(collapse>0) a=chosen?1:intensity*0.95;
    a=Math.max(0,a);
    const p=row.p, lhs=p.a+' + '+p.b+' ', rhs='= '+p.s;
    ctx.textAlign='left';
    const wl=ctx.measureText(lhs).width, wr=ctx.measureText(rhs).width, sx=xr-(wl+wr)/2;
    ctx.globalAlpha=a; ctx.fillStyle='#dfe5ff'; ctx.fillText(lhs,sx,row.y);
    ctx.globalAlpha=Math.max(a,chosen?1:a); ctx.fillStyle=chosen?'#bff0d0':C.elec; ctx.fillText(rhs,sx+wl,row.y);
  });
  ctx.globalAlpha=1; ctx.textBaseline='alphabetic';
}
/* explicit output state (few branches): the FULL six-qubit output register.
   The adder is reversible — six wires in, six out. Shape marks each wire's
   register (▲ A-bits, ■ B-bits, ● carry-bits); after the adder the B-bits hold
   s0,s1 and the top carry holds s2, while c1 is a leftover ("garbage") carry. */
const REG_SHAPES=['diamond','circle','pentagon','hexagon','square','triangle']; // one per wire
const REG_LABELS=['a0','s0','c1','a1','s1','s2'];
const REG_SUM=[1,4,5]; // the answer wires: s0, s1, s2
function drawRegStateCloud(items, measured, collapse, intensity){
  const N=items.length, M=6, xr=W*0.855, cyMid=G.cy;
  const r=Math.max(8,H*0.016), cdx=r*2.05;
  const rowSep=N>1?Math.max(3.4*r,H*0.11):0;
  const totalH=(N-1)*rowSep;
  const labW=Math.max(32,W*0.034), gap=9, decW=Math.max(30,W*0.03), cellsW=(M-1)*cdx;
  const blockW=labW+gap+cellsW+gap+decW, x0=xr-blockW/2;
  const labRX=x0+labW, c0x=x0+labW+gap, decX=c0x+cellsW+gap+r;
  const rows=items.map((it,i)=>({it,y:cyMid-totalH/2+i*rowSep}));
  const crx=blockW/2+16, cry=totalH/2+r+30;
  intensity=Math.max(0,Math.min(1,intensity));
  if(intensity>0.002){
    ctx.save();ctx.globalAlpha=intensity;
    const R=Math.max(crx,cry);
    const grd=ctx.createRadialGradient(xr,cyMid,r*0.4,xr,cyMid,R*1.05);
    grd.addColorStop(0,'rgba(198,184,255,0.30)');grd.addColorStop(0.6,'rgba(180,164,255,0.15)');grd.addColorStop(1,'rgba(180,164,255,0)');
    ctx.shadowColor='rgba(185,168,255,0.5)';ctx.shadowBlur=22;
    cloudPath(xr,cyMid,crx,cry);ctx.fillStyle=grd;ctx.fill();
    ctx.shadowBlur=0;cloudPath(xr,cyMid,crx*0.96,cry*0.96);ctx.fillStyle=grd;ctx.fill();
    ctx.restore();
    if(N>1){ctx.save();ctx.globalAlpha=intensity*0.75;ctx.strokeStyle='rgba(205,194,255,0.6)';ctx.lineWidth=1.3;
      for(let i=1;i<N;i++){const by=(rows[i-1].y+rows[i].y)/2;ctx.beginPath();ctx.moveTo(xr-crx*0.62,by);ctx.lineTo(xr+crx*0.62,by);ctx.stroke();}ctx.restore();}
    ctx.save();ctx.globalAlpha=intensity*0.9;ctx.textAlign='center';ctx.font='600 9px Cabin,Inter,system-ui';
    for(let m=0;m<M;m++){ ctx.fillStyle=(m===1||m===4||m===5)?C.elec:C.muted; ctx.fillText(REG_LABELS[m], c0x+m*cdx, rows[0].y-r-7); }
    ctx.restore();
  }
  ctx.textBaseline='middle';
  rows.forEach((row,idx)=>{
    const it=row.it, chosen=measured===idx; let a=intensity*0.95, sc=1;
    if(collapse>0){a=chosen?1:intensity*0.95;sc=chosen?1+0.08*collapse:1-0.3*collapse;}
    a=Math.max(0,a);
    ctx.save();ctx.globalAlpha=a;ctx.textAlign='right';ctx.font='600 11px Cabin,Inter,system-ui';ctx.fillStyle='#c9d1f5';
    ctx.fillText(it.A+'+'+it.B, labRX, row.y);ctx.restore();
    ctx.save();ctx.globalAlpha=chosen?1:a;
    for(let m=0;m<M;m++){ const isSum=REG_SUM.indexOf(m)>=0, cr=(r*sc)*(isSum?1:0.5);
      drawCell(REG_SHAPES[m], c0x+m*cdx, row.y, cr, it.wires[m], chosen, intensity); }
    ctx.restore();
    ctx.save();ctx.globalAlpha=chosen?1:a;ctx.textAlign='left';ctx.font='800 13px Cabin,Inter,system-ui';
    ctx.fillStyle=chosen?'#bff0d0':C.elec;ctx.fillText('= '+it.s, decX, row.y);ctx.restore();
  });
  ctx.textBaseline='alphabetic';
}
const ADD_CSUB='Chain the gates into a machine that adds two 2-bit numbers.';
const ADD_QSUB='Feed the adder a superposition of inputs and it computes every sum at once.';
const ADD_QCAP={
  t:'One run, <b class="mist">every sum at once</b>.',
  s:'Put the inputs in a <b class="mist">cloud</b> of all values and the same six-gate adder computes <b class="warm">A</b>+<b class="cool">B</b> for <b>every</b> pair simultaneously &mdash; the output is a <b class="mist">cloud of sums</b>. That parallel power is the heart of quantum computing. The catch: <b class="warn">measuring</b> collapses the cloud to just <b>one</b> random sum, so a real quantum algorithm must first steer the useful answer to the top.'
};
const S5={
  tag:'5 · 2-bit adder', tagColor:'var(--elec)',
  subtitle:'Chain the gates into a machine that adds two 2-bit numbers.',
  capTitle:'The whole <b class="elec">adder</b>: gates chained into a switchyard.',
  capSub:'Six bits flow left&rarr;right &mdash; the numbers <b class="warm">A</b> and <b class="cool">B</b> plus two blank <b>carry</b> bits. Three Toffolis and three CNOTs route the balls so the output lanes spell <b class="e">A + B</b>. Count them: six balls in, six out &mdash; still reversible.',
  A:2, B:1, stage:0, prog:0, running:false, landed:null, sim:null, _sync:null,
  labels:['a0','b0','c1','a1','b1','c2'],
  gates:[{c:[0,1],tg:2},{c:[0],tg:1},{c:[3,4],tg:5},{c:[3],tg:4},{c:[2,4],tg:5},{c:[2],tg:4}],
  STAGE:[
    {t:'The workspace: six bits, no gates yet.',
     s:'<b class="warm">a0, a1</b> are the bits of number <b class="warm">A</b>; <b class="cool">b0, b1</b> are number <b class="cool">B</b>; <b>c1, c2</b> are blank <b>carry</b> bits (start at 0). Fire &mdash; each ball flies straight to its readout. Nothing is added yet.'},
    {t:'Ones column &mdash; write the carry.',
     s:'The first <b class="elec">Toffoli</b> sets c1 = a0 AND b0: the carry out of the ones column.'},
    {t:'Ones column &mdash; write the sum (half adder done).',
     s:'A <b class="elec">CNOT</b> turns b0 into a0 XOR b0 = <b class="elec">s0</b>. Try <b class="warm">1</b>+<b class="warm">1</b>: sum 0, carry 1.'},
    {t:'Twos column &mdash; write its carry.',
     s:'A second <b class="elec">Toffoli</b> sets c2 = a1 AND b1.'},
    {t:'Twos column &mdash; partial sum.',
     s:'A <b class="elec">CNOT</b> folds a1 into b1 (a1 XOR b1) &mdash; not finished until the carry arrives.'},
    {t:'Carry the 1 &mdash; into the twos column.',
     s:'A <b class="elec">Toffoli</b> adds the ones-column carry c1 into c2 (when b1 is set).'},
    {t:'Final sum bit &mdash; the adder is complete.',
     s:'The last <b class="elec">CNOT</b> folds c1 into b1 = <b class="elec">s1</b>. Output lanes now spell <b class="elec">A + B</b>. Six balls in, six out.'}
  ],
  setStage(s){
    this.stage=s;
    this.prog=0;this.running=false;this.landed=null;this.simulate();
    this.setReadout(s===0?'Set <b class="w">A</b> and <b class="c">B</b>, then <b>Run</b> the six straight shots.':'Press <b>Run</b> to fire through the '+s+' gate'+(s>1?'s':'')+' built so far.');
    if(this._sync)this._sync();
  },
  setReadout(t){ $('#readout').innerHTML=t; },
  qrun:false, qprog:0, qmist:false, qcollapse:0, qmeasured:null,
  quantum(){ return this.A>=4 || this.B>=4; },
  Aset(){ return this.A<4?[this.A]:(this.A===4?[2,3]:[0,1,2,3]); },
  Bset(){ return this.B<4?[this.B]:[0,1,2,3]; },
  configs(){ const out=[]; this.Aset().forEach(a=>this.Bset().forEach(b=>out.push({A:a,B:b}))); return out; },
  explicit(){ return this.quantum() && this.configs().length<=4; },
  problems(){ return this.configs().map(c=>({a:c.A,b:c.B,s:c.A+c.B})); },
  simAt(A,B){ const a0=A&1,a1=(A>>1)&1,b0=B&1,b1=(B>>1)&1;
    const inVals=[a0,b0,0,a1,b1,0], vals=inVals.slice(), events=[[],[],[],[],[],[]],gact=[],gctrl=[];
    this.gates.forEach((g,gi)=>{const cvals=g.c.map(ci=>vals[ci]);gctrl.push(cvals);const active=cvals.every(v=>v===1);gact.push(active);
      if(active){const t=g.tg;events[t].push({x:G.adGX[gi],to:1-vals[t]});vals[t]^=1;}});
    return {inVals,outVals:vals,events,gact,gctrl}; },
  laneYFor(sim,i,x){ const w=2*G.adGW;let v=sim.inVals[i];
    for(const e of sim.events[i]){ if(x>=e.x+w/2){v=e.to;continue;} if(x>e.x-w/2){const t=(x-(e.x-w/2))/w;return lerp(this.bitLane(i,v),this.bitLane(i,e.to),t);} return this.bitLane(i,v);} return this.bitLane(i,v); },
  valAtFor(sim,i,x){ let v=sim.inVals[i];for(const e of sim.events[i]){if(x>=e.x)v=e.to;else break;}return v; },
  setCap(t,s){ this.capTitle=t;this.capSub=s; },
  qreset(){ this.qrun=false;this.qprog=0;this.qmist=false;this.qcollapse=0;this.qmeasured=null;
    this.setReadout('Inputs are a <b class="m">cloud</b>. Press <b>Run</b> to add them all at once, then <b>Measure</b>.'); },
  afterSet(){
    const panel=$('#panel');
    if(this.quantum()){
      panel.classList.remove('wsmode');
      $('#wsheet').classList.remove('show');
      this.stage=6; this.qreset();
      this.subtitle=ADD_QSUB; $('#subtitle').innerHTML=ADD_QSUB; this.setCap(ADD_QCAP.t,ADD_QCAP.s);
    } else {
      panel.classList.add('wsmode');
      $('#wsheet').classList.add('show');
      this.subtitle=ADD_CSUB; $('#subtitle').innerHTML=ADD_CSUB;
      this.setStage(this.stage);
    }
  },
  measure(){ if(!this.qmist||this.qcollapse>0)return; this.qmeasured=Math.floor(Math.random()*this.problems().length); this.qcollapse=0.0001; this.setReadout('Measuring&hellip;'); },
  bitLane(i,v){ return v?(G.adCy[i]-G.adLG/2):(G.adCy[i]+G.adLG/2); },
  simulate(){
    const A=this.A,B=this.B,a0=A&1,a1=(A>>1)&1,b0=B&1,b1=(B>>1)&1;
    const inVals=[a0,b0,0,a1,b1,0], vals=inVals.slice();
    const events=[[],[],[],[],[],[]],gact=[],gctrl=[],ng=this.stage;
    this.gates.forEach((g,gi)=>{
      if(gi>=ng){gact.push(false);gctrl.push(g.c.map(()=>0));return;}
      const cvals=g.c.map(ci=>vals[ci]);gctrl.push(cvals);
      const active=cvals.every(v=>v===1);gact.push(active);
      if(active){const t=g.tg;events[t].push({x:G.adGX[gi],to:1-vals[t]});vals[t]^=1;}
    });
    this.sim={inVals,outVals:vals,events,gact,gctrl};
  },
  laneY(i,x){
    const w=2*G.adGW;let v=this.sim.inVals[i];
    for(const e of this.sim.events[i]){
      if(x>=e.x+w/2){v=e.to;continue;}
      if(x>e.x-w/2){const t=(x-(e.x-w/2))/w;return lerp(this.bitLane(i,v),this.bitLane(i,e.to),t);}
      return this.bitLane(i,v);
    }
    return this.bitLane(i,v);
  },
  valAt(i,x){let v=this.sim.inVals[i];for(const e of this.sim.events[i]){if(x>=e.x)v=e.to;else break;}return v;},
  buildControls(el){
    el.innerHTML='';const self=this;
    const aB=mkbtn('','up',()=>{self.A=(self.A+1)%6;self._sync();self.afterSet();});
    const bB=mkbtn('','dn',()=>{self.B=(self.B+1)%5;self._sync();self.afterSet();});
    const buildB=mkbtn('','',()=>{ if(self.quantum())return; self.setStage((self.stage+1)%7); });
    el.append(aB,bB,buildB,mkbtn('Run ⚡','',()=>self.run()),mkbtn('Measure','',()=>self.measure()),mkbtn('↻','',()=>self.reset()));
    this._sync=()=>{
      aB.textContent='A = '+(self.A<4?self.A:(self.A===4?'{2,3}':'★ all')); aB.className='stepbtn '+(self.A>=4?'mist':'up');
      bB.textContent='B = '+(self.B<4?self.B:'★ all'); bB.className='stepbtn '+(self.B>=4?'mist':'dn');
      buildB.textContent='Build ▶ '+self.stage+'/6'; buildB.style.opacity=self.quantum()?0.4:1;
    };this._sync();
  },
  reset(){ if(this.quantum()){ this.qreset(); return; }
    this.prog=0;this.running=false;this.landed=null;this.simulate();
    this.setReadout(this.stage===0?'Set <b class="w">A</b> and <b class="c">B</b>, then <b>Run</b> the six straight shots.':'Press <b>Run</b> to fire through the '+this.stage+' gate'+(this.stage>1?'s':'')+' built so far.'); },
  run(){ if(this.quantum()){ this.qrun=true;this.qprog=0;this.qmist=false;this.qcollapse=0;this.qmeasured=null;this.setReadout('Computing <b class="m">all sums</b> in parallel&hellip;'); return; }
    this.simulate();this.prog=0;this.running=true;this.landed=null;this.setReadout('Running&hellip;'); },
  step(dt){
    if(this.quantum()){
      if(this.qrun){ this.qprog+=dt*0.4; if(this.qprog>=1){ this.qprog=1;this.qrun=false;this.qmist=true;
        const P=this.problems(); this.setReadout('<b class="m">'+P.length+' sums at once</b> &mdash; '+P.map(p=>p.a+'+'+p.b+'='+p.s).join(', ')+'. <b class="warn">Measure</b> to collapse.'); } }
      if(this.qcollapse>0&&this.qcollapse<1){ this.qcollapse=Math.min(1,this.qcollapse+dt*1.6);
        if(this.qcollapse>=1){ const P=this.problems(), p=P[this.qmeasured]||P[0];
          this.setReadout('Collapsed to one: <b class="w">'+p.a+'</b> + <b class="c">'+p.b+'</b> = <b class="e">'+p.s+'</b> &mdash; just one random sum survives.'); } }
      return;
    }
    if(!this.running)return;
    this.prog+=dt*0.38;
    if(this.prog>=1){this.prog=1;this.running=false;this.landed=this.sim.outVals;
      const o=this.sim.outVals,s0=o[1],s1=o[4],s2=o[5];
      if(this.stage===0) this.setReadout('A = <b class="w">'+this.A+'</b>, B = <b class="c">'+this.B+'</b> &mdash; six straight shots, nothing added yet.');
      else if(this.stage===6) this.setReadout('<b class="w">'+this.A+'</b> + <b class="c">'+this.B+'</b> = <b class="e">'+(this.A+this.B)+'</b> &nbsp; (s&#8322;s&#8321;s&#8320; = '+s2+s1+s0+')');
      else this.setReadout('Built <b>'+this.stage+'/6</b> gates &mdash; partial result on the output lanes.');}
  },
  drawGate(g,gi){
    const x=G.adGX[gi],tg=g.tg,cy=G.adCy[tg],lg=G.adLG;
    const top=cy-lg/2,bot=cy+lg/2,gw=G.adGW,pad=Math.max(5,lg*0.32);
    const x0=x-gw,x1=x+gw,yT=top-pad,yB=bot+pad,active=this.sim.gact[gi];
    const ctrlYs=g.c.map(ci=>this.bitLane(ci,1)),cyMin=Math.min.apply(null,ctrlYs.concat([yT]));
    ctx.save();ctx.strokeStyle=active?C.elec:'#7CFFB244';ctx.lineWidth=2;if(active){ctx.shadowColor=C.elec;ctx.shadowBlur=6;}
    ctx.beginPath();ctx.moveTo(x,cyMin);ctx.lineTo(x,yT);ctx.stroke();ctx.restore();
    g.c.forEach((ci,k)=>{const cyD=this.bitLane(ci,1),on=this.sim.gctrl[gi][k]===1;
      ctx.save();ctx.beginPath();ctx.arc(x,cyD,5,0,7);if(on){ctx.shadowColor=C.elec;ctx.shadowBlur=6;}
      ctx.fillStyle=on?C.elec:'#0c101e';ctx.fill();ctx.lineWidth=2;ctx.strokeStyle=on?C.elec:'#7CFFB288';ctx.stroke();ctx.restore();});
    const r=6,L=Math.max(12,gw*0.95),m=Math.max(6,lg*0.18);
    const tT=top-m,tB=bot+m,mcy=(tT+tB)/2,mry=(tB-tT)/2,mxL=x0-L,mxR=x1+L;
    const sc=active?C.elec:'#7CFFB255';
    ctx.save();ctx.fillStyle='rgba(8,11,20,0.9)';
    ctx.fillRect(mxL,tT,x0-mxL,tB-tT);ctx.fillRect(x1,tT,mxR-x1,tB-tT);
    rrect(x0,yT,x1-x0,yB-yT,r);ctx.fill();ctx.restore();
    ctx.save();ctx.strokeStyle=sc;ctx.lineWidth=1.6;ctx.lineJoin='round';ctx.lineCap='round';
    if(active){ctx.shadowColor=C.elec;ctx.shadowBlur=5;}
    ctx.beginPath();ctx.moveTo(x0,tT);ctx.lineTo(x0,yT+r);ctx.arcTo(x0,yT,x0+r,yT,r);
    ctx.lineTo(x1-r,yT);ctx.arcTo(x1,yT,x1,yT+r,r);ctx.lineTo(x1,tT);ctx.stroke();
    ctx.beginPath();ctx.moveTo(x0,tB);ctx.lineTo(x0,yB-r);ctx.arcTo(x0,yB,x0+r,yB,r);
    ctx.lineTo(x1-r,yB);ctx.arcTo(x1,yB,x1,yB-r,r);ctx.lineTo(x1,tB);ctx.stroke();
    ctx.beginPath();
    ctx.moveTo(x0,tT);ctx.lineTo(mxL,tT);ctx.moveTo(x0,tB);ctx.lineTo(mxL,tB);
    ctx.moveTo(x1,tT);ctx.lineTo(mxR,tT);ctx.moveTo(x1,tB);ctx.lineTo(mxR,tB);ctx.stroke();
    ctx.beginPath();ctx.ellipse(mxL,mcy,5,mry,0,0,7);ctx.stroke();
    ctx.beginPath();ctx.ellipse(mxR,mcy,5,mry,0,0,7);ctx.stroke();
    ctx.restore();
    ctx.save();ctx.lineCap='round';
    if(active){ctx.strokeStyle=C.elec;ctx.lineWidth=2.5;
      ctx.beginPath();ctx.moveTo(x0,top);ctx.lineTo(x1,bot);ctx.stroke();
      ctx.beginPath();ctx.moveTo(x0,bot);ctx.lineTo(x1,top);ctx.stroke();}
    else{ctx.lineWidth=2;ctx.strokeStyle=C.warm+'aa';ctx.beginPath();ctx.moveTo(x0,top);ctx.lineTo(x1,top);ctx.stroke();
      ctx.strokeStyle=C.cool+'aa';ctx.beginPath();ctx.moveTo(x0,bot);ctx.lineTo(x1,bot);ctx.stroke();}
    ctx.restore();
  },
  drawQuantumAdder(){
    const cfgs=this.configs(), sims=cfgs.map(c=>this.simAt(c.A,c.B)), exp=this.explicit(), sx0=G.bx+G.bw/2;
    // merged sim so the gates show as "used by some branch"
    const gact=this.gates.map((g,gi)=>sims.some(s=>s.gact[gi]));
    const gctrl=this.gates.map((g,gi)=>g.c.map((ci,k)=>sims.some(s=>s.gctrl[gi][k]===1)?1:0));
    this.sim={inVals:sims[0].inVals,events:[[],[],[],[],[],[]],gact,gctrl};
    // machine backdrop (lanes + the six gates + barrier)
    ctx.save();ctx.globalAlpha=exp?0.7:0.45;ctx.setLineDash([4,7]);ctx.lineWidth=1.3;
    for(let i=0;i<6;i++){ctx.strokeStyle=C.warm+'22';ctx.beginPath();ctx.moveTo(sx0,this.bitLane(i,1));ctx.lineTo(G.rx,this.bitLane(i,1));ctx.stroke();
      ctx.strokeStyle=C.cool+'22';ctx.beginPath();ctx.moveTo(sx0,this.bitLane(i,0));ctx.lineTo(G.rx,this.bitLane(i,0));ctx.stroke();}
    ctx.setLineDash([]);ctx.restore();
    ctx.save();ctx.globalAlpha=exp?0.92:0.55;
    this.gates.forEach((g,gi)=>this.drawGate(g,gi));
    const slits=[];for(let i=0;i<6;i++){slits.push({y:this.bitLane(i,1),color:C.warm});slits.push({y:this.bitLane(i,0),color:C.cool});}
    drawBarrierMulti(slits,G.adSH);ctx.restore();
    // cannons: mist where the input wire differs across branches
    const wireMist=i=> new Set(sims.map(s=>s.inVals[i])).size>1;
    for(let i=0;i<6;i++) drawCannonAt(G.adCy[i],REG_SHAPES[i], wireMist(i)?C.mist:colOf(sims[0].inVals[i]));
    ctx.font='10px Cabin,Inter,system-ui';ctx.fillStyle=C.muted;ctx.textAlign='center';
    for(let i=0;i<6;i++) ctx.fillText(this.labels[i],G.sx,G.adCy[i]-G.adLG/2-7);
    // input register summary + explicit ket
    ctx.textAlign='left';ctx.font='600 13px Cabin,Inter,system-ui';
    ctx.fillStyle=this.A>=4?C.mist:C.warm; ctx.fillText('A = '+(this.A<4?this.A:(this.A===4?'{2,3}':'{0,1,2,3}')), 16, H*0.40);
    ctx.fillStyle=this.B>=4?C.mist:C.cool; ctx.fillText('B = '+(this.B<4?this.B:'{0,1,2,3}'), 16, H*0.40+18);
    if(exp){ ctx.fillStyle=C.mist;ctx.font='600 12px Cabin,Inter,system-ui';
      ctx.fillText('ψ = '+cfgs.map(c=>'|'+c.A+','+c.B+'⟩').join(' + '), 16, H*0.40+40); }
    if(exp){
      // RUN THE CIRCUIT EXPLICITLY. A wire that differs across branches is in a
      // superposition: it is SHOT as a mist fan (through both slits), and on the
      // lanes it shows fuzzy where branches diverge, crisp where they all agree.
      if(this.qrun){
        const coreR=Math.max(4,H*0.009), startR=Math.max(4,H*0.011), bigRx=Math.max(7,H*0.016);
        const crisp=(px,py,col)=>{ctx.save();ctx.shadowColor=col;ctx.shadowBlur=9;ctx.beginPath();ctx.arc(px,py,Math.max(4,H*0.0085),0,7);ctx.fillStyle=col;ctx.fill();ctx.restore();};
        const fuzz=(px,py,col)=>{ctx.save();ctx.globalAlpha=0.8;blob(px,py,coreR*1.6,coreR*1.6,col);ctx.restore();};
        if(this.qprog<0.18){
          const u=this.qprog/0.18, px=lerp(G.sx,G.bx,u);
          for(let i=0;i<6;i++){
            if(wireMist(i)){ const spanRy=(this.bitLane(i,0)-this.bitLane(i,1))/2+G.adSH;
              blob(px,G.adCy[i],lerp(startR,bigRx,u),lerp(startR,spanRy,u),C.mist); }
            else { const v=sims[0].inVals[i]; crisp(px,lerp(G.adCy[i],this.bitLane(i,v),u),colOf(v)); }
          }
        } else {
          const u=(this.qprog-0.18)/0.82, x=lerp(G.bx,G.rx,u);
          for(let i=0;i<6;i++){
            const m=new Map(); sims.forEach(s=>m.set(this.valAtFor(s,i,x), this.laneYFor(s,i,x)));
            const sup=m.size>1;
            m.forEach((y,v)=> sup?fuzz(x,y,colOf(v)):crisp(x,y,colOf(v)) );
          }
        }
      }
      // explicit output state written out: the FULL six-qubit output register
      const items=sims.map((s,ci)=>({A:cfgs[ci].A,B:cfgs[ci].B,s:cfgs[ci].A+cfgs[ci].B,wires:s.outVals.slice()}));
      if(this.qmist||this.qcollapse>0){ const inten=this.qcollapse>0?(1-this.qcollapse):1; drawRegStateCloud(items,this.qmeasured,this.qcollapse,inten); }
      else if(this.qrun && this.qprog>0.55){ const f=Math.min(1,(this.qprog-0.55)/0.45); drawRegStateCloud(items,null,0,f*0.9); }
    } else {
      // too many branches to draw individually: abstract parallel sweep + cloud of sums
      const P=this.problems();
      if(this.qrun){ const sweepX=lerp(G.bx,G.rx,this.qprog), top=this.bitLane(0,1)-18, bot=this.bitLane(5,0)+18;
        ctx.save();const grd=ctx.createLinearGradient(sweepX-46,0,sweepX+8,0);
        grd.addColorStop(0,'rgba(185,168,255,0)');grd.addColorStop(1,'rgba(185,168,255,0.45)');
        ctx.fillStyle=grd;ctx.fillRect(sweepX-46,top,54,bot-top);ctx.restore(); }
      if(this.qmist||this.qcollapse>0){ const inten=this.qcollapse>0?(1-this.qcollapse):1; drawSumCloud(P,this.qmeasured,this.qcollapse,inten); }
      else if(this.qrun && this.qprog>0.45){ const f=Math.min(1,(this.qprog-0.45)/0.45); drawSumCloud(P,null,0,f*0.9); }
    }
  },
  draw(){
    clearBG();
    if(this.quantum()){ this.drawQuantumAdder(); return; }
    const sx0=G.bx+G.bw/2, rr=Math.max(8,G.adLG*0.30);
    ctx.save();ctx.setLineDash([4,7]);ctx.lineWidth=1.3;
    for(let i=0;i<6;i++){
      ctx.strokeStyle=C.warm+'30';ctx.beginPath();ctx.moveTo(sx0,this.bitLane(i,1));ctx.lineTo(G.rx,this.bitLane(i,1));ctx.stroke();
      ctx.strokeStyle=C.cool+'30';ctx.beginPath();ctx.moveTo(sx0,this.bitLane(i,0));ctx.lineTo(G.rx,this.bitLane(i,0));ctx.stroke();
    }ctx.restore();
    for(let i=0;i<6;i++){
      [[1,C.warm],[0,C.cool]].forEach(p=>{const y=this.bitLane(i,p[0]),on=this.landed&&this.landed[i]===p[0];
        ctx.beginPath();ctx.arc(G.rx,y,rr,0,7);ctx.fillStyle=on?p[1]:'#0d1226';
        if(on){ctx.save();ctx.shadowColor=p[1];ctx.shadowBlur=14;ctx.fill();ctx.restore();}else ctx.fill();
        ctx.lineWidth=1.6;ctx.strokeStyle=p[1]+(on?'':'55');ctx.stroke();});
    }
    if(this.stage===6){ctx.font='800 12px Cabin,Inter,system-ui';ctx.fillStyle=C.elec;ctx.textAlign='left';
      [[1,'s0'],[4,'s1'],[5,'s2']].forEach(p=>ctx.fillText(p[1],G.rx+rr+7,G.adCy[p[0]]+4));}
    this.gates.forEach((g,gi)=>{if(gi<this.stage)this.drawGate(g,gi);});
    const slits=[];for(let i=0;i<6;i++){slits.push({y:this.bitLane(i,1),color:C.warm});slits.push({y:this.bitLane(i,0),color:C.cool});}
    drawBarrierMulti(slits,G.adSH);
    for(let i=0;i<6;i++) drawCannonAt(G.adCy[i],REG_SHAPES[i],colOf(this.sim.inVals[i]));
    ctx.font='10px Cabin,Inter,system-ui';ctx.fillStyle=C.muted;ctx.textAlign='center';
    for(let i=0;i<6;i++) ctx.fillText(this.labels[i],G.sx,G.adCy[i]-G.adLG/2-7);
    if(this.running||(this.prog>0&&this.prog<1)){
      for(let i=0;i<6;i++){
        let x,y,v;
        if(this.prog<0.18){const u=this.prog/0.18;x=lerp(G.sx,G.bx,u);y=lerp(G.adCy[i],this.bitLane(i,this.sim.inVals[i]),u);v=this.sim.inVals[i];}
        else{const u=(this.prog-0.18)/0.82;x=lerp(G.bx,G.rx,u);y=this.laneY(i,x);v=this.valAt(i,x);}
        const col=colOf(v);
        ctx.save();ctx.shadowColor=col;ctx.shadowBlur=12;ctx.beginPath();ctx.arc(x,y,Math.max(4,H*0.0095),0,7);ctx.fillStyle=col;ctx.fill();ctx.restore();
      }
    }
    this.updateSheet();
  },
  updateSheet(){
    const A=this.A,B=this.B,st=this.stage;
    const a0=A&1,a1=(A>>1)&1,b0=B&1,b1=(B>>1)&1;
    const s0=a0^b0,c1=a0&b0,tt=a1+b1+c1,s1=tt&1,c2=tt>>1,s2=c2;
    // reveal each digit as the ball-front passes the gate that computes it;
    // idle (just built / after a run) -> front at the readout, so all built digits show.
    const front=this.running?((this.prog<0.18)?G.bx:lerp(G.bx,G.rx,(this.prog-0.18)/0.82)):G.rx;
    const shown=gi=>(gi<st)&&(front>=G.adGX[gi]);
    const $=id=>root.querySelector('#'+id);
    const badge=$('wshBadge'); if(!badge) return; badge.textContent=st+'/6';
    const setd=(id,val,cls)=>{const e=$(id);if(e){e.textContent=val;e.className=cls||'';}};
    setd('wsA2',a1,'wa'); setd('wsA1',a0,'wa');
    setd('wsB2',b1,b1?'wa':'wz'); setd('wsB1',b0,b0?'wa':'wz');
    setd('wsC2',shown(0)?c1:''); setd('wsC4',shown(4)?c2:'');
    setd('wsS1',shown(1)?s0:'·',shown(1)?'':'wz');
    setd('wsS2',shown(5)?s1:'·',shown(5)?'':'wz');
    setd('wsS4',shown(5)?s2:'·',shown(5)?'':'wz');
  },
  onEnter(){ this.buildControls($('#sctrl')); if(!this.quantum()) this.stage=0; this.afterSet(); },
  onLeave(){ $('#panel').classList.remove('wsmode');$('#wsheet').classList.remove('show');this.running=false;this.prog=0;this.qrun=false; },
};

/* ----------------------------- scene manager ------------------------------ */
const scenes=[S1,S2,S3,S4,S5];
const labels=['Qubit','NOT','CNOT','Toffoli','Adder'];
let cur=0;

const els={
  subtitle:$('#subtitle'),
  tag:$('#tag'),
  prev:$('#prev'),
  next:$('#next'),
};
const dotsWrap=$('#dots');
const dotEls=labels.map((l,i)=>{
  const d=document.createElement('div');d.className='dot';
  d.innerHTML='<span class="pip"></span><span class="dl">'+l+'</span>';
  d.onclick=()=>go(i);dotsWrap.appendChild(d);return d;
});
function applySceneUI(s){
  els.subtitle.innerHTML=s.subtitle;
  els.tag.textContent=s.tag;els.tag.style.color=s.tagColor;els.tag.style.borderColor=s.tagColor+'55';
  dotEls.forEach((d,i)=>d.classList.toggle('active',i===cur));
  els.prev.disabled=cur===0;els.next.disabled=cur===scenes.length-1;
}
function go(i){
  i=Math.max(0,Math.min(scenes.length-1,i));
  if(i===cur){return;}
  scenes[cur].onLeave&&scenes[cur].onLeave();
  cur=i;
  scenes[cur].onEnter&&scenes[cur].onEnter();
  applySceneUI(scenes[cur]);
}
els.prev.onclick=()=>go(cur-1);
els.next.onclick=()=>go(cur+1);

/* ------------------------------- main loop -------------------------------- */
let last=performance.now();
function frame(now){
  const dt=Math.min(0.05,(now-last)/1000);last=now;
  scenes[cur].step(dt);
  scenes[cur].draw();
  requestAnimationFrame(frame);
}
resize();
scenes[0].onEnter();
applySceneUI(scenes[0]);
requestAnimationFrame(frame);
})();
</script>
"""

    HTML(_scene)
end

# ╔═╡ 1e31796d-5694-419a-9485-feaf6a8515b7
slide_button()

# ╔═╡ Cell order:
# ╟─09511395-916f-4106-be2e-3c16a37ec40b
# ╟─e519f227-38c6-4107-83e9-9d796e561afc
# ╟─c100d5b9-904e-4c3c-9700-294cf743fef7
# ╠═7b793d26-5ce7-4257-99f6-556fee67908c
# ╠═9c46d5dd-e463-46b7-915f-5c91fd48f659
# ╠═1e7fbf4b-5a2f-4382-8c44-843d386706b7
# ╠═fceb9b41-4f02-43d1-abda-8a869976377a
# ╠═07c68981-18b4-46ce-9e38-4940f734d348
# ╟─1e31796d-5694-419a-9485-feaf6a8515b7
