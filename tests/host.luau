--!nonstrict
local now, tree, renders, interval = 0, nil, 0, 0
local eventCallback, actions, notices, calls = nil, {}, {}, {}
local widgetVisible = true
local intervalWrites,lastCommandCallback = 0,nil
local vertical, output, resolverCalls = false, "DP-1", 0
local settings = table.clone(defaults)
local shellSettings,hostOutputs={},{}
local settingReads=0
local translations = {
  title = "Smart Taskbar", hint = "Click to expand • Wheel to navigate",
  disconnected = "No compositor snapshot", action_failed = "Action failed",
  unsupported_action = "Unsupported action", launcher_missing = "Launcher missing",
}
local function encode(v)
  if type(v) == "table" then
    local result = {}
    if #v > 0 then
      for _, item in ipairs(v) do table.insert(result, encode(item)) end
      return "[" .. table.concat(result, ",") .. "]"
    end
    for key, item in pairs(v) do
      if type(item) ~= "function" then table.insert(result, encode(tostring(key)) .. ":" .. encode(item)) end
    end
    return "{" .. table.concat(result, ",") .. "}"
  elseif type(v) == "string" then
    return '"' .. v:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n') .. '"'
  else return tostring(v) end
end
local ui = {}
for _, name in ipairs({ "column", "row", "image", "glyph", "label", "box", "dragSource", "dropZone" }) do
  ui[name] = function(props, children) return { kind = name, props = props or {}, children = children or {} } end
end
local noctalia = {
  getSetting = function(key) settingReads+=1; return shellSettings[key] end,
  outputs = function() return hostOutputs end,
  getConfig = function(key) assert(settings[key] ~= nil, "Undeclared config: " .. key); return settings[key] end,
  nowMs = function() return now end,
  setUpdateInterval = function(ms) interval=ms; intervalWrites+=1 end,
  log = function(_) end,
  appIconPath = function(app, _)
    resolverCalls += 1
    return app == "missing" and nil or ("fixture:" .. app)
  end,
  tr = function(key) return translations[key] or key end,
  notify = function(_, text) table.insert(notices, text) end,
  notifyError = function(_, text) table.insert(notices, text) end,
  commandExists = function(_) return true end,
  runAsync = function(argv, cb) lastCommandCallback=cb~=nil; table.insert(calls, argv); if cb then cb({ exitCode = 0, stderr = "" }) end; return true end,
  openSettings = function() table.insert(calls, "settings") end,
  compositor = {
    name = function() return "umbriel" end,
    subscribe = function(_, callback) eventCallback = callback; return 7 end,
    unsubscribe = function(id) assert(id == 7); eventCallback = nil; return true end,
  },
  umbriel = { action = function(request, cb)
    table.insert(actions, request); if cb then cb(true) end; return true
  end },
}
local barWidget = {
  setVisible = function(value) widgetVisible = value end,
  isVertical = function() return vertical end,
  outputName = function() return output end,
  render = function(value) tree = value; renders += 1 end,
  setTooltip = function(_) end,
}
