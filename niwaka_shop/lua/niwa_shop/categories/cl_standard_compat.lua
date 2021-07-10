AddCSLuaFile( )

if SERVER then return end

hook.Add("PS_CustomCategoryTab", "AddSubcategories", function(CATEGORY)
	if CATEGORY.EnableSubcategories then
		local ShopCategoryTab = vgui.Create("DPointshopSubcategorizedCategory")
		ShopCategoryTab:SetSkin("StandardPS")
		ShopCategoryTab:LoadItems(CATEGORY)
		return ShopCategoryTab
	end
end)