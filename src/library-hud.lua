--[[
local shakeStr = 1
local vals = {0, 0.09, -0.09, 0.05, -0.05, 0.02, 0.02}
local numX = vals[math.random(7)] * shakeStr
local numY = vals[math.random(7)] * shakeStr
local blur = (numX + numY) / 2

Render.shakeX = numX
Render.shakeY = numY
Render.blur = blur
]]

--[[
  deep red:           801c00  128, 28, 0      13, 95%, 25%
  dark deep red:                              13, 90%, 18%
  steel blue:         3a5971  58, 89, 113     206, 32%, 34%
  dark steel blue:    2d485c  45, 72, 92      206, 27%, 27%
  darker steel blue:  2b4355  43, 67, 85
  bright blue:        4992CF  73, 146, 207    206, 58, 55
  bright green:       58B947  88, 185, 71
  bright orange:      F99F37  249, 159, 55

  ui bright
  ui dark (bg)
  ui font
  ui header bg                58, 89, 113   206°, 16%, 40%

  if core L is above 70%, change font to dark 
]]

HUD = Controller.new({
  styles = "",
  widgets = {},
  activated = {},
  deactivated = {},
  hsls = {},
  color = '#4992CF',
  opacity = '0.95',
  scale = 1
});


function HUD:opacitize(str)
  self.opacity = str/100
  self:colorize()
end

function HUD:scalize(str)
  self.scale = str/100
  self:colorize()
end

