#!/usr/bin/env python3
"""Render recorded Luau fixture trees as labeled OFFLINE previews, never live screenshots."""
import json
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
FONT = '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
COLORS = {
    'surface_container': '#232733', 'primary_container': '#3d4770',
    'secondary_container': '#4b4163', 'on_secondary_container': '#eadeff',
    'primary': '#b6c4ff', 'on_surface': '#e5e5ee',
    'on_surface_variant': '#bfc2d2', 'outline_variant': '#454958', 'error': '#ffb4ab',
}
SCALE = 2

def color(token, fallback='on_surface'):
    name, _, alpha = (token or fallback).partition('/')
    c = COLORS.get(name, COLORS[fallback])
    return c

def font(size):
    return ImageFont.truetype(FONT, max(1, round(size * SCALE)))

def measure(node):
    p, kind = node['props'], node['kind']
    gap = p.get('gap', 0)
    sizes = [measure(c) for c in node['children']]
    ph, pv = p.get('paddingH', p.get('padding', 0)), p.get('paddingV', p.get('padding', 0))
    if kind in ('row', 'dragSource', 'dropZone', 'column'):
        if kind == 'column':
            w, h = max((s[0] for s in sizes), default=0), sum(s[1] for s in sizes) + max(0, len(sizes)-1)*gap
        else:
            w, h = sum(s[0] for s in sizes) + max(0, len(sizes)-1)*gap, max((s[1] for s in sizes), default=0)
        w += ph*2; h += pv*2
    elif kind == 'label':
        box = font(p.get('fontSize', 12)).getbbox(p.get('text', ''))
        w, h = min((box[2]-box[0])/SCALE, p.get('maxWidth', 999)), p.get('fontSize', 12)+2
    else:
        w = h = p.get('size', 18)
    return p.get('width', w), p.get('height', h)

def paint(image, node, x, y):
    p, kind = node['props'], node['kind']
    w, h = measure(node)
    if w <= 0 or h <= 0: return
    layer = Image.new('RGBA', (max(1, round(w*SCALE)), max(1, round(h*SCALE))))
    d = ImageDraw.Draw(layer)
    if p.get('fill') and not p['fill'].endswith('/0'):
        d.rounded_rectangle((0, 0, w*SCALE-1, h*SCALE-1), radius=p.get('radius', 0)*SCALE, fill=color(p['fill']))
    if p.get('border'):
        d.rounded_rectangle((0, 0, w*SCALE-1, h*SCALE-1), radius=p.get('radius',0)*SCALE, outline=color(p['border']), width=2)
    if kind in ('row', 'column', 'dragSource', 'dropZone'):
        sizes = [measure(c) for c in node['children']]
        vertical = kind == 'column'
        gap = p.get('gap', 0)
        ph, pv = p.get('paddingH', p.get('padding', 0)), p.get('paddingV', p.get('padding',0))
        total = sum(s[1 if vertical else 0] for s in sizes) + max(0,len(sizes)-1)*gap
        main = h-2*pv if vertical else w-2*ph
        pos = (pv if vertical else ph) + ((main-total)/2 if p.get('justify') == 'center' else 0)
        for child, (cw, ch) in zip(node['children'], sizes):
            cx = (w-cw)/2 if vertical else pos
            cy = pos if vertical else (h-ch)/2
            paint(layer, child, cx, cy)
            pos += (ch if vertical else cw)+gap
    elif kind == 'label':
        d.text((0, -1*SCALE), p.get('text',''), font=font(p.get('fontSize',12)), fill=color(p.get('color')))
    elif kind == 'image':
        app = p.get('path','').removeprefix('fixture:')
        d.rounded_rectangle((1,1,w*SCALE-2,h*SCALE-2),radius=5*SCALE,fill=COLORS['primary'])
        text = app.removeprefix('org.').removeprefix('app')[:1].upper() or 'A'
        d.text((w*SCALE/2,h*SCALE/2),text,anchor='mm',font=font(12),fill=COLORS['surface_container'])
    elif kind == 'glyph':
        symbols = {'chevron-left':'‹','chevron-right':'›','chevron-up':'↑','chevron-down':'↓','apps':'▦'}
        d.text((w*SCALE/2,h*SCALE/2),symbols.get(p.get('name'),'□'),anchor='mm',font=font(p.get('size',14)),fill=color(p.get('color')))
    opacity = p.get('opacity',1)
    if opacity < 1: layer.putalpha(layer.getchannel('A').point(lambda v: round(v*opacity)))
    image.alpha_composite(layer,(round(x*SCALE),round(y*SCALE)))

snapshots = json.loads((ROOT/'test-results/trees.json').read_text())
for snapshot in snapshots:
    name = snapshot['name']
    image = Image.new('RGBA',(960,300),'#14171f')
    draw = ImageDraw.Draw(image)
    draw.text((32,24),'Smart Taskbar · '+name.title(),font=font(15),fill=COLORS['on_surface'])
    draw.text((32,78),'OFFLINE FIXTURE PREVIEW · NOT A NOCTALIA SCREENSHOT',font=font(7),fill=COLORS['on_surface_variant'])
    draw.rounded_rectangle((20,130,940,248),radius=24,fill='#1c202b')
    tree = snapshot['tree']; w,h=measure(tree)
    paint(image,tree,(480-w*SCALE/2)/SCALE,(190-h*SCALE/2)/SCALE)
    image.convert('RGB').save(ROOT/'smart-taskbar/screenshots'/f'{name}.png')

print('Wrote four labeled offline previews. Export thumbnail.webp with the official generator.')
