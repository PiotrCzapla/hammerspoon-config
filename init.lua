-- foo = hs.distributednotifications.new(function(name, object, userInfo) print(string.format("name: %s\nobject: %s\nuserInfo: %s\n", name, object, hs.inspect(userInfo))) end)
-- foo:start()


-- hattip https://github.com/lodestone/hyper-hacks
-- hattip https://gist.github.com/ttscoff/cce98a711b5476166792d5e6f1ac5907
-- hattip https://gist.github.com/prenagha/1c28f71cb4d52b3133a4bff1b3849c3e

local hyper = {'cmd','alt','shift','ctrl'}

-- A global hotkey modal to enable Hyper Mode
-- no key to enable
hyperMode = hs.hotkey.modal.new({}, nil)

hyperBindings = {
  'a',     -- Things add
  's',     -- Things add selection
  'd',     -- Dash
  'c',     -- multi clipboard
  'v',     -- ?
  'F12',    -- Mute
  '`',
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  'DOWN',
  'UP',
  'LEFT', -- right workspace
  'RIGHT', -- left workspace 
  'm', -- mute notifications
  '§', -- notification center
  ';',
  'SPACE', -- Alfred
}

function hyperModeBind(key, fn)
  hyperMode:bind({}, key, function()
    hyperMode.triggered = true;
    fn();
  end)
  hs.hotkey.bind(hyper, key, fn) 
end

for i,key in ipairs(hyperBindings) do
  hyperMode:bind({}, key, nil, function()
    hs.eventtap.keyStroke(hyper, key)
    print("Hyper mode triggered key" .. key)
    hyperMode.triggered = true
  end)
end
-- Simulates pressing escape when we have a key binding on escape
--
simpulateESCAPE = function ()
  hs.timer.doAfter(0.001, function ()
    ESCAPE:disable() 
    hs.eventtap.keyStroke({}, 'ESCAPE')
    ESCAPE:enable()
  end)
end

-- Enter Hyper Mode when ESCAPE (Hyper/Capslock) is pressed
pressedHyper = function()
  hyperMode.triggered = false
  hyperMode:enter()
end

-- Leave Hyper Mode when F18 (Hyper/Capslock) is pressed,
--   send ESCAPE if no other keys are pressed.
releasedHyper = function()
  hyperMode:exit()
  if not hyperMode.triggered then
    simpulateESCAPE()
  end
end

ESCAPE = hs.hotkey.bind({}, 'ESCAPE', pressedHyper, releasedHyper)
 
function runOSAScript(name)
  local results = hs.execute("osascript '".. os.getenv('HOME') .. "/Library/Mobile Documents/com~apple~ScriptEditor2/Documents/" .. name .. "' 2>&1", true)
  hs.alert.show(name .. " " .. results)
end

function hideShow(name)
  
  local app = hs.application.find(name)
  if app then
    print("the app was found")
    if app:isHidden() then
      app:unhide()
      app:activate()
    else
      app:hide()
    end
  else
    print("notfound")
    hs.application.open(name)
  end
end

function hideShow2(name)
  local app = hs.application.get(name) -- so it does not look for partial matches
  print("Focusing on: "..name)
  if app and app:isFrontmost() then
    print("cycle to the next window "..tostring(nextWindowInCycle))
    local windows = app:allWindows()
    windows[#windows ]:focus()
  else
    if string.find(name, "%.") then
      print("Focusing by boundle id:"..name)
      hs.application.launchOrFocusByBundleID(name)
    else
      print("Focusing by name:"..name)
      hs.application.launchOrFocus(name)
    end
  end
end

hyperModeBind('b', function() hideShow2("Safari") end)
hyperModeBind('t', function() hideShow2("iTerm") end)
hyperModeBind('v', function() hideShow2("com.microsoft.VSCode") end)
hyperModeBind('f', function() hideShow2("Craft") end)
hyperModeBind('g', function() hideShow2("Google Chrome") end)
hyperModeBind('r', function() hideShow2("Finder") end)
hyperModeBind('m', function() hideShow2("Slack") end)
hyperModeBind('z', function() hs.brightness.set(0);  print("setting brightness to 0") end)

require('layouts')

-- Reload config when any lua file in config directory changes
function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == '.lua' then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end

local myWatcher = hs.pathwatcher.new(os.getenv('HOME') .. '/.hammerspoon/', reloadConfig):start()

hs.alert.show("Hammerspoon, at your service.", 2)

-- handy simulation for barcode scanner
-- function barcode(str)
--   return function()             
--       hs.eventtap.keyStrokes(str)
--       hs.eventtap.keyStroke({}, "return")
--   end
-- end

-- hs.hotkey.bind({"ctrl", "alt", "shift"}, "X", barcode('BLO_21750928'));