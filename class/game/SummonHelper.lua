local Node = require("class.engine.Node2d")

local SummonHelper = Node:subclass("SummonHelper")

function SummonHelper:initialize( enemy, delay  )
    Node.initialize(self)
    self.time = delay
    self.enemy = enemy
end

function SummonHelper:ready()
    local anim = resource.get_resource("scene/summonanimation.scene"):instance()
    anim:set_global_position(self.enemy:get_global_position())

    self:get_tree():get_current_scene():add_child(anim)
end

function SummonHelper:update(dt)
    self.time = self.time - dt
    if self.time <= 0 then
        self:get_tree():get_current_scene():add_child(self.enemy)
        self:get_parent():remove_child(self)
    end
end

return SummonHelper

