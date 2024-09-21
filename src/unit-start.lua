local log = system.print

log('')
log('')
log('')
log('')
log('')
log('')
log('')
log('')
log('')
log('')
log('- /////// ALBATROSS HUD LOADED ///////');
log('- twitch.tv/codeinfused')
log('- tinyurl.com/codehud')
log('-----------------------------------')
log('For a list of commands, type:  help')

-- //////////////////////////////////////////////////////
-- VARIABLE SET UPS
---------------------------------------------------------

UpdateDatabank = false --export: Checkmark this to update the current databank ship settings
hudColor = '#4992CF' --export: Hex color code for the HUD
hudTextColor = '' --export: Force text color of HUD data, leave blank for auto-color
hudOpacity = 94 --export: 0 to 100, percentage of HUD opacity
hudScale = 120 --export: 90 to 140, percentage to scale the HUD
drawFPS = 20 --export: FPS to draw HUD at, reduce for better performance
startingHoverHeight = 40 --export: Meters off the ground to hover when you disengage landing mode
landingSpeedConfig = 500 --export: Max speed at which landing mode can engage
burnSpeedMax = 0 --export: Use 0 for auto, allow HUD to calculate it
showAutopilot = true --export: Disable to remove the Autopilot button
apAtmoPark = 400000 --export: Distance for autopilot on arrival to park away from a planet
apSpacePark = 10000 --export: Distance for autopilot on arrival to space coordinate to park
showHOTAS = true --export: Disable to remove the HOTAS button
enableHOTAS = false --export: Enable the HOTAS Lua Axis controls
hotasThrottle = 'half' --export: Use "full" for no reverse range, or "half" for zero at center
pitchInvert = false --export: HOTAS invert, -1 or 1
rollInvert = false --export: HOTAS invert, -1 or 1
yawInvert = false --export: HOTAS invert, -1 or 1
soundFolder = 'albatross_hud' --export: Rename your local albatross sound folder and put name here
brakeToggleMode = false --export: Turn on for brake lock to be a toggle instead of keypress
burnSpeedLimiter = true --export: If on, will brake before hitting atmospheric burn speed
cruiseDefault = false --export: Use Cruise Speed as default flight mode
showReticles = true --export: Show the forward and velocity reticles projected into world
showWarnings = true --export: Show warnings such as stall and burn
playSounds = true --export: Play voice files if present on local computer
rcuFreeze = true --export: Freeze the player flying remotely using an RCU
showGroundMode = false --export: Show the button to toggle on Ground Mode hovering
needleAutopilot = false --export: Turn on racing alignment in autopilot
containerWeightTier = 0 --export: Talent Tier for Container-Optimization (-5%/e item mass)
fuelWeightTier = 0 --export: Talent Tier for Fuel-Tank-Optimization (-5%/e fuel mass)
atmoTankSizeTier = 0 --export: Talent Tier for Atmo Fuel-Tank-Handling (+20%/e volume)
spaceTankSizeTier = 0 --export: Talent Tier for Space Fuel-Tank-Handling (+20%/e volume)
rocketTankSizeTier = 0 --export: Talent Tier for Rocket Fuel-Tank-Handling (+10%/e volume)

