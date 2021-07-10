ITEM.Name = "100,000 € "
ITEM.Price = 100
ITEM.Model = "models/props/cs_assault/Money.mdl"
ITEM.NoPreview = true
ITEM.SingleUse = true

function ITEM:OnBuy(ply)
	ply:addMoney(100000)
end