import re, sys, json, os

# This script lives in html-slides/build/. It reads the 5 standalone source
# slide files directly from html-slides/ (one level up) and writes the merged
# deck back into html-slides/. Just edit any of the 5 source files and rerun
# `python3 build.py` from this folder to regenerate combined-lecture-deck.html.
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SRC_DIR = os.path.normpath(os.path.join(SCRIPT_DIR, ".."))
OUT_FILE = os.path.join(SRC_DIR, "combined-lecture-deck.html")

def load(name):
    with open(os.path.join(SRC_DIR, name), encoding="utf-8") as f:
        return f.read()

def extract(text, tag):
    a = text.index(f"<{tag}")
    a = text.index(">", a) + 1
    b = text.index(f"</{tag}>", a)
    return text[a:b]

def scope_css(css_text, deck_id):
    out = []
    for m in re.finditer(r'([^{}]+)\{([^{}]*)\}', css_text):
        sel, decls = m.group(1).strip(), m.group(2)
        if sel in (':root', '*', 'html,body', 'body'):
            continue
        parts = [p.strip() for p in sel.split(',')]
        scoped = ', '.join(f'#deck-{deck_id} {p}' for p in parts)
        out.append(f'{scoped}{{{decls}}}')
    return '\n'.join(out)

def suffix_html(text, ids, suf):
    # ONLY touch id="X" / id='X' attributes -- never class="X" (some ids share
    # their literal name with an unrelated class, e.g. class="panel" id="panel").
    for old in ids:
        text = text.replace(f'id="{old}"', f'id="{old}-{suf}"')
        text = text.replace(f"id='{old}'", f"id='{old}-{suf}'")
    return text

def suffix_js(text, ids, suf, blanket=()):
    # Safe everywhere: literal getElementById('X') / ("X") calls.
    for old in ids:
        text = text.replace(f"getElementById('{old}')", f"getElementById('{old}-{suf}')")
        text = text.replace(f'getElementById("{old}")', f'getElementById("{old}-{suf}")')
    # Only for ids known to be referenced indirectly (never collide with a class name):
    for old in blanket:
        text = text.replace(f"'{old}'", f"'{old}-{suf}'")
        text = text.replace(f'"{old}"', f'"{old}-{suf}"')
    return text

def must_replace(text, old, new, label):
    if old not in text:
        raise SystemExit(f"MISSING BLOCK [{label}]:\n{old[:200]}")
    return text.replace(old, new, 1)

decks = []

# ============================================================ SCALES ============================================================
src = load("scales-quantum-cosmos.html")
style = extract(src, "style")
body = extract(src, "body")
body = body[:body.index("<script")]
script = extract(src, "script")

controls_block = '''  <div class="controls">
    <div class="ticks" id="ticks"></div>
    <div class="sliderrow">
      <button class="nav" id="prev" title="Step toward human scale (←)">◀</button>
      <input type="range" id="slider" min="0" max="3000" value="0">
      <button class="nav" id="next" title="Step outward (→)">▶</button>
    </div>
    <div class="hint">Drag the slider, use <b>◀ ▶</b> or the <b>arrow keys</b>, or click a label. Pairs marked <b>≈</b> are the classic order-of-magnitude analogies.</div>
  </div>

'''
body = must_replace(body, controls_block, '', 'scales controls block')

blk1 = '''const ticks = document.getElementById('ticks');
const tickEls = LEFT.map((d,i)=>{
  const s=document.createElement('span');
  s.innerHTML = i===0 ? "Human" : `${LEFT[i].name} ⟷ ${RIGHT[i].name}`;
  s.onclick = ()=> animateTo(i);
  ticks.appendChild(s);
  return s;
});

'''
script = must_replace(script, blk1, '', 'scales tickEls block')

blk2 = "  tickEls.forEach((el,i)=> el.classList.toggle('active', i===near));\n"
script = must_replace(script, blk2, '', 'scales tickEls.forEach line')

blk3 = '''const slider=document.getElementById('slider');
let current=0;
slider.addEventListener('input',()=>{current=(slider.value/SMAX)*(N-1);render(current);});'''
script = must_replace(script, blk3, 'let current=0;', 'scales slider block')

blk4 = "    slider.value=(current/(N-1))*SMAX;\n"
script = must_replace(script, blk4, '', 'scales slider.value line')