Settings = {
  haskey = 0,
  hasap = 0,
  vals = {},
  names = {
    'hudColor'
    ,'hudTextColor'
    ,'hudOpacity'
    ,'hudScale'
    ,'drawFPS'
    ,'startingHoverHeight'
    ,'landingSpeedConfig'
    ,'showAutopilot'
    ,'apAtmoPark'
    ,'apSpacePark'
    ,'showHOTAS'
    ,'enableHOTAS'
    ,'hotasThrottle'
    ,'pitchInvert'
    ,'rollInvert'
    ,'yawInvert'
    ,'soundFolder'
    ,'brakeToggleMode'
    ,'burnSpeedLimiter'
    ,'cruiseDefault '
    ,'showReticles'
    ,'showWarnings '
    ,'playSounds '
    ,'rcuFreeze '
    ,'showGroundMode'
    ,'needleAutopilot'
    ,'containerWeightTier'
    ,'fuelWeightTier'
    ,'atmoTankSizeTier'
    ,'spaceTankSizeTier'
    ,'rocketTankSizeTier'
  },
  init = function(s)
    s.haskey = myDB.hasKey('AISconf')
    s.hasap = myDB.hasKey('AISap')
    if s.hasap~=1 then
      --local ap = json.encode({})
      myDB.setStringValue('AISap', "{}")
    end
    if s.haskey==1 then
      s.text = myDB.getStringValue('AISconf')
      s.vals = json.decode(s.text)
    else
      _G['UpdateDatabank'] = true
    end
    if _G['UpdateDatabank']==true then
      s:saveDB()
    else
      s:useDB()
    end
  end,
  saveDB = function(s)
    local vals = {}
    for i,key in ipairs(s.names) do
      vals[key] = _G[key]
    end
    s.vals = vals
    local text = json.encode(vals)
    myDB.setStringValue('AISconf', text)
    log('Databank updated')
  end,
  useDB = function(s)
    log('Using databank settings')
    for i,key in ipairs(s.names) do
      _G[key] = s.vals[key]
    end
  end,
  checkAP = function(s)
    if s.hasap~=1 then return false end
    s.ap = json.decode(myDB.getStringValue('AISap'))
    if s.ap and s.ap.target ~= nil then
      Autopilot:go(s.ap.target)
    end
  end,
  saveAP = function(s, target)
    if s.hasap~=1 then return false end
    local ap = json.encode({target = target})
    myDB.setStringValue('AISap', ap)
  end,
  clearAP = function(s)
    if s.hasap~=1 then return false end
    myDB.setStringValue('AISap', "{}")
  end
}

core = nil
warpdrive = nil
shield = nil
antigrav = nil
gyro = nil
dbs = {}
myDB = nil
radars = {}
weapons = {}

for slot_name, slot in pairs(unit) do
  if
    type(slot) == "table"
    and type(slot.export) == "table"
    and slot.getClass
  then
    local elementClass = slot.getClass():lower()
    if elementClass:find("coreunit") then
      core = slot
    elseif elementClass:find("radar") then
      table.insert(radars, slot)
    elseif elementClass:find("warpdriveunit") then
      warpdrive = slot
    elseif elementClass:find("databankunit") then
      table.insert(dbs, slot)
    elseif elementClass:find("shieldgenerator") then
      shield = slot
    elseif elementClass:find("weapon") then
      table.insert(weapons, slot)
    elseif elementClass:find("gyrounit") then
      gyro = slot
    elseif elementClass:find("antigravitygeneratorunit") then
      antigrav = slot
    else
      --log(elementClass)
    end
  end
end

if #dbs > 0 then 
  myDB = dbs[1]
  Settings:init()
else
  log('No databank linked')
end

if core == nil then
  print("You must link a Core to the seat.")
end

Nav = Navigator.new(system, core, unit)
NACM = Nav.axisCommandManager
NACM:setupCustomTargetSpeedRanges(axisCommandId.longitudinal, {1000, 5000, 10000, 20000, 30000, 60000})
NACM.axisCommands[axisCommandId.longitudinal].throttleMouseStepScale = 1

if cruiseDefault then unit.cancelCurrentControlMasterMode() end

if rcuFreeze and unit.isRemoteControlled() then player.freeze(true) end

