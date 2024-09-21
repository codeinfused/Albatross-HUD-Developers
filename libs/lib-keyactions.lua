--[[
  LIBRARY: KEY ACTIONS
  ------------------------------------
  This library is used to register events and key events. The events must have a generic call happen for their DU event type. For example, in an autoconfig format:

  unit:
      onTimer(timerId):
          lua: |
              KeyActions:exec('tick', timerId)
  system:
      onUpdate:
          lua: |
              Nav:update()
              KeyActions:exec('system', 'update')
      onActionStart(action):
          lua: |
              KeyActions:exec('start', action)

  This setup allows you bind multiple handlers to the same event type (such as Alt+1) and they all fire.
  However, this library is assuming each handler belongs to a parent object (widget), and stores references to them internally when bound.

  EXAMPLE OF BINDING AN EVENT
  -------------------------------------
  Keyactions:register( EVENT_DU_NAME, EVENT_TRIGGER, CUSTOM_NAME, PARENT_OBJECT, FUNCTION )

  KeyActions:register('start', 'yawright', 'keyyawright', Flight, Flight.keyYawRightStart);
  KeyActions:register('start', 'gear', 'gear', Gear, Gear.keyPress);

  -- And also for unit tick
  KeyActions:register('tick', 'AtlasUpdate', 'AtlasUpdate', AISAtlas, AISAtlas.update);
  unit.setTimer('AtlasUpdate', 0.3);
]]

KeyActions = (function()
  local this = {};

  this.store = {}
  this.events = {}

  function this:register(type, action, name, obj, fn)
    local event = {}
    event.type = type;
    event.action = action
    event.parent = obj;
    event.exec = fn;
    self.store[name] = event;
    self:orderize();
  end;

  function this:unregister(name)
    self.store[name] = nil;
    self:orderize();
  end;

  function this.orderize(s)
    while #s.events ~= 0 do rawset(s.events, #s.events, nil) end
    s.events = {}
    for k,v in pairs(s.store) do
      if( not s.events[v.type] ) then s.events[v.type] = {} end;
      if( not s.events[v.type][v.action] ) then s.events[v.type][v.action] = {} end;
      local ct = #s.events[v.type][v.action]
      s.events[v.type][v.action][ct+1] = v;
    end
  end

  function this.exec(s, type, action)
    if( not s.events[type] or not s.events[type][action] ) then return end 
    for i,event in ipairs(s.events[type][action]) do
      --event.parent[event.exec](event.parent);
      event.exec(event.parent);
    end;
  end;

  return this;
end)();
