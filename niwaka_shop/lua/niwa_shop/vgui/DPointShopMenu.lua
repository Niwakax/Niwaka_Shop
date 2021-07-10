surface.CreateFont("niwaka_shop_category", {font = "Roboto", size = 18, weight = 400, antialias = true, extended = true})
surface.CreateFont("niwaka_shop_title", {font = "Roboto", size = 32, weight = 350, antialias = true, extended = true})
surface.CreateFont("niwaka_shop_balance", {font = "Roboto", size = 32, italic = true, weight = 350, antialias = true, extended = true})
surface.CreateFont("niwaka_shop_large", {size = 26, weight = 350, antialias = true, extended = true, font = "Roboto"})

local ALL_ITEMS = 1
local OWNED_ITEMS = 2
local UNOWNED_ITEMS = 3

local function BuildItemMenu(menu, ply, itemstype, callback)
	local plyitems = ply:PS_GetItems()
	
	for category_id, CATEGORY in pairs(PS.Categories) do
		
		local catmenu = menu:AddSubMenu(CATEGORY.Name)
		
		table.SortByMember(PS.Items, PS.Config.SortItemsBy, function(a, b) return a > b end)
		
		for item_id, ITEM in pairs(PS.Items) do
			if ITEM.Category == CATEGORY.Name then
				if itemstype == ALL_ITEMS or (itemstype == OWNED_ITEMS and plyitems[item_id]) or (itemstype == UNOWNED_ITEMS and not plyitems[item_id]) then
					catmenu:AddOption(ITEM.Name, function() callback(item_id) end)
				end
			end
		end
	end
end

local PANEL = {}

