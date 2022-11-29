-- Parts of this code were taken from the below repos
-- https://github.com/Jericho1060/du-nested-coroutines

-- Verify that we have a screen connected to the board
-- verify that we have a core connected to the board
screens = {}
core = nil

for slot_name, slot in pairs(unit) do
    if type(slot) == "table"
            and type(slot.export) == "table"
            and slot.getClass
    then
        if slot.getClass():lower() == 'screenunit' then
            table.insert(screens, slot)
        end
        if slot.getClass():lower():find("coreunit") then
            core = slot
        end
    end
end

-- values that are generally unchanging
elementsIdList = core.getElementIdList()
init = false
initIndex = 0
chkIndex = 0
maxIndustryInit = 10
maxIndustryCheck = 5
industryRefreshSeconds = 1

assembler = {}
glass = {}
printer = {}
smelter = {}
recycler = {}
refiner = {}
chemical = {}
electronic = {}
metalwork = {}

lastRun = 0
sele = nil
selected = {}
package = {}

coroutinesTable  = {}
--all functions here will become a coroutine
MyCoroutines = {
    function()
        if not init then
            local maxInitIndex = math.min((initIndex + maxIndustryInit), #elementsIdList)
            for i = initIndex, maxInitIndex, 1 do
                initIndex = i
                local id = elementsIdList[i]
                elementType = core.getElementDisplayNameById(id):lower()

                -- system.print(initIndex .. ": " .. elementType)
                if elementType:find("assembly line") then
                    table.insert(assembler, id)
                elseif elementType:find("glass furnace") then
                    table.insert(glass, id)
                elseif elementType:find("3d printer") then
                    table.insert(printer, id)
                elseif elementType:find("smelter") then
                    table.insert(smelter, id)
                elseif elementType:find("recycler") then
                    table.insert(recycler, id)
                elseif elementType:find("refinery") then
                    table.insert(refiner, id)
                elseif elementType:find("chemical") then
                    table.insert(chemical, id)
                elseif elementType:find("electronics") then
                    table.insert(electronic, id)
                elseif elementType:find("metalwork") then
                    table.insert(metalwork, id)
                end
            end

            if initIndex >= #elementsIdList then
                -- elementsTypes = removeDuplicatesInTable(elementsTypes)
                init = true
                system.print("All elements loaded")

                sele = "assembler"
                selected = assembler;
            end
        end
    end,
    function()
        if init then
            if lastRun ~= 0 and lastRun > system.getUtcTime() then
                -- it is not yet time for us to run the get data again
                return
            end

            -- system.print(#selected .. " / " .. #assembler)
            local maxInitIndex = math.min((chkIndex + maxIndustryCheck), #selected)
            for i = chkIndex, maxInitIndex, 1 do
                chkIndex = i

                local id = selected[i]
                local elem = core.getElementIndustryInfoById(id)
                local elemName = core.getElementDisplayNameById(id)
                system.print(chkIndex .. ": " .. elemName)
                system.print(chkIndex .. elem.currentProducts[1].quantity .. " / " .. elem.maintainProductAmount)

                local machine = {
                    id = id,
                    name = elemName,
                    state = elem.state,
                    stop_requested = elem.stopRequested,
                    schematic_id = elem.schematicId,
                    schematics_remaining = elem.schematicsRemaining,
                    units_produced = elem.unitsProduced,
                    time_remaining = elem.remainingTime,
                    batches_requested = elem.batchesRequested,
                    batches_remaining = elem.batchesRemaining,
                    maintain_amount = elem.maintainProductAmount,
                    current_product_amount = elem.currentProductAmount,
                    current_products = elem.currentProducts
                }
                table.insert(package, machine)
                -- coroutine.yield(coroutinesTable[2])--the second fonction yiel is with index 2
            end

            if chkIndex >= #selected then
                local input = json.encode(package)
                for _,screen in pairs(screens) do
                    screen.setScriptInput(input)
                end

                system.print("sending data")
                lastRun = system.getUtcTime() + industryRefreshSeconds
                chkIndex = 0
            end
        end
    end,
    function()
        if init then
            local output = nil
            for _,screen in pairs(screens) do
                local check = screen.getScriptOutput()
                if check ~= nil and check ~= '' then
                    screen.clearScriptOutput()
                    output = check
                end
            end

            if output ~= nil and output ~= sele then
                sele = output
                if sele == "assembler" then
                    selected = assembler
                elseif sele == "glass" then
                    selected = glass
                elseif sele == "printer" then
                    selected = printer
                elseif sele == "smelter" then
                    selected = smelter
                elseif sele == "recycler" then
                    selected = recycler
                elseif sele == "refiner" then
                    selected = refiner
                elseif sele == "chemical" then
                    selected = chemical
                elseif sele == "electronic" then
                    selected = electronic
                elseif sele == "metalwork" then
                    selected = metalwork
                end
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
