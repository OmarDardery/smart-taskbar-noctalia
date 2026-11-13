#!/usr/bin/env python3
"""Execute actual plugin source in Luau with a deterministic public-host fixture.
No Noctalia process, compositor, renderer, or input device is implied by these tests.
"""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import tomllib

ROOT = Path(__file__).resolve().parents[1]
PLUGIN = ROOT / 'smart-taskbar'

def lua(value):
    if isinstance(value, dict):
        return '{' + ','.join('[' + lua(k) + ']=' + lua(v) for k, v in value.items()) + '}'
    if isinstance(value, list):
        return '{' + ','.join(map(lua, value)) + '}'
    if isinstance(value, bool):
        return 'true' if value else 'false'
    return json.dumps(value, ensure_ascii=False)

def main():
    manifest = tomllib.loads((PLUGIN / 'plugin.toml').read_text())
    defaults = {s['key']: s['default'] for s in manifest['widget'][0]['setting']}
    source = 'local defaults = ' + lua(defaults) + '\n'
    source += (ROOT / 'tests/host.luau').read_text() + '\n'
    for name in ('model', 'compositor'):
        source += 'local module_' + name + ' = (function()\n'
        source += (PLUGIN / 'lib' / (name + '.luau')).read_text() + '\nend)()\n'
    widget = (PLUGIN / 'widget.luau').read_text()
    widget = widget.replace('require("./lib/model.luau")', 'module_model')
    widget = widget.replace('require("./lib/compositor.luau")', 'module_compositor')
    source += widget + '\n' + (ROOT / 'tests/spec.luau').read_text()
    with tempfile.TemporaryDirectory() as temp:
        entry = Path(temp) / 'suite.luau'
        entry.write_text(source)
        result = subprocess.run([os.environ.get('LUAU', 'luau'), str(entry)], text=True, capture_output=True)
        print('\n'.join(line for line in result.stdout.splitlines() if not line.startswith('SNAPSHOT ')))
        print(result.stderr, end='')
        if result.returncode:
            raise SystemExit(result.returncode)
        # Fixture UI trees are usable for clearly labeled offline previews.
        snapshots = [json.loads(line[9:]) for line in result.stdout.splitlines() if line.startswith('SNAPSHOT ')]
        if snapshots:
            output = ROOT / 'test-results'
            output.mkdir(exist_ok=True)
            (output / 'trees.json').write_text(json.dumps(snapshots, indent=2))

if __name__ == '__main__':
    main()
