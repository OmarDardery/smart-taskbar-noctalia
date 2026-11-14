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

check("niri full snapshots deduplicate IDs and reject malformed event families",function()
  local b=Compositor.new("niri")
  local windows={}
  for i=1,2000 do table.insert(windows,{id=i,app_id="a",is_focused=i==2000}) end
  table.insert(windows,windows[1]); table.insert(windows,{id="invalid"})
  assert(Compositor.event(b,"WindowsChanged",{windows=windows})); equal(#b.windows,2000)
  assert(not Compositor.event(b,"WindowsChanged",{windows=windows}))
  assert(not Compositor.event(b,"WindowsChanged",{windows=true})); equal(#b.windows,2000)
  assert(not Compositor.event(b,"WorkspacesChanged",{workspaces=true}))
  assert(not Compositor.event(b,"WindowOpenedOrChanged",{window={id=-1}}))
  assert(Compositor.event(b,"WindowOpenedOrChanged",{window={id=2001,app_id="new"}}))
  equal(#b.windows,2001)
end)
check("appearance changes preserve expansion and reuse live icon entries",function()
  configure("expand_mode","click"); emit({window(1,"a",true)})
  onClick(); equal(expanded,true)
  local before=resolverCalls
  configure("border",not config.border); equal(expanded,true); equal(resolverCalls,before)
  configure("inline_count_style","bubble"); equal(expanded,true); equal(resolverCalls,before)
  configure("inline_count_style","plain")
  emit({window(2,"b",true)})
  local entries=0; for _ in pairs(icons) do entries+=1 end; equal(entries,1)
end)
check("hover animation reuses geometry instead of scanning applications each frame",function()
  configure("expand_mode","always"); configure("hover_enlarge",true); configure("animations",true)
  emit({window(1,"a",true),window(2,"b")})
  local original=Model.layout
  local calculations=0
  Model.layout=function(...) calculations+=1; return original(...) end
  local key=groups[2].key
  find(tree,key).props.onHover("true")
  for _=1,8 do now+=20; update() end
  equal(calculations,0)
  find(tree,key).props.onHover("false")
  Model.layout=original
  configure("hover_enlarge",false)
end)
check("wheel gestures at viewport edges do not redraw unchanged content",function()
  emit({window(1,"a",true)})
  now+=1000; update()
  local before=renders
  onScroll("vertical",1,true); onScroll("vertical",-1,true)
  equal(renders,before)
end)

check("auto sizing fits bar thickness, hover peak and content scales",function()
  local c=table.clone(config); c.sizing_mode="auto"; c.sizing_bar=""; c.collapsed_label="none"
  local widgets={smart={type="omardardery/smart-taskbar:taskbar",capsule=false}}
  for _,thickness in ipairs({12,16,24,34,44,64,96}) do
    for _,scale in ipairs({0.5,1,1.6,2.5}) do
      for _,zoom in ipairs({false,true}) do
        local bars={default={thickness=thickness,position="top",scale=scale,border_width=1,start={"smart"}}}
        c.hover_enlarge=zoom; c.hover_scale=1.5
        local fit=Sizing.resolve(c,bars,widgets,"DP-1",false,{})
        assert(fit.auto_sized)
        assert((Model.peakIconSize(fit)+2*Model.cellPadding(fit))*scale<=thickness-2)
        local l=Model.layout(fit,100)
        assert(l.width*scale<=c.max_width)
      end
    end
  end
  widgets.smart.scale=2.5
  c.hover_enlarge=true
  local fit=Sizing.resolve(c,{default={thickness=12,position="top",scale=2.5,start={"smart"}}},widgets,"DP-1",false,{})
  assert((Model.peakIconSize(fit)+2*Model.cellPadding(fit))*6.25<=12)
end)
check("auto sizing resolves output overrides and ambiguous bars conservatively",function()
  local c=table.clone(config); c.sizing_mode="auto"; c.sizing_bar=""; c.hover_enlarge=false
  local widgets={smart={type="omardardery/smart-taskbar:taskbar",capsule=false}}
  local bars={small={thickness=34,position="top",start={"smart"}},
    large={thickness=64,position="top",start={"smart"},monitor={dp={match="DP-1",thickness=44}}}}
  equal(Sizing.resolve(c,bars,widgets,"DP-1",false,{}).icon_size,22)
  c.sizing_bar="large"; equal(Sizing.resolve(c,bars,widgets,"DP-1",false,{}).icon_size,32)
  bars.large.monitor.other={match="Panel",thickness=24}
  equal(Sizing.resolve(c,bars,widgets,"DP-1",false,{{name="DP-1",description="Panel"}}).icon_size,12)
end)
check("auto sizing accounts for host capsule padding and groups",function()
  local c=table.clone(config); c.sizing_mode="auto"; c.sizing_bar=""
  local widgets={smart={type="omardardery/smart-taskbar:taskbar",capsule=true,capsule_padding=6,scale=1.5}}
  local bars={default={thickness=44,position="left",scale=1,start={"smart"},capsule_thickness=0.76}}
  local fit=Sizing.resolve(c,bars,widgets,"DP-1",true,{})
  assert(fit.auto_sized)
  assert((Model.peakIconSize(fit)+2*Model.cellPadding(fit))*1.5<=33)
  assert((Model.layout(fit,100).width+12)*1.5<=c.max_width)
  bars.default.start={"group:g"}; bars.default.capsule_group={{id="g",members={"smart"}}}
  assert(Sizing.resolve(c,bars,widgets,"DP-1",true,{}).auto_sized)
end)
check("auto sizing falls back to manual for missing or incompatible placements",function()
  local c=table.clone(config); c.sizing_mode="auto"; c.sizing_bar=""
  equal(Sizing.resolve(c,nil,nil,"DP-1",false,{}),c)
  equal(Sizing.resolve(c,{default={thickness=44,start={"other"}}},{},"DP-1",false,{}),c)
  local widgets={smart={type="omardardery/smart-taskbar:taskbar"}}
  local bars={default={thickness=44,position="left",start={"smart"}}}
  equal(Sizing.resolve(c,bars,widgets,"DP-1",false,{}),c)
  c.sizing_mode="manual"; equal(Sizing.resolve(c,bars,widgets,"DP-1",true,{}),c)
end)
check("live bar sizing changes update through configuration without idle polling",function()
  shellSettings={bar={default={position="top",thickness=34,start={"smart"}}},
    widget={smart={type="omardardery/smart-taskbar:taskbar",capsule=false}}}
  configure("sizing_mode","auto"); configure("hover_enlarge",false)
  emit({window(1,"a",true)}); equal(config.icon_size,22)
  shellSettings.bar.default.thickness=44; onConfigChanged(); equal(config.icon_size,32)
  snapshot("expanded")
  local reads=settingReads
  now+=1000; update(); for _=1,100 do update() end
  equal(settingReads,reads)
  configure("sizing_mode","manual"); equal(config.icon_size,settings.icon_size)
  shellSettings={}; configure("sizing_mode","auto")
end)

check("automatic sizing uses logical pixels and compensates font scale",function()
  local c=table.clone(config); c.sizing_mode="auto"; c.sizing_bar=""
  local widgets={smart={type="omardardery/smart-taskbar:taskbar",font_scale=1.5}}
  local bars={default={thickness=44,position="top",font_scale=1.5,start={"smart"}}}
  local a=Sizing.resolve(c,bars,widgets,"DP-1",false,{{name="DP-1",scale=1}})
  local b=Sizing.resolve(c,bars,widgets,"DP-1",false,{{name="DP-1",scale=1.6}})
  equal(a.icon_size,b.icon_size); equal(a.max_width,b.max_width); equal(a.auto_text_scale,2.25)
end)

check("auto dimensions ignore all hidden manual size values",function()
  local c=table.clone(config); c.sizing_mode="auto"; c.sizing_bar=""; c.collapsed_label="title"
  local bars={default={thickness=44,position="top",start={"smart"}}}
  local widgets={smart={type="omardardery/smart-taskbar:taskbar",capsule=false}}
  local a=Sizing.resolve(c,bars,widgets,"DP-1",false,{})
  c.icon_size=48; c.icon_spacing=30; c.min_width=2048; c.collapsed_width=2000; c.capsule_radius=40
  local b=Sizing.resolve(c,bars,widgets,"DP-1",false,{})
  equal(a.icon_size,b.icon_size); equal(a.icon_spacing,b.icon_spacing)
  equal(a.min_width,b.min_width); equal(a.collapsed_width,b.collapsed_width); equal(a.capsule_radius,b.capsule_radius)
end)
