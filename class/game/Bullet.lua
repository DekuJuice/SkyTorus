local glow_img = resource.get_resource("assets/images/bulletglow.png")
local Area = require("class.engine.Area")
local Bullet = Area:subclass("Bullet")
Bullet:include(require("class.game.mixin.VelocityHelper"))

Bullet:export_var("loops", "int")

local loop_color = {
    { 0.168, 0.8, 0.156 },
    { 0.172, 0.545, 0.764 },
    { 0.513, 0.254, 0.764 },
    { 0.741, 0.254, 0.764 },
    { 0.760, 0, 0.027}
}

function Bullet:initialize()
    Area.initialize(self)
    self.loops = 0
    self.velocity = vec2(0, 0)
    self.velocity_remainder = vec2(0, 0)
    self.friendly_fire_immunity = false
end

function Bullet:remove()
    self:get_parent():remove_child(self)
end

function Bullet:set_velocity(velocity)
    self.velocity = velocity:clone()
end

function Bullet:physics_update(dt)
    local tree = self:get_tree()
    local view = tree:get_viewport()

    self:translate( self:get_velocity_delta(dt) )
    
    local bmin, bmax = view:get_bounds()
    local sw, sh = view:get_resolution()
    local rmin, rmax = self:get_bounding_box()
    
    if rmax.y < bmin.y then
        self:translate( vec2(0, sh) )
        self.loops = self.loops - 1
        self.friendly_fire_immunity = false
    elseif rmin.y > bmax.y then
        self:translate( vec2(0, -sh) )
        self.loops = self.loops - 1
        self.friendly_fire_immunity = false
    end
    
    if rmax.x < bmin.x then
        self:translate( vec2(sw, 0) )
        self.loops = self.loops - 1        
        self.friendly_fire_immunity = false
    elseif rmin.x > bmax.x then
        self:translate( vec2(-sw, 0) )
        self.loops = self.loops - 1
        self.friendly_fire_immunity = false
    end
    
    if self.loops < 0 then
        self:get_parent():remove_child(self)
        return
    end
    
    self:update_physics_position()
end

function Bullet:draw()
    local bulletcolor
    if self.loops == 0 then
        bulletcolor = loop_color[1]
    elseif self.loops == math.huge then
        bulletcolor = loop_color[5]
    elseif self.loops >= 3 then
        bulletcolor = loop_color[4]
    else
        bulletcolor = loop_color[self.loops + 1]
    end
    
    local gpos = self:get_global_position()
    local extents = self:get_aabb_extents()
    love.graphics.push("all")
    love.graphics.setColor(unpack(bulletcolor))

    love.graphics.ellipse("fill", gpos.x, gpos.y, extents.x*1.1, extents.y*1.1)
    
    local loveimg = glow_img:get_love_image()
    local iw, ih = loveimg:getDimensions()
    love.graphics.setBlendMode("add")
    love.graphics.setColor(1,1,1)

    love.graphics.draw(loveimg, gpos.x, gpos.y, 0,  extents.x / iw * 2, extents.y / ih * 2, iw / 2, ih / 2)
    
    love.graphics.pop()
end

return Bullet