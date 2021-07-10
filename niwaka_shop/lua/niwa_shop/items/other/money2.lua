ITEM.Name = "500,000 €"
ITEM.Price = 500
ITEM.Model = "models/props/cs_assault/Money.mdl"
ITEM.NoPreview = true
ITEM.SingleUse = true

function ITEM:OnBuy(ply)
	ply:addMoney(500000)
end