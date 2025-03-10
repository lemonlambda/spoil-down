local helper = require("prototypes.helper")
local function try_make_science_spoil(name, result)
    if (data.raw["tool"][name] == nil and data.raw["tool"][result] == nil) or data.raw["tool"][name] == nil then
        return
    end

    data.raw["tool"][name].spoil_ticks = 60 * 60 * 60 * 2
    if type(result) == "string" then
        data.raw["tool"][name].spoil_result = result
    else
        helper.create_spoilable_item(data.raw["tool"][name], result)
    end
end

try_make_science_spoil("automation-science-pack", {"copper-plate", "iron-gear-wheel"})
try_make_science_spoil("logistic-science-pack", "automation-science-pack")
try_make_science_spoil("military-science-pack", "automation-science-pack")
try_make_science_spoil("chemical-science-pack", "logistic-science-pack")
try_make_science_spoil("production-science-pack", "chemical-science-pack")
try_make_science_spoil("utility-science-pack", "chemical-science-pack")
try_make_science_spoil("space-science-pack", {"utility-science-pack", "production-science-pack"})
try_make_science_spoil("metallurgic-science-pack", "space-science-pack")
try_make_science_spoil("electromagnetic-science-pack", "space-science-pack")
try_make_science_spoil("agricultural-science-pack", "space-science-pack")
try_make_science_spoil("cryogenic-science-pack", {"metallurgic-science-pack", "electromagnetic-science-pack", "agricultural-science-pack"})
try_make_science_spoil("promethium-science-pack", "cryogenic-science-pack")
