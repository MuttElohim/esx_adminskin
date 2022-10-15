local restricted = {
	'tshirt_1', 'tshirt_2',
	'torso_1', 'torso_2',
	'decals_1', 'decals_2',
	'arms',	'arms_2',
	'pants_1', 'pants_2',
	'shoes_1', 'shoes_2',
	-- 'bags_1', 'bags_2',
	'chain_1', 'chain_2',
	'helmet_1', 'helmet_2',
	'glasses_1', 'glasses_2'
}

local elements = {
	{name = "dress", title = TranslateCap("title_dress"), icon = "fa-solid fa-shirt"}
}

function AddElement(element) elements[#elements+1] = element end

if Config.Custom then AddElement({name = "custom", title = TranslateCap("title_custom"), icon = "fa-solid fa-palette"}) end

if Config.Personal then
	AddElement({name = "personalcustom", title = TranslateCap("title_personalcustom"), icon = "fa-solid fa-pen-to-square"})
	AddElement({name = "personaldelete", title = TranslateCap("title_personaldelete"), icon = "fa-solid fa-trash"})
end

local Dressed = false

function Undress() ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin) TriggerEvent('skinchanger:loadSkin', skin, function() Dressed = false end) end) end

function Dress(personal, cb)
	ESX.TriggerServerCallback('esx_adminskin:GetSkin', function(_skin)
		TriggerEvent('skinchanger:getSkin', function(skin)
			for _,i in pairs(restricted) do skin[i] = _skin[i] end
			TriggerEvent('skinchanger:loadSkin', skin, function() Dressed = true if cb then cb() end end)
		end)
	end, personal)
end

function ToggleSkin() if Dressed then Undress() else Dress(true) end end

function OpenMenu()
    ESX.OpenContext("right", elements, function(menu, item)
		if item.name == 'dress' then
			ToggleSkin()
		elseif item.name == 'custom' then
			CustomSkin()
		elseif item.name == 'personalcustom' then
			CustomSkin(true)
		elseif item.name == 'personaldelete' then
			ESX.TriggerServerCallback('esx_adminskin:DeleteSkin', function() if Dressed then Undress() end end)
		end
	end)
end

function CustomSkin(personal)
	Dress(personal, function()
		ESX.CloseContext()

		TriggerEvent('esx_skin:openRestrictedMenu', function(data, menu)
			menu.close()

			TriggerEvent('skinchanger:getSkin', function(skin)
				local _skin = {}
				for _,i in pairs(restricted) do _skin[i] = skin[i] end
				TriggerServerEvent('esx_adminskin:SaveSkin', _skin, personal)

				OpenMenu()
			end)
		end, function(data, menu) menu.close() OpenMenu() end, restricted)
	end)
end

RegisterNetEvent('esx_adminskin:ToggleSkin')
AddEventHandler('esx_adminskin:ToggleSkin', function()
	ToggleSkin()
end)

RegisterNetEvent('esx_adminskin:OpenMenu')
AddEventHandler('esx_adminskin:OpenMenu', function()
	OpenMenu()
end)