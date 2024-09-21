--[[
  TODO LIST
  Split update into 2 timers
    - body checker using coroutine and updating nearest body, on 0.05 tick
    - distance/render updater, on slower tick 0.5
]]

AISatlas = (function()
  local Flight = Flight
  local this = {
    state = true,
    sys = 0,
    closeBodyId = 2,
    dist = 0,
    bodyIDs = {},
    bodyNames = {},
    safeRadius = 18000000,
    sfradius = 500000,
    distsz = math.huge, 
    distp = math.huge,
    closeBodyId = 1,
    safeZonePos = vec3({13771471,7435803,-128971})
  }

  function this.init(s)
    for pId, body in pairs(atlas[s.sys]) do
      --if body.hasAtmosphere then
      s.bodyIDs[#s.bodyIDs+1]=pId
      s.bodyNames[body.name[1]:lower()]=pId
        --log(body.name[1])
      --end
    end

    s.body = atlas[s.sys][s.closeBodyId]

    s.Processor = coroutine.create(s.coCheck)
    KeyActions:register('tick', 'AtlasCheck', 'AtlasCheck', s, 'coCheck');
    unit.setTimer('AtlasCheck', 0.05);

    KeyActions:register('tick', 'AtlasUpdate', 'AtlasUpdate', s, 'update');
    unit.setTimer('AtlasUpdate', 0.3);
  end

  function this.nearestPlanetToPos(s, pos, maxDist)
    for pId, body in pairs(atlas[s.sys]) do
      local dist = math.abs( vec3(pos):dist(vec3(body.center)) )
      if dist < body.radius + maxDist then
        return body.id
      end
    end
    return 0
  end

  function this.anyPlanetToPos(s, pos)
    local currDist = 99999999999
    local returnId = 0
    for pId, body in pairs(atlas[s.sys]) do
      local dist = math.abs( vec3(pos):dist(vec3(body.center)) )
      if dist < currDist then
        currDist = dist
        returnId = body.id
      end
    end
    return returnId
  end

  function this.coCheck(s)
    local cont = coroutine.status(s.Processor)
    if cont ~= "dead" then 
      local value, done = coroutine.resume(s.Processor)
      --if done then log("Atlas ready.") end
    elseif cont == "dead" then
      s.Processor = coroutine.create(s.check)
      local value, done = coroutine.resume(s.Processor)
    end
  end

  function this.check()
    local s = AISatlas
    if not Flight.position then return end

    local lowest = math.huge
    local closeBodyId = 2

    for i, pId in ipairs(s.bodyIDs) do
      local body = atlas[s.sys][pId]
      local dist = Flight.position:dist(vec3(body.center))
      if dist < lowest then lowest = dist; closeBodyId = pId end
      coroutine.yield()
    end

    s.closeBodyId = closeBodyId
    s.body = atlas[s.sys][closeBodyId]
    --local atmoTopAlt = body.surfaceMaxAltitude + body.atmosphereThickness

    HUD.widgets.primary.tmpl:bind({
      ClosestBodyName = s.body.name[1],
      ClosestIcon = s.body.iconPath,
      AtmoAlt = format("%.1f", (s.body.atmosphereThickness or 0)/1000)..'km', --'99.9km', -- format(self.atmoDensity < 0.1 and "%.1f" or "%.0f", self.atmoDensity*100 or 0)..'%',
      Gravity = format("%.1f", s.body.gravity/10 or 0)
    });
  end

  function this.update(s)
    local dist = Flight.position:dist(vec3(s.body.center))
    --local atmoTopAlt = body.surfaceMaxAltitude + body.atmosphereThickness
    local atmoDist = dist - (s.body.radius+s.body.atmosphereThickness)
    --[[
      atmoDist is straight down, towards gravity
      abs() of velocity vector, angle between gravity... multiply against dist?
    ]]
    local timeV = Flight.speed<50 and "--:--" or formatTime(timeToDist(atmoDist, Flight.speed*3.6))
    Flight.inLowSpace = atmoDist>0
    Flight.atmoDist = atmoDist

    HUD.widgets.primary.tmpl:bind({
      ClosestBodyDistance = formatDist(abs(atmoDist)),
      ClosestBodyTime = timeV,
      ClosestBodyChange = atmoDist>0 and "atmo" or "space"
    });
  end

  function this.parsePOS(s, v)
    local num = ' *([+-]?%d+%.?%d*e?[+-]?%d*)'
    local systemId, bodyId, latitude, longitude, altitude = string.match(v, '::pos{' .. num .. ',' .. num .. ',' ..  num .. ',' .. num ..  ',' .. num .. '}')
    
    systemId  = tonumber(systemId)
    bodyId    = tonumber(bodyId)
    latitude  = tonumber(latitude)
    longitude = tonumber(longitude)
    altitude  = tonumber(altitude)
  
    if bodyId == 0 or bodyId == nil then -- this is a hack to represent points in space
      return {
        latitude  = latitude,
        longitude = longitude,
        altitude  = altitude,
        bodyId    = bodyId,
        systemId  = systemId
      }
      end
      return {
      latitude  = constants.deg2rad*utils.clamp(latitude, -90, 90),
      longitude = constants.deg2rad*(longitude % 360),
      altitude  = altitude,
      bodyId    = bodyId,
      systemId  = systemId
    }
  end

  function this.convertPOS(s, v)
    local mapPosition = s:parsePOS(v)
    if mapPosition.altitude == nil then 
      return nil 
    end
    if mapPosition.bodyId == 0 then -- support deep space map position
      return vec3(mapPosition.latitude,
        mapPosition.longitude,
        mapPosition.altitude)
    end
    local xproj = math.cos(mapPosition.latitude)
    local planet = atlas[mapPosition.systemId][mapPosition.bodyId]
    return vec3(planet.center) + (planet.radius + mapPosition.altitude) *
      vec3(xproj*math.cos(mapPosition.longitude),
      xproj*math.sin(mapPosition.longitude),
      math.sin(mapPosition.latitude))
  end

  function this:getVecToSZ()
    local mypos = Flight.position

  end

  function this:keyAction1()
    if Flight.keyLShift==1 then return end
    if Flight.position ~= nil then
      
      --madis = 7050, 6200
      --alioth = 6060, 4960
      --thades = 44.7k, 31.0k

      -- JUST USE ATMOSPHERETHICKNESS FOR THE ATMO START POINT
      local lowest = math.huge
      local closeBodyId = 2

      for i, pId in ipairs(self.bodyIDs) do
        local body = atlas[self.sys][pId]
        local dist = Flight.position:dist(vec3(body.center))
        if dist < lowest then lowest = dist; closeBodyId = pId end
      end

      local body = atlas[self.sys][closeBodyId]
      local atmoTopAlt = body.surfaceMaxAltitude + body.atmosphereThickness
      local atmoDist = abs(lowest - (body.radius+body.atmosphereThickness))
      --system.print( body.name[1].." Top: " .. formatDist(body.atmosphereThickness) .. ', out: ' .. formatDist(atmoDist) )

      HUD.widgets.primary.tmpl:bind({
        ClosestBodyName = 'Lacobus Moon 4', -- self.cpdata.name[1],
        ClosestBodyDistance = formatDist(calcDist(self.cpdata.center, self.position))
      });

    end
  end

  function this:safeZoneDist(WorldPos) -- Thanks to @SeM for the base code, modified to work with existing Atlas
    local safe = false
    distsz = vec3(WorldPos):dist(self.safeZonePos)
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

  --[[
    @return vec3 position of the target crossing point into nearest planet bubble or SZ
  ]]
  function this:closestSafeArea() -- Thanks to @SeM for the base code, modified to work with existing Atlas
    local safe = false
    local WorldPos = Flight.position
    distsz = vec3(WorldPos):dist(self.safeZonePos)
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

  return this
end)()
