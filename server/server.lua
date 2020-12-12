ESX                = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


ESX.RegisterCommand('jail', 'admin', function(xPlayer, args, showError)
	local src = source
	local jailPlayer = args.playerId.source
	local jailTime = args.jailTime
	local jailReason = args.jailReason
	
	if GetPlayerName(jailPlayer) ~= nil then
		if jailTime ~= nil then
			JailPlayer(jailPlayer, jailTime)
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

--[[
RegisterCommand("jail", function(src, args, raw)	
	if xPlayer["job"]["name"] == "police" then

		local jailPlayer = args[1]
		local jailTime = tonumber(args[2])
		local jailReason = args[3]

		if GetPlayerName(jailPlayer) ~= nil then

			if jailTime ~= nil then
				JailPlayer(jailPlayer, jailTime)

				TriggerClientEvent("esx:showNotification", src, GetPlayerName(jailPlayer) .. " Jailed for " .. jailTime .. " months!")
				
				if args[3] ~= nil then
					GetRPName(jailPlayer, function(Firstname, Lastname)
						TriggerClientEvent('chat:addMessage', -1, { args = { "JUDGE",  Firstname .. " " .. Lastname .. " Is now in jail for the reason: " .. args[3] }, color = { 249, 166, 0 } })
					end)
				end
			else
				TriggerClientEvent("esx:showNotification", src, "This time is invalid!")
			end
		else
			TriggerClientEvent("esx:showNotification", src, "This ID is not online!")
		end
	else
		TriggerClientEvent("esx:showNotification", src, "You are not an officer!")
	end
end)
]]--

RegisterCommand("unjail", function(src, args)
	local source = src
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.job.name == "police" or xPlayer.getGroup() ~= 'user' then

		local jailPlayer = args[1]

		if GetPlayerName(jailPlayer) ~= nil then
			UnJail(jailPlayer)
		else
			TriggerClientEvent("pNotify:SendNotification", source, { text = "این شهروند آنلاین نیست.", type = "error", timeout = 4000, layout = "bottomCenter"})
		end
	else
		TriggerClientEvent("pNotify:SendNotification", source, { text = "شما مدیر یا پلیس نیستید.", type = "error", timeout = 4000, layout = "bottomCenter"})
	end
end)

RegisterServerEvent("esx-qalle-jail:jailPlayer")
AddEventHandler("esx-qalle-jail:jailPlayer", function(targetSrc, jailTime, jailReason)
	local targetSrc = tonumber(targetSrc)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if xPlayer.job.name == "police" or xPlayer.getGroup() ~= 'user' then
		if GetPlayerName(targetSrc) ~= nil then
			JailPlayer(targetSrc, jailTime)
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
	local src = srouce
	local xPlayer = ESX.GetPlayerFromId(src)
	local tPlayer = ESX.GetPlayerFromIdentifier(targetIdentifier)
	if xPlayer.job.name == "police" or xPlayer.getGroup() ~= 'user' then
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
	TriggerClientEvent("pNotify:SendNotification", src, { text = "شما " .. Config.PrisonWorkReward .. "$ جایزه گرفتید.", type = "info", timeout = 4000, layout = "bottomCenter"})
end)

function JailPlayer(jailPlayer, jailTime)
	local tPlayer = ESX.GetPlayerFromId(jailPlayer)
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