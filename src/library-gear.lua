Gear = (function()
  local F = Flight
  local this = {
    disabled = false,
    landing = true,
    prevCmd = 0
  }

  function this.init(s)
    if not F.inSpace then
      --NACM:setTargetGroundAltitude(0)
      --Hovers:change(0)
      s.landing = true
      Nav.control.deployLandingGears()
    else
      s.landing = false
      Nav.control.retractLandingGears()
    end
    --s.prevCmd = startingHoverHeight/1

    KeyActions:register('start', 'gear', 'Gear', Gear, 'keyAction');
    s.button = HUD.buttons:createButton('Gear', "Landing Mode", KeyMaps['gear'], s.landing and "lock" or "off");
  end

  function this.enableBtn(s)
    s.landing = false
    s.button:toggle({active = s.landing and "lock" or "off"})
  end

  function this.keyAction(s)
    --if F.keyLShift==1 then return end
    s.landing = not s.landing
    s.button:toggle({active = s.landing and "lock" or "off"})

    if s.landing then
      if (F.speed or 0) * 3.6 < landingSpeedConfig then -- and Throttle.previous < 3
        --currentGroundAltitudeStabilization = 0
        --NACM:setTargetGroundAltitude(0)
        --unit.activateGroundEngineAltitudeStabilization(0)
        --Hovers:change(0)
        Hovers:land()
        F:keyStopEngines(1)
        Nav.control.deployLandingGears()
        Brakes:keyAction('lock')
        Sound:play('land')
      else
        s.landing = false
      end
    else
      --unit.activateGroundEngineAltitudeStabilization(s.prevCmd ~= 0 and s.prevCmd or 120)
      --NACM:setTargetGroundAltitude(s.prevCmd ~= 0 and s.prevCmd or 120)
      --Hovers:change(100)
      Hovers:full()
      Nav.control.retractLandingGears()
    end

  end

  return this
end)()
