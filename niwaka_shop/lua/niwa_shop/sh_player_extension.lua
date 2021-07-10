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

function Player:PS_GetUsergroup()
	return self:GetNWString("UserGroup")
end