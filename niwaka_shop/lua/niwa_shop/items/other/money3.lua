ITEM.Name = "1,000,000 €"
ITEM.Price = 1000
ITEM.Model = "models/props/cs_assault/Money.mdl"
ITEM.NoPreview = true
ITEM.SingleUse = true

function ITEM:OnBuy(ply)
	ply:addMoney(1000000)
end