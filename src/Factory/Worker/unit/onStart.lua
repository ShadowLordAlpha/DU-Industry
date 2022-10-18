-- Worker unit for control boards

-- Container(s) containing all items that we should be able to produce
itemLibrary = {}

databank = nil

industry = {}

for slot_name, slot in pairs(unit) do
    if type(slot) == "table"
            and type(slot.export) == "table"
            and slot.getClass
    then
        if slot.getClass():lower() == 'industry1' or slot.getClass():lower() == 'industryunit'then
            system.print("industry found")
            table.insert(industry, {
                indy = slot,
                broken = false,
                item_index = 0
            })
        elseif slot.getClass():lower():find("databankunit") then
            databank = slot
        elseif slot.getClass():lower():find('container') then
            system.print("container found")
            table.insert(itemLibrary, {
                obj = slot,
                mass = 0
            })
        end
    end
end

maintainAmount = 300 --export: How much should we attempt to keep in our containers

local data = nil
knownData = false
for _,container in pairs(itemLibrary) do
    if databank.hasKey(container.obj.getLocalId()) == 1 then
        system.print(databank.getStringValue(container.obj.getLocalId()))
        data = json.decode(databank.getStringValue(container.obj.getLocalId()))

        system.print("known data" .. data.mass .. " / " .. container.obj.getItemsMass())

        if  math.ceil(data.mass) ==  math.ceil(container.obj.getItemsMass()) then
            system.print("data equal")
            knownData = true
            break
        else
            system.print("data not equal")
        end
    end
end

if knownData then
    system.print("known data")
    -- get what index we are on
    -- local data = json.decode(databank.getStringValue(container.obj.getLocalId()))

    for _,indy in pairs(industry) do
        if indy.indy.getState() ~= 2 then
            indy.indy.stop(1, 0)

            local find = indy.indy.getOutputs()[1].id

            for i,item in pairs(data.data) do
                if item.id == find then
                    if i >= #data.data then
                        indy.indy.setOutput(data.data[1])
                    else
                        indy.indy.setOutput(data.data[i + 1])
                    end

                    indy.indy.startMaintain(maintainAmount)
                    break
                end
            end
        end
    end

    unit.exit(1)
end

coroutinesTable  = {}
--all functions here will become a coroutine
MyCoroutines = {
    function()
        if not knownData then
            for _,container in pairs(itemLibrary) do

                -- Check to make sure we are able to do the update on the container
                local time = math.ceil(container.obj.updateContent())
                system.print("refresh time: " .. time)
                while time > 0 do
                    local next = system.getUtcTime() + time
                    while next > system.getUtcTime() do
                        coroutine.yield(coroutinesTable[1])
                    end

                    time = math.ceil(container.obj.updateContent())
                end

                local content = container.obj.getContent()

                local data = {}
                for _,item in pairs(content) do
                    system.print(item.id)

                    table.insert(data, item.id)
                end

                local mass = container.obj.getItemsMass()

                local package = {
                    mass = mass,
                    data = data
                }

                databank.setStringValue(container.obj.getLocalId(), json.encode(package))
                system.print("data saved")
            end

            unit.exit(1)

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
