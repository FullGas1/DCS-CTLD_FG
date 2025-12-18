--[[---------------------------------------------------------------
-- Customizing CTLD allows users to modify various application settings.

To do this, they create a file named CTLD_personalConfig.lua containing a YAML data structure.
This data is automatically parsed when CTLD starts and before any functional activations
(menus, etc.) are triggered, in order to override the default configuration.

The CTLD_personalConfig.lua file must be executed using "DO SCRIPT FILE" before CTLD.lua is loaded.
----------------------------------------------------------------]] --

------------------------------------------------------------------
-- yaml parsing utilities
------------------------------------------------------------------
-- Utility: Trims whitespace from both ends of a string
-- @param s: The raw string to trim
local function trim(s)
    return s:match("^%s*(.-)%s*$")
end

-- Utility: Converts string values to their appropriate Lua types
-- @param v: The string value to convert
local function to_type(v)
    if v == "true" then return true end
    if v == "false" then return false end
    if tonumber(v) then return tonumber(v) end
    return v:gsub("^['\"]", ""):gsub("['\"]$", "")
end

-- Main Parser: Converts a YAML-formatted string into a Lua Table
function parseYAML(data)
    local result = {}
    local stack = { result }
    local indentStack = { -1 }

    local literalMode = false
    local literalKey, literalIndent = "", 0
    local literalLines = {}

    for line in data:gmatch("[^\r\n]+") do
        local indent = line:match("^%s*"):len()
        local content = trim(line)

        -- 1. EXIT MULTILINE MODE
        if literalMode and #content > 0 and indent <= literalIndent then
            stack[#stack][literalKey] = table.concat(literalLines, "\n")
            literalMode = false
            literalLines = {}
        end

        -- 2. PROCESSING
        if literalMode then
            literalLines[#literalLines + 1] = line:sub(literalIndent + 3) or ""
        elseif content ~= "" and not content:match("^#") then
            -- STACK REALIGNMENT
            while #indentStack > 1 and indent <= indentStack[#indentStack] do
                table.remove(stack)
                table.remove(indentStack)
            end

            -- Check for list item with key attached (- polar:)
            local listDashKey, listDashValue = content:match("^%- ([^:]+):%s*(.*)")
            local key, value

            if listDashKey then
                -- NEW LIST ITEM OBJECT
                local newEntry = {}
                local parent = stack[#stack]
                parent[#parent + 1] = newEntry

                -- We push the entry into the stack
                table.insert(stack, newEntry)
                table.insert(indentStack, indent)

                key, value = listDashKey, listDashValue
                -- Important: update indent to match the key position after the dash
                indent = line:find(listDashKey) - 1
            else
                -- Standard key:value
                key, value = content:match("([^:]+):%s*(.*)")
            end

            if key then
                key, value = trim(key), trim(value)
                if value == "|" then
                    literalMode, literalKey, literalIndent = true, key, indent
                    literalLines = {}
                elseif value == "" then
                    -- Nested object
                    local newSubTable = {}
                    stack[#stack][key] = newSubTable
                    -- Move into the sub-table
                    table.insert(stack, newSubTable)
                    table.insert(indentStack, indent)
                else
                    -- Simple assignment
                    stack[#stack][key] = to_type(value)
                end
            elseif content:match("^%-") then
                -- Simple list item (- SAM-6)
                local item = trim(content:sub(2))
                local parent = stack[#stack]
                if type(parent) == "table" then
                    parent[#parent + 1] = to_type(item)
                end
            end
        end
    end

    if literalMode then stack[#stack][literalKey] = table.concat(literalLines, "\n") end
    return result
end

--[[[--- example and test -----------------------------------------
------------ example script yaml ---------------------------------
if ctld == nil then ctld = {} end
ctld.yamlConfigDatas = [[
config_mission:
  auto_start: true
  max_players: 10
  briefing: |
    Bienvenue dans l'opération "Steel Rain".
    Objectif 1 : Détruire les radars.
    Objectif 2 : Rentrer à la base.
  targets:
    - SAM-6
    - ZU-23
  scenes:
    FARP Alpha:
      steps:
        - polar:
            distance: 100
            angle: 0
          delayAfterPreviousStep: 0
          relativeHeadingInDegrees: 180
          relativeAltitudeInMeters: 0
          objectsDescDbKey: SINGLE_HELIPAD
          func: |
            function(triggerUnitObj, spwanedObject, stepDatas)
                -- Custom logic here
                return true
            end
        - polar:
            distance: 130
            angle: 5
          delayAfterPreviousStep: 3
          relativeHeadingInDegrees: 90
          relativeAltitudeInMeters: 0
          objectsDescDbKey: COMMAND_TENT
]]
---]]]---------------------------------------------------------------
--[[ run parsing
local myTable = parseYAML(yamlConfigDatas)

-- types Verification
if myTable.config_mission.auto_start == true then
    local limit = myTable.config_mission.max_players + 5 -- Calculation is possible because it is a number
    trigger.action.outText("Briefing loaded :\n" .. myTable.config_mission.briefing, 15)
end
------------------------------------------------------------------
return myTable ]] --
