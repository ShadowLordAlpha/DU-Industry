-- Control industry stuff :D

itemLibrary = {}
industry = {}
core = nil

for slot_name, slot in pairs(unit) do
    if type(slot) == "table"
            and type(slot.export) == "table"
            and slot.getClass
    then
        -- system.print(slot.getClass())
        if slot.getClass():lower() == 'industry1' or slot.getClass():lower() == 'industryunit'then
            system.print("industry found")
            table.insert(industry, {
                indy = slot,
                broken = false,
                item_index = 0
            })
        elseif slot.getClass():lower():find('container') then
            system.print("container found")
            table.insert(itemLibrary, {
                indy = slot,
                mass = 0
            })
        elseif slot.getClass():lower():find("coreunit") then
            system.print("core found")
            core = slot
        end

    end
end

init = false
initIndex = 0
initMaxRun = 10
prodItems = {}
containerRefresh = 0;
industryRefresh = 0;
industryRefreshTime = 2;

qty = 300

coroutinesTable  = {}
--all functions here will become a coroutine
MyCoroutines = {
    function()
        if not init then
            if containerRefresh ~= 0 and containerRefresh > system.getUtcTime() then
                return
            end

            local loaded = false
            local maxRun = math.min((initIndex + initMaxRun), #itemLibrary)
            for i = initIndex, maxRun, 1 do
                initIndex = i
                -- Check container for items
                local container = itemLibrary[i]
                if container ~= nil and container.indy.getItemsMass() ~= container.mass then
                    local refresh = container.indy.updateContent()
                    if refresh ~= 0 then
                        containerRefresh = system.getUtcTime() + math.ceil(refresh)
                        system.print("Refresh in: " .. containerRefresh)
                    else
                        system.print("Loading Items")
                        container.mass = container.indy.getItemsMass()
                        local content = container.indy.getContent()
                        for _,item in pairs(content) do
                            local itmData = system.getItem(item.id)

                            local data = {
                                id = itmData.id,
                                name = itmData.locDisplayName,
                                amt = qty
                            }
                            table.insert(prodItems, data)
                            loaded = true
                        end
                    end
                end
            end

            if initIndex >= #itemLibrary and loaded then
                system.print("Starting Industry")
                init = true
            end
        end
        --    coroutine.yield(coroutinesTable[1])--start with index 1 and so on
    end,
    function()
        if init then
            if industryRefresh ~= 0 and industryRefresh > system.getUtcTime() then
                return
            end

            for _,indy in pairs(industry) do

                if indy.broken then
                    local info = indy.indy.getInfo();
                    local item = prodItems[indy.item_index]

                    system.print("Broken Amount, " .. info.currentProductAmount .. " / " .. item.amt)
                    if info.currentProductAmount >= item.amt then
                        indy.indy.stop(1, 0)
                    else
                        industryRefresh = system.getUtcTime() + industryRefreshTime
                    end
                end

                if indy.indy.getState() ~= 2 then

                    indy.indy.stop(1, 0)
                    coroutine.yield(coroutinesTable[2])

                    if indy.item_index >= #prodItems then
                        indy.item_index = 1
                    else
                        indy.item_index = indy.item_index + 1
                    end

                    local item = prodItems[indy.item_index]

                    if indy.indy.getOutputs()[1].id ~= item.id then
                        system.print("Changing item: " .. item.name)
                        indy.indy.setOutput(item.id)
                        coroutine.yield(coroutinesTable[2])
                        industryRefresh = system.getUtcTime() + industryRefreshTime
                        indy.indy.startMaintain(item.amt)

                        local delayRefresh = system.getUtcTime() + 2
                        if delayRefresh > system.getUtcTime() then
                            coroutine.yield(coroutinesTable[2])
                        end


                        --local info = core.getElementIndustryInfoById(indy.indy.getLocalId())
                        local info = indy.indy.getInfo();
                        if info.maintainProductAmount ~= item.amt then
                            system.print("Broken Item " .. item.name)
                            system.print("Broken Amount, maint AMOUNT " .. info.maintainProductAmount)
                            system.print("Broken Amount, cURRENT AMOUNT " .. info.currentProductAmount)
                            indy.indy.stop(1, 0)

                            indy.broken = true
                            indy.indy.startRun()
                        else
                            indy.broken = false
                        end
                    end
                end

                coroutine.yield(coroutinesTable[2])
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
