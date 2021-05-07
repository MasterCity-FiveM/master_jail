ESX                = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RunCustomFunction("AddCommand", {"jail"}, 1, function(xPlayer, args)
	local src = source
	local jailPlayer = args.playerId.source
	local jailTime = args.jailTime
	local jailReason = args.jailReason
	
	if jailReason == nil then
		jailReason = "No Reason"
	end
	
	if GetPlayerName(jailPlayer) ~= nil then
		if jailTime ~= nil then
			ESX.RunCustomFunction("discord", xPlayer.source, 'jail', 'GM Jail', "Player: **" .. GetPlayerName(jailPlayer) .. "**\nTime: **" .. jailTime .. "**\nReason: " .. jailReason, "2106194")
			JailPlayer(src, jailPlayer, jailTime)
			TriggerClientEvent("pNotify:SendNotification", jailPlayer, { text = "شما به مدت " .. jailTime .. " ماه زندانی شدید.", type = "error", timeout = 4000, layout = "bottomCenter"})
		else
			TriggerClientEvent("pNotify:SendNotification", src, { text = "مدت زندانی شدن صحیح نیست.", type = "error", timeout = 4000, layout = "bottomCenter"})
		end
	else
		TriggerClientEvent("pNotify:SendNotification", src, { text = "این شهروند آنلاین نیست.", type = "error", timeout = 4000, layout = "bottomCenter"})
	end
end, {
	{name = 'playerId', type = 'player'},
	{name = 'jailTime', type = 'number'},
	{name = 'jailReason', type = 'full'}
}, '.jail PlayerID jailTime jailReason', '.')

ESX.RunCustomFunction("AddCommand", {"unjail"}, 2, function(xPlayer, args)
	local src = source
	local jailPlayer = args.playerId.source
	
	
	if GetPlayerName(jailPlayer) ~= nil then
		ESX.RunCustomFunction("discord", xPlayer.source, 'jail', 'GM UnJail', "Player: **" .. GetPlayerName(jailPlayer) .. "**", "2384697")
		UnJail(jailPlayer)
		TriggerClientEvent("pNotify:SendNotification", jailPlayer, { text = "بازیکن از زندان خارج شد.", type = "success", timeout = 4000, layout = "bottomCenter"})
	else
		TriggerClientEvent("pNotify:SendNotification", src, { text = "این شهروند آنلاین نیست.", type = "error", timeout = 4000, layout = "bottomCenter"})
	end
end, {
	{name = 'playerId', type = 'player'}
}, '.unjail PlayerID', '.')

RegisterServerEvent("master_jail:jailPlayer")
AddEventHandler("master_jail:jailPlayer", function(targetSrc, jailTime, jailReason)
	ESX.RunCustomFunction("anti_ddos", source, 'master_jail:jailPlayer', {targetSrc = targetSrc, jailTime = jailTime, jailReason = jailReason})
	local targetSrc = tonumber(targetSrc)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if xPlayer.job.name == "police" or xPlayer.job.name == "sheriff" or xPlayer.getRank() > 0 then
		if GetPlayerName(targetSrc) ~= nil then
			JailPlayer(src, targetSrc, jailTime)
			TriggerClientEvent("pNotify:SendNotification", targetSrc, { text = "شما به مدت " .. jailTime .. " ماه زندانی شدید.", type = "error", timeout = 4000, layout = "bottomCenter"})
			TriggerClientEvent("pNotify:SendNotification", src, { text =  GetPlayerName(targetSrc) .. " به مدت " .. jailTime .. " ماه زندانی شد.", type = "success", timeout = 4000, layout = "bottomCenter"})
			ESX.RunCustomFunction("discord", source, 'jail', 'Faction Jail', "Player: **" .. GetPlayerName(targetSrc) .. "**\nTime: **" .. jailTime .. "**\nReason: " .. jailReason)
		else
			TriggerClientEvent("pNotify:SendNotification", src, { text = "این شهروند آنلاین نیست.", type = "error", timeout = 4000, layout = "bottomCenter"})
		end
	else
		TriggerClientEvent("pNotify:SendNotification", src, { text = "شما مدیر یا پلیس نیستید.", type = "error", timeout = 4000, layout = "bottomCenter"})
	end
end)

