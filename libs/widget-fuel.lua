Fuel = (function()
  local this = {
    tankSizes = {
      atmo = {
        xs = {35.03,100},
        s = {182.67,400},
        m = {988.67,1600},
        l = {5480,12800}
      },
      space = {
        xs = {35.03,100},
        s = {182.67,400},
        m = {988.67,1600},
        l = {5480,12800}
      },
      rocket = {
        xs = {173.42,400},
        s = {886.72,800},
        m = {4720,6400},
        l = {25740,50000}
      }
    },
    fuelWeights = {
      atmo = 4,
      space = 6,
      rocket = 0.8
    },
    mainTemplates = {},
    template = "",
    html = "",
    initBinds = {}
  };

  function this.compile(s, obj, name, start)
    s.template = ""
    for key,h in pairs(s.mainTemplates) do
      s.template = s.template .. h
    end
    s.initBinds[name] = {obj, start}
  end

  function this.ready(s)
    s.tmpl:compile(s.template)
    for name,set in pairs(s.initBinds) do
      set[1]:fill(set[2])
    end
  end

  function this:makeFuelTicks(perc)
    local cssFill, cssEmpty = 'fil1', 'fil3 op04'
    local tmpl, aperc = {}, round(perc/10, 0)
    for i=1,10,1 do
      local css = aperc >= i and cssFill or cssEmpty
      tmpl[#tmpl+1] = concat({[[<use xlink:href="#fuel_arr" transform="translate(]], ((i-1)*8)+1, [[ 0)" class="]], css, [["></use>]]})
    end
    return concat(tmpl)
  end

  function this.makeWidget(s, i, type)
    local o = {
      tickTemplate = {}
    }
    local yfac = -29 + (i*27)
    local xfac = 20
    
    if i>3 then
      local ymod = i%3==0 and 3 or i%3
      xfac = 20 - (floor((i-1)/3)*188)
      yfac = -29 + (ymod*27)
    end

    --  style="fill: rgb(58, 89, 113);"
    o.template = [[
      <g transform="translate(]]..xfac..[[ ]]..yfac..[[)">
        <polygon class="c-co" points="359.9 815.4 362.1 813 414.5 813 416.9 815.4" />
        <path class="c-co" d="M 347.3 833.2 L 441 833.2 L 441 815.5 L 347.3 815.7 L 347.3 833.2 Z M 347.3 814.8 L 441.7 814.8 L 441.7 833.9 L 347.3 833.9 L 347.3 814.8 Z" />
        {{ticks}}
        <polygon class="c-bg" points="439.8 832.2 439.8 816.6 433.6 816.6 438.4 824.4 433.6 832.2" />
        <path class="c-bg" d="M 342.6 832.2 L 348.8 827 L 348.8 816.6 L 312.2 816.6 L 312.2 832.2 L 342.6 832.2 Z" transform="matrix(-1, 0, 0, -1, 661.8, 1648.8)"/>
        <polygon class="c-bg" points="350.7 816.6 349.4 816.6 349.4 832.2 350.7 832.2 355.6 824.4"/>
        <text class="ffrd c-tm" style="text-anchor:end;text-transform:uppercase;" x="349.2" y="828.4">]]..type..[[</text>
        <path d="M 431.2 815.4 L 433.6 812.6 L 445.4 812.6 L 454.4 814.9 L 489.8 814.9 L 489.8 828 L 483.9 833.9 L 443.9 833.9 L 444 813.8 L 434.3 813.8 L 432.9 815.4 L 431.2 815.4 Z" class="c-co" />
        <text class="c-th ffrd" x="448.3" y="828.4" bx:origin="0.5 0.5">{{time}}</text>
      </g>
    ]]

    o.tmpl = Template.new(o.template);
    o.tmpl:listen(function(data)
      s.tmpl:bind({[type] = data.html})
      s.tmpl:render()
    end);

    o.fill = function(self, data)
      o.tmpl:bind(data)
      o.tmpl:render()
    end

    s.mainTemplates[type] = "{{"..type.."}}"
    s:compile(o, type, {})

    return o
  end

  function this.init(s)
    s.fuelWeightMod = (100-(5*fuelWeightTier)-(5*containerWeightTier))/100;
    s.fuelWeights.atmo = s.fuelWeights.atmo * s.fuelWeightMod;
    s.fuelWeights.space = s.fuelWeights.space * s.fuelWeightMod;
    s.fuelWeights.rocket = s.fuelWeights.rocket * s.fuelWeightMod;

    s.curTime = system.getArkTime();

    local kinds = {['Atmospheric Fuel Tank']='atmo',['Space Fuel Tank']='space',['Rocket Fuel Tank']='rocket'};
    local elemIDs = core.getElementIdList();
    local elemAll = {};
    local fuels = {}
    local html = ''

    s.fuelComps = {}

    for i=1,#elemIDs,1 do
      elem = {
        uid = elemIDs[i],
        name = core.getElementNameById(elemIDs[i]),
        kind = core.getElementDisplayNameById(elemIDs[i]),
        mass = core.getElementMassById(elemIDs[i])
      }
      kind = kinds[elem.kind]

      if kinds[elem.kind]~=nil then
        elem.size = 'xs'
        elem.size = string.lower(string.match(elem.name, " (%a%a?) "))
        elem.kind = kind
        --[[for k,o in pairs(self.tankSizes[kind]) do
          system.print(o[1]..' '..elem.mass)
          if elem.mass == o[1] then elem.size = k end
        end]]

        elem.subtype = string.match(elem.name, "%(([%a%d_]+)%)") or kind
        elem.lastTime = s.curTime;
        elem.percent = 1;
        elem.lastMass = 4;
        elem.mass = 2;
        elem.timeLeft = 1;
        elem.lastTimeLeft = 1;
        elem.maxMass = s.tankSizes[kind][elem.size][2] * (1 + (0.2 * _G[kind..'TankSizeTier'])) * s.fuelWeights[kind];
        if not fuels[elem.subtype] then fuels[elem.subtype] = {} end
        fuels[elem.subtype][#fuels[elem.subtype]+1] = elem

        if not s.fuelComps[elem.subtype] then 
          s.fuelComps[elem.subtype] = {} 
        end
      else
        -- other element item :: elemAll[#elemAll+1] = elem
      end
    end

    s.fuels = fuels;
    s.Processor = coroutine.create(s.update)

    KeyActions:register('tick', 'FuelUpdate', 'FuelUpdate', s, s.coUpdate);
    unit.setTimer('FuelUpdate', 0.04);
    
    s.tmpl = nil
    s.tmpl = Template.new(s.template)
    s.tmpl:listen(function(data)
      HUD.widgets.primary.tmpl:bind({MainFuel = data.html})
    end);

    HUD.widgets.primary.tmpl:bind({MainFuel = ""})

    local activeList = tableKeys(s.fuelComps)
    table.sort(activeList)
    for i, key in ipairs(activeList) do
      s.fuelComps[key].o = s:makeWidget(i, key)
    end

    s:ready()
  end

  function this.coUpdate(s)
    local cont = coroutine.status(s.Processor)
    if cont ~= "dead" then 
      local value, done = coroutine.resume(s.Processor)
      if done then log("ERROR UPDATE FUEL: "..done) end
    elseif cont == "dead" then
      s.Processor = coroutine.create(s.update)
      local value, done = coroutine.resume(s.Processor)
    end
  end

  function this.update()
    local s = Fuel

    for key, comp in pairs(s.fuelComps) do
      --coroutine.yield()
      s.curTime = system.getArkTime()
      local list = s.fuels[key]
      local showPerc = false
      comp.totalperc = 0
      comp.totaltime = 0

      for i, tank in ipairs(list) do
        coroutine.yield()
        s.curTime = system.getArkTime()
        tank.lastMass = tank.mass;
        tank.mass = core.getElementMassById(tank.uid) - s.tankSizes[tank.kind][tank.size][1];
        
        if(tank.mass ~= tank.lastMass) then
          tank.percent = ((tank.mass / tank.maxMass) or 0)*100;
          tank.lastTimeLeft = tank.timeLeft;
          tank.timeLeft = floor(tank.mass / ((tank.lastMass - tank.mass) / (s.curTime - tank.lastTime)))
          tank.lastTime = s.curTime;
        elseif s.curTime - tank.lastTime > 6 or showPerc then
          showPerc = true
        end
  
        comp.totalperc = comp.totalperc + (tank.percent or 0)
        comp.totaltime = comp.totaltime + (tank.timeLeft > 0 and tank.timeLeft or 0)
      end
      comp.avgperc = comp.totalperc / #s.fuels[key]
      comp.avgtime = comp.totaltime / #s.fuels[key]

      local fill = {}
      fill.ticks = s:makeFuelTicks(comp.avgperc)

      if comp.avgtime > (2*24*60*60) or comp.avgtime <= 1 or isINF(comp.avgtime) or showPerc then 
        fill.time = format("%.0f",comp.avgperc)..'%' 
      else
        fill.time = formatTime(comp.avgtime)
      end

      comp.o:fill(fill)
    end

  end

  return this;
end)();
