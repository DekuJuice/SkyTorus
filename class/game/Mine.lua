local Enemy = require("class.game.Enemy")
local Mine = Enemy:subclass("Mine")

function Mine:enter_tree()
    Enemy.enter_tree(self)
    
    self:connect("on_death", self, "fire_ring")
end

function Mine:fire_bullet_at_player() end

function Mine:fire_ring()
    for i = 1, 8 do
        self:fire_bullet(nil, math.rad( (i - 1) *  45 + 15), nil, 1)
    end
end


return Mine