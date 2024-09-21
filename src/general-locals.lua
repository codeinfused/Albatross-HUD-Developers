local utils, st = utils, string
local log,          ipairs, pairs, setmetatable, gmatch,    str_gsub,  str_sub,  str_find,  format,    concat,       sort,       floor,      max,        min,      abs,      unpack,       remove,       uclamp     =
      system.print, ipairs, pairs, setmetatable, st.gmatch, st.gsub,   st.sub,   st.find,   st.format, table.concat, table.sort, math.floor, math.max,   math.min, math.abs, table.unpack, table.remove, utils.clamp;

local yield,           resume            status           =
      coroutine.yield, coroutine.resume, coroutine.status

local atlas = require('atlas');