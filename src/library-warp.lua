--[[
    .initiate()
    .getStatus() 1=noDrive, 2=broken, 3=warping, 4=parentIsWarping, 5=notAnchored?, 6=cooldownWarp, 7=cooldownPVP, 8=movingChild, 9=noContainer, 10=planetTooClose, 11=noDestination, 12=destTooClose, 13=destTooFar, 14=moreCells, 15=READY
    .getDistance()
    .getDestination() > constructId
    .getDestinationName()
    .getContainerId()
    .getAvailableWarpCells()
    .getRequiredWarpCells() 


    warp power = Flight.maxSpeed * 84

    time to destination  timeToDist(dist, Flight.speed*3.6)
    estimated time to dest also
<g>
  <path d="M 658.2 878.6 L 943.2 878.6 L 943.2 895.5 L 658.2 895.5 L 658.2 878.6 Z" style="fill: rgb(216, 216, 216);"/>
  <text class="st4 ffrd  " style="fill: rgb(191, 211, 228); white-space: pre; font-size: 12px;" x="661.7" y="891.8">Destination Too Close</text>
</g>
]]

Warp = (function()
  local this = {
    hasBox = true,
    statusMap = {
      'No Warp Drive', --1
      'Warp Drive Broken', --2
      'In Warp', --3
      'In Warp', --4
      'Not Piloting', --5
      'Warp Cooldown', --6
      'In PVP', --7
      'Moving', --8
      'No Container Link', --9
      'Gravity Too Close', --10
      'No Destination', --11
      'Destination Too Close', --12
      'Destination Too Far', --13
      'Need Warp Cells', --14
      'Ready' --15
    },
    stateMap = {
      'Drive Idle', --1
      'Measuring', --2
      'Aligning Ship', --3
      'Drive Spooling', --4
      'En Route', --5
      'En Route', --6
      'Making Approach', --7
      'Drive Braking', --8
      'Trip Complete', --9
    }
  }

  function this.init(s)
    s.wd = warpdrive

    KeyActions:register('tick', 'WarpUpdate', 'WarpUpdate', s, 'update');
    unit.setTimer('WarpUpdate', 0.25);
    KeyActions:register('tick', 'WarpSlowUpdate', 'WarpSlowUpdate', s, 'slowUpdate');
    unit.setTimer('WarpSlowUpdate', 1);
  end

  function this.slowUpdate(s)
    local maxSpeed = Flight.maxSpeed * 84
    local dist = s.wd.getDistance()
    local t = timeToDist(dist, maxSpeed)+6
    local txt = formatTime(t)
  end

  function this.update(s)
    local w = {
      cstat = construct.getWarpState(), -- 1=idle, 2=engage, 3=align, 4=spool, 5=accel, 6=cruise, 7=decelerate, 8=stopping, 9=disengage
      status = s.wd.getStatus(),
      name = s.wd.getDestinationName(),
      cellsInv = s.wd.getAvailableWarpCells(),
      cellsReq = s.wd.getRequiredWarpCells(),
      dist = s.wd.getDistance()
    }

    local rdyColor = 'lock'

    if w.status==15 then
      rdyColor = 'temp'
    end

    if w.status==3 or w.status==4 then
      rdyColor = 'on'
    end

    if w.cstat==2 and Throttle.real > 0 then
      Flight:keyStopEngines()
    end

    if w.cstat == 8 then
      Brakes.locked = true
      Brakes:keyAction('loop')
    end

    local maxSpeed = 2520000 --Flight.maxSpeed * 84
    local t = timeToDist(w.dist, maxSpeed)+6
    local timeTxt = formatTime(t)

    local txtCells = 'NO LINK'
    local destName = w.name=='' and 'No Destination' or w.name
    if w.status==9 then
      s.hasBox=false
    else
      s.hasBox=true
      txtCells = "CELLS: "..w.cellsInv.."  ["..w.cellsReq..": "..destName.."]"
    end

    local txtStatus = s.statusMap[w.status]
    local txtState = s.stateMap[w.cstat]
    local html = ''

    if w.status==6 or w.status==7 then
      local wd = warpdrive.getWidgetData()
      local wdo = json.decode(wd)
      --local cdText = wd:match([["statusText":"([%.]*)"]])
      txtStatus = wdo.statusText
      -- txtStatus = txtStatus..": "..CooldownRemaining
    end
    
    if not Flight.inSpace or (Autopilot.alignState~='off' or Autopilot.apState~='off') then
      
      html=html..[[<g transform="translate(0,2)"><path class="c-bg" d="M 658.2 878.6 L 943.2 878.6 L 943.2 895.5 L 658.2 895.5 L 658.2 878.6 Z"/>
        <text class="c-co fttu fs12" x="661.7" y="891.8">WARP: ]]..txtStatus..[[</text>
        <text class="c-co fttu fs12" x="940" y="891.8" text-anchor="end">]]..txtCells..[[</text>
      ]]
    else
      html=html..[[
        <g>
          <path class="c-bg" d="M 670.8 701.5 L 869.2 701.5 L 880 712.1 L 861.5 730.2 L 815.1 730.2 L 808.2 723.1 L 729.1 723.1 L 722 730.2 L 675.9 730.2 L 658 712.1 L 670.8 701.5 Z" style="opacity:0.8;" transform="matrix(-1, 0, 0, -1, 1569.5, 1439.59998)"/>
          <text class="ffrd ftam fs20 c-co" x="801.2" y="734.0">WARP DRIVE SYSTEM</text>
          
          <text class="ffrd fs15 c-wh fttu" x="680.6" y="764.4">TO: ]]..destName..[[</text>
          <text class="ffrd fs15 c-wh" style="text-anchor: end;" x="920.1" y="764.4">COST: ]]..w.cellsReq..[[</text>
          <g transform="matrix(1.27269, 0, 0, 1.27269, -525.2196, -212.85268)">
            <path class="c-co" d="M 963.1 776.9 L 998.9 776.9 L 983.1 792.6 L 963.1 792.6 L 963.1 776.9 Z"/>
            <path class="btn-]]..rdyColor..[[" d="M 1000.7 776.9 L 1004.1 776.9 L 988.3 792.6 L 984.9 792.6 L 1000.7 776.9 Z"/>
            <path class="c-bg" d="M 984.9 776.7 L 1128.2 776.3 L 1112.4 792 L 978 792.5 L 984.9 786.2 L 984.9 776.7 Z" transform="matrix(-1, 0, 0, -1, 2118.69995, 1568.79999)"/>
            <text class="ffrd fs14 c-th fttu" x="1007.4" y="789.3">]]..txtStatus..[[</text>
            <path class="btn-]]..rdyColor..[[" d="M 949.5 776.9 L 961.7 776.9 L 961.7 785.8 L 968.2 792.6 L 949.5 792.6 L 949.5 776.9 Z" transform="matrix(-1, 0, 0, -1, 1910.90002, 1569.5)"/>
            <text class="ffrd fs14 c-th ftam" x="974.1" y="789.3">A:J</text>
          </g>
          <g transform="matrix(1, 0, 0, 1, -2.73686, 9.579)">
            <path class="c-bg op06" d="M 703.2 789.2 L 790.6 789.2 L 770.5 809.2 L 703.2 809.2 L 703.2 789.2 Z" />
            <path class="c-bg" d="M 818.1 788.9 L 965.5 788.4 L 945.4 808.4 L 818.2 809 L 818.1 788.9 Z" transform="matrix(-1, 0, 0, -1, 1738.60004, 1597.40002)"/>
            <text class="ffrd fs15 c-tm fttu" x="794.5" y="804.4">]]..txtState..[[</text>
            <text class="ffrd fs15 c-th" style=" text-anchor: middle;" x="737" y="804.4">DRIVE STATE</text>
          </g>
          <text class="ffrd fs11 c-ow" x="700" y="839.3">ESTIMATED TRAVEL TIME / ]]..timeTxt..[[</text>
          <text class="ffrd fs12 c-ow" x="700" y="854.3">WARP CELLS REMAINING: ]]..w.cellsInv..[[</text>
          <text class="ffrd fs12 c-ow" x="700" y="869.3">DISTANCE TO DESTINATION: ]]..formatDist(w.dist)..[[</text>
        </g>
      ]]
    end

    html=html..'</g>'

    HUD.widgets.primary.tmpl:bind({
      CenterWarp=html
    })
  end

  return this
end)()
