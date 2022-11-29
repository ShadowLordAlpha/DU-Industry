-- local items = require 'src.v2.Factory.External.items_api_dump'
-- local recipes = require 'src.v2.Factory.External.recipes_api_dump'

local industryUtil = {}

industryUtil.items = nil
industryUtil.recipes = nil

-- Get the Industry needed to craft the specific Item. Should be mostly accurate.
function industryUtil.getIndustryFromItem(item)

    local icon = item.iconPath;
    local name = item.displayNameWithSize;

    if string.match(icon, 'resources_generated/elements/scraps/') then
        -- All products made in the Recycler
        return "Recycler"
    elseif
        -- Materials
        string.match(icon, 'resources_generated/elements/products/product-brick') or
        string.match(icon, 'resources_generated/elements/products/product-concrete') or
        string.match(icon, 'resources_generated/elements/products/product-marble') or
        string.match(icon, 'resources_generated/elements/products/product-wood') or
        string.match(icon, 'resources_generated/env/voxel/ingots') then

        return "Refinery"

    elseif
        -- Parts
        string.match(icon, 'resources_generated/elements/complex-parts/complex-part-injector') or
        string.match(icon, 'resources_generated/elements/complex-parts/complex-part-quantum-core') or
        string.match(icon, 'resources_generated/elements/functional-parts/functional-part-screen') or
        string.match(icon, 'resources_generated/elements/intermediary-parts/intermediary-part-fixation') or
        string.match(icon, 'resources_generated/elements/structural-parts/structural-part-casing') or
        -- Materials
        string.match(icon, 'resources_generated/elements/products/product-carbon-fiber') then

        return "Printer"
    elseif
        -- Materials
        string.match(icon, 'resources_generated/elements/products/product-conductor-metal') or
        string.match(icon, 'resources_generated/elements/products/product-heavy-metal') or
        string.match(icon, 'resources_generated/elements/products/product-light-metal') then

        return "Smelter"
    elseif
        -- Parts
        string.match(icon, 'resources_generated/elements/complex-parts/complex-part-anti-matter-capsule') or
        string.match(icon, 'resources_generated/elements/complex-parts/complex-part-optics') or
        string.match(icon, 'resources_generated/elements/functional-parts/functional-part-laser-chamber') or
        string.match(icon, 'resources_generated/elements/intermediary-parts/intermediary-part-led') or
        -- Materials
        string.match(icon, 'resources_generated/elements/products/product-glass') or
        string.match(icon, 'resources_generated/env/voxel/hc/emissive-hc') then

        -- All products made in the Glass Furnace
        return "Glass"
    elseif
        -- Parts
        string.match(icon, 'resources_generated/elements/complex-parts/complex-part-burner') or
        string.match(icon, 'resources_generated/elements/complex-parts/complex-part-hydraulics') or
        string.match(icon, 'resources_generated/elements/complex-parts/complex-part-magnet') or
        string.match(icon, 'resources_generated/elements/complex-parts/complex-part-singularity-container') or
        string.match(icon, 'resources_generated/elements/complex-parts/complex-part-warhead') or
        string.match(icon, 'resources_generated/elements/functional-parts/functional-part-chemical-container') or
        string.match(icon, 'resources_generated/elements/functional-parts/functional-part-combustion-chamber') or
        string.match(icon, 'resources_generated/elements/functional-parts/functional-part-electric-engine') or
        string.match(icon, 'resources_generated/elements/functional-parts/functional-part-firing-system') or
        string.match(icon, 'resources_generated/elements/functional-parts/functional-part-gaz-cylindre') or
        string.match(icon, 'resources_generated/elements/functional-parts/functional-part-ionic-chamber') or
        string.match(icon, 'resources_generated/elements/functional-parts/functional-part-magnetic-rail') or
        string.match(icon, 'resources_generated/elements/functional-parts/functional-part-silo') or
        string.match(icon, 'resources_generated/elements/functional-parts/functional-part-mobile-panel') or
        string.match(icon, 'resources_generated/elements/functional-parts/functional-part-robotic-arm') or
        string.match(icon, 'resources_generated/elements/intermediary-parts/intermediary-part-pipe') or
        string.match(icon, 'resources_generated/elements/intermediary-parts/intermediary-part-screw') or
        string.match(icon, 'resources_generated/elements/structural-parts/structural-part-reinforced-frame') or
        string.match(icon, 'resources_generated/elements/structural-parts/structural-part-standart-frame') then

        -- All products made in the Metalworks
        return "Metalworks"
    elseif
        -- Parts
        string.match(icon, 'resources_generated/elements/complex-parts/complex-part-electronics') or
        string.match(icon, 'resources_generated/elements/complex-parts/complex-part-power-system') or
        string.match(icon, 'resources_generated/elements/complex-parts/complex-part-processor') or
        string.match(icon, 'resources_generated/elements/exceptional-parts/exceptional-part-antigravity-core') or
        string.match(icon, 'resources_generated/elements/exceptional-parts/exceptional-part-anti-matter-core') or
        string.match(icon, 'resources_generated/elements/exceptional-parts/exceptional-part-quantum-alignment-unit') or
        string.match(icon, 'resources_generated/elements/exceptional-parts/exceptional-part-quantum-barrier') or
        string.match(icon, 'resources_generated/elements/functional-parts/functional-part-antenna') or
        string.match(icon, 'resources_generated/elements/functional-parts/functional-part-control-system') or
        string.match(icon, 'resources_generated/elements/functional-parts/functional-part-core-system') or
        string.match(icon, 'resources_generated/elements/functional-parts/functional-part-light') or
        string.match(icon, 'resources_generated/elements/functional-parts/functional-part-mechanical-sensor') or
        string.match(icon, 'resources_generated/elements/functional-parts/functional-part-motherboard') or
        string.match(icon, 'resources_generated/elements/functional-parts/functional-part-ore-scanner') or
        string.match(icon, 'resources_generated/elements/functional-parts/functional-part-power-convertor') or
        string.match(icon, 'resources_generated/elements/intermediary-parts/intermediary-part-component') or
        string.match(icon, 'resources_generated/elements/intermediary-parts/intermediary-part-connector') then

        return "Electronics"
    elseif
        -- Parts
        string.match(icon, 'resources_generated/elements/complex-parts/complex-part-igniter') or
        -- Materials
        string.match(icon, 'resources_generated/iconsLib/materialslib/Kergon') or
        string.match(icon, 'resources_generated/iconsLib/materialslib/Xeron') or
        string.match(icon, 'resources_generated/iconsLib/materialslib/Nitron') or
        string.match(icon, 'resources_generated/elements/products/product-biologic-matter') or
        string.match(icon, 'resources_generated/iconsLib/partslib/burner') or
        string.match(icon, 'resources_generated/elements/products/product-polymer') then

        return "Chemical"
    elseif
        -- Materials, these MUST be after Glass as the glass furnace can make some voxels as well
        string.match(icon, 'resources_generated/env/voxel/hc') or
        string.match(icon, 'resources_generated/iconsLib/materialslib') then

        return "Honeycomb"
    elseif
        -- Parts
        string.match(icon, 'resources_generated/elements') then

        return "Assembler"
    elseif
        -- World
        string.match(icon, 'resources_generated/env/voxel/worlds') or
        string.match(icon, 'resources_generated/env/voxel/ore') or
        string.match(icon, 'resources_generated/iconsLib/misclib') or
        string.match(icon, 'resources_generated/iconsLib/partslib/chassis') or -- things
        string.match(name, 'Deprecated') or
        string.match(icon, 'resources_generated/iconsLib/elementslib/missingmesh') then

        return "None"
    else
        DUSystem.print('UNKNOWN ITEM ' .. icon)
        return "UNKNOWN"
    end
