--[[-------------------------------------------------------------------

    NIWAKA SHOP SETTINGS SOUND & ROLES : ADDONS

    The script was based on the V1 of the pointshop I decided to redo a new version in much more modern design

    V1 Pointshop : https://pointshop.burt0n.net/

    Script made by Niwaka (https://steamcommunity.com/id/NiwakaDarling/)
    Creation : 05/07/2021

    /!\ Don't sell/use/reproduce without author's agreement /!\    		

    /!\ Please leave this for credits/!\ 

    /!\ Modifier juste la ligne 21 pour ajouter vos grades que vous avez en jeux /!\ 

---------------------------------------------------------------------]]

net.Receive("premiumgreet", function()
	if LocalPlayer():CheckGroup("fondateur") or LocalPlayer():CheckGroup("Co-Fondateur") or LocalPlayer():CheckGroup("Gerant-Staff") or LocalPlayer():CheckGroup("superadmin") or LocalPlayer():CheckGroup("admin") or LocalPlayer():CheckGroup("Moderateur") or LocalPlayer():CheckGroup("Moderateur-Test") or LocalPlayer():CheckGroup("VIP") or LocalPlayer():CheckGroup("VIP+") or LocalPlayer():CheckGroup("Premium")then
		timer.Create("song", 0, 1, function()
			RunConsoleCommand("play", "niwakax/premiumgreet.mp3")
		end)
		timer.Create("yay", 1, 1, function()		
			surface.PlaySound("vo/npc/Barney/ba_yell.wav")
		end)
		timer.Create("haha", 4, 1, function()
			surface.PlaySound("vo/npc/Barney/ba_laugh03.wav")
		end)
		timer.Create("stopmusic", 7, 1, function()
			RunConsoleCommand("play", "vo/npc/Barney/ba_yell.wav")
		end)
	end	
end)

net.Receive("lkgreet", function()
	timer.Create("lksong", 0, 1, function()
		RunConsoleCommand("play", "niwakax/lkgreet.wav")
	end)

	timer.Create("stoplkmusic", 15, 1, function()
		RunConsoleCommand("play", "vo/npc/Barney/ba_yell.wav")
	end)
end)

net.Receive("pirategreet", function()
	timer.Create("piratesong", 0, 1, function()
		RunConsoleCommand("play", "niwakax/pirategreet.mp3")
	end)

	timer.Create("stoppiratemusic", 7, 1, function()
		RunConsoleCommand("play", "vo/npc/Barney/ba_yell.wav")
	end)
end)