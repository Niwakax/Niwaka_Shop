--[[-------------------------------------------------------------------

    NIWAKA SHOP : ADDONS

    The script was based on the V1 of the pointshop I decided to redo a new version in much more modern design

    V1 Pointshop : https://pointshop.burt0n.net/

    Script made by Niwaka (https://steamcommunity.com/id/NiwakaDarling/)
    Creation : 05/07/2021

    /!\ Don't sell/use/reproduce without author's agreement /!\    		

    /!\ Please leave this for credits/!\ 

---------------------------------------------------------------------]]

local Player = FindMetaTable("Player")

function Player:PS_PlayerSpawn()
	if not self:PS_CanPerformAction() then return end

	if TEAM_SPECTATOR != nil and self:Team() == TEAM_SPECTATOR then return end
	if TEAM_SPEC != nil and self:Team() == TEAM_SPEC then return end

	if self.Spectating then return end

	timer.Simple(1, function()
		if !IsValid(self) then return end
		for item_id, item in pairs(self.PS_Items) do
			local ITEM = PS.Items[item_id]
			if item.Equipped then
				ITEM:OnEquip(self, item.Modifiers)
			end
		end
	end)
end

function Player:PS_PlayerDeath()
	for item_id, item in pairs(self.PS_Items) do
		if item.Equipped then
			local ITEM = PS.Items[item_id]
			ITEM:OnHolster(self, item.Modifiers)
		end
	end
end

function Player:PS_PlayerInitialSpawn()
	self.PS_Points = 0
	self.PS_Items = {}

	timer.Simple(1, function()
		if !IsValid(self) then return end

		self:PS_LoadData()
		self:PS_SendClientsideModels()
	end)

	if PS.Config.CheckVersion and PS.BuildOutdated and self:IsAdmin() then
		timer.Simple(5, function()
			if !IsValid(self) then return end
			self:PS_Notify("PointShop is out of date, please tell the server owner!")
		end)
	end

	if PS.Config.PointsOverTime then
		timer.Create('PS_PointsOverTime_' .. self:UniqueID(), PS.Config.PointsOverTimeDelay * 60, 0, function()
			if !IsValid(self) then return end
			self:PS_GivePoints(PS.Config.PointsOverTimeAmount)
			self:PS_Notify("on vous a donné ", PS.Config.PointsOverTimeAmount, " ", PS.Config.PointsName, " pour avoir jouer sur le serveur !")
		end)
	end
end

function Player:PS_PlayerDisconnected()
	PS.ClientsideModels[self] = nil

	if timer.Exists('PS_PointsOverTime_' .. self:UniqueID()) then
		timer.Destroy('PS_PointsOverTime_' .. self:UniqueID())
	end
end



function Player:PS_Save()
	PS:SetPlayerData(self, self.PS_Points, self.PS_Items)
end

function Player:PS_LoadData()
	self.PS_Points = 0
	self.PS_Items = {}

	PS:GetPlayerData(self, function(points, items)
		self.PS_Points = points
		self.PS_Items = items

		self:PS_SendPoints()
		self:PS_SendItems()
	end)
end



function Player:PS_CanPerformAction(itemname)
	local allowed = true
	local itemexcept = false
	if itemname then itemexcept = PS.Items[itemname].Except end

	if (self.IsSpec and self:IsSpec()) and not itemexcept then allowed = false end
	if not self:Alive() and not itemexcept then allowed = false end


	if not allowed then
		self:PS_Notify("Tu ne peux pas faire ça maintenant !")
	end

	return allowed
end



function Player:PS_GivePoints(points)
	self.PS_Points = self.PS_Points + points
	PS:GivePlayerPoints(self, points)
	self:PS_SendPoints()
end

function Player:PS_TakePoints(points)
	self.PS_Points = self.PS_Points - points >= 0 and self.PS_Points - points or 0
	PS:TakePlayerPoints(self, points)
	self:PS_SendPoints()
end

function Player:PS_SetPoints(points)
	self.PS_Points = points
	PS:SetPlayerPoints(self, points)
	self:PS_SendPoints()
end

function Player:PS_GetPoints()
	return self.PS_Points and self.PS_Points or 0
end

function Player:PS_HasPoints(points)
	return self.PS_Points >= points
end

function Player:PS_GiveItem(item_id)
	if not PS.Items[item_id] then return false end

	self.PS_Items[item_id] = { Modifiers = {}, Equipped = false }

	PS:GivePlayerItem(self, item_id, self.PS_Items[item_id])

	self:PS_SendItems()

	return true
end

function Player:PS_TakeItem(item_id)
	if not PS.Items[item_id] then return false end
	if not self:PS_HasItem(item_id) then return false end

	self.PS_Items[item_id] = nil

	PS:TakePlayerItem(self, item_id)

	self:PS_SendItems()

	return true
end

function Player:PS_BuyItem(item_id)
	local ITEM = PS.Items[item_id]
	if not ITEM then return false end

	local points = PS.Config.CalculateBuyPrice(self, ITEM)

	if not self:PS_HasPoints(points) then return false end
	if not self:PS_CanPerformAction(item_id) then return end

	if ITEM.AdminOnly and not self:IsAdmin() then
		self:PS_Notify("Cet élément est réservé aux administrateurs !")
		return false
	end

	if ITEM.StockEnded then
		self:PS_Notify("La part sur l’élément donné est terminée !")
		return false
	end		

	if ITEM.AllowedUserGroups and #ITEM.AllowedUserGroups > 0 then
		if not table.HasValue(ITEM.AllowedUserGroups, self:PS_GetUsergroup()) then
			self:PS_Notify("Cet article est réservé aux joueurs premium !")
			return false
		end
	end

	local cat_name = ITEM.Category
	local CATEGORY = PS:FindCategoryByName(cat_name)

	if CATEGORY.AllowedUserGroups and #CATEGORY.AllowedUserGroups > 0 then
		if not table.HasValue(CATEGORY.AllowedUserGroups, self:PS_GetUsergroup()) then
			self:PS_Notify("Cet article est réservé aux joueurs premium !")
			return false
		end
	end

	if CATEGORY.CanPlayerSee then
		if not CATEGORY:CanPlayerSee(self) then
			self:PS_Notify("Cette article n’est pas disponible pour vous !")
			return false
		end
	end

	if ITEM.CanPlayerBuy then 
		local allowed, message
		if ( type(ITEM.CanPlayerBuy) == "function" ) then
			allowed, message = ITEM:CanPlayerBuy(self)
		elseif ( type(ITEM.CanPlayerBuy) == "boolean" ) then
			allowed = ITEM.CanPlayerBuy
		end

		if not allowed then
			self:PS_Notify(message or "Cet article n’est pas disponible pour vous !")
			return false
		end
	end

	self:PS_TakePoints(points)

	self:PS_Notify("vous avez acheté ", ITEM.Name, " pour ", points, " ", PS.Config.PointsName)

	ITEM:OnBuy(self)

	if ITEM.SingleUse then return end

	self:PS_GiveItem(item_id)
	self:PS_EquipItem(item_id)
end

function Player:PS_SellItem(item_id)
	if not PS.Items[item_id] then return false end
	if not self:PS_HasItem(item_id) then return false end

	local ITEM = PS.Items[item_id]

	if ITEM.CanPlayerSell then
		local allowed, message
		if ( type(ITEM.CanPlayerSell) == "function" ) then
			allowed, message = ITEM:CanPlayerSell(self)
		elseif ( type(ITEM.CanPlayerSell) == "boolean" ) then
			allowed = ITEM.CanPlayerSell
		end

		if not allowed then
			self:PS_Notify(message or "Il vous est interdit de vendre cet article. !")
			return false
		end
	end

	local points = PS.Config.CalculateSellPrice(self, ITEM)
	self:PS_GivePoints(points)

	ITEM:OnHolster(self)
	ITEM:OnSell(self)

	self:PS_Notify("vous avez vendu ", ITEM.Name, " pour ", points, " ", PS.Config.PointsName)

	return self:PS_TakeItem(item_id)
end

function Player:PS_HasItem(item_id)
	return self.PS_Items[item_id] or false
end

function Player:PS_HasItemEquipped(item_id)
	if not self:PS_HasItem(item_id) then return false end

	return self.PS_Items[item_id].Equipped or false
end

function Player:PS_NumItemsEquippedFromCategory(cat_name)
	local count = 0

	for item_id, item in pairs(self.PS_Items) do
		local ITEM = PS.Items[item_id]
		if ITEM.Category == cat_name and item.Equipped then
			count = count + 1
		end
	end

	return count
end

function Player:PS_EquipItem(item_id)
	if not PS.Items[item_id] then return false end
	if not self:PS_HasItem(item_id) then return false end
	if not self:PS_CanPerformAction(item_id) then return false end

	local ITEM = PS.Items[item_id]

	if type(ITEM.CanPlayerEquip) == "function" then
		allowed, message = ITEM:CanPlayerEquip(self)
	elseif type(ITEM.CanPlayerEquip) == "boolean" then
		allowed = ITEM.CanPlayerEquip
	end

	if not allowed then
		self:PS_Notify(message or "Tu n’as pas le droit de porter ce truc !")
		return false
	end

	local cat_name = ITEM.Category
	local CATEGORY = PS:FindCategoryByName(cat_name)

	if CATEGORY and CATEGORY.AllowedEquipped > -1 then
		if self:PS_NumItemsEquippedFromCategory(cat_name) + 1 > CATEGORY.AllowedEquipped then
			self:PS_Notify("Seulement " .. CATEGORY.AllowedEquipped .. " choses" .. (CATEGORY.AllowedEquipped == 1 and "" or "") .. " peut être habillé !")
			return false
		end
	end

	if PS.Items[item_id].Slot then
		for id, item in pairs(self.PS_Items) do
			if item_id != id and PS.Items[id].Slot and PS.Items[id].Slot == PS.Items[item_id].Slot and self.PS_Items[id].Equipped then
				self:PS_HolsterItem(id)
			end
		end
	end


	if CATEGORY.SharedCategories then
		local ConCatCats = CATEGORY.Name
		for p, c in pairs( CATEGORY.SharedCategories ) do
			if p ~= #CATEGORY.SharedCategories then
				ConCatCats = ConCatCats .. ", " .. c
			else
				if #CATEGORY.SharedCategories ~= 1 then
					ConCatCats = ConCatCats .. ", and " .. c
				else
					ConCatCats = ConCatCats .. " and " .. c
				end
			end
		end
		local NumEquipped = self.PS_NumItemsEquippedFromCategory
		for id, item in pairs(self.PS_Items) do
			if not self:PS_HasItemEquipped(id) then continue end
			local CatName = PS.Items[id].Category
			local Cat = PS:FindCategoryByName( CatName )
			if not Cat.SharedCategories then continue end
			for _, SharedCategory in pairs( Cat.SharedCategories ) do
				if SharedCategory == CATEGORY.Name then
					if Cat.AllowedEquipped > -1 and CATEGORY.AllowedEquipped > -1 then
						if NumEquipped(self,CatName) + NumEquipped(self,CATEGORY.Name) + 1 > Cat.AllowedEquipped then
							self:PS_Notify("Vous dépassez la limite des accessoires actifs !")
							return false
						end
					end
				end
			end
		end
	end

	self.PS_Items[item_id].Equipped = true

	ITEM:OnEquip(self, self.PS_Items[item_id].Modifiers)

	self:PS_Notify("Vous mettez ", ITEM.Name, ".")

	PS:SavePlayerItem(self, item_id, self.PS_Items[item_id])

	self:PS_SendItems()
end

function Player:PS_HolsterItem(item_id)
	if not PS.Items[item_id] then return false end
	if not self:PS_HasItem(item_id) then return false end
	if not self:PS_CanPerformAction(item_id) then return false end

	self.PS_Items[item_id].Equipped = false

	local ITEM = PS.Items[item_id]

	if type(ITEM.CanPlayerHolster) == "function" then
		allowed, message = ITEM:CanPlayerHolster(self)
	elseif type(ITEM.CanPlayerHolster) == "boolean" then
		allowed = ITEM.CanPlayerHolster
	end

	if not allowed then
		self:PS_Notify(message or "Vous n’êtes pas autorisé à supprimer cet élément !")
		return false
	end

	ITEM:OnHolster(self)

	PS:SavePlayerItem(self, item_id, self.PS_Items[item_id])

	self:PS_SendItems()
end

function Player:PS_ModifyItem(item_id, modifications)
	if not PS.Items[item_id] then return false end
	if not self:PS_HasItem(item_id) then return false end
	if not type(modifications) == "table" then return false end
	if not self:PS_CanPerformAction(item_id) then return false end

	local ITEM = PS.Items[item_id]

	for key, value in pairs(modifications) do
		self.PS_Items[item_id].Modifiers[key] = value
	end

	ITEM:OnModify(self, self.PS_Items[item_id].Modifiers)

	PS:SavePlayerItem(self, item_id, self.PS_Items[item_id])

	self:PS_SendItems()
end



function Player:PS_AddClientsideModel(item_id)
	if not PS.Items[item_id] then return false end
	if not self:PS_HasItem(item_id) then return false end

	net.Start("PS_AddClientsideModel")
		net.WriteEntity(self)
		net.WriteString(item_id)
	net.Broadcast()

	if not PS.ClientsideModels[self] then PS.ClientsideModels[self] = {} end

	PS.ClientsideModels[self][item_id] = item_id
end



function Player:PS_RemoveClientsideModel(item_id)
	if not PS.Items[item_id] then return false end
	if not self:PS_HasItem(item_id) then return false end
	if not PS.ClientsideModels[self] or not PS.ClientsideModels[self][item_id] then return false end

	net.Start("PS_RemoveClientsideModel")
		net.WriteEntity(self)
		net.WriteString(item_id)
	net.Broadcast()

	PS.ClientsideModels[self][item_id] = nil
end

function Player:PS_ToggleMenu(show)
	net.Start("PS_ToggleMenu")
	net.Send(self)
end

function Player:PS_SendPoints()
	net.Start("PS_Points")
		net.WriteEntity(self)
		net.WriteInt(self.PS_Points, 32)
	net.Broadcast()
end

function Player:PS_SendItems()
	net.Start("PS_Items")
		net.WriteEntity(self)
		net.WriteTable(self.PS_Items)
	net.Broadcast()
end

function Player:PS_SendClientsideModels()
	net.Start("PS_SendClientsideModels")
		net.WriteTable(PS.ClientsideModels)
	net.Send(self)
end

function Player:PS_Notify(...)
	local str = table.concat({...}, "")

	net.Start("PS_SendNotification")
		net.WriteString(str)
	net.Send(self)
end
