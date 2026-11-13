#!/usr/bin/env python3
"""Exercise the shipped shell program with a fake Umbriel CLI, real pipes and signals.
This tests framing/reconnect/process-group cleanup, not a running compositor or Noctalia.
"""
import json
import os
from pathlib import Path
import selectors
import signal
import subprocess
import sys
import tempfile
import time
import unittest

ROOT = Path(__file__).resolve().parents[1]
COMMAND = (ROOT/'smart-taskbar/lib/transport.luau').read_text().split('M.umbrielCommand = [[',1)[1].split(']]',1)[0]

class StreamTest(unittest.TestCase):
    def test_reconnect_and_process_group_cleanup(self):
        with tempfile.TemporaryDirectory() as directory:
            temp = Path(directory)
            cli = temp/'umbriel'
            cli.write_text('#!'+sys.executable+'\n'+'''
import json, os, pathlib, sys, time
assert sys.argv[1:] == ["subscribe", "windows", "workspaces"]
state = pathlib.Path(os.environ["STREAM_TEST_STATE"])
with state.open("a") as f: f.write(str(os.getpid()) + "\\n")
connection = len(state.read_text().splitlines())
if connection == 1:
    print(json.dumps({"event":"windows","data":[{"id":"one"}]}),flush=True)
else:
    print(json.dumps({"event":"workspaces","data":[]}),flush=True)
    time.sleep(60)
''')
            cli.chmod(0o755)
            state=temp/'pids'
            env=dict(os.environ,PATH=directory+os.pathsep+os.environ['PATH'],STREAM_TEST_STATE=str(state))
            process=subprocess.Popen(['/bin/sh','-c',COMMAND],env=env,stdout=subprocess.PIPE,
                                     stderr=subprocess.PIPE,start_new_session=True)
            selector=selectors.DefaultSelector()
            selector.register(process.stdout,selectors.EVENT_READ)
            pending=b''
            messages=[]
            try:
                deadline=time.monotonic()+10
                while len(messages)<5 and time.monotonic()<deadline:
                    for key,_ in selector.select(timeout=0.2):
                        chunk=os.read(key.fileobj.fileno(),65536)
                        self.assertTrue(chunk,'stream unexpectedly exited')
                        pending+=chunk
                        while b'\n' in pending:
                            line,pending=pending.split(b'\n',1)
                            messages.append(json.loads(line))
                self.assertEqual([m['event'] for m in messages],
                                 ['reset','windows','reset','reset','workspaces'])
                self.assertEqual(messages[1]['data'][0]['id'],'one')
                self.assertEqual(len(state.read_text().splitlines()),2)
                # An idle, connected CLI must not be restarted by a timer.
                self.assertFalse(selector.select(timeout=0.2))
                self.assertEqual(len(state.read_text().splitlines()),2)
            finally:
                os.killpg(process.pid,signal.SIGTERM)
                process.wait(timeout=5)
                selector.close()
                process.stdout.close()
                process.stderr.close()
            deadline=time.monotonic()+3
            while time.monotonic()<deadline:
                running=[]
                for pid in state.read_text().splitlines():
                    status=Path('/proc')/pid/'stat'
                    if status.exists() and status.read_text().split(') ',1)[1][0] != 'Z':
                        running.append(pid)
                if not running: break
                time.sleep(0.05)
            self.assertEqual(running,[], 'CLI child survived cancellation')

if __name__=='__main__':
    unittest.main()
