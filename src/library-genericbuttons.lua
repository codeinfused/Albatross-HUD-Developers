local atlas = atlas

MyLoc = (function()
  local this = {
    state = true,
    sys = 0,
    bodyIDs = {}
  }

  function this:init()
    KeyActions:register('start', 'option9', 'MyLoc', MyLoc, 'keyAction1');
    --self.button1 = HUD.buttons:createButton('MyLoc', "Location Log", 'A:9', 'off');

  end

  function this:keyAction1()
    if Flight.keyLShift==1 then return end
    if Flight.position ~= nil then
      log( json.encode(Flight.position) )
    end
  end

  return this
end)()
