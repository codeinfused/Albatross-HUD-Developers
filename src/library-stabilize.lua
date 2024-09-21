Stabilize = (function()
  local this = {
    disabled = false,
    active = false,
    tempsw = false
  }

  function this:init()
    KeyActions:register('start', 'option2', 'StabRotation', Stabilize, 'keyAction')
    KeyActions:register('tick', 'StabTick', 'StabTick', Stabilize, 'tsw')
    unit.setTimer('StabTick', 0.25)

    SystemFlush:register(12, 'stabilize', Stabilize, 'flush')
    --this.button1 = HUD.buttons:createButton('Stabilize', "Stabilize to gravity", 'A:2', 'off')
    this.button1 = HUD.buttons:createButton('Stabilize', "Auto-Level", 'A:2', 'off')
  end

  function this.flush(s)
    if not s.disabled and Flight.inSpace then
      s.disabled = true
      s.button1:toggle({active = 'dis'})
    elseif not Flight.inSpace then
      s.disabled = false
      s.button1:toggle({active = s.active and s.tempsw and "on" or "off"})
    end
    if Flight.speed == nil or Throttle.previous == nil or s.disabled then return end
    if (s.active and s.tempsw) or (Flight.speed < 28 and Flight.atmoDensity>0.1 and Throttle.previous < 3) then
      Flight.targetAngularVelocity = Flight.targetAngularVelocity + Flight.worldVertical:cross(Flight.up)
    end
  end

  function this.keyAction(s, force)
    if s.disabled or Flight.keyLShift==1 then return end
    if force==1 or force==0 then s.active = force else s.active = not s.active end
    --s.active = force or not s.active
    s.tempsw = s.active
    s.button1:toggle({active = s.active and s.tempsw and "on" or "off"})
  end

  function this.tsw(s)
    if Flight.pitchInput > 0 or Flight.rollInput > 0 or Flight.yawInput > 0 then
      s.tempsw = false
    else
      s.tempsw = s.active
    end
  end

  return this
end)()


AltLock = (function()
  local this = {
    state = false,
    disabled = false,
    labelOn = 'Holding at: ',
    labelOff = 'Hold Altitude',
    autoPitch = 0
  }

  function this.init(s)
    KeyActions:register('start', 'option3', 'AltLockToggle', s, 'keyAction')
    KeyActions:register('stop', 'forward', 'AltLockPitchStop', s, 'AltLockPitchStop');
    KeyActions:register('stop', 'backward', 'AltLockPitchStop', s, 'AltLockPitchStop');
    SystemFlush:register(13, 'altlock', s, 'flush')
    s.button1 = HUD.buttons:createButton('AltLock', s.labelOff, 'A:3', 'off')
    s.PID = pid.new(0.015, 0, 0.4)
  end

  function this.flush(s)
    if not s.disabled and Flight.inSpace then
      s.disabled = true
      s.button1:toggle({active = 'dis', label = s.labelOff})
    elseif s.disabled and not Flight.inSpace then
      s.disabled = false
      s.state = false
      s.button1:toggle({active = false and s.tempsw and "on" or "off"})
    end

    if not s.state or s.disabled then return end

    --local Flight = Flight
    local alt = Flight.altitude
    local velMag = Flight.velocity:len()
    local altDiff = s.state - alt
    local minmax = 300 + velMag
    local maxPitch = 25
    local adjustedPitch = Flight.spitch -- (-90 to 90)
    local targetPitch = (utils.smoothstep(altDiff, -minmax, minmax) - 0.5) * 2 * maxPitch

    local autoPitchThreshold = 0.05
    if math.abs(targetPitch - adjustedPitch) > autoPitchThreshold then
      s.PID:inject(targetPitch - adjustedPitch)
      s.autoPitch = s.PID:get()
    end

    Flight.targetAngularVelocity = Flight.targetAngularVelocity + (s.autoPitch * Flight.pitchSpeedFactor * Flight.right)
  end

  function this.keyAction(s)
    if Flight.keyLShift==1 then return end
    if s.state==false then s.state = Flight.altitude; Stabilize:keyAction(1); else s.state = false; Stabilize:keyAction(0); end
    s.button1:toggle({active = s.state and "on" or "off", label = s.state and s.labelOn..format("%.0f", (s.state or 0)).." m" or s.labelOff})
  end

  function this.set(s, alt)
    s.state = alt
    Stabilize:keyAction(true);
    s.button1:toggle({active = s.state and "on" or "off", label = s.state and s.labelOn..format("%.0f", (s.state or 0)).." m" or s.labelOff})
  end

  function this.AltLockPitchStop(s)
    if s.state then 
      s.state = Flight.altitude 
      s.button1:toggle({label = s.labelOn..format("%.0f", (s.state or 0)).."m"})
    end
  end

  return this
end)()

-- ///////////////////////////////////////////////////////////////

