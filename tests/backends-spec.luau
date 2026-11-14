--!nonstrict
check("geometry-only and identical native snapshots do not render",function()
  configure("expand_mode","always"); configure("display_mode","running")
  configure("workspace_filter","all"); configure("output_filter","all")
  local w=window(1,"geometry",true)
  emit({w}); now+=1000; update()
  local before=renders
  w.x=999; w.y=123; w.width=1500; w.height=900
  emit({w}); equal(renders,before)
end)
check("niri updates urgency and ignores layout-only events",function()
  local b=Compositor.new("niri")
  assert(Compositor.event(b,"WindowsChanged",{windows={{id=5,app_id="a",workspace_id=2,is_focused=false}}}))
  assert(not Compositor.event(b,"WindowsChanged",{windows={{id=5,app_id="a",workspace_id=2,is_focused=false}}}))
  assert(not Compositor.event(b,"WindowLayoutsChanged",{changes={}}))
  assert(Compositor.event(b,"WindowUrgencyChanged",{id=5,urgent=true})); equal(b.windows[1].urgent,true)
  assert(Compositor.event(b,"WindowFocusChanged",{id=5})); equal(b.windows[1].urgent,false)
  assert(not Compositor.event(b,"WindowFocusChanged",{id=5}))
  assert(not Compositor.event(b,"WindowClosed",{id=999}))
end)
check("normalized snapshots reject malformed state without replacing good windows",function()
  local b=Compositor.new("mango")
  assert(Compositor.event(b,"snapshot",{windows={{id="8",appId="a",workspace="DP-1:2",output="DP-1"}},workspaces={}}))
  assert(not Compositor.event(b,"snapshot",{windows={{title="missing identity"}},workspaces={}}))
  equal(#b.windows,1); equal(b.windows[1].id,"8")
  assert(not Compositor.event(b,"snapshot",{windows={},workspaces={17}})); equal(#b.windows,1)
end)
check("Mango multi-tag clients are counted once and match any active tag",function()
  local b=Compositor.new("mango")
  local snapshot={windows={{id="9",appId="tagged",title="A",workspace="DP-1:1",output="DP-1",
    workspaces={"DP-1:1","DP-1:2"}}},workspaces={{id="DP-1:2",output="DP-1",active=true}}}
  Compositor.event(b,"snapshot",snapshot)
  local st=Model.new(); Model.reconcile(st,Compositor.snapshot(b))
  local c=table.clone(config); c.workspace_filter="active"; c.grouping="app"; c.display_mode="running"
  local g=Model.groups(st,c,"DP-1",b.workspaces)
  equal(#g,1); equal(#g[1].windows,1)
end)
check("workspace representative icons follow focused windows and pins join member apps",function()
  local st=Model.new()
  Model.reconcile(st,{{id="1",appId="older",title="Old",workspace="ws",output="DP-1"},
    {id="2",appId="focused",title="New",workspace="ws",output="DP-1",focused=true}})
  local c=table.clone(config); c.grouping="workspace"; c.pinned_apps={"older"}; c.display_mode="running_pinned"
  local g=Model.groups(st,c,"DP-1",{})
  equal(#g,1); equal(g[1].iconId,"focused"); equal(g[1].pinned,true)
end)
check("active-only mode does not merge unrelated missing application IDs",function()
  local st=Model.new()
  Model.reconcile(st,{{id="1",appId="",focused=true},{id="2",appId=""}})
  local c=table.clone(config); c.display_mode="active"; c.grouping="app"
  equal(#Model.groups(st,c,"DP-1",{}),1)
end)
check("Hyprland, Mango and Sway actions are targeted argv with validated IDs",function()
  local h=table.clone(noctalia)
  local requests={}
  h.json={decode=function(value)
    if value=="mango" then return {success=true} elseif value=="sway" then return {{success=true}} end
  end}
  h.runAsync=function(argv,cb,timeout)
    equal(timeout,5000)
    table.insert(requests,argv)
    cb({exitCode=0,stdout=argv[1]=="mmsg" and "mango" or "sway",stderr=""}); return true
  end
  local b=Compositor.new("hyprland"); b.connected=true
  assert(Compositor.action(b,h,"focus",{id="0xabc"})); equal(requests[#requests][4],"address:0xabc")
  assert(Compositor.action(b,h,"close",{id="0xabc"})); equal(requests[#requests][3],"closewindow")
  assert(not Compositor.action(b,h,"focus",{id="0x1;launch something"}))
  assert(not Compositor.action(b,h,"minimize",{id="0xabc"}))
  b.name="mango"
  assert(Compositor.action(b,h,"focus",{id="7"})); equal(requests[#requests][4],"client,7")
  assert(Compositor.action(b,h,"close",{id="7"})); equal(requests[#requests][3],"killclient")
  assert(Compositor.action(b,h,"minimize",{id="7",minimizable=true})); equal(requests[#requests][3],"minimized")
  assert(not Compositor.action(b,h,"close",{id="7,force"}))
  b.name="sway"
  assert(Compositor.action(b,h,"close",{id="8"})); equal(requests[#requests][2],"[con_id=8]")
  equal(requests[#requests][3],"kill")
end)
check("CLI action failures include compositor-level failed replies",function()
  local h=table.clone(noctalia)
  h.json={decode=function(_) return {success=false,error="unknown target"} end}
  h.runAsync=function(_,cb) cb({exitCode=0,stdout="failure",stderr=""}); return true end
  local b=Compositor.new("mango"); b.connected=true
  local ok
  assert(Compositor.action(b,h,"focus",{id="7"},function(value) ok=value end)); equal(ok,false)
end)
check("bridge transport assembles snapshots atomically and replays without another process",function()
  local raw,starts= nil,0
  local packets={}
  local h=table.clone(noctalia)
  h.compositor={name=function() return "mango" end,subscribe=function() error("Mango has no native subscription") end,
    unsubscribe=function() return true end}
  h.getenv=function(_) return nil end
  h.pluginDir=function() return "/fixture/it's a plugin" end
  h.runStream=function(command,cb)
    assert(string.find(command,"exec python3 -B -u ",1,true)); assert(string.find(command,"'\\''",1,true))
    starts+=1; raw=cb; return true
  end
  h.json={decode=function(line) return packets[line] end}
  local t=module_transport.new(h); equal(t.native,false)
  local snapshots,resets=0,0
  local callback=function(event,data)
    if event=="snapshot" then snapshots+=1; equal(#data.windows,2)
    elseif event=="reset" then resets+=1 end
  end
  local id=t.subscribe({},callback); assert(id)
  packets.first={event="snapshot-part",data={token=1,index=1,windows={{id="1"}},workspaces={},last=false}}
  raw("first"); equal(snapshots,0)
  packets.last={event="snapshot-part",data={token=1,index=2,windows={{id="2"}},workspaces={},last=true}}
  raw("last"); equal(snapshots,1)
  t.unsubscribe(id); t.subscribe({},callback); equal(snapshots,2); equal(starts,1)
  packets.bad={event="snapshot-part",data={token=2,index=9,windows={},workspaces={},last=true}}
  raw("bad"); equal(resets,1); equal(snapshots,2)
end)
check("legacy detection recognizes each public compositor environment",function()
  local h=table.clone(noctalia); h.compositor=nil
  local env={}; h.getenv=function(k) return env[k] end
  local cases={{"UMBRIEL_SOCKET","umbriel"},{"NIRI_SOCKET","niri"},
    {"HYPRLAND_INSTANCE_SIGNATURE","hyprland"},{"MANGO_INSTANCE_SIGNATURE","mango"},{"SWAYSOCK","sway"}}
  for _,pair in ipairs(cases) do env={[pair[1]]="value"}; equal(module_transport.new(h).name,pair[2]) end
  env={NIRI_SOCKET="",XDG_CURRENT_DESKTOP="niri"}; equal(module_transport.new(h).name,"niri")
end)
