Executor = (function()
  local this = {};

  this.new = function()
    local out = {
      store = {},
      events = {}
    };
    setmetatable(out, {__index=this});
    return out;
  end;

  function this:register(index, name, obj, fn)
    local event = {}
    event.index = index;
    event.parent = obj;
    event.exec = fn;
    self.store[name] = event;
    self:orderize();
  end;

  function this:unregister(name)
    self.store[name] = nil;
    self:orderize();
  end;

  function this:orderize()
    while #self.events ~= 0 do rawset(self.events, #self.events, nil) end
    for k,v in pairs(self.store) do
      self.events[#self.events+1] = v;
    end
    sort(self.events, function(a,b) return a.index < b.index end);
  end

  function this:exec()
    for i,event in ipairs(self.events) do
      event.parent[event.exec](event.parent);
    end;
  end;

  return this;
end)();
