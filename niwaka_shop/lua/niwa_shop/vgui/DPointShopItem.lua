local PANEL = {}

function PANEL:Init()
	self.PaintTime = -1
	self.Info = ""
	self.InfoHeight = 20
	self.InfoBar = 6
	self.PriceInfo = 0
end

function PANEL:DoClick()
	local points = PS.Config.CalculateBuyPrice(LocalPlayer(), self.Data)
	
	if not LocalPlayer():PS_HasItem(self.Data.ID) and not LocalPlayer():PS_HasPoints(points) then
		notification.AddLegacy("Tu n’as pas assez pour ça !", NOTIFY_GENERIC, 5)
	end

	local menu = DermaMenu(self)
	
	if LocalPlayer():PS_HasItem(self.Data.ID) then
		--
	elseif LocalPlayer():PS_HasPoints(points) then
		menu:AddOption("Acheter", function()
			Derma_Query("Voulez-vous vraiment acheter " .. self.Data.Name .. "?", "Acheter une chose",
				"Oui", function() LocalPlayer():PS_BuyItem(self.Data.ID) end,
				"Non", function() end
			)
		end)
	end	

	if LocalPlayer():PS_HasItem(self.Data.ID) then
		menu:AddSpacer()
		
		if LocalPlayer():PS_HasItemEquipped(self.Data.ID) then
			menu:AddOption("Enlever", function()
				LocalPlayer():PS_HolsterItem(self.Data.ID)
			end)
		else
			menu:AddOption("Equiper", function()
				LocalPlayer():PS_EquipItem(self.Data.ID)
			end)
		end
		
		if LocalPlayer():PS_HasItemEquipped(self.Data.ID) and self.Data.Modify then
			menu:AddSpacer()
			
			menu:AddOption("Modifier", function()
				PS.Items[self.Data.ID]:Modify(LocalPlayer().PS_Items[self.Data.ID].Modifiers)
			end)
		end
	end

	if self.Data.Info then
		menu:AddOption("Informations", function()
			PS.Items[self.Data.ID]:CheckInfo()
		end)
	end	

	menu:Open()
end

function PANEL:SetData(data)
	self.Data = data
	self.Info = data.Name
	
	if data.Model then
		local DModelPanel = vgui.Create("DModelPanel", self)
		DModelPanel:SetModel(data.Model)
		
		DModelPanel:Dock(FILL)
		
		if data.Skin then
			DModelPanel.Entity:SetSkin(data.Skin)
		end
		
		local PrevMins, PrevMaxs = DModelPanel.Entity:GetRenderBounds()
		DModelPanel:SetCamPos(PrevMins:Distance(PrevMaxs) * Vector(0.5, 0.5, 0.5))
		DModelPanel:SetLookAt((PrevMaxs + PrevMins) / 2)
		
		function DModelPanel:LayoutEntity(ent)
			if self:GetParent().Hovered then
				ent:SetAngles(Angle(0, ent:GetAngles().y + 2, 0))
			end
			
			local ITEM = PS.Items[data.ID]
			
			ITEM:ModifyClientsideModel(LocalPlayer(), ent, Vector(), Angle())
		end
		
		function DModelPanel:DoClick()
			self:GetParent():DoClick()
		end
		
		function DModelPanel:OnCursorEntered()
			self:GetParent():OnCursorEntered()
		end
		
		function DModelPanel:OnCursorExited()
			self:GetParent():OnCursorExited()
		end
		
	else
		local DImageButton = vgui.Create("DImageButton", self)
		DImageButton:SetMaterial(data.Material)
		
		DImageButton:Dock(FILL)
		
		function DImageButton:DoClick()
			self:GetParent():DoClick()
		end
		
		function DImageButton:OnCursorEntered()
			self:GetParent():OnCursorEntered()
		end
		
		function DImageButton:OnCursorExited()
			self:GetParent():OnCursorExited()
		end
	end
end

function PANEL:Paint()	
	surface.SetDrawColor(Color(109, 109, 109))
	surface.DrawRect(0, 0, self:GetTall(), self:GetWide() + 52) 	

	draw.TexturedQuad
	{
		texture = surface.GetTextureID "gui/gradient",
		color = Color(0, 0, 0, 60 + 60 * math.Clamp(self.PaintTime, -1, 0)),
		x = 1,
		y = 1,
		w = self:GetWide() - 2,
		h = self:GetTall() - 2
	}
end

function PANEL:PaintOver()
	if LocalPlayer():PS_HasItem(self.Data.ID) then
		surface.SetMaterial(Material("icon16/tick.png"))
		surface.SetDrawColor(Color(255, 255, 255, alpha))
		surface.DrawTexturedRect(self:GetWide() - 5 - 16, 5, 16, 16)
	end

	if LocalPlayer():PS_HasItemEquipped(self.Data.ID) then
		surface.SetMaterial(Material("icon16/wrench.png"))
		surface.SetDrawColor(Color(255, 255, 255, alpha))
		surface.DrawTexturedRect(self:GetWide() - 5 - 34, 5, 16, 16)		
	end
	
	surface.SetDrawColor(Color(36, 36, 36, 255))
	surface.DrawRect(0, self:GetTall() - self.InfoHeight, self:GetWide(), self.InfoHeight)

	local alpha = 255 + 255 * math.Clamp(self.PaintTime, -1, 0) 
	txtColor = Color(255, 255, 255, alpha)
	
	draw.SimpleText(self.Info, "HudHintTextLarge", self:GetWide() / 2, self:GetTall() - (self.InfoHeight / 2), txtColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	
	if LocalPlayer().PS_Items and LocalPlayer().PS_Items[self.Data.ID] and LocalPlayer().PS_Items[self.Data.ID].Modifiers and LocalPlayer().PS_Items[self.Data.ID].Modifiers.color then
		surface.SetDrawColor(LocalPlayer().PS_Items[self.Data.ID].Modifiers.color)
		surface.DrawRect(self:GetWide() - 5 - 16, 26, 16, 16)
	end
end

function PANEL:OnCursorEntered()
	self.Hovered = true
	self.InfoHeight = 20	

	if LocalPlayer():PS_HasItem(self.Data.ID) then
		self.Info = "acquise"
		self.PriceInfo = 1
	else
		self.Info = PS.Config.CalculateBuyPrice(LocalPlayer(), self.Data) .. " " .. PS.Config.PointsName 
		self.PriceInfo = -1
	end
	
	PS:SetHoverItem(self.Data.ID)
end

function PANEL:Think()
	if self.PaintTime < 0 then
		self.PaintTime = self.PaintTime + FrameTime() * 2
	elseif self.PaintTime > 0 then
		self.PaintTime = 0
	end
end

function PANEL:OnCursorExited()
	self.Hovered = false
	self.InfoHeight = 20
	self.Info = self.Data.Name
	self.PriceInfo = 0
	
	PS:RemoveHoverItem()
end
vgui.Register("DPointShopItem", PANEL, "DPanel")