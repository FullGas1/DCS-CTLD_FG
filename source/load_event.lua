----------------------------------------------------------------
local tracker = {
    loadedObjects = {}
}

-- Logique de collision Bounding Box (Certifiée API)
local function isInsideBox(carrier, cargo)
    local cPos = carrier:getPosition()
    local cDesc = carrier:getDesc()
    local gPos = cargo:getPosition()

    if not cDesc or not cDesc.box then return false end

    local rel = {
        x = gPos.p.x - cPos.p.x,
        y = gPos.p.y - cPos.p.y,
        z = gPos.p.z - cPos.p.z
    }

    local lx = rel.x * cPos.x.x + rel.y * cPos.x.y + rel.z * cPos.x.z
    local ly = rel.x * cPos.y.x + rel.y * cPos.y.y + rel.z * cPos.y.z
    local lz = rel.x * cPos.x.z + rel.y * cPos.y.z + rel.z * cPos.z.z

    if lx >= cDesc.box.min.x and lx <= cDesc.box.max.x and
        ly >= cDesc.box.min.y and ly <= cDesc.box.max.y and
        lz >= cDesc.box.min.z and lz <= cDesc.box.max.z then
        return true
    end
    return false
end

-- Inventaire exhaustif via coalition (Seule méthode API réelle)
local function getAllLiveObjects()
    local obs = {}
    local coalitions = { 0, 1, 2 } -- Neutral, Red, Blue

    for _, coa in pairs(coalitions) do
        -- Récupération des Unités
        local groups = coalition.getGroups(coa)
        for _, gp in pairs(groups) do
            local units = gp:getUnits()
            for _, u in pairs(units) do
                if u:isExist() and u:getLife() > 0 then table.insert(obs, u) end
            end
        end
        -- Récupération des Statics
        local statics = coalition.getStaticObjects(coa)
        for _, s in pairs(statics) do
            if s:isExist() and s:getLife() > 0 then table.insert(obs, s) end
        end
    end
    return obs
end

function tracker.update()
    local candidates = getAllLiveObjects()

    for i = 1, #candidates do
        local carrier = candidates[i]
        for j = 1, #candidates do
            local cargo = candidates[j]
            if i ~= j then
                local cargoID = cargo:getID()
                local inside = isInsideBox(carrier, cargo)

                if inside and not tracker.loadedObjects[cargoID] then
                    tracker.loadedObjects[cargoID] = carrier:getID()
                    trigger.action.outText(
                        string.format("EVENT_LOAD_OBJECT : [%s] a loadé [%s]", carrier:getName(), cargo:getName()), 10)
                elseif not inside and tracker.loadedObjects[cargoID] == carrier:getID() then
                    tracker.loadedObjects[cargoID] = nil
                end
            end
        end
    end
    return timer.getTime() + 1.0
end

timer.scheduleFunction(tracker.update, nil, timer.getTime() + 1)
