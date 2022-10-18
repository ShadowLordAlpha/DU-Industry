-- Master control program
-- This board has all the logic for production of a final product with what should be minimal wast items

-- Container(s) containing all items that we should be able to produce
itemLibrary = {}

-- The core of the construct (factory) we are on currently
core = nil

-- The emitter that we use to trigger the worker boards in order to start production
emitter = nil

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

init = false

-- Emitter channels
channel_refiner = "refiner" --export: receiver channel to send orders to refiners
channel_assembly = "assembly" --export: receiver channel to send orders to assembly lines
channel_smelter = "smelters" --export: receiver channel to send orders to smelters
channel_chemical = "chemical" --export: receiver channel to send orders to chemical indutries
channel_electronics = "_electronics" --export: receiver channel to send orders to electronic industries
channel_glass = "glass" --export: receiver channel to send orders to glass furnace
channel_honeycomb = "honeycomb" --export: receiver channel to send orders to honeycomb refiniries
channel_recycler = "recycler" --export: receiver channel to send orders to recylers
channel_metalwork = "metalworks" --export: receiver channel to send orders to metalworks
channel_3d_printer = "printers" --export: receiver channel to send orders to 3d printers
channel_suffix_transfer_output = "_output" --export: receiver channel to send orders to output tranfer units
channel_suffix_transfer_input = "_input" --export: receiver channel to send orders to input tranfer units


coroutinesTable  = {}
--all functions here will become a coroutine
MyCoroutines = {
    function()
        if not init then
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

                for _,item in pairs(content) do
                    system.print(item.id)
                    local itmData = system.getItem(item.id)
                    local itemRecipes = system.getRecipes(item.id)

                    for _,itemRecipe in pairs(itemRecipes) do
                        for _,ingre in pairs(itemRecipe.ingredients) do
                            local ingreItmData = system.getItem(ingre.id)
                            system.print(ingreItmData.displayName .. " " .. ingre.quantity)
                        end
                    end
                end
            end
        end
    end,
    function()
        for i=0, 10 do
            -- system.print("function 2 --- "..i)
            coroutine.yield(coroutinesTable[2])--the second fonction yiel is with index 2
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
