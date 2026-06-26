### A Pluto.jl notebook ###
# v0.20.16

using Markdown
using InteractiveUtils

# ╔═╡ b2a4c6e8-1d3f-4a5b-8c7d-0e1f2a3b4c01
begin
    import Pkg
    Pkg.develop(path=expanduser("~/Documents/Presentations/MCPresPluto.jl"))
    using MCPresPluto, PlutoUI, Base64
end

# ╔═╡ b2a4c6e8-1d3f-4a5b-8c7d-0e1f2a3b4c02
slide_setup(
    author = "Adrien Florio",
    place = "MINT Sommer",
    date = "08.07.26",
    colour = :bleunuit,
)

# ╔═╡ b2a4c6e8-1d3f-4a5b-8c7d-0e1f2a3b4c03
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

# ╔═╡ b2a4c6e8-1d3f-4a5b-8c7d-0e1f2a3b4c04
slide_button()

# ╔═╡ Cell order:
# ╟─b2a4c6e8-1d3f-4a5b-8c7d-0e1f2a3b4c01
# ╟─b2a4c6e8-1d3f-4a5b-8c7d-0e1f2a3b4c02
# ╠═b2a4c6e8-1d3f-4a5b-8c7d-0e1f2a3b4c03
# ╟─b2a4c6e8-1d3f-4a5b-8c7d-0e1f2a3b4c04
