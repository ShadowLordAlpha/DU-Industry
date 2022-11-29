-- Master control program
-- This board has all the logic for production of a final product with what should be minimal wast items

-- Container(s) containing all items that we should be able to produce
itemLibrary = {}

-- The core of the construct (factory) we are on currently
core = nil

-- The emitter that we use to trigger the worker boards in order to start production
emitter = nil

-- The databanks used to communicate back and forth with sub-boards
databanks = {}

for slot_name, slot in pairs(unit) do
    if type(slot) == "table"
            and type(slot.export) == "table"
            and slot.getClass
    then
        if slot.getClass():lower():find("coreunit") then
            core = slot
        elseif slot.getClass():lower():find('container') then
            system.print("container found")
            table.insert(itemLibrary, {
                obj = slot,
                mass = 0
            })
        elseif slot.getClass():lower():find('emitterunit') then
            emitter = slot
        elseif slot.getClass():lower():find("databankunit") then
            table.insert(databanks, slot)
        end
    end
end

-- confirm that we now have needed elements connected
if core == nil then
    system.print("Core not attached!")
    system.exit()
end

if #itemLibrary <= 0 then
    system.print("Container (Item Library) not attached!")
    system.exit()
end

if emitter == nil then
    system.print("Emitter not attached!")
    system.exit()
end

for _,databank in pairs(databanks) do
    databank.clear()
end

init = false
elementList = core.getElementIdList()
initIndex = 1
initElementsPer = 10

updateIndex = 1
updateIndustryPer = 20
updateIndustryWait = 1

industry = {}


-- Emitter channels
channel_industry_prefix = "industry_"
numChannels = 3


coroutinesTable  = {}
--all functions here will become a coroutine
MyCoroutines = {
    function()
        -- Get all the industry units on the core and store them in a table so we can easily use them later to check
        if not init then

            local maxForLoop = math.min((initIndex + initElementsPer), #elementList)
            for i = initIndex, maxForLoop, 1 do
                initIndex = i
                local id = elementList[i]

                elementType = core.getElementDisplayNameById(id):lower()

                if elementType:find("assembly line") or
                        elementType:find("glass furnace") or
                        elementType:find("3d printer") or
                        elementType:find("smelter") or
                        elementType:find("recycler") or
                        elementType:find("refinery") or
                        elementType:find("refiner") or
                        elementType:find("chemical") or
                        elementType:find("electronics") or
                        elementType:find("metalwork") or
                        elementType:find("transfer") then

                    table.insert(industry, id)
                end
            end

            if initIndex >= #elementList then
                system.print("Done Init")
                init = true
            end
        end
    end,
    function()
        -- update the status of the industry units and store them, using this as a work around for dumb shit happening at other times on workers especially for transfer units
        if init then

            local maxForLoop = math.min((updateIndex + updateIndustryPer), #industry)
            for i = updateIndex, maxForLoop, 1 do
                updateIndex = i
                local id = industry[i]
                local info = core.getElementIndustryInfoById(id)
                info.updatedUtc = system.getUtcTime() + 1

                for _,databank in pairs(databanks) do
                    if databank.hasKey(id) == 1 then
                        databank.setStringValue(id, json.encode(info))
                    end
                end
            end

            if updateIndex >= #industry then
                updateIndex = 1

                -- Is this the best way to do this? probably not but it should work for now
                local moveOn = system.getUtcTime() + updateIndustryWait
                while moveOn > system.getUtcTime() do
                    coroutine.yield(coroutinesTable[2])
                end
            end
        end
    end,
    function()
        -- update the status of the industry units and store them, using this as a work around for dumb shit happening at other times on workers especially for transfer units
        if init then
            for i = 1, numChannels, 1 do
                emitter.send(channel_industry_prefix .. i, "update")
                for i=0,10,1 do
                    coroutine.yield(coroutinesTable[3])
                end
            end

            -- Is this the best way to do this? probably not but it should work for now
            local moveOn = system.getUtcTime() + (updateIndustryWait * 2)
            while moveOn > system.getUtcTime() do
                coroutine.yield(coroutinesTable[3])
            end
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
