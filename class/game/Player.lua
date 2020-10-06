
local Bullet = require("class.game.Bullet")
local Area = require("class.engine.Area")
local Node2d = require("class.engine.Node2d")
local Player = Area:subclass("Player")
local Color = require("class.engine.Color")
local AudioPlayer = require("class.engine.AudioPlayer")
local Enemy = require("class.game.Enemy")

local stand_img = resource.get_resource("assets/images/player/stand.png")
local shoot_img = resource.get_resource("assets/images/player/shoot.png")

Player:include(require("class.game.mixin.VelocityHelper"))

Player:export_var("move_speed", "int")
Player:export_var("fire_interval", "float")
Player:export_var("bullet_size", "int")
Player:export_var("bullet_velocity", "int")
Player:export_var("bullet_offset", "vec2_int")
Player:export_var("bullet_loops", "int")
Player:export_var("hit_invuln", "float")

-- stupid hack to get hitbox drawn ontop of player sprite because proper sprite ordering
-- isn't implemented yet
local HitboxDraw = Node2d:subclass("HitboxDraw")
HitboxDraw.static.dontlist = true

function HitboxDraw:draw()
    local parent = self:get_parent()
    local rmin, rmax = parent:get_bounding_box()
    
    love.graphics.push("all")
    
    local col1 = Color( love.math.colorFromBytes( 0xff, 0x7b, 0x00 ) )
    local col2 = Color( love.math.colorFromBytes( 0xff, 0xd8, 0x4d ) )
    
    local col = (col2 - col1) * love.math.random() + col1
    love.graphics.setLineWidth(2.5)
    love.graphics.setColor(col[1], col[2], col[3], col[4])
    love.graphics.rectangle("line", rmin.x, rmin.y, rmax.x - rmin.x, rmax.y - rmin.y)
    
    love.graphics.pop()
end

function Player:initialize()
    Area.initialize(self)
    self.move_speed = 500
    self.velocity = vec2(0, 0)
    self.velocity_remainder = vec2(0, 0)
    
    self.invuln_time = 0
    
    self.fire_interval = 20/60
    self.fire_timer = self.fire_interval
    self.bomb_cooldown = 0
    self.bullet_size = 14
    self.bullet_velocity = 700
    self.bullet_offset = vec2(40, -20)
    self.bullet_loops = 1
end

function Player:enter_tree()
    Area.enter_tree(self)
    self.sprite = self:get_node("Sprite")
    self:connect("area_entered", self, "bullet_hit")
end

function Player:ready()
    self:add_child(HitboxDraw())
end

function Player:update(dt)
    self.invuln_time = self.invuln_time - dt
end

function Player:physics_update(dt)
    if self.dead then return end

    local tree = self:get_tree()
    local view = tree:get_viewport()
    local gpos = self:get_global_position()
 
    self.fire_timer = math.min(self.fire_timer + dt, self.fire_interval)
    self.bomb_cooldown = math.max(self.bomb_cooldown - dt, 0)
    if input.action_is_pressed("bomb") and self.bomb_cooldown <= 0 then
        local level = self:get_parent()
        local can_bomb = not level.player_bombs or level.player_bombs > 0
        
        if can_bomb then
            if level.player_bombs then level.player_bombs = level.player_bombs - 1 end
            
            for i,v in ipairs(self:get_tree():get_current_scene():get_children()) do
                if v:isInstanceOf(Bullet) then
                    v:get_parent():remove_child(v)
                elseif v:isInstanceOf(Enemy) then
                    v:deal_damage(10, true)
                end
            end 
            
            local exp = resource.get_resource("scene/playerbomb.scene"):instance()
            exp:set_global_position(gpos)
            tree:get_current_scene():add_child(exp)
            
            local sound = AudioPlayer()
            sound:set_autoplay(true)
            sound:set_autoremove(true)
            sound:set_source(resource.get_resource("assets/sound/explode.ogg"))
            sound:set_volume(0.86)
            tree:get_current_scene():add_child(sound)
            
            self.invuln_time = 1.5
            self.bomb_cooldown = 1
        end
    end
    
    if input.action_is_down("fire") and self.fire_timer >= self.fire_interval then
        self.fire_timer = self.fire_timer - self.fire_interval
        
        local b = Bullet()
        b:set_aabb_extents(vec2(self.bullet_size, self.bullet_size))
        b:set_velocity( vec2.unit_x:scale(self.bullet_velocity) )
        b:set_position( gpos + self.bullet_offset )
        b:set_loops(self.bullet_loops)
        b.friendly_fire_immunity = true
        b:set_collision_layer( 0 )
        b:set_collision_mask( 3 )
        tree:get_current_scene():add_child(b)        
        
        
        local shoot_sound = AudioPlayer()
        shoot_sound:set_source(resource.get_resource("assets/sound/shoot.ogg"))
        shoot_sound:set_autoplay(true)
        shoot_sound:set_autoremove(true)
        shoot_sound:set_volume(0.9)
        tree:get_current_scene():add_child(shoot_sound)        
        
    end
    
    if self.fire_timer < self.fire_interval then
        self.sprite:set_texture(shoot_img)
    else
        self.sprite:set_texture(stand_img)
    end

    self.velocity = vec2(
        input.action_get_strength("right") - input.action_get_strength("left"),
        input.action_get_strength("down") - input.action_get_strength("up")
    ):normalize() * self.move_speed
    
    local dv = self:get_velocity_delta(dt)
    
    self:translate(dv)
       
    local bmin, bmax = view:get_bounds()
    local sw, sh = view:get_resolution()
    local rmin, rmax = self:get_bounding_box()
    
    if rmax.y < bmin.y then
        self:translate( vec2(0, sh) )
    elseif rmin.y > bmax.y then
        self:translate( vec2(0, -sh) )
    end
    
    if rmax.x < bmin.x then
        self:translate( vec2(sw, 0) )
    elseif rmin.x > bmax.x then
        self:translate( vec2(-sw, 0) )
    end
    
    self:update_physics_position()
end

function Player:kill()
    local root = self:get_tree():get_root()
    local ap = AudioPlayer()
    ap:set_source(resource.get_resource("assets/sound/death.ogg"))
    ap:set_autoplay(true)
    ap:set_autoremove(true)
    root:add_child(ap)    
    local exp = resource.get_resource("scene/explosion.scene"):instance()
    exp:set_scale(vec2(2,2))
    exp:set_global_position(self:get_global_position())
    
    root:add_child(exp)
    
    self.dead = true
end

function Player:bullet_hit(what)
    if self.invuln_time > 0 then return end
    if self.dead then return end
    if what:isInstanceOf(Bullet) then
        if not what.friendly_fire_immunity then
            self:kill()
        end
    else
        self:kill()
    end
end


return Player