function PANEL:Init()
	self:SetSize(ScrW(), ScrH())
	self:SetPos(0, 0)

	local closebutton = vgui.Create("DButton", self)
	closebutton:SetSize(40, 25)
	closebutton:SetTextColor(Color(230, 230, 230, 150))
	if system.IsWindows() then
		closebutton:SetFont("Marlett")
		closebutton:SetText("r")
	else
		closebutton:SetText("✖")
	end
	closebutton:SetPos(self:GetWide() - 40, 0)
	closebutton.Paint = function(self, w, h)
		if self.Hovered then
			surface.SetDrawColor(Color(255, 0, 0, 200))
			surface.DrawRect(0, 0, w, h)
		else
			surface.SetDrawColor(Color(255, 0, 0, 100))
			surface.DrawRect(0, 0, w, h)
		end
	end
	closebutton.DoClick = function()
		PS:ToggleMenu()
		surface.PlaySound("ambient/water/rain_drip1.wav")
	end

	donate_opened = false

	local donatebutton = vgui.Create("DButton", self)
	donatebutton:SetFont("niwaka_shop_category")
	donatebutton:SetText("+")
	donatebutton:SetSize(40, 25)
	donatebutton:SetTextColor(Color(230, 230, 230, 150))
	donatebutton:SetPos(self:GetWide() - closebutton:GetWide() - 55, 0)
	donatebutton.Paint = function(self, w, h)
		if self.Hovered then
			surface.SetDrawColor(Color(127, 255, 0, 200))
			surface.DrawRect(0, 0, w, h)
		else
			surface.SetDrawColor(Color(127, 255, 0, 100))
			surface.DrawRect(0, 0, w, h)
		end
	end
	donatebutton.DoClick = function()
		surface.PlaySound("ambient/water/rain_drip1.wav")

		if not donate_opened then
			donate_opened = true

			local fr = vgui.Create("DFrame")
			fr:SetAlpha(1)
			fr:AlphaTo(255, 0.4, 0)
			fr:SetSize(400, 200)
			fr:SetSkin("DarkRP")
			fr:SetPos(self:GetWide() - fr:GetWide() - 5, 60)
			fr:SetTitle("Donnation")
			fr:SetDraggable(true)
			fr:MakePopup()
			fr.Close = function()
				donate_opened = false
				fr:Remove()
			end

			local wallettext = vgui.Create("DTextEntry", fr)
			wallettext:SetSize(393, 33)
			wallettext:SetPos(3, 35)
			wallettext:SetFont("niwaka_shop_large")
			wallettext:SetText("paypal.me/niwakax")
			wallettext:SetEditable(false)

			local infotext = vgui.Create("DTextEntry", fr)
			infotext:SetSize(393, 115)
			infotext:SetPos(3, 80)
			infotext:SetMultiline(true)
			infotext:SetEditable(false)
			infotext:SetText("si vous voulez me faire un don pour la création de cette addons !")
		end
	end	

	local buttonContainer = vgui.Create("DPanel", self)
	buttonContainer:SetTall(28)
	buttonContainer:Dock(TOP)
	buttonContainer:DockMargin(0, 48, 0, 0)
	buttonContainer.Paint = function(pnl, w, h)
		surface.SetDrawColor(0, 0, 0, 150) 
		surface.DrawRect(0, 0, w, h)
	end	

	local container = vgui.Create("DPanel", self)
	container:DockMargin(0, 0, ScrW() / 2, 0)
	container:Dock(FILL)
	container:SetSize(self:GetWide() - 60, self:GetTall() - 150)
	container:SetPos((self:GetWide() / 2) - (container:GetWide() / 2), 120)
	container.Paint = nil

	local btns = {}
	local firstBtn = true
	local function createBtn(text, material, panel, align, description)
		panel:SetParent(container)
		panel:Dock(FILL)
		panel.Paint = function(pnl, w, h)
			surface.SetDrawColor(0, 0, 0, 150) 
			surface.DrawRect(0, 0, w, h)
		end

		if firstBtn then
			panel:SetZPos(100)
			panel:SetVisible(true)
		else
			panel:SetZPos(1)
			panel:SetVisible(false)
		end

		local btn = vgui.Create("DButton", buttonContainer)
		btn:Dock(align or LEFT)
		btn:SetText(text)
		btn:SetFont("niwaka_shop_title")
		btn:SetImage(material)
		if description and description ~= "" then
			btn:SetToolTip(description)
		end
		
		btn.Paint = function(pnl, w, h)
			surface.SetDrawColor(218, 218, 218, 255)
			surface.DrawRect(0, 0, w, h)

			if pnl:GetActive() then
				surface.SetDrawColor(178, 178, 178, 255)
				surface.DrawRect(0, 0, w, h)
			end			
		end
		btn.UpdateColours = function(pnl)
			if pnl:GetActive() then return pnl:SetTextColor(Color(105, 105, 105, 255)) end
			if pnl.Hovered then return pnl:SetTextColor(Color(120, 120, 120, 255)) end
			pnl:SetTextColor(Color(140, 140, 140, 255))
		end
		btn.PerformLayout = function(pnl)
			pnl:SizeToContents() pnl:SetWide(pnl:GetWide() + 12) pnl:SetTall(pnl:GetParent():GetTall()) DLabel.PerformLayout(pnl)

			pnl.m_Image:SetSize(16, 16)
			pnl.m_Image:SetPos(8, (pnl:GetTall() - pnl.m_Image:GetTall()) * 0.5)
			pnl:SetContentAlignment(4)
			pnl:SetTextInset(pnl.m_Image:GetWide() + 16, 0)
		end

		btn.GetActive = function(pnl) return pnl.Active or false end
		btn.SetActive = function(pnl, state) pnl.Active = state end

		if firstBtn then firstBtn = false; btn:SetActive(true) end

		btn.DoClick = function(pnl)
			for k, v in pairs(btns) do v:SetActive(false) v:OnDeactivate() end
			pnl:SetActive(true) pnl:OnActivate()
		end

		btn.OnDeactivate = function()
			panel:SetVisible(false)
			panel:SetZPos(1)
		end
		btn.OnActivate = function()
			panel:SetVisible(true)
			panel:SetZPos(100)
		end

		table.insert(btns, btn)

		return btn
	end

	local categories = {}
	
	for _, i in pairs(PS.Categories) do
		table.insert(categories, i)
	end
	
	table.sort(categories, function(a, b) 
		if a.Order == b.Order then 
			return a.Name < b.Name
		else
			return a.Order < b.Order
		end
	end)
	
	local items = {}
	
	for _, i in pairs(PS.Items) do
		table.insert(items, i)
	end
	
	table.SortByMember(items, PS.Config.SortItemsBy, function(a, b) return a > b end)

	local tbl1 = {}
	local tbl2 = {}
	local tbl3 = {}

	for _, i in pairs(items) do
		local points = PS.Config.CalculateBuyPrice(LocalPlayer(), i)

		if (LocalPlayer():PS_HasItem(i.ID)) then 
			table.insert(tbl3, i)
		elseif (LocalPlayer():PS_HasPoints(points)) then 
			table.insert(tbl1, i)
		else 
			table.insert(tbl2, i)
		end
	end

	items = {}

	for _, i in pairs(tbl1) do table.insert(items, i) end
	for _, i in pairs(tbl2) do table.insert(items, i) end
	for _, i in pairs(tbl3) do table.insert(items, i) end
	
	for _, CATEGORY in pairs(categories) do
		if CATEGORY.AllowedUserGroups and #CATEGORY.AllowedUserGroups > 0 then
			if not table.HasValue(CATEGORY.AllowedUserGroups, LocalPlayer():PS_GetUsergroup()) then
				continue
			end
		end
		
		if CATEGORY.CanPlayerSee then
			if not CATEGORY:CanPlayerSee(LocalPlayer()) then
				continue
			end
		end
		
 		local ShopCategoryTab = hook.Run("PS_CustomCategoryTab", CATEGORY)
		if IsValid(ShopCategoryTab) then
			createBtn(CATEGORY.Name, "icon16/" .. CATEGORY.Icon .. ".png", ShopCategoryTab, nil, CATEGORY.Description)
			continue
		else
			ShopCategoryTab = vgui.Create("DPanel")
		end
		
		local DScrollPanel = vgui.Create("DScrollPanel", ShopCategoryTab)
		DScrollPanel:Dock(FILL)
		DScrollPanel.Paint = nil
		
		local ShopCategoryTabLayout = vgui.Create("DIconLayout", DScrollPanel)
		ShopCategoryTabLayout:Dock(FILL)
		ShopCategoryTabLayout:SetBorder(8)
		ShopCategoryTabLayout:SetSpaceX(8)
		ShopCategoryTabLayout:SetSpaceY(8)
		ShopCategoryTabLayout.Paint = nil
		
		DScrollPanel:AddItem(ShopCategoryTabLayout)
		
		local delay = 0.05		
		for _, ITEM in pairs(items) do				
			if ITEM.Category == CATEGORY.Name then			
				timer.Simple(delay, function()
					local model = vgui.Create("DPointShopItem")
					model:SetData(ITEM)
					model:SetSize(128, 180)
					
					ShopCategoryTabLayout:Add(model)				
				end)		

				delay = delay + 0.015
			end
		end

		if CATEGORY.ModifyTab then
			CATEGORY:ModifyTab(ShopCategoryTab)
		end
		
		createBtn(CATEGORY.Name, "icon16/" .. CATEGORY.Icon .. ".png", ShopCategoryTab, nil, CATEGORY.Description)
	end

	if LocalPlayer():IsSuperAdmin() then
		local AdminTab = vgui.Create("DPanel")
		
		local ClientsList = vgui.Create("DListView", AdminTab)
		ClientsList:DockMargin(10, 10, 10, 10)
		ClientsList:Dock(FILL)	
		
		ClientsList:SetMultiSelect(false)
		ClientsList:AddColumn("Name")
		ClientsList:AddColumn("Points"):SetFixedWidth(60)
		ClientsList:AddColumn("Items"):SetFixedWidth(60)
		
		ClientsList.OnClickLine = function(parent, line, selected)
			local ply = line.Player
			
			local menu = DermaMenu()
			
			menu:AddOption("Set " .. PS.Config.PointsName.. "...", function()
				Derma_StringRequest(
					"Set " .. PS.Config.PointsName .. " for " .. ply:GetName(),
					"Set " .. PS.Config.PointsName .. " to...",
					"",
					function(str)
						if not str or not tonumber(str) then return end
						
						net.Start("PS_SetPoints")
							net.WriteEntity(ply)
							net.WriteInt(tonumber(str), 32)
						net.SendToServer()
					end
				)
			end)
			
			menu:AddOption("Give " .. PS.Config.PointsName .. "...", function()
				Derma_StringRequest(
					"Give " .. PS.Config.PointsName .. " to " .. ply:GetName(),
					"Give " .. PS.Config.PointsName .. "...",
					"",
					function(str)
						if not str or not tonumber(str) then return end
						
						net.Start("PS_GivePoints")
							net.WriteEntity(ply)
							net.WriteInt(tonumber(str), 32)
						net.SendToServer()
					end
				)
			end)
			
			menu:AddOption("Take " .. PS.Config.PointsName .. "...", function()
				Derma_StringRequest(
					"Take " .. PS.Config.PointsName .. " from " .. ply:GetName(),
					"Take " .. PS.Config.PointsName .. "...",
					"",
					function(str)
						if not str or not tonumber(str) then return end
						
						net.Start("PS_TakePoints")
							net.WriteEntity(ply)
							net.WriteInt(tonumber(str), 32)
						net.SendToServer()
					end
				)
			end)
			
			menu:AddSpacer()
			
			BuildItemMenu(menu:AddSubMenu("Give Item"), ply, UNOWNED_ITEMS, function(item_id)
				net.Start("PS_GiveItem")
					net.WriteEntity(ply)
					net.WriteString(item_id)
				net.SendToServer()
			end)
			
			BuildItemMenu(menu:AddSubMenu("Take Item"), ply, OWNED_ITEMS, function(item_id)
				net.Start("PS_TakeItem")
					net.WriteEntity(ply)
					net.WriteString(item_id)
				net.SendToServer()
			end)
			
			menu:Open()
		end
		
		self.ClientsList = ClientsList

		createBtn("Admin", "icon16/shield.png", AdminTab, RIGHT)
	end
	
	local preview
	preview = vgui.Create("DPanel", self)
	preview:DockMargin(self:GetWide() / 2, 0, 0, 0)
	preview:Dock(FILL)
	preview.Paint = nil

	local previewpanel = vgui.Create("DPointShopPreview", preview)
	previewpanel:Dock(FILL)
	previewpanel.Angles = Angle(0, 30, 0)	

	function previewpanel:DoRightClick()
		if previewpanel:GetFOV() == 20 then
			previewpanel:SetFOV(40)
		elseif previewpanel:GetFOV() == 40 then
			previewpanel:SetFOV(60)
		elseif previewpanel:GetFOV() == 60 then
			previewpanel:SetFOV(20)			
		end
	end

	function previewpanel:DragMousePress()
		self.PressX, self.PressY = gui.MousePos()
		self.Pressed = true
	end

	function previewpanel:DragMouseRelease()
		self.Pressed = false
		self.lastPressed = RealTime()
	end
		
	function previewpanel:LayoutEntity(thisEntity)
		if (self.bAnimated) then self:RunAnimation() end
			
		if (self.Pressed) then
			local mx, my = gui.MousePos()
			self.Angles = self.Angles - Angle(0, (self.PressX or mx) - mx, 0)
			self.PressX, self.PressY = gui.MousePos()
		end
			
		if (RealTime() - (self.lastPressed or 0)) < 4 or self.Pressed then
			thisEntity:SetAngles(self.Angles)
		else	
			self.Angles.y = math.NormalizeAngle(self.Angles.y)
			thisEntity:SetAngles(Angle(0, self.Angles.y,  0) + Angle(0, 20, 0))
		end		
	end
