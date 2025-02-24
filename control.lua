--- Splits by delimiter
--- @param to_split string
--- @param delimiter string
--- @return string[]
function string.split(to_split, delimiter)
    if string.find(to_split, delimiter) ~= 0 then
        local splitted = {}
        for split in string.gmatch(to_split, "([^" .. delimiter .. "]+)") do
            table.insert(splitted, split)
        end
        return splitted
    end
    return {to_split}
end

local done = false

local function call_remote()
    if done then return end
    for name, _ in pairs(prototypes.item) do
        if string.sub(name, 1, 10) == "spoildown-" then
            local items = string.sub(name, 11, #name)
            -- log(serpent.block(items))
            local item_names = string.split(items, "___")
            local result_table = {}
            -- log(serpent.block(result_table))
            item_name = table.remove(item_names, 1)
            for _, result_name in pairs(item_names) do
                table.insert(result_table, {name = result_name})
            end
            remote.call("rsl_registry", "register_rsl_definition", item_name, { -- You call the "rsl_registry" to use "register_rsl_definition" and pass it the name of your custom item "mutation-a"
                mode = {random = true, conditional = false, weighted = false},
                condition = true,
                possible_results = {
                    [true] = result_table
                }
            }
            )
        end
    end
    done = true
end

script.on_event(defines.events.on_tick, call_remote)


-- script.on_init(
--     call_remote()
-- )

-- script.on_configuration_changed(
--     call_remote()
-- )
