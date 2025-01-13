if mods["space-age"] and settings.startup["planetside-crusher"] then
    local bad_crusher = table.deepcopy(data.raw["assembling-machine"]["crusher"])
    bad_crusher.name = "bad-crusher"
    bad_crusher.crafting_speed = bad_crusher.crafting_speed / 3.0
    bad_crusher.energy_usage = "4MW"
    bad_crusher.surface_conditions = {{
      property = "gravity",
      min = 1,
    }}
    bad_crusher.enabled = true

    local bad_crusher_item = table.deepcopy(data.raw["item"]["crusher"])
    bad_crusher_item.name = "bad-crusher"
    bad_crusher.localised_name = {"", "Bad ", {"item-name.crusher"}}
    bad_crusher.localised_description = {"item-description.crusher"}
    bad_crusher_item.place_result = "bad-crusher"

    local bad_crusher_recipe = table.deepcopy(data.raw["recipe"]["crusher"])
    bad_crusher_recipe.name = "bad-crusher"
    bad_crusher_recipe.localised_name = {"", "Bad ", {"item-name.crusher"}}
    bad_crusher_recipe.localised_description = {"item-description.crusher"}
    bad_crusher_recipe.enabled = true
    bad_crusher_recipe.ingredients = {
        {
            type = "item",
            name = "steel-plate",
            amount = 10
        },
        {
            type = "item",
            name = "electronic-circuit",
            amount = 10
        },
        {
            type = "item",
            name = "pipe",
            amount = 20
        }
    }
    bad_crusher_recipe.results = {
        {
            type = "item",
            name = "bad-crusher",
            amount = 1
        }
    }

    local new_crushing_recipes = {}
    local included_recipes = {
        "metallic-asteroid-crushing",
        "carbonic-asteroid-crushing",
        "oxide-asteroid-crushing"
    }   
    
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.category == "crushing" and (included_recipes[1] == recipe.name or included_recipes[2] == recipe.name or included_recipes[3] == recipe.name) then
            local new_recipe = table.deepcopy(recipe)
            new_recipe.results = {
                {
                    type = "item",
                    name = recipe.results[1].name,
                    amount = 1,
                    probability = 0.99
                },
            }
            new_recipe.name = "bad-" .. recipe.name
            new_recipe.localised_name = {"", "Bad ", {"recipe-name." .. recipe.name}}
            new_recipe.localised_description = {"recipe-description." .. recipe.name}
            new_recipe.enabled = true
            table.insert(new_crushing_recipes, new_recipe)
        end
    end

    data:extend(new_crushing_recipes)
    
    data:extend{
        bad_crusher,
        bad_crusher_item,
        bad_crusher_recipe
    }
end
