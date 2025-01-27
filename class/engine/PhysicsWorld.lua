--[[

MIT License

Copyright (c) 2020 DekuJuice

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

]]--

-- 3 types of physics bodies
-- Actors - Anything that moves, must be AABBs. Only collide with obstacles
-- Obstacles - Things actors can collide with, such as tilemaps, moving platforms, etc
--             Obstacles can move, but do not interact with each other. Must be AABB, but
--             can use heightmaps to create things such as slopes
-- Areas - Can be any convex polygon shape - Detects when actors or obstacles overlap them
--         but does not perform any sort of collision resolution

-- Collision
-- For collision between actors and obstacles, only collision for actors and obstacles that 
-- are NOT intersecting are checked. This means that if an actor and obstacle somehow overlap,
-- no further collision checks between them will be made.  This is for the sake of crush resolution

local intersect = require("enginelib.intersect")

local SpatialHash = require("class.engine.SpatialHash")
local Object = require("class.engine.Object")
local Actor = require("class.engine.Actor")
local Obstacle = require("class.engine.Obstacle")
local Area = require("class.engine.Area")
local TileMap = require("class.engine.TileMap")

local PhysicsWorld = Object:subclass("PhysicsWorld")

local CELL_SIZE = 16 * 6

local function overlap_interval(a, b, c, d)
    return math.max(a, c), math.min(b, d)
end

function PhysicsWorld:initialize()
    Object.initialize(self)

    self.collidables = {}    
    self.actor_shash = SpatialHash(CELL_SIZE)
    self.obstacle_shash = SpatialHash(CELL_SIZE)
    self.area_shash = SpatialHash(CELL_SIZE)
    -- Tilemaps are a special case, since there likely won't be more than
    -- 2 or 3 collidable layers, we'll just check all of them instead of bothering with spatial hashing it
    self.tilemaps = {}
end

-- For now, processing order of areas is undefined. 
-- This can be changed later if needed
function PhysicsWorld:physics_update(dt)

    local checks = 0
    local ave_nearby = 0
    local area_count = 0
    for area in pairs(self.area_shash:get_objects()) do
        
        area_count = area_count + 1
        local cur = area:get_collide_current()
        if area:get_collision_layer() ~= 0 then
        
            local rmin, rmax = area:get_bounding_box()
            local dim = rmax - rmin
            -- Area Actor intersections
            local nact = self.actor_shash:get_nearby_in_rect(rmin.x, rmin.y, dim.x, dim.y)
            for _, other in ipairs(nact) do
                if bit.band( area:get_collision_layer(), other:get_collision_mask() ) ~= 0 then
                    if intersect.aabb_aabb(rmin, rmax, other:get_bounding_box()) then
                        if cur[other] == nil then
                            area:emit_signal("actor_entered", other)
                        end
                        cur[other] = false

                    end
                end
            end


            -- Area Obstacle intersections
            local no = self.obstacle_shash:get_nearby_in_rect(rmin.x, rmin.y, dim.x, dim.y)
            for _,other in ipairs(no) do
                if bit.band( area:get_collision_layer(), other:get_collision_mask() ) ~= 0 then

                end
            end


            -- Area Area intersections
            local na = self.area_shash:get_nearby_in_rect( rmin.x, rmin.y, dim.x, dim.y)
            for _, other in ipairs(na) do
                checks = checks + 1
                ave_nearby = ave_nearby + 1
                if other ~= area
                and bit.band( area:get_collision_layer() , other:get_collision_mask() ) ~= 0
                and self:has_collidable(other) then
                    if intersect.aabb_aabb(rmin, rmax, other:get_bounding_box()) then
                        if cur[other] == nil then
                            area:emit_signal("area_entered", other)
                        end
                        cur[other] = false
                    end
                end
            end

        end

        for p, is_prev in pairs(cur) do
            if is_prev or not self:has_collidable(p) then
                if p:isInstanceOf(Area) then
                    area:emit_signal("area_exited", p)
                elseif p:isInstanceOf(Obstacle) then
                    area:emit_signal("obstacle_exited", p)
                elseif p:isInstanceOf(Actor) then
                    area:emit_signal("actor_exited", p)
                end
                cur[p] = nil                
            else
                cur[p] = true
            end
        end 
    end
    
    
    


end

