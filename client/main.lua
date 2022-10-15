local restricted = {
	'tshirt_1', 'tshirt_2',
	'torso_1', 'torso_2',
	'decals_1', 'decals_2',
	'arms',	'arms_2',
	'pants_1', 'pants_2',
	'shoes_1', 'shoes_2',
	'bags_1', 'bags_2',
	'chain_1', 'chain_2',
	'helmet_1', 'helmet_2',
	'glasses_1', 'glasses_2'
}

local menuelements = {
	{unselectable = "true", title = TranslateCap('title_adminskin'), icon = "fa-solid fa-vest"},
	{name = "dress", title = TranslateCap("title_dress"), icon = "fa-solid fa-shirt"}
}

if Config.Custom then
	menuelements[#menuelements+1] = {name = "custom", title = TranslateCap("title_custom"), icon = "fa-solid fa-palette"}
end

if Config.CustomSkin then
	menuelements[#menuelements+1] = {name = "custom2", title = TranslateCap("title_custom2"), icon = "fa-solid fa-pen-to-square"}
	menuelements[#menuelements+1] = {name = "deletecustom", title = TranslateCap("title_deletecustom"), icon = "fa-solid fa-trash"}
end

local AdminDressed = false

function Undress()
	ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
		TriggerEvent('skinchanger:loadSkin', skin, function() AdminDressed = false end)
	end)
end

function Dress(global, cb)
	ESX.TriggerServerCallback('esx_adminskin:getAdminSkin', function(adminskin)
		TriggerEvent('skinchanger:getSkin', function(skin)
			local editskin = skin
			for _,i in pairs(restricted) do
				skin[i] = adminskin[i]
			end
			TriggerEvent('skinchanger:loadSkin', editskin, function()
				AdminDressed = true 
				if cb then cb() end
			end)
		end)
	end, global)
end

function toggledress()
	if AdminDressed then
		Undress()
	else
		Dress()
	end
end

function OpenMenu()
    ESX.OpenContext("right", menuelements, function(menu, item)
		if item.name == 'custom' then
			undressbef = false
			if not AdminDressed then undressbef = true Dress(true, function() CustomSkin(true) end) else CustomSkin(true) end
		elseif item.name == 'custom2' then
			undressbef = false
			if not AdminDressed then undressbef = true Dress(false, function() CustomSkin() end) else CustomSkin() end
		elseif item.name == 'deletecustom' then
			ESX.TriggerServerCallback('esx_adminskin:deleteAdminSkin', function()
				if AdminDressed then
					Undress()
				end
			end)
		elseif item.name == 'dress' then
			toggledress()
		end
	end)
end

function CustomSkin(global)
	ESX.CloseContext()
			
	TriggerEvent('esx_skin:openRestrictedMenu', function(data, menu)
		menu.close()

		TriggerEvent('skinchanger:getSkin', function(skin)
			local editskin = {}
			for _,i in pairs(restricted) do
				editskin[i] = skin[i]
			end
			TriggerServerEvent('esx_adminskin:save', global, editskin)
		end)

		if undressbef then Undress() end

		OpenMenu()
	end, function(data, menu)
		menu.close()

		if undressbef then Undress() end

		OpenMenu()
	end, restricted)
end

RegisterNetEvent('esx_adminskin:toggledress')
AddEventHandler('esx_adminskin:toggledress', function()
	toggledress()
end)

RegisterNetEvent('esx_adminskin:OpenMenu')
AddEventHandler('esx_adminskin:OpenMenu', function()
	OpenMenu()
end)