end

function industryUtil.getMinTierIndustry(item)

    -- If null we assume its the same tier as the item
    local schem = item.schematics
    if schem == nil then
        return item.tier
    end

    local schemName = schem.displayNameWithSize
    if schemName == nil then
        return item.tier
    elseif string.match(schemName, 'Tier 1') then
        return 1
    elseif string.match(schemName, 'Tier 2') then
        return 1
    elseif string.match(schemName, 'Tier 3') then
        return 2
    elseif string.match(schemName, 'Tier 4') then
        return 3
    elseif string.match(schemName, 'Tier 5') then
        return 4
    else
        DUSystem.print('UNKNOWN TIER ' .. schemName)
        return -1
    end
end

-- Get the Industry needed to craft the Recipe.
function industryUtil.getIndustryFromRecipe(recipe)
    local itemOutput = industryUtil.getItemOutputFromRecipe(recipe)
    return industryUtil.getIndustryFromItem(itemOutput.item)
end

-- Get the primary item produced from the recipe. This will be the item and the amount produced
function industryUtil.getItemOutputFromRecipe(recipe)
    local output = recipe.products[1]
    return {item = industryUtil.getItemFromId(output.id), amount = output.quantity}
end

-- Get the primary item produced from the recipe. This will be the item and the amount produced
function industryUtil.getItemOutputFromRecipeId(recipeId)
    -- No idea why but need to convert it to a string...
    industryUtil.loadRecipes()
    return industryUtil.getItemOutputFromRecipe(industryUtil.recipes['' .. recipeId])
