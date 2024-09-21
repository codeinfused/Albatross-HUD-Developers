Brakes = (function()
  local F = Flight
  local this = {
    locked = false,
    ap = 'off',
    labelOn = brakeToggleMode and 'Brake Toggle' or 'Brakes [Lock with ALT key]',
    labelOff = brakeToggleMode and 'Brake Toggle' or 'Brakes [Tap to Release]'
  }

  function this.init(s)
    KeyActions:register('start', 'brake', 'keyBrakeStart', F, 'keyBrakeStart');
    KeyActions:register('stop', 'brake', 'keyBrakeStop', F, 'keyBrakeStop');
    KeyActions:register('loop', 'brake', 'keyBrakeLoop', F, 'keyBrakeLoop');

    if not F.inSpace then
      s.locked = true
    end
    
    this.button1 = HUD.buttons:createButton('Brakes', s.locked and s.labelOn or s.labelOff, KeyMaps['brake'], s.locked and 'lock' or 'off');
  end

  function this.keyAction(s, force, ap)
    color = 'off'
    if ap ~= 1 then s.ap = 'off'; end

    if force=='start' then
      if brakeToggleMode then
        s.locked = not s.locked
      elseif F.keyLAlt==1 then
        s.locked = true
      else
        s.locked = false
        color = 'temp'
      end
    elseif force=='stop' then
      if ap == 1 then s.ap = 'off'; s.locked = false end
      
    elseif force=='loop' and not brakeToggleMode then
      if F.keyLAlt==1 then
        s.locked = true
      else
        color = 'temp'
      end
    elseif force=='lock' then
      if ap == 1 then s.ap = 'on' end
      s.locked = true
    end

    local longitudinalCommandType = NACM:getAxisCommandType(axisCommandId.longitudinal)
    if (longitudinalCommandType == axisCommandType.byTargetSpeed) then
      local targetSpeed = NACM:getTargetSpeed(axisCommandId.longitudinal)
      if (math.abs(targetSpeed) > constants.epsilon) then
        if force=='loop' then
          NACM:updateCommandFromActionLoop(axisCommandId.longitudinal, - utils.sign(targetSpeed))
        elseif force=='start' then
          NACM:updateCommandFromActionStart(axisCommandId.longitudinal, - utils.sign(targetSpeed))
        end
      end
    end

    if s.locked then
      color = 'lock'
    end
    s.button1:toggle({active = color, label = s.locked==true and s.labelOff or s.labelOn})
  end

  return this
end)()

