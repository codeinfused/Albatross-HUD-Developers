GroundMode = (function()
  local F = Flight
  local this = {
    active = false
  }

  function this.init(s)
    KeyActions:register('start', 'option9', 'keyAction', s, 'keyAction');
    SystemFlush:register(90, 'groundmode', GroundMode, 'flush')
    s.button = HUD.buttons:createButton('GroundMode', 'Ground Mode', 'A:9', 'off')
  end

  function this.flush(s)
    if not s.active then return end
  
    local dir = vec3() --F.down
    
    --Nav:setEngineForceCommand('airfoil vertical', dir, s.dontKeepCollinearity, '', '', '', s.tolerancePercentToSkipOtherPriorities)
    --Nav:setEngineForceCommand('airfoil vertical', dir, s.keepCollinearity, '', '', '', s.tolerancePercentToSkipOtherPriorities)
    --Nav:setEngineForceCommand('airfoil vertical', dir, s.dontKeepCollinearity, 'airfoil', 'ground', '', s.tolerancePercentToSkipOtherPriorities)
    --Nav:setEngineForceCommand('airfoil vertical', dir, s.keepCollinearity, 'airfoil', 'ground', '', s.tolerancePercentToSkipOtherPriorities)
    --Nav:setEngineForceCommand('airfoil vertical', dir, s.dontKeepCollinearity, 'airfoil', '', '', s.tolerancePercentToSkipOtherPriorities)
    --Nav:setEngineForceCommand('airfoil vertical', dir, s.keepCollinearity, 'airfoil', '', '', s.tolerancePercentToSkipOtherPriorities)
    --Nav:setEngineForceCommand('airfoil vertical', dir, s.dontKeepCollinearity, '', 'ground', '', s.tolerancePercentToSkipOtherPriorities)
    --Nav:setEngineForceCommand('airfoil vertical', dir, s.keepCollinearity, '', 'ground', '', s.tolerancePercentToSkipOtherPriorities)
  end

  function this.keyAction(s)
    if F.keyLShift==1 then return end
    s.active = not s.active
    F.groundMode = s.active
    if s.active then 
      Stabilize:keyAction(1)
      currentGroundAltitudeStabilization = 120
      NACM:updateTargetGroundAltitudeFromActionStart(120);
      Hovers:update()
      --Gear.prevCmd = 120
      --Hovers.pwr = 120
      if F.mode==0 then unit.cancelCurrentControlMasterMode() end
    end
    s.button:toggle({active = s.active and "on" or "off"})
  end

  return this
end)()