function PhysicsWorld:has_collidable(collidable)
    return self.collidables[collidable] ~= nil
end

function PhysicsWorld:add_collidable(collidable)
    self.collidables[collidable] = true

    if collidable:isInstanceOf(Actor) then
        local rmin, rmax = collidable:get_bounding_box()
        local dim = rmax - rmin

        self.actor_shash:add_object(collidable, rmin.x, rmin.y, dim.x, dim.y)
    elseif collidable:isInstanceOf(Obstacle) then
        local rmin, rmax = collidable:get_bounding_box()
        local dim = rmax - rmin

        self.obstacle_shash:add_object(collidable, rmin.x, rmin.y, dim.x, dim.y)
    elseif collidable:isInstanceOf(Area) then
        local rmin, rmax = collidable:get_bounding_box()
        local dim = rmax - rmin

        self.area_shash:add_object(collidable, rmin.x, rmin.y, dim.x, dim.y)
    elseif collidable:isInstanceOf(TileMap) then
        table.insert(self.tilemaps, collidable)
    else
        error("Base collidable should not be instantiated")
    end 
end

function PhysicsWorld:remove_collidable(collidable)
    self.collidables[collidable] = nil
    if collidable:isInstanceOf(Actor) then
        self.actor_shash:remove_object(collidable)
    elseif collidable:isInstanceOf(Obstacle) then
        self.obstacle_shash:remove_object(collidable)
    elseif collidable:isInstanceOf(Area) then
        self.area_shash:remove_object(collidable)
    elseif collidable:isInstanceOf(TileMap) then
        local n = #self.tilemaps
        if n == 1 then
            self.tilemaps[n] = nil
        else
            for i,v in ipairs(self.tilemaps) do
                if v == collidable then
                    self.tilemaps[i] = self.tilemaps[n]
                    self.tilemaps[n] = nil
                    break
                end
            end
        end
    else
        error("Base collidable should not be instantiated")
    end 
end

-- Exclude is so that when the actor is being moved by a moving obstacle,
-- they won't collide with that particular obstacle

