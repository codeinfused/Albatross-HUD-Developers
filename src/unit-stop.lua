_autoconf.hideCategoryPanels()
if antigrav ~= nil then antigrav.hideWidget() end
if warpdrive ~= nil then warpdrive.hideWidget() end
if gyro ~= nil then gyro.hideWidget() end
core.hideWidget()
Nav.control.switchOffHeadlights()
system.setScreen("")
system.showScreen(false)
player.freeze(false)