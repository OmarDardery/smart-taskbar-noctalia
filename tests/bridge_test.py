#!/usr/bin/env python3
"""Public IPC fixtures and real UNIX-socket integration for the shipped bridge.
These are fake compositors, not desktop acceptance or real compositor benchmarks.
"""
import copy
import importlib.util
import json
import os
from pathlib import Path
import selectors
import signal
import socket
import socketserver
import struct
import subprocess
import sys
import tempfile
import threading
import time
import unittest

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[1]
ENTRY = ROOT/'smart-taskbar/lib/bridge.py'
spec = importlib.util.spec_from_file_location('bridge', ENTRY)
bridge = importlib.util.module_from_spec(spec)
spec.loader.exec_module(bridge)

HYPR_CLIENTS = [dict(address='0xabc', mapped=True, workspace={'id':1,'name':'1'}, monitor=0,
                     **{'class':'app','title':'A','at':[0,0]})]
HYPR_MONITORS = [dict(id=0,name='DP-1',focused=True,activeWorkspace={'id':1},specialWorkspace={'id':0})]
HYPR_WORKSPACES = [dict(id=1,name='1',monitor='DP-1')]
MANGO_MONITORS = [dict(name='DP-1',active=True,active_client={'id':7},
                       tags=[dict(index=1,is_active=False),dict(index=2,is_active=True)])]
MANGO_CLIENTS = [dict(id=7,appid='app',title='A',monitor='DP-1',tags=[1,2],is_focused=True)]
SWAY_WORKSPACES = [dict(id=10,name='1',num=1,output='DP-1',visible=True,focused=True)]
SWAY_TREE = dict(type='root',nodes=[dict(type='output',name='DP-1',nodes=[
    dict(type='workspace',id=10,nodes=[dict(type='con',id=99,app_id='app',name='A',pid=1,focused=True)])])])


