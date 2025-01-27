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
local Color = require("class.engine.Color")
local Node = require("class.engine.Node")
local SelectResourceModal = require("class.editor.SelectResourceModal")
local SignalModal = require("class.editor.SignalModal")
local ImportedResource = require("class.engine.resource.ImportedResource")

local Inspector = Node:subclass("Inspector")
Inspector.static.dontlist = true
Inspector:define_get_set("inspected_object")
Inspector:define_get_set("auto_inspect_nodes")

function Inspector:initialize()
    Node.initialize(self)
    self.is_open = true
    self.object = nil
    self.auto_inspect_nodes = true
    self.select_resource_modal = SelectResourceModal()
    self.signal_modal = SignalModal()
end

function Inspector:parented(parent)
    parent:add_action("Show Inspector", function()
            self.is_open = not self.is_open
        end)
end

local function get_hint_value(obj, name, hints, default)
    local h = hints[name]
    
    if h == nil then return default end
    
    if type(h) == "function" then
        return h(obj)
    end
    
    return h    
end

local function sort_connection_comp(a, b)
    return a.target:get_absolute_path() < b.target:get_absolute_path()
end

function Inspector:_draw_edit_widget(obj, ptype, export_hints, old_val)
    local filter = export_hints.filter
    
    local changed = false
    local finalized = false
    local new_val = old_val
    local merge_mode
    
    if ptype == "string" then
        imgui.PushItemWidth(-1)
        local max_len = get_hint_value(obj, "max_len", export_hints, 64)
        
        changed, new_val = imgui.InputText("##StringInput", old_val, max_len)
        finalized = imgui.IsItemDeactivatedAfterEdit()
        merge_mode = "merge_ends"
        
    elseif ptype == "float" then
    
        local velo, smin, smax = 
            get_hint_value(obj, "speed", export_hints, 0.01),
            get_hint_value(obj, "min", export_hints, -math.huge),
            get_hint_value(obj, "max", export_hints, math.huge)        
        
        imgui.PushItemWidth(-1)
        changed, new_val = imgui.DragFloat("##FloatSlider", old_val, velo, smin, smax)
        finalized = imgui.IsItemDeactivatedAfterEdit()
        merge_mode = "merge_ends"
    elseif ptype == "int" then
        local velo, smin, smax =
            get_hint_value(obj, "speed", export_hints, 0.01),
            get_hint_value(obj, "min", export_hints, -math.huge),
            get_hint_value(obj, "max", export_hints, math.huge)     
        
        imgui.PushItemWidth(-1)
        changed, new_val = imgui.DragInt("##IntSlider", old_val, velo, smin, smax)
        finalized = imgui.IsItemDeactivatedAfterEdit()
        merge_mode = "merge_ends"
    elseif ptype:find("vec2") == 1 then
        local velo, smin, smax = 
            get_hint_value(obj, "speed", export_hints, 0.01),
            get_hint_value(obj, "min", export_hints, -math.huge),
            get_hint_value(obj, "max", export_hints, math.huge)  
        
        imgui.PushItemWidth(-1)
        
        local c, nx, ny
        if ptype:find("int") then
            c, nx, ny = imgui.DragInt2("##Vec2Slider", old_val.x, old_val.y, velo, smin, smax)
        else
            c, nx, ny = imgui.DragFloat2("##Vec2Slider", old_val.x, old_val.y, velo, smin, smax)
        end
        
        finalized = imgui.IsItemDeactivatedAfterEdit()
        new_val = vec2(nx, ny)            
        changed = c
        merge_mode = "merge_ends"
    elseif ptype == "color" then
        local r,g,b,a = old_val[1], old_val[2], old_val[3], old_val[4]
        changed, r, g, b, a = imgui.ColorEdit4("##ColorEdit4f", r,g,b,a, {"ImGuiColorEditFlags_Float"})
        finalized = imgui.IsItemDeactivatedAfterEdit()
        new_val = Color()
        new_val[1] = r
        new_val[2] = g
        new_val[3] = b
        new_val[4] = a      

        merge_mode = "merge_ends"
    elseif ptype == "bool" then
        changed, new_val = imgui.Checkbox("##Checkbox", old_val)
        finalized = changed
    elseif ptype == "bitmask" then

        if imgui.CollapsingHeader("Bitmask") then
            local bits = export_hints.bits or 31
            for i = 1, bits do
                local b = 2^(i - 1)
                local checked = bit.band(b, old_val) == b
                if imgui.Checkbox(("%d##bit%d"):format(i-1,i), checked) then
                    new_val = bit.bxor(old_val, b)
                    finalized = true
                end
            end
        end
    elseif ptype == "array" then
        assert(export_hints.array_type ~= nil, ("A type for the array contents must be specified (%s, %s)"):format(tostring(obj), ptype))
        assert(export_hints.init_value ~= nil, ("An init value must be specified (%s, %s)"):format(tostring(obj), ptype))
        
        if imgui.CollapsingHeader("Array") then
            local cx = imgui.GetCursorPosX()
            
            local n = #old_val
            imgui.Text(("Count: %d"):format(n))        
            
            local craw = imgui.GetContentRegionAvailWidth()
            
            imgui.SameLine()
            imgui.SetCursorPosX(cx + craw - 58)
            
            if imgui.Button(IconFont.MINUS) and n > 0 then
                new_val = table.copy(old_val)
                table.remove(new_val)
                changed = true
                finalized = true
            end
            
            imgui.SameLine()
            
            if imgui.Button(IconFont.PLUS) then
                new_val = table.copy(old_val)
                table.insert(new_val, export_hints.init_value)
                changed = true
                finalized = true
            end
            
            for i,aval in ipairs(new_val) do
                imgui.PushID(("%d"):format(i))
                local naval, achanged, afinalized, amerge_mode 
                    = self:_draw_edit_widget(obj, export_hints.array_type, export_hints, aval )
                
                if achanged then
                    new_val = table.copy(old_val)
                    new_val[i] = naval
                    changed = achanged
                    finalized = afinalized
                    merge_mode = amerge_mode
                end
                
                imgui.PopID()
            end
            
        end

    elseif ptype == "resource" then
        assert(export_hints.resource_type ~= nil, ("A resource type must be specified (%s, %s)"):format(tostring(obj), ptype))
        
        if imgui.Button("Select") then
            self.select_resource_modal:open(  export_hints.resource_type.static.extensions )
        end
        
        local r, fin = self.select_resource_modal:draw()
        changed = fin
        finalized = fin
        if fin then
            new_val = r
        end
        
        imgui.SameLine()
        imgui.Text("Path:")
        imgui.SameLine()
        if old_val then
            imgui.Text(old_val:get_filepath())
        else
            imgui.Text("No Resource")
        end

    elseif ptype == "enum" then
        imgui.PushItemWidth(-1)
        
        local enums = get_hint_value(obj, "enum", export_hints, {})
        if imgui.BeginCombo("##enum", tostring(old_val)) then
            if get_hint_value(obj, "include_nil", export_hints, false) then
                if imgui.Selectable("nil", old_val == nil) and old_val ~= nil then
                    new_val = nil
                    changed = true
                    finalized = true
                end
            end
            
            for _,enum in ipairs(enums) do
                local is_selected = enum == val
                if imgui.Selectable(tostring(enum), is_selected) and not is_selected then
                    new_val = enum
                    changed = true
                    finalized = true
                end
                imgui.SetItemDefaultFocus()
                
            end
            imgui.EndCombo()
        end
    end 
    
    if finalized then
        merge_mode = nil
    end
    
    return new_val, changed, finalized, merge_mode
