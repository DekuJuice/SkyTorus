local BossWarning = require("class.game.BossWarning")
local AudioPlayer = require("class.engine.AudioPlayer")
local Tween = require("class.engine.Tween")

-- scene
local Jelly = resource.get_resource("scene/jelly.scene")
local Monoeye = resource.get_resource("scene/monoeye.scene")
local SkullLaser = resource.get_resource("scene/skulllaser.scene")
local GunDevil = resource.get_resource("scene/gundevil.scene")
local Mine = resource.get_resource("scene/mine.scene")
local SuperSkull = resource.get_resource("scene/superskull.scene")


local tree = level:get_tree()
local root = tree:get_current_scene()

tree:get_viewport():set_background_color({0.580, 0.098, 0.098})

-- Start level music
local music_player = AudioPlayer()
music_player:set_source(resource.get_resource("assets/sound/stage3.ogg"))
music_player:set_loop(true)
music_player:set_autoplay(true)

root:add_child(music_player)

sleep(3)


level:spawn_enemy(SuperSkull, vec2(785, 560), [[
    self:get_node("Sprite"):set_rotation(math.rad(90))

    sleep(0.5)
    self:queue_move(vec2(-50, 550), 1.75)

    while self:get_global_position().x > 0 do
        self:fire_bullet(15, math.rad(90)+math.pi, 680, 2)
        sleep(4/60)
        self:play_fire_sound()
    end
    
    while self:get_global_position().x > -50 do
        coroutine.yield()
    end
    
    self:remove()
]], 0.4)

sleep(0.5)
level:wait_for_wave(0)
sleep(1)

level:spawn_enemy(SuperSkull, vec2(750, 25), [[
    sleep(0.5)
    self:queue_move(vec2(750, 650), 1.75)

    while self:get_global_position().y < 580 do
        self:fire_bullet(15, math.pi, 680, 2)
        sleep(4/60)
        self:play_fire_sound()
    end
    
    while self:get_global_position().y < 650 do
        coroutine.yield()
    end
    
    self:remove()
]], 0.4)

sleep(0.5)
level:wait_for_wave(0)
sleep(1)

level:spawn_enemy(SuperSkull, vec2(15, 560), [[
    self:get_node("Sprite"):set_rotation(math.rad(90))

    sleep(0.5)
    self:queue_move(vec2(850, 560), 1.75)

    while self:get_global_position().x < 800 do
        self:fire_bullet(15, math.rad(90)+math.pi, 680, 2)
        sleep(4/60)
        self:play_fire_sound()
    end
    
    while self:get_global_position().x < 850 do
        coroutine.yield()
    end
    
    self:remove()
]], 0.4)

sleep(0.5)
level:wait_for_wave(0)
sleep(1)

level:spawn_enemy(SuperSkull, vec2(785, 15), [[
    sleep(1.5)
    
    self:queue_move(vec2(785, 200), 1)
    
    while self:get_global_position().y ~= 200 do
        self:fire_bullet(15, math.pi, 600, 0)
        sleep(4/60)
        self:play_fire_sound()
    end
    
    local t = 0
    local shot_interval = 0
    while t < 15 do
        local dt = coroutine.yield()
        t = t + dt
        local gp = self:get_global_position()
        gp.y = math.sin(t * 2/math.pi * 3) * 150 + 200
        self:set_global_position(gp) 
        
        shot_interval = shot_interval - dt
        if shot_interval < 0 then
            shot_interval = shot_interval + 6/60
            self:fire_bullet(15, math.pi, 600, 0)
        end

    end
    
    self:remove()
    
]], 0.4)

level:spawn_enemy(SuperSkull, vec2(785, 585), [[
    sleep(1.5)
    
    self:queue_move(vec2(785, 400), 1)
    
    while self:get_global_position().y ~= 400 do
        self:fire_bullet(15, math.pi, 600, 0)
        sleep(4/60)
    end
    
    local t = 0
    local shot_interval = 0
    while t < 15 do
        local dt = coroutine.yield()
        t = t + dt
        local gp = self:get_global_position()
        gp.y = math.sin(t * 2/math.pi * 3) * 150 + 400
        self:set_global_position(gp) 
        
        shot_interval = shot_interval - dt
        if shot_interval < 0 then
            shot_interval = shot_interval + 6/60
            self:fire_bullet(15, math.pi, 600, 0)
            self:play_fire_sound()
        end
    end
    
    self:remove()
]], 0.4)

