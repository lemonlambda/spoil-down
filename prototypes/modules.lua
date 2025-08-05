local helper = require("prototypes.helper")

local function try_make_module_spoil(name, result)
    if (data.raw["module"][name] == nil and data.raw["module"][result] == nil) or data.raw["module"][name] == nil then
        return
    end

    data.raw["module"][name].spoil_ticks = 60 * 60 * 60 * 8
    if type(result) == "string" then
        data.raw["module"][name].spoil_result = result
    else
        helper.create_spoilable_item(data.raw["module"][name], result)
    end
end

try_make_module_spoil("speed-module", data.raw["recipe"]["speed-module"].ingredients)
try_make_module_spoil("speed-module-2", "speed-module")
try_make_module_spoil("speed-module-3", "speed-module-2")
try_make_module_spoil("productivity-module", data.raw["recipe"]["productivity-module"].ingredients)
try_make_module_spoil("productivity-module-2", "productivity-module")
try_make_module_spoil("productivity-module-3", "productivity-module-2")
try_make_module_spoil("efficiency-module", data.raw["recipe"]["efficiency-module"].ingredients)
try_make_module_spoil("efficiency-module-2", "efficiency-module")
try_make_module_spoil("efficiency-module-3", "efficiency-module-2")
try_make_module_spoil("quality-module", {"advanced-circuit", "electronic-circuit"})
try_make_module_spoil("quality-module-2", "quality-module")
try_make_module_spoil("quality-module-3", "quality-module-2")
