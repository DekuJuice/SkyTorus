local Sprite = require("class.engine.Sprite")
local Fake3dBackground = Sprite:subclass("Fake3dBackground")

Fake3dBackground:export_var("cam_pos", "vec2_float")
Fake3dBackground:export_var("cam_rot", "float")
Fake3dBackground:export_var("horizon", "float")
Fake3dBackground:export_var("fov", "float")
Fake3dBackground:export_var("scale_3d", "float")

local shader_code = [[
    

    const float CENTER_SCREEN = 0.5;
    
    uniform float fov = 0.5;
    uniform float scale = 0.7;
    uniform vec2 cam_pos = vec2(0, 0) ;
    uniform float cam_rot = 0.75;
    uniform float horizon = 1.0;
    
    vec4 effect(vec4 color, Image tex, vec2 uv, vec2 screen_coords)
    {
        uv -= vec2(CENTER_SCREEN);
        if (uv.y > horizon)
            discard;
        
        vec3 projection = vec3(uv.x, uv.y - horizon - fov, uv.y - horizon);
        vec2 scene = projection.xy / projection.z;
        
        scene *= scale;
        mat2 rotation_matrix = mat2(
            cos(cam_rot), -sin(cam_rot), 
            sin(cam_rot), cos(cam_rot));
        
        scene *= rotation_matrix;
        scene += cam_pos;
        
        vec4 texturecolor = Texel(tex, scene);
        texturecolor.w = abs(horizon-uv.y);
                
        return texturecolor * color;
    }
]]

local shader = love.graphics.newShader(shader_code)

function Fake3dBackground:initialize()
    Sprite.initialize(self)
    self.cam_pos = vec2(0, 0)
    self.cam_rot = 0.5
    self.horizon = 0.75
    self.fov = 0.5
    self.scale_3d = 0.5
    self.cam_time = 0
end

function Fake3dBackground:update(dt)
    self.cam_time = self.cam_time + dt
    self.cam_pos.y = math.sin(self.cam_time)
    self.cam_pos.x = self.cam_time * 4
end

function Fake3dBackground:draw()
    if not self.texture then return end
    
    love.graphics.push("all")
    love.graphics.setShader(shader)
    shader:send("cam_pos", {self.cam_pos:unpack()})
    shader:send("cam_rot", self.cam_rot)
    shader:send("horizon", self.horizon)
    shader:send("fov", self.fov)
    shader:send("scale", self.scale_3d)
    
    Sprite.draw(self)
    
    love.graphics.pop()
end

return Fake3dBackground
