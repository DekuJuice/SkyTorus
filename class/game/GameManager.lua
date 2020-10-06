local Node = require("class.engine.Node")
local GameManager = Node:subclass("GameManager")
local Coroutine = require("class.game.Coroutine")

GameManager:export_var("level_file", "string")
GameManager:export_var("next_scene", "string")

function GameManager:initialize()
    Node.initialize(self)
    self.level_file = ""
    self.next_scene = ""
    self.sleep_timer = 0
    self.enemy_count = 0
    
    self.player_lives = 5
    self.player_bombs = 3
    self.player_score = 0
    self.respawn_timer = 0
    self.boss_path = ""
    self.boss_dead = false
    
    self.game_loop = Coroutine(loadstring([[
    
        -- spawn player initial
        
        local pscene = resource.get_resource("scene/player.scene")
        local player = pscene:instance()
        
        player:set_global_position(vec2(100, 300))
        self:add_child(player)
        
        coroutine.yield()
        
        local view = self:get_tree():get_viewport()
        view.modulate_color[4] = 1
        while view.modulate_color[4] > 0 do
            local dt = coroutine.yield()
            view.modulate_color[4] = math.max(view.modulate_color[4] - dt * 1.3, 0)
        end
        
        while true do
            player = self:get_node("Player")
            
            if player.dead then 
                self.player_lives = self.player_lives - 1
                
                self:remove_child(player)
                if self.player_lives <= 0 then break end
                
                local np = pscene:instance()
                np:set_global_position(vec2(100, 300))
                np.invuln_time = 1.5
                
                sleep(2)
                self:add_child(np)
            end
            
            if self.boss_dead then break end
            
            coroutine.yield()
        end
        
        sleep(1.2)
        
        while view.modulate_color[4] < 1 do
            local dt = coroutine.yield()
            view.modulate_color[4] = math.min(view.modulate_color[4] + dt * 1.3, 1)
        end
        sleep(1.2)
        if self.boss_dead then
            
            local level = resource.get_resource(self.next_scene):instance()
            self.player_score = self.player_score + 1000 * self.player_bombs
            level.player_score = self.player_score
            self:get_tree():set_current_scene(level)
            
        else 
            local level = resource.get_resource(self.filepath):instance()
            level.player_score = self.player_score / 2
            level.skip_tutorial = true
            self:get_tree():set_current_scene(level)    
        end
        
        
        -- game over
    ]]), {self = self} )

end

function GameManager:enter_tree()
    local f = love.filesystem.load(self.level_file)
    self.level_coroutine = Coroutine(f, {level = self})
end

function GameManager:update(dt) 
    self.game_loop:update(dt)
    
    if not self:get_tree() then return end
    
    self.level_coroutine:update(dt)
end

function GameManager:_increment_enemy_count()
    self.enemy_count = self.enemy_count + 1
end

function GameManager:_decrement_enemy_count()
    self.enemy_count = self.enemy_count - 1
end

function GameManager:_increment_score(enemy)
    self.player_score = self.player_score + enemy.score
end

function GameManager:_end_level()
    self.boss_dead = true
end

function GameManager:spawn_enemy(type, pos, script, delay)
    local SummonHelper = require("class.game.SummonHelper")

    delay = delay or 0
    
    local i = type:instance()
    i:set_script(script)
    i:set_global_position(pos)
    
    i:connect("on_enter_tree", self, "_increment_enemy_count")
    i:connect("on_exit_tree", self, "_decrement_enemy_count")
    i:connect("on_death", self, "_increment_score")
    
    if delay > 0 then
        self:get_tree():get_current_scene():add_child( SummonHelper(i, delay) )
    else
        self:get_tree():get_current_scene():add_child(i)
    end    
end

function GameManager:spawn_boss(type, pos, script)
    local i = type:instance()
    i:set_script(script)
    i:set_global_position(pos)
    
    i:connect("on_enter_tree", self, "_increment_enemy_count")
    i:connect("on_exit_tree", self, "_decrement_enemy_count")
    i:connect("on_death", self, "_increment_score")
    i:connect("on_death", self, "_end_level")
    
    self:get_tree():get_current_scene():add_child(i)
    self.boss_path = i:get_absolute_path()
end

function GameManager:wait_for_wave(count)
    while self.enemy_count > count do
        coroutine.yield()
    end
end

function GameManager:get_boss()
    return self:get_node(self.boss_path)
end

return GameManager
