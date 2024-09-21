Flight = Controller.new({
  init = function(s)
    s.pitchInput = 0
    s.rollInput = 0
    s.yawInput = 0
    s.brakeInput = 0
    s.brakeLock = 0
    s.brakeTick = 0
    s.keyLShift = 0
    s.keyLAlt = 0

    s.currentBrake = 0
    s.maxBrake = 0
    s.spitch = 0
    s.sroll = 0
    s.maxSpeed = 30000
    s.mode = 0
    s.groundMode = false
    s.mass = 0
    s.addedMass = 0
    s.tmpDMass = 0

    s.hotasThrottle = hotasThrottle:lower()
    s.pitchInvert = not pitchInvert and 1 or -1
    s.rollInvert = not rollInvert and 1 or -1
    s.yawInvert = not yawInvert and 1 or -1
    s.brakeAxisDetected = false
    s.strafeAxisDetected = false
    s.climbAxisDetected = false
    s.hoverAxisDetected = false
    s.strafeAxis = false
    s.climbAxis = false
    s.hoverAxis = false

    s.keepCollinearity = 1 -- for easier reading
    s.dontKeepCollinearity = 0 -- for easier reading
    s.tolerancePercentToSkipOtherPriorities = 1 -- if we are within this tolerance (in%), we don't go to the next priorities
    
    s.pitchSpeedFactor = 0.9 --export: This factor will increase/decrease the player input along the pitch axis<br>(higher value may be unstable)<br>Valid values: Superior or equal to 0.01
    s.yawSpeedFactor =  1 --export: This factor will increase/decrease the player input along the yaw axis<br>(higher value may be unstable)<br>Valid values: Superior or equal to 0.01
    s.rollSpeedFactor = 1.5 --export: This factor will increase/decrease the player input along the roll axis<br>(higher value may be unstable)<br>Valid values: Superior or equal to 0.01

    s.brakeSpeedFactor = 3 --export: When braking, this factor will increase the brake force by brakeSpeedFactor * velocity<br>Valid values: Superior or equal to 0.01
    s.brakeFlatFactor = 2 --export: When braking, this factor will increase the brake force by a flat brakeFlatFactor * velocity direction><br>(higher value may be unstable)<br>Valid values: Superior or equal to 0.01

    s.autoRoll = false --export: [Only in atmosphere]<br>When the pilot stops rolling,  flight model will try to get back to horizontal (no roll)
    s.autoRollFactor = 2 --export: [Only in atmosphere]<br>When autoRoll is engaged, this factor will increase to strength of the roll back to 0<br>Valid values: Superior or equal to 0.01

    s.turnAssist = true --export: [Only in atmosphere]<br>When the pilot is rolling, the flight model will try to add yaw and pitch to make the construct turn better<br>The flight model will start by adding more yaw the more horizontal the construct is and more pitch the more vertical it is
    s.turnAssistFactor = 4 --export: [Only in atmosphere]<br>This factor will increase/decrease the turnAssist effect<br>(higher value may be unstable)<br>Valid values: Superior or equal to 0.01

    s.torqueFactor = 1 -- Force factor applied to reach rotationSpeed<br>(higher value may be unstable)<br>Valid values: Superior or equal to 0.01

    s.inLowSpace = false -- Boolean: if over the atmospheric ceiling for the nearest body // Atlas::
    s.atmoDist = 0 -- Meters: distance to nearest atmo, negative is in atmo, positive is in space // Atlas::
    s.spcBrake = false -- used by burn limiter, if braking distance within atmo range
    s.apBrake = false -- used by autopilot
    s.spcAngToBody = 90 -- angle of velocity compared to gravity of nearest body

    s.forceThrottle = -1 -- used to autopilot and other widgets to set throttle

    -- lshift, lalt

    KeyActions:register('start', 'lshift', 'keyLShiftStart', s, 'keyLShiftStart')
    KeyActions:register('stop', 'lshift', 'keyLShiftStop', s, 'keyLShiftStop')
    KeyActions:register('start', 'lalt', 'keyLAltStart', s, 'keyLAltStart')
    KeyActions:register('stop', 'lalt', 'keyLAltStop', s, 'keyLAltStop')

    KeyActions:register('start', 'forward', 'keyPitchForwardStart', s, 'keyPitchForwardStart');
    KeyActions:register('stop', 'forward', 'keyPitchForwardStop', s, 'keyPitchForwardStop');

    KeyActions:register('start', 'backward', 'keyPitchBackwardStart', s, 'keyPitchBackwardStart');
    KeyActions:register('stop', 'backward', 'keyPitchBackwardStop', s, 'keyPitchBackwardStop');

    KeyActions:register('start', 'left', 'keyRollLeftStart', s, 'keyRollLeftStart');
    KeyActions:register('loop', 'left', 'keyRollLeftLoop', s, 'keyRollLeftStart');
    KeyActions:register('stop', 'left', 'keyRollLeftStop', s, 'keyRollLeftStop');

    KeyActions:register('start', 'right', 'keyRollRightStart', s, 'keyRollRightStart');
    KeyActions:register('loop', 'right', 'keyRollRightLoop', s, 'keyRollRightStart');
    KeyActions:register('stop', 'right', 'keyRollRightStop', s, 'keyRollRightStop');

    KeyActions:register('start', 'yawright', 'keyYawRightStart', s, 'keyYawRightStart');
    KeyActions:register('loop', 'yawright', 'keyYawRightLoop', s, 'keyYawRightStart');
    KeyActions:register('stop', 'yawright', 'keyYawRightStop', s, 'keyYawRightStop');

    KeyActions:register('start', 'yawleft', 'keyYawLeftStart', s, 'keyYawLeftStart');
    KeyActions:register('loop', 'yawleft', 'keyYawLeftLoop', s, 'keyYawLeftStart');
    KeyActions:register('stop', 'yawleft', 'keyYawLeftStop', s, 'keyYawLeftStop');

    KeyActions:register('start', 'strafeleft', 'keyStrafeLeftStart', s, 'keyStrafeLeftStart');
    KeyActions:register('stop', 'strafeleft', 'keyStrafeLeftStop', s, 'keyStrafeLeftStop');
    KeyActions:register('start', 'straferight', 'keyStrafeRightStart', s, 'keyStrafeRightStart');
    KeyActions:register('stop', 'straferight', 'keyStrafeRightStop', s, 'keyStrafeRightStop');

    KeyActions:register('start', 'stopengines', 'keyStopEngines', s, 'keyStopEngines');

    KeyActions:register('start', 'booster', 'keyBoostersToggle', s, 'keyBoostersToggle');
    KeyActions:register('stop', 'booster', 'keyBoostersToggle', s, 'keyBoostersToggle');

    KeyActions:register('start', 'speedup', 'keySpeedUpLoop', s, 'keySpeedUpLoop');
    KeyActions:register('loop', 'speedup', 'keySpeedUpLoop', s, 'keySpeedUpLoop');
    KeyActions:register('start', 'speeddown', 'keySpeedDownLoop', s, 'keySpeedDownLoop');
    KeyActions:register('loop', 'speeddown', 'keySpeedDownLoop', s, 'keySpeedDownLoop');

    KeyActions:register('start', 'up', 'keyManualLiftUpStart', s, 'keyManualLiftUpStart')
    KeyActions:register('stop', 'up', 'keyManualLiftUpStop', s, 'keyManualLiftUpStop')
    KeyActions:register('start', 'down', 'keyManualLiftDownStart', s, 'keyManualLiftDownStart')
    KeyActions:register('stop', 'down', 'keyManualLiftDownStop', s, 'keyManualLiftDownStop')

    --KeyActions:register('tick', 'SystemUpdate', 'SystemUpdate', s, 'update');
    KeyActions:register('system', 'update', 'SystemUpdate', s, 'update');
    --unit.setTimer('SystemUpdate', 0.05);

    KeyActions:register('tick', 'SlowUpdate', 'SlowUpdate', s, 'slowUpdate');
    unit.setTimer('SlowUpdate', 0.5);

    s.DockProcessor = coroutine.create(s.updateDock)
    KeyActions:register('tick', 'DockUpdate', 'DockUpdate', s, 'coUpdateDock');
    unit.setTimer('DockUpdate', 0.15);

    s:validate(true);
  end,

  coUpdateDock = function(s)
    local cont = coroutine.status(s.DockProcessor)
    if cont ~= "dead" then 
      local value, done = coroutine.resume(s.DockProcessor)
      if done then log("ERROR UPDATE FUEL: "..done) end
    elseif cont == "dead" then
      s.DockProcessor = coroutine.create(s.updateDock)
      local value, done = coroutine.resume(s.DockProcessor)
    end
  end,

  updateDock = function()
    local s = Flight
    local boarded = construct.getPlayersOnBoard()
    local docked = construct.getDockedConstructs()
    s.tmpDMass = 0

    for k,id in ipairs(boarded) do
      s.tmpDMass = s.tmpDMass + construct.getBoardedPlayerMass(id)
      coroutine.yield()
    end
    for k,id in ipairs(docked) do
      s.tmpDMass = s.tmpDMass + construct.getDockedConstructMass(id)
      coroutine.yield()
    end

    s.addedMass = s.tmpDMass
  end,

  keyLShiftStart = function(s) s.keyLShift = 1 end,
  keyLShiftStop = function(s) s.keyLShift = 0 end,
  keyLAltStart = function(s) s.keyLAlt = 1 end,
  keyLAltStop = function(s) s.keyLAlt = 0 end,

  keyPitchForwardStart = function(s) s.pitchInput = - 1 end,
  keyPitchForwardStop = function(s) s.pitchInput = 0 end,

  keyPitchBackwardStart = function(s) s.pitchInput = 1 end,
  keyPitchBackwardStop = function(s) s.pitchInput = 0 end,

  keyRollLeftStart = function(s) s.rollInput = - 1 end,
  keyRollLeftStop = function(s) s.rollInput = 0 end,

  keyRollRightStart = function(s) s.rollInput = 1 end,
  keyRollRightStop = function(s) s.rollInput =0 end,

  keyYawRightStart = function(s) s.yawInput = - 1 end,
  keyYawRightStop = function(s) s.yawInput = 0 end,

  keyYawLeftStart = function(s) s.yawInput = 1 end,
  keyYawLeftStop = function(s) s.yawInput = 0 end,

  keyStrafeLeftStart = function(s) NACM:updateCommandFromActionStart(axisCommandId.lateral, -1.0) end,
  keyStrafeLeftStop = function(s) NACM:updateCommandFromActionStop(axisCommandId.lateral, 1.0) end,
  keyStrafeRightStart = function(s) NACM:updateCommandFromActionStart(axisCommandId.lateral, 1.0) end,
  keyStrafeRightStop = function(s) NACM:updateCommandFromActionStop(axisCommandId.lateral, -1.0) end,

  keyBrakeStart = function(s) s.brakeInput = 1; Brakes:keyAction('start') end,
  keyBrakeStop = function(s) s.brakeInput = 0; Brakes:keyAction('stop') end, 
  keyBrakeLoop = function(s) s.brakeInput = 1; Brakes:keyAction('loop') end,
  --keyBrakeLoop = function(self) 
    --self.brakeTick = self.brakeTick + 1; 
    --if self.brakeTick > 70 then 
      --self.brakeLock = 1 
      --Brakes:keyAction(true) 
    --end 
  --end,

  keyStopEngines = function(s, manual)
    if s.mode==0 and s.keyLAlt==1 and manual~=1 then
      -- instant full speed throttler
      NACM:setThrottleCommand(axisCommandId.longitudinal, 1)
      unit.setAxisCommandValue(axisCommandId.longitudinal, 1)
    elseif Throttle.real ~= 0 then
      NACM:resetCommand(axisCommandId.longitudinal) 
    end
  end,

  keyBoostersToggle = function(s) Nav:toggleBoosters() end,

  keySpeedUpLoop = function(s) NACM:updateCommandFromActionLoop(axisCommandId.longitudinal, 1.0) end,
  keySpeedDownLoop = function(s) NACM:updateCommandFromActionLoop(axisCommandId.longitudinal, -1.0) end,

  keyManualLiftUpStart = function(s)
    --Gear:change(1.0, 'start')
    if s.keyLAlt==1 then return end
    NACM:deactivateGroundEngineAltitudeStabilization()
    NACM:updateCommandFromActionStart(axisCommandId.vertical, 1.0)
  end,
  keyManualLiftUpStop = function(s)
    --Gear:change(-1.0, 'stop')
    if s.keyLAlt==1 then return end
    NACM:updateCommandFromActionStop(axisCommandId.vertical, -1.0)
    NACM:activateGroundEngineAltitudeStabilization(currentGroundAltitudeStabilization)
  end,
  keyManualLiftDownStart = function(s)
    --Gear:change(-1.0, 'start')
    if s.keyLAlt==1 then return end
    NACM:deactivateGroundEngineAltitudeStabilization()
    NACM:updateCommandFromActionStart(axisCommandId.vertical, -1.0)
  end,
  keyManualLiftDownStop = function(s)
    --Gear:change(1.0, 'stop')
    if s.keyLAlt==1 then return end
    NACM:updateCommandFromActionStop(axisCommandId.vertical, 1.0)
    NACM:activateGroundEngineAltitudeStabilization(currentGroundAltitudeStabilization)
  end,


  --[[
    FLIGHT HELPERS
    ----------------------------------
  ]]

  reticleFwd = function(s)
    local p = s.position+(s.forward*4*s.velocity:len());
    --local x,y,z = shipForward.x, shipForward.y, shipForward.z;
    --local o = {x,y,z};
    local o ={p.x, p.y, p.z};
    local spos = library.getPointOnScreen( o );
    if spos[1]<.01 and spos[2]<.01 then return "" end
    return [[
<g class="rcon" style="transform:translate(]]..((spos[1]*100)-1.18)..[[vw,]]..((spos[2]*100)-0.9)..[[vh); fill:#fff;">      
<svg x="0px" y="0px" viewBox="0 0 177 150" height="2.4%" width="2.4%" style="fill:#fff;">
<path d="M50.7,60l26.5-46c1-1.7,0.4-3.8-1.3-4.8c-1.7-1-3.8-0.4-4.8,1.3l-55.9,96.9c-1,1.7-0.4,3.8,1.3,4.8
 c0.6,0.3,1.2,0.5,1.7,0.5c1.2,0,2.4-0.6,3-1.8l25.9-44.8L50.7,60z"/>
<path d="M164.7,107.4l-55.9-96.9c-1-1.7-3.1-2.2-4.8-1.3c-1.7,1-2.2,3.1-1.3,4.8l26.5,45.8l3.5,6.1l26,45c0.6,1.1,1.8,1.8,3,1.8
 c0.6,0,1.2-0.2,1.7-0.5C165.1,111.3,165.7,109.1,164.7,107.4z"/>
<path d="M145.9,133H93h-7H34.1c-1.9,0-3.5,1.6-3.5,3.5s1.6,3.5,3.5,3.5h111.9c1.9,0,3.5-1.6,3.5-3.5S147.9,133,145.9,133z"/>
</svg>
</g>
    ]];
  end,

  reticlePro = function(s)
    local p = s.position+(s.velocity*5); -- math.max( self.position+(self.forward), self.velocity*2 );
    --local x,y,z = shipPrograde.x, shipPrograde.y, shipPrograde.z;
    --local o = {x,y,z};
    local o ={p.x, p.y, p.z};
    local spos = library.getPointOnScreen( o );
    if spos[1]<.01 and spos[2]<.01 then return "" end
    return [[
<g class="rcon" style="transform:translate(]]..((spos[1]*100)-1.18)..[[vw,]]..((spos[2]*100)-1.1)..[[vh); fill:#fff;">      
<svg x="0px" y="0px" viewBox="0 0 177 150" height="2.4%" width="2.4%" style="fill:#fff;">
<path d="M116.1,67.5C110.3,59.3,100.8,54,90,54c-10.8,0-20.4,5.4-26.1,13.6L50.7,60l-3.5,6.1l13.2,7.6c-1.6,3.8-2.5,8-2.5,12.3
	c0,16.3,12.2,29.8,28,31.7V133h7v-15.1c16.3-1.5,29-15.2,29-31.9c0-4.4-0.9-8.6-2.5-12.4l13.2-7.6l-3.5-6.1L116.1,67.5z M90,111
	c-13.8,0-25-11.2-25-25s11.2-25,25-25s25,11.2,25,25S103.8,111,90,111z"/>
</svg>
</g>
    ]];
  end,

  reticleRtr = function(s)
    local p = s.position+(-s.velocity*5); --math.max( self.position+(self.forward), -self.velocity*2 );
    --local x,y,z = shipRetrograde.x, shipRetrograde.y, shipRetrograde.z;
    --local o = {x,y,z};
    local o ={p.x, p.y, p.z};
    local spos = library.getPointOnScreen( o );
    if spos[1]<.01 and spos[2]<.01 then return "" end
    return [[
<g class="rcon" style="transform:translate(]]..((spos[1]*100)-1.18)..[[vw,]]..((spos[2]*100)-1.1)..[[vh); fill:#ff0000;">      
<svg x="0px" y="0px" viewBox="0 0 177 150" height="2.4%" width="2.4%" style="fill:#ff0000;">
<path d="M116.1,67.5C110.3,59.3,100.8,54,90,54c-10.8,0-20.4,5.4-26.1,13.6L50.7,60l-3.5,6.1l13.2,7.6c-1.6,3.8-2.5,8-2.5,12.3
	c0,16.3,12.2,29.8,28,31.7V133h7v-15.1c16.3-1.5,29-15.2,29-31.9c0-4.4-0.9-8.6-2.5-12.4l13.2-7.6l-3.5-6.1L116.1,67.5z M90,111
	c-13.8,0-25-11.2-25-25s11.2-25,25-25s25,11.2,25,25S103.8,111,90,111z"/>
</svg>
</g>
    ]];
  end,

  reticleBody = function(s)
    local p = Autopilot.alignTarget
    local dist = s.position:dist(p) --s.position:dist(vec3(p))
    
    --local vh = system.getScreenHeight()
    --local fov = system.getCameraVerticalFov()
    --local px = dist / fov
    --local scale = px / vh / 3 -- this is wrong, size needs to be inversely proportional to distance
    -- // ((spos[1]*100)-(scale*100/2)), scale=()

    local o = {p.x, p.y, p.z};
    local spos = library.getPointOnScreen( o );
    if spos[1]<.01 and spos[2]<.01 then return "" end
    
    return [[
<g class="rcon" style="transform:translate(]]..((spos[1]*100)-1.68)..[[vw,]]..((spos[2]*100)-1.6)..[[vh); fill:#7cc47c;">
<svg viewBox="0 0 300 203" style="fill:#7cc47c;" height="3.4%" width="3.4%"><path d="m214.6 101.5 11-11.1v-10l-21.1 21.1 21.1 21.1v-10.1zM85.4 101.5l-11-11.1v-10l21.1 21.1-21.1 21.1v-10.1zM150 166.1l11 11h10.1L150 156l-21.1 21.1H139zM150 36.9l11-11h10.1l-21.1 21-21.1-21H139z"/><path d="M124 203H41.7L0 101.5 41.7 0H124v12.8H50.3l-36.4 88.7 36.4 88.6H124zM258.3 203H176v-12.9h73.7l36.4-88.6-36.4-88.7H176V0h82.3L300 101.5z"/></svg>
</g>
]]
  end,


  --[[
    FLUSH & UPDATE FUNCTIONS
    ----------------------------------
  ]]

  update = function(s)
    s.position = vec3(construct.getWorldPosition())
    s.mass = construct.getMass() + s.addedMass
    --s.imass = construct.getInertialMass()
    s.gravity = core.getGravityIntensity() -- 10 = 1g, 
    s.altitude = core.getAltitude()
    s.inSpace = (s.altitude==0.0 or s.altitude>90000) -- detect "outer" space --self.altitude > 400000 or self.altitude == 0.0 or self.atmoDensity < .03 -- atmo density is super low the moment you transfer into true space

    if RadarSwitch and RadarSwitch.active>1 then 
      if RadarSwitch.activet=='space' and not s.inSpace then RadarSwitch:force('atmo') end
      if RadarSwitch.activet=='atmo' and s.inSpace then RadarSwitch:force('space') end
    end

    --local mx = system.getMouseDeltaX()
    --local my = system.getMouseDeltaY()

    local retFwd = ''
    local retPro = ''
    local retRtr = ''
    local retBody = '' --self:reticleBody()

    if(s.velocity) then
      s.speed = s.velocity:len()
      s.speedForward = s.forward:dot(s.velocity) -- self.velocity:dot( self.forward ) -- m/s
      s.speedUp = -s.worldVertical:dot(s.velocity) -- self.velocity:dot( -self.gravityDirection ); -- m/s
      s.accel = s.acceleration:len()

      --retFwd = s:reticleFwd();
      if(s.speed > 5 and showReticles) then
        retPro = s:reticlePro()
        retRtr = s:reticleRtr()
        retFwd = s:reticleFwd()
        if Autopilot.apState=='on' then
          -- TODO: this reticle render was causing an error
          --retBody = s:reticleBody()
        end
      end

      if s.forceThrottle == 0 then
        unit.setAxisCommandValue(0, 0.0)
        NACM:resetCommand(axisCommandId.longitudinal)
      elseif s.forceThrottle > 0 then
        NACM:setThrottleCommand(axisCommandId.longitudinal, s.forceThrottle)
        unit.setAxisCommandValue(axisCommandId.longitudinal, s.forceThrottle)
      end
      s.forceThrottle = -1

      if(s.maxSpeed and (s.speed*3.6)+50 >= s.maxSpeed and Throttle.real >= 1 and s.facingdiff < 0.25 ) then
        NACM:resetCommand(axisCommandId.longitudinal);
      end

      if burnSpeedLimiter and s.atmoDist and s.inLowSpace and s.speedUp < -100 and (s.speed*3.6) > (s.burnSpeed*0.92) then
        local spD, spT = calcBrakeDist2(s.burnSpeed*0.95)
        s.spcBrake = spD >= abs(s.atmoDist)

        if Throttle.real > 10 and s.spcBrake and s.inSpace then
          unit.setAxisCommandValue(0, 0.0)
          NACM:resetCommand(axisCommandId.longitudinal);
        end
      else
        s.spcBrake = false
      end
    end

    local al = 0;
    if(s.altitude > 1000) then
      al = format("%.2f", s.altitude/1000) .. "km";
    else
      al = format("%.0f", (s.altitude or 0)) .. "m";
    end

    HUD.widgets.primary.tmpl:bind({
      VelocitySpeed = format("%.0f", (s.speed or 0) * 3.6),
      VelocityUp = format("%.0f", (s.speedUp and (s.speedUp<-1 or s.speedUp>0)) and s.speedUp or 0),
      Acceleration = format("%.0f", (s.accel or 0) * 3.6),
      Altitude = al,
      ReticleFwd = retFwd,
      ReticlePro = retPro,
      ReticleRtr = retRtr,
      ReticleBody = retBody,
      SpcBrake = s.spcBrake and "on" or "off"
    });
  end,

  slowUpdate = function(s)
    local C = construct
    s.atmoDensity = unit.getAtmosphereDensity()
    s.closestInfluence = unit.getClosestPlanetInfluence()
    s.maxSpeed = floor(construct.getMaxSpeed()*3.6)
    s.burnSpeed = floor(construct.getFrictionBurnSpeed()*3.6)
    if burnSpeedMax > 1000 then s.burnSpeed = burnSpeedMax end
    s.zoneDist = construct.getDistanceToSafeZone()

    local boarded = construct.getPlayersOnBoard()
    local docked = construct.getDockedConstructs()
    s.boarded = #boarded
    s.docked = #docked

    s.facingdiff = 2
    if s.forward then
      s.facingdiff = s.forward:angle_between(s.velocityDirection)
    end

    gravity = 30
    if AISatlas and AISatlas.body then
      gravity = AISatlas.body.gravity/1 or gravity; -- max potential gravity for nearest planet --core.getGravityIntensity()
    end

    local axisCRefDirection = vec3(construct.getOrientationForward())
    local maxKPAlongAxis = C.getMaxThrustAlongAxis('thrust analog longitudinal ', {axisCRefDirection:unpack()})
    local axisCRefDirection = vec3(C.getOrientationUp())
    local maxKPAlongAxis = C.getMaxThrustAlongAxis('hover_engine, booster_engine', {axisCRefDirection:unpack()})
    s.safeLocalMass = 0.45*maxKPAlongAxis[1]/gravity
    s.safeLocalMass = format("%.0f", (s.safeLocalMass/1000))
    s.safeAtmoMass = 0.45*maxKPAlongAxis[1]/10
    s.safeAtmoMass = format("%.0f", (s.safeAtmoMass/1000))
    s.safeSpaceMass = 0.45*maxKPAlongAxis[3]/gravity
    s.safeSpaceMass = format("%.0f", (s.safeSpaceMass/1000))
    s.safeHoverMass = 0.45*maxKPAlongAxis[1]/gravity
    --s.airResist = floor(construct.getWorldAirFrictionAcceleration())

    HUD.widgets.primary.tmpl:bind({
      AtmoDensity = format("%.3f",s.atmoDensity),
      MaxSpeed = s.maxSpeed,
      BurnSpeed = s.burnSpeed,
      BoardedCt = s.boarded,
      DockedCt = s.docked,
      SafeLocalMass = s.safeLocalMass,
      SafeAtmoMass = s.safeAtmoMass,
      SafeSpaceMass = s.safeSpaceMass,
      ZoneDistLabel = s.zoneDist < 0 and "PVP SPACE IN" or "SAFE ZONE IN",
      ZoneDist = formatDist(abs(s.zoneDist))
    })
    -- if (shipPos-safeWorldPos):len() < safeRadius then inSafeZone=true else inSafeZone = false end
  end,

  validate = function(s, firstRun)
    s.pitchSpeedFactor = math.max(s.pitchSpeedFactor, 0.01)
    s.yawSpeedFactor = math.max(s.yawSpeedFactor, 0.01)
    s.rollSpeedFactor = math.max(s.rollSpeedFactor, 0.01)
    s.torqueFactor = math.max(s.torqueFactor, 0.01)
    s.brakeSpeedFactor = math.max(s.brakeSpeedFactor, 0.01)
    s.brakeFlatFactor = math.max(s.brakeFlatFactor, 0.01)
    s.autoRollFactor = math.max(s.autoRollFactor, 0.01)
    s.turnAssistFactor = math.max(s.turnAssistFactor, 0.01)

    local gAV0, gAV1, gAV2, gAV3, gAV4, gAV5, gAV6, gAV7, gAV8, gAV9 = 0, 0, 0, 0, -1, 0, 0, 0, 0, 0 -- 3 is defined in Throttle Class
    if enableHOTAS then
      gAV0 = system.getAxisValue(0) -- roll
      gAV1 = -system.getAxisValue(1) -- pitch
      gAV2 = -system.getAxisValue(2) -- yaw
      gAV4 = system.getAxisValue(4) -- brakes, full range
      gAV5 = system.getAxisValue(5) -- strafe, half range
      gAV6 = system.getAxisValue(6) -- up/down, half range
      gAV7 = system.getAxisValue(7) -- hover height, full range
      --gAV8, 
      --gAV9

      if gAV4 ~= 0 then s.brakeAxisDetected = true end
      if gAV5 ~= 0 then s.strafeAxisDetected = true end
      if gAV6 ~= 0 then s.climbAxisDetected = true end
      if gAV7 ~= 0 then s.hoverAxisDetected = true end
    end
    
    -- Flight Control Inputs
    s.finalRollInput = s.rollInput + (s.rollInvert * gAV0) + system.getControlDeviceYawInput()
    s.finalPitchInput = s.pitchInput + (s.pitchInvert * gAV1) + system.getControlDeviceForwardInput()
    s.finalYawInput = ( s.yawInput + (s.yawInvert * gAV2) ) - system.getControlDeviceLeftRightInput()

    -- Brake Control Inputs
    local joyBrakeInput = s.brakeAxisDetected and (gAV4 + 1) / 2 or 0
    local brakeControl = Brakes.locked and 1 or s.brakeInput
    s.finalBrakeInput = brakeControl==1 and 1 or joyBrakeInput

    -- HOTAS Only Translation Inputs
    if enableHOTAS then
      s.strafeAxis = gAV5
      s.climbAxis = gAV6
      s.hoverAxis = (gAV7 + 1) / 2

      if s.strafeAxisDetected then
        NACM:setThrottleCommand(axisCommandId.lateral, s.strafeAxis)
        unit.setAxisCommandValue(axisCommandId.lateral, s.strafeAxis)
      end

      if s.climbAxisDetected then
        NACM:setThrottleCommand(axisCommandId.vertical, s.climbAxis)
        unit.setAxisCommandValue(axisCommandId.vertical, s.climbAxis)
      end

      if not firstRun and s.hoverAxisDetected then Hovers:manual(s.hoverAxis) end
    end

    -- Cruise Control Defaults
    s.autoNavigationEngineTags = ''
    s.autoNavigationAcceleration = vec3()
    s.autoNavigationUseBrake = false
  end,

  flush = function(s)
    s.up = vec3(construct.getWorldOrientationUp())
    s.down = -s.up
    s.forward = vec3(construct.getWorldOrientationForward())
    s.back = -s.forward
    s.right = vec3(construct.getWorldOrientationRight())
    s.left = -s.right
    
    s.gravityDirection = vec3(core.getWorldGravity())
    s.worldVertical = vec3(core.getWorldVertical())
    
    s.velocity = vec3(construct.getWorldVelocity())
    s.velocityDirection = s.velocity:normalize()
    s.acceleration = vec3(construct.getWorldAcceleration())

    Flight:getSelfRoll()
    Flight:getSelfPitch()
  end,

  getPitch = function(gravDir, forward, right)
    local horForward = gravDir:cross(right):normalize_inplace() -- Cross forward?
    local spitch = math.acos(uclamp(horForward:dot(-forward), -1, 1)) * constants.rad2deg -- acos?
    if horForward:cross(-forward):dot(right) < 0 then spitch = -spitch end
    return spitch
  end,

  getSelfPitch = function(s)
    --[[
    local horForward = self.worldVertical:cross(self.right):normalize_inplace() -- Cross forward?
    local spitch = math.acos(uclamp(horForward:dot(-self.forward), -1, 1)) * constants.rad2deg -- acos?
    if horForward:cross(-self.forward):dot(self.right) < 0 then
      spitch = -spitch
    end
    ]]
    local radianRoll = s.radr
    local corrX = math.cos(radianRoll)
    local corrY = math.sin(radianRoll)
    local adjustedPitch = s.getPitch(s.worldVertical, s.forward, (s.right * corrX) + (s.up * corrY)) 

    s.spitch = uclamp(adjustedPitch,-90,90)
  end,

  getSelfRoll = function(s)
    s.sroll = s.currentRollDeg or 0 --getRoll(self.worldVertical, self.forward, self.right)
    s.radr = (s.sroll / 180) * math.pi
  end,

  rotation = function(s)
    s.currentRollDeg = getRoll(s.worldVertical, s.forward, s.right)
    s.currentRollDegAbs = math.abs(s.currentRollDeg)
    s.currentRollDegSign = utils.sign(s.currentRollDeg)

    s.constructAngularVelocity = vec3(construct.getWorldAngularVelocity())
    s.targetAngularVelocity = s.finalPitchInput * s.pitchSpeedFactor * s.right
                                + s.finalRollInput * s.rollSpeedFactor * s.forward
                                + s.finalYawInput * s.yawSpeedFactor * s.up;
    
    if s.worldVertical:len() > 0.01 and s.atmoDensity > 0.0 then
      s.autoRollRollThreshold = 1.0
      -- autoRoll on AND currentRollDeg is big enough AND player is not rolling
      if s.autoRoll == true and s.currentRollDegAbs > s.autoRollRollThreshold and s.finalRollInput == 0 then
        s.targetRollDeg = utils.clamp(0,s.currentRollDegAbs-30, s.currentRollDegAbs+30);  -- we go back to 0 within a certain limit
        if (s.rollPID == nil) then
          s.rollPID = pid.new(s.autoRollFactor * 0.01, 0, s.autoRollFactor * 0.1) -- magic number tweaked to have a default factor in the 1-10 range
        end
        s.rollPID:inject(s.targetRollDeg - s.currentRollDeg)
        s.autoRollInput = s.rollPID:get()

        s.targetAngularVelocity = s.targetAngularVelocity + s.autoRollInput * s.forward
      end
      s.turnAssistRollThreshold = 20.0
      -- turnAssist AND currentRollDeg is big enough AND player is not pitching or yawing
      if s.turnAssist == true and s.currentRollDegAbs > s.turnAssistRollThreshold and s.finalPitchInput == 0 and s.finalYawInput == 0 then
        s.rollToPitchFactor = s.turnAssistFactor * 0.1 -- magic number tweaked to have a default factor in the 1-10 range
        s.rollToYawFactor = s.turnAssistFactor * 0.025 -- magic number tweaked to have a default factor in the 1-10 range

        -- rescale (turnAssistRollThreshold -> 180) to (0 -> 180)
        s.rescaleRollDegAbs = ((s.currentRollDegAbs - s.turnAssistRollThreshold) / (180 - s.turnAssistRollThreshold)) * 180
        s.rollVerticalRatio = 0
        if s.rescaleRollDegAbs < 90 then
          s.rollVerticalRatio = s.rescaleRollDegAbs / 90
        elseif s.rescaleRollDegAbs < 180 then
          s.rollVerticalRatio = (180 - s.rescaleRollDegAbs) / 90
        end

        s.rollVerticalRatio = s.rollVerticalRatio * s.rollVerticalRatio

        s.turnAssistYawInput = - s.currentRollDegSign * s.rollToYawFactor * (1.0 - s.rollVerticalRatio)
        s.turnAssistPitchInput = s.rollToPitchFactor * s.rollVerticalRatio

        s.targetAngularVelocity = s.targetAngularVelocity
          + s.turnAssistPitchInput * s.right
          + s.turnAssistYawInput * s.up;
      end
    end

    --[[
      if autoMode == "level" then 
          targetAngularVelocity = worldVertical:cross(constructUp) + (finalPitchInput ) * pitchSpeedFactor * constructRight + finalRollInput * rollSpeedFactor * constructForward + finalYawInput * yawSpeedFactor * constructUp
      elseif autoMode == "normal+" then
          targetAngularVelocity = worldVertical:cross(constructForward) + (finalPitchInput ) * pitchSpeedFactor * constructRight + finalRollInput * rollSpeedFactor * constructForward + finalYawInput * yawSpeedFactor * constructUp
      elseif autoMode == "normal-" then
          targetAngularVelocity = -worldVertical:cross(constructForward) + (finalPitchInput ) * pitchSpeedFactor * constructRight + finalRollInput * rollSpeedFactor * constructForward + finalYawInput * yawSpeedFactor * constructUp
      elseif autoMode  == "retro" then  
          local constructVelocityDir = vec3(construct.getWorldVelocity()):normalize()     
          targetAngularVelocity = (constructVelocityDir:cross(constructForward)) + finalPitchInput * pitchSpeedFactor * constructRight + finalRollInput * rollSpeedFactor * constructForward + finalYawInput * yawSpeedFactor * constructUp
      elseif autoMode  == "pro" then  
          local constructVelocityDir = vec3(construct.getWorldVelocity()):normalize()     
          targetAngularVelocity = (-constructVelocityDir:cross(constructForward)) + finalPitchInput * pitchSpeedFactor * constructRight + finalRollInput * rollSpeedFactor * constructForward + finalYawInput * yawSpeedFactor * constructUp
      end  
    ]]
  end,

  torque = function(s)
    s.angularAcceleration = s.torqueFactor * (s.targetAngularVelocity - s.constructAngularVelocity)
    s.airAcceleration = vec3(construct.getWorldAirFrictionAngularAcceleration())
    s.angularAcceleration = s.angularAcceleration - s.airAcceleration -- Try to compensate air friction
    local tags = 'torque'
    Nav:setEngineTorqueCommand(tags, s.angularAcceleration, s.keepCollinearity, 'airfoil', '', '', s.tolerancePercentToSkipOtherPriorities)
  end, -- end rotation

  brakes = function(s)
    if s.burnSpeed and s.speed and burnSpeedLimiter then
      if not s.inLowSpace and s.speed*3.6 >= max(1200, s.burnSpeed-50) then
        if s.speedUp >= -30 and s.atmoDensity <= 0.03 then
        else
          s.finalBrakeInput = 1
        end
      end
      if s.spcBrake==true or s.apBrake==true then s.finalBrakeInput = 1 end
    end

    s.brakeAcceleration = -s.finalBrakeInput * (s.brakeSpeedFactor * s.velocity + s.brakeFlatFactor * s.velocityDirection)
    --if(s.finalBrakeInput == 0) then
      --self.brakeAcceleration = -50 * (self.brakeSpeedFactor * self.brakeFlatFactor * self.worldVertical)
    --end
    Nav:setEngineForceCommand('brake', s.brakeAcceleration)

    --[[
    -- dx, dy and dz is the direction vector values.
    local brakeForce = s.maxBrake
    local mass = s.mass
    local maxAccMag = brakeForce/mass

    local dx, dy, dz = s.velocityDirection:unpack()

    -- Brakes
    local finalBrakeFlatFactor = -s.finalBrakeInput * maxAccMag
    local brakeAcceleration = {
        finalBrakeFlatFactor * dx,
        finalBrakeFlatFactor * dy,
        finalBrakeFlatFactor * dz
    }
    unit.setEngineCommand(
        'brake',
        brakeAcceleration,
        {0.0,0.0,0.0},
        1, 
        1,
        '',
        '',
        '', 
        0.001
    )
    ]]
  end,

  longitudinal = function(s)
    s.longitudinalEngineTags = 'thrust analog longitudinal' .. (s.groundMode and ' fueled' or '')
    s.longitudinalCommandType = NACM:getAxisCommandType(axisCommandId.longitudinal)
    if (s.longitudinalCommandType == axisCommandType.byThrottle) then
      s.longitudinalAcceleration = NACM:composeAxisAccelerationFromThrottle(s.longitudinalEngineTags,axisCommandId.longitudinal)
      Nav:setEngineForceCommand(s.longitudinalEngineTags, s.longitudinalAcceleration, s.keepCollinearity)
    elseif (s.longitudinalCommandType == axisCommandType.byTargetSpeed) then
      s.longitudinalAcceleration = NACM:composeAxisAccelerationFromTargetSpeed(axisCommandId.longitudinal)
      s.autoNavigationEngineTags = s.autoNavigationEngineTags .. ' , ' .. s.longitudinalEngineTags
      s.autoNavigationAcceleration = s.autoNavigationAcceleration + s.longitudinalAcceleration
      if (NACM:getTargetSpeed(axisCommandId.longitudinal) == 0 or -- we want to stop
        NACM:getCurrentToTargetDeltaSpeed(axisCommandId.longitudinal) < - NACM:getTargetSpeedCurrentStep(axisCommandId.longitudinal) * 0.5) -- if the longitudinal velocity would need some braking
      then
        s.autoNavigationUseBrake = true
      end
    end

    
  end,

  lateral = function(s)
    s.lateralStrafeEngineTags = 'thrust analog lateral'-- .. (s.groundMode and ' fueled' or '')
    s.lateralCommandType = NACM:getAxisCommandType(axisCommandId.lateral)
    if (s.lateralCommandType == axisCommandType.byThrottle) then
      s.lateralStrafeAcceleration =  NACM:composeAxisAccelerationFromThrottle(s.lateralStrafeEngineTags,axisCommandId.lateral)
      Nav:setEngineForceCommand(s.lateralStrafeEngineTags, s.lateralStrafeAcceleration, s.keepCollinearity)
    elseif  (s.lateralCommandType == axisCommandType.byTargetSpeed) then
      s.lateralAcceleration = NACM:composeAxisAccelerationFromTargetSpeed(axisCommandId.lateral)
      s.autoNavigationEngineTags = s.autoNavigationEngineTags .. ' , ' .. s.lateralStrafeEngineTags
      s.autoNavigationAcceleration = s.autoNavigationAcceleration + s.lateralAcceleration
    end
  end,

  vertical = function(s)
    if not s.groundMode then
      s.verticalStrafeEngineTags = 'thrust analog vertical'
      s.verticalCommandType = NACM:getAxisCommandType(axisCommandId.vertical)
      if (s.verticalCommandType == axisCommandType.byThrottle) then
        s.verticalStrafeAcceleration = NACM:composeAxisAccelerationFromThrottle(s.verticalStrafeEngineTags,axisCommandId.vertical)
        Nav:setEngineForceCommand(s.verticalStrafeEngineTags, s.verticalStrafeAcceleration, s.keepCollinearity, 'airfoil', 'ground', '', s.tolerancePercentToSkipOtherPriorities)
      elseif  (s.verticalCommandType == axisCommandType.byTargetSpeed) then
        s.verticalAcceleration = NACM:composeAxisAccelerationFromTargetSpeed(axisCommandId.vertical)
        s.autoNavigationEngineTags = s.autoNavigationEngineTags .. ' , ' .. s.verticalStrafeEngineTags
        s.autoNavigationAcceleration = s.autoNavigationAcceleration + s.verticalAcceleration
      end
    end
  end,

  cruise = function(s)
    if (s.autoNavigationAcceleration:len() > constants.epsilon) then
      if (s.brakeInput ~= 0 or s.autoNavigationUseBrake or math.abs(s.velocityDirection:dot(s.forward)) < 0.95)  -- if the velocity is not properly aligned with the forward
      then
        s.autoNavigationEngineTags = s.autoNavigationEngineTags .. ', brake'
      end
      Nav:setEngineForceCommand(s.autoNavigationEngineTags, s.autoNavigationAcceleration, s.dontKeepCollinearity, '', '', '', s.tolerancePercentToSkipOtherPriorities)
    end
  end,

  boosters = function(s)
    -- Rockets
    Nav:setBoosterCommand('rocket_engine')
  end

});