end

function industryUtil.getItemFromId(itemId)
    -- No idea why but need to convert it to a string...
    if industryUtil.items == nil then
        return DUSystem.getItem(itemId);
    end

    -- industryUtil.loadItems()
    return industryUtil.items['' .. itemId];
end

function industryUtil.getRecipesFromItemId(itemId)
    -- No idea why but need to convert it to a string...
    if industryUtil.recipes == nil then
        return DUSystem.getRecipes(itemId);
    end

    local recipes = {}
    for k,v in pairs(industryUtil.recipes) do
        local itemProdData = industryUtil.getItemOutputFromRecipe(v)

        if itemProdData.item.id == itemId then
            table.insert(recipes, v)
        end
    end

    return recipes;
end

function industryUtil.getRecipesFromItem(item)
    -- No idea why but need to convert it to a string...
    return industryUtil.getRecipesFromItemId(item.id);
end

function industryUtil.getItemsFromItemId(itemId, cofunction)
    return industryUtil.getItemsFromItemId(itemId, nil, cofunction)
end

function industryUtil.getItemsFromItemId(itemId, items, cofunction)

    local recipe = industryUtil.getRecipesFromItemId(itemId)[1]

    if recipe == nil then
        return nil
    end

    if items == nil then
        items = {}
    end

    for k,v in pairs(recipe.ingredients) do
        local key = '' .. v.id

        DUSystem.print('key start ' .. key)
        if items[key] == nil then
            items[key] = v.quantity
        else
            items[key] = items[key] + v.quantity
        end
        DUSystem.print('key done')
        if cofunction ~= nil then
            DUSystem.print('func start')
            cofunction()
            DUSystem.print('func done')
        else
            coroutine.yield()
        end
        industryUtil.getItemsFromItemId(v.id, items)
    end

    return items;
end

function industryUtil.getItemsFromItem(item, cofunction)
    return industryUtil.getItemsFromItem(item, nil, cofunction)
end

function industryUtil.getItemsFromItem(item, items)
    return industryUtil.getItemsFromItemId(item.id, items)
end

function industryUtil.loadItems()
    if industryUtil.items == nil then
        DUSystem.print("Loading Items Data")
        industryUtil.items = require 'autoconf.custom.shadow.items_api_dump'
    end

    return industryUtil.items
end

function industryUtil.loadRecipes()
    if industryUtil.recipes == nil then
        DUSystem.print("Loading Recipe Data")
        industryUtil.recipes = require 'autoconf.custom.shadow.recipes_api_dump'
    end

    return industryUtil.recipes
end

return industryUtil