class NormalizerTests(unittest.TestCase):
    def test_hypr_legacy_and_typed_workspaces(self):
        value=bridge.normalize_hypr(HYPR_CLIENTS,HYPR_MONITORS,HYPR_WORKSPACES,{'address':'0xabc'})
        self.assertTrue(value['windows'][0]['focused'])
        self.assertEqual(value['windows'][0]['output'],'DP-1')
        self.assertTrue(value['workspaces'][0]['active'])
        for schema in ({'type':'numbered','address':'1'}, {'type':'normal','address':'1','id':1}):
            self.assertEqual(bridge.hypr_workspace(schema),'1')
        self.assertEqual(bridge.hypr_workspace({'type':'named','address':'web'}),'name:web')
        self.assertEqual(bridge.hypr_workspace({'type':'special','address':'special:chat'}),'special:chat')

    def test_hypr_hidden_group_members_are_not_fabricated_minimized_windows(self):
        clients=copy.deepcopy(HYPR_CLIENTS)
        clients[0].update(hidden=True,mapped=True)
        value=bridge.normalize_hypr(clients,HYPR_MONITORS,HYPR_WORKSPACES,{})['windows'][0]
        self.assertFalse(value['minimized']); self.assertFalse(value['minimizable'])

    def test_hypr_duplicate_unmapped_and_urgency(self):
        clients=copy.deepcopy(HYPR_CLIENTS)*2+[dict(address='0xdef',mapped=False)]
        value=bridge.normalize_hypr(clients,HYPR_MONITORS,HYPR_WORKSPACES,{}, {'0xabc'})
        self.assertEqual(len(value['windows']),1); self.assertTrue(value['windows'][0]['urgent'])
        value=bridge.normalize_hypr(clients,HYPR_MONITORS,HYPR_WORKSPACES,{'address':'0xabc'}, {'0xabc'})
        self.assertFalse(value['windows'][0]['urgent'])

    def test_mango_multi_tag_identity_count_focus_and_membership(self):
        value=bridge.normalize_mango(MANGO_CLIENTS*2,MANGO_MONITORS)
        self.assertEqual(len(value['windows']),1)
        w=value['windows'][0]
        self.assertEqual(w['workspace'],'DP-1:2')
        self.assertEqual(w['workspaces'],['DP-1:1','DP-1:2'])
        self.assertTrue(w['focused']); self.assertTrue(w['minimizable'])

    def test_mango_hidden_scratchpads_and_minimized_windows(self):
        clients=copy.deepcopy(MANGO_CLIENTS)
        clients[0].update(is_scratchpad=True)
        self.assertEqual(bridge.normalize_mango(clients,MANGO_MONITORS)['windows'],[])
        clients[0].update(is_minimized=True)
        w=bridge.normalize_mango(clients,MANGO_MONITORS)['windows'][0]
        self.assertTrue(w['minimized']); self.assertFalse(w['minimizable'])

    def test_mango_multiple_outputs_keep_tag_ids_distinct(self):
        monitors=copy.deepcopy(MANGO_MONITORS)
        second=copy.deepcopy(monitors[0]);second.update(name='HDMI-A-1',active=False)
        value=bridge.normalize_mango(MANGO_CLIENTS,monitors+[second])
        self.assertEqual(len({ws['id'] for ws in value['workspaces']}),4)
        self.assertEqual(sum(ws['focused'] for ws in value['workspaces']),1)

    def test_sway_tree_floating_xwayland_and_scratchpad_exclusion(self):
        tree=copy.deepcopy(SWAY_TREE)
        workspace=tree['nodes'][0]['nodes'][0]
        workspace['floating_nodes']=[dict(type='con',id=100,pid=2,name='X',window_properties={'class':'XApp'})]
        tree['nodes'].append(dict(type='output',name='__i3',nodes=[dict(type='con',id=101,pid=3)]))
        value=bridge.normalize_sway(tree,SWAY_WORKSPACES)
        self.assertEqual({w['id'] for w in value['windows']},{'99','100'})
        self.assertEqual(next(w for w in value['windows'] if w['id']=='100')['appId'],'XApp')
        self.assertTrue(value['workspaces'][0]['active'])

    def test_publisher_ignores_geometry_only_and_reordered_snapshots(self):
        sent=[]; publisher=bridge.Publisher(sent.append)
        value=bridge.normalize_hypr(HYPR_CLIENTS,HYPR_MONITORS,HYPR_WORKSPACES,{})
        publisher.snapshot(value); count=len(sent)
        clients=copy.deepcopy(HYPR_CLIENTS);clients[0]['at']=[999,888]
        publisher.snapshot(bridge.normalize_hypr(clients,HYPR_MONITORS,HYPR_WORKSPACES,{}))
        self.assertEqual(len(sent),count)

    def test_large_snapshots_are_chunked_losslessly_below_host_line_limit(self):
        sent=[];publisher=bridge.Publisher(sent.append)
        windows=[bridge.window(str(i),'app','🚀'*400,'1','DP-1') for i in range(100)]
        publisher.snapshot(dict(windows=windows,workspaces=[]))
        self.assertGreater(len(sent),1)
        for message in sent:
            self.assertLess(len(json.dumps(message,ensure_ascii=True).encode()),bridge.FRAME_BYTES)
        restored=[w for frame in sent for w in frame['data']['windows']]
        self.assertEqual(len(restored),100)
        self.assertTrue(sent[-1]['data']['last'])
        self.assertEqual([f['data']['index'] for f in sent],list(range(1,len(sent)+1)))

    def test_identity_is_not_truncated_or_whitespace_merged(self):
        self.assertEqual(bridge.window('1','Unusual  App','A\nB','1','DP-1')['appId'],'Unusual  App')
        self.assertEqual(bridge.window('1','app','A\nB','1','DP-1')['title'],'A B')
        with self.assertRaises(ValueError):bridge.window('1','x'*4097,'A','1','DP-1')

    def test_invalid_and_oversized_payloads_are_rejected(self):
        with self.assertRaises(ValueError):bridge.normalize_mango({},[])
        with self.assertRaises(ValueError):bridge.checked_array([None]*(bridge.MAX_ITEMS+1))
        self.assertEqual(bridge.address('abc'),'0xabc')
        self.assertEqual(bridge.address('abc;exec'), '')
        with self.assertRaises(ValueError):bridge.Bridge('hyprland',{'HYPRLAND_INSTANCE_SIGNATURE':'../../other'}).paths()


