Throttle = (function()
  local this = {
    previous = 0
  }

  this.template = [[
    <g id="WIDGET_THROTTLE">
      <polygon class="{{fwd1}}" points="601 771.6 625.4 771.6 631.5 765.5 607.1 765.5"/>
      <polygon class="{{fwd2}}" points="608.6 764 632.9 764 639 758 614.6 758"/>
      <polygon class="{{fwd3}}" points="616.1 756.7 640.5 756.7 646.5 750.4 622.1 750.4"/>
      <polygon class="{{fwd4}}" points="623.4 749.1 647.8 749.1 654.1 742.9 629.7 742.9"/>
      <polygon class="{{fwd5}}" points="631 741.6 655.4 741.6 661.4 735.6 637.2 735.6" />
      <polygon class="{{fwd6}}" points="638.5 734.1 662.9 734.1 669 728 644.6 728"/>
      <polygon class="{{fwd7}}" points="646 726.6 670.4 726.6 676.5 720.5 652.1 720.5"/>
      <polygon class="{{fwd8}}" points="653.6 719.2 678 719.2 684 713 659.6 713"/>
      <polygon class="{{fwd9}}" points="660.9 711.7 685.3 711.7 691.5 705.4 667.1 705.4"/>
      <polygon class="{{fwd10}}" points="668.5 704.1 692.8 704.1 699.1 698.1 674.7 698.1"/>
    </g>
    <g>
      <polygon class="{{fwd-10}}" points="587.3 771.6 596.6 771.6 602.7 765.5 593.3 765.5"/>
      <polygon class="{{fwd-9}}" points="594.8 764 604.1 764 610.2 758 600.9 758"/>
      <polygon class="{{fwd-8}}" points="602.2 756.7 611.7 756.7 617.7 750.4 608.4 750.4"/>
      <polygon class="{{fwd-7}}" points="609.7 749.1 619.2 749.1 625.2 742.9 615.8 742.9"/>
      <polygon class="{{fwd-6}}" points="617.2 741.6 626.6 741.6 632.8 735.6 623.3 735.6"/>
      <polygon class="{{fwd-5}}" points="624.8 734.1 634.1 734.1 640.1 728 630.8 728"/>
      <polygon class="{{fwd-4}}" points="632.3 726.6 641.6 726.6 647.7 720.5 638.3 720.5"/>
      <polygon class="{{fwd-3}}" points="639.7 719.2 649.1 719.2 655.2 713 645.9 713"/>
      <polygon class="{{fwd-2}}" points="647.2 711.7 656.7 711.7 662.7 705.4 653.2 705.4"/>
      <polygon class="{{fwd-1}}" points="654.7 704.1 664 704.1 670.3 698.1 660.8 698.1"/>
    </g>
  ]]

  this.init = function(s)
    s.percent = 0
    s.tmpl = Template.new(s.template)
    s.tmpl:listen(function(data)
      s.html = data.html
    end);

    local fils = {}
    for i=-10,10 do
      fils['fwd'..i] = 'op03'
    end
    s.tmpl:bind(fils)
  end

  this.update = function(s)
    --[[
      fil1 = forward: green
      op03 = low opacity blue
      st12 = reverse: orange
    ]]

    local real = round(unit.getThrottle())
    local fils = {}
    local val = ''
    local perc, mod, tmpspd = 0, 0, 0
    
    -- these are units of increments, 1 full tick = 1 unit
    if Flight.mode==0 then
      perc = floor(real / 10) -- 3.5
      mod = (real % 10) * 10 -- .5*10
    elseif Flight.mode==1 then
      local inc = NACM:getTargetSpeedCurrentStep(axisCommandId.longitudinal)
      local binc = inc*10
      tmpspd = floor(real / 100) -- 350
      perc = floor(tmpspd / binc) -- 3
      mod = ((tmpspd % binc) / binc) * 100
    end

    for i=-10,10 do
      val = 'op03 c-co'
      if perc > 0 and i > 0 and i <= perc then val = 'fil1' end
      if perc < 0 and i < 0 and i >= perc then val = 'fil4' end
      if perc >= 0 and perc+1 == i and mod > 0 then val = 'lastTick' end
      fils['fwd'..i] = val
    end

    HUD.widgets.primary.tmpl:bind({
      RealThrottle = real,
      LastTickP = 1-(mod/100),
      LastTickP1 = 1-((mod+1)/100)
    })

    s.previous = perc
    s.real = real
    s.tmpl:bind(fils)
    s.tmpl:render()
  end

  return this;

end)()