sleep(0.5)
level:wait_for_wave(0)

sleep(1)

level:spawn_enemy(SuperSkull, vec2(900, 300), [[
        self:queue_move(vec2(400, 300), 1.5, "outCubic")
        sleep(1.7)
        
        local t = 0
        local rot = 0
        local rotspeed = math.rad(100)
        
        local shot_interval = .13
        local shot_timer = 0

        local sprite = self:get_node("Sprite")
        while t < 3.6 do
            local dt = coroutine.yield()
            t = t + dt
            
            rot = rot + rotspeed * dt
            sprite:set_rotation(rot)
            
            shot_timer = shot_timer - dt
            if shot_timer <= 0 then
                shot_timer = shot_timer + shot_interval
                self:fire_bullet(15, rot + math.pi, 800, 0)     
                self:play_fire_sound()
            end
        end
        
        self:queue_move(vec2(900, 300), 1.5, "inCubic")
        
        sleep(1.5)
        self:remove()
]])

sleep(6)

level:spawn_enemy(SuperSkull, vec2(900, 300), [[
        self:queue_move(vec2(600, 100), 1.5, "outCubic")
        sleep(1.7)
        
        local t = 0
        local rot = 0
        local rotspeed = math.rad(100)
        
        local shot_interval = .13
        local shot_timer = 0

        local sprite = self:get_node("Sprite")
        while t < 3.6 do
            local dt = coroutine.yield()
            t = t + dt
            
            rot = rot + rotspeed * dt
            sprite:set_rotation(rot)
            
            shot_timer = shot_timer - dt
            if shot_timer <= 0 then
                shot_timer = shot_timer + shot_interval
                self:fire_bullet(15, rot + math.pi, 800, 0)      
                self:play_fire_sound()
            end
        end
        
        self:queue_move(vec2(900, 300), 1.5, "inCubic")
        
        sleep(1.5)
        self:remove()
]])

sleep(5)

level:spawn_enemy(SuperSkull, vec2(900, 300), [[
        self:queue_move(vec2(200, 500), 1.5, "outCubic")
        sleep(1.7)
        
        local t = 0
        local rot = 0
        local rotspeed = math.rad(100)
        
        local shot_interval = .13
        local shot_timer = 0

        local sprite = self:get_node("Sprite")
        while t < 3.6 do
            local dt = coroutine.yield()
            t = t + dt
            
            rot = rot + rotspeed * dt
            sprite:set_rotation(rot)
            
            shot_timer = shot_timer - dt
            if shot_timer <= 0 then
                shot_timer = shot_timer + shot_interval
                self:fire_bullet(15, rot + math.pi, 800, 0)      
                self:play_fire_sound()
            end
        end
        
        self:queue_move(vec2(900, 300), 1.5, "inCubic")
        
        sleep(1.5)
        self:remove()
]])

sleep(3)

level:spawn_enemy(SuperSkull, vec2(900, 300), [[
        self:queue_move(vec2(400, 300), 1.5, "outCubic")
        sleep(1.7)
        
        local t = 0
        local rot = 0
        local rotspeed = math.rad(100)
        
        local shot_interval = .13
        local shot_timer = 0

        local sprite = self:get_node("Sprite")
        while t < 3.6 do
            local dt = coroutine.yield()
            t = t + dt
            
            rot = rot + rotspeed * dt
            sprite:set_rotation(rot)
            
            shot_timer = shot_timer - dt
            if shot_timer <= 0 then
                shot_timer = shot_timer + shot_interval
                self:fire_bullet(15, rot + math.pi, 800, 0)                
                self:play_fire_sound()
            end
        end
        
        self:queue_move(vec2(900, 300), 1.5, "inCubic")
        
        sleep(1.5)
        self:remove()
]])

sleep(3)

level:spawn_enemy(SuperSkull, vec2(-50, 300), [[
        self:queue_move(vec2(100, 100), 1.5, "outCubic")
        sleep(1.7)
        
        local t = 0
        local rot = 0
        local rotspeed = math.rad(100)
        
        local shot_interval = .13
        local shot_timer = 0

        local sprite = self:get_node("Sprite")
        while t < 3.6 do
            local dt = coroutine.yield()
            t = t + dt
            
            rot = rot + rotspeed * dt
            sprite:set_rotation(rot)
            
            shot_timer = shot_timer - dt
            if shot_timer <= 0 then
                shot_timer = shot_timer + shot_interval
                self:fire_bullet(15, rot + math.pi, 800, 0)       
                self:play_fire_sound()
            end
        end
        
        self:queue_move(vec2(900, 300), 1.5, "inCubic")
        
        sleep(1.5)
        self:remove()
]])

