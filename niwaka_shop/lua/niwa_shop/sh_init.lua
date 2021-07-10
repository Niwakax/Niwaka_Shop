--[[-------------------------------------------------------------------

    NIWAKA SHOP : ADDONS

    The script was based on the V1 of the pointshop I decided to redo a new version in much more modern design

    V1 Pointshop : https://pointshop.burt0n.net/

    Script made by Niwaka (https://steamcommunity.com/id/NiwakaDarling/)
    Creation : 05/07/2021

    /!\ Don't sell/use/reproduce without author's agreement /!\    		

    /!\ Please leave this for credits/!\ 

---------------------------------------------------------------------]]

PS = {}
PS.__index = PS

PS.Items = {}
PS.Categories = {}
PS.ClientsideModels = {}

include("sh_config.lua")
include("sh_player_extension.lua")

function PS:ValidateItems(items)
	if type(items) ~= "table" then return {} end
	
	for item_id, item in pairs(items) do
		if not self.Items[item_id] then
			items[item_id] = nil
		end
	end
	
	return items
end

function PS:ValidatePoints(points)
	if type(points) != "number" then return 0 end
	
	return points >= 0 and points or 0
end

function PS:FindCategoryByName(cat_name)
	for id, cat in pairs(self.Categories) do
		if cat.Name == cat_name then
			return cat
		end
	end
	
	return false
end

function PS:Initialize()
	if SERVER then self:LoadDataProvider() end
	if SERVER and self.Config.CheckVersion then self:CheckVersion() end

	self:LoadItems()
end

function PS:LoadItems()	
	local _, dirs = file.Find("niwa_shop/items/*", "LUA")
	
	for _, category in pairs(dirs) do
		local f, _ = file.Find("niwa_shop/items/" .. category .. "/__category.lua", "LUA")
		
		if #f > 0 then
			CATEGORY = {}
			
			CATEGORY.Name = ""
			CATEGORY.Icon = ""
			CATEGORY.Order = 0
			CATEGORY.AllowedEquipped = -1
			CATEGORY.AllowedUserGroups = {}
			CATEGORY.CanPlayerSee = function() return true end
			CATEGORY.ModifyTab = function(tab) return end
			
			if SERVER then AddCSLuaFile("niwa_shop/items/" .. category .. "/__category.lua") end
			include("niwa_shop/items/" .. category .. "/__category.lua")
			
			if not PS.Categories[category] then
				PS.Categories[category] = CATEGORY
			end
			
			local files, _ = file.Find("niwa_shop/items/" .. category .. "/*.lua", "LUA")
			
			for _, name in pairs(files) do
				if name ~= "__category.lua" then
					if SERVER then AddCSLuaFile("niwa_shop/items/" .. category .. "/" .. name) end
					
					ITEM = {}
					
					ITEM.__index = ITEM
					ITEM.ID = string.gsub(string.lower(name), ".lua", "")
					ITEM.Category = CATEGORY.Name
					ITEM.Price = 0
										
					ITEM.AdminOnly = false
					ITEM.AllowedUserGroups = {}
					ITEM.SingleUse = false
					ITEM.NoPreview = false
					
					ITEM.CanPlayerBuy = true
					ITEM.CanPlayerSell = true
					
					ITEM.CanPlayerEquip = true
					ITEM.CanPlayerHolster = true

					ITEM.OnBuy = function() end
					ITEM.OnSell = function() end
					ITEM.OnEquip = function() end
					ITEM.OnHolster = function() end
					ITEM.OnModify = function() end
					ITEM.ModifyClientsideModel = function(ITEM, ply, model, pos, ang)
						return model, pos, ang
					end
					
					include("niwa_shop/items/" .. category .. "/" .. name)
					
					if not ITEM.Name then
						ErrorNoHalt("[POINTSHOP] Item missing name: " .. category .. '/' .. name .. "\n")
						continue
					elseif not ITEM.Price then
						ErrorNoHalt("[POINTSHOP] Item missing price: " .. category .. '/' .. name .. "\n")
						continue
					elseif not ITEM.Model and not ITEM.Material then
						ErrorNoHalt("[POINTSHOP] Item missing model or material: " .. category .. '/' .. name .. "\n")
						continue
					end
										
					if ITEM.Model then
						util.PrecacheModel(ITEM.Model)
					end
					
					local item = ITEM
					
					for prop, val in pairs(item) do
						if type(val) == "function" then
							hook.Add(prop, "PS_Item_" .. item.Name .. "_" .. prop, function(...)
								for _, ply in pairs(player.GetAll()) do
									if ply:PS_HasItemEquipped(item.ID) then
										item[prop](item, ply, ply.PS_Items[item.ID].Modifiers, unpack({...}))
									end
								end
							end)
						end
					end

					self.Items[ITEM.ID] = ITEM
					
					ITEM = nil
				end
			end
			
			CATEGORY = nil
		end
	end
end