end

function Inspector:_draw_property_widget(obj, ep)
    local is_node = obj:isInstanceOf(Node)
    
    local ptype = ep.type

    -- "data" type is any type that needs its own specialized editor, so we don't show it here
    if ptype == "data" then
        return
    end

    local name = ep.name
    local export_hints = ep.export_hints
    local display_name = export_hints.display_name or name
    local filter = export_hints.filter

    local getter = ("get_%s"):format(name)
    local setter = ("set_%s"):format(name)
    local val = obj[getter](obj)

    imgui.PushID(name)
    imgui.TableSetColumnIndex(0)
    imgui.AlignTextToFramePadding()
    imgui.Text(display_name)
    imgui.TableSetColumnIndex(1)
    
    local new_val, changed, finalized, merge_mode = self:_draw_edit_widget(obj, ptype, export_hints, val)
        
    imgui.PopID()
    
    if filter and not (filter(obj, new_val))  then
        new_val = val
    end
    
    if changed or finalized then
        if is_node then
            
            local editor = self:get_parent()
            local model = editor:get_active_scene_model()
            local cmd = model:create_command(("Change value %s"):format(display_name), merge_mode)
            cmd:add_do_var(obj, name, new_val)
            cmd:add_undo_var(obj, name, val)
            model:commit_command(cmd)
        else
            obj[setter](obj, new_val)
            obj:set_has_unsaved_changes(true)
        end
    
    end
end

