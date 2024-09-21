AGG = (function()
  local F = Flight
  local this = {
    active = true
  }

  function this.init(s)
    s.active = antigrav.isActive()==true
    if not s.active then antigrav.activate() end
    s.baseTarget = floor(antigrav.getBaseAltitude())
    s.altTarget = antigrav.getTargetAltitude()

    KeyActions:register('start', 'antigravity', 'keyAntigrav', s, 'keyAntigrav');
    KeyActions:register('tick', 'AGGupdate', 'AGGupdate', s, 'update');

    KeyActions:register('start', 'groundaltitudeup', 'keyLiftAGGUpStart', s, 'keyAntigravUp');
    KeyActions:register('loop', 'groundaltitudeup', 'keyLiftAGGUpLoop', s, 'keyAntigravUp');

    KeyActions:register('start', 'groundaltitudedown', 'keyLiftAGGDownStart', s, 'keyAntigravDown');
    KeyActions:register('loop', 'groundaltitudedown', 'keyLiftAGGDownLoop', s, 'keyAntigravDown');
    
    unit.setTimer('AGGupdate', 0.15)
  end

  function this.update(s)
    s.baseTarget = antigrav.getBaseAltitude()
    s.altTarget = antigrav.getTargetAltitude()
    s.fieldStr = antigrav.getFieldPower()
    s.pulsors = antigrav.getPulsorCount()
    s.active = antigrav.isActive()==true
    local html = s:render()
    HUD.widgets.primary.tmpl:bind({
      AGGView = html
    })
  end

  function this.set(s, v)
    s.altTarget = v
    antigrav.setTargetAltitude(v)
  end

  function this.keyAntigravUp(s)
    s.altTarget=s.altTarget + (F.keyLShift==1 and 50 or 5)
    s:set(s.altTarget)
  end

  function this.keyAntigravDown(s)
    s.altTarget=s.altTarget - (F.keyLShift==1 and 50 or 5)
    s:set(s.altTarget)
  end

  function this.keyAntigrav(s)
    antigrav.toggle()
  end

  function this.render(s)
    local target = format("%.0f",s.altTarget)
    local base = format("%.0f",s.baseTarget)
    local color = s.active and 'on' or 'lock'
    local state = s.active and 'ON' or 'OFF'
    
    local html = [[
      <g transform="translate(2,0)">
        <path d="M 250 778.1 L 250 730.6 L 312.5 730.4 L 312.5 772.6 L 307.3 777.9 L 250 778.1 Z M 129 728 L 129 794.6 L 135.6 799.4 L 149.9 799.4 L 152 798.1 L 245.2 798.1 L 247.3 799.4 L 312.1 799.4 L 315.3 796.5 L 315.2 728 L 129 728 Z M 131.7 730.6 L 247.1 730.6 L 247.2 786.1 L 241 792.4 L 131.8 792.4 L 131.7 730.6 Z" class="c-co" style=""/>
        <g transform="matrix(1, 0, 0, 1, -820.5, -67.22807)">
          <path class="c-co" d="M 963.9 776.9 L 1004.7 776.9 L 988.9 792.6 L 963.9 792.6 L 963.9 776.9 Z"/>
          <path class="btn-]]..color..[[" d="M 1007.9 776.9 L 1011.3 776.9 L 995.5 792.6 L 992.1 792.6 L 1007.9 776.9 Z"/>
          <path class="c-bg" d="M 967.3 776.8 L 1104.5 776.9 L 1088.7 792.6 L 967.3 792.6 L 967.3 776.8 Z" transform="matrix(-1, 0, 0, -1, 2103, 1569.39996)"/>
          <text class="ffrd fs14 c-tm" style=" white-space: pre; font-size: 14px;" x="1015.6" y="789.6">ANTIGRAV ]]..state..[[</text>
          <path class="btn-]]..color..[[" d="M 949.5 776.9 L 961.4 776.9 L 961.4 787.5 L 956.3 792.6 L 949.5 792.6 L 949.5 776.9 Z" transform="matrix(-1, 0, 0, -1, 1910.90002, 1569.5)"/>
          <text class="ffrd fs14 c-th" style="text-anchor: middle; white-space: pre; font-size: 14px;" x="977.6" y="789.3">A:G</text>
        </g>
        <polygon class="c-bg" points="236.9 737.4 236.9 794.9 126.5 794.9 126.5 742.7 131.7 737.4" transform="matrix(-1, 0, 0, -1, 371.09999, 1527.70001)"/>
        <path d="M 290.4 794.1 L 297.8 789.4 L 305.1 794.1 L 305.1 787.4 L 297.8 782.7 L 290.4 787.4 L 290.4 794.1 Z M 273.9 794.1 L 281.2 789.4 L 288.6 794.1 L 288.6 787.4 L 281.2 782.7 L 273.9 787.4 L 273.9 794.1 Z M 257.3 794.1 L 264.6 789.4 L 271.9 794.1 L 271.9 787.4 L 264.6 782.7 L 257.3 787.4 L 257.3 794.1 Z" style="fill: rgb(255, 255, 255); fill-opacity: 0.23;">
        </path>
        <g transform="matrix(1, 0, 0, 1, -5.45956, 0.70261)">
          <rect x="285.4" y="737.5" width="29.3" height="11.3" class="c-bg" />
          <path class="c-co" d="M 258.6 735.3 L 285.4 735.3 L 285.4 745.9 L 280.3 751 L 258.6 751 L 258.6 735.3 Z" transform="matrix(-1, 0, 0, -1, 544, 1486.29999)"/>
          <text class="c-bg ffrd fs14" style=" font-size: 12px; text-anchor: middle;" x="272.3" y="747.3">A:SPC</text>
          <text class="c-co ffrd fs14" style=" font-size: 12px;" x="287.4" y="747.3">UP</text>
        </g>
        <g transform="matrix(1, 0, 0, 1, -5.46111, 20.72485)">
          <rect x="285.4" y="737.5" width="29.3" height="11.3" class="c-bg" />
          <path class="c-co" d="M 258.6 735.3 L 285.4 735.3 L 285.4 745.9 L 280.3 751 L 258.6 751 L 258.6 735.3 Z" transform="matrix(-1, 0, 0, -1, 544, 1486.29999)"/>
          <text class="c-bg ffrd fs14" style="font-size: 12px; text-anchor: middle;" x="272.3" y="747.3">A:C</text>
          <text class="c-co ffrd fs14" style="font-size: 12px;" x="287.4" y="747.3">DOWN</text>
        </g>
        <text class="c-co ffrd " style="white-space: pre; font-size: 12px;" x="139.3" y="747.1">SINGULARITY</text>
        <text class="c-tm ffrd  " style=" white-space: pre; font-size: 12px; text-anchor: end;" x="238.5" y="747.1">]]..base..[[m</text>
        <text class="c-co ffrd " style="white-space: pre; font-size: 12px;" x="139.6" y="759.2">TARGET</text>
        <text class="c-tm ffrd  " style=" white-space: pre; font-size: 12px; text-anchor: end;" x="238.8" y="759.2">]]..target..[[m</text>
        <text class="c-co ffrd " style="white-space: pre; font-size: 12px;" x="139.5" y="771">PULSORS</text>
        <text class="c-tm ffrd  " style=" white-space: pre; font-size: 12px; text-anchor: end;" x="238.7" y="771">]]..s.pulsors..[[</text>
        <text class="c-co ffrd " style="white-space: pre; font-size: 12px;" x="139.5" y="783">FIELD PWR</text>
        <text class="c-tm ffrd  " style=" white-space: pre; font-size: 12px; text-anchor: end;" x="238.7" y="783">]]..format("%.3f",s.fieldStr)..[[</text>
    </g>
    ]]
    return html
  end

  return this
end)()