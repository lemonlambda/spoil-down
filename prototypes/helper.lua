local multispoil = require("__multispoil__.api")
local helper = {
    default_spoil_ticks = 30 * 60
}

local caching_get_spoil_ticks = {}
local caching_get_complexity = {}

function helper.in_table(table, value)
    for _, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

function helper.get_best_recipe(item_name)
    local recipe = helper.get_recipe(item_name)

    if recipe == {} then
        return {}
    end

    local best_option = {}
    -- Pick the best recipe based on what has the most spoilage or the most ingredients
    for _, r in pairs(recipe) do
        if r.ingredients == nil then
            goto recipe_continue
        end

        if r.category == "recycling" then
            goto recipe_continue
        end

        if #r.ingredients >= 1 then
            local all_fluid = true
            for _, v in pairs(r.ingredients) do
                if v.type == "item" then
                    all_fluid = false
                    break
                end
            end

            if all_fluid then
                goto recipe_continue
            end
        end

        if best_option == nil then
            best_option = r
            goto recipe_continue
        end

        -- We hate fluids don't we :) (they can't spoil)
        if helper.get_spoil_ticks(best_option) < helper.get_spoil_ticks(r) or #helper.remove_fluid_ingredients(best_option.ingredients) < #helper.remove_fluid_ingredients(r.ingredients) then
            best_option = r
        end

        ::recipe_continue::
    end
    return best_option
end

-- Excluded recipe categories because they're from a silly mod most likely
local excluded_recipe_categories = {
    "voidcrafting",
    "voidcrafting-inverse",
}

function helper.get_recipe_complexity(recipe, params)
    if helper.in_table(caching_get_complexity, recipe.name) then
        return caching_get_complexity[recipe.name]
    end
    if recipe.category == "recycling" then
        caching_get_complexity[recipe.name] = 0
        return 0
    end
    if helper.in_table(excluded_recipe_categories, recipe.category) then
        caching_get_complexity[recipe.name] = 0
        return 0
    end
    -- Fixes https://mods.factorio.com/mod/spoil-down/discussion/6735ae6d7e0796de0c1bd43f
    if recipe.ingredients == nil or recipe.ingredients == {} then
        caching_get_complexity[recipe.name] = 1
        return 1
    end

    local complexity = 1

    params = params or {
        iter = 0
    }
    params.ignore_item = params.ignore_item or {}
    params.ignore_recipe = params.ignore_recipe or {}

    table.insert(params.ignore_recipe, recipe.name)

    log(recipe.name .. " -> " .. serpent.line(params.ignore_item))

    for _, ingredient in pairs(recipe.ingredients) do
        if helper.in_table(params.ignore_item, ingredient.name) then
            goto continue
        end

        table.insert(params.ignore_item, ingredient.name)

        if ingredient.type == "fluid" then
            complexity = complexity + 2
        end
        if ingredient.type == "item" then
            complexity = complexity + 1
        end

        for _, ingredient_recipe in pairs(helper.get_recipe(ingredient.name)) do
            if not helper.in_table(params.ignore_recipe, ingredient_recipe.name) then
                complexity = complexity + helper.get_recipe_complexity(ingredient_recipe, params)
            end
        end
        ::continue::
    end

    caching_get_complexity[recipe.name] = complexity

    return complexity
end

function helper.get_spoil_ticks(recipe)
    if helper.in_table(caching_get_spoil_ticks, recipe.name) then
        return caching_get_spoil_ticks[recipe.name]
    end

    if recipe.ingredients == nil or recipe.results == nil then
        return helper.default_spoil_ticks
    end

    local spoil_ticks = 20 * 60 * helper.get_recipe_complexity(recipe, {})

    caching_get_spoil_ticks[recipe.name] = spoil_ticks
    return spoil_ticks
end

function helper.remove_fluid_ingredients(ingredients)
    local ingreds = {}

    if ingredients ~= {} and ingredients ~= nil then
        for _, ingredient in pairs(ingredients) do
            if ingredient.type == "item" then
                table.insert(ingreds, ingredient)
            end
        end
    end

    return ingreds
end

-- Gets the recipes of an an item
-- SUPER SLOW
function helper.get_recipe(item_name)
    local recipes = {}

    for name, recipe in pairs(data.raw["recipe"]) do
        if recipe.results == nil then
            goto continue
        end
        if #recipe.results == 0 then
            goto continue
        end

        for _, result in pairs(recipe.results) do
            if result.name == item_name then
                table.insert(recipes, recipe)
            end
        end

        ::continue::
    end

    return recipes
end

---@param item data.ItemPrototype
---@param results data.ItemID[]
function helper.create_spoilable_item(item, results)
    local converted_results = {}
    for _, result in pairs(results) do
        if result.name then
            converted_results[result.name] = result.amount or 1
        else
            converted_results[result] = 1
        end
    end
    
    item.spoil_to_trigger_result = multispoil.create_spoil_trigger(converted_results)
end

return helper
