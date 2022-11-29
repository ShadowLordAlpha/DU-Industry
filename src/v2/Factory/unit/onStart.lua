--
-- Control system for factory stuff
--

-- Load up industry helper
industryUtil = require 'autoconf.custom.shadow.IndustryUtil'

worker = false
init = true

local item_lookup = false
local item_id = nil

-- Data that actually needs to run consistently
coroutinesTable  = {}
--all functions here will become a coroutine
MyCoroutines = {
    function()
        -- If we are a worker board what should we be doing
        if worker then

        end
    end,
    function()
        -- If we are not a worker we need to load both tables
        if not worker and init then
            -- Load up the item data
            -- industryUtil.loadItems()
            coroutine.yield(coroutinesTable[2]) -- just wait a second as its a large data part

            -- Now we need to wait for a few seconds
            local wait = system.getUtcTime() + 3
            while wait < system.getUtcTime() do
                coroutine.yield(coroutinesTable[2]) -- we need to wait for a bit of time, so this will let us wait without forgetting everything on a restart
            end

            -- Load up the recipe data
            industryUtil.loadRecipes()
            coroutine.yield(coroutinesTable[2]) -- just wait a second as its a large data part

            -- Now we need to wait for a few seconds
            local wait = system.getUtcTime() + 3
            while wait < system.getUtcTime() do
                coroutine.yield(coroutinesTable[2]) -- we need to wait for a bit of time, so this will let us wait without forgetting everything on a restart
            end

            system.print("Done loading Master Control Data")
            init = false;
        end
    end
}

function initCoroutines()
    for _,f in pairs(MyCoroutines) do
        local co = coroutine.create(f)
        table.insert(coroutinesTable, co)
    end
end

initCoroutines()

runCoroutines = function()
    for i,co in ipairs(coroutinesTable) do
        if coroutine.status(co) == "dead" then
            coroutinesTable[i] = coroutine.create(MyCoroutines[i])
        end
        if coroutine.status(co) == "suspended" then
            assert(coroutine.resume(co))
        end
    end
end

MainCoroutine = coroutine.create(runCoroutines)
