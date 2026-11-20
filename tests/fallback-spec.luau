--!nonstrict
local passed = 0
local function check(name, fn) fn(); passed += 1; print("PASS fallback " .. name) end
local function equal(a,b) assert(a==b,tostring(a).." ~= "..tostring(b)) end
local windows = {
  { id="1",app_id="firefox",title="Firefox",workspace="DP-1:1",active=true,minimized=false,minimizable=true },
  { id="2",app_id="firefox",title="Second",workspace="DP-1:1",active=false,minimized=false,minimizable=true },
}
check("starts without a native compositor namespace", function()
  update(); equal(backend.name,"umbriel"); equal(transport.native,false)
  equal(streamStarts,1); equal(streamCommand,module_transport.umbrielCommand)
end)
check("initial snapshots feed real widget and grouped focus actions", function()
  deliver("workspaces",{{id="DP-1:1",output="DP-1",active=true,focused=true}})
  deliver("windows",windows); equal(#groups,1); equal(#groups[1].windows,2)
  equal(groups[1].focused,true); onClick(); activate(groups[1])
  equal(actions[#actions].action,"window-focus"); equal(actions[#actions].window,"2")
end)
check("malformed and unrelated messages are ignored", function()
  streamCallback("not-json")
  packets.scalar=42; streamCallback("scalar")
  deliver("windows","not an array"); deliver("outputs",{})
  equal(#groups,1); equal(#groups[1].windows,2)
end)
check("stream reset clears stale windows and fresh snapshots recover", function()
  deliver("reset"); equal(#groups,0); equal(backend.connected,false)
  deliver("windows",windows); equal(#groups,1); equal(backend.connected,true)
  equal(streamStarts,1)
end)
check("compatibility toggle replays snapshots without spawning another stream", function()
  settings.compositor_compatibility="niri"; onConfigChanged(); equal(#groups,0)
  deliver("windows",{windows[1]}); equal(#groups,0)
  settings.compositor_compatibility="auto"; onConfigChanged()
  equal(#groups,1); equal(#groups[1].windows,1); equal(streamStarts,1)
end)
check("idle updates start no additional processes", function()
  now+=1000; update()
  local count=renders
  for _=1,1000 do update() end
  equal(streamStarts,1); equal(renders,count)
end)
check("desktop detection works when socket environment is absent", function()
  environment.UMBRIEL_SOCKET=nil
  equal(module_transport.new(noctalia).name,"umbriel")
end)
check("missing CLI or failed stream launch degrades without throwing", function()
  local host=table.clone(noctalia)
  host.commandExists=function(_) return false end
  equal(module_transport.new(host).subscribe({},function() end),nil)
  host.commandExists=function(_) return true end
  host.runStream=function() return false end
  equal(module_transport.new(host).subscribe({},function() end),nil)
end)
check("niri streams public JSON events without native functions", function()
  environment.XDG_CURRENT_DESKTOP="niri"; environment.NIRI_SOCKET="/fixture/niri.sock"
  local host=table.clone(noctalia)
  local rawCallback,command
  host.runStream=function(value,callback) command=value; rawCallback=callback; return true end
  local t=module_transport.new(host); equal(t.name,"niri")
  local snapshot
  assert(t.subscribe({},function(event,data) if event=="snapshot" then snapshot=data end end))
  equal(command,module_transport.niriCommand)
  packets.niri={WindowsChanged={windows={{id=9,app_id="a",title="A",workspace_id=2,is_focused=true}}}}
  rawCallback("niri"); equal(snapshot.windows[1].id,"9")
  packets.niri={WorkspacesChanged={workspaces={{id=2,output="DP-1",idx=1,is_active=true}}}}
  rawCallback("niri"); equal(snapshot.windows[1].output,"DP-1")
end)
check("exit detaches callbacks until host-owned process teardown", function()
  onExit(); deliver("reset"); equal(#groups,1)
end)
print(string.format("%d fallback compatibility tests passed",passed))
