local Node = require("class.engine.Node")
local font = love.graphics.newFont(32)
local WinScreen = Node:subclass("WinScreen")
local Coroutine = require("class.game.Coroutine")

function WinScreen:initialize()
    Node.initialize(self)
    self.show_score = false
    self.show_return = false
    self.coroutine = Coroutine(loadstring[[

        self:get_tree():get_viewport():set_background_color({0,0,0,0})
        self:get_tree():get_viewport().modulate_color[4] = 0
        sleep(2)
        self.show_score = true
        
        sleep(1)
        self.show_return = true
        
        
        while not input.action_is_pressed("fire") do
            coroutine.yield()
        end
        
        sleep(0.2)
        
        self:get_tree():set_current_scene( resource.get_resource("scene/title.scene"):instance() )

    ]], {self = self})
end

function WinScreen:update(dt)
    self.coroutine:update(dt)
end

function WinScreen:draw()
    love.graphics.push("all")
    love.graphics.setFont(font)
    love.graphics.printf("You're winner!", 0, 250, 800, "center")
    
    if self.show_score then
        love.graphics.printf(("Final Score: %010d"):format(self.player_score or 0), 0, 300, 800, "center")
    end
    
    if self.show_return then
        love.graphics.printf(("Press Z to return to the title screen"), 0, 350, 800, "center")

    end
    
    
    love.graphics.pop()
end

return WinScreen