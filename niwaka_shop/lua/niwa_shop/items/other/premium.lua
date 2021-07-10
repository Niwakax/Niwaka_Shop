ITEM.Name = "Statut prime"
ITEM.Price = 200
ITEM.Model = "models/maxofs2d/logo_gmod_b.mdl"
ITEM.NoPreview = true
ITEM.SingleUse = true
ITEM.Info = true

function ITEM:OnBuy(ply)
	net.Start("premiumgreet")
	net.Send(ply)
	RunConsoleCommand("ulx", "adduser", ply:Name(), "premium")
end

local function Info()
	local fr = vgui.Create("DFrame")
	fr:SetAlpha(1)
	fr:AlphaTo(255, 0.4, 0)
	fr:SetSize(400, 140)
	fr:SetSkin("DarkRP")
	fr:SetPos(input.GetCursorPos())
	fr:SetTitle("informations")
	fr:SetDraggable(true)
	fr:MakePopup()
	local infotext = vgui.Create("DTextEntry", fr)
	infotext:SetSize(393, 105)
	infotext:SetPos(3, 30)
	infotext:SetMultiline(true)
	infotext:SetEditable(false)
	infotext:SetText("Votre Description du vip")	
end

function ITEM:CheckInfo() 
	Info()
end