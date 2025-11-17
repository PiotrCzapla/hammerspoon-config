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
  'd',     -- Discord
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


function hideShow(name, hide, followCursor)
  local app = hs.application.get(name) -- so it does not look for partial matches
  print("Focusing on: "..name)
  if app and app:isFrontmost() then
    -- app:hide()
    -- when windows is nill
    local windows = app:allWindows()
    if (#windows == 1 or #windows == nil) and app:focusedWindow() then
      print("Hiding app")
      if hide then
        app:hide()
      else
        app:focusedWindow():minimize()
      end
    else
      print("Switching to next group")
      windows[#windows]:focus()
    end
  else
    print('Current focused app', hs.application.frontmostApplication():bundleID())
    if string.find(name, "%.") then
      print("Focusing by boundle id:"..name)
      hs.application.launchOrFocusByBundleID(name)
    else
      print("Focusing by name:"..name)
      hs.application.launchOrFocus(name)
    end
    
    -- Move window to cursor's screen if requested
    if followCursor then
      if not app then  
        app = hs.application.get(name) -- so it does not look for partial matches
      end
      if not app then 
        return
      end
      local win = app:focusedWindow()
      if win then
        local mouseScreen = hs.mouse.getCurrentScreen()
        if mouseScreen then
          win:moveToScreen(mouseScreen, false, true)
        end
      end
    end
  end
end
-----------

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
function moveWindowToDisplay(d)
  return function()
    local displays = hs.screen.allScreens()
    local win = hs.window.focusedWindow()
    win:moveToScreen(displays[d], false, true)
  end
end

function toNextDisplay()
  local win = hs.window.focusedWindow()
  local screen = win:screen()
  local frame = win:frame()
  local screenFrame = screen:frame()

  if not frame or not screenFrame or not win then
    print("Invalid frame or screenFrame.")
    return
  end

  local unitRect = nil
  local success, err = pcall(function()
    unitRect = frame:toUnitRect(screenFrame)
  end)

  if not success then
    print("Error converting to unit rect:", err)
    return
  end

  local nextScreen = screen:next()
  if not nextScreen then
    print("No next screen.")
    return
  end

  win:move(unitRect, nextScreen, true, 0)
end


hyperModeBind("1", moveWindowToDisplay(1))
hyperModeBind("2", moveWindowToDisplay(2))
hyperModeBind("3", moveWindowToDisplay(3))

hyperModeBind('n', toNextDisplay)

hyperModeBind('r', function() hideShow("Craft") end)
hyperModeBind('t', function() hideShow("Terminal") end)
hyperModeBind('v', function() hideShow("com.microsoft.VSCode") end)
hyperModeBind('b', function() hideShow("Safari") end)
hyperModeBind('f', function() hideShow("Finder") end)
hyperModeBind('d', function() hideShow("Discord") end)
hyperModeBind('p', function() hideShow("Passwords", true) end)
hyperModeBind('o', function() hideShow("1Password", true) end)
hs.hotkey.bind({}, 'f18', function() hideShow("Claude", true, true) end)
hs.hotkey.bind({}, 'f19', function() hideShow("Comet", true, true) end)
hs.hotkey.bind({}, 'f16', function() hideShow("Obsidian", true, false) end)
hyperModeBind('f18', function()
  local win = hs.window.focusedWindow()
  if win then
    local frame = win:frame()
    local center = hs.geometry.point(frame.x + frame.w / 2, frame.y + frame.h / 2)
    hs.mouse.absolutePosition(center)
  end
end)

-- local myWatcher = hs.pathwatcher.new(os.getenv('HOME') .. '/.hammerspoon/', reloadConfig):start()

hs.alert.show("Hammerspoon, at your service.", 2)

-- handy simulation for barcode scanner
-- function barcode(str)
--   return function()             
--       hs.eventtap.keyStrokes(str)
--       hs.eventtap.keyStroke({}, "return")
--   end
-- end

-- hs.hotkey.bind({"ctrl", "alt", "shift"}, "X", barcode('BLO_21750928'));
