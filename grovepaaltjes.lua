-- Made By ML: Discord: ml0118 --

local BOLLARD_HASH = `prop_bollard_02c`
local STEP = 1.35   

local ROWS = {
  -- midden van LINKER rij (4 stuks)
  { anchor = vec4(-10.0220, -1832.2670, 25.2706, 231.8948), count = 4 },

  -- midden van MIDDELSTE rij (6 stuks)
  { anchor = vec4(-13.8140, -1832.6670, 25.2273, 321.1120), count = 4 },

  -- midden van RECHTER rij (4 stuks)
  { anchor = vec4(-14.1071, -1828.8940, 25.4788, 49.1368), count = 4 },
}



local spawned = {}

local function ensureModel(hash)
  if not HasModelLoaded(hash) then
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(0) end
  end
end

local function fwd(heading)
  local r = math.rad(heading)
  return vec3(-math.sin(r), math.cos(r), 0.0) 
end

local function rightVec(heading)
  local f = fwd(heading)
  return vec3(f.y, -f.x, 0.0)                 
end

local function spawnRow(anchor, count)
  ensureModel(BOLLARD_HASH)

  local base  = vec3(anchor.x, anchor.y, anchor.z)
  local right = rightVec(anchor.w)

  local mid = (count - 1) / 2.0

  for i = 0, count - 1 do
    local offset = (i - mid) * STEP
    local p = base + right * offset

    local obj = CreateObjectNoOffset(BOLLARD_HASH, p.x, p.y, p.z - 0.5, true, true, false)
    PlaceObjectOnGroundProperly(obj)
    SetEntityHeading(obj, anchor.w)
    FreezeEntityPosition(obj, true)
    SetEntityAsMissionEntity(obj, true, true)
    table.insert(spawned, obj)
  end
end

CreateThread(function()
  for _, row in ipairs(ROWS) do
    spawnRow(row.anchor, row.count)
  end
  SetModelAsNoLongerNeeded(BOLLARD_HASH)
end)

RegisterCommand('clearpaaltjes', function()
  for _, ent in ipairs(spawned) do
    if DoesEntityExist(ent) then DeleteObject(ent) end
  end
  spawned = {}
end)

AddEventHandler('onResourceStop', function(res)
  if res == GetCurrentResourceName() then
    for _, ent in ipairs(spawned) do
      if DoesEntityExist(ent) then DeleteObject(ent) end
    end
  end
end)
