### A Pluto.jl notebook ###
# v0.20.16

using Markdown
using InteractiveUtils

# ╔═╡ 0bc0c702-31e5-43b9-89dc-1c5faf33fdcb
begin
    import Pkg
    Pkg.develop(path=expanduser("~/Documents/Presentations/MCPresPluto.jl"))
    using MCPresPluto, PlutoUI, Base64
end

# ╔═╡ 0112e558-3aee-41bd-a59f-65e7b34ed1d2
slide_setup(
    author = "Adrien Florio",
    place = "MINT Sommer",
    date = "08.07.26",
    colour = :bleunuit,
)

# ╔═╡ eafac84a-050f-4200-9aa9-edf3aca1f799
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

# ╔═╡ c5b43b60-9dfb-490a-8adb-4b8585d45867
slide_button()

# ╔═╡ Cell order:
# ╟─0bc0c702-31e5-43b9-89dc-1c5faf33fdcb
# ╟─0112e558-3aee-41bd-a59f-65e7b34ed1d2
# ╠═eafac84a-050f-4200-9aa9-edf3aca1f799
# ╟─c5b43b60-9dfb-490a-8adb-4b8585d45867
