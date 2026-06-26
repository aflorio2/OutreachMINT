### A Pluto.jl notebook ###
# v0.20.16

using Markdown
using InteractiveUtils

# ╔═╡ 573d5a77-858c-4792-909b-c59fdd5080c4
begin
	import Pkg
	Pkg.develop(path=joinpath(@__DIR__, "MCPresPluto.jl"))
	using MCPresPluto, PlutoUI, Base64
	nothing
end

# ╔═╡ 5e06425f-6512-4e9c-b149-e9b3e3654ce2
slide_setup(
	author = "Adrien Florio",
	place = "MINT Sommer",
	date = "08.07.26",
	colour = :bleunuit
)

# ╔═╡ fad87406-e04b-4834-8d80-6819a2c7def4
blank_slide(let
	img = LocalResource(joinpath(@__DIR__, "imgs", "title-1.svg"))
	@htl("<div style=\"text-align:center\">$img</div>")
end)

# ╔═╡ ecff9498-0ef0-44a3-abc4-28a21a6fac19
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

# ╔═╡ 14652856-88a6-4198-8d93-8371bed0e9e4
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

# ╔═╡ 60e71a4f-83e2-4998-b2ca-b410dd48aab3
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

# ╔═╡ 21c6edc2-c7bc-43b1-8d14-cf5e2774d4f6
slide_button()

# ╔═╡ Cell order:
# ╟─573d5a77-858c-4792-909b-c59fdd5080c4
# ╟─5e06425f-6512-4e9c-b149-e9b3e3654ce2
# ╟─fad87406-e04b-4834-8d80-6819a2c7def4
# ╠═ecff9498-0ef0-44a3-abc4-28a21a6fac19
# ╠═14652856-88a6-4198-8d93-8371bed0e9e4
# ╠═60e71a4f-83e2-4998-b2ca-b410dd48aab3
# ╟─21c6edc2-c7bc-43b1-8d14-cf5e2774d4f6
