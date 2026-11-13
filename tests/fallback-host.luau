--!nonstrict
-- Model an API 52/53 host with no compositor namespace at all.
noctalia.compositor = nil
local streamCallback, streamStarts, streamCommand = nil, 0, nil
local packets, packetSerial = {}, 0
local environment = { UMBRIEL_SOCKET = "/fixture/umbriel.sock", XDG_CURRENT_DESKTOP = "umbriel" }
noctalia.getenv = function(key) return environment[key] end
noctalia.json = { decode = function(line) return packets[line] end }
noctalia.runStream = function(command, callback)
  streamStarts += 1; streamCommand = command; streamCallback = callback; return true
end
local function deliver(event, data)
  packetSerial += 1
  local line = "fixture-json-" .. tostring(packetSerial)
  -- JSON decoding is the host's public built-in, stubbed here. The real shell
  -- framing is independently exercised with actual JSON in stream_test.py.
  packets[line] = { event = event, data = data }
  streamCallback(line)
end
