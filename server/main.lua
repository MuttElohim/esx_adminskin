MySQL.query('CREATE TABLE IF NOT EXISTS adminskin (identifier varchar(60) NOT NULL, skin longtext DEFAULT NULL)')

function deleteSkin(xPlayer, cb)
	MySQL.query('DELETE FROM adminskin WHERE identifier = ?', {xPlayer.identifier}, function(result) cb(result) end)
end

ESX.RegisterServerCallback('esx_adminskin:deleteAdminSkin', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	deleteSkin(xPlayer, function(result)
		if result.affectedRows > 0 then cb() end
	end)
end)

RegisterServerEvent('esx_adminskin:save')
AddEventHandler('esx_adminskin:save', function(global, skin)
	local xPlayer = ESX.GetPlayerFromId(source)
	local skin = json.encode(skin)
	if global then
		SaveResourceFile(GetCurrentResourceName(), 'adminskin.txt', skin)
	else
		deleteSkin(xPlayer, function()
			MySQL.insert('INSERT INTO adminskin (identifier, skin) VALUES (?, ?)', {xPlayer.identifier, skin})
		end)
	end
end)

ESX.RegisterServerCallback('esx_adminskin:getAdminSkin', function(source, cb, global)
	local xPlayer = ESX.GetPlayerFromId(source)

	if global then
		cb(json.decode(LoadResourceFile(GetCurrentResourceName(), 'adminskin.txt')))
	else
		MySQL.query('SELECT skin FROM adminskin WHERE identifier = @identifier', {
			['@identifier'] = xPlayer.identifier
		}, function(admin)
			cb(json.decode(#admin == 1 and admin[1].skin or LoadResourceFile(GetCurrentResourceName(), 'adminskin.txt')))
		end)
	end
end)

ESX.RegisterCommand({'adminskin', 'as'}, 'admin', function(xPlayer, args, showError)
	TriggerClientEvent('esx_adminskin:toggledress', xPlayer.source)
end, false, {help = _U('command_adminskin')})

ESX.RegisterCommand({'adminskinmenu', 'asm'}, 'admin', function(xPlayer, args, showError)
	TriggerClientEvent('esx_adminskin:OpenMenu', xPlayer.source)
end, false, {help = _U('command_adminskinmenu')})
