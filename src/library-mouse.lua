Mouse = Controller.new({
  init = function(self)
    system.getScreenWidth()
    system.getScreenHeight()
    system.getFov()
  end,
  update = function(self)
    system.getMouseWheel()
    system.getMousePosX()
    system.getMousePosY()
    
  end
});