-- Worker unit for control boards

-- Container(s) containing all items that we should be able to produce
itemLibrary = nil

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
            itemLibrary = slot
        end
    end
end

maintainAmount = 300 --export: How much should we attempt to keep in our containers
-- the item id followed by the amount we want to keep. this allows us to override the default on a per item need
-- TODO: add these overrides to the list of items as well most likely
--override = "{\"3193900802\":1}"
override = '{}' --export: How much should we attempt to keep in our containers
overrideParsed = json.decode(override)

local data = nil
knownData = itemLibrary == nil
if itemLibrary ~= nil and databank.hasKey(itemLibrary.getLocalId()) == 1 then
    system.print(databank.getStringValue(itemLibrary.getLocalId()))
    data = json.decode(databank.getStringValue(itemLibrary.getLocalId()))

    system.print("known data" .. data.mass .. " / " .. itemLibrary.getItemsMass())

    if  math.ceil(data.mass) ==  math.ceil(itemLibrary.getItemsMass()) and #data.items > 0 then
        system.print("data equal")
        knownData = true
    else
        system.print("data not equal")
    end
end

for i,v in pairs(overrideParsed) do
    if v ~= nil then
        local insert = true
        if data ~= nil then
            for k,x in pairs(data.items) do
                if x == tonumber(i) then
                    insert = false
                    break
                end
            end
        else
            data = {mass = 0, items = {}}
        end

        if insert then
            table.insert(data.items, i)
        end
    end
end

if knownData then
    -- data is know so we can just use the databank data
    for _,indy in pairs(industry) do

        system.print("Checking key " .. databank.hasKey(indy.indy.getLocalId()))
        if databank.hasKey(indy.indy.getLocalId()) == 1 then
            local info = json.decode(databank.getStringValue(indy.indy.getLocalId()))

            -- If there has not been an update to this industry do nothing
            if info.updatedUtc == nil or info.updatedUtc < system.getUtcTime() then
                unit.exit(1)
            end

            -- local info = indy.indy.getInfo()
            local amount = maintainAmount
            if overrideParsed ~= nil and overrideParsed["" .. info.currentProducts[1].id] ~= nil then
                amount = overrideParsed["" .. info.currentProducts[1].id]
            end

            if (info.state ~= 2 and info.state ~= 1) or (info.state ~= 1 and info.maintainProductAmount ~= amount) then
                indy.indy.stop(1, 0)
            elseif info.state == 1 and info.maintainProductAmount ~= amount then
                indy.indy.startMaintain(amount)
            elseif info.state == 1 then

                local find = info.currentProducts[1].id
                local itemId = data.items[1]
                for i,item in pairs(data.items) do
                    if item == find then
                        if i >= #data.items then
                            itemId = data.items[1]
                        else
                            itemId = data.items[i + 1]
                        end
                    end
                end

                amount = maintainAmount
                if overrideParsed ~= nil and overrideParsed["" .. itemId] ~= nil then
                    amount = overrideParsed["" .. itemId]
                end

                indy.indy.setOutput(itemId)
                indy.indy.startMaintain(amount)

                -- note, attempting to get the industry info here does not work, its too soon for it to actually do anything
            end
        else
            databank.setStringValue(indy.indy.getLocalId(), "{}")
        end
    end

elseif itemLibrary ~= nil and math.ceil(itemLibrary.updateContent()) <= 0 then
    -- we need to refresh the data in the databank and have been successful in our run
    local within = {}
    for _,item in pairs(itemLibrary.getContent()) do
        system.print(item.id)

        table.insert(within, item.id)
    end

    local mass = itemLibrary.getItemsMass()

    local package = {
        mass = mass,
        items = within
    }

    databank.setStringValue(itemLibrary.getLocalId(), json.encode(package))
    system.print("data saved")
end

-- worker script done
unit.exit(1)
