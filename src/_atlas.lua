--[[
  ATLAS CONCEPT FUNCTIONS
  Ideas for functions to extrapolate useful data from atlas polls.
]]

local atlas = atlas

local function getPipeDistance(origCenter, destCenter)  -- Many thanks to Tiramon for the idea and functionality.
  local pipeDistance
  local pipe = (destCenter - origCenter):normalize()
  local r = (worldPos -origCenter):dot(pipe) / pipe:dot(pipe)
  if r <= 0. then
    return (worldPos-origCenter):len()
  elseif r >= (destCenter - origCenter):len() then
    return (worldPos-destCenter):len()
  end
  local L = origCenter + (r * pipe)
  pipeDistance =  (L - worldPos):len()
  return pipeDistance
end

local function getClosestPipe() -- Many thanks to Tiramon for the idea and functionality, thanks to Dimencia for the assist
  local pipeDistance
  local nearestDistance = nil
  local nearestPipePlanet = nil
  local pipeOriginPlanet = nil
  for k,nextPlanet in pairs(atlas[0]) do
    if nextPlanet.hasAtmosphere then -- Skip moons
      local distance = getPipeDistance(planet.center, nextPlanet.center)
      if nearestDistance == nil or distance < nearestDistance then
        nearestPipePlanet = nextPlanet
        nearestDistance = distance
        pipeOriginPlanet = planet
      end
      if autopilotTargetPlanet and autopilotTargetPlanet.name ~= "Space" and autopilotTargetPlanet.name ~= planet.name then 
        local distance2 = getPipeDistance(autopilotTargetPlanet.center, nextPlanet.center)
        if distance2 < nearestDistance then
          nearestPipePlanet = nextPlanet
          nearestDistance = distance2
          pipeOriginPlanet = autopilotTargetPlanet
        end
      end
    end
  end
  local pipeX = ConvertResolutionX(1770)
  local pipeY = ConvertResolutionY(330)
  if nearestDistance then
    pipeDistance = getDistanceDisplayString(nearestDistance,2)
    pipeMessage = svgText(pipeX, pipeY, "Pipe ("..pipeOriginPlanet.name.."--"..nearestPipePlanet.name.."): "..pipeDistance, "pbright txttick txtmid") 
  end
end



local safeWorldPos = vec3({13771471,7435803,-128971})
local safeRadius = 18000000 
local sfradius = 500000
local distsz, distp = math.huge, math.huge
local function safeZone(WorldPos) -- Thanks to @SeM for the base code, modified to work with existing Atlas
  local safe = false
  distsz = vec3(WorldPos):dist(safeWorldPos)
  if distsz < safeRadius then  
    return true, mabs(distsz - safeRadius), "Safe Zone", 0
  end
  distp = vec3(WorldPos):dist(vec3(planet.center))
  if distp < sfradius then safe = true end
  if mabs(distp - sfradius) < mabs(distsz - safeRadius) then 
    return safe, mabs(distp - sfradius), planet.name, planet.bodyId
  else
    return safe, mabs(distsz - safeRadius), "Safe Zone", 0
  end
end
