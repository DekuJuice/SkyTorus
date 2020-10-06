local BossWarning = require("class.game.BossWarning")
local AudioPlayer = require("class.engine.AudioPlayer")
local Tween = require("class.engine.Tween")

-- scene
local Jelly = resource.get_resource("scene/jelly.scene")
local Monoeye = resource.get_resource("scene/monoeye.scene")
local SkullLaser = resource.get_resource("scene/skulllaser.scene")
local Cirno = resource.get_resource("scene/cirno.scene")
local Mine = resource.get_resource("scene/mine.scene")

local tree = level:get_tree()
local root = tree:get_current_scene()

tree:get_viewport():set_background_color({0.701, 0.737, 0.780})

-- Start level music
local music_player = AudioPlayer()
music_player:set_source(resource.get_resource("assets/sound/stage2.ogg"))
music_player:set_loop(true)
music_player:set_autoplay(true)

root:add_child(music_player)

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

sleep(2)

level:spawn_enemy(Mine, vec2(900, 300), [[
    self:queue_move(vec2(450, 300), 1.5, "outCubic")
]])

level:wait_for_wave(0)

sleep(1.5)

level:spawn_enemy(Jelly, vec2(900, 200), [[
    self:queue_move(vec2(-100, 200), 7, "linear")
    
    while self:get_global_position().x > -100 do
        coroutine.yield()
    end

    self:remove()
]])

sleep(0.3)

level:spawn_enemy(Mine, vec2(900, 500), [[
    self:queue_move(vec2(-100, 500), 7, "linear")
    
    while self:get_global_position().x > -100 do
        coroutine.yield()
    end

    self:remove()
]])

sleep(0.3)


level:spawn_enemy(Jelly, vec2(900, 450), [[
    self:queue_move(vec2(-100, 450), 7, "linear")
    
    while self:get_global_position().x > -100 do
        coroutine.yield()
    end

    self:remove()
]])

sleep(0.3)

level:spawn_enemy(Mine, vec2(900, 200), [[
    self:queue_move(vec2(-100, 200), 7, "linear")
    
    while self:get_global_position().x > -100 do
        coroutine.yield()
    end

    self:remove()
]])

sleep(0.3)


level:spawn_enemy(Jelly, vec2(900, 100), [[
    self:queue_move(vec2(-100, 100), 7, "linear")
    
    while self:get_global_position().x > -100 do
        coroutine.yield()
    end

    self:remove()
]])

sleep(0.3)

level:spawn_enemy(Mine, vec2(900, 450), [[
    self:queue_move(vec2(-100, 450), 7, "linear")
    
    while self:get_global_position().x > -100 do
        coroutine.yield()
    end

    self:remove()
]])

sleep(0.3)


level:spawn_enemy(Jelly, vec2(900, 350), [[
    self:queue_move(vec2(-100, 350), 7, "linear")
    
    while self:get_global_position().x > -100 do
        coroutine.yield()
    end

    self:remove()
]])

sleep(0.3)

level:spawn_enemy(Mine, vec2(900, 250), [[
    self:queue_move(vec2(-100, 250), 7, "linear")
    
    while self:get_global_position().x > -100 do
        coroutine.yield()
    end

    self:remove()
]])

sleep(0.3)


level:spawn_enemy(Jelly, vec2(900, 500), [[
    self:queue_move(vec2(-100, 500), 7, "linear")
    
    while self:get_global_position().x > -100 do
        coroutine.yield()
    end

    self:remove()
]])
sleep(0.3)

level:spawn_enemy(Mine, vec2(900, 150), [[
    self:queue_move(vec2(-100, 150), 7, "linear")
    
    while self:get_global_position().x > -100 do
        coroutine.yield()
    end

    self:remove()
]])

sleep(0.3)

level:spawn_enemy(Jelly, vec2(900, 400), [[
    self:queue_move(vec2(-100, 400), 7, "linear")
    
    while self:get_global_position().x > -100 do
        coroutine.yield()
    end

    self:remove()
]])
sleep(0.3)

level:spawn_enemy(Mine, vec2(900, 550), [[
    self:queue_move(vec2(-100, 550), 7, "linear")
    
    while self:get_global_position().x > -100 do
        coroutine.yield()
    end

    self:remove()
]])

sleep(0.3)

level:spawn_enemy(Jelly, vec2(900, 250), [[
    self:queue_move(vec2(-100, 250), 7, "linear")
    
    while self:get_global_position().x > -100 do
        coroutine.yield()
    end

    self:remove()
]])
sleep(0.3)


level:spawn_enemy(Mine, vec2(900, 550), [[
    self:queue_move(vec2(-100, 550), 7, "linear")
    
    while self:get_global_position().x > -100 do
        coroutine.yield()
    end

    self:remove()
]])

level:spawn_enemy(Jelly, vec2(900, 150), [[
    self:queue_move(vec2(-100, 150), 7, "linear")
    
    while self:get_global_position().x > -100 do
        coroutine.yield()
    end

    self:remove()
]])
sleep(0.6)

level:spawn_enemy(Jelly, vec2(900, 200), [[
    self:queue_move(vec2(-100, 200), 7, "linear")
    
    while self:get_global_position().x > -100 do
        coroutine.yield()
    end

    self:remove()
]])
sleep(0.6)

