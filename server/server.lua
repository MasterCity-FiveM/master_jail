ESX                = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterCommand('jail', 'admin', function(xPlayer, args, showError)
	local src = source
	local jailPlayer = args.playerId.source
	local jailTime = args.jailTime
	local jailReason = args.jailReason
	
	if GetPlayerName(jailPlayer) ~= nil then
		if jailTime ~= nil then
			JailPlayer(src, jailPlayer, jailTime)
			TriggerClientEvent("pNotify:SendNotification", jailPlayer, { text = "شما به مدت " .. jailTime .. " ماه زندانی شدید.", type = "error", timeout = 4000, layout = "bottomCenter"})
		else
			TriggerClientEvent("pNotify:SendNotification", src, { text = "مدت زندانی شدن صحیح نیست.", type = "error", timeout = 4000, layout = "bottomCenter"})
		end
	else
		TriggerClientEvent("pNotify:SendNotification", src, { text = "این شهروند آنلاین نیست.", type = "error", timeout = 4000, layout = "bottomCenter"})
	end
	
end, true, {help = "زندانی کردن شهروند", validate = true, arguments = {
	{name = 'playerId', help = 'Code Melli Dorost nist!', type = 'player'},
	{name = 'jailTime', help = 'Time Jail dorost nist!', type = 'number'},
	{name = 'jailReason', help = 'Dalil dorost nist!', type = 'string'}
}})


ESX.RegisterCommand('unjail', 'admin', function(xPlayer, args, showError)
	local src = source
	local jailPlayer = args.playerId.source
	
	if GetPlayerName(jailPlayer) ~= nil then
		UnJail(jailPlayer)
		TriggerClientEvent("pNotify:SendNotification", jailPlayer, { text = "بازیکن از زندان خارج شد.", type = "success", timeout = 4000, layout = "bottomCenter"})
	else
		TriggerClientEvent("pNotify:SendNotification", src, { text = "این شهروند آنلاین نیست.", type = "error", timeout = 4000, layout = "bottomCenter"})
	end
	
end, true, {help = "آزاد کردن از زندان", validate = true, arguments = {
	{name = 'playerId', help = 'Code Melli Dorost nist!', type = 'player'}
}})

RegisterServerEvent("esx-qalle-jail:jailPlayer")
AddEventHandler("esx-qalle-jail:jailPlayer", function(targetSrc, jailTime, jailReason)
	local targetSrc = tonumber(targetSrc)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if xPlayer.job.name == "police" or xPlayer.getGroup() ~= 'user' then
		if GetPlayerName(targetSrc) ~= nil then
			JailPlayer(src, targetSrc, jailTime)
			TriggerClientEvent("pNotify:SendNotification", targetSrc, { text = "شما به مدت " .. jailTime .. " ماه زندانی شدید.", type = "error", timeout = 4000, layout = "bottomCenter"})
			TriggerClientEvent("pNotify:SendNotification", src, { text =  GetPlayerName(targetSrc) .. " به مدت " .. jailTime .. " ماه زندانی شد.", type = "success", timeout = 4000, layout = "bottomCenter"})
		else
			TriggerClientEvent("pNotify:SendNotification", src, { text = "این شهروند آنلاین نیست.", type = "error", timeout = 4000, layout = "bottomCenter"})
		end
	else
		TriggerClientEvent("pNotify:SendNotification", src, { text = "شما مدیر یا پلیس نیستید.", type = "error", timeout = 4000, layout = "bottomCenter"})
	end
end)

RegisterServerEvent("esx-qalle-jail:unJailPlayer")
AddEventHandler("esx-qalle-jail:unJailPlayer", function(targetIdentifier)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local tPlayer = ESX.GetPlayerFromIdentifier(targetIdentifier)
	if not xPlayer.job.name == "police" or xPlayer.getGroup() ~= 'user' then
		if xPlayer.source ~= tPlayer.source then
			if tPlayer ~= nil then
				UnJail(tPlayer.source)
			else
				MySQL.Async.execute(
					"UPDATE users SET jail = @newJailTime WHERE identifier = @identifier",
					{
						['@identifier'] = tPlayer,
						['@newJailTime'] = 0
					}
				)
			end
			TriggerClientEvent("pNotify:SendNotification", src, { text = "بازیکن از زندان خارج شد.", type = "success", timeout = 4000, layout = "bottomCenter"})
		else
			TriggerClientEvent("pNotify:SendNotification", src, { text = "شما نمیتوانید خودتان  را آزاد کنید.", type = "error", timeout = 4000, layout = "bottomCenter"})
		end
	else
		TriggerClientEvent("pNotify:SendNotification", src, { text = "شما مدیر یا پلیس نیستید.", type = "error", timeout = 4000, layout = "bottomCenter"})
	end
end)

