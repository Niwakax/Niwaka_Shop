AddCSLuaFile()

if SERVER then return end

local PANEL = {}

function PANEL:Init()
end

function PANEL:LoadItems(category, ownedOnly)
	local defaultSubcategory = {
		name = category.DefaultSubcategoryName or "Standard",
		items = {}
	}
	local subCategories = {
		[defaultSubcategory.name] = defaultSubcategory
	}
	
	local itemsSorted = {}
	for k, v in pairs(PS.Items) do
		if v.Category == category.Name then
			table.insert(itemsSorted, v)
		end
	end
	table.SortByMember(itemsSorted, PS.Config.SortItemsBy, function(a, b) return a > b end)
	
	for k, item in pairs(itemsSorted) do
		if item.Category != category.Name then
			continue
		end
		
		if ownedOnly and not LocalPlayer():PS_HasItem(item.ID) then
			continue
		end
		
		if item.SubCategory then
			subCategories[item.SubCategory] = subCategories[item.SubCategory] or {
				name = item.SubCategory,
				items = {}
			}
			
			table.insert(subCategories[item.SubCategory].items, item)
		else
			table.insert(defaultSubcategory.items, item)
		end
	end
	
	local orderedSubcats = {}
	for k, v in pairs(subCategories) do 
		table.insert(orderedSubcats, v)
	end
	
	category.SubcategoryOrder = category.SubcategoryOrder or {}
	for order, subcategoryName in ipairs(category.SubcategoryOrder) do
		if not subCategories[subcategoryName] and subcategoryName != defaultSubcategory.name then
			continue
		end
		subCategories[subcategoryName].Order = order
	end
	
	table.SortByMember(orderedSubcats, "Order", function(a, b) 
		return a > b 
	end)
	
	category.SubcategoryLabels = category.SubcategoryLabels or {}
	for k, v in ipairs(orderedSubcats) do
		local subCategoryPanel = vgui.Create("DSubcategoryContainer", self)
		subCategoryPanel:Dock(TOP)
		subCategoryPanel:DockMargin(10, 10, 10, 10)
		subCategoryPanel:SetItems(v.items)
		subCategoryPanel:SetTitle(v.name, category.SubcategoryLabels[v.name])
	end
	
end

vgui.Register("DPointshopSubcategorizedCategory", PANEL, "DScrollPanel")

local PANEL = {}

Derma_Hook(PANEL, "Paint", "Paint", "SubcategoryPanel")

AccessorFunc(PANEL, "m_iconSize", "IconSize")
function PANEL:Init()
	self:DockPadding(10, 5, 10, 10)
	
	self.titleLabel = vgui.Create( "DLabel", self )
	self.titleLabel:DockMargin(0, 0, 0, 5)
	self.titleLabel:Dock(TOP)
	self.titleLabel:SetFont("niwaka_shop_category")
	
	self.descLabel = vgui.Create("DLabel", self)
	self.descLabel:DockMargin(0, 0, 0, 5)
	self.descLabel:Dock(TOP)
	self.descLabel:SetFont("niwaka_shop_category")
	
	self.weaponsList = vgui.Create("DIconLayout", self)
	self.weaponsList:SetSpaceX(8)
	self.weaponsList:SetSpaceY(8)
	self.weaponsList:DockMargin(0, 0, 0, 0)
	self.weaponsList:Dock(FILL)

	self:SetIconSize(100)
	
	self.itemicons = {}
	
	derma.SkinHook("Layout", "SubcategoryPanel", self)
end

function PANEL:SetTitle(strTitle, desc)
	self.titleLabel:SetText(strTitle)

	if desc then
		self.descLabel:SetText(desc)
	else
		self.descLabel:Remove()
	end
end

function PANEL:AddItem(item)
	timer.Simple(0.01, function()
	local weaponIcon = self.weaponsList:Add("DPointShopItem")
		weaponIcon:SetData(item)
		weaponIcon:SetSize(123, 123)
		derma.SkinHook("Layout", "ItemIcon", weaponIcon)
		Derma_Hook(weaponIcon, "Paint", "Paint", "ItemIcon")
		table.insert(self.itemicons, weaponIcon)
	end )
end

function PANEL:SetItems(items)
	for k, v in pairs(items) do
		self:AddItem(v)
	end
end

function PANEL:Think()
	self:SetTall(10)
	
	self.weaponsList:PerformLayout()
	
	local wx, wy, ww, wh = 0, 0, 0, 0
	for k, v in pairs(self.weaponsList:GetChildren()) do
		wx, wy = v:GetPos()
		ww, wh = v:GetSize()
	end	
	self.weaponsList:SetTall(wy + wh + 10)
	
	wx, wy = self.weaponsList:GetPos()
	
	self:SetTall(self.weaponsList:GetTall() + wy)
end
vgui.Register("DSubcategoryContainer", PANEL, "DPanel")