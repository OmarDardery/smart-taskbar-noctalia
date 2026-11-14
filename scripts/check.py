#!/usr/bin/env python3
"""Additional source-package checks; official community validation remains canonical."""
from pathlib import Path
import json
import tomllib

root = Path(__file__).resolve().parents[1]
plugin = root / 'smart-taskbar'
manifest = tomllib.loads((plugin/'plugin.toml').read_text())
catalog = tomllib.loads((root/'catalog.toml').read_text())['plugin'][0]
for key, value in catalog.items():
    assert manifest[key] == value, f'Catalog drift: {key}'
assert manifest['plugin_api'] == 52
assert len(manifest['widget']) == 1
assert not any(key in manifest for key in ('service', 'panel', 'layer'))
translations = json.loads((plugin/'translations/en.json').read_text())
for setting in manifest['widget'][0]['setting']:
    assert setting['key'] != 'settings_page'
    assert not setting.get('visible_when'), 'Every plugin control must be available together'
    assert not setting.get('advanced', False), 'No plugin controls hidden behind another toggle'

    value = setting['default']
    if setting['type'] in ('int','double'):
        assert setting['min'] <= value <= setting['max']
    if setting['type'] == 'select':
        assert value in [option['value'] for option in setting['options']]
    for key in ('label_key','description_key'):
        node = translations
        for segment in setting[key].split('.'):
            node = node[segment]
        assert isinstance(node,str) and node
        if key == "label_key": assert ":" not in node
for entry in plugin.rglob('*.luau'):
    text = entry.read_text()
    assert text.startswith('--!nonstrict')
    assert 'ui.scroll' not in text
    if entry.name != 'transport.luau':
        assert 'runStream(' not in text
assert 'python3' in manifest['dependencies']
assert (plugin/'lib/bridge.py').is_file()
assert (plugin/'LICENSE').is_file()
assert len(list((plugin/'screenshots').glob('*.png'))) == 4
print('PASS catalog consistency, setting defaults/translations, single-entry architecture, and package assets')