RegisterServerEvent("esx-qalle-jail:updateJailTime")
AddEventHandler("esx-qalle-jail:updateJailTime", function(newJailTime)
	local src = source
	EditJailTime(src, newJailTime)
end)

RegisterServerEvent("esx-qalle-jail:prisonWorkReward")
AddEventHandler("esx-qalle-jail:prisonWorkReward", function()
	local src = source

	local xPlayer = ESX.GetPlayerFromId(src)
	xPlayer.addMoney(Config.PrisonWorkReward)
	TriggerClientEvent("pNotify:SendNotification", src, { text = "شما " .. Config.PrisonWorkReward .. "$ جایزه گرفتید و یک ماه از حبس شما کم شد.", type = "info", timeout = 4000, layout = "bottomCenter"})
end)

function GetItemCount(source, item)
    local xPlayer = ESX.GetPlayerFromId(source)
    local items = xPlayer.getInventoryItem(item)

    if items == nil then
        return 0
    else
        return items.count
    end
end

function JailPlayer(src, jailPlayer, jailTime)
	local tPlayer = ESX.GetPlayerFromId(jailPlayer)
	local xPlayer = ESX.GetPlayerFromId(src)
	
	if tPlayer.get('EscortBy') then
		yPlayer = ESX.GetPlayerFromId(tPlayer.get('EscortBy'))
		if yPlayer and yPlayer.get('EscortPlayer') and yPlayer.get('EscortPlayer') == jailPlayer then
			yPlayer.set('EscortPlayer', nil)
			TriggerClientEvent('esx_policejob:dragCopOn', yPlayer.source, jailPlayer)
		end
		
		TriggerClientEvent('esx_policejob:dragOn', jailPlayer, yPlayer.source)
		tPlayer.set('EscortBy', nil)
	end
	
	if tPlayer.get('HandCuffedBy') then
		yPlayer = ESX.GetPlayerFromId(tPlayer.get('HandCuffedBy'))
		if yPlayer and yPlayer.get('HandCuffedPlayer') and yPlayer.get('HandCuffedPlayer') == jailPlayer then
			if GetItemCount(yPlayer.source, 'handcuffs') == 0 then
				yPlayer.addInventoryItem('handcuffs', 1)
			end
			
			yPlayer.set('HandCuffedPlayer', nil)
		end
	end
	
	if tPlayer.get('HandCuff') then
		tPlayer.set('HandCuff', false)
		TriggerClientEvent('esx_policejob:handuncuffFast', jailPlayer, true)
		tPlayer.set('HandCuffedBy', nil)
	end

	for k,v in ipairs(tPlayer.loadout) do
		tPlayer.removeWeapon(v.name)
	end
	
	TriggerClientEvent("esx-qalle-jail:jailPlayer", jailPlayer, jailTime)
	EditJailTime(jailPlayer, jailTime)
end

function UnJail(jailPlayer)
	TriggerClientEvent("esx-qalle-jail:unJailPlayer", jailPlayer)
	EditJailTime(jailPlayer, 0)
end

function EditJailTime(source, jailTime)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(source)
	local Identifier = xPlayer.identifier

	MySQL.Async.execute(
       "UPDATE users SET jail = @newJailTime WHERE identifier = @identifier",
        {
			['@identifier'] = Identifier,
			['@newJailTime'] = tonumber(jailTime)
		}
	)
end

ESX.RegisterServerCallback("esx-qalle-jail:retrieveJailedPlayers", function(source, cb)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local jailedPersons = {}
	if xPlayer.job.name == "police" or xPlayer.getGroup() ~= 'user' then
		MySQL.Async.fetchAll("SELECT firstname, lastname, jail, identifier FROM users WHERE jail > @jail", { ["@jail"] = 0 }, function(result)

			for i = 1, #result, 1 do
				table.insert(jailedPersons, { name = result[i].firstname .. " " .. result[i].lastname, jailTime = result[i].jail, identifier = result[i].identifier })
			end

			cb(jailedPersons)
		end)
	else
		TriggerClientEvent("pNotify:SendNotification", src, { text = "شما مدیر یا پلیس نیستید.", type = "error", timeout = 4000, layout = "bottomCenter"})
		cb(jailedPersons)
	end
end)

ESX.RegisterServerCallback("esx-qalle-jail:retrieveJailTime", function(source, cb)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local Identifier = xPlayer.identifier

	MySQL.Async.fetchAll("SELECT jail FROM users WHERE identifier = @identifier", { ["@identifier"] = Identifier }, function(result)

		local JailTime = tonumber(result[1].jail)

		if JailTime > 0 then

			cb(true, JailTime)
		else
			cb(false, 0)
		end
	end)
end)