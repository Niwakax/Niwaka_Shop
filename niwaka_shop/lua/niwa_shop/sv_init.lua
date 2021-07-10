--[[-------------------------------------------------------------------

    NIWAKA SHOP : ADDONS

    The script was based on the V1 of the pointshop I decided to redo a new version in much more modern design

    V1 Pointshop : https://pointshop.burt0n.net/

    Script made by Niwaka (https://steamcommunity.com/id/NiwakaDarling/)
    Creation : 05/07/2021

    /!\ Don't sell/use/reproduce without author's agreement /!\    		

    /!\ Please leave this for credits/!\ 

---------------------------------------------------------------------]]

include("sh_init.lua")
include("sv_player_extension.lua")
include("sv_manifest.lua")
include("cl_greetings.lua")

net.Receive("PS_BuyItem", function(length, ply)
	ply:PS_BuyItem(net.ReadString())
end)

net.Receive("PS_SellItem", function(length, ply)
	ply:PS_SellItem(net.ReadString())
end)

net.Receive("PS_EquipItem", function(length, ply)
	ply:PS_EquipItem(net.ReadString())
end)

net.Receive("PS_HolsterItem", function(length, ply)
	ply:PS_HolsterItem(net.ReadString())
end)

net.Receive("PS_ModifyItem", function(length, ply)
	ply:PS_ModifyItem(net.ReadString(), net.ReadTable())
end)

net.Receive("PS_SendPoints", function(length, ply)

end)

net.Receive("PS_GivePoints", function(length, ply)
	local other = net.ReadEntity()
	local points = net.ReadInt(32)
	
	if ply:IsSuperAdmin() and other and points and IsValid(other) and other:IsPlayer() then
		other:PS_GivePoints(points)
		other:PS_Notify("Votre solde a été modifié !")
	end
end)

net.Receive("PS_TakePoints", function(length, ply)
	local other = net.ReadEntity()
	local points = net.ReadInt(32)
	
	if ply:IsSuperAdmin() and other and points and IsValid(other) and other:IsPlayer() then
		other:PS_TakePoints(points)
		other:PS_Notify("Votre solde a été modifié !")
	end
end)

net.Receive("PS_SetPoints", function(length, ply)
	local other = net.ReadEntity()
	local points = net.ReadInt(32)
	
	if ply:IsSuperAdmin() and other and points and IsValid(other) and other:IsPlayer() then
		other:PS_SetPoints(points)
		other:PS_Notify("Votre solde a été modifié !")
	end
end)

net.Receive("PS_GiveItem", function(length, ply)
	local other = net.ReadEntity()
	local item_id = net.ReadString()
	
	if ply:IsSuperAdmin() and other and item_id and PS.Items[item_id] and IsValid(other) and other:IsPlayer() and not other:PS_HasItem(item_id) then
		other:PS_GiveItem(item_id)
	end
end)

net.Receive("PS_TakeItem", function(length, ply)
	local other = net.ReadEntity()
	local item_id = net.ReadString()

	if ply:IsSuperAdmin() and other and item_id and PS.Items[item_id] and IsValid(other) and other:IsPlayer() and other:PS_HasItem(item_id) then
		other.PS_Items[item_id].Equipped = false
	
		local ITEM = PS.Items[item_id]
		ITEM:OnHolster(other)
		other:PS_TakeItem(item_id)
	end
end)

local KeyToHook = {
	F1 = "ShowHelp",
	F2 = "ShowTeam",
	F3 = "ShowSpare1",
	F4 = "ShowSpare2",
	None = "ThisHookDoesNotExist"
}

hook.Add("PlayerSpawn", "PS_PlayerSpawn", function(ply) ply:PS_PlayerSpawn() end)
hook.Add("PlayerDeath", "PS_PlayerDeath", function(ply) ply:PS_PlayerDeath() end)
hook.Add("PlayerInitialSpawn", "PS_PlayerInitialSpawn", function(ply) ply:PS_PlayerInitialSpawn() end)
hook.Add("PlayerDisconnected", "PS_PlayerDisconnected", function(ply) ply:PS_PlayerDisconnected() end)

util.AddNetworkString("premiumgreet")
util.AddNetworkString("lkgreet")
util.AddNetworkString("pirategreet")

util.AddNetworkString("serverstartinfo")

util.AddNetworkString("PS_Items")
util.AddNetworkString("PS_Points")
util.AddNetworkString("PS_BuyItem")
util.AddNetworkString("PS_SellItem")
util.AddNetworkString("PS_EquipItem")
util.AddNetworkString("PS_HolsterItem")
util.AddNetworkString("PS_ModifyItem")
util.AddNetworkString("PS_SendPoints")
util.AddNetworkString("PS_GivePoints")
util.AddNetworkString("PS_TakePoints")
util.AddNetworkString("PS_SetPoints")
util.AddNetworkString("PS_GiveItem")
util.AddNetworkString("PS_TakeItem")
util.AddNetworkString("PS_AddClientsideModel")
util.AddNetworkString("PS_RemoveClientsideModel")
util.AddNetworkString("PS_SendClientsideModels")
util.AddNetworkString("PS_SendNotification")
util.AddNetworkString("PS_ToggleMenu")

concommand.Add(PS.Config.ShopCommand, function(ply, cmd, args)
	ply:PS_ToggleMenu()
end)

hook.Add("PlayerSay", "PS_PlayerSay", function(ply, text)
	if string.len(PS.Config.ShopChatCommand) > 0 then
		if string.sub(text, 0, string.len(PS.Config.ShopChatCommand)) == PS.Config.ShopChatCommand then
			ply:PS_ToggleMenu()
			return ""
		end
	end
end)

concommand.Add("ps_clear_points", function(ply, cmd, args)
	if IsValid(ply) then return end
	
	for _, ply in pairs(player.GetAll()) do
		ply:PS_SetPoints(0)
	end
	
	sql.Query("DELETE FROM playerpdata WHERE infoid LIKE "%PS_Points%"")
end)

concommand.Add("ps_clear_items", function(ply, cmd, args)
	if IsValid(ply) then return end
	
	for _, ply in pairs(player.GetAll()) do
		ply.PS_Items = {}
		ply:PS_SendItems()
	end
	
	sql.Query("DELETE FROM playerpdata WHERE infoid LIKE "%PS_Items%"")
end)

PS.CurrentBuild = 0
PS.LatestBuild = 0
PS.BuildOutdated = false

function PS:LoadDataProvider()
	local path = "niwa_shop/providers/" .. self.Config.DataProvider .. ".lua"

	PROVIDER = {}
	PROVIDER.__index = {}
	PROVIDER.ID = self.Config.DataProvider
		
	include(path)
		
	self.DataProvider = PROVIDER
	PROVIDER = nil
end

function PS:GetPlayerData(ply, callback)
	self.DataProvider:GetData(ply, function(points, items)
		callback(PS:ValidatePoints(tonumber(points)), PS:ValidateItems(items))
	end)
end

function PS:SetPlayerData(ply, points, items)
	self.DataProvider:SetData(ply, points, items)
end

function PS:SetPlayerPoints(ply, points)
	self.DataProvider:SetPoints(ply, points)
end

function PS:GivePlayerPoints(ply, points)
	self.DataProvider:GivePoints(ply, points, items)
end

function PS:TakePlayerPoints(ply, points)
	self.DataProvider:TakePoints(ply, points)
end

function PS:SavePlayerItem(ply, item_id, data)
	self.DataProvider:SaveItem(ply, item_id, data)
end

function PS:GivePlayerItem(ply, item_id, data)
	self.DataProvider:GiveItem(ply, item_id, data)
end

function PS:TakePlayerItem(ply, item_id)
	self.DataProvider:TakeItem(ply, item_id)
end