Warnings = (function()
  local this = {
    disabled = false,
    template = "",
    mainTemplates = {},
    allKeys = {},
    initBinds = {},
    html = ""
  }

  function this:flush()
    local alt = Flight.altitude
    if not self.disabled and Flight.inSpace then
      self.disabled = true
      self.button1:toggle({active = 'dis'})
    elseif not Flight.inSpace then
      self.disabled = false
      self.button1:toggle({active = self.active and self.tempsw and "on" or "off"})
    end
    if Flight.speed == nil or Throttle.previous == nil or self.disabled then return end
    if (self.active and self.tempsw) or (Flight.speed < 70 and not Flight.inSpace and Throttle.previous < 3 and Flight.gravity > 1) then
      Flight.targetAngularVelocity = Flight.targetAngularVelocity + Flight.worldVertical:cross(Flight.up)
    end
  end

  function this:keyAction()
    if self.disabled then return end
    self.active = not self.active
    self.tempsw = self.active
    self.button1:toggle({active = self.active and self.tempsw and "on" or "off"})
  end

  function this:tsw()
    if Flight.pitchInput > 0 or Flight.rollInput > 0 or Flight.yawInput > 0 then
      self.tempsw = false
    else
      self.tempsw = self.active
    end
  end


  function compile(obj, name, start)
    self.template = ""
    for key,h in pairs(self.mainTemplates) do
      self.template = self.template .. h
    end
    self.initBinds[name] = {obj, start}
  end

  function this:init()
    self.tmpl = nil
    self.tmpl = Template.new(self.template)
    self.tmpl:listen(function(data)
      --HUD.widgets.primary.tmpl:bind({MainButtons = data.html})
    end);

    KeyActions:register('start', 'option9', 'IgnoreWarns', Warnings, 'keyAction')
    --KeyActions:register('tick', 'StabTick', 'StabTick', Stabilize, 'tsw')
    --unit.setTimer('StabTick', 0.25)

    this.button1 = HUD.buttons:createButton('IgnoreWarns', "Ignore Warning Messages", 'A:9', 'off')
  end

  function this:ready()
    self.tmpl:compile(self.template)
    for name,set in pairs(self.initBinds) do
      set[1]:toggle(set[2])
    end
  end

  function this:create(name, label, key, start)
    local prnt = self
    local this = {name = name}
    prnt.allKeys[#prnt.allKeys+1] = name

    local yfac = 9.4 + (#prnt.allKeys*20)
    this.template = [[<svg viewBox="0 0 254 44" class="svg-warning" transform="translate(0,]]..yfac..[[)">
      <path fill="#b85656" fill-opacity=".35" d="m13.1 9-8.8 3.7.1 20.9 8.1 3.6h228.9l8.8-3.7V12.7L241.7 9z"/>
      <path fill="#e82d2d" d="M159.66 39.73h14.91l6.53 3.95h15.55l3.43-3.43h9l-1.48-1.5h-47.2zm-65.02 0h-14.9l-6.54 3.95H57.65l-3.43-3.43h-9l1.48-1.5h47.2zm65.43-36.71 2.41-2.41h63.9l2.61 2.62h8.94l1.22 1.22h-9.75s-.66.98-.98.98h-35.75s-1.95-2.41-2.42-2.41h-30.18Zm-65.85 0L91.8.61H27.91l-2.63 2.62h-8.92l-1.22 1.22h9.75s.65.98.98.98h35.75s1.95-2.41 2.42-2.41h30.18Zm-60.8 36.24.03-1.18-21.2.08-8.85-4.04-.06-21.9 9.57-4.08 95.98.07-1.47-1.48-94.8.26L2.2 11.51l.05 23.43 9.68 4.37 21.49-.05Zm187.88 0-.04-1.18 21.2.08 8.86-4.04.05-21.9-9.56-4.08-95.98.07 1.46-1.48 94.8.26 10.43 4.52-.05 23.43-9.68 4.37-21.5-.05Z" />
      <text class="ffrd fftam" x="127.2" y="31.8" fill="#e82d2d" font-size="26" letter-spacing=".3" style="white-space:pre" word-spacing="2">{{message}}</text>
    </svg>
    <g class="btn-{{active}}" transform="translate(180,]]..yfac..[[)">
      <use class="btn-{{active}}" xlink:href="#BUTTON_SINGLE" />
      <text class="c-wh fs14 ftam" x="967.4" y="735.1">]].. key ..[[</text>
      <text class="fs14" style="fill: rgb(200, 216, 244);" x="1005.5" y="735.1">{{label}}</text>
    </g>]]

    this.tmpl = Template.new(this.template);
    this.tmpl:listen(function(data)
      prnt.tmpl:bind({[this.name] = data.html})
      prnt.tmpl:render()
    end);

    this.toggle = function(self, o)
      this.tmpl:bind(o)
      this.tmpl:render()
    end

    this.tmpl:bind({label=label})
    prnt.mainTemplates[name] = "{{"..name.."}}"
    prnt:compile(this, name, {active=start})

    return this
  end

  return this
end)()


