--[[

MIT License

Copyright (c) 2020 DekuJuice

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

]]--

-- This module helps manage global settings

local module = {}
local settings = {}
local validators = {}

-- Helpers to verify validity of settings values
local function is_real(n)
    return type(n) == "number" and n > -math.huge and n < math.huge
end

local function is_in_range(n, min, max)
    return type(n) == "number" and n >= min and n <= max
end

local function is_int(n)
    return type(n) == "number" and n % 1 == 0
end

local function is_boolean(b)
    return type(b) == "boolean"
end

local function is_member(s, values)
    for _,v in ipairs(values) do
        if s == v then
            return true
        end
    end
    
    return false
end

local function is_greater(a, b)
    return a > b
end

local function is_greater_equal(a, b)
    return a >= b
end

local function is_less(a, b)
    return a < b
end

local function is_less_equal(a, b)
    return a <= b
end

local function is_string(a)
    return type(a) == "string"
end

local function is_table(a)
    return type(a) == "table"
end

-- Special validator to indicate read only settings
local function read_only(a)
    return false
end

local function curry(f, ...)
    local a = {...} -- hack needed since we can't pass ... directly
    return function(v)
        return f(v, unpack(a))
    end
end

local function check_table(t, func)
    for k,v in pairs(t) do
        if not func(v) then
            return false
        end
    end
    
    return true
end

local function define_setting(name, default, funcs)
    settings[name] = default
    validators[name] = funcs
end

-- Project settings and constants, mostly read_only
define_setting("config_file", "config.txt", {read_only})
define_setting("asset_dir", "assets", {read_only})
define_setting("scene_dir", "scene", {read_only})
define_setting("backup_ext", "bak", {read_only})
define_setting("import_ext", "import", {read_only})
define_setting("title", "Sky Torus", {read_only})
define_setting("icon", nil, {read_only})
define_setting("is_debug", false, {is_boolean})
define_setting("is_editor", false, {is_boolean})
define_setting("game_width", 800, {is_int, is_real, curry(is_greater, 0)})
define_setting("game_height", 600, {is_int, is_real, curry(is_greater, 0)})
define_setting("main_scene", "scene/title.scene", {read_only})
define_setting("autoload_scenes", {}, {read_only})

define_setting("collision_layer_0_name", "world", {read_only})
define_setting("collision_layer_1_name", "player", {read_only})
define_setting("collision_layer_2_name", "enemy", {read_only})
define_setting("collision_layer_3_name", "", {read_only})
define_setting("collision_layer_4_name", "", {read_only})
define_setting("collision_layer_5_name", "", {read_only})
define_setting("collision_layer_6_name", "", {read_only})
define_setting("collision_layer_7_name", "", {read_only})
define_setting("collision_layer_8_name", "", {read_only})
define_setting("collision_layer_9_name", "", {read_only})
define_setting("collision_layer_10_name", "", {read_only})
define_setting("collision_layer_11_name", "", {read_only})
define_setting("collision_layer_12_name", "", {read_only})
define_setting("collision_layer_13_name", "", {read_only})
define_setting("collision_layer_14_name", "", {read_only})
define_setting("collision_layer_15_name", "", {read_only})
define_setting("physics_gravity", 900, {read_only})

define_setting("grid_minor_x", 16, {read_only})
define_setting("grid_minor_y", 16, {read_only})
define_setting("grid_major_x", 800, {read_only})
define_setting("grid_major_y", 600, {read_only})

define_setting("max_loop", 500, {read_only})
define_setting("max_accum", 5, {read_only})
define_setting("frame_time", 1/60, {read_only})

-- Window settings
define_setting("window_width", 800, {is_int, is_real, curry(is_greater, 0)})
define_setting("window_height", 600, {is_int, is_real, curry(is_greater, 0)})
define_setting("window_x", nil, {is_int, is_real})
define_setting("window_y", nil, {is_int, is_real})
define_setting("centered", true, {is_boolean})

define_setting("upscale_mode", "aspect", {curry(is_member, {"perfect", "free", "aspect"})})
define_setting("fullscreen", false, {is_boolean})
define_setting("fullscreen_type", "desktop", {curry(is_member, {"desktop", "exclusive"})})
define_setting("borderless", false, {is_boolean})
define_setting("resizable", true, {is_boolean})
define_setting("vsync", 0, {is_int, curry(is_in_range, 0, 2)})
define_setting("msaa", 0, {is_int, is_real, curry(is_greater_equal, 0)})
define_setting("depth", 0, {is_int, is_real, curry(is_greater_equal, 0)})
define_setting("stencil", true, {is_boolean})
define_setting("display", 1, {is_int, curry(is_greater_equal, 1)})
define_setting("hidpi", false, {is_boolean})
define_setting("usedpiscale", true, {is_boolean})

-- Game specific settings
define_setting("master_volume", 70, {is_int, curry(is_in_range, 0, 100)})
define_setting("music_volume", 70, {is_int, curry(is_in_range, 0, 100)})
define_setting("sfx_volume", 70, {is_int, curry(is_in_range, 0, 100)})

function module.get_setting(key)
    return settings[key]
end

function module.set_setting(key, val)
    if settings[key] == nil then return end
    for _,v in ipairs(validators[key]) do
        if not v(val) then
            return false
        end
    end
    
    settings[key] = val
    
    return true
end

return module