blk5 = '''document.getElementById('next').onclick=()=>animateTo(Math.round(current)+1);
document.getElementById('prev').onclick=()=>animateTo(Math.round(current)-1);
window.addEventListener('keydown',e=>{
  if(e.key==='ArrowRight')animateTo(Math.round(current)+1);
  if(e.key==='ArrowLeft')animateTo(Math.round(current)-1);
});

'''
script = must_replace(script, blk5, '', 'scales nav wiring block')

ids_scales = ['panelL','wrapL','nameL','subL','refL','sizeL','panelR','wrapR','nameR','subR','refR','sizeR']
body = suffix_html(body, ids_scales, 'scales')
script = suffix_js(script, ids_scales, 'scales', blanket=['wrapL','wrapR'])

reg_scales = '''
window.__DECKS.push({
  sectionId: 'deck-scales',
  labels: LEFT.map((d,i)=> i===0 ? 'Human' : (LEFT[i].name+' ⟷ '+RIGHT[i].name)),
  goto(i){ animateTo(i); },
  activate(){},
  deactivate(){},
});
'''
script = script.rstrip() + '\n' + reg_scales

decks.append({
    'id': 'scales', 'active': True,
    'css': scope_css(style, 'scales'),
    'body': body,
    'script': f'(function(){{\n{script}\n}})();'
})

# ============================================================ SLIT ============================================================
src = load("double-slit.html")
style = extract(src, "style")
body = extract(src, "body")
body = body[:body.index("<script")]
script = extract(src, "script")

controls_block = '''  <div class="controls">
    <div class="dots" id="dots"></div>
    <div class="navrow">
      <button class="nav" id="prev" title="Previous (←)">◀</button>
      <button class="nav" id="next" title="Next (→)">▶</button>
    </div>
    <div class="hint">Use <b>◀ ▶</b> or the <b>arrow keys</b> to move between scenes · click a label to jump.</div>
  </div>

'''
body = must_replace(body, controls_block, '', 'slit controls block')

els_old = '''const els = {
  subtitle:document.getElementById('subtitle'),
  tag:document.getElementById('tag'),
  capTitle:document.getElementById('capTitle'),
  capSub:document.getElementById('capSub'),
  caption:document.getElementById('caption'),
  prev:document.getElementById('prev'),
  next:document.getElementById('next'),
};'''
els_new = '''const els = {
  subtitle:document.getElementById('subtitle'),
  tag:document.getElementById('tag'),
  capTitle:document.getElementById('capTitle'),
  capSub:document.getElementById('capSub'),
  caption:document.getElementById('caption'),
};'''
script = must_replace(script, els_old, els_new, 'slit els object')

dots_old = '''const dotsWrap=document.getElementById('dots');
const labels=['Balls','Waves','The real thing','Electrons'];
const dotEls=labels.map((l,i)=>{
  const d=document.createElement('div'); d.className='dot';
  d.innerHTML=`<span class="pip"></span><span class="dl">${l}</span>`;
  d.onclick=()=>go(i); dotsWrap.appendChild(d); return d;
});'''
script = must_replace(script, dots_old, "const labels=['Balls','Waves','The real thing','Electrons'];", 'slit dots block')

apply_old = '''function applySceneUI(s){
  els.subtitle.textContent=s.subtitle;
  els.tag.textContent=s.tag; els.tag.style.color=s.tagColor; els.tag.style.borderColor=s.tagColor+'55';
  els.capTitle.innerHTML=s.capTitle;
  els.capSub.innerHTML=s.capSub;
  dotEls.forEach((d,i)=>d.classList.toggle('active',i===cur));
  els.prev.disabled=cur===0; els.next.disabled=cur===scenes.length-1;
}'''
apply_new = '''function applySceneUI(s){
  els.subtitle.textContent=s.subtitle;
  els.tag.textContent=s.tag; els.tag.style.color=s.tagColor; els.tag.style.borderColor=s.tagColor+'55';
  els.capTitle.innerHTML=s.capTitle;
  els.capSub.innerHTML=s.capSub;
}'''
script = must_replace(script, apply_old, apply_new, 'slit applySceneUI')

nav_old = '''els.prev.onclick=()=>go(cur-1);
els.next.onclick=()=>go(cur+1);
window.addEventListener('keydown',e=>{
  if(e.key==='ArrowRight') go(cur+1);
  if(e.key==='ArrowLeft')  go(cur-1);
});'''
script = must_replace(script, nav_old, '', 'slit nav wiring')

