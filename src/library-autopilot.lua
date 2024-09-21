Autopilot = (function()

  local F = Flight

  local this = {
    stageState = 0,
    apState = 'off',
    alignState = 'off',
    alignTicks = 0,
    tempsw = false,
    alignTarget = vec3(),
    targetName = 'None',
    targetType = 'body',
    targetPID = 0,
    targetBody = {},
    targetDist = 0,
    targetBodyName = 'Unknown',
    apBuffer = 0
  }

  F.targetAngularVelocity = vec3()

  function this.init(s)
    KeyActions:register('start', 'option4', 'APAlign', Autopilot, 'stop')
    if showAutopilot then
      s.button = HUD.buttons:createButton('APAlign', "Autopilot", 'A:4', s.alignState=='off' and "dis" or "on")
    end

    SystemFlush:register(13, 'autopilot', Autopilot, 'alignFlush')

    KeyActions:register('tick', 'APUpdate', 'APUpdate', s, 'update');
    unit.setTimer('APUpdate', 0.25);
  end

  function this.stop(s)
    if s.alignState=='off' and s.apState=='off' then
      system.print('For autopilot, use ALIGN or GO in Lua chat.')
    end
    s.alignState = 'off'
    s.apState = 'off'
    s.stageState = 0
    s.targetBodyName = 'Unknown'
    s.targetName = 'None'
    s.targetDist = 0
    F.apBrake = false
    if showAutopilot then s.button:toggle({active = "dis", label = 'Autopilot'}) end
    Settings:clearAP()
  end

  function this.go(s, v)
    local lb = 'AP/ '
    local ap = s:setTarget(v)
    if ap==0 then return end
    s.alignState = 'on'
    s.apState = 'on'
    lb = lb..s.targetName

    if showAutopilot then s.button:toggle({active = "on", label = "Autopilot: "..lb}) end
    Settings:saveAP(v)
  end

  function this.align(s, v)
    local lb = 'Align/ '
    s.alignTicks = 0
    s.stageState = 0
    local done = 0
    if type(v) == 'string' then
      if v:lower() == 'forward' then
        lb = 'Align/ Forward'
        s:forward()
        done = 1
      elseif v:lower() == 'retro' then
        lb = 'Align/ Retro'
        s:retro()
        done = 1
      end
    end
    if done==0 then
      s:setTarget(v)
      s.alignState = 'on'
      s.apState = 'off'
      lb = lb..s.targetName
    end
    if showAutopilot then s.button:toggle({active = "on", label = "Autopilot: "..lb}) end
  end

  function this.forward(s)
    s:setTarget(F.velocity)
    s.alignState = 'forward'
  end

  function this.retro(s)
    s:setTarget(-F.velocity)
    s.alignState = 'retro'
  end

  function this.setTarget(s, v)
    if not F.inSpace and not needleAutopilot then
      log("Your set alignment will enable once in deep space. A:1 to disable.")
    end

    s.stageState = 0
    s.alignTicks = 0
    s.targetType = 'body'
    s.targetPID = 0
    s.targetBody = {}
    s.alignTarget = vec3()
    s.targetBodyName = 'Unknown'
    local pos = v
    local inPlanetDistLimit = 200000

    if type(v) == 'string' then
      if v:lower() == 'forward' then
        s:forward()
        return 0
      elseif v:lower() == 'retro' then
        s:retro()
        return 0
      elseif string.sub(v,1,2) ~= '::' then
        local bodyId = AISatlas.bodyNames[v:lower()]
        if not bodyId then
          log('Body name not found:' .. v)
          return 0
        end
        local body = atlas[AISatlas.sys][bodyId]
        pos = vec3(body.center)
        s.targetName = body.name[1]
        s.targetPID = body.id
        s.targetBody = body
        s.targetBodyName = body.name[1]
      else
        system.setWaypoint(v)
        pos = AISatlas:convertPOS(v)
        if not pos then return 0 end
        s.targetName = 'Custom'

        local pId = AISatlas:nearestPlanetToPos(pos, inPlanetDistLimit)
        if pId ~= 0 and not needleAutopilot then
          local body = atlas[AISatlas.sys][pId]
          pos = body.center
          s.targetName = body.name[1]
          s.targetPID = body.id
          s.targetBody = body
          s.targetBodyName = body.name[1]
        else
          local anyPId = AISatlas:anyPlanetToPos(pos)
          s.targetType = 'space'
          s.targetBodyName = atlas[AISatlas.sys][anyPId].name[1]
        end
      end
    end
    
    s.alignTarget = pos
    return 1
  end

  -- autopilot activation in atmo is setting thrust to full

  function this.alignFlush(s)
    if F.speed == nil or F.speed < 0.1 then
      --s.alignState = 'off'
      --turn the button to off also
      --return
    end
    if s.alignState=='off' and s.apState=='off' then return end

    local maxTurnSpeed = F.maxSpeed * 0.125 --0.25
    local maxAlignSpeed = F.maxSpeed * 0.125
    local minAlignAngle = 178
    local destVector = F.position - vec3(s.alignTarget)
    local angle = 0
    s.angle = 0

    local distToTarget = abs(vec3(s.alignTarget):dist(F.position))
    s.targetDist = distToTarget

    if not F.inSpace and not needleAutopilot then
      --F.targetAngularVelocity = s.alignTarget:cross(-F.forward)--:project_on(F.worldVertical)
    
    elseif s.alignState=='pro' then
      angle = math.deg( F.forward:angle_between(s.alignTarget:normalize()) )
      local targetAngular = F.velocity:rotate(math.pi, s.alignTarget)
      F.targetAngularVelocity = F.targetAngularVelocity + (targetAngular:normalize()/2):cross(-F.forward)
      if angle < 0.09 then s.alignTicks = s.alignTicks + 1 end
      if s.alignTicks > 200 then s.alignState='off' end

    elseif s.alignState=='retro' then
      angle = math.deg( F.forward:angle_between(s.alignTarget:normalize()) )
      local targetAngular = F.velocity:rotate(math.pi, s.alignTarget)
      F.targetAngularVelocity = F.targetAngularVelocity + (targetAngular:normalize()/2):cross(F.forward)
      if angle < 0.09 then s.alignTicks = s.alignTicks + 1 end
      if s.alignTicks > 200 then s.alignState='off' end

    else
      --local targetAngular = F.velocity:mirror_on(destVector);
      angle = math.deg( F.velocity:angle_between(destVector) )
      if not angle then angle = 0 end
      s.angle = angle

      if s.alignState=='on' then
        if (angle==nil or angle < 120 or (F.speed*3.6 > maxTurnSpeed and angle < minAlignAngle)) and s.stageState < 2 then
          if not Brakes.locked then Brakes:keyAction('lock', 1) end
        else
          if Brakes.locked and Brakes.ap=='on' then Brakes:keyAction('stop', 1) end
        end

        if (angle==nil or angle < 120) then
          F.targetAngularVelocity = (destVector:normalize()/2):cross(F.forward)
        else
          local normVel = vec3(F.velocity):normalize()
          local normDest = vec3(destVector):normalize()
          local uppedVelocity = normDest:rotate(math.pi, normVel)
          local targetAngular = uppedVelocity:normalize():rotate(math.pi, normDest)

          F.targetAngularVelocity = (targetAngular:normalize()):cross(F.forward)
          if angle >= 179.8 then s.alignTicks = s.alignTicks + 1 end
          --if s.alignTicks > 1000 and s.apState=='off' then s.alignState='off' end
          if s.alignTicks > 1000 and not needleAutopilot and s.apState ~= 'on' then s.alignState='off' end
        end
      end

      if s.apState=='on' then
        if s.stageState==0 then
          --log( round(unit.getThrottle()) )
          s.stageState=1
          if F.mode~=0 then unit.cancelCurrentControlMasterMode() end
          F.forceThrottle = 0.5
          --NACM:resetCommand(axisCommandId.longitudinal)
          --NACM:setThrottleCommand(axisCommandId.longitudinal, 0.2)
          --unit.setAxisCommandValue(axisCommandId.longitudinal, 0.2)
          --Nav.axisCommandManager:updateCommandFromActionStart(axisCommandId.longitudinal, 5.0)
          --NACM:updateCommandFromActionLoop(axisCommandId.longitudinal, 1.0)
          --log( round(unit.getThrottle()) )
        elseif s.stageState==1 then
          if s.angle==nil or (s.angle>165 and s.angle<179.74) then
            if needleAutopilot then
              F.forceThrottle = 1
            else
              F.forceThrottle = 0.5
            end
            --NACM:setThrottleCommand(axisCommandId.longitudinal, 0.5)
            --unit.setAxisCommandValue(axisCommandId.longitudinal, 0.5)
            --Nav.axisCommandManager:updateCommandFromActionStart(axisCommandId.longitudinal, 5.0)
            --NACM:updateCommandFromActionLoop(axisCommandId.longitudinal, 1.0)
          elseif s.angle>=179.74 and s.alignTicks > 700 then
            F.forceThrottle = 1
            --NACM:setThrottleCommand(axisCommandId.longitudinal, 1)
            --unit.setAxisCommandValue(axisCommandId.longitudinal, 1)
            --Nav.axisCommandManager:updateCommandFromActionStart(axisCommandId.longitudinal, 5.0)
            --NACM:updateCommandFromActionLoop(axisCommandId.longitudinal, 1.0)
            s.stageState = 2
          end
        elseif s.stageState==2 then
          local buffer = s.targetType=='body' and (apAtmoPark+s.targetBody.radius+s.targetBody.atmosphereThickness) or apSpacePark
          if distToTarget <= buffer + F.brakeDistance then
            s.stageState = 3
          end
        elseif s.stageState==3 then
          s.stageState=4
          Sound:play('APapproach')
          --unit.setAxisCommandValue(0, 0)
          --NACM:resetCommand(0)
          --NACM:updateCommandFromActionLoop(axisCommandId.longitudinal, 0)
          F.forceThrottle = 0
        elseif s.stageState==4 then
          local buffer = s.targetType=='body' and (apAtmoPark+s.targetBody.radius+s.targetBody.atmosphereThickness) or apSpacePark
          if distToTarget <= buffer + F.brakeDistance then
            --Brakes:keyAction('lock')
            F.apBrake = true
          else
            --Brakes:keyAction('stop')
            F.apBrake = false
          end
          if distToTarget <= buffer then 
            s.stageState=5
            F.apBrake = false
            Brakes:keyAction('lock')
          end
        end
      end

    end -- end AP type switch
  end

  function this.update(s)
    local html = ""
    local doRender = true

    --if ((not F.inSpace and s.alignState=='on' and not needleAutopilot) or (warpdrive~=nil and (s.apState~='on' and s.alignState~='on'))) then
    if (warpdrive~=nil and (s.apState~='on' and s.alignState~='on')) then doRender = false end
    if needleAutopilot then
      if s.alignState~='on' and not F.inSpace then doRender = false end
    else
      if not F.inSpace then doRender = false end
    end
    
    if not doRender then
      --[=[
        [[<g transform="translate(0,-2)"><path class="c-bg" d="M 658.2 878.6 L 943.2 878.6 L 943.2 895.5 L 658.2 895.5 L 658.2 878.6 Z"/>
        <text class="c-co fttu fs12" x="661.7" y="891.8">WARP: ]]..txtStatus..[[</text>
        <text class="c-co fttu fs12" x="940" y="891.8" text-anchor="end">]]..txtCells..[[</text>
      ]]
      ]=]
    else
      local spd = F.maxSpeed
      local secs = timeToDist(s.targetDist, spd)
      local travelTime = formatTime(secs)
      local secs2 = timeToDist(s.targetDist, F.speed*3.6)
      local travelTime2 = formatTime(secs2)
      local angleDiff = format("%.1f", 180 - (s.angle or 1))

      local status = 'OFF'
      if s.alignState=='on' and s.apState=='off' then
        status = 'ALIGN ONLY'
      end
      if s.apState=='on' then
        if s.stageState==1 then
          status = 'ALIGNING '..angleDiff
        elseif s.stageState==2 then
          status = 'ACCELERATING'
          if (F.speed*3.6)+120 >= F.maxSpeed then
            status = 'CRUISING'
          end
        elseif s.stageState==3 or s.stageState==4 then
          status = 'ON APPROACH'
        elseif s.stageState==5 then
          status = 'ARRIVED'
        end
      end

      local opacity = 1
      if status=='OFF' then opacity = 0.4 end

      html=html..[[
        <g style="opacity:]]..opacity..[[;">
          <path class="c-bg" d="M 670.8 701.5 L 869.2 701.5 L 880 712.1 L 861.5 730.2 L 815.1 730.2 L 808.2 723.1 L 729.1 723.1 L 722 730.2 L 675.9 730.2 L 658 712.1 L 670.8 701.5 Z" style="opacity:0.8;" transform="matrix(-1, 0, 0, -1, 1569.5, 1439.59998)"/>
          <text class="ffrd ftam fs20 c-co" x="801.2" y="734.0">SPACE AUTOPILOT</text>
          <text class="ffrd fs15 c-wh fttu" x="689" y="764.4">TO: ]]..s.targetName..[[</text>
          <g transform="matrix(1, 0, 0, 1, -15, -13)">
            <path class="c-bg op06" d="M 703.2 789.2 L 790.6 789.2 L 770.5 809.2 L 703.2 809.2 L 703.2 789.2 Z" />
            <path class="c-bg" d="M 818.1 788.9 L 965.5 788.4 L 945.4 808.4 L 818.2 809 L 818.1 788.9 Z" transform="matrix(-1, 0, 0, -1, 1738.60004, 1597.40002)"/>
            <text class="ffrd fs15 c-tm fttu" x="794.5" y="804.4">]]..status..[[</text>
            <text class="ffrd fs15 c-th" style=" text-anchor: middle;" x="737" y="804.4">AP STATUS</text>
          </g>
          <g>
            <text class="ffrd fs12 c-ow" x="689" y="816.3">DISTANCE TO DESTINATION:</text>
            <text class="ffrd fs12 c-ow" x="804" y="816.3">]]..formatDist(s.targetDist)..[[</text>
            <text class="ffrd fs12 c-wh" x="689" y="832.3">ESTIMATED TRAVEL TIME:</text>
            <text class="ffrd fs12 c-wh" x="804" y="832.3">]]..travelTime..[[</text>
            <text class="ffrd fs12 c-ow" x="689" y="848.3">TRAVEL TIME BY SPEED:</text>
            <text class="ffrd fs12 c-ow" x="804" y="848.3">]]..travelTime2..[[</text>
            <text class="ffrd fs12 c-ow" x="689" y="864.3">CLOSEST BODY TO TARGET:</text>
            <text class="ffrd fs12 c-ow" x="804" y="864.3">]]..s.targetBodyName..[[</text>
          </g>
        </g>
      ]]
    end

    HUD.widgets.primary.tmpl:bind({
      CenterAP=html
    })
  end

  return this
end)()