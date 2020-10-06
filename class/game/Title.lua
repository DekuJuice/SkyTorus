local Node = require("class.engine.Node")
local Title = Node:subclass("Title")
local img = resource.get_resource("assets/images/title.png")
local font = love.graphics.newFont(32)
local Coroutine = require("class.game.Coroutine")

function Title:initialize()
    Node.initialize(self)
    self.delay = 1
    self.coroutine = Coroutine(loadstring[[
        while true do
            local dt = coroutine.yield()
            self.delay = self.delay - dt
            
            if self.delay <= 0 then
                if input.action_is_pressed("fire") then
                    break
                end 
            end
        end
        
        local opacity = 0
        while true do
            local dt = coroutine.yield()
            self:get_tree():get_viewport().modulate_color[4] = opacity
            opacity = math.min(opacity + dt, 1)
            if opacity >= 1 then
                break
            end
        end
        
        self:get_tree():set_current_scene( resource.get_resource("scene/level1.scene"):instance() )

    ]], {self = self})
end

function Title:ready()
    self:get_tree():get_viewport():set_background_color({0.698, 0.835, 0.921})
end

function Title:draw()
    love.graphics.draw(img:get_love_image())
    
    love.graphics.push("all")
    love.graphics.setFont(font)
    love.graphics.printf("Press Z To start", 0, 400, 800, "center")
    love.graphics.pop()
    
end

function Title:update(dt)
    self.coroutine:update(dt)
end


return Title