loop_old = '''function loop(now){
  let dt=(now-last)/1000; last=now;
  dt=Math.min(dt,0.05);
  const s=scenes[cur];
  s.step(dt);
  s.draw();
  requestAnimationFrame(loop);
}'''
loop_new = '''let __active=false;
function loop(now){
  if(!__active){ last=now; requestAnimationFrame(loop); return; }
  let dt=(now-last)/1000; last=now;
  dt=Math.min(dt,0.05);
  const s=scenes[cur];
  s.step(dt);
  s.draw();
  requestAnimationFrame(loop);
}'''
script = must_replace(script, loop_old, loop_new, 'slit main loop')

ids_slit = ['subtitle','tag','panel','cv','qctrl','obsToggle','ecount','resetBtn','speedctrl','sceneReset','speed','caption','capTitle','capSub']
body = suffix_html(body, ids_slit, 'slit')
script = suffix_js(script, ids_slit, 'slit')

reg_slit = '''
window.__DECKS.push({
  sectionId: 'deck-slit',
  labels: labels,
  goto(i){ go(i); },
  activate(){ __active = true; last = performance.now(); },
  deactivate(){ __active = false; },
});
'''
script = script.rstrip() + '\n' + reg_slit

decks.append({
    'id': 'slit', 'active': False,
    'css': scope_css(style, 'slit'),
    'body': body,
    'script': f'(function(){{\n{script}\n}})();'
})

# ============================================================ B2 ============================================================
src = load("binary-base2.html")
style = extract(src, "style")
body = extract(src, "body")
body = body[:body.index("<script")]
script = extract(src, "script")

controls_block = '''  <div class="controls">
    <div class="dots" id="dots"></div>
    <div class="navrow">
      <button class="nav" id="prev" title="Previous (←)">◀</button>
      <button class="nav" id="next" title="Next (→)">▶</button>
    </div>
    <div class="hint">Use <b>◀ ▶</b> or the <b>arrow keys</b> to switch scenes · click the bits and drag the sliders.</div>
  </div>

'''
body = must_replace(body, controls_block, '', 'b2 controls block')

els_old = '''const els = {
  subtitle:document.getElementById('subtitle'),
  tag:document.getElementById('tag'),
  capTitle:document.getElementById('capTitle'),
  capSub:document.getElementById('capSub'),
  prev:document.getElementById('prev'),
  next:document.getElementById('next'),
};'''
els_new = '''const els = {
  subtitle:document.getElementById('subtitle'),
  tag:document.getElementById('tag'),
  capTitle:document.getElementById('capTitle'),
  capSub:document.getElementById('capSub'),
};'''
script = must_replace(script, els_old, els_new, 'b2 els object')

dots_old = '''const dotsWrap=document.getElementById('dots');
const labels=['Counting','Adding'];
const dotEls=labels.map((l,i)=>{
  const d=document.createElement('div'); d.className='dot';
  d.innerHTML=`<span class="pip"></span><span class="dl">${l}</span>`;
  d.onclick=()=>go(i); dotsWrap.appendChild(d); return d;
});'''
script = must_replace(script, dots_old, "const labels=['Counting','Adding'];", 'b2 dots block')

apply_old = '''function applySceneUI(s){
  els.subtitle.textContent=s.subtitle;
  els.tag.textContent=s.tag; els.tag.style.color=s.tagColor; els.tag.style.borderColor=s.tagColor+'55';
  els.capTitle.innerHTML=s.capTitle;
  els.capSub.innerHTML=s.capSub;
  dotEls.forEach((d,i)=>d.classList.toggle('active',i===cur));
  sceneEls.forEach((e,i)=>e.classList.toggle('active',i===cur));
  els.prev.disabled=cur===0; els.next.disabled=cur===scenes.length-1;
}'''
apply_new = '''function applySceneUI(s){
  els.subtitle.textContent=s.subtitle;
  els.tag.textContent=s.tag; els.tag.style.color=s.tagColor; els.tag.style.borderColor=s.tagColor+'55';
  els.capTitle.innerHTML=s.capTitle;
  els.capSub.innerHTML=s.capSub;
  sceneEls.forEach((e,i)=>e.classList.toggle('active',i===cur));
}'''
script = must_replace(script, apply_old, apply_new, 'b2 applySceneUI')

nav_old = '''els.prev.onclick=()=>go(cur-1);
els.next.onclick=()=>go(cur+1);
window.addEventListener('keydown',e=>{
  // don't hijack arrows while dragging a slider
  if(e.target && e.target.tagName==='INPUT') return;
  if(e.key==='ArrowRight') go(cur+1);
  if(e.key==='ArrowLeft')  go(cur-1);
});'''
script = must_replace(script, nav_old, '', 'b2 nav wiring')

