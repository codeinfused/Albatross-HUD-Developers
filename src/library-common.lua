-- ====================================================
-- ======= GENERAL FUNCTIONS

local function assignFn(target, fn)
  if(type(fn)=='function') then
    target = fn;
  else
    target = function() end;
  end
end

local function tableKeys(tab)
  local keyset={}
  for k,v in pairs(tab) do
    keyset[#keyset+1]=k
  end
  return keyset
end

local function isINF(val)
  return val == math.huge or val == -math.huge
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return floor(num * mult + 0.5) / mult
end

local function getHeading(forward) -- code provided by tomisunlucky   
  local up = -Flight.worldVertical
  forward = forward - forward:project_on(Flight.up)
  local north = vec3(0, 0, 1)
  north = north - north:project_on(Flight.up)
  local east = north:cross(Flight.up)
  local angle = north:angle_between(forward) * constants.rad2deg
  if forward:dot(east) < 0 then
      angle = 360-angle
  end
  return angle
end

local function calcDist(b1, b2)
  return vec3(b1):dist(vec3(b2))
end

function formatDist(d)
  if type(d) ~= "number" then return "--" end
  local su = floor(d/200000)
  local distKM = floor(d)/1000 -- distance in KM
  local distSU = floor(distKM)/200  -- distance in SU

  local showDist = '';
  if(distSU < 0.49) then
    showDist = format("%.2f", distKM) .. 'km';
  elseif distSU < 10 then
    showDist = format("%.2f", distSU) .. 'su';
  else
    showDist = format("%.1f", distSU) .. 'su';
  end
  return showDist
end

function formatTime(t)
  if t~=t or t<1 or t==nil or type(t) ~= "number" then return "00:00:00" end
  local hrs = floor(t / 3600)
  t = t - (3600*hrs)
  local min = floor(t / 60)    
  t = t - (60*min)
  local sec = round(t, 0)
  local time_s = format("%02d:%02d:%02d", hrs, min, sec)
  return time_s
end

function timeToDist(d, spd)
  --destTime (10km/hr..  spd*1000*3600=(m/sec)
  -- d in m, spd in kmph
  if type(d)~="number" then return 0 end
  return abs((floor(d)/1000) / spd) * 3600;
end

function calcBrakeDist(spcStop)
  local c = 50000*1000/3600
  if not Flight.velocity then return 0, "00m:00s" end
  if spcStop==true and Flight.burnSpeed then 
    c = (Flight.maxSpeed-Flight.burnSpeed)*1000/3600 
  else
    c = (Flight.maxSpeed+200)*1000/3600
    --c = 29999*1000/3600
  end
  local c2 = c*c
  local brakeforce = Flight.maxBrake;
  local forwardV = Flight.velocity:len()
  if forwardV > 0 then
    local bt = (brakeforce*-1)/Flight.mass
    local distance = 0
    local time = 0
    local k1 = c*math.asin(forwardV/c)
    local k2 = c2*math.cos(k1/c)/bt
    local t = (c*math.asin(0/c)-k1)/bt
    local d = k2-c2*math.cos((bt*t+k1)/c)/bt

    --[[
    local k1 = c*math.asin(forwardV/c)
    local k2 = c2*math.cos(k1/c)/bt
    local t = (c*math.asin(0/c)-k1)/bt
    local d = k2-c2*math.cos((bt*t+k1)/c)/bt
    ]]

    distance = distance+d
    time = time+t
    local min = floor(time / 60)    
    t = t - (60 * min)
    local sec = round(t, 0)
    local time_s = format("%02dm:%02ds", min, sec)
    return distance, time_s
  else
    return 0.0, "00m:00s"
  end
end

function calcBrakeDist2(spcStopSpeed)
  local fvel = Flight.velocity:len()
  if fvel > 1 then
    local initialSp=(math.floor((fvel)*3.6)) --INSERT Km/h
    local v=initialSp*0.277777777778

    local finalSp=(spcStopSpeed)*0.277777777778 --INSERT Km/h
    local restMass=(Flight.mass)*1000 --INSERT t
    local rrThrust=Flight.maxBrake --INSERT kN

    local totA=rrThrust * 1000/restMass
    local distance=0
    local time=0

    if (initialSp>finalSp) then
      local t=v/totA
      local d=(v*v)/(2*totA)
      distance=distance + d
      time=time + t
    end

    --brake_min=math.floor(time/60)
    --brake_sec=math.floor(((time/60)-brake_min)*60)
    --brake_su=math.floor(distance/200000*100)/100
    --brake_km=math.floor(distance/1000)

    local min = floor(time / 60)    
    t = time - (60 * min)
    local sec = round(t, 0)
    local time_s = format("%02dm:%02ds", min, sec)
    return distance, time_s
  else
    return 0.0, "00m:00s"
  end
end

local function signedRotationAngle(normal, vecA, vecB)
  vecA = vecA:project_on_plane(normal)
  vecB = vecB:project_on_plane(normal)
  return atan(vecA:cross(vecB):dot(normal), vecA:dot(vecB))
end

function h2rgb(m1, m2, h)
	if h<0 then h = h+1 end
	if h>1 then h = h-1 end
	if h*6<1 then
		return m1+(m2-m1)*h*6
	elseif h*2<1 then
		return m2
	elseif h*3<2 then
		return m1+(m2-m1)*(2/3-h)*6
	else
		return m1
	end
end
function hsl_to_rgb(h, s, L)
	h = h / 360
  s = s / 100
  L = L / 100
	local m2 = L <= .5 and L*(s+1) or L+s-L*s
	local m1 = L*2-m2
	return
		h2rgb(m1, m2, h+1/3)*255,
		h2rgb(m1, m2, h)*255,
		h2rgb(m1, m2, h-1/3)*255
end

local HxHSL = function(H)
  local r,g,b,cm,cx,d,h,sa,l
  if string.len(H) == 7 then
    r="0x"..str_sub(H,2,3)
    g="0x"..str_sub(H,4,5)
    b="0x"..str_sub(H,6,7)
  else return end

  r=r/255;
  g=g/255;
  b=b/255;
  cm=min(r,g,b)
  cx=max(r,g,b)
  d=cx-cm

  if d==0 then
    h=0
  elseif cx==r then
    h=((g-b)/d)%6
  elseif cx==g then
    h=(b-r)/d+2
  else
    h=(r-g)/d+4
  end
  h=round(h*60)
  if h<0 then h=h+360 end

  l = (cx + cm)/2
  if d==0 then
    sa=0
  else
    sa=d/(1-abs(2*l-1))
  end
  sa = round(sa*100)
  l = round(l*100)
  return {h,sa,l}
end

local HSLmod = function(t,sm,lm)
  sa=max(0,min(100,t[2]+sm))
  l=max(0,min(100,t[3]+lm))
  return format("hsl(%s,%s%%,%s%%)",t[1],sa,l)
end

-- ====================================================
-- ======= GENERAL APIS

-- Anim = (function()
--   local this = {}
--   this.new = function(speed, anims)
--     local out = {
--       speed = speed or 0.03,
--       anims = anims or {},
--       a = {
--         easeInOutElastic=function(a,c,b,d,e,f) if(a==0) then return c end if((a/=d/2)==2) then return c+b end f||(f=d*0.3*1.5);if(e<math.abs(b)) then var e=b,g=f/4 else g=f/(2*math.pi)*math.asin(b/e) end return a<1?-0.5*e*math.pow(2,10*(a-=1))*math.sin((a*d-g)*2*math.pi/f)+c:e*math.pow(2,-10*(a-=1))*math.sin((a*d-g)*2*math.pi/f)*0.5+b+c end
--       } 
--         --[[
--           'name' = {
--             val = 0,
--             anim = '' or #
--           }
--         ]]
--     }
--     setmetatable(out, {__index=this})
--     return out
--   end

--   function this:exec()
--     for n,o in pairs(self.anims) do
--       if type(o.anim)=='number' then
--         o.val = o.val + o.anim
--       else
--         o.val = self.a[o.anim]()
--       end
--     end;
--   end;

--   return this
-- end)()

Sound = (function()
  local this = {
    base = 'albatross_hud\\',
    fs = {
      init = 'v-hud-init.mp3',
      land = 'v-landing.mp3',
      confirm = 'v-confirmed.mp3',
      APapproach = 'v-autopilot-finishing.mp3'
    },
    q = {}
  }

  function this:init()
    KeyActions:register('tick', 'SoundCheck', 'SoundCheck', self, 'check')
    unit.setTimer('SoundCheck', 0.25)
    return this;
  end

  function this.check(s)
    if(system.isPlayingSound()==1 or #s.q < 1) then return end
    local f = table.remove(s.q,1)
    if playSounds then system.playSound(s.base..s.fs[f]) end
  end

  function this.play(s, n, nomult, force)
    if nomult then 
      if system.isPlayingSound()==1 then return end
    end
    if force then
      system.stopSound()
      s.q = {}
    end
    s.q[#s.q+1] = n
  end

  return this
end)()

--[[
local function SaveDataBank(copy) -- Save values to the databank.
  local function writeData(dataList)
      for k, v in pairs(dataList) do
          dbHud_1.setStringValue(k, jencode(v.get()))
          if copy and dbHud_2 then
              dbHud_2.setStringValue(k, jencode(v.get()))
          end
      end
  end
  if dbHud_1 then
      writeData(autoVariables) 
      writeData(saveableVariables())
      p("Saved Variables to Datacore")
      if copy and dbHud_2 then
          p("Databank copied.  Remove copy when ready.")
      end
  end
end

local function LoadVariables() -- Databank variable loading
  local function processVariableList(varList)
      local hasKey = dbHud_1.hasKey
      for k, v in pairs(varList) do
          if hasKey(k) then
              local result = jdecode(dbHud_1.getStringValue(k))
              if result ~= nil then
                  v.set(result)
                  valuesAreSet = true
              end
          end
      end
  end
  pcall(require,"autoconf/custom/archhud/custom/userglobals")
  if dbHud_1 then
      if not useTheseSettings then 
          processVariableList(saveableVariables())
          coroutine.yield()
          processVariableList(autoVariables)
      else
          processVariableList(autoVariables)
          p("Updated user preferences used.  Will be saved when you exit seat.\nToggle off useTheseSettings to use saved values")
          valuesAreSet = false
      end
      coroutine.yield()
      if valuesAreSet then
          p("Loaded Saved Variables")
      elseif not useTheseSettings then
          p("No Databank Saved Variables Found\nVariables will save to Databank on standing")
      end
  else
      p("No databank found. Attach one to control U and rerun \nthe autoconfigure to save preferences and locations")
  end
  resolutionWidth = S.getScreenWidth()
  resolutionHeight = S.getScreenHeight()
  MaxGameVelocity = c.getMaxSpeed()-0.1
end
]]


--[[ 
  DualUniverse kinematic equations
  Author: JayleBreak

  Usage (unit.start):
  Kinematics = require('autoconf.custom.kinematics')

  Methods:
   computeAccelerationTime - "relativistic" version of t = (vf - vi)/a
   computeDistanceAndTime - Return distance & time needed to reach final speed.
   computeTravelTime - "relativistic" version of t=(sqrt(2ad+v^2)-v)/a

  Description
  DualUniverse increases the effective mass of constructs as their absolute
  speed increases by using the "lorentz" factor (from relativity) as the scale
  factor.  This results in an upper bound on the absolute speed of constructs
  (excluding "warp" drive) that is set to 30 000 KPH (8 333 MPS). This module
  provides utilities for computing some physical quantities taking this
  scaling into account.
]]--

Kinematic = {} -- just a namespace

local C       = 30000000/3600
local C2      = C*C
local ITERATIONS = 100 -- iterations over engine "warm-up" period

function lorentz(v) return 1/math.sqrt(1 - v*v/C2) end

--
-- computeAccelerationTime - "relativistic" version of t = (vf - vi)/a
-- initial      [in]: initial (positive) speed in meters per second.
-- acceleration [in]: constant acceleration until 'finalSpeed' is reached.
-- final        [in]: the speed at the end of the time interval.
-- return: the time in seconds spent in traversing the distance
--
function Kinematic.computeAccelerationTime(initial, acceleration, final)
    -- The low speed limit of following is: t=(vf-vi)/a (from: vf=vi+at)
    local k1 = C*math.asin(initial/C)
    return (C * math.asin(final/C) - k1)/acceleration
end

--
-- computeDistanceAndTime - Return distance & time needed to reach final speed.
-- initial[in]:     Initial speed in meters per second.
-- final[in]:       Final speed in meters per second.
-- restMass[in]:    Mass of the construct at rest in Kg.
-- thrust[in]:      Engine's maximum thrust in Newtons.
-- t50[in]:         (default: 0) Time interval to reach 50% thrust in seconds.
-- brakeThrust[in]: (default: 0) Constant thrust term when braking.
-- return: Distance (in meters), time (in seconds) required for change.
--
function Kinematic.computeDistanceAndTime(initial,
                                          final,
                                          restMass,
                                          thrust,
                                          t50,
                                          brakeThrust)
    -- This function assumes that the applied thrust is colinear with the
    -- velocity. Furthermore, it does not take into account the influence
    -- of gravity, not just in terms of its impact on velocity, but also
    -- its impact on the orientation of thrust relative to velocity.
    -- These factors will introduce (usually) small errors which grow as
    -- the length of the trip increases.
    local C       = (Flight.maxSpeed+200)*1000/3600 --30000000/3600
    local C2      = C*C

    t50            = t50 or 0
    brakeThrust    = brakeThrust or 0 -- usually zero when accelerating

    local tau0     = lorentz(initial)
    local speedUp  = initial <= final
    local a0       = thrust * (speedUp and 1 or -1)/restMass
    local b0       = -brakeThrust/restMass
    local totA     = a0+b0

    if speedUp and totA <= 0 or not speedUp and totA >= 0 then
        return -1, -1 -- no solution
    end

    local distanceToMax, timeToMax = 0, 0

    -- If, the T50 time is set, then assume engine is at zero thrust and will
    -- reach full thrust in 2*T50 seconds. Thrust curve is given by:
    -- Thrust: F(z)=(a0*(1+sin(z))+2*b0)/2 where z=pi*(t/t50 - 1)/2
    -- Acceleration is given by F(z)/m(z) where m(z) = m/sqrt(1-v^2/c^2)
    -- or v(z)' = (a0*(1+sin(z))+2*b0)*sqrt(1-v(z)^2/c^2)/2

    if a0 ~= 0 and t50 > 0 then
        -- Closed form solution for velocity exists:
        -- v(t) = -c*tan(w)/sqrt(tan(w)^2+1) => w = -asin(v/c)
        -- w=(pi*t*(a0/2+b0)-a0*t50*sin(pi*t/2/t50)+*pi*c*k1)/pi/c
        -- @ t=0, v(0) = vi
        -- pi*c*k1/pi/c = -asin(vi/c)
        -- k1 = asin(vi/c)
        local k1  = math.asin(initial/C)

        local c1  = math.pi*(a0/2+b0)
        local c2  = a0*t50
        local c3  = C*math.pi

        local v = function(t)
            local w  = (c1*t - c2*math.sin(math.pi*t/2/t50) + c3*k1)/c3
            local tan = math.tan(w)
            return C*tan/math.sqrt(tan*tan+1)
        end

        local speedchk = speedUp and function(s) return s >= final end or
                                     function(s) return s <= final end
        timeToMax  = 2*t50

        if speedchk(v(timeToMax)) then
            local lasttime = 0

            while math.abs(timeToMax - lasttime) > 0.5 do
                local t = (timeToMax + lasttime)/2
                if speedchk(v(t)) then
                    timeToMax = t 
                else
                    lasttime = t
                end
            end
        end

        -- There is no closed form solution for distance in this case.
        -- Numerically integrate for time t=0 to t=2*T50 (or less)
        local lastv = initial
        local tinc  = timeToMax/ITERATIONS

        for step = 1, ITERATIONS do
            local speed = v(step*tinc)
            distanceToMax = distanceToMax + (speed+lastv)*tinc/2
            lastv = speed
        end

        if timeToMax < 2*t50 then
            return distanceToMax, timeToMax
        end
        initial     = lastv
    end
    -- At full thrust, acceleration only depends on the Lorentz factor:
    -- v(t)' = (F/m(v)) = a*sqrt(1-v(t)^2/c^2) where a = a0+b0
    -- -> v = c*sin((at+k1)/c)
    -- @ t=0, v=vi: k1 = c*asin(vi/c)
    -- -> t = (c*asin(v/c) - k1)/a
    -- x(t)' = c*sin((at+k1)/c)
    -- x = k2 - c^2 cos((at+k1)/c)/a
    -- @ t=0, x=0: k2 = c^2 * cos(k1/c)/a
    local k1       = C*math.asin(initial/C)
    local time     = (C * math.asin(final/C) - k1)/totA

    local k2       = C2 *math.cos(k1/C)/totA
    local distance = k2 - C2 * math.cos((totA*time + k1)/C)/totA

    return distance+distanceToMax, time+timeToMax
end

--
-- computeTravelTime - "relativistic" version of t=(sqrt(2ad+v^2)-v)/a
-- initialSpeed [in]: initial (positive) speed in meters per second
-- acceleration [in]: constant acceleration until 'distance' is traversed
-- distance [in]: the distance traveled in meters
-- return: the time in seconds spent in traversing the distance
--
function Kinematic.computeTravelTime(initial, acceleration, distance)
    -- The low speed limit of following is: t=(sqrt(2ad+v^2)-v)/a
    -- (from: d=vt+at^2/2)
    if distance == 0 then return 0 end

    if acceleration > 0 then
        local k1       = C*math.asin(initial/C)
        local k2       = C2*math.cos(k1/C)/acceleration
        return (C*math.acos(acceleration*(k2 - distance)/C2) - k1)/acceleration
    end
    assert(initial > 0, 'Acceleration and initial speed are both zero.')
    return distance/initial
end

function Kinematic.lorentz(v) return lorentz(v) end


function computeDistanceAndTime2(initial, final, restMass, thrust, t50, brakeThrust)
    
  t50 = t50 or 0
  brakeThrust = brakeThrust or 0 -- usually zero when accelerating
  local speedUp = initial <= final
  local a0 = thrust * (speedUp and 1 or -1) / restMass
  local b0 = -brakeThrust / restMass
  local totA = a0 + b0
  if speedUp and totA <= 0 or not speedUp and totA >= 0 then
      return -1, -1 -- no solution
  end
  local distanceToMax, timeToMax = 0, 0

  if a0 ~= 0 and t50 > 0 then

      local k1 = math.asin(initial / C)
      local c1 = math.pi * (a0 / 2 + b0)
      local c2 = a0 * t50
      local c3 = C * math.pi
      local v = function(t)
          local w = (c1 * t - c2 * math.sin(math.pi * t / 2 / t50) + c3 * k1) / c3
          local tan = math.tan(w)
          return C * tan / msqrt(tan * tan + 1)
      end
      local speedchk = speedUp and function(s)
          return s >= final
      end or function(s)
          return s <= final
      end
      timeToMax = 2 * t50
      if speedchk(v(timeToMax)) then
          local lasttime = 0
          while mabs(timeToMax - lasttime) > 0.5 do
              local t = (timeToMax + lasttime) / 2
              if speedchk(v(t)) then
                  timeToMax = t
              else
                  lasttime = t
              end
          end
      end
      -- There is no closed form solution for distance in this case.
      -- Numerically integrate for time t=0 to t=2*T50 (or less)
      local lastv = initial
      local tinc = timeToMax / ITERATIONS
      for step = 1, ITERATIONS do
          local speed = v(step * tinc)
          distanceToMax = distanceToMax + (speed + lastv) * tinc / 2
          lastv = speed
      end
      if timeToMax < 2 * t50 then
          return distanceToMax, timeToMax
      end
      initial = lastv
  end

  local k1 = C * math.asin(initial / C)
  local time = (C * math.asin(final / C) - k1) / totA
  local k2 = C2 * math.cos(k1 / C) / totA
  local distance = k2 - C2 * math.cos((totA * time + k1) / C) / totA
  return distance + distanceToMax, time + timeToMax
end