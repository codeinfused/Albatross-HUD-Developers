RadarSwitch = (function()
  local F = Flight
  local this = {
    radars={ {n="Off", t='off', radar={}} },
    active=0,
    activet='',

    incoming = {},
    contacts = {},
    sorted = {}
  }

  function this.init(s)
    KeyActions:register('start', 'option8', 'RadarSwitch', s, 'keyAction')

    for i,r in ipairs(radars) do
      local t = 0
      local d = r.getWidgetData()
      local j = json.decode(d)
      local n = j.name
      r.hideWidget()
      if n:lower():find('atmo') then t='atmo' else t='space' end
      s.radars[#s.radars+1] = {n=n, radar=r, t=t}
      if s.activet=='' then
        if (t=='space' and Flight.inSpace) or (t=='atmo' and not Flight.inSpace) then s.active=i+1; s.activet=t end
      end
    end

    s.active=1
    local r = s.radars[s.active]
    s.activet = r.t
    s.radar = r.radar
    
    s.button1 = HUD.buttons:createButton('RadarSwitch', "Active Radar", 'A:8', s.active>1 and "on" or "off")
    s.button1:toggle({label="Radar ["..r.n.."]", active = s.active>1 and "on" or "off"})

    --local rs = {self.radars[2].radar}
    --if self.active>1 then rs = {self.radars[self.active].radar} end
    --_autoconf.displayCategoryPanel(rs, 1, "Periscope", "periscope")
    --self:keyAction(self.active)

    --s.Processor = coroutine.create(s.coCheck)

    --[[
    KeyActions:register('tick', 'RadarIncoming', 'RadarIncoming', s, 'getIncomingList')
    unit.setTimer('RadarIncoming', 0.1)

    KeyActions:register('tick', 'RadarUpdate', 'RadarUpdate', s, 'coCheck')
    unit.setTimer('RadarUpdate', 0.016)

    KeyActions:register('tick', 'RadarRender', 'RadarRender', s, 'renderContacts')
    unit.setTimer('RadarRender', 0.1)
    ]]

  end

  --[[
  function this.coCheck(s)
    local cont = coroutine.status(s.Processor)
    if cont ~= "dead" then 
      local value, done = coroutine.resume(s.Processor)
      --if done then log("Atlas ready.") end
    elseif cont == "dead" then
      --log('radar loop finished')
      s.Processor = coroutine.create(s.updateContacts)
      local value, done = coroutine.resume(s.Processor)
    end
  end

  function this.getIncomingList(s)
    local r = s.radar -- s.radars[s.active].radar
    if r.getConstructIds == nil then return end
    
    s.incoming = r.getConstructIds()

    local remap = {}
    --for k,v in ipairs(s.incoming) do
    for k=1,#s.incoming,1 do
      local v = s.incoming[k]
      remap['c'..v] = 1
      if s.contacts['c'..v] == nil then 
        s.contacts['c'..v] = {
          cid = v
        }
      end
    end

    HUD.widgets.primary.tmpl:bind({
      RadarContactCount = #s.incoming
    });

    --for k,v in pairs(s.contacts) do
    for k=1,tablex.size(s.contacts),1 do
      if remap[k] ~= 1 then remove(s.contacts, k) end
    end

  end

  function this.updateStaticInfo(s, c)
    c.kind = s.radar.getConstructKind(c.cid)
    c.size = s.radar.getConstructCoreSize(c.cid)
    c.name = s.radar.getConstructName(c.cid)
  end

  function this.updateContacts(s)
    s = this
    local cmap = {}
    local r = s.radar
    local i = 0
    if r.getConstructIds == nil then return end
    for k,v in pairs(s.contacts) do
      i=i+1
      if i>30 then coroutine.yield(); i=0 end
      if v.name == nil then s:updateStaticInfo(v) end
      v.dist = r.getConstructDistance(v.cid)
      v.speed = r.getConstructSpeed(v.cid)
      cmap[#cmap+1] = {cid=v.cid, dist=v.dist}
    end

    table.sort(cmap, function(a, b)
      return a.dist < b.dist
    end)

    s.sorted = cmap
    -- at the end of update contacts, create sorted list (by distance)

    --log(tablex.size(s.contacts))
  end
  ]]

  function this.renderContacts(s)
    local radarDisplay = '';
    if #s.sorted < 11 then return end

    for k=1, 10, 1 do
      local c = s.contacts['c'..s.sorted[k].cid]
      radarDisplay = radarDisplay .. [[
        <p>]]..c.name..[[ (]]..c.kind..[[) (]]..c.size..[[) // ]]..formatDist(c.dist)..[[ // ]]..(c.speed*3.6)..[[kmh</p>
      ]]
    end

    HUD.widgets.primary.tmpl:bind({
      RadarList = radarDisplay
    });
  end
  

  function this.keyAction(s, i)
    if F.keyLShift == 1 then return end
    if s.active>1 then s.radars[s.active].radar.hideWidget() end
    if not i then 
      s.active = s.active>1 and 1 or 2
    else 
      s.active = i
    end
    if s.active > #s.radars then s.active = 1 end
    local r = s.radars[s.active]
    if s.active>1 then
      r.radar.showWidget()
    end
    s.activet = r.t
    s.radar = r.radar

    s.button1:toggle({label="Radar ["..r.n.."]", active = s.active>1 and "on" or "off"})
  end

  function this.force(s, t)
    for i,r in ipairs(s.radars) do
      if r.t==t then 
        s:keyAction(i)
        return
      end
    end
  end

  return this
end)()