ids_b2 = ['subtitle','tag','panel','scene1','scene2','bitrow','s1sum','binBig','decBig','caption','capTitle','capSub',
          'addGrid','s2status','inA','inB','valA','valB','addStep','addAuto','addReset','s1minus','s1plus','s1play']
body = suffix_html(body, ids_b2, 'b2')
script = suffix_js(script, ids_b2, 'b2')

reg_b2 = '''
window.__DECKS.push({
  sectionId: 'deck-b2',
  labels: labels,
  goto(i){ go(i); },
  activate(){},
  deactivate(){ clearInterval(S1.timer); clearInterval(S2.autoTimer); },
});
'''
script = script.rstrip() + '\n' + reg_b2

decks.append({
    'id': 'b2', 'active': False,
    'css': scope_css(style, 'b2'),
    'body': body,
    'script': f'(function(){{\n{script}\n}})();'
})

print("PART 2 OK: b2 transformed")

# ============================================================ CANNON + CANNONQ (shared pattern) ============================================================
def build_cannon_deck(srcfile, deck_id, hint_text):
    src = load(srcfile)
    style = extract(src, "style")
    body = extract(src, "body")
    body = body[:body.index("<script")]
    script = extract(src, "script")

    controls_block = f'''  <div class="controls">
    <div class="dots" id="dots"></div>
    <div class="navrow">
      <button class="nav" id="prev" title="Previous (&#8592;)">&#9664;</button>
      <button class="nav" id="next" title="Next (&#8594;)">&#9654;</button>
    </div>
    <div class="hint">Use <b>&#9664; &#9654;</b> or the <b>arrow keys</b> to move between panels &middot; {hint_text}</div>
  </div>

'''
    body = must_replace(body, controls_block, '', f'{deck_id} controls block')

    els_old = '''const els={
  subtitle:document.getElementById('subtitle'),
  tag:document.getElementById('tag'),
  capTitle:document.getElementById('capTitle'),
  capSub:document.getElementById('capSub'),
  prev:document.getElementById('prev'),
  next:document.getElementById('next'),
};'''
    els_new = '''const els={
  subtitle:document.getElementById('subtitle'),
  tag:document.getElementById('tag'),
  capTitle:document.getElementById('capTitle'),
  capSub:document.getElementById('capSub'),
};'''
    script = must_replace(script, els_old, els_new, f'{deck_id} els object')

    dots_old = '''const dotsWrap=document.getElementById('dots');
const dotEls=labels.map((l,i)=>{
  const d=document.createElement('div');d.className='dot';
  d.innerHTML='<span class="pip"></span><span class="dl">'+l+'</span>';
  d.onclick=()=>go(i);dotsWrap.appendChild(d);return d;
});'''
    script = must_replace(script, dots_old, '', f'{deck_id} dots block')

    apply_old = '''function applySceneUI(s){
  els.subtitle.innerHTML=s.subtitle;
  els.tag.textContent=s.tag;els.tag.style.color=s.tagColor;els.tag.style.borderColor=s.tagColor+'55';
  els.capTitle.innerHTML=s.capTitle;els.capSub.innerHTML=s.capSub;
  dotEls.forEach((d,i)=>d.classList.toggle('active',i===cur));
  els.prev.disabled=cur===0;els.next.disabled=cur===scenes.length-1;
}'''
    apply_new = '''function applySceneUI(s){
  els.subtitle.innerHTML=s.subtitle;
  els.tag.textContent=s.tag;els.tag.style.color=s.tagColor;els.tag.style.borderColor=s.tagColor+'55';
  els.capTitle.innerHTML=s.capTitle;els.capSub.innerHTML=s.capSub;
}'''
    script = must_replace(script, apply_old, apply_new, f'{deck_id} applySceneUI')

    nav_old = '''els.prev.onclick=()=>go(cur-1);
els.next.onclick=()=>go(cur+1);
window.addEventListener('keydown',e=>{
  if(e.key==='ArrowRight')go(cur+1);
  if(e.key==='ArrowLeft')go(cur-1);
});'''
    script = must_replace(script, nav_old, '', f'{deck_id} nav wiring')

    loop_old = '''let last=performance.now();
function frame(now){
  const dt=Math.min(0.05,(now-last)/1000);last=now;
  scenes[cur].step(dt);
  scenes[cur].draw();
  requestAnimationFrame(frame);
}
resize();
scenes[0].onEnter();
applySceneUI(scenes[0]);
requestAnimationFrame(frame);'''
    loop_new = '''let last=performance.now();
let __active=false;
function frame(now){
  if(!__active){ last=now; requestAnimationFrame(frame); return; }
  const dt=Math.min(0.05,(now-last)/1000);last=now;
  scenes[cur].step(dt);
  scenes[cur].draw();
  requestAnimationFrame(frame);
}
resize();
scenes[0].onEnter();
applySceneUI(scenes[0]);
requestAnimationFrame(frame);'''
    script = must_replace(script, loop_old, loop_new, f'{deck_id} main loop')

    ids = ['subtitle','tag','panel','cv','sctrl','readout','capTitle','capSub',
           'wsheet','wshBadge','wsC4','wsC2','wsA2','wsA1','wsB2','wsB1','wsS4','wsS2','wsS1']
    ws_indirect = ['wshBadge','wsC4','wsC2','wsA2','wsA1','wsB2','wsB1','wsS4','wsS2','wsS1']
    body = suffix_html(body, ids, deck_id)
    script = suffix_js(script, ids, deck_id, blanket=ws_indirect)

    reg = f'''
window.__DECKS.push({{
  sectionId: 'deck-{deck_id}',
  labels: labels,
  goto(i){{ go(i); }},
  activate(){{ __active = true; last = performance.now(); }},
  deactivate(){{ __active = false; }},
}});
'''
    script = script.rstrip() + '\n' + reg

    return {
        'id': deck_id, 'active': False,
        'css': scope_css(style, deck_id),
        'body': body,
        'script': f'(function(){{\n{script}\n}})();'
    }