class FakeServer(socketserver.ThreadingUnixStreamServer):
    daemon_threads=True
    allow_reuse_address=True
    def __init__(self,path,kind):
        self.kind=kind;self.stop=threading.Event();self.lock=threading.Lock()
        self.requests=[];self.watches=[]
        self.clients=copy.deepcopy(HYPR_CLIENTS if kind=='hypr' else MANGO_CLIENTS)
        self.monitors=copy.deepcopy(HYPR_MONITORS if kind=='hypr' else MANGO_MONITORS)
        self.workspaces=copy.deepcopy(HYPR_WORKSPACES)
        self.tree=copy.deepcopy(SWAY_TREE)
        super().__init__(str(path),Handler)
        self.thread=threading.Thread(target=self.serve_forever,kwargs={'poll_interval':0.05},daemon=True)
        self.thread.start()

    def send(self,value,family=None):
        with self.lock:watches=list(self.watches)
        for sock,command in watches:
            if family and command!='watch '+family:continue
            try:sock.sendall(value)
            except OSError:pass

    def close_watches(self):
        with self.lock:
            watches=self.watches;self.watches=[]
        for sock,_ in watches:
            try:sock.shutdown(socket.SHUT_RDWR)
            except OSError:pass

    def close(self):
        self.stop.set();self.close_watches();self.shutdown();self.server_close();self.thread.join(timeout=2)


class Handler(socketserver.BaseRequestHandler):
    def handle(self):
        server=self.server; sock=self.request
        try:
            if server.kind=='events':
                with server.lock:server.watches.append((sock,'hypr'))
                server.stop.wait(15)
                return
            if server.kind=='sway':
                header=bridge.recv_exact(sock,14)
                length,kind=struct.unpack('<II',header[6:])
                payload=bridge.recv_exact(sock,length)
                with server.lock:server.requests.append(kind)
                if kind==2:
                    with server.lock:server.watches.append((sock,'sway'))
                    sock.sendall(bridge.i3_frame(2,b'{"success":true}'));server.stop.wait(15)
                else:
                    response=server.tree if kind==4 else SWAY_WORKSPACES
                    sock.sendall(bridge.i3_frame(kind,json.dumps(response).encode()))
                return
            command=sock.recv(4096).decode().strip()
            with server.lock:server.requests.append(command)
            if server.kind=='hypr':
                response={'j/clients':server.clients,'j/monitors':server.monitors,
                          'j/workspaces':server.workspaces,'j/activewindow':{'address':'0xabc'}}[command]
                sock.sendall(json.dumps(response).encode())
            elif server.kind=='events':
                with server.lock:server.watches.append((sock,'hypr'))
                server.stop.wait(15)
            else:
                family=command.removeprefix('watch all-')
                with server.lock:server.watches.append((sock,command))
                sock.sendall((json.dumps({family:getattr(server,family)})+'\n').encode())
                server.stop.wait(15)
        except (OSError,EOFError):
            pass


class Reader:
    def __init__(self,stream):
        self.stream=stream;self.selector=selectors.DefaultSelector();self.selector.register(stream,selectors.EVENT_READ)
        self.buffer=b'';self.queue=[]
    def message(self,timeout=3):
        deadline=time.monotonic()+timeout
        while not self.queue:
            remaining=deadline-time.monotonic()
            if remaining<=0:return None
            if not self.selector.select(remaining):return None
            chunk=os.read(self.stream.fileno(),65536)
            if not chunk:raise EOFError('helper exited')
            self.buffer+=chunk
            while b'\n' in self.buffer:
                line,self.buffer=self.buffer.split(b'\n',1);self.queue.append(json.loads(line))
        return self.queue.pop(0)
    def snapshot(self,timeout=5):
        deadline=time.monotonic()+timeout;result={'windows':[],'workspaces':[]}
        while time.monotonic()<deadline:
            message=self.message(max(0.01,deadline-time.monotonic()))
            if message is None:break
            if message['event']=='snapshot-part':
                for key in result:result[key].extend(message['data'][key])
                if message['data']['last']:return result
        raise AssertionError('no complete snapshot from helper')
    def close(self):self.selector.close()


