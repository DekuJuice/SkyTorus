-- class
local TutorialText = require("class.game.TutorialText")
local BossWarning = require("class.game.BossWarning")
local AudioPlayer = require("class.engine.AudioPlayer")
local Tween = require("class.engine.Tween")

-- scene
local Jelly = resource.get_resource("scene/jelly.scene")
local Monoeye = resource.get_resource("scene/monoeye.scene")
local SkullLaser = resource.get_resource("scene/skulllaser.scene")
local Gazer = resource.get_resource("scene/gazer.scene")

local tree = level:get_tree()
local root = tree:get_current_scene()

tree:get_viewport():set_background_color({0.701, 0.737, 0.780})

-- Start level music

local music_player = AudioPlayer()
music_player:set_source(resource.get_resource("assets/sound/stage1.ogg"))
music_player:set_loop(true)
music_player:set_autoplay(true)

root:add_child(music_player)

-- Tutorial
if not level.skip_tutorial then

sleep(2)

root:add_child( TutorialText("Move with arrow keys.", 2) )

sleep(2)

root:add_child( TutorialText("Shoot with Z, Bomb with X.", 2))

sleep(2)

root:add_child( TutorialText("You and all bullets will loop around the screen", 3) )

sleep(3)

root:add_child( TutorialText("Watch out for friendly fire!", 2) )

sleep(2)

end

local function monoeye_type_a(p1, p2)
    return ([[
        self:queue_move(vec2(%d, %d), 1.5, "outCubic")
        sleep(1.5)
        sleep(0.3)
        
        self:fire_bullet_at_player()
        self:play_fire_sound()
        
        sleep(1.5)
        
        self:fire_bullet_at_player()
        self:play_fire_sound()

        sleep(1.5)
        
        self:queue_move(vec2(%d, %d), 1.5, "inCubic")
        
        sleep(1.5)
        self:remove()
    ]]):format(p1.x, p1.y, p2.x, p2.y)
end

local function monoeye_type_b(p1)
    return ([[
        
        sleep(1.5)
        self:fire_bullet_at_player()
        self:play_fire_sound()

        sleep(1.5)
        self:fire_bullet_at_player()
        self:play_fire_sound()

        sleep(1.5)
        self:queue_move(vec2(%d, %d), 1.5, "inCubic")
        
        sleep(1.5)
        self:remove()
    
    
    ]]):format(p1.x, p1.y)
end

local function skull_type_a(angle)
    return ([[
        local angle = %d
        self:get_node("Sprite"):set_rotation(angle+math.pi)
        sleep(.5)
        while true do
            sleep(1.5)
            self:fire_bullet(nil, angle, nil, 3)
            self:play_fire_sound()
                
        end
    ]]):format(angle)
end

sleep(1)

for i = 1, 4 do
    level:spawn_enemy(Jelly, vec2(900, 150), [[
        self:queue_move(vec2(450, 150), 1.5)
        self:queue_move(vec2(550, 350), 1.25)
        self:queue_move(vec2(-100, 350), 2)
        sleep(6.5)
        self:remove()
    ]])
    sleep(0.3)
end

sleep(2)

for i = 1, 4 do
    level:spawn_enemy(Jelly, vec2(900, 450), [[
        self:queue_move(vec2(450, 450), 1.5)
        self:queue_move(vec2(550, 250), 1.25)
        self:queue_move(vec2(-100, 250), 2)
        sleep(6.5)
        self:remove()
    ]])
    sleep(0.3)
end

sleep(3)

level:spawn_enemy(Monoeye, vec2(900, 100), monoeye_type_a( vec2(500, 300), vec2(900,500) ))
level:wait_for_wave(0)
sleep(0.7)

level:spawn_enemy(Monoeye, vec2(900, 100), monoeye_type_a( vec2(500, 100), vec2(900,300) ))
sleep(1.2)
level:spawn_enemy(Monoeye, vec2(900, 300), monoeye_type_a( vec2(600, 300), vec2(900,300) ))
sleep(1.2)
level:spawn_enemy(Monoeye, vec2(900, 500), monoeye_type_a( vec2(500, 500), vec2(900,300) ))
sleep(2)


