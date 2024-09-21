Gear = (function()
  local F = Flight
  local this = {
    disabled = false,
    landing = true,
    prevCmd = 0
  }

  function this.init(s)
    if not F.inSpace then
      NACM:setTargetGroundAltitude(0)
      Nav.control.deployLandingGears()
    else
      s.landing = false
    end
    s.prevCmd = startingHoverHeight/1
    unit.activateGroundEngineAltitudeStabilization(s.prevCmd)
    unit.deactivateGroundEngineAltitudeStabilization()

    KeyActions:register('start', 'gear', 'Gear', s, s.keyAction);
    s.button = HUD.buttons:createButton('Gear', "Landing Mode", KeyMaps['gear'], 'lock');
  end

  function this.keyAction(s)
    if F.keyLShift==1 then return end
    s.landing = not s.landing

    if s.landing then
      if (F.speed or 0) * 3.6 < 1000 then
        NACM:setTargetGroundAltitude(0)
        F:keyStopEngines()
        Nav.control.deployLandingGears()
        Brakes:keyAction('lock')
        Sound:play('land')
      else
        s.landing = false
      end
    else
      NACM:setTargetGroundAltitude(s.prevCmd ~= 0 and s.prevCmd or 120)
      Nav.control.retractLandingGears()
    end
    
    Hovers:update(true)
    s.button:toggle({active = s.landing and "lock" or "off"})
  end

  function this.change(s, dir, mode)
    if mode == 'start' then
      if not Gear.landing then NACM:deactivateGroundEngineAltitudeStabilization() end
    else
      if not Gear.landing then NACM:activateGroundEngineAltitudeStabilization(currentGroundAltitudeStabilization) end
    end

    NACM:updateCommandFromActionStart(axisCommandId.vertical, dir)
  end

  return this
end)()