-- WEAPONS
_autoconf.displayCategoryPanel(weapons, #weapons, L_TEXT("ui_lua_widget_weapon", "Weapons"), "weapon", true)

-- ANTIGRAV
if antigrav ~= nil then 
  AGG:init()
end

-- WARPDRIVE
--if warpdrive ~= nil then warpdrive.showWidget() end

core.hideWidget()
unit.hideWidget()
system.showHelper(false)
system.showScreen(true)
system.setScreen("")

KeyMaps = {
  stopengines='',
  booster='',
  speedup='',
  speeddown='',
  up='',
  down='',
  gear='',
  groundaltitudeup='',
  groundaltitudedown='',
  brake=''
}
for k,v in pairs(KeyMaps) do
  KeyMaps[k]=system.getActionKeyName(k):upper():gsub('ALT %+ ', 'A:'):gsub('SHIFT %+ ', 'S:'):gsub('SPACE', 'SPC')
end
KeyMaps.warp='A:J'


-- //////////////////////////////////////////////////////
-- INITIALIZE HUD COMPONENTS
---------------------------------------------------------

--HUD.widgets.shields:init()
HUD.widgets.primary:init()

HUD.widgets.primary.tmpl:bind({
  KeyGroundUp = KeyMaps['groundaltitudeup'],
  KeyGroundDown = KeyMaps['groundaltitudedown'],
  HUDver = '2.4.4',
  VelocitySpeed = 0,
  VelocityUp = 0,
  ThrottlePercent = 0,
  HoverHeight = 0,
  ClosestBodyName = 'Space',
  ClosestBodyChange = 'space',
  ClosestBodyDistance = '-',
  ClosestIcon = '',
  AtmoAlt = 0,
  Gravity = 0,
  BrakesUsed = 0,
  BrakesMax = 50000,
  BrakingDistance = '0 su',
  BrakingTime = '00:01:00',
  ShipMass = '230,069',
  DockedTo = 'None',
  DockedClosest = 'None',
  Altitude = '0',
  WidgetThrottle = '',
  MainButtons = '',
  MainFuel = '',
  MainWarp = '',
  HPStressPerc = 100,
  RadarContactCount = 0,
  CenterNav = function() return HUD.widgets.primary.CenterNav() end
})

HUD.full:init()
HUD.buttons:init() -- initial setup

SystemFlush = Executor.new()

--Warnings:init()
Throttle:init()
Flight:init()
Flight:update()
Flight:slowUpdate()
Fuel:init()
AISatlas:init()
Autopilot:init()
Gear:init()
Brakes:init()
Hovers:init()

SystemFlush:register(3, 'flush', Flight, 'flush')
SystemFlush:register(5, 'validate', Flight, 'validate')
SystemFlush:register(10, 'rotation', Flight, 'rotation')
SystemFlush:register(15, 'torque', Flight, 'torque')
SystemFlush:register(20, 'brakes', Flight, 'brakes')
SystemFlush:register(25, 'longitudinal', Flight, 'longitudinal')
SystemFlush:register(30, 'lateral', Flight, 'lateral')
SystemFlush:register(35, 'vertical', Flight, 'vertical')
SystemFlush:register(40, 'cruise', Flight, 'cruise')
SystemFlush:register(45, 'boosters', Flight, 'boosters')

Commands:init()
Stabilize:init()
AltLock:init()
Sound:init()

SystemFlush:exec()

if #radars > 0 then RadarSwitch:init() end
if warpdrive ~= nil then Warp:init() else
  --warpdrive = {hideWidget=function() end, getStatus=function() return 1 end, getDistance=function() return 0 end, getDestinationName=function() return 'No Destination' end, getAvailableWarpCells=function() return 0 end, getRequiredWarpCells=function() return 0 end}
  --Warp:init()
end

OptBurn = {btn=HUD.buttons:createButton('OptBurn', 'Burn Speed Limiter', 'AS:8', burnSpeedLimiter and 'on' or 'off'), toggle=function(s) 
  if Flight.keyLShift==0 then return end 
  burnSpeedLimiter = not burnSpeedLimiter
  s.btn:toggle({active = burnSpeedLimiter and 'on' or 'off'})
end}
KeyActions:register('start', 'option8', 'OptBurn', OptBurn, 'toggle')

--Disabling Ground Mode for now due to bugs
--if showGroundMode then GroundMode:init() end


HUD.buttons:ready()

HUD:colorize(hudColor)
HUD:opacitize(hudOpacity)
HUD:scalize(hudScale)
HUD.full:fps(drawFPS)

--json = nil
--vec3 = nil
--AxisCommandManager = nil
--utils = nil
--Navigator = nil
--constants = nil
database = nil
SGui = nil
sgui = nil
ClickableArea = nil
--axisCommandType = nil
getAxisAngleRad = nil
--AxisCommand = nil


HUDHelper = {state=false, toggle = function(s) if Flight.keyLShift==0 then return end s.state = not s.state; system.showHelper(s.state) end}
KeyActions:register('start', 'option9', 'HUDHelper', HUDHelper, 'toggle')

Lights = {toggle=function(s)
  if unit.isAnyHeadlightSwitchedOn() then
    unit.switchOffHeadlights()
  else
    unit.switchOnHeadlights()
  end
end}
KeyActions:register('start', 'light', 'Lights', Lights, 'toggle')

--CBReset = {reset = function(s) collectgarbage("restart") end}
--KeyActions:register('tick', 'CBReset', 'CBReset', CBReset, 'reset');
--unit.setTimer('CBReset', 600);

Settings:checkAP()

Sound:play('init');