function Inspector:_draw_node_inspector()
    local node = self.inspected_object
    local editor = self:get_parent()
    local model = editor:get_active_scene_model()
    local tree = model:get_tree()

    imgui.Text( ("%s: %s"):format(node.class.name, node:get_name()))
    imgui.Text( ("Path: %s"):format(node:get_absolute_path()))
    imgui.Separator()
    if imgui.CollapsingHeader("Tags") then

        local changed, nv = imgui.InputText("Add New Tag", "", 128)
        local finalized = imgui.IsItemDeactivatedAfterEdit()

        if finalized and nv ~= "" and not node:has_tag(nv) then
            local cmd = model:create_command("Add Tag")
            cmd:add_do_func(function()
                node:add_tag(nv)
            end)
            
            cmd:add_undo_func(function()
                node:remove_tag(nv)
            end)
            model:commit_command(cmd)
        end

        local tags = {}
        for k,v in pairs(node:get_tags()) do
            table.insert(tags, k)
        end
        table.sort(tags)

        for _,t in ipairs(tags) do
            imgui.Text(t)
            imgui.SameLine()
            if imgui.Button(IconFont.MINUS) then
                local cmd = model:create_command("Remove Tag")
                cmd:add_do_func(function()
                    node:remove_tag(t)
                end)
                cmd:add_undo_func(function()
                    node:add_tag(t)
                end)
                model:commit_command(cmd)
            end
        end                  
    end
    imgui.Separator()
    
    -- Signal editor
    if imgui.CollapsingHeader("Signals") then
        local class = node.class
        local signals = {}
        for name in pairs(class:get_signals()) do
            table.insert(signals, name)
        end
        table.sort(signals)
        
        
        if imgui.BeginTable("##SignalTable", 2, {"ImGuiTableFlags_RowBg"}) then

            local tree_flags = {"ImGuiTreeNodeFlags_DefaultOpen"}
            for _, name in ipairs(signals) do
                local connections = node:get_connections(name)
                table.sort(connections, sort_connection_comp)
                
                imgui.TableNextRow()
                imgui.TableSetColumnIndex(1)
                if imgui.Button(("%s##%s"):format(IconFont.PLUS, name)) then
                    editor:get_node("SignalModal"):open( name )
                end

                imgui.TableSetColumnIndex(0)
                if imgui.TreeNodeEx(name, tree_flags) then
                    
                    for _, c in ipairs(connections) do
                        if c.target:get_tree() == tree then
                            imgui.TableNextRow()
                            imgui.TableSetColumnIndex(0)
                            
                            imgui.Text(("%s : %s"):format(c.target:get_name(), c.method))
                            if imgui.IsItemHovered() then
                                imgui.BeginTooltip()
                                imgui.Text(c.target:get_relative_path(node))
                                imgui.EndTooltip()
                            end
                            
                            imgui.TableSetColumnIndex(1)
                            
                            if imgui.Button(IconFont.TRASH) then
                                local cmd = model:create_command("Disconnect signal")
                                local target = c.target
                                local method = c.method
                                local n = name
                                cmd:add_do_func(function()
                                    node:disconnect(n, target, method )
                                end)
                                
                                cmd:add_undo_func(function()
                                    node:connect(n, target, method)
                                end)
                                
                                model:commit_command(cmd)
                            end
                        end
                    end
                    
                    
                    imgui.TreePop()    
                end
                
            end
            imgui.EndTable()
        end        
    end
    
    imgui.Separator()
    
end

function Inspector:_draw_resource_inspector()
    local res = self.inspected_object

    local rtype = res.class.name
    local path = res:get_filepath() or ("Unsaved Resource")

    imgui.Text( ("Resource: %s"):format(rtype))

    if res:get_has_unsaved_changes() then
        imgui.SameLine()
        imgui.TextColored( 1, 1, 0, 1,  ("(%s Unsaved changes!)"):format(IconFont.ALERT_TRIANGLE))
    end

    imgui.SetCursorPosY(imgui.GetCursorPosY() + 3)
    imgui.Text( ("Path: %s"):format(path) )
    imgui.Separator()
    if imgui.Button(("%s Save changes"):format(IconFont.SAVE)) then 
        if res:get_filepath() then
            resource.save_resource(res)
        end
    end
    imgui.Separator()

end

function Inspector:draw()
    local editor = self:get_parent()

    if imgui.BeginMainMenuBar() then
        if imgui.BeginMenu("View") then
            editor:_menu_item("Show Inspector", self.is_open)
            imgui.EndMenu()
        end
        imgui.EndMainMenuBar()
    end

    if not self.is_open then
        return
    end

    local model = editor:get_active_scene_model()

    local window_flags = {}
    imgui.SetNextWindowSize(800, 600, {"ImGuiCond_FirstUseEver"})

    local flags = {}
    local should_draw, open = imgui.Begin("Inspector", self.is_open, flags)
    self.is_open = open

    if should_draw then
        if self.auto_inspect_nodes then
            self.inspected_object = editor:get_active_scene_model():get_selected_nodes()[1]
        end

        if self.inspected_object then
            local is_node = self.inspected_object:isInstanceOf(Node)
            if is_node then
                self:_draw_node_inspector()
            else
                self:_draw_resource_inspector()
            end

            local table_flags = {
                "ImGuiTableFlags_Resizable",
                "ImGuiTableFlags_RowBg",
            }

            if imgui.BeginTable("##Properties", 2, table_flags, 0, 0) then
                local class = self.inspected_object.class
                while class do
                    local static = rawget(class, "static")
                    if static then
                        local exported = rawget(static, "exported_vars")
                        if exported then
                            for _,ep in ipairs(exported) do
                                imgui.TableNextRow()
                                self:_draw_property_widget(self.inspected_object, ep)
                            end
                        end
                    end
                    class = class.super
                end
            end
            imgui.EndTable()
        else
            imgui.Text("Nothing selected")
        end

    end

    imgui.End()
end

return Inspector