RegisterServerEvent("master_jail:unJailPlayer")
AddEventHandler("master_jail:unJailPlayer", function(targetIdentifier)
	ESX.RunCustomFunction("anti_ddos", source, 'master_jail:unJailPlayer', {targetIdentifier = targetIdentifier})
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local tPlayer = ESX.GetPlayerFromIdentifier(targetIdentifier)
	if not xPlayer.job.name == "police" or xPlayer.job.name == "sheriff" or xPlayer.getRank() > 0 then
		if tPlayer and xPlayer.source ~= tPlayer.source then
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
			ESX.RunCustomFunction("discord", source, 'jail', 'Faction UnJail', "Player: **" .. GetPlayerName(tPlayer) .. "**")
		else
			TriggerClientEvent("pNotify:SendNotification", src, { text = "شما نمیتوانید خودتان  را آزاد کنید.", type = "error", timeout = 4000, layout = "bottomCenter"})
		end
	else
		TriggerClientEvent("pNotify:SendNotification", src, { text = "شما مدیر یا پلیس نیستید.", type = "error", timeout = 4000, layout = "bottomCenter"})
	end
end)

RegisterServerEvent("master_jail:updateJailTime")
AddEventHandler("master_jail:updateJailTime", function(newJailTime)
	ESX.RunCustomFunction("anti_ddos", source, 'master_jail:updateJailTime', {newJailTime = newJailTime})
	local src = source
	EditJailTime(src, newJailTime)
end)

RegisterServerEvent("master_jail:prisonWorkReward")
AddEventHandler("master_jail:prisonWorkReward", function()
	ESX.RunCustomFunction("anti_ddos", source, 'master_jail:prisonWorkReward', {})
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
	
	TriggerClientEvent('esx_policejob:dargOff', -1, tPlayer.source)
	TriggerClientEvent('esx_policejob:darg', tPlayer.source, nil)
	
	if tPlayer.get('HandCuff') then
		if GetItemCount(xPlayer.source, 'handcuffs') <= 2 then
			xPlayer.addInventoryItem('handcuffs', 1)
		end
		TriggerClientEvent('esx_policejob:handuncuff', tPlayer.source, foot)
	end
	
	for k,v in ipairs(tPlayer.loadout) do
		tPlayer.removeWeapon(v.name)
	end
	
	TriggerClientEvent("master_jail:jailPlayer", jailPlayer, jailTime)
	EditJailTime(jailPlayer, jailTime)
end

function UnJail(jailPlayer)
	TriggerClientEvent("master_jail:unJailPlayer", jailPlayer)
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

ESX.RegisterServerCallback("master_jail:retrieveJailedPlayers", function(source, cb)
	ESX.RunCustomFunction("anti_ddos", source, 'master_jail:retrieveJailedPlayers', {})
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local jailedPersons = {}
	if xPlayer.job.name == "police" or xPlayer.job.name == "sheriff" or xPlayer.getRank() > 0 then
		MySQL.Async.fetchAll("SELECT firstname, lastname, jail, identifier FROM users WHERE jail > @jail", { ["@jail"] = 0 }, function(result)

			for i = 1, #result, 1 do
				if result[i].identifier ~= nil then
					local tPlayer = ESX.GetPlayerFromIdentifier(result[i].identifier)
					if tPlayer then
						table.insert(jailedPersons, { name = result[i].firstname .. " " .. result[i].lastname, jailTime = result[i].jail, identifier = result[i].identifier })
					end
				end
			end

			cb(jailedPersons)
		end)
	else
		TriggerClientEvent("pNotify:SendNotification", src, { text = "شما مدیر یا پلیس نیستید.", type = "error", timeout = 4000, layout = "bottomCenter"})
		cb(jailedPersons)
	end
end)

ESX.RegisterServerCallback("master_jail:retrieveJailTime", function(source, cb)
	ESX.RunCustomFunction("anti_ddos", source, 'master_jail:retrieveJailTime', {})
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