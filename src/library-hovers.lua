Hovers = (function()
  local F = Flight
  local this = {
    cmd = 0,
    max = 30
  }

  function this.init(s)
    KeyActions:register('start', 'groundaltitudeup', 'keyLiftUpStart', s, 'keyLiftUpStart');
    KeyActions:register('loop', 'groundaltitudeup', 'keyLiftUpLoop', s, 'keyLiftUpLoop');

    KeyActions:register('start', 'groundaltitudedown', 'keyLiftDownStart', s, 'keyLiftDownStart');
    KeyActions:register('loop', 'groundaltitudedown', 'keyLiftDownLoop', s, 'keyLiftDownLoop');

    local vals = unit.computeGroundEngineAltitudeStabilizationCapabilities()
    s.max = vals[1]/1
    s.cmd = uclamp(startingHoverHeight, 0, s.max)

    unit.activateGroundEngineAltitudeStabilization(0)
    s:update(true)
  end

  -- function this:keyLiftUpStart() NACM:updateTargetGroundAltitudeFromActionStart(2.0); self.update() end
  -- function this:keyLiftUpLoop() NACM:updateTargetGroundAltitudeFromActionLoop(2.0); self.update() end

  -- function this:keyLiftDownStart() NACM:updateTargetGroundAltitudeFromActionStart(-2.0); self.update() end
  -- function this:keyLiftDownLoop() NACM:updateTargetGroundAltitudeFromActionLoop(-2.0); self.update() end

  function this.keyLiftUpStart(s) s:start(1.0); s:update() end
  function this.keyLiftUpLoop(s) s:loop(1.0); s:update() end

  function this.keyLiftDownStart(s) s:start(-1.0); s:update() end
  function this.keyLiftDownLoop(s) s:loop(-1.0); s:update() end

  function this.start(s, cmd)
    NACM:updateTargetGroundAltitudeFromActionStart(cmd)
  end

  function this.loop(s, cmd)
    NACM:updateTargetGroundAltitudeFromActionLoop(cmd)
  end

  function this.full(s)
    unit.activateGroundEngineAltitudeStabilization(s.cmd)
    NACM:setTargetGroundAltitude(s.cmd)
    s:update()
  end

  function this.manual(s, percent)
    if Gear.landing then return end
    local cmd = s.max * percent
    s.cmd = cmd
    unit.activateGroundEngineAltitudeStabilization(cmd)
    NACM:setTargetGroundAltitude(cmd)
    s:update()
  end

  function this.land(s)
    unit.activateGroundEngineAltitudeStabilization(0)
    NACM:setTargetGroundAltitude(0)
    s:update()
  end

  --[[function this.set(s, cmd)
    unit.activateGroundEngineAltitudeStabilization(cmd)
  end
  ]]

  --[[function this.change(s, chg)
    s.cmd = uclamp(s.cmd + chg, 0, s.max)
    s:set(s.cmd)
  end
  ]]

  function this.update(s, noop)
    --s.pwr = s.cmd or 0 --unit.getSurfaceEngineAltitudeStabilization() or 0 -- currentGroundAltitudeStabilization
    --if noop ~= true then Gear.prevCmd = s.pwr end
    local v = unit.getSurfaceEngineAltitudeStabilization()
    if v > 1 then s.cmd = v end
    if v < 0 then v = 0 end -- set display after cmd is set
    if v > 1 then Gear:enableBtn() end
    HUD.widgets.primary.tmpl:bind({ HoverHeight = format("%.0f", v) }) --s.pwr
  end

  return this
end)()