class SocketIntegrationTests(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory();self.root=Path(self.temp.name)
        self.servers=[];self.process=None;self.reader=None
    def start(self,kind,environment):
        self.process=subprocess.Popen([sys.executable,'-B','-u',str(ENTRY),kind],
            env=dict(os.environ,**environment),stdout=subprocess.PIPE,stderr=subprocess.PIPE,start_new_session=True)
        self.reader=Reader(self.process.stdout)
        return self.reader.snapshot()
    def server(self,path,kind):
        server=FakeServer(path,kind);self.servers.append(server);return server
    def tearDown(self):
        if self.process:
            if self.process.poll() is None:os.killpg(self.process.pid,signal.SIGTERM)
            self.process.wait(timeout=3)
            self.reader.close();self.process.stdout.close();self.process.stderr.close()
        for server in self.servers:server.close()
        self.temp.cleanup()
    def test_hypr_subscribe_snapshot_bursts_and_idle_no_queries(self):
        directory=self.root/'hypr'/'fixture';directory.mkdir(parents=True)
        queries=self.server(directory/'.socket.sock','hypr')
        events=self.server(directory/'.socket2.sock','events')
        result=self.start('hyprland',{'XDG_RUNTIME_DIR':str(self.root),'HYPRLAND_INSTANCE_SIGNATURE':'fixture'})
        self.assertEqual(result['windows'][0]['id'],'0xabc')
        count=len(queries.requests)
        self.assertIsNone(self.reader.message(0.2));self.assertEqual(len(queries.requests),count)
        queries.clients[0]['title']='Changed'
        events.send(b'windowtitlev2>>abc\n'*30)
        self.assertEqual(self.reader.snapshot()['windows'][0]['title'],'Changed')
        self.assertLessEqual(len(queries.requests)-count,8)
        count=len(queries.requests)
        events.send(b'mouseMoved>>100,100\n'*30)
        self.assertIsNone(self.reader.message(0.2));self.assertEqual(len(queries.requests),count)
    def test_mango_two_watch_streams_dedup_geometry_and_reconnect(self):
        server=self.server(self.root/'mango.sock','mango')
        result=self.start('mango',{'MANGO_INSTANCE_SIGNATURE':str(self.root/'mango.sock')})
        self.assertEqual(len(result['windows']),1)
        self.assertEqual(result['windows'][0]['workspace'],'DP-1:2')
        self.assertEqual(sorted(server.requests),['watch all-clients','watch all-monitors'])
        clients=copy.deepcopy(server.clients);clients[0]['x']=99
        server.send((json.dumps({'clients':clients})+'\n').encode(),family='all-clients')
        self.assertIsNone(self.reader.message(0.25))
        clients[0]['title']='Changed'
        server.clients=clients
        server.send((json.dumps({'clients':clients})+'\n').encode(),family='all-clients')
        self.assertEqual(self.reader.snapshot()['windows'][0]['title'],'Changed')
        server.close_watches()
        reset=self.reader.message(3);self.assertEqual(reset['event'],'reset')
        self.assertEqual(self.reader.snapshot(5)['windows'][0]['title'],'Changed')
        self.assertEqual(len(server.requests),4)
    def test_sway_binary_subscription_and_window_event(self):
        server=self.server(self.root/'sway.sock','sway')
        result=self.start('sway',{'SWAYSOCK':str(self.root/'sway.sock')})
        self.assertEqual(result['windows'][0]['id'],'99')
        self.assertEqual(server.requests[0],2)
        count=len(server.requests)
        self.assertIsNone(self.reader.message(0.2));self.assertEqual(len(server.requests),count)
        server.tree['nodes'][0]['nodes'][0]['nodes'][0]['name']='Changed'
        server.send(bridge.i3_frame(0x80000003,b'{"change":"title"}'))
        self.assertEqual(self.reader.snapshot()['windows'][0]['title'],'Changed')


if __name__=='__main__':unittest.main()
