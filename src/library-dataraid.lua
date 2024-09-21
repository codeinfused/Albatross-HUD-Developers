---
--- Simulates a databank raid creating an abstraction layer to support
--- multiple databank units through round robin selection, allowing the
--- use of in-game syntax to access the databank info.
---
--- To initialise the databank raid, use an array of databank units.
---
--- local raid = bankraid:new( { databank1, databank2 } )
---
--- you can add more databanks later without disrupting the raid:
---
--- raid:add( databank3 )
---
--- In your script use, use the raid as if it is a single databank unit:
---
--- raid.clear()
--- raid.setStringValue( "testkey", "testvalue" )
--- system.print( raid.getKeys() )
---
--- Notes: if initially you had a single databank in your code, rename it
--- to something else and create the databank raid using the same name of
--- your previous databank, this way you won't need to touch any other line
--- of code in your script.
---
---
json = require "dkjson"

bankraid = {}

--- Creates and initializes the databank array
--- @param banks array
--- @return raid object
function bankraid:new(banks)
  o = {}
  setmetatable(o, self);
  self.__index = self;
  o.banks = banks or {}
  o.banks_size = #banks or 0
  o.banks_chars = {}
  o.default_max = 30000
  o.default_pad = 2000
  o.full = false
  o.rr = math.floor(math.random()*#o.banks) + 1

  -- databank shortcuts to allow in-game syntax.
  function o.clear()                    return o:_clear() end
  function o.getNbKeys()                return o:_getNbKeys() end
  function o.getKeys()                  return o:_getKeys() end
  function o.hasKey(key)                return o:_hasKey(key) end
  function o.hasRaidKey(key)            return o:_hasRaidKey(key) end
  function o.getStringValue(key)        return o:_getStringValue(key) end
  function o.getIntValue(key)           return o:_getIntValue(key) end
  function o.getFloatValue(key)         return o:_getFloatValue(key) end
  function o.setStringValue(key, value) return o:_setStringValue(key, value) end
  function o.setIntValue(key, value)    return o:_setIntValue(key, value) end
  function o.setFloatValue(key, value)  return o:_setFloatValue(key, value) end

  o:_init();
  return o
end

function bankraid:_init()
  for i=1, self.banks_size, 1 do
    sized = 0
    local keys = self.banks[i].getKeys()
    for k,v in ipairs(keys) do
      sized = sized + self:_addlength(i, k)
    end
    self.banks_chars[i] = sized
  end
end

function bankraid:_measureDb(i)
  sized = 0
  local keys = self.banks[i].getKeys()
  for k,v in ipairs(keys) do
    sized = sized + self:_addlength(i, k)
  end
  self.banks_chars[i] = sized
end

function bankraid:_addlength(i, k)
  return #tostring(k) + #self.banks[i].getStringValue(k)
end

--- Adds another databank to the raid.
--- @param object The databank unit to add.
function bankraid:add(element)
  table.insert( self.banks, element)
  self.banks_size = self.banks_size + 1
  --self.banks_chars[i]
end

--- Updates the round-robin index
function bankraid:update()
  local tries = 0;
  local valid = 0;
  while tries < 2 or valid < 1 do
    self.rr = self.rr + 1
    if( self.rr > self.banks_size ) then 
      self.rr = 1;
      tries = tries + 1;
    end
    if( self.banks_chars[self.rr] > (self.default_max - self.default_pad) ) then
      valid = 0
    else
      valid = 1
    end
  end
  if(tries > 1) then
    self.full = true
    system.print('-------------------------------');
    system.print('ERROR: All databanks are now full.');
  end
  return self.full;
end

--- Clears the databank array
function bankraid:_clear()
  local res = 0
  for i=1, self.banks_size, 1 do self.banks[i].clear() end
  return res
end

--- Returns the number of keys in the entire databank array
--- @return integer number of total keys
function bankraid:_getNbKeys()
  local res = 0
  for i=1, self.banks_size, 1 do res = res + self.banks[i].getNbKeys() end
  return res
end

--- Returns all the keys in the databank array
--- @return string json encoded string of keys
function bankraid:_getKeys()
  local res = {}
  for i=1, self.banks_size, 1 do
    local keys = json.decode(self.banks[i].getKeys())
    for k,v in pairs(keys) do table.insert(res, v) end
  end
  return json.encode(res)
end

--- Checks if a key exists in the databank array
--- @param string key
--- @return boolean returns 1 if the array holds this key.
function bankraid:_hasKey(key)
  for i=1, self.banks_size, 1 do
    if (self.banks[i].hasKey(key) == 1) then return 1 end
  end
  return 0
end

--- Checks if a key exists and returns raid index
--- @param string key
--- @return boolean returns 1 if the array holds this key.
function bankraid:_hasRaidKey(key)
    for i=1, self.banks_size, 1 do
      if (self.banks[i].hasKey(key) == 1) then return i end
    end
    return 0
  end

--- Returns the value of the key if existing
--- @param string key
--- @return string returns value or nil
function bankraid:_getStringValue(key)
  for i=1, self.banks_size, 1 do
    if (self.banks[i].hasKey(key) == 1) then
      return self.banks[i].getStringValue(key)
    end
  end
  return nil
end

--- Returns the integer value of the key if existing
--- @param string key
--- @return number returns value or nil
function bankraid:_getIntValue(key)
  for i=1, self.banks_size, 1 do
    if (self.banks[i].hasKey(key) == 1) then
      return self.banks[i].getIntValue(key)
    end
  end
  return nil
end

--- Returns the float value of the key if existing
--- @param string key
--- @return number returns value or nil
function bankraid:_getFloatValue(key)
  for i=1, self.banks_size, 1 do
    if (self.banks[i].hasKey(key) == 1) then
      return self.banks[i].getFloatValue(key)
    end
  end
  return nil
end

--- Stores the string value using the key
--- @param string key
--- @param string value
function bankraid:_setStringValue(key, value)
  if( self:update() ) then return end;
  local rr = self.rr
  local existsRR = self:_hasRaidKey(key)
  if(existsRR > 0) then rr = existsRR end
  self.banks[rr].setStringValue(key, value)
end

--- Stores the integer value using the key
--- @param string key
--- @param number value
function bankraid:_setIntValue(key, value)
  if( self:update() ) then return end;
  local rr = self.rr
  local existsRR = self:_hasRaidKey(key)
  if(existsRR > 0) then rr = existsRR end
  self.banks[rr].setIntValue(key, value)
end

--- Stores the float value using the key
--- @param string key
--- @param number value
function bankraid:_setFloatValue(key, value)
  if( self:update() ) then return end;
  local rr = self.rr
  local existsRR = self:_hasRaidKey(key)
  if(existsRR > 0) then rr = existsRR end
  self.banks[rr].setFloatValue(key, value)
end

--[[

-- example
-- Asuming your construct has 3 databanks named: db1, db2 and db3
testraid = bankraid:new({db1, db2, db3})

-- add some sample data
testraid.setStringValue("test1key", "test1value")
testraid.setStringValue("test2key", "test2value")
testraid.setStringValue("test3key", "test3value")
testraid.setIntValue("int1key", 1234)
testraid.setIntValue("int2key", 5678)
testraid.setFloatValue("float1key", 1234.5678)
testraid.setFloatValue("float2key", 8765.4321)

system.print("Number of keys     : " .. testraid.getNbKeys())
system.print("key list           : " .. testraid.getKeys())
system.print("'test2key' exists  : " .. testraid.hasKey("test2key"))
system.print("'test0key' does not: " .. testraid.hasKey("test0key"))
system.print("int1   int   value : " .. testraid.getIntValue("int1key"))
system.print("float2 float value : " .. testraid.getFloatValue("float2key"))

-- if needed, you can still access your databanks directly and it would
-- not affect the databank array
db1.setIntValue("int1", 1234)

]]
