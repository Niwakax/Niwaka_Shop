--[[-------------------------------------------------------------------

    NIWAKA SHOP CONFIG : ADDONS

    The script was based on the V1 of the pointshop I decided to redo a new version in much more modern design

    V1 Pointshop : https://pointshop.burt0n.net/

    Script made by Niwaka (https://steamcommunity.com/id/NiwakaDarling/)
    Creation : 05/07/2021

    /!\ Don't sell/use/reproduce without author's agreement /!\    		

    /!\ Please leave this for credits/!\ 

---------------------------------------------------------------------]]

PS.Config = {}

PS.Config.DataProvider = "pdata" -- ne pas toucher

PS.Config.ShopCommand = "niwashop" -- vous pouvez la changer commande f10 pour ouvrir le shop
PS.Config.ShopChatCommand = "NiwakShop" -- commande dans le chat pour ouvrir le shop PS ne pas mettre dans le chat "! ou /" mettez simplement "NiwakShop"

PS.Config.PointsName = "Points"
PS.Config.SortItemsBy = "Name"

PS.Config.PointsOverTime = true -- Si les joueurs reçoivent des points au fil du temps ?
PS.Config.PointsOverTimeDelay = 1 -- Si oui, à combien de minutes d’intervalle ?
PS.Config.PointsOverTimeAmount = 10 -- Et si oui combien de point donner après le temps ?

PS.Config.CalculateBuyPrice = function(ply, item)
	return item.Price
end

PS.Config.CalculateSellPrice = function(ply, item)
	return math.Round(item.Price * 0.75)
end