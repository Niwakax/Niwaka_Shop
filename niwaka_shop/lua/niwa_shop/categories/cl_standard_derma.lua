AddCSLuaFile()

if SERVER then return end

local SKIN = {}

SKIN.Name = "StandardPS"

local function loadSkin()
	SKIN.Colours = table.Copy(derma.GetDefaultSkin( ).Colours)
	SKIN.Colours.Label = {}
	SKIN.Colours.Label.Default = color_white
	SKIN.Colours.Label.Bright = SKIN.ItemDescPanelBorder

	SKIN.IconSize = {100, 160}

	function SKIN:PaintSubcategoryPanel()
	end


	function SKIN:LayoutItemIcon(panel, w, h)
		panel:SetSize(100, 160)
	end

	function SKIN:PaintItemIcon(panel, w, h)
		surface.SetDrawColor(Color(109, 109, 109))
		surface.DrawRect(0, 0, w, h)
	end

	function SKIN:LayoutSubcategoryPanel(panel)
		panel.titleLabel:SetFont("niwaka_shop_category")
		panel.titleLabel:SetTall(12)
		panel.titleLabel:SizeToContents()
		panel.descLabel:SetFont("niwaka_shop_category")
		panel.descLabel:SetTall(10)
		panel.descLabel:SizeToContents()
	end

	derma.DefineSkin(SKIN.Name, "PointshopSkin", SKIN)
end

if GAMEMODE then
	loadSkin()
end

hook.Add("Initialize", SKIN.Name .. "init", loadSkin, 100)
hook.Add("OnReloaded", SKIN.Name .. "reload", loadSkin, 100)