function PhysicsWorld:_step_actor_x(actor, sign, exclude, pushed)
    local p = actor:get_position()
    local step = vec2(sign, 0)
    local rmin, rmax = actor:get_bounding_box() -- old bounding box
    local nmin, nmax = rmin + step, rmax + step -- new bounding box
    local nearby = self.obstacle_shash:get_nearby_in_rect( nmin.x, nmin.y, (nmax - nmin):unpack() ) 
    local nearby_tiles = {}

    -- Include tilemap obstacles in our collision check
    -- Due to memory optimization with get_obstacles, we need to store 
    -- the tile obstacles separately to return them to the object pool
    for _, tilemap in ipairs(self.tilemaps) do
        if tilemap:get_collision_enabled() then
            local t = tilemap:get_obstacles_in_rect(
                tilemap:transform_to_map(nmin),
                tilemap:transform_to_map(nmax)
            )

            for _,o in ipairs(t) do
                table.insert(nearby, o)
                table.insert(nearby_tiles, o)
            end
        end
    end

    local obstacle_hit = false

    for _, obstacle in ipairs(nearby) do
        if bit.band( obstacle:get_collision_layer() , actor:get_collision_mask() ) == 0 then
            goto CONTINUE
        end

        local omin, omax = obstacle:get_bounding_box()

        if obstacle == exclude or not intersect.aabb_aabb_no_touch(nmin, nmax, omin, omax) then
            goto CONTINUE
        end

        -- if no heightmap, treat obstacle as aabb
        local hm = obstacle:get_heightmap()
        if #hm == 0 and not intersect.aabb_aabb_no_touch(rmin, rmax, omin, omax) then

            if obstacle:has_tag("one_way") then
                goto CONTINUE
            end


            obstacle_hit = true
        else

            -- No collision if actor was previously inside the obstacle
            if intersect.aabb_aabb_no_touch(rmin, rmax, omin, omax) then
                local ox1, ox2 = overlap_interval(rmin.x, rmax.x, omin.x, omax.x)
                local omax_height = 0
                for x = ox1, ox2 - 1 do
                    omax_height = math.max(omax_height, obstacle:get_height(x - omin.x))
                end

                if obstacle:get_flip_v() then
                    local b_edge = omin.y + omax_height
                    if rmin.y < b_edge then
                        goto CONTINUE
                    end
                else
                    local t_edge = omax.y - omax_height
                    if rmax.y > t_edge then
                        goto CONTINUE
                    end
                end
            end

            local x1, x2 = overlap_interval(nmin.x, nmax.x, omin.x, omax.x)

            local max_height = 0
            for x = x1, x2 - 1 do
                max_height = math.max(max_height, obstacle:get_height(x - omin.x))
            end

            if obstacle:get_flip_v() then                
                local b_edge = omin.y + max_height

                if nmin.y < omin.y then
                    if obstacle:has_tag("one_way") then
                        goto CONTINUE
                    end
                    obstacle_hit = true

                elseif nmin.y < b_edge then

                    local climb_dist = b_edge - nmin.y

                    if climb_dist > actor:get_climb_dist() then

                        if obstacle:has_tag("one_way") then
                            goto CONTINUE
                        else                    
                            obstacle_hit = true
                            goto CONTINUE
                        end
                    end

                    for i = 1, climb_dist do
                        if self:_step_actor_y(actor, 1, exclude) then
                            obstacle_hit = true
                            actor:translate(vec2(0, -(i - 1)))
                            break
                        end
                    end
                end

            else
                local t_edge = omax.y - max_height

                if nmax.y > omax.y then
                    if obstacle:has_tag("one_way") then
                        goto CONTINUE
                    end

                    obstacle_hit = true
                elseif nmax.y > t_edge then

                    local climb_dist = nmax.y - t_edge
                    if climb_dist > actor:get_climb_dist() then
                        if obstacle:has_tag("one_way") then
                            goto CONTINUE
                        else
                            obstacle_hit = true
                            goto CONTINUE
                        end
                    end

                    for i = 1, nmax.y - t_edge do
                        if self:_step_actor_y(actor, -1, exclude) then
                            obstacle_hit = true
                            actor:translate(vec2(0, i - 1))
                            break
                        end
                    end
                end
            end
        end


        if obstacle_hit then
            if pushed and obstacle:has_tag("no_crush") then
                obstacle_hit = false
            else
                break
            end
        end


        ::CONTINUE::
    end

    if not obstacle_hit then
        actor:translate(step)
    end

    for _, o in ipairs(nearby_tiles) do
        TileMap:pool_push_obstacle(o)
    end

    return obstacle_hit
end

function PhysicsWorld:_step_actor_y(actor, sign, exclude, pushed)
    local p = actor:get_position()
    local step = vec2(0, sign)
    local rmin, rmax = actor:get_bounding_box()

    local nmin, nmax = rmin + step, rmax + step
    local nearby = self.obstacle_shash:get_nearby_in_rect( nmin.x, nmin.y, (nmax - nmin):unpack() ) 
    local nearby_tiles = {}

    for _, tilemap in ipairs(self.tilemaps) do
        if tilemap:get_collision_enabled() then
            local t = tilemap:get_obstacles_in_rect(
                tilemap:transform_to_map(nmin),
                tilemap:transform_to_map(nmax)
            )

            for _,o in ipairs(t) do
                table.insert(nearby, o)
                table.insert(nearby_tiles, o)
            end
        end
    end

    local obstacle_hit = false

    for _, obstacle in ipairs(nearby) do
        if bit.band( obstacle:get_collision_layer(), actor:get_collision_mask() ) == 0 then
            goto CONTINUE
        end

        local omin, omax = obstacle:get_bounding_box()

        if obstacle == exclude or not intersect.aabb_aabb_no_touch(nmin, nmax, omin, omax) then
            goto CONTINUE
        end

        if obstacle:has_tag("one_way") and actor:get_jump_down_one_way() then
            goto CONTINUE
        end

        local hm = obstacle:get_heightmap()
        if #hm == 0 and not intersect.aabb_aabb_no_touch(rmin, rmax, omin, omax) then

            if obstacle:has_tag("one_way") and rmax.y > omin.y then
                goto CONTINUE
            end

            obstacle_hit = true
        else

            if intersect.aabb_aabb_no_touch(rmin, rmax, omin, omax) then
                local ox1, ox2 = overlap_interval(rmin.x, rmax.x, omin.x, omax.x)
                local omax_height = 0
                for x = ox1, ox2 - 1 do
                    omax_height = math.max(omax_height, obstacle:get_height(x - omin.x))
                end

                if obstacle:get_flip_v() then
                    local b_edge = omin.y + omax_height
                    if rmin.y < b_edge then
                        goto CONTINUE
                    end
                else
                    local t_edge = omax.y - omax_height
                    if rmax.y > t_edge then
                        goto CONTINUE
                    end
                end
            end

            local x1, x2 = overlap_interval(nmin.x, nmax.x, omin.x, omax.x)
            local max_height = 0
            for x = x1, x2 - 1 do
                max_height = math.max(max_height, obstacle:get_height(x - omin.x))
            end

            if obstacle:get_flip_v() then
                local b_edge = omin.y + max_height

                if obstacle:has_tag("one_way") and rmin.y < b_edge then
                    goto CONTINUE
                end

                if nmin.y < b_edge then
                    obstacle_hit = true
                end
            else
                local t_edge = omax.y - max_height

                if obstacle:has_tag("one_way") and rmax.y > t_edge then
                    goto CONTINUE
                end

                if nmax.y > t_edge then
                    obstacle_hit = true
                end
            end

        end

        if obstacle_hit then
            if pushed and obstacle:has_tag("no_crush") then
                obstacle_hit = false
            else
                break
            end
        end

        ::CONTINUE::
    end

    if not obstacle_hit then
        actor:translate(step)
    end    

    for _, o in ipairs(nearby_tiles) do
        TileMap:pool_push_obstacle(o)
    end

    return obstacle_hit
