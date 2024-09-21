Template = (function()
  local this = {}

  this.new = function(html)
    html = html or ""
    local out = {
      parsed = {},
      data = {},
      index = {},
      fns = {},
      pos = 1,
      eos = 0,
      vals = {},
      needs = 1,
      event = function() end
    }
    setmetatable(out, {__index=this})
    out:compile(html)
    return out
  end

  this.minify = function(html)
    return html:
      gsub("%s%s+", ""):
      gsub("[\t\r\n]+", "")
  end

  function this.parseNext(s)
    local i,e = str_find(s.tmpl, "{{[%w_\\-]+}}", s.pos)
    if(i~=nil) then
      s.parsed[#s.parsed+1] = str_sub(s.tmpl, s.pos, i-1)
      s.parsed[#s.parsed+1] = ""
      s.index[str_sub(s.tmpl, i, e):gsub("[{}]", "")] = #s.parsed
      s.pos = e+1
    else
      s.parsed[#s.parsed+1] = str_sub(s.tmpl, s.pos, -1)
      s.eos = 1
    end
  end

  function this.compile(s, html)
    s.tmpl = s.minify(html)
    s.parsed = {}
    s.index = {}
    s.fns = {}
    s.eos = 0
    while s.eos==0 do
      s:parseNext()
    end
    return s
  end

  function this.bind(s, data)
    s.data = data
    for k,v in pairs(data) do
      if(s.index[k]~=nil and type(v)~='function') then
        s.parsed[ s.index[k] ] = v
      elseif type(v)=='function' then
        s.fns[k] = v
      end
    end
    s.needs=1
    return s
  end

  function this.update(s)
    for k,v in pairs(s.fns) do
      if(s.index[k]~=nil and type(v)=='function') then
        s.parsed[ s.index[k] ] = v()
      end
    end
    return s
  end

  function this.render(s)
    if s.needs==1 then
      s:update()
      s.vals.html = concat(s.parsed)
      s.needs=0
    end
    s:dispatch()
  end

  function this.listen(s, cb)
    s.event = cb
    return s
  end

  function this.dispatch(s)
    s.event(s.vals)
  end

  return this
end)()
