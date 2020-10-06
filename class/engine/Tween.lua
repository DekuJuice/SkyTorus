local easing = require("enginelib.easing")

local Node = require("class.engine.Node")
local Tween = Node:subclass("Tween")
Tween:define_signal("on_finish")

Tween:define_get_set("target")
Tween:define_get_set("property")
Tween:define_get_set("target_value")
Tween:define_get_set("method")
Tween:define_get_set("duration")
Tween:define_get_set("autoremove")

function Tween:initialize()
    Node.initialize(self)
    
    self.target = ""
    self.property = ""
    self.target_value = nil
    self.method = "linear"
    self.duration = 0
    self.time = 0
    self.playing = false
    self.autoremove = true
end

function Tween:ready()
    local tnode = self:get_node(self.target)
    if tnode then
        self.playing = true
        self.initial_value = tnode[("get_%s"):format(self.property)](tnode)        
    end
end

function Tween:update(dt)
    
    if not self.playing then return end
    local tnode = self:get_node(self.target)
    if not tnode then return end

    self.time = self.time + dt

    local new_val = easing[self.method](self.time, self.initial_value, (self.target_value - self.initial_value), self.duration )
    tnode[("set_%s"):format(self.property)](tnode, new_val)
    if self.time > self.duration then
        self.playing = false
        self:emit_signal("on_finish")
        if self.autoremove then
            self:get_parent():remove_child(self)
        end
    end
end

return Tween