end

-- Delta must not be 0
-- Returns absolute step 
-- Assumed x step taken first
local function get_step_size(delta)

    local ax = math.abs(delta.x)
    local ay = math.abs(delta.y)

    if ax == 0 or ay == 0 then
        return ax, ay
    end

    return math.ceil(ax / ay), math.ceil(ay / ax)
end

function PhysicsWorld:move_actor(actor, delta)
    assert(self:has_collidable(actor), "Actor is not in physics world")
    assert(actor:isInstanceOf(Actor), "move_actor expects an anctor")

    if delta == vec2.zero then return end

    local cling_dist = actor:get_cling_dist()

    local x_remainder = delta.x
    local y_remainder = delta.y

    local xsign = math.sign(delta.x)
    local ysign = math.sign(delta.y)

    local step_x, step_y = get_step_size(delta)

    local next_step_x = x_remainder ~= 0
    while math.abs(x_remainder) + math.abs(y_remainder) > 0 do

        if next_step_x then
            local capped_step = math.min(step_x, math.abs(x_remainder))
            local hit = false
            for i = 1, capped_step do
                if self:_step_actor_x(actor, xsign) then
                    hit = true
                    actor.on_wall = true

                    if xsign == 1 then
                        actor.on_wall_right = true
                    elseif xsign == -1 then
                        actor.on_wall_left = true
                    end

                    break
                end

                if actor.on_ground or actor.on_ground_prev and cling_dist > 0 then
                    local clung = false

                    for j = 1, cling_dist + 1 do
                        if self:_step_actor_y(actor, 1) then
                            clung = true
                            break
                        end
                    end

                    if clung then
                        actor.on_ground = true
                    else
                        actor:translate(vec2(0, -(cling_dist + 1)))
                    end
                end

            end

            if hit then
                x_remainder = 0
            else
                x_remainder = x_remainder - capped_step * xsign
            end

        else
            local capped_step = math.min(step_y, math.abs(y_remainder))
            local hit = false
            for i = 1, capped_step do
                if self:_step_actor_y(actor, ysign) then
                    hit = true
                    break
                end
            end
            if hit then
                y_remainder = 0
                if ysign == 1 then
                    actor.on_ground = true
                elseif ysign == -1 then
                    actor.on_ceil = true
                end

            else
                y_remainder = y_remainder - capped_step * ysign
            end
        end

        next_step_x = not next_step_x
    end

    self:update_collidable_position(actor)

end

