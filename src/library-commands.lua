Commands = (function()
  local this = {
    active = false,
    label = 'Listen to Voice',
    timed = 0,
    lastCMD = '',
    list = {
      --[[travel = {
        desc = ' [Pilot in space to :pos or planet name]',
          -- travel :pos{}
          -- travel alioth
          -- travel thades moon 1
        fn = function(s, cmd)
          if not Flight.inLowSpace then 
            log("You must be in space to activate the interspace autopilot.")
            return
          end
          local target = concat(cmd, " ", 2, #cmd)
          local first = str_sub(target, 1, 1)
          local targetVec = (first==':') and getWorldFromPos(target) or AISatlas:get(target);
          -- engage space pilot to targetVec
        end
      },]]
      xyzwp = {
        desc = ' [Get waypoint from json] {"x":...}',
        fn = function(s, cmd, ov)
          local vcmd = table.remove(cmd, 1)
          local v = table.concat(cmd, ' ')
          local loc = vec3(json.deocde(v))
          local pos = "::pos{0,0,"..format('%.4f',loc.x)..","..format('%.4f',loc.y)..","..format('%.4f',loc.z).."}"
          log(pos)
        end
      },
      time = {
        desc = ' [Travel time to distance(su) from speed] time 100 30000', -- time 152.8
        fn = function(s, cmd)
          local t = (cmd[2]/1) * 200000
          local customSpeed = cmd[3]~=nil and cmd[3]/1 or nil
          local spd = customSpeed ~= nil and customSpeed or (Flight.speed * 3.6)
          if spd < 300 then spd = Flight.maxSpeed end
          local secs = timeToDist(t, spd)
          log("Time to target: "..formatTime(secs))
        end
      },
      fps = {
        desc = ' [Change HUD rendering FPS] fps 20',
        fn = function(s, cmd)
          local t = cmd[2]/1
          HUD.full:fps(t)
        end
      },
      color = {
        desc = ' [Change the HUD hex color] color #555555',
        fn = function(s, cmd, ov)
          local t = cmd[2]
          HUD:colorize(t)
          if ov=='y' then Sound:play('confirm') end
        end
      },
      opacity = {
        desc = ' [Set the opacity percentage] opacity 95',
        fn = function(s, cmd, ov)
          local t = cmd[2]
          HUD:opacitize(t)
        end
      },
      scale = {
        desc = ' [Scale UI by percentage] scale 100',
        fn = function(s, cmd, ov)
          local t = cmd[2]
          HUD:scalize(t)
        end
      },
      altitude = {
        desc = ' [Change altitude to X meters] altitude 2000',
        fn = function(s, cmd, ov)
          local v = cmd[2]:gsub("[\\,\\.]+", "")/1
          AltLock:set(v)
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
      hover = {
        fn = function(s, cmd, ov)
          local v = cmd[2]/1
          unit.activateGroundEngineAltitudeStabilization(v)
          Hovers:change(v)
        end
      },
      align = {
        desc = ' [Align to a body or ::pos] align alioth moon 4',
        fn = function(s, cmd, ov)
          local vcmd = table.remove(cmd, 1)
          local v = table.concat(cmd, ' ')
          system.print(v)
          Autopilot:align(v)
        end
      },
      go = {
        desc = ' [Autopilot to a body or ::pos] go alioth moon 4',
        fn = function(s, cmd, ov)
          local vcmd = table.remove(cmd, 1)
          local v = table.concat(cmd, ' ')
          system.print(v)
          Autopilot:go(v)
        end
      },
      cancel = {
        fn = function(s, cmd)
          Autopilot:stop()
        end
      },
      stop = {
        desc = ' [Stop the current auto-alignment]',
        fn = function(s, cmd)
          Autopilot:stop()
        end
      }
    }
  }

  function this.init(s)
    --[[
    if receiver_voice then 
      receiver_voice.setChannelList({'albhud_cmd'})
      KeyActions:register('start', 'option1', 'StartVoice', s, 'keyAction')
      KeyActions:register('tick', 'CheckVoice', 'CheckVoice', s, 'check')
      this.button1 = HUD.buttons:createButton('Voice', s.label, 'A:1', 'off')
    end
    ]]
    --[[
    -- yaml bind of receiver (old method)
    receiver_1:
        onReceived(channel, message):
            lua: |
                Commands:call(message, 'y')
    ]]
    s.helps = {}
    for cmd, o in pairs(s.list) do
      if o.desc then o.name=cmd; s.helps[#s.helps+1] = cmd end
    end
    sort(s.helps)

    --[[
    if screen_voice then 
      KeyActions:register('start', 'option1', 'StartVoice', s, 'keyAction')
      KeyActions:register('tick', 'CheckVoice', 'CheckVoice', s, 'check')
      this.button1 = HUD.buttons:createButton('Voice', s.label, 'A:1', 'off')
    end
    ]]
  end

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
