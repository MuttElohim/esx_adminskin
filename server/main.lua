MySQL.query('CREATE TABLE IF NOT EXISTS admin_skin (identifier varchar(60) NOT NULL, skin longtext DEFAULT NULL)')

function DeleteSkin(xPlayer, cb)
	MySQL.query('DELETE FROM admin_skin WHERE identifier = ?', {xPlayer.identifier}, function(result) cb(result) end)
end

ESX.RegisterServerCallback('esx_adminskin:DeleteSkin', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	DeleteSkin(xPlayer, function(result) if result.affectedRows > 0 then cb() end end)
end)

RegisterServerEvent('esx_adminskin:SaveSkin')
AddEventHandler('esx_adminskin:SaveSkin', function(skin, personal)
	local xPlayer = ESX.GetPlayerFromId(source)
	local skin = json.encode(skin)
	if personal then
		DeleteSkin(xPlayer, function() MySQL.insert('INSERT INTO admin_skin (identifier, skin) VALUES (?, ?)', {xPlayer.identifier, skin}) end)
	else
		SaveResourceFile(GetCurrentResourceName(), 'adminskin.txt', skin)
	end
end)

ESX.RegisterServerCallback('esx_adminskin:GetSkin', function(source, cb, personal)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.single('SELECT skin FROM admin_skin WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(admin)
		cb(json.decode(personal and admin and admin.skin or LoadResourceFile(GetCurrentResourceName(), 'adminskin.txt')))
	end)
end)

ESX.RegisterCommand({'adminskin', 'as'}, 'admin', function(xPlayer, args, showError)
	TriggerClientEvent('esx_adminskin:ToggleSkin', xPlayer.source)
end, false, {help = _U('command_adminskin')})

ESX.RegisterCommand({'adminskin:menu', 'asm'}, 'admin', function(xPlayer, args, showError)
	TriggerClientEvent('esx_adminskin:OpenMenu', xPlayer.source)
end, false, {help = _U('command_adminskinmenu')})