function PhysicsWorld:_step_obstacle_x(obstacle, sign)
    local step = vec2(sign, 0)

    local rmin, rmax = obstacle:get_bounding_box()
    local nmin, nmax = rmin + step, rmax + step
    local dim = rmax - rmin

    local nearby = self.actor_shash:get_nearby_in_rect(rmin.x, rmin.y, dim:unpack())

    for _, actor in ipairs(nearby) do
        if bit.band( obstacle:get_collision_mask(), actor:get_collision_layer() ) == 0 then
            goto CONTINUE
        end

        local amin, amax = actor:get_bounding_box()

        local x1, x2 = overlap_interval(rmin.x, rmax.x, amin.x, amax.x)
        local y1, y2 = overlap_interval(rmin.y, rmax.y, amin.y, amax.y)

        if x2 - x1 > 0 then

            if actor:get_stick_moving_ground() and amax.y == rmin.y  then
                self:_step_actor_x(actor, sign, obstacle)
            elseif actor:get_stick_moving_ceil() and amin.y == rmax.y then
                self:_step_actor_x(actor, sign, obstacle)
            end
        elseif y2 - y1 > 0 then

            local blocked = false

            if amin.x == rmax.x and ( sign == 1 or actor:get_stick_moving_wall_left() ) then
                blocked = self:_step_actor_x(actor, sign, obstacle, true)
            elseif amax.x == rmin.x and ( sign == -1 or actor:get_stick_moving_wall_right() ) then
                blocked = self:_step_actor_x(actor, sign, obstacle, true)
            end

            if blocked and not obstacle:has_tag("no_crush") then
                actor:emit_signal("actor_crushed", obstacle)
            end

        end

        ::CONTINUE::
    end


    obstacle:translate(step)
end

function PhysicsWorld:_step_obstacle_y(obstacle, sign)
    local step = vec2(0, sign)

    local rmin, rmax = obstacle:get_bounding_box()
    local nmin, nmax = rmin + step, rmax + step
    local dim = rmax - rmin

    local nearby = self.actor_shash:get_nearby_in_rect(rmin.x, rmin.y, dim:unpack())

    for _, actor in ipairs(nearby) do

        if bit.band( obstacle:get_collision_mask(),  actor:get_collision_layer() ) == 0 then
            goto CONTINUE
        end

        local amin, amax = actor:get_bounding_box()

        local x1, x2 = overlap_interval(rmin.x, rmax.x, amin.x, amax.x)
        local y1, y2 = overlap_interval(rmin.y, rmax.y, amin.y, amax.y)

        if x2 - x1 > 0 then
            local blocked = false
            if amax.y == rmin.y and (sign == -1 or actor:get_stick_moving_ground() )  then
                blocked = self:_step_actor_y(actor, sign, obstacle, true)
            elseif amin.y == rmax.y and (sign == 1 or actor:get_stick_moving_ceil() ) then
                blocked = self:_step_actor_y(actor, sign, obstacle, true)
            end

            if blocked and not obstacle:has_tag("no_crush") then
                actor:crushed()
            end

        elseif y2 - y1 > 0 then

            if amin.x == rmax.x and actor:get_stick_moving_wall_left() then
                self:_step_actor_y(actor, sign, obstacle)
            elseif amax.x == rmin.x and actor:get_stick_moving_wall_right() then
                self:_step_actor_y(actor, sign, obstacle)
            end

        end

        ::CONTINUE::

    end

    obstacle:translate(step)
end

function PhysicsWorld:move_obstacle(obstacle, delta)
    assert(self:has_collidable(obstacle), "Obstacle is not in physics world")
    assert(obstacle:isInstanceOf(Obstacle), "move_obstacle expects an obstacle")

    if delta == vec2.zero then return end

    local x_remainder = delta.x
    local y_remainder = delta.y

    local xsign = math.sign(delta.x)
    local ysign = math.sign(delta.y)

    local step_x, step_y = get_step_size(delta)

    local next_step_x = x_remainder ~= 0
    while math.abs(x_remainder) + math.abs(y_remainder) > 0 do
        if next_step_x then
            local capped_step = math.min(step_x, math.abs(x_remainder))

            for i = 1, capped_step do
                self:_step_obstacle_x(obstacle, xsign)
            end

            x_remainder = x_remainder - capped_step * xsign
        else
            local capped_step = math.min(step_y, math.abs(y_remainder))

            for i = 1, capped_step do
                self:_step_obstacle_y(obstacle, ysign)
            end

            y_remainder = y_remainder - capped_step * ysign
        end

        next_step_x = not next_step_x
    end

    self:update_collidable_position(obstacle)
end

