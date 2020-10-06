local Node2d = require("class.engine.Node2d")
local AimLaser = Node2d:subclass("AimLaser")

AimLaser:define_get_set("angle")
AimLaser:define_get_set("loops")

function AimLaser:initialize()
    Node2d.initialize(self)
    self.angle = 0
    self.loops = 0
end

local function line_ray_intersect(q1, q2, p, theta)
    local r = vec2(math.cos(theta), math.sin(theta))
    local s = q2 - q1
    
    local c1 = r:cross(s)
    local c2 = (q1 - p):cross(r) 
    if c1 == 0 and c2 == 0 then
        return nil
    elseif c1 == 0 and c2 ~= 0 then
        return nil
    elseif c1 ~= 0 then
        local u = c2 / c1
        if u >= 0 and u <= 1 then
            local t = (q1 - p):cross(s) / c1
            if t > 0 then
                return q1 + s * u
            end
        end
    end

    return nil    
end

local function draw_laser(origin, angle, rmin, rmax, loops)
    if loops < 0 then return end
    
    
    local dir = vec2.unit_x:rotate(angle)
    local perp = dir:perpendicular()
    
    local p1 = rmin
    local p2 = vec2(rmax.x, rmin.y)
    local p3 = rmax
    local p4 = vec2(rmin.x, rmax.y)
    
    local s1 = line_ray_intersect(p1, p2, origin, angle)
    local s2 = line_ray_intersect(p2, p3, origin, angle)
    local s3 = line_ray_intersect(p3, p4, origin, angle)
    local s4 = line_ray_intersect(p4, p1, origin, angle)
    
    local dim = rmax - rmin

    love.graphics.setLineWidth((loops + 1) * 1.7)
    
    if s1 then
        love.graphics.line(origin.x, origin.y, (s1 + dir:scale(50)):unpack() )
        draw_laser(s1 + vec2(0, dim.y), angle, rmin, rmax, loops - 1) 
        
    elseif s2 then
        love.graphics.line(origin.x, origin.y, (s2 + dir:scale(50)):unpack() )
        draw_laser(s2 - vec2(dim.x, 0), angle, rmin, rmax, loops - 1) 
    
    elseif s3 then
        love.graphics.line(origin.x, origin.y, (s3 + dir:scale(50)):unpack() )
        draw_laser(s3 - vec2(0, dim.y), angle, rmin, rmax, loops - 1) 
    
    elseif s4 then
        love.graphics.line(origin.x, origin.y, (s4 + dir:scale(50)):unpack() )
        draw_laser(s4 + vec2(dim.x, 0), angle, rmin, rmax, loops - 1) 
    
    end
    
    
    

end

function AimLaser:draw()
    local gp = self:get_global_position()
    local view = self:get_tree():get_viewport()
    local rmin, rmax = view:get_bounds()
    love.graphics.push("all")
    love.graphics.setColor(1, 0, 0, 0.4)
    
    draw_laser(gp, self.angle, rmin, rmax, self.loops)
    
    love.graphics.pop()
    
    



end

return AimLaser