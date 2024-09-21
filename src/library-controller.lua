Controller = (function()
  local this = {};

  this.new = function(item)
    local out = item or {};
    out.active = (item.active == 'on') and 'on' or 'off'
    out.constructor = 'Controller';
    out.condition = item.condition or function(self)
      return (self.active == 'on');
    end;
  
    setmetatable(out, {__index=this});
    return out;
  end;

  function this:toggle(force)
    if(force == self.active) then return false end;
    if(self.active == 'on' or force == 'off') then
      self.active = 'off';
    elseif(self.active == 'off' or force == 'on') then
      self.active = 'on';
    end
  end

  return this;
end)();