-- Updates cached positions without checking for any intersections
function PhysicsWorld:update_collidable_position(collidable)
    assert(self:has_collidable(collidable))

    local rmin, rmax = collidable:get_bounding_box()
    local dim = rmax - rmin

    if collidable:isInstanceOf(Actor) then
        self.actor_shash:update_object(collidable, rmin.x, rmin.y, dim.x, dim.y)
    elseif collidable:isInstanceOf(Obstacle) then
        self.obstacle_shash:update_object(collidable, rmin.x, rmin.y, dim.x, dim.y)
    elseif collidable:isInstanceOf(Area) then
        self.area_shash:update_object(collidable, rmin.x, rmin.y, dim.x, dim.y)
    end
end

function PhysicsWorld:debug_draw()
    -- Draw collision boxes
    for collidable in pairs(self.collidables) do
        if collidable:is_visible_in_tree() and collidable.draw_collision then collidable:draw_collision() end
    end
end

-- Query funcs

local function intersect_point_obstacle(p, ob)
    local rmin, rmax = ob:get_bounding_box()
    if not intersect.point_aabb(p, rmin, rmax) then
        return false
    end

    local hm = ob:get_heightmap()
    if #hm ~= 0 then
        local h = ob:get_height(p.x - rmin.x)

        if ob:get_flip_v() then
            return p.y < (rmin.y + h)
        else
            return p.y > (rmax.y - h)
        end

    end

    return true
end

function PhysicsWorld:get_nearby(rmin, rmax, mask, include_actor, include_obstacle, include_area)
    local result = {}
    result._tiles = {}
    
    assert(mask ~= nil, "A mask must be provided")
    
    local dim = rmax - rmin
    
    if include_actor then
        for _,actor in ipairs(self.actor_shash:get_nearby_in_rect(rmin.x, rmin.y, dim.x, dim.y)) do
            if bit.band(actor:get_collision_layer(), mask) ~= 0 then
                table.insert(result, actor)
            end
        end
    end

    if include_obstacle then
        for _,obstacle in ipairs(self.obstacle_shash:get_nearby_in_rect(rmin.x, rmin.y, dim.x, dim.y)) do
            if bit.band(obstacle:get_collision_layer(), mask) ~= 0 then
                table.insert(result, obstacle)
            end
        end
        
        for _, tilemap in ipairs(self.tilemaps) do
        
            if bit.band(tilemap:get_collision_layer(), mask) ~= 0 then
                local obs = tilemap:get_obstacles_in_rect( tilemap:transform_to_map( rmin ), tilemap:transform_to_map( rmax ))
                for _, o in ipairs(obs) do
                    table.insert(result, o)
                    table.insert(result._tiles, o)
                end
            end
        end
        
    end

    if include_area then
        for _,area in ipairs(self.area_shash:get_nearby_in_rect(rmin.x, rmin.y, dim.x, dim.y)) do
            if bit.band(area:get_collision_layer(), mask) ~= 0 then
                table.insert(result, area)
            end
        end
    end

    return result
end

function PhysicsWorld:query_point(p, mask, include_actor, include_obstacle, include_area)

    local nearby = self:get_nearby(p, p, mask, include_actor, include_obstacle, include_area)
    
    -- Filter anything that isn't actually intersecting
    for i = #nearby, 1, -1 do
        local o = nearby[i]
        local omin, omax = o:get_bounding_box()
        
        if not intersect.point_aabb(p, omin, omax) then goto REMOVE end
        
        if o:isInstanceOf(Obstacle) then
            local hm = o:get_heightmap()
            if #hm == 0 then goto CONTINUE end
            
            local h = o:get_height(p.x - omin.x)
            if (o:get_flip_v() and p.y < (omin.y + h))
            or (not o:get_flip_v() and p.y > (omax.y - h)) then
                goto CONTINUE
            end            
        end
        
        ::REMOVE::
        
        table.remove(nearby, i)
        
        ::CONTINUE::
    end
    
    return nearby
end

function PhysicsWorld:query_aabb(rmin, rmax, mask)

end

function PhysicsWorld:query_ray(origin, dir, mask)

end

-- Obstacles from tilemaps are pooled, use this method to return them
function PhysicsWorld:pool_push_query(result)
    for _,v in ipairs(result._tiles) do
        TileMap.pool_push_obstacle(v)
    end
end

return PhysicsWorld