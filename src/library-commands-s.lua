Commands = (function()
  local this = {
    active = false,
    label = 'Listen to Voice',
    timed = 0,
    lastCMD = '',

    --[[
      The name of the object in "list" is the name of the CLI command.
      If the object has a "desc", then it shows up in command list. Otherwise it's intended for voice control only.
      If the command has a voice control option, then it uses the "s:stopAction()" when activated to stop listening to voice.
      Some calls like Gear already have internal soundbytes.. if it doesn't, and is a voice command, then it should play "confirm" soundbyte.
    ]]
    list = {
      fps = {
        desc = ' [Change HUD rendering FPS] 20',
        fn = function(s, cmd)
          local t = cmd[2]/1
          HUD.full:fps(t)
        end
      },
      color = {
        desc = ' [Change the HUD hex color] #555555',
        fn = function(s, cmd, ov)
          local t = cmd[2]
          HUD:colorize(t)
          if ov=='y' then Sound:play('confirm') end
        end
      },
      opacity = {
        desc = ' [Set the opacity percentage] 95',
        fn = function(s, cmd, ov)
          local t = cmd[2]
          HUD:opacitize(t)
        end
      },
      scale = {
        desc = ' [Scale UI by percentage] 100',
        fn = function(s, cmd, ov)
          local t = cmd[2]
          HUD:scalize(t)
        end
      },
      altitude = {
        desc = ' [Change altitude to X meters] 2000',
        fn = function(s, cmd, ov)
          local v = cmd[2]:gsub("[\\,\\.]+", "")/1
          AltLock:set(v)
          s:stopAction()
          if ov=='y' then Sound:play('confirm') end
        end
      },
      agg = {
        desc = ' [Set AGG target altitude] 4100',
        fn = function(s, cmd, ov)
          local v = cmd[2]:gsub("[\\,\\.]+", "")/1
          AGG:set(v)
          s:stopAction()
          if ov=='y' then Sound:play('confirm') end
        end
      },
      landing = {
        fn = function(s, cmd, ov)
          Gear:keyAction()
          s:stopAction()
        end
      },
      warp = {
        fn = function(s, cmd, ov)
          warpdrive.initiate()
          s:stopAction()
        end
      }
      
    }
  }

  --[[
    sorts the command list into alphabetical display
    registers the voice command listener
  ]]
  function this.init(s)
    s.helps = {}
    for cmd, o in pairs(s.list) do
      if o.desc then o.name=cmd; s.helps[#s.helps+1] = cmd end
    end
    sort(s.helps)

    if screen_voice then 
      KeyActions:register('start', 'option1', 'StartVoice', s, 'keyAction')
      KeyActions:register('tick', 'CheckVoice', 'CheckVoice', s, 'check')
      this.button1 = HUD.buttons:createButton('Voice', s.label, 'A:1', 'off')
    end
  end

  --[[
    checks for voice command input
  ]]
  function this.check(s)
    s.timed = s.timed + 1
    local left = math.ceil((50-s.timed)/5)
    s.button1:toggle({label="Listening: "..left})
    if s.timed > 50 then
      s:stopAction()
      return
    end
    if screen_voice then 
      screen_voice.toggle()
    end
  end

  --[[
    display the command list into Lua tab
  ]]
  function this.help(s)
    log('-- HUD COMMANDS --')
    for i,n in ipairs(s.helps) do
      log(n..s.list[n].desc)
    end
    log('---------------------')
  end

  function this.call(s, text, ov)
    local cmd = {}
    for item in text:gmatch("%S+") do
      table.insert(cmd, item)
    end

    local t = string.lower(cmd[1])
    if t=='help' then
      s:help()
    else
      s.list[t].fn(s, cmd, ov)
    end
  end

  --[[
    these are buttons for voice command
    (voice command is a 10 second window, if a command isn't recognized in 10 seconds, it stops listening)
  ]]
  function this.keyAction(s)
    if Flight.keyLShift==1 then return end
    if s.active then
      s:stopAction()
    else
      s:startAction()
    end
  end

  function this.startAction(s)
    s.active = true
    s.timed = 0
    s.button1:toggle({active = "on", label = "Listening: 10"})
    unit.setTimer('CheckVoice', 0.2)
  end

  function this.stopAction(s)
    s.active = false
    s.button1:toggle({active = "off", label = s.label})
    unit.stopTimer('CheckVoice')
  end

  return this
end)()