level:wait_for_wave(0)
sleep(1)

do

local music_tween = Tween()
music_tween:set_target( music_player:get_absolute_path() )
music_tween:set_property("volume")
music_tween:set_target_value(0)
music_tween:set_duration(5)

root:add_child(music_tween)

end

sleep(2.5)

root:add_child(BossWarning())

sleep(5)

music_player:set_source( resource.get_resource("assets/sound/sol32.ogg") )
music_player:set_volume(0.5)
music_player:play()

level:spawn_boss(GunDevil, vec2(900, 250), [[
    self:queue_move(vec2(600, 250), 1.5, "outCubic")
    sleep(1.7)
    
    local SuperSkull = resource.get_resource("scene/superskull.scene")

    local tree = self:get_tree()
    
    while true do
        do
            for i = 1, 3 do
                sleep(1.5)
                local offset = love.math.random() * math.pi * 2
                for j = 1, 8 do
                    self:fire_bullet(12, math.rad((j - 1) * 45) + offset, nil, 2)
                end
                self:play_fire_sound()
            end
            sleep(5)
        end
    
        -- pattern 2
        do
            local y1 = 0
            local gp = self:get_global_position()
            for i = 1, 5 do
                local sleep_time = 6/60 - i/60
                while y1 < 600 do
                    self:fire_bullet(15, math.pi, 800, 0, vec2(150, y1 - gp.y))
                    y1 = y1 + 50
                    sleep(sleep_time)
                    self:play_fire_sound()
                end
                
                y1 = 600
                
                while y1 > 0 do
                    y1 = y1 - 50
                    self:fire_bullet(15, math.pi, 800, 0, vec2(150, y1 - gp.y))
                    sleep(sleep_time)
                    self:play_fire_sound()
                end
            end
        end
    
        -- pattern 3
        do
            local skull_1 = SuperSkull:instance()
            local skull_2 = SuperSkull:instance()
            
            skull_1:set_position(vec2(785, 15))
            skull_2:set_position(vec2(785, 585))
            
            skull_1:set_script([=[ 
                sleep(1.5)
                self:queue_move(vec2(785, 200), 1)
                
                while true do
                    self:fire_bullet(15, math.pi, 800, 0)                    
                    sleep(4/60)
                end
            ]=])
            
            skull_2:set_script([=[ 
                sleep(1.5)
                self:queue_move(vec2(785, 400), 1)
                
                while true do
                    self:fire_bullet(15, math.pi, 800, 0)                    
                    sleep(4/60)
                end
            ]=])
            
            tree:get_current_scene():add_child(skull_1)
            tree:get_current_scene():add_child(skull_2)
            
            sleep(3)
            
            
            for i = 1, 12 do
                local row = love.math.random(1, 3)
                if row ~= 1 then
                    self:fire_bullet(46, math.pi, 200, 0, vec2(150, -15))
                end
                if row ~= 2 then
                    self:fire_bullet(46, math.pi, 200, 0, vec2(150, 50))
                end
                if row ~= 3 then
                    self:fire_bullet(46, math.pi, 200, 0, vec2(150, 120))                
                end
                self:play_fire_sound()
                sleep(1.3)
                
            end
            
            sleep(3)
            skull_1:remove()
            skull_2:remove()
            
            
            
        end
        do
            local AimLaser = require("class.game.AimLaser")

            for i = 1, 3 do
            
                local laser = AimLaser()
                self:add_child(laser)
                laser:set_loops(5)
                local charge_time = 1.25
                local target_angle = 0
                self:play_fire_sound("assets/sound/charge.ogg")
                while charge_time > 0 do
                    local dt = coroutine.yield()
                    charge_time = charge_time - dt
                    target_angle = self:get_angle_to_player() or 0
                    laser:set_angle(target_angle)
                end
                
                sleep(0.5)
                self:fire_bullet(50, target_angle, 2250, 5)
                self:play_fire_sound()
                self:remove_child(laser)

                sleep(3)
            end
            
        end
        
        coroutine.yield()
    end
]])