decks.append(build_cannon_deck("cannon-bits.html", "cannon", "fire the cannon to send a bit."))
print("PART 3 OK: cannon transformed")
decks.append(build_cannon_deck("cannon-bits-quantum.html", "cannonq", "fire the cannon to send a qubit."))
print("PART 4 OK: cannonq transformed")

# ============================================================ ASSEMBLE ============================================================
GLOBAL_ROOT = ''':root{
  --bg:#05060d; --ink:#eef2ff; --muted:#8b93b8; --line:#1c2238;
  --warm:#ffb24a; --cool:#6ad7ff; --elec:#7CFFB2; --warn:#ff5470; --mist:#b9a8ff;
  --accentL:#6ad7ff; --accentR:#ffb24a;
}
*{box-sizing:border-box;margin:0;padding:0}
html,body{height:100%}
body{
  background:radial-gradient(1200px 800px at 50% -10%, #11162b 0%, var(--bg) 60%);
  color:var(--ink);
  font-family:'Inter',system-ui,-apple-system,"Segoe UI",Roboto,Helvetica,Arial,sans-serif;
  overflow:hidden;height:100vh;display:flex;flex-direction:column;
}
.deck{display:none;flex:1 1 auto;flex-direction:column;min-height:0;}
.deck.active{display:flex;}
.gcontrols{flex:0 0 auto;padding:10px 24px 16px;display:flex;flex-direction:column;align-items:center;gap:8px;min-width:0;width:100%}
.gdots{display:flex;gap:10px;flex-wrap:nowrap;align-items:center;justify-content:flex-start;
  max-width:min(1400px,96vw);width:100%;overflow-x:auto;overflow-y:hidden;padding:2px 4px 6px;scrollbar-width:thin}
.gdot{display:flex;flex-direction:column;align-items:center;gap:4px;cursor:pointer;opacity:.55;transition:opacity .2s;flex:0 0 auto}
.gdot.active{opacity:1}
.gdot .gpip{width:9px;height:9px;border-radius:50%;background:#39406a;transition:background .2s,box-shadow .2s}
.gdot.active .gpip{background:var(--cool);box-shadow:0 0 12px var(--cool)}
.gdot .gdl{font-size:9px;color:var(--muted);letter-spacing:.2px;text-align:center;white-space:nowrap}
.gdot.active .gdl{color:var(--ink);font-weight:700}
.gnavrow{display:flex;align-items:center;gap:16px}
button.gnav{background:#121734;color:var(--ink);border:1px solid var(--line);border-radius:10px;
  width:46px;height:40px;font-size:18px;cursor:pointer;transition:background .15s,transform .1s}
button.gnav:hover{background:#1b2350} button.gnav:active{transform:scale(.94)}
button.gnav:disabled{opacity:.3;cursor:default}
.ghint{color:var(--muted);font-size:12px;text-align:center}
.ghint b{color:var(--ink)}
'''