function HUD:colorize(str)
  if not str then str = self.color end
  self.color = str
  local hslraw = HxHSL(str)
  local hsls = {
    core = HSLmod(hslraw,0,0),
    bg = HSLmod(hslraw,-23,-24),
    headbg = HSLmod(hslraw,-26,-20),
  }
  hsls.gyro = hsls.core

  if hslraw[3] > 60 then
    hsls.txthi = 'hsl(0,0%,15%)'
    hsls.txtmd = 'hsl(0,0%,15%)'
  else 
    hsls.txthi = 'hsl(0,0%,100%)'
    hsls.txtmd = 'hsl(0,0%,77%)'
    hsls.gyro = 'hsl(0,0%,80%)'
  end

  if hudTextColor ~= '' and hudTextColor ~= nil then
    hsls.txtmd = hudTextColor
  end

  --local r,g,b = hsl_to_rgb(hslraw[1],hslraw[2],hslraw[3])
  -- "rgb("..r..","..g..","..b..")"
  
  HUD.widgets.primary.tmpl:bind({
    HSLScore = self.color
  })

  local oppX = - (-4.15 * self.scale) --  * (1 - (self.scale - 1)) -- 4.425 -- * (1 - (self.scale - 1)) -- scale calculation for X offset swings to left and right of center
  oppX = oppX .. "vh"

  self.styles = [[
    <style>
    .olay{position:absolute;top:0vh;left:0vw;width:100vw;height:100vh;z-index:5;font-size:0.5vh;color:#fff;opacity:]]..self.opacity..[[;}
    .hud-fill{position:absolute;top:0vh;left:0vw;width:100vw;height:100vh; /*background:rgba(255,255,255,0.25);*/ backdrop-filter:blur(50px);}
    .hud-scope{position:absolute;bottom:52vh;right:1vh;height:18vh;width:22vh;border:2px solid #bbb;}
    .hud-shields{position:absolute;/*bottom:35vh;*/top:0.75vh;left:1vh;height:9.25vh;text-align:center; opacity:0.85; display:none;}
    .hud-body{position:absolute;bottom:0.6vh;left:0;right:0;height:calc(17.75vh * ]]..self.scale..[[); transform:translateX(]]..oppX..[[);}
    .hud-warning{position:absolute;top:14vh;height:7vh;width:100vw;margin-left:50%;left:-50%;display:none;}
    .olay svg{display:inline-block; position:absolute; top:0;left:0; height:100%; margin-left:50%; transform:translateX(-50%);
      filter: drop-shadow(0.11rem 0.15rem 0.4rem rgba(0, 0, 0, 0.4));
      font-family:Refrigerator; font-weight:900; z-index:10;
    }
    .hud-body-txt{
      display:inline-block; height:100%; margin-left:50%; transform:translateX(-50%); 
      position:relative; width:707px;
      font-family:Refrigerator; font-weight:900;
      z-index:15;
    }
    </style>
    <style type="text/css">
      .dt{postion:absolute; font-size:12px; white-space:pre;}
      text{font-size:12px; white-space:pre;}
      .st0{fill:none;stroke:]]..hsls.core..[[;stroke-miterlimit:10;}          /* outline and focus color */
      .ffrd{font-family:Refrigerator; font-weight:900;}
      .ffro{font-family:Roboto;}
      .fs7{font-size:7px;}
      .fs8{font-size:8px;}
      .fs11{font-size:11px;}
      .fs12{font-size:12.4px;}
      .fs13{font-size:13px;}
      .fs14{font-size:14px;}
      .fs15{font-size:15px;}
      .fs17{font-size:17px;}
      .fs20{font-size:20px;}
      .fs22{font-size:22px;}
      .ftam{text-anchor:middle;}
      .fttu{text-transform:uppercase;}
      .fls1{letter-spacing:-0.1px;}
      .st15{font-size:10px;glyph-orientation-vertical:0;writing-mode:tb;}
      .fil3{fill: #2b4355;}  /* dark blue bg */
      .fil1{fill: rgb(88,185,71);}   /* green success fill */
      .fil2{fill: rgb(73,146,207);}  /* bright blue accent */
      .fil4{fill: rgb(249,159,55);} /* orange accent */
      .c-bg{fill:]]..hsls.bg..[[;}
      .c-co{fill:]]..hsls.core..[[;}
      .c-hb{fill:]]..hsls.headbg..[[;}
      .c-th{fill:]]..hsls.txthi..[[;}
      .c-tm{fill:]]..hsls.txtmd..[[;}
      .c-wh{fill:#ffffff;}
      .c-ow{fill:#bbbbbb;}
      .c-gyr{fill:]]..hsls.gyro..[[;}
      .c-wh{fill:#fff;}
      .op03{opacity:0.3;}
      .op04{opacity:0.4;}
      .op06{opacity:0.6;}
      .btn-dis{opacity:0.25; fill: rgb(90,90,90);}
      .btn-on{fill: rgb(88,185,71);}
      .btn-lock{fill: rgb(197,103,103);}
      .btn-temp{fill: #bcc21d;}
      .btn-off{opacity:0.8; fill: rgb(120,120,120);}
      .logo1{display:none;}
      #gyrolines text{alignment-baseline:middle;}
      .lastTick{fill:url(#lastTick); overflow:hidden;}
    </style>
  ]]
end

HUD.n=concat({'A','l','b','a','t','r','o','s','s'})
Menu = (function()
  local this = {
    LSkey = 0,
    LSloops = 0,
    show = 0
  }
  function this.menuLShiftStart(s)
    s.LSkey = 1
  end

  function this.menuLShiftStop(s)
    s.LSkey = 0
    s.LSloops = 0
    s.show = 0
    system.lockView(false)
  end

  function this.menuLShiftLoop(s)
    if s.LSloops < 100 then -- rewrite this to use a TRUE TIMER, built into the system.flush module
      s.LSloops = s.LSloops + 1
    elseif s.show==0 then
      s.show = 1
      system.lockView(true)
    end
  end

  return this;
end)();

HUD.full = {
  init = function(s)
    KeyActions:register('tick', 'HUDrender', 'HUDrender', s, 'render');
    KeyActions:register('tick', 'HUDupdate', 'HUDupdate', s, 'update');
    unit.setTimer('HUDupdate', 0.3);

    KeyActions:register('start', 'lshift', 'menuLShiftStart', Menu, 'menuLShiftStart')
    KeyActions:register('stop', 'lshift', 'menuLShiftStop', Menu, 'menuLShiftStop')
    KeyActions:register('loop', 'lshift', 'menuLShiftLoop', Menu, 'menuLShiftLoop')
  end,

  fps = function(s, fps)
    local rate = 1/fps
    unit.stopTimer('HUDrender')
    unit.setTimer('HUDrender', rate)
  end,

  --[[
    function calculateBrakingDistance()
      local speed = vec3.new(core.getVelocity()):len()
      local mass = core.getConstructMass()
      local maxBrakingForce = json.decode(unit.getData()).maxBrake
      if not maxBrakingForce then
        brakingDistance = 0
        brakingDistanceUnit = "km"
        return
      end

      local c = (30000*1000)/3600
      local cSq = c*c
      local totA = -maxBrakingForce * (1 / mass)

      local k1 = c * math.asin( speed / c)
      local k2 = cSq * math.cos(k1 / c) / totA
      local t = -k1 / totA
      local d = k2 - cSq * math.cos( (totA*t + k1) / c ) / totA
      local d_su = d / 200000

      if d_su < 0.5 then
        brakingDistance = d / 1000
        brakingDistanceUnit = "km"
      else
        brakingDistance = d_su
        brakingDistanceUnit = "su"
      end

    end
  ]]

  update = function(s)
    Throttle:update()

    brakeData = unit.getWidgetData()
    -- construct.getCurrentBrake(), construct.getMaxBrake()
    local currentBrake, maxBrake = construct.getCurrentBrake(), construct.getMaxBrake() -- brakeData:match([["currentBrake":([%d%.]*),.*,"maxBrake":([%d%.]*)]])
    Flight.currentBrake = currentBrake
    Flight.maxBrake = maxBrake

    local fwdReverseThrust = construct.getMaxThrustAlongAxis('fueled', construct.getOrientationForward()[4]);

    local distance, time_s = calcBrakeDist2(0)
    --initial, final, restMass, thrust, t50, brakeThrust

    --[[local distance, time_s = computeDistanceAndTime2(
      Flight.speed,
      0,
      Flight.mass,
      0,
      0,
      maxBrake
    );
    ]]

    local showDist = formatDist(distance)

    Flight.mode = unit.getControlMode()
    Flight.brakeDistance = distance
    local tLabel, tValue = '', ''
    local modeLabel = Flight.mode==0 and "THROTTLE" or "CRUISE SPD"

    if Flight.mode == 0 then
      tLabel = 'THROTTLE'
      tValue = format("%.0f", Throttle.real).."%"
    else
      tLabel = 'SPD'
      tValue = format("%.0f", Throttle.real/100).." kmph"
    end

    HUD.widgets.primary.tmpl:bind({
      BrakesMax = format("%.0f", (maxBrake or 0)/1000),      -- Reading MaxBrake from atmo gives you: maxBrake * clamp(speedInMPS/100, 0.1, 1) * atmoDensity
      BrakesUsed = format("%.0f", (currentBrake or 0)/1000),
      ShipMass = format("%.0f", (Flight.mass or 0)/1000),
      ModeLabel = modeLabel,
      ThrottleLabel = tLabel,
      ThrottleValue = tValue,
      WidgetThrottle = Throttle.html,
      BrakingDistance = showDist,
      BrakingTime = time_s --formatTime(time_s),
    });
  end,

  reset = function(s) s.widgets = {} end,
  html = "",
  htmlobj = {},
  widgets = {},

  render = function(s)
    --[[
    HUD.widgets.primary.tmpl:bind({
      Pitch = format("%.2f",(Flight.spitch or 0)*1.6,1), --format("%.1f",self.pitch),
      Roll = format("%.2f",-Flight.sroll or 0,1) --format("%.1f",self.roll)
    });
    ]]

    -- system.print( "x: "..format("%.2f", system.getMousePosX()).." / y: "..format("%.2f", system.getMousePosY()) ); -- X and Y are range 0 to viewport-1px (0-1599)

    s.htmlobj = {
      [[<div class="olay">]],
      HUD.styles
    };
    for key,v in pairs(s.widgets) do
      HUD.widgets[key].tmpl:render()
      s.htmlobj[#s.htmlobj+1] = HUD.widgets[key].html
    end
    
    s.htmlobj[#s.htmlobj+1] = [[</div>]]
    s.html = concat(s.htmlobj)
    system.setScreen(s.html)

  end

};

HUD.widgets.shiphp =  {
  init = function(s)
    s.tmpl = Template.new(s.template);
    s.tmpl:listen(function(data)
      s.html = data.html;
    end);
  end,
  html = "",
  template = [[]]
}

local function makeGyroLines()
  local ls = {}
  for i=-9,9,1 do
    local ly = 309.8 + (i*16)
    local ld = -i*10
    if i~=0 then
      ls[#ls+1]=[[
        <text class="c-gyr ftam fs7" x="341.2" y="]]..ly..[[">]]..ld..[[</text>
        <text class="c-gyr ftam fs7" x="443.6" y="]]..ly..[[">]]..ld..[[</text>
        <line class="st0" x1="428" y1="]]..ly..[[" x2="437" y2="]]..ly..[["/>
        <line class="st0" x1="347" y1="]]..ly..[[" x2="356" y2="]]..ly..[["/>
      ]]
    end
  end

  return concat(ls)
end

HUD.widgets.primary = {
  centerControlMode = 'warp',
  init = function(s)
    s.tmpl = Template.new(s.template());
    s.tmpl:listen(function(data)
      s.html = data.html;
    end);
    HUD.full.widgets['primary'] = 'primary';
  end,

  TertiaryFields = (function()
    local html = ""
    local startY = 786.3
    local fields = {
      --{'ACCELERATION', '{{Acceleration}}'},
      {'{{ZoneDistLabel}}', '{{ZoneDist}}'},
      {'SAFE LOCAL LOAD', '{{SafeLocalMass}} t'},
      {'SAFE ALIOTH LOAD', '{{SafeAtmoMass}} t'},
      {'BURN SPEED', '{{BurnSpeed}} kmph'},
      {'MAX SPACE KMPH', '{{MaxSpeed}}'},
      {'ATMO DENSITY', '{{AtmoDensity}}'},
      {'ONBOARD COUNT', '{{BoardedCt}} players'},
      {'DOCKED COUNT', '{{DockedCt}} ships'}
      --{'ACCELERATION', '{{}}'},
      --{'ACCELERATION', '{{}}'},
    }

    for k,o in ipairs(fields) do
      local dy = ((k-1)*14.8) + startY
      html = html .. [[
<text class="c-tm" x="1039" y="]]..dy..[[">]]..o[2]..[[</text>
<text class="c-co" x="959.6" y="]]..dy..[[">]]..o[1]..[[</text>
      ]]
    end
    --[[
      <text class="c-tm" x="1039" y="804.1" data-y="14.8">{{ZoneDist}}</text>
      <text class="c-co" x="959.6" y="804.1">{{ZoneDistLabel}}</text>
      <text class="c-tm" x="1039" y="818.9" data-y="14.8">{{MaxSpeed}} kmph</text>
      <text class="c-co" x="959.6" y="818.9">MAX SPEED</text>
      <text class="c-tm" x="1039" y="833.7">{{BurnSpeed}} kmph</text>
      <text class="c-co" x="959.6" y="833.7">BURN SPEED</text>
      <text class="c-tm" x="1039" y="848.5">{{AtmoDensity}}</text>
      <text class="c-co" x="959.6" y="848.5">ATMO DENSITY</text>
      <text class="c-tm" x="1039" y="863.3">{{BoardedCt}} players</text>
      <text class="c-co" x="959.6" y="863.3">ONBOARD COUNT</text>
      <text class="c-tm" x="1039" y="878.1">{{DockedCt}} ships</text>
      <text class="c-co" x="959.6" y="878.1">DOCKED COUNT</text>
      <text class="c-tm" x="1039" y="892.9">{{SpcBrake}}</text>
      <text class="c-co" x="959.6" y="892.9">ENTRY BRAKES</text>
    ]]

    return html
  end)(),

  gyroLines = makeGyroLines(),

  CenterNav = function()
    if Flight.inSpace then return [[<g transform="matrix(1.63676, 0, 0, 1.63676, 158.69531, 298.66381)" id="Navball" style="clip-path: url(#clip-gyrowrap);"></g>]] end
    if not Flight.spitch or not Flight.sroll then
      Flight.spitch = 0
      Flight.sroll = 0
    end
    local Pitch = format("%.2f",(Flight.spitch or 0)*1.6,1)
    local Roll = format("%.2f",-Flight.sroll or 0,1)

    local html = concat({[[<g transform="matrix(1.63676, 0, 0, 1.63676, 158.69531, 298.66381)" id="Navball" style="clip-path: url(#clip-gyrowrap);">
      <g id="NavballCenter">
        <polyline class="st0" points="419,300.8 410,305.3 410,314.3 419,318.8 &#9;&#9;" style="stroke: rgb(249, 159, 55);"/>
        <polyline class="st0" points="365,300.8 374,305.3 374,314.3 365,318.8 &#9;&#9;" style="stroke: rgb(249, 159, 55);"/>
        <line class="st0" x1="392" y1="305.3" x2="392" y2="314.3" style="stroke: rgb(249, 159, 55);"/>
        <line class="st0" x1="404.1" y1="309.8" x2="379.9" y2="309.8" style="stroke: rgb(249, 159, 55);"/>
      </g>
      <g id="gyrolines" transform-box="view-box" transform="rotate(]], Roll, [[, 392, 310) translate(0 ]], Pitch, [[)">
        <line class="st0" x1="422.8" y1="309.8" x2="447.2" y2="309.8" style="stroke: rgb(249, 159, 55);"/>
        <line class="st0" x1="338" y1="309.8" x2="361.4" y2="309.8" style="stroke: rgb(249, 159, 55);"/>
        ]], HUD.widgets.primary.gyroLines, [[
      </g>
    </g>]]});

    return html
  end,

  html = "",
  template = function()
    return [[
  <div class="hud-fill">
    <svg style="width:100%;height:100%;">
      {{ReticleFwd}}
      {{ReticlePro}}
      {{ReticleRtr}}
      {{ReticleBody}}
    </svg>
  </div>

  <div class="hud-body">
    <div class="hud-body-txt">
      
    </div>
    <svg viewBox="329.2 697.2 1036.2 201" style="overflow:visible;">
      <defs>
        <linearGradient id="gradient-1-1" gradientUnits="userSpaceOnUse" x1="297.8" y1="266.9" x2="297.8" y2="270.6" gradientTransform="matrix(1.63676, 0, 0, 1.63676, 158.69531, 298.66382)" xlink:href="#gradient-1"/>
        <linearGradient id="lastTick" gradientTransform="rotate(90)">
          <stop offset="{{LastTickP}}" style="stop-color: {{HSLScore}}; stop-opacity:0.3;"/>
          <stop offset="{{LastTickP1}}" style="stop-color: #58B947; stop-opacity:1;"/>
        </linearGradient>
        <g id="BUTTON_SINGLE">
          <path class="c-co" d="M 953.8 722.4 L 994.6 722.4 L 978.8 738.1 L 953.8 738.1 L 953.8 722.4 Z" />
          <path d="M 997.8 722.4 L 1001.2 722.4 L 985.4 738.1 L 982 738.1 L 997.8 722.4 Z" />
          <path class="c-bg" d="M 1004.3 722.3 L 1182.6 722.4 L 1166.8 738.1 L 988.4 738.1 L 1004.3 722.3 Z" style="fill-opacity: 1;" transform="matrix(-1, 0, 0, -1, 2171, 1460.39996)"/>
          <path d="M 939.4 722.4 L 951.3 722.4 L 951.3 733 L 946.2 738.1 L 939.4 738.1 L 939.4 722.4 Z" transform="matrix(-1, 0, 0, -1, 1890.70001, 1460.5)"/>
        </g>
        <g id="fuel_arr">
          <polygon points="351.8 816.6 356.8 824.4 351.8 832.2 358.9 832.2 363.9 824.4 358.9 816.6" />
        </g>
        <clipPath id="clip-gyrowrap">
          <path d="M 303.7 282.3 L 335.1 250.5 L 364.4 250.5 L 369 254.9 L 415.7 255 L 420.3 250.2 L 449.5 250.3 L 468 268.8 L 479.7 268.8 L 479.9 283.6 L 466.6 297 L 466.7 340.1 L 479.9 353.2 L 479.9 366.2 L 304.8 366.3 L 304.8 353.3 L 318.4 339.7 L 318.3 297 L 303.7 282.3 Z" style="fill: rgb(212, 141, 141); fill-opacity: 1;" id="NavballMask"/>
        </clipPath>
      </defs>

      {{AGGView}}

      <g id="WIDGET_CLOSEST">
        <path class="c-bg" fill-opacity=".88" d="m605.8 738.3-38.2 38.2h-48.3l-12.1 12.1-177.9.1v-50.6l276.5.2Z" paint-order="fill"/>
        <text x="519.1" y="767.1" class="c-co fs13"></text>
        <text x="335.1" y="750.4" class="c-co" style="font-size:11.5px; font-style:italic;">Closest Body</text>
        
        <g transform="translate(-12 0)">
          <circle cx="461.3" cy="765.8" r="14.7" class="st0"/>
          <path d="M453.9 743.7h14.7l14.8 14.7v22.1" class="st0"/>
          <path d="M451.77 754.35c.16.66.65 1.15 1.3 1.31.33.17.66 0 .99 0 .16 0 .49 0 .65.17.17.16.17.32.33.49.33.65.82.81 1.47.49.5-.17.82-.33 1.31-.5.5-.16.99 0 1.48.17.65.16 1.47.5 2.12.16.5-.32.82-.81.5-1.3-.17-.33-.33-.5-.66-.66-.33-.16-.49-.5-.16-.82.16 0 .16-.16.32-.16.17-.17.17-.66.33-.98.17-.5.33-.99.66-1.31.16-.17-.17-.5-.33-.17l-.5.98c-.16.33-.16.66-.32.99-.16.32-.49.32-.65.49a.5.5 0 0 0 0 .65c.16.5 1.3.98.81 1.64-.65.65-1.63.16-2.45 0a2.74 2.74 0 0 0-1.96.16c-.33.17-.66.33-1.15.5-.66.16-.66-.33-.82-.82-.16-.5-.65-.5-1.14-.5-.82 0-1.64-.16-1.97-.98.16-.33-.16-.33-.16 0zm-1.31 7.2c-.5.33-.33.99.16 1.15.17 0 .33 0 .5.16.48 0 .48.17.65.66.16.33.16.49.49.65.82.33 2.13-.65 2.62.5.32.65-.17 1.14-.82 1.3-.33 0-.66-.32-.98-.32-.66.16-.33 1.14 0 1.3.32.33.82.33.98.82.16.5.16.99.33 1.48.32.65.81 1.3 1.63 1.14.33 0 .66-.16.99-.49.49-.33.81-.65 1.47-.33.49.33 1.3.66 1.8.17.49-.5.49-1.31.33-2.13-.17-.66-.17-1.31.32-1.8.33-.33.66-.66.82-.98.17-.5.33-1.64-.33-1.64s-1.14.82-1.47 1.15c-.16.16-.33.49-.49.16-.16-.16 0-.65.16-.65.17-.17.66-.17.66-.5.16-.65-.98-.65-1.31-.65-.82.16-1.8.82-2.46.16-.49-.49-.49-1.3-1.14-1.63-.33-.17-.66-.17-.82 0-.65.16-.98.65-1.47 0-.33-.33-.5-.66-.82-.66-.5-.16-.98-.16-1.31 0-.33 0-.66.17-.66.66-.16 0 0 .32.17.32s.33-.32 0-.49c0 0 0-.16.16-.16 0-.16.17-.33.33-.16h.98c.5.16.5.49.82.81.5.33.98.33 1.47 0 .33-.16.82-.49 1.15-.16.16.16.33.5.49.82.16.49.5.82.98 1.14.5.17 1.15 0 1.64-.16.33-.16.65-.33.98-.16 0 0 .33 0 .33.16h-.17c-.16 0-.16 0-.32.16-.33.33-.5.99-.17 1.48.33.49.82 0 1.15-.17.16-.16.33-.49.65-.65.17-.16.17-.33.33-.33.5-.16.5.33.33.66-.17.81-1.15 1.14-1.31 1.96-.16.82.33 1.64.16 2.46 0 .49-.32.98-.98.81l-.98-.49c-.66-.16-.98 0-1.47.33-.5.33-.82.65-1.48.33-.49-.33-.65-.82-.82-1.31-.16-.66-.16-1.31-.81-1.64-.17-.16-.33-.16-.5-.33-.16-.16-.32-.32-.16-.49.16-.16 0 0 .16 0 .33 0 .5.17.82.17 1.31-.17 1.64-1.97.33-2.46-.33-.16-.65 0-.98 0-.33 0-.5.17-.82.17-.5 0-.5-.33-.66-.66 0-.33-.16-.5-.32-.5-.17-.15-.33-.15-.5-.15h-.16s-1.14-.17-.65-.5c.49-.16.33-.65 0-.49zm23.9-2.45c-.66-.33-1.8-.82-2.62-.66-.33.17-.33.33-.5.5-.32.16-.49.32-.81.49-.33-.17-.5-.33-.82-.5-.17-.16-.33-.32-.5-.32-.48-.33-1.63-.5-1.96.16-.16.16-.16.5-.16.66 0 .32.82.65.65.81-.16.17 0 .33 0 .33.5.33 1.64 1.31.99 2.13-.33.33-.66.33-1.15.33-.33 0-.5-.17-.82-.17-.33-.16-.49-.49-.49-.98 0-.16 0-.33-.16-.33-.5-.49-1.15.17-1.48.5-.32.49-.16.65-.16 1.14 0 .5-.33 1.15 0 1.8.16.33.33.5.66.66.49.32.81.32.98.81.16.17.16.5.16.66.16.33.33.49.66.65 1.63.66.81 1.64-.17 2.3-.82.49-1.47 1.14-1.63 2.12 0 .82.49 1.8 1.3 1.97.33 0 .66 0 .99-.17.16 0 .16-.16.32-.32s.17-.17.17-.33c.16-.17.16 0 .16.49v.33c.82.49.33.98.66 1.47l.32.33c.5.32.66.49.66.98 0 .33.49.16.33-.16-.17-.82-.82-.99-1.15-1.8-.16-.66-.16-.99-.82-1.31v.32c.33-.49 0-1.3-.65-1.3-.17 0-.17 0-.17.16-.16.82-.98.98-1.63.65-.5-.33-.66-.98-.5-1.63.17-.82.82-1.15 1.48-1.64.65-.5 1.47-.98 1.3-1.97 0-.32-.16-.49-.32-.65-.16-.16-.33-.16-.5-.16a2.2 2.2 0 0 1-1.14-.99c-.16-.32-.16-.65-.49-.81-.16-.17-.32-.17-.32-.33-.5-.33-.5-.17-.66-.82-.16-.5 0-.5 0-.98 0-.17-.16-.33-.16-.66s.16-1.63.82-.98c0-.16.16.5.16.5.33.65 1.14.81 1.64.81 2.12-.16 1.47-2.3.16-3.1v.32c.33-.33.33-.66 0-.98 0 0-.16 0-.16-.17-.33 0-.33-.16-.17-.33 0-.32 0-.32.33-.32.65-.33 1.3.49 1.8.82.33.32.82.49 1.3.16.5-.33.5-.98 1.16-.98.65 0 1.3.32 1.8.49 1.47.49 1.63.16 1.3 0zm-18.34 12.11a.9.9 0 0 0-.82.5c-.16.32 0 .65.17.81.16.16.33.16.49.16h.33v.17s0 .16.16.16c.16.16.16.16.33.16h.49c.16.17.33 0 .33-.16 0-.33-.17-.49-.33-.65l-.16-.17v-.32c0-.33-.5-.5-.99-.66 0 0-.16 0 0 0-.16.16-.16.33 0 .33.33.16.66.16.66.49 0 .16 0 .33.16.49l.17.16s.16 0 .16.17c.16 0 .16 0 .33-.17-.17-.16-.5-.16-.66-.16h-.33v-.16c0-.17-.16-.33-.16-.33-.16-.16-.33-.16-.33-.16-.16 0-.49 0-.49-.17s.17-.33.5-.33c.32.33.32-.16 0-.16z" class="c-co"/>
        </g>
        <!--<image href="{{ClosestIcon}}" x="461.3" y="765.8" width="29.4" height="29.4" />-->
        <text class="c-co fs13" transform="translate(478 752.4)">{{ClosestBodyDistance}}</text>
        <text class="c-co fs13 fttu" transform="translate(519.1 752.4)">TO {{ClosestBodyChange}}</text>
        <text class="c-co fs13" transform="translate(478 767.12)">{{ClosestBodyTime}}</text>
        <text class="c-co fs13" transform="translate(478 781.84)">{{Gravity}}g</text>
        <text class="fttu c-co" x="335.2" y="766.7" style='font-size:16.1px;'>{{ClosestBodyName}}</text>
        <text class="fs13 c-co" x="335.2" y="781.7">{{AtmoAlt}} Atmo Altitude</text>
      </g>

      <g id="ui-framing-lines">
        <g class="logo1">
          <path d="M644.49 790.48c.4-.27.81-.6 1.22-.88 1.9-1.36 3.67-2.92 5.5-4.41.81-.68 1.63-1.36 2.51-1.83a7.63 7.63 0 0 1 4.55-1.02 7.16 7.16 0 0 1 5.36 3.12 7.05 7.05 0 0 1 1.36 3.4 7.46 7.46 0 0 1-2.17 6.37 6.98 6.98 0 0 1-4.08 2.1 7.5 7.5 0 0 1-7.33-2.91c-.6-.75-.47-1.7.2-2.3.41-.35.75-.69 1.16-.96.75-.54 1.77-.4 2.3.34a2.9 2.9 0 0 0 2.38 1.15 2.8 2.8 0 0 0 .89-5.43c-.48-.2-1.02-.2-1.56-.13-1.9.13-3.74.74-5.57 1.36-1.7.54-3.4 1.15-5.02 1.7-.55.2-1.09.26-1.7.33 0 .07 0 0 0 0z" class="c-co"/>
          <path d="M654.2 789.26c-.61.48-1.23.88-1.84 1.36-1.7 1.36-3.32 2.71-4.95 4.07a11.6 11.6 0 0 1-3.06 2.04 7.5 7.5 0 0 1-6.38 0 7.13 7.13 0 0 1-4.2-5.57 7.38 7.38 0 0 1 2.64-7.13 7.23 7.23 0 0 1 4.75-1.76 7.46 7.46 0 0 1 6.11 2.99c.61.74.48 1.76-.34 2.37l-1.01.82c-.75.6-1.9.47-2.45-.28a2.96 2.96 0 0 0-1.83-1.15 2.8 2.8 0 0 0-3.2 2.17c-.26 1.56.62 2.99 2.11 3.33.61.13 1.22.07 1.77 0 2.03-.27 4-.95 5.9-1.63a52.3 52.3 0 0 1 4.62-1.5c.47 0 .95-.06 1.36-.13z" class="c-co"/>
        </g>
        <g transform="scale(0.48) translate(932,1435)">
          <path class="c-co" d="M459.2,234.2c0,0-4.4-8-7.7-13.2c-0.7,1.5-1.5,2.9-2.4,4.2C453.4,228.8,459.2,234.2,459.2,234.2z"/>
          <path class="c-co" d="M409.2,188.8c-6.6-1.9-14.7-4-14.7-4s6.8,3.7,11.9,6.7C407.3,190.6,408.2,189.7,409.2,188.8z"/>
          <path class="c-co" d="M445,222.1c-2.3-1.2-15.1-6.7-17-6.5c-1.9,0.2-7.7,3.3-8.7,4.3s-1.5,2.9-1.5,2.9l-4.4,1.2l-1.2-0.7l1.4-4.2
            c0,0,2.6-1.2,3.5-2.1c0.9-0.9,4.7-5.8,4.7-7.4s-7.9-12.3-10-14.4c-0.7-0.7-2.8-2-5.3-3.5c-4.2,4.8-6.8,11.1-6.8,18
            c0,15,12.2,27.2,27.2,27.2c9.2,0,17.3-4.6,22.2-11.5C447.3,223.7,445.7,222.4,445,222.1z"/>
          <path class="c-co" d="M426.3,203.6c1.3,1.3,2.8,0,2.8,0s1.9-2.6,4.7-2.6c2.8,0,2.8,1.9,2.8,1.9s3.1,0.1,3.4,2.2
            c-1.6-0.7-3-0.7-3.8-0.3c-0.8,0.3-3.7,3-2.4,5c1.3,2,12.6,5.1,15,7.3c0.7,0.6,1.7,2.1,2.9,3.9c1.6-3.5,2.5-7.4,2.5-11.5
            c0-15-12.2-27.2-27.2-27.2c-6.7,0-12.9,2.5-17.7,6.5c3.9,1.1,7.3,2.2,8.2,2.9C420.1,193.5,425,202.3,426.3,203.6z"/>
        </g>
        <path d="m510.73 700.05 3.77 3.77-3.77 3.6m-4.91-7.37 3.77 3.77-3.77 3.6m-4.91-7.37 3.77 3.77-3.77 3.6M653.5 764.8l21.9 22.1v66.3l-21.9 22.1v22.1m294.6 0v-22.1L926 853.2v-66.3l22.1-22.1v-22.1h417.3" class="st0"/>
        <path fill-opacity=".88" d="M515.4 710.7h118.1l12.7-12.7H528.5z" class="c-bg"/>
        <path d="M329.4 794.3h287.3l95.7-95.8h176.8l36.8 36.9h439.4" class="st0"/>
        <path d="M329.4 735.4h279.9l22.1-22.1H476.7L462 728H329.4zm302 44.1H520.9l-12.3 12.4H329.4v7.5h283.5zm73.6-73.6h51.6l7.4 7.4h73.6l7.4-7.4h51.5l-7.3-7.4H712.4z" class="c-co"/>
        <text x="392.08" y="251.26" class="c-th ftam" style="font-size:7px;" transform="translate(158.7 298.66) scale(1.63676)">]]..HUD['n']..[[ v{{HUDver}}</text>
        <path d="M903.9 713.3h110.5l14.7 14.7h336.3v7.4H926l-22.1-22.1Zm36.8 58.9v95.7L926 853.2v-66.3z" class="c-co"/>
        <!--<path fill="#4992cf" d="M1033.1 724.2h3l1.5-2.6-1.5-2.6h-3l-1.5 2.6 1.5 2.6Zm3.4.7h-3.8l-2-3.3 2-3.3h3.8l1.9 3.3-1.9 3.3Z"/>
        <path fill="#4992cf" d="M1035.7 719.7h-2.2l-1.1 1.9 1.1 1.9h2.2l1-1.9z"/>
        <path fill="#4992cf" d="M1145.8 722h-110.7v-.7h110.4l20-19.2h182.8l7 6.9-.5.4-6.9-6.6h-182.1l-20 19.2Z" />
        <path fill="#4992cf" d="M1357.8 709.1c0 1.7-1.3 3-3 3s-3.1-1.3-3.1-3 1.4-3.1 3.1-3.1c1.7 0 3 1.4 3 3.1Z" />-->
      </g>
      
      <path d="M 655.8 760.7 L 707.2 708.7 L 755.1 708.7 L 762.7 715.9 L 839.1 716 L 846.6 708.2 L 894.4 708.3 L 924.7 738.6 L 943.8 738.6 L 944.2 762.8 L 922.4 784.8 L 922.6 855.3 L 944.2 876.8 L 944.2 898 L 657.6 898.2 L 657.6 876.9 L 679.8 854.7 L 679.7 784.8 L 655.8 760.7 Z" style="fill: rgb(25, 25, 25); fill-opacity: 0.55;"/>
      {{CenterNav}}
      {{CenterAP}}
      {{CenterWarp}}

      {{WidgetThrottle}}

      <g transform="matrix(1.63676, 0, 0, 1.63676, 158.69531, 298.66381)">
        <text class="c-th" style="font-size: 9.8px;" x="222.642" y="303.209">{{ThrottleLabel}}: {{ThrottleValue}}</text>
      </g>
      <text class="c-th fs15" x="927.8" y="730.6">ALT: {{Altitude}}</text>
      <text class="fs22 c-th" y="38" x="0"><tspan x="477.1" y="731.7" style="font-size: 22px; word-spacing: 0px;">SPEED: {{VelocitySpeed}}</tspan></text>
      <text class="c-th" style="font-size: 11.5px;" x="584.8" y="726.1">km:h</text>
      <g transform="matrix(1.63676, 0, 0, 1.63676, 144.10788, 299.01016)">
        <text class="fs7 c-tm" x="235" y="250.3">VERT SPEED: {{VelocityUp}} m:s</text>
      </g>

      {{MainButtons}}

      <g transform="matrix(1, 0, 0, 1, -610.19897, -12.72636)" id="button_flight">
        <path class="c-co" d="M 953.8 722.4 L 994.6 722.4 L 978.8 738.1 L 953.8 738.1 L 953.8 722.4 Z" />
        <text class="c-th fs14 ftam" x="967.4" y="735.1">A: R</text>
        <path class="fil1" d="M 997.8 722.4 L 1001.2 722.4 L 985.4 738.1 L 982 738.1 L 997.8 722.4 Z"/>
        <path class="c-bg" d="M 1099.9 722.3 L 1182.6 722.4 L 1166.8 738.1 L 1084 738.1 L 1099.9 722.3 Z" style="fill-opacity: 0.9;" transform="matrix(-1, 0, 0, -1, 2171, 1460.39996)"/>
        <text class="c-tm fs14" x="1004.5" y="735.1">{{ModeLabel}}</text>
        <path class="fil1" d="M 939.4 722.4 L 951.3 722.4 L 951.3 733 L 946.2 738.1 L 939.4 738.1 L 939.4 722.4 Z" transform="matrix(-1, 0, 0, -1, 1890.70001, 1460.5)"/>
      </g>
      <g id="WIDGET_AUX">
        <path class="c-bg" d="M 670.8 851.2 L 648.7 873.3 L 648.6 895.5 L 522.6 894.2 L 523.1 811 L 526.8 807 L 659.4 807 L 670.8 816.6 L 670.8 851.2 Z" style="fill-rule: nonzero; paint-order: fill; fill-opacity: 0.88;"/>
        <text class="c-tm" x="585.7" y="842.4">{{BrakesUsed}}/{{BrakesMax}} kn</text>
        <text class="c-co" x="529.5" y="857.2">BRAKE DIST</text>
        <text class="c-tm" x="585.7" y="857.2">{{BrakingDistance}}</text>
        <text class="c-co" x="529.5" y="872">BRAKE TIME</text>
        <text class="c-tm" x="585.7" y="872">{{BrakingTime}}</text>
        <path d="M 589.7 809.2 L 587.8 811 L 556.4 811 L 558.2 809.1 Z" class="c-co" />
        <path d="M 554.5 809.1 L 552.7 810.9 L 526.7 811 L 528.6 809.1 L 554.5 809.1 Z" class="c-co" />
        <path d="M 624.9 809.2 L 623 811 L 591.6 811 L 593.4 809.1 Z" class="c-co" />
        <path d="M 658.1 809.1 L 660.4 811 L 626.8 811 L 628.6 809.1 L 658.1 809.1 Z" class="c-co" />
        <text class="c-co" x="529.5" y="842.4">BRAKE PWR</text>
        <path d="M 662.2 812.7 L 668.4 817.9 L 668.4 827.4 L 526.7 827.4 L 526.7 812.7 L 662.2 812.7 Z" class="c-hb"/>
        <text class="c-co fs14" x="529.5" y="824.7">AUX FLIGHT DATA</text>
        <text class="c-co" x="529.5" y="886.8">SHIP MASS</text>
        <text class="c-tm" x="585.7" y="886.8">{{ShipMass}} ton</text>
      </g>
      <g id="WIDGET_DOCK">
        <path class="c-bg" d="M 1107.6 763.7 L 1107.6 895.6 L 952.6 895.6 L 952.7 871.6 L 945.3 864.6 L 945.2 774.9 L 953.1 767.1 L 953.1 756.4 L 959.3 750.6 L 1091.8 750.4 L 1107.6 763.7 Z" style="fill-rule: nonzero; paint-order: fill; fill-opacity: 0.88;"/>
        <path d="M 1022.3 752.8 L 1020.4 754.6 L 989 754.6 L 990.8 752.7 Z" class="c-co" />
        <path d="M 987.1 752.7 L 985.3 754.5 L 959.3 754.6 L 961.2 752.7 L 987.1 752.7 Z" class="c-co" />
        <path d="M 1057.5 752.8 L 1055.6 754.6 L 1024.2 754.6 L 1026 752.7 Z" class="c-co" />
        <path d="M 1090.7 752.7 L 1093 754.6 L 1059.4 754.6 L 1061.2 752.7 L 1090.7 752.7 Z" class="c-co" />
        <path d="M 1096 757.2 L 1104.7 764.7 L 1104.6 771.9 L 952.9 771.9 L 956.5 768.2 L 956.5 757.2 L 1096 757.2 Z" class="c-hb"/>
        <text class="c-co fs14" x="959.3" y="769.4">TERTIARY FLIGHT DATA</text>
        ]]..HUD.widgets.primary.TertiaryFields..[[
      </g>
      <g id="WIDGET_HOVER">
        <path class="c-bg" d="M 1194 724.6 L 1317.9 724.6 L 1301.8 708.4 L 1210.7 708.4 L 1194 724.6 Z" style="fill-opacity: 0.88;"/>
        <text class="fs13 c-th fil2 ftam" x="1256.8" y="721.4">HOVER POWER :: {{HoverHeight}}m</text>
        <path d="M 1191.6 724.5 L 1152.2 724.5 L 1168.4 708.5 L 1207.8 708.4 L 1191.6 724.5 Z" style="fill: rgb(128, 107, 107);"/>
        <text class="fs13 c-th ftam" x="1179" y="721.4">{{KeyGroundDown}}</text>
        <path d="M 1320.6 724.5 L 1360 724.5 L 1343.9 708.5 L 1304.4 708.4 L 1320.6 724.5 Z" style="fill: rgb(121, 135, 117);"/>
        <text class="fs13 c-th ftam" x="1332.2" y="721.4">{{KeyGroundUp}}</text>
      </g>
      {{MainFuel}}
    </svg>
  </div>
  ]]
  end
}

--[[
      <g id="WIDGET_DOCK">
        <path d="M 1107.6 763.7 L 1107.6 895.6 L 952.6 895.6 L 952.7 871.6 L 945.3 864.6 L 945.2 774.9 L 953.1 767.1 L 953.1 756.4 L 959.3 750.6 L 1091.8 750.4 L 1107.6 763.7 Z" style="fill-rule: nonzero; paint-order: fill; fill-opacity: 0.88; fill: rgb(45, 72, 92);"/>
        <path d="M 1022.3 752.8 L 1020.4 754.6 L 989 754.6 L 990.8 752.7 Z" class="fil2" />
        <path d="M 987.1 752.7 L 985.3 754.5 L 959.3 754.6 L 961.2 752.7 L 987.1 752.7 Z" class="fil2" />
        <path d="M 1057.5 752.8 L 1055.6 754.6 L 1024.2 754.6 L 1026 752.7 Z" class="fil2" />
        <path d="M 1090.7 752.7 L 1093 754.6 L 1059.4 754.6 L 1061.2 752.7 L 1090.7 752.7 Z" class="fil2" />
        <path d="M 1096 757.2 L 1104.7 764.7 L 1104.6 771.9 L 952.9 771.9 L 956.5 768.2 L 956.5 757.2 L 1096 757.2 Z" class="fil105" style="fill: rgb(58, 89, 113);"/>
        <text class="c-th fs14 fil2" x="959.3" y="769.4">DOCKING STATUS</text>
        <path class="fil2" d="M 963.9 776.9 L 1004.7 776.9 L 988.9 792.6 L 963.9 792.6 L 963.9 776.9 Z" />
        <path class="fil1" d="M 1007.9 776.9 L 1011.3 776.9 L 995.5 792.6 L 992.1 792.6 L 1007.9 776.9 Z" />
        <path d="M 998.5 776.8 L 1104.5 776.9 L 1088.7 792.6 L 998.5 792.6 L 998.5 776.8 Z" style="fill-opacity: 0.9; fill: rgb(78, 94, 105);" transform="matrix(-1, 0, 0, -1, 2103, 1569.39996)"/>
        <text class="c-th fs14" style="fill: rgb(223, 230, 237); " x="1015.6" y="789.6">DOCKED</text>
        <path class="fil1" d="M 949.5 776.9 L 961.4 776.9 L 961.4 787.5 L 956.3 792.6 L 949.5 792.6 L 949.5 776.9 Z" transform="matrix(-1, 0, 0, -1, 1910.90002, 1569.5)"/>
        <text class="c-th fs14 ftam" x="977.6" y="789.3">AS: 1</text>
        <path class="fil2" d="M 949.6 798 L 990.4 798 L 974.6 813.7 L 949.6 813.7 L 949.6 798 Z" />
        <path d="M 993.6 798 L 997 798 L 981.2 813.7 L 977.8 813.7 L 993.6 798 Z" style="fill: rgb(169, 169, 150);"/>
        <text class="c-th fs14 ftam" x="963.8" y="810.4">AS: 2</text>
        <path class="fil1" d="M 1000 797.8 L 1034.1 797.8 L 1018.3 813.6 L 984.1 813.6 L 1000 797.8 Z" transform="matrix(-1, 0, 0, -1, 2018.19995, 1611.39996)"/>
        <text class="c-th" x="998.6" y="809.7">NONE</text>
        <path d="M 1036.8 797.8 L 1068.3 797.8 L 1052.5 813.6 L 1020.9 813.6 L 1036.8 797.8 Z" style="fill: rgb(74, 92, 103);" transform="matrix(-1, 0, 0, -1, 2089.20007, 1611.39996)"/>
        <text class="c-th" style="font-size: 11px;" x="1034.8" y="809.5">PROX</text>
        <path d="M 1070.9 797.8 L 1102.4 797.8 L 1086.6 813.6 L 1055 813.6 L 1070.9 797.8 Z" style="fill: rgb(74, 92, 103);" transform="matrix(-1, 0, 0, -1, 2157.40002, 1611.39996)"/>
        <text class="c-th" style="font-size: 11px;" x="1069" y="809.4">OWN</text>
        <path d="M 1088.8 797.8 L 1104.5 797.8 L 1088.7 813.6 L 1088.8 797.8 Z" style="fill: rgb(55, 75, 87);" transform="matrix(-1, 0, 0, -1, 2193.19995, 1611.39996)"/>
        <text class="c-th fs13 fil2" x="958.9" y="833.7">DOCKED TO</text>
        <text class="c-th" style="fill: rgb(191, 211, 228); font-size: 11px; " x="959.3" y="848.1">{{DockedTo}}</text>
        <text class="c-th fs13 fil2" x="959.3" y="870.7">CLOSEST TARGET</text>
        <text class="c-th" style="fill: rgb(191, 211, 228); font-size: 11px; " x="959.7" y="885.1">{{DockedClosest}}</text>
      </g>
]]

HUD.buttons = {
  template = "",
  mainTemplates = {},
  btnKeys = {},
  initBinds = {},
  html = "",

  compile = function(s, obj, name, start)
    s.template = ""
    for key,h in pairs(s.mainTemplates) do
      s.template = s.template .. h
    end
    s.initBinds[name] = {obj, start}
  end,

  init = function(s)
    s.tmpl = nil
    s.tmpl = Template.new(s.template)
    s.tmpl:listen(function(data)
      HUD.widgets.primary.tmpl:bind({MainButtons = data.html})
    end);
  end,

  ready = function(s)
    s.tmpl:compile(s.template)
    for name,set in pairs(s.initBinds) do
      set[1]:toggle(set[2])
    end
  end,

  createButton = function(s, name, label, key, start)
    local prnt = s
    local this = {name = name}
    prnt.btnKeys[#prnt.btnKeys+1] = name

    local yfac = 9.4 + (#prnt.btnKeys*20)
    this.template = [[<g class="btn-{{active}}" transform="translate(180,]]..yfac..[[)">
      <use class="btn-{{active}}" xlink:href="#BUTTON_SINGLE" />
      <text class="fs13 c-th ftam" x="967.4" y="734.9">]].. key ..[[</text>
      <text class="fs12 fttu c-tm" x="1005.5" y="734.4">{{label}}</text>
    </g>]]

    this.tmpl = Template.new(this.template);
    this.tmpl:listen(function(data)
      prnt.tmpl:bind({[this.name] = data.html})
      prnt.tmpl:render()
    end);

    this.toggle = function(s, o)
      this.tmpl:bind(o)
      this.tmpl:render()
    end

    this.tmpl:bind({label=label})
    prnt.mainTemplates[name] = "{{"..name.."}}"
    prnt:compile(this, name, {active=start})

    return this
  end
}