end

function PANEL:Think()
	if self.ClientsList then
		local lines = self.ClientsList:GetLines()
		
		for _, ply in pairs(player.GetAll()) do
			local found = false
			
			for _, line in pairs(lines) do
				if line.Player == ply then
					found = true
				end
			end
			
			if not found then
				self.ClientsList:AddLine(ply:GetName(), ply:PS_GetPoints(), table.Count(ply:PS_GetItems())).Player = ply
			end
		end
		
		for i, line in pairs(lines) do
			if IsValid(line.Player) then
				local ply = line.Player
				
				line:SetValue(1, ply:GetName())
				line:SetValue(2, ply:PS_GetPoints())
				line:SetValue(3, table.Count(ply:PS_GetItems()))
			else
				self.ClientsList:RemoveLine(i)
			end
		end
	end
end

function PANEL:Paint(w, h)
	Derma_DrawBackgroundBlur(self)
	
	surface.SetDrawColor(Color(87, 92, 104, 160))
	surface.DrawRect(0, 0, w, 48)

	local youhave = "Vous avez"

	surface.SetFont("niwaka_shop_title")
	local balancesize = surface.GetTextSize(youhave)

	draw.SimpleText("Vous avez: ", "niwaka_shop_title", 16, 8, color_white)
	draw.SimpleText(LocalPlayer():PS_GetPoints() ..  " " .. PS.Config.PointsName, "niwaka_shop_balance", balancesize + 27, 8, color_white)
end
vgui.Register("DPointShopMenu", PANEL)