level:spawn_enemy(Jelly, vec2(900, 400), [[
    self:queue_move(vec2(-100, 400), 7, "linear")
    
    while self:get_global_position().x > -100 do
        coroutine.yield()
    end

    self:remove()
]])
sleep(0.6)

level:wait_for_wave(2)

sleep(1)

level:spawn_enemy(Monoeye, vec2(900, 100), monoeye_type_a( vec2(500, 100), vec2(900,300) ))
level:spawn_enemy(Mine, vec2(900, 100), monoeye_type_a( vec2(450, 100), vec2(900,300) ))
sleep(3)
level:spawn_enemy(Monoeye, vec2(900, 300), monoeye_type_a( vec2(600, 300), vec2(900,300) ))
level:spawn_enemy(Mine, vec2(900, 300), monoeye_type_a( vec2(550, 300), vec2(900,300) ))
sleep(3)
level:spawn_enemy(Monoeye, vec2(900, 500), monoeye_type_a( vec2(500, 500), vec2(900,300) ))
level:spawn_enemy(Mine, vec2(900, 500), monoeye_type_a( vec2(450, 500), vec2(900,300) ))

level:wait_for_wave(0)
sleep(3)


for x = 1, 3 do
    for y = 1, 12 do 
        
        local my = (y - 1) * 50 + 25
        local sx = (x - 1) * 50 + 650
        level:spawn_enemy(Mine, vec2(900, my),( [[
            
            self:queue_move(vec2( %d, %d ), 1.3, "outCubic" )
            sleep(3)
            
            self:queue_move(vec2(%d * -50, %d), 20, "linear")
            sleep(20)
            self:remove()            
        ]]):format( sx, my, 4 - x, my ))
        
    end
end

for y = 1, 12 do
    local my = (y - 1) * 50 + 25
    level:spawn_enemy(Mine, vec2(50, my), ([[
        sleep(22)
        self:queue_move(vec2(-50, %d), 1, "linear")
        sleep(1)
        self:remove()
    ]]):format(my) , 1)
end

sleep(3)
level:wait_for_wave(0)

sleep(1)

level:spawn_enemy(Monoeye, vec2(900, 100), monoeye_type_a( vec2(500, 100), vec2(900,300) ))
level:spawn_enemy(Mine, vec2(900, 100), monoeye_type_a( vec2(450, 100), vec2(900,300) ))
sleep(3)
level:spawn_enemy(Monoeye, vec2(900, 300), monoeye_type_a( vec2(600, 300), vec2(900,300) ))
level:spawn_enemy(Mine, vec2(900, 300), monoeye_type_a( vec2(550, 300), vec2(900,300) ))
sleep(3)
level:spawn_enemy(Monoeye, vec2(900, 500), monoeye_type_a( vec2(500, 500), vec2(900,300) ))
level:spawn_enemy(Mine, vec2(900, 500), monoeye_type_a( vec2(450, 500), vec2(900,300) ))

level:wait_for_wave(0)
sleep(3)

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

level:spawn_boss(Cirno, vec2(900, 300), [[
    self:queue_move(vec2(600, 300), 1.5, "outCubic")
    sleep(1.7)
    
    while true do
        -- pattern 1
        for i = 1, 3 do
            
            local np
            local max_attempts = 20
            repeat
                np = vec2(
                    love.math.random(350, 650),
                    love.math.random(150, 450)
                )                  
                
                max_attempts = max_attempts - 1
                if max_attempts <= 0 then break end
                
            until ( np - self:get_global_position() ):len() > 300
            
            self:queue_move(np, 1.3, "outCubic")
            sleep(1.6)
            local offset = love.math.random() * math.pi * 2
            for i = 1, 8 do
                self:fire_bullet(12, math.rad((i - 1) * 45) + offset, nil, 1)
            end
            self:play_fire_sound()
            sleep(1.5)
        
            -- pattern 2
            repeat
                np = vec2(
                    love.math.random(350, 650),
                    love.math.random(150, 450)
                )                  
                
                max_attempts = max_attempts - 1
                if max_attempts <= 0 then break end
                
            until ( np - self:get_global_position() ):len() > 300
            self:queue_move(np, 1.3, "outCubic")
            sleep(1.6)
            
            for i = 1, 3 do
                local spd = 330 + (i / 3 * 80)
                self:fire_bullet_at_player(nil, math.rad(-20), spd, 2)
                self:fire_bullet_at_player(nil, 0, spd, 2)
                self:fire_bullet_at_player(nil, math.rad(20), spd, 2)
            end
            self:play_fire_sound()
            
            sleep(1.5)
        end

        do
            self:queue_move(vec2(700, 300), 1.5, "outCubic")
            sleep(1.7)
            
            local t = 0
            local shot_interval = .26
            local shot_timer = 0
            
            while t < 6 do
                local dt = coroutine.yield()
                t = t + dt
                
                shot_timer = shot_timer - dt
                if shot_timer <= 0 then
                    shot_timer = shot_timer + shot_interval
                    self:fire_bullet(15,  math.rad(100) , 800, 6)                
                    self:fire_bullet(15,  math.rad(-100) , 800, 6)                
                    self:play_fire_sound()
                end
                
            end
            
            sleep(2.5)
        end

    end


]])