css_all = GLOBAL_ROOT + '\n' + '\n'.join(d['css'] for d in decks)

sections = []
for d in decks:
    cls = 'deck active' if d['active'] else 'deck'
    sections.append(f'<section id="deck-{d["id"]}" class="{cls}">\n{d["body"]}\n</section>')

nav_html = '''<div class="gcontrols">
  <div class="gdots" id="gdots"></div>
  <div class="gnavrow">
    <button class="gnav" id="gprev" title="Previous (&#8592;)">&#9664;</button>
    <button class="gnav" id="gnext" title="Next (&#8594;)">&#9654;</button>
  </div>
  <div class="ghint">Use <b>&#9664; &#9654;</b> or the <b>arrow keys</b> to move through the whole talk &middot; click a dot to jump.</div>
</div>'''

master_script = '''(function(){
  const decks = window.__DECKS;
  const sectionEls = decks.map(d=>document.getElementById(d.sectionId));
  const flat = [];
  decks.forEach((d,di)=> d.labels.forEach((lab,li)=> flat.push({di,li,lab})));
  let curFlat = 0;
  const gdotsWrap = document.getElementById('gdots');
  const gdotEls = flat.map((f,i)=>{
    const el=document.createElement('div'); el.className='gdot';
    el.innerHTML = '<span class="gpip"></span><span class="gdl">'+f.lab+'</span>';
    el.onclick=()=>goFlat(i); gdotsWrap.appendChild(el); return el;
  });
  const gprev=document.getElementById('gprev'), gnext=document.getElementById('gnext');
  function applyUI(){
    gdotEls.forEach((el,i)=>el.classList.toggle('active', i===curFlat));
    gprev.disabled = curFlat===0; gnext.disabled = curFlat===flat.length-1;
  }
  function showDeck(di){ sectionEls.forEach((el,i)=>el.classList.toggle('active', i===di)); }
  function goFlat(i){
    i = Math.max(0, Math.min(flat.length-1, i));
    const prevDi = flat[curFlat].di, target = flat[i];
    if(target.di !== prevDi){
      decks[prevDi].deactivate && decks[prevDi].deactivate();
      showDeck(target.di);
      decks[target.di].activate && decks[target.di].activate();
    }
    decks[target.di].goto(target.li);
    curFlat = i;
    applyUI();
  }
  gprev.onclick=()=>goFlat(curFlat-1);
  gnext.onclick=()=>goFlat(curFlat+1);
  window.addEventListener('keydown', e=>{
    if(e.target && e.target.tagName==='INPUT') return;
    if(e.key==='ArrowRight') goFlat(curFlat+1);
    if(e.key==='ArrowLeft') goFlat(curFlat-1);
  });
  decks[0].activate && decks[0].activate();
  decks[0].goto(0);
  applyUI();
})();'''

scripts_html = '<script>\nwindow.__DECKS = [];\n</script>\n'
for d in decks:
    scripts_html += f'<script>\n{d["script"]}\n</script>\n'
scripts_html += f'<script>\n{master_script}\n</script>\n'

final_html = f'''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Quantum Mechanics &amp; Quantum Computing — Outreach Lecture</title>
<style>
{css_all}
</style>
</head>
<body>
{chr(10).join(sections)}

{nav_html}

{scripts_html}</body>
</html>
'''

with open(OUT_FILE, "w", encoding="utf-8") as f:
    f.write(final_html)

print("ASSEMBLED", OUT_FILE, "total bytes:", len(final_html))

# ============================================================ VERIFY ============================================================
ids_found = re.findall(r'id="([^"]+)"', final_html)
dupes = [i for i in set(ids_found) if ids_found.count(i) > 1]
print("Duplicate ids:", dupes if dupes else "NONE")

get_ids = set(re.findall(r"getElementById\(['\"]([^'\"]+)['\"]\)", final_html))
missing = [i for i in get_ids if i not in ids_found]
print("getElementById refs with no matching id= :", missing if missing else "NONE")

kd_count = final_html.count("addEventListener('keydown'")
print("keydown listeners:", kd_count, "(expect 1)")

expected = {'scales':7,'slit':4,'b2':2,'cannon':5,'cannonq':5}
print("Expected bullet counts:", expected, "total:", sum(expected.values()))

# sanity: each deck's script should still contain its own 'labels' array declaration
for d in decks:
    if "labels" not in d['script'] and d['id'] != 'scales':
        print("WARNING: no labels array found in", d['id'])
print("Done.")
