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
      event.parent[event.exec](event.parent);
    end;
  end;

  return this;
end)();