for i = 1, 4 do
    level:spawn_enemy(Jelly, vec2(900, 450), [[
        self:queue_move(vec2(450, 450), 1.5)
        self:queue_move(vec2(550, 250), 1.25)
        self:queue_move(vec2(-100, 250), 2)
        sleep(6.5)
        self:remove()
    ]])
    sleep(0.3)
end

level:spawn_enemy(Monoeye, vec2(250, 150), monoeye_type_b( vec2(-100, 300) ), 0.4)
sleep(2)

level:spawn_enemy(Monoeye, vec2(550, 50), monoeye_type_b( vec2(-100, 300) ), 0.4)
sleep(2)
level:spawn_enemy(Monoeye, vec2(350, 450), monoeye_type_b( vec2(-100, 300) ), 0.4)

sleep(2)
level:spawn_enemy(Monoeye, vec2(400, 300), monoeye_type_b( vec2(-100, 300) ), 0.4)

sleep(2)


level:wait_for_wave(0)

sleep(0.5)

for i = 1, 6 do

level:spawn_enemy(Monoeye, vec2(600, -50), [[
    self:queue_move(vec2(600, 700), 10)

    sleep(1)
    
    while self:get_global_position().y < 700 do
        self:fire_bullet_at_player()
        self:play_fire_sound()

        sleep(1.5)
    end
    
    self:remove()
]])

sleep(.5)
level:spawn_enemy(Jelly, vec2(650, 700), [[
        self:queue_move(vec2(650, -50), 5)
        sleep(5)
        self:remove()
]])
sleep(.5)
level:spawn_enemy(Jelly, vec2(650, 700), [[
        self:queue_move(vec2(650, -50), 5)
        sleep(5)
        self:remove()
]])

sleep(1)

end

level:wait_for_wave(2)
sleep(1.5)

level:spawn_enemy(Monoeye, vec2(-100, 100), monoeye_type_a( vec2(200, 100), vec2(-100,300) ))
sleep(1.2)
level:spawn_enemy(Monoeye, vec2(-100, 300), monoeye_type_a( vec2(300, 300), vec2(-100,300) ))
sleep(1.2)
level:spawn_enemy(Monoeye, vec2(-100, 500), monoeye_type_a( vec2(200, 500), vec2(-100,300) ))
sleep(2)

level:wait_for_wave(0)

sleep(1.5)

level:spawn_enemy(SkullLaser, vec2(600, 500), skull_type_a(math.rad(-165)), 0.4)

sleep(0.5)
level:wait_for_wave(0)

sleep(1.5)

level:spawn_enemy(SkullLaser, vec2(600, 100), skull_type_a(math.rad(104)), 0.4)
sleep(0.1)
level:spawn_enemy(SkullLaser, vec2(650, 100), skull_type_a(math.rad(104)), 0.4)
sleep(0.1)

for i = 1, 4 do
    level:spawn_enemy(Jelly, vec2(900, 150), [[
        self:queue_move(vec2(450, 150), 1.5)
        self:queue_move(vec2(550, 350), 1.25)
        self:queue_move(vec2(-100, 350), 2)
        sleep(6.5)
        self:remove()
    ]])
    sleep(0.3)
end

sleep(1.5)

for i = 1, 4 do
    level:spawn_enemy(Jelly, vec2(900, 450), [[
        self:queue_move(vec2(450, 450), 1.5)
        self:queue_move(vec2(550, 250), 1.25)
        self:queue_move(vec2(-100, 250), 2)
        sleep(6.5)
        self:remove()
    ]])
    sleep(0.3)
end

sleep(1.5)

for i = 1, 4 do
    level:spawn_enemy(Jelly, vec2(900, 150), [[
        self:queue_move(vec2(450, 150), 1.5)
        self:queue_move(vec2(550, 350), 1.25)
        self:queue_move(vec2(-100, 350), 2)
        sleep(6.5)
        self:remove()
    ]])
    sleep(0.3)
