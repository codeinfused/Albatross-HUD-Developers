
HUD.widgets.shields.tmpl:bind({
  ShipName = construct.getName()
})

s.stressHP = (1 - core.getCoreStressRatio())*100

HUD.widgets.shields.tmpl:bind({
  HPStressPerc = format('%.0f',s.stressHP)
})