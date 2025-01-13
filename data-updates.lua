require("prototypes.modules")
require("prototypes.science")
require("prototypes.planetside_crusher")
local multispoil = require("__multispoil__.api")

local helper = require("prototypes.helper")

if feature_flags["spoiling"] == false then
    error("This mod requires Space Age to work")
end

for name,item in pairs(data.raw["item"]) do
    if item.spoil_ticks ~= nil or item.spoil_result ~= nil or item.spoil_to_trigger_result ~= nil then
        goto continue
    end

    local recipes = helper.get_recipe(name)

    if recipes == {} then
        goto continue
    end

    local recipe = helper.get_best_recipe(name)

    if recipe.ingredients == nil or recipe.results == nil then
        item.spoil_ticks = helper.default_spoil_ticks
        goto continue
    end

    log(name .. " -> " .. (function (ingredients)
        local names = ""

        for k,v in pairs(helper.remove_fluid_ingredients(ingredients)) do
            if names == "" then
                names = v.name
            else
                names = names .. " " .. v.name
            end
        end

        return names
    end)(recipe.ingredients))

    if #recipe.ingredients == 1 and recipe.ingredients[1].type == "fluid" then
        goto continue
    end

    item.spoil_ticks = helper.get_spoil_ticks(recipe)

    if not settings.startup["hard-mode"] then
        item.spoil_ticks = item.spoil_ticks * 5
    end

    local ingredient_no_fluid = helper.remove_fluid_ingredients(recipe.ingredients)

    if #ingredient_no_fluid == 1 then
        item.spoil_result = ingredient_no_fluid[1].name
    else
        local items = {}

        for _,ingredient in pairs(ingredient_no_fluid) do
            table.insert(items, ingredient.name)
        end

        item.spoil_to_trigger_result = multispoil.create_spoil_trigger(items)
    end

    ::continue::
end
