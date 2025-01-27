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

local scaledraw = require("enginelib.scaledraw")

local Object = require("class.engine.Object")
local Node = require("class.engine.Node")
local Node2d = require("class.engine.Node2d")
local Viewport = require("class.engine.Viewport")
local PhysicsWorld = require("class.engine.PhysicsWorld")
local PackedScene = require("class.engine.resource.PackedScene")

local SceneTree = Object:subclass("SceneTree")
SceneTree:define_get_set("debug_draw_physics")
SceneTree:define_get_set("is_editor")

function SceneTree:initialize()
    Object.initialize(self)
    -- Scenetree can only have 1 root node
    self.root = Node()
    self.root:set_name("root")
    self.current_scene = nil
    
    self.viewport = Viewport(800, 600)
    self.physics_world = PhysicsWorld()
    self.debug_draw_physics = false
    self.is_editor = false

    self.root:_set_tree(self)
end

function SceneTree:create_autoload_scenes()
    -- Create autoloads
    for _, path in ipairs(settings.get_setting("autoload_scenes")) do
        local as = resource.get_resource( path )
        assert(as, ("Failed to get autoload %s"):format(path))
        assert(as:isInstanceOf(PackedScene), ("Invalid autoload %s"):format(path) )
        
        local instance = as:instance()
        
        self.root:add_child( instance )
    end
end

function SceneTree:get_physics_world()
    return self.physics_world
end

function SceneTree:set_current_scene(scene)
    if self.current_scene then
        self.root:remove_child(self.current_scene)
    end
    
    self.current_scene = scene
    
    if self.current_scene then
        self.root:add_child(self.current_scene)
    end    
end

function SceneTree:get_current_scene()
    return self.current_scene
end

function SceneTree:get_root()
    return self.root
end

-- Sets how canvas contents are upscaled to the screen.
-- Uses the same options as enginelib.scaledraw.
function SceneTree:set_scale_mode(mode)
    self.scale_mode = mode
end

function SceneTree:get_viewport()
    return self.viewport
end

function SceneTree:update(dt)
    for _, node in ipairs(self:_traverse()) do
        if node:get_tree() == self then
            node:event("update", dt)
        end
    end
    
    for _, node in ipairs(self:_traverse()) do
        if node:get_tree() == self then
            node:event("physics_update", dt)
        end
    end
    
    self.physics_world:physics_update(dt)
end

function SceneTree:editor_update(dt)
    for _,node in ipairs(self:_traverse()) do
        node:event("editor_update", dt)
    end
end


-- Iterates over root node in preorder
-- Ex
--[[
-- 1
--  2
--   3
--    4
--    5
--  6
--   7
--  8
]]--
function SceneTree:_traverse()
    
    local stack = {self.root}
    local nodes = {}
    
    while (#stack > 0) do
        local top = table.remove(stack)
        
        table.insert(nodes, top)
        local children = top:get_children()
        for i = #children, 1, -1 do
            table.insert(stack, children[i])
        end
    end
    
    return nodes
end

-- Iterates in reverse preorder
--[[
-- 8
--  7
--   6
--    5
--    4
--  3
--   2
--  1
]]--
function SceneTree:_traverse_reverse()
    local nodes = self:_traverse()
    local n = #nodes
    
    for i = 1, n / 2 do
        local tmp = nodes[i]
        nodes[i] = nodes[n - i + 1]
        nodes[n - i + 1] = tmp
    end
    
    return nodes
end

function SceneTree:render()
    self.viewport:set()
    self.viewport:clear()
        
    local stack = {self.root}
    
    for _,node in ipairs(self:_traverse()) do
        if node:get_visible() and node:get_tree() == self then
            node:event("draw")
        end
    end
    
    if self.debug_draw_physics then
        self.physics_world:debug_draw()
    end
        
    self.viewport:unset()
end

function SceneTree:draw()
    self:render()
    self.viewport:draw()
end

-- Event callbacks are all passed in reverse preorder

function SceneTree:mousepressed(x, y, button, isTouch)
    x, y = self.viewport:transform_to_screen(vec2(x, y)):unpack()
    for _,node in ipairs(self:_traverse()) do
        if node:get_tree() == self then
            node:event("mousepressed", x,y,button,isTouch)
        end
    end
end

function SceneTree:mousereleased(x, y, button, isTouch)
    x, y = self.viewport:transform_to_screen(vec2(x, y)):unpack()
    for _,node in ipairs(self:_traverse()) do
        if node:get_tree() == self then
            node:event("mousereleased", x, y, button, isTouch)
        end
    end
end

function SceneTree:mousemoved(x, y, dx, dy, isTouch)
    x, y = self.viewport:transform_to_screen(vec2(x, y)):unpack()
    dx, dy = (self.viewport:transform_to_screen(vec2(dx, dy)) 
              - self.viewport:transform_to_screen(vec2.zero)):unpack()
    for _,node in ipairs(self:_traverse()) do
        if node:get_tree() == self then
            node:event("mousemoved", x, y, dx, dy, isTouch)
        end
    end
end

for _, callback in ipairs({
    "textinput",
    "keypressed",
    "keyreleased",
    "joystickpressed",
    "joystickreleased",
    "joystickaxis",
    "joystickhat",
    "wheelmoved"
}) do
    SceneTree[callback] = function(self, ...)
        for _,node in ipairs(self:_traverse()) do
            if node:get_tree() == self then
                node:event(callback, ...)
            end
        end
    end
end

return SceneTree