end

sleep(1.5)

for i = 1, 4 do
    level:spawn_enemy(Jelly, vec2(900, 450), [[
        self:queue_move(vec2(450, 450), 1.5)
        self:queue_move(vec2(550, 250), 1.25)
        self:queue_move(vec2(-100, 250), 2)
        sleep(6.5)
        self:remove()
    ]])
    sleep(0.3)
end

sleep(1.5)


level:spawn_enemy(Monoeye, vec2(900, 300), monoeye_type_a( vec2(500, 100), vec2(900,300) ))
sleep(1.6)
level:spawn_enemy(Monoeye, vec2(900, 300), monoeye_type_a( vec2(600, 200), vec2(900,300) ))
sleep(1.6)
level:spawn_enemy(Monoeye, vec2(900, 300), monoeye_type_a( vec2(450, 300), vec2(900,300) ))
sleep(1.6)
level:spawn_enemy(Monoeye, vec2(900, 300), monoeye_type_a( vec2(550, 400), vec2(900,300) ))
sleep(1.6)
level:spawn_enemy(Monoeye, vec2(900, 300), monoeye_type_a( vec2(500, 500), vec2(900,300) ))
sleep(1.6)

level:wait_for_wave(0)

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

music_player:set_source( resource.get_resource("assets/sound/genesisap.ogg") )
music_player:set_volume(0.5)
music_player:play()

level:spawn_boss(Gazer, vec2(900, 300), [[
    self:queue_move(vec2(600, 300), 1.5, "outCubic")
    sleep(1.7)
    
    while true do
        -- pattern 1
        for i = 1, 3 do
            
            local np
            local max_attempts = 20
            repeat
                np = vec2(
                    love.math.random(150, 650),
                    love.math.random(150, 450)
                )                  
                
                max_attempts = max_attempts - 1
                if max_attempts <= 0 then break end
                
            until ( np - self:get_global_position() ):len() > 300
            
            self:queue_move(np, 1.3, "outCubic")
            sleep(1.6)
            
            local a = self:get_angle_to_player()
            if a then
            
                for i = 1, 5 do
                    local angle_mod = (love.math.random() * 2 - 1) * math.rad(15)
                    
                    self:fire_bullet(nil, a + angle_mod, nil, 3 )                    
                end
                self:play_fire_sound()
                
            end
            
            sleep(2)
        end
        
        -- pattern 2
        do
            self:queue_move(vec2(400, 300), 1.5, "outCubic")
            sleep(1.7)
            
            local t = 0
            local rot = 0
            local rotspeed = math.rad(190)
            
            local shot_interval = .21
            local shot_timer = 0
            
            while t < 6 do
                local dt = coroutine.yield()
                t = t + dt
                
                rot = rot + rotspeed * dt
                
                shot_timer = shot_timer - dt
                if shot_timer <= 0 then
                    shot_timer = shot_timer + shot_interval
                    self:fire_bullet(nil, rot + math.pi, nil, 1)                
                    self:play_fire_sound()
                    
                end
                
            end
        end
        
        -- pattern 3
        
        do
            for i = 1, 3 do
            
                local np = vec2(
                    love.math.random(150, 650),
                    love.math.random(150, 450)
                )     
                
                self:queue_move(np, 1.3, "outCubic")
                sleep(1.5)            
            
                local AimLaser = require("class.game.AimLaser")
                local laser = AimLaser()
                self:add_child(laser)
                laser:set_loops(5)
                local charge_time = 1.25
                local target_angle = love.math.random() * math.pi * 2
                laser:set_angle(target_angle)
                self:play_fire_sound("assets/sound/charge.ogg")
                while charge_time > 0 do
                    local dt = coroutine.yield()
                    charge_time = charge_time - dt
                end
                
                self:fire_bullet(50, target_angle, 2250, 5)
                self:remove_child(laser)
                self:play_fire_sound()

                sleep(3)
            end
            
        end
    
    
    
    end
    
    
]])