--[[
velMag = vec3(constructVelocity):len()
vSpd = -worldVertical:dot(constructVelocity)
local adjustedRoll = getRoll(worldVertical, constructForward, constructRight) 
local radianRoll = (adjustedRoll / 180) * math.pi
local corrX = math.cos(radianRoll)
local corrY = math.sin(radianRoll)
adjustedPitch = Flight.spitch

local constructVelocityDir = constructVelocity:normalize()
local currentRollDegAbs = mabs(adjustedRoll)
local currentRollDegSign = utils.sign(adjustedRoll)

local currentPitch = -math.deg(signedRotationAngle(constructRight, constructForward, constructVelocity:normalize()))

-- this pitch only applies to a target vector
local targetPitch = uclamp(math.deg(signedRotationAngle(constructRight, constructVelocity:normalize(), targetVec:normalize()))*(velMag/500),-90,90)

-- ////////////
  -- Consider: 100m below target, but 30m/s vspeed.  We should pitch down.  
  -- Or 100m above and -30m/s vspeed.  So (Hold-Core) - vspd
  -- Scenario 1: Hold-c = -100.  Scen2: Hold-c = 100
  -- 1: 100-30 = 70     2: -100--30 = -70
  --if not ExternalAGG and antigravOn and not Reentry and HoldAltitude < antigrav.getBaseAltitude() then p("HERE3") HoldAltitude = antigrav.getBaseAltitude() end
  local altDiff = (HoldAltitude - coreAltitude) - vSpd -- Maybe a multiplier for vSpd here...
  -- This may be better to smooth evenly regardless of HoldAltitude.  Let's say, 2km scaling?  Should be very smooth for atmo
  -- Even better if we smooth based on their velocity
  local minmax = 200+velMag -- Previously 500+
  if Reentry or spaceLand then minMax = 2000+velMag end -- Smoother reentries
  -- Smooth the takeoffs with a velMag multiplier that scales up to 100m/s
  local velMultiplier = 1
  if AutoTakeoff then velMultiplier = uclamp(velMag/100,0.1,1) end
  local targetPitch = (utils.smoothstep(altDiff, -minmax, minmax) - 0.5) * 2 * MaxPitch * velMultiplier

  if not Reentry and not spaceLand and not VectorToTarget and constructForward:dot(constructVelocity:normalize()) < 0.99 then
    -- Widen it up and go much harder based on atmo level if we're exiting atmo and velocity is keeping up with the nose
    -- I.e. we have a lot of power and need to really get out of atmo with that power instead of feeding it to speed
    -- Scaled in a way that no change up to 10% atmo, then from 10% to 0% scales to *20 and *2
    targetPitch = (utils.smoothstep(altDiff, -minmax*uclamp(20 - 19*atmosDensity*10,1,20), minmax*uclamp(20 - 19*atmosDensity*10,1,20)) - 0.5) * 2 * MaxPitch * uclamp(2 - atmosDensity*10,1,2) * velMultiplier
  end

-- ///////////
local onGround = abvGndDet > -1
local pitchToUse = adjustedPitch

if (VectorToTarget or spaceLaunch or ReversalIsOn) and not onGround and velMag > minRollVelocity and inAtmo then
    local rollRad = math.rad(mabs(adjustedRoll))
    pitchToUse = adjustedPitch*mabs(math.cos(rollRad))+currentPitch*math.sin(rollRad)
end
-- TODO: These clamps need to be related to roll and YawStallAngle, we may be dealing with yaw?
local pitchDiff = uclamp(targetPitch-pitchToUse, -PitchStallAngle*0.80, PitchStallAngle*0.80)
if not inAtmo and VectorToTarget then
    pitchDiff = uclamp(targetPitch-pitchToUse, -85, MaxPitch) -- I guess
elseif not inAtmo then
    pitchDiff = uclamp(targetPitch-pitchToUse, -MaxPitch, MaxPitch) -- I guess
end
if (((mabs(adjustedRoll) < 5 or VectorToTarget or ReversalIsOn)) or BrakeLanding or onGround or AltitudeHold) then
    if (pitchPID == nil) then -- Changed from 8 to 5 to help reduce problems?
        pitchPID = pid.new(5 * 0.01, 0, 5 * 0.1) -- magic number tweaked to have a default factor in the 1-10 range
    end
    pitchPID:inject(pitchDiff)
    local autoPitchInput = pitchPID:get()
    pitchInput2 = pitchInput2 + autoPitchInput
end

-- ////////////
if VtPitch ~= nil then
  if (vTpitchPID == nil) then
      vTpitchPID = pid.new(2 * 0.01, 0, 2 * 0.1)
  end
  local vTpitchDiff = uclamp(VtPitch-adjustedPitch, -PitchStallAngle*0.80, PitchStallAngle*0.80)
  vTpitchPID:inject(vTpitchDiff)
  local vTPitchInput = uclamp(vTpitchPID:get(),-1,1)
  pitchInput2 = vTPitchInput
end

-- /////////////
if (apPitchPID == nil) then
  apPitchPID = pid.new(2 * 0.01, 0, 2 * 0.1) -- magic number tweaked to have a default factor in the 1-10 range
end
apPitchPID:inject(targetPitch - currentPitch)
local autoPitchInput = uclamp(apPitchPID:get(),-1,1)

pitchInput2 = pitchInput2 + autoPitchInput

-- //////////////
if (currentPitch < -PitchStallAngle or currentPitch > PitchStallAngle) and inAtmo then
  targetPitch = uclamp(adjustedPitch-currentPitch,adjustedPitch - PitchStallAngle*0.80, adjustedPitch + PitchStallAngle*0.80) -- Just try to get within un-stalling range to not bounce too much
end

]]










