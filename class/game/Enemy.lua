local explosion = resource.get_resource("scene/explosion.scene")

local Area = require("class.engine.Area")
local Enemy = Area:subclass("Enemy")
local Bullet = require("class.game.Bullet")
local AudioPlayer = require("class.engine.AudioPlayer")
local Coroutine = require("class.game.Coroutine")
local easing = require("enginelib.easing")

Enemy:export_var("max_health", "int")
Enemy:export_var("shot_size", "int")
Enemy:export_var("shot_speed", "int")
Enemy:export_var("shot_loops", "int")
Enemy:export_var("score", "int")

Enemy:define_get_set("script")
Enemy:define_signal("on_death")

function Enemy:initialize()
    Area.initialize(self)
    self.max_health = 2
    self.health = 2
    self.shot_size = 10
    self.shot_speed = 400
    self.shot_loops = 1
    self.score = 200
    
    self:set_collision_layer(2)
    self:set_collision_mask(3)
    
    self.movement_queue = {}
    self.move_co = Coroutine(loadstring([[
        
        while true do
            local dt = coroutine.yield()
            local mv = table.remove(self.movement_queue, 1)
            if mv then
                local begin = self:get_global_position()
                local t = 0
                while self:get_global_position() ~= mv.point do
                    t = t + dt
                    local np = easing[mv.ease](t, begin, mv.point - begin, mv.time)
                    self:set_global_position(np)
                    self:update_physics_position()
                    dt = coroutine.yield()
                end
            end
        end
        
    ]]), {self = self, easing = easing})
end

function Enemy:enter_tree()
    Area.enter_tree(self)
    self.health = self.max_health
    self:connect("area_entered", self, "bullet_hit")
end

function Enemy:set_script(script)
    self.script = Coroutine(loadstring(script), {self = self})
end

function Enemy:physics_update(dt)
    
    if self.script then self.script:update(dt) end
    if not self:get_tree() then return end
    self.move_co:update(dt)

end

function Enemy:queue_move(point, time, ease)
    table.insert(self.movement_queue, 
    {
        ease = ease or "linear",
        point = point,
        time = time
    })
end

function Enemy:get_angle_to_player()
    local player = self:get_node("/root/GameManager/Player")
    if not player then return nil end
    
    local ppos = player:get_global_position()
    local a = (ppos - self:get_global_position()):angle_to(vec2.unit_x)
    return a
end

function Enemy:fire_bullet(size, angle, velocity, loops, offset)

    size = size or self.shot_size
    velocity = velocity or self.shot_speed
    loops = loops or self.shot_loops
    offset = offset or vec2.zero

    local b = Bullet()
    
    b:set_collision_layer(0)
    b:set_global_position(self:get_global_position() + offset)
    b:set_aabb_extents(vec2(size, size))
    b:set_velocity(vec2.unit_x:rotate(angle) * velocity) 
    b:set_loops(loops)
    
    self:get_tree():get_current_scene():add_child(b)
end

function Enemy:fire_bullet_at_player(size, offset, velocity, loops)
    offset = offset or 0
    local a = self:get_angle_to_player()
    
    if not a then return end
    
    self:fire_bullet(size, a + offset, velocity, loops)
end

function Enemy:remove()
    self:get_parent():remove_child(self)
end

function Enemy:deal_damage(dmg, suppress_sound)
    self.health = self.health - dmg
    if self.health <= 0 then
        if not suppress_sound then
            local death_sound = AudioPlayer()
            death_sound:set_source(resource.get_resource("assets/sound/explode.ogg"))
            death_sound:set_volume(0.5)
            death_sound:set_autoplay(true)
            death_sound:set_autoremove(true)
            
            self:get_tree():get_current_scene():add_child(death_sound)
        end
        
        local exp = explosion:instance() 
        exp:set_global_position(self:get_global_position())
        self:emit_signal("on_death", self)
        self:get_tree():get_current_scene():add_child( exp )  
        self:remove()
        self.dead = true
    end
end

function Enemy:bullet_hit(bullet)
    if not bullet:isInstanceOf(Bullet) then return end
    if self.dead then return end
        
    bullet:remove()
    self:deal_damage(1)
end

function Enemy:play_fire_sound(path)
    path = path or "assets/sound/shoot2.ogg"
    local ap = AudioPlayer()
    ap:set_source(resource.get_resource(path))
    ap:set_autoplay(true)
    ap:set_autoremove(true)
    self:get_tree():get_root():add_child(ap)
end

function Enemy:draw()
    
    if self.max_health < 10 then
        local rmin, rmax = self:get_bounding_box()
        
        love.graphics.push("all")
        love.graphics.setColor(1, 0, 0, 0.5)
        
        love.graphics.rectangle("fill", rmin.x, rmin.y - 8, (rmax.x - rmin.x) * (self.health / self.max_health), 5) 
        love.graphics.pop()
    end
    
    
end

return Enemy