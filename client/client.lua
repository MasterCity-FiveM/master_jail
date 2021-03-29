local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX = nil

PlayerData = {}

local jailTime = 0
local unjail = false
local PackageID = nil
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData() == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()

	--LoadTeleporters()
end)

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(newData)
	PlayerData = newData

	Citizen.Wait(25000)

	ESX.TriggerServerCallback("master_jail:retrieveJailTime", function(inJail, newJailTime)
		if inJail then

			jailTime = newJailTime

			JailLogin()
		end
	end)
end)

RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(response)
	PlayerData["job"] = response
end)

RegisterNetEvent("master_jail:openJailMenu")
AddEventHandler("master_jail:openJailMenu", function()
	OpenJailMenu()
end)

RegisterNetEvent("master_jail:jailPlayer")
AddEventHandler("master_jail:jailPlayer", function(newJailTime)
	jailTime = newJailTime
	Cutscene()
end)


RegisterNetEvent("master_jail:unJailPlayer")
AddEventHandler("master_jail:unJailPlayer", function()
	jailTime = 0
	UnJail()
	unjail = true
end)

function JailLogin()
	local JailPosition = Config.JailPositions["Cell"]
	SetEntityCoords(PlayerPedId(), JailPosition["x"], JailPosition["y"], JailPosition["z"] - 1)
	exports.pNotify:SendNotification({text = "آخرین باری که از سرور خارج شدید در زندان بودید، لذا مجدد به زندان باز میگردید.", type = "info", timeout = 6000})
	InJail()
end

function UnJail()
	Citizen.Wait(100)
	
	if PackageID then
		DeleteEntity(PackageID)
		ClearPedTasksImmediately(PlayerPedId())
		deliverd = true
	end
	
	if IsEntityPlayingAnim(PlayerPedId(), "anim@heists@box_carry@", "idle", 3) then
		StopAnimTask(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 1.0)
	end

	InJail()
	ESX.Game.Teleport(PlayerPedId(), Config.Teleports2["Boiling Broke"])
	ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
		TriggerEvent('skinchanger:loadSkin', skin)
	end)

	
	exports.pNotify:SendNotification({text = "شما از زندان خارج شدید، امیدواریم از اشتباهات خود درس گرفته باشید!", type = "success", timeout = 6000})
end

function InJail()
	--Jail Timer--
	local JailPosition = Config.JailPositions["Cell"]
	Citizen.CreateThread(function()
		while jailTime > 0 do
			if jailTime >= 2 then
				exports.pNotify:SendNotification({text = "شما " .. jailTime .." ماه دیگر از زندان خارج می شوید.", type = "info", timeout = 3000})
			end
			jailTime = jailTime - 1
			
			local Ped = PlayerPedId()
			TriggerServerEvent("master_jail:updateJailTime", jailTime)
			local PedCoords = GetEntityCoords(Ped)
			if jailTime < 1 then
				UnJail()
				TriggerServerEvent("master_jail:updateJailTime", 0)
			end
			Citizen.Wait(60000)
		end
	end)
	
	Citizen.CreateThread(function()
		local JailPosition = Config.JailPositions["Cell"]
		local JailCenterPostion = Config.JailPositions["Center"]
		while jailTime > 0 do
			DisableControlAction(0, 24, true) -- Attack
			DisableControlAction(0, 257, true) -- Attack 2
			DisableControlAction(0, 25, true) -- Aim
			DisableControlAction(0, 263, true) -- Melee Attack 1
			DisableControlAction(0, 45, true) -- Reload
			DisableControlAction(0, 288, true) -- Phone
			local Ped = PlayerPedId()
			local PedCoords = GetEntityCoords(Ped)

			local DistanceCheck = GetDistanceBetweenCoords(PedCoords, JailCenterPostion["x"], JailCenterPostion["y"], JailCenterPostion["z"], true)
			if DistanceCheck> 61.5 then
				SetEntityCoords(Ped, JailPosition["x"], JailPosition["y"], JailPosition["z"])
			end
			Citizen.Wait(0)
		end
	end)

	--Jail Timer--

			
	--Prison Work--

	Citizen.CreateThread(function()
		while jailTime > 0 do
			local sleepThread = 500
			local Packages = Config.PrisonWork["Packages"]
			local Ped = PlayerPedId()
			local PedCoords = GetEntityCoords(Ped)

			for posId, v in pairs(Packages) do
				local DistanceCheck = GetDistanceBetweenCoords(PedCoords, v["x"], v["y"], v["z"], true)
				if DistanceCheck <= 10.0 then
					sleepThread = 5
					local PackageText = "Pack"

					if not v["state"] then
						PackageText = "Already Taken"
					end
					
					DrawMarker(21, vector3(v["x"], v["y"], v["z"]), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
					
					ESX.Game.Utils.DrawText3D(v, "[E] " .. PackageText, 0.4)
					if DistanceCheck <= 1.5 then
						if IsControlJustPressed(0, 38) then
							if v["state"] then
								PackPackage(posId)
							else
								exports.pNotify:SendNotification({text = "شما این بسته را قبلا دریافت کردید.", type = "info", timeout = 3000})
							end
						end
					end
				end
			end
			Citizen.Wait(sleepThread)
		end
	end)
end

--[[
function LoadTeleporters()
	Citizen.CreateThread(function()
		while true do
			
			local sleepThread = 500

			local Ped = PlayerPedId()
			local PedCoords = GetEntityCoords(Ped)

			for p, v in pairs(Config.Teleports) do

				local DistanceCheck = GetDistanceBetweenCoords(PedCoords, v["x"], v["y"], v["z"], true)

				if DistanceCheck <= 7.5 then

					sleepThread = 5

					ESX.Game.Utils.DrawText3D(v, "[E] Open Door", 0.4)

					if DistanceCheck <= 1.0 then
						if IsControlJustPressed(0, 38) then
							TeleportPlayer(v)
						end
					end
				end
			end

			Citizen.Wait(sleepThread)

		end
	end)
end
]]
function PackPackage(packageId)
	local Package = Config.PrisonWork["Packages"][packageId]

	LoadModel("prop_cs_cardbox_01")

	local PackageObject = CreateObject(GetHashKey("prop_cs_cardbox_01"), Package["x"], Package["y"], Package["z"], true)

	PlaceObjectOnGroundProperly(PackageObject)

	TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, false)

	local Packaging = true
	local StartTime = GetGameTimer()

	while Packaging and jailTime > 0 do
		Citizen.Wait(1)
		local TimeToTake = 30000 * 1 -- Minutes
		local PackPercent = (GetGameTimer() - StartTime) / TimeToTake * 100
		if not IsPedUsingScenario(PlayerPedId(), "PROP_HUMAN_BUM_BIN") then
			DeleteEntity(PackageObject)
			ESX.ShowNotification("Canceled!")
			Packaging = false
		end

		if PackPercent >= 100 then
			Packaging = false
			PackageID = PackageObject
			DeliverPackage(PackageObject)
			Package["state"] = false
		else
			ESX.Game.Utils.DrawText3D(Package, "Packaging... " .. math.ceil(tonumber(PackPercent)) .. "%", 0.4)
		end
	end
end

local deliverd = false

function DeliverPackage(packageId)
	if DoesEntityExist(packageId) then
		AttachEntityToEntity(packageId, PlayerPedId(), GetPedBoneIndex(PlayerPedId(),  28422), 0.0, -0.03, 0.0, 5.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
		ClearPedTasks(PlayerPedId())
	else
		return
	end
	
	local Packaging = true 
	LoadAnim("anim@heists@box_carry@")
	while Packaging and jailTime > 0 do

		Citizen.Wait(5)
		if not IsEntityPlayingAnim(PlayerPedId(), "anim@heists@box_carry@", "idle", 3) then
			TaskPlayAnim(PlayerPedId(), "anim@heists@box_carry@", "idle", 8.0, 8.0, -1, 50, 0, false, false, false)
		end

		if not IsEntityAttachedToEntity(packageId, PlayerPedId()) then
			Packaging = false
			DeleteEntity(packageId)
		else
			local DeliverPosition = Config.PrisonWork["DeliverPackage"]
			local PedPosition = GetEntityCoords(PlayerPedId())
			local DistanceCheck = GetDistanceBetweenCoords(PedPosition, DeliverPosition["x"], DeliverPosition["y"], DeliverPosition["z"], true)

			DrawMarker(21, vector3(DeliverPosition["x"], DeliverPosition["y"], DeliverPosition["z"]), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
					
			ESX.Game.Utils.DrawText3D(DeliverPosition, "[E] Leave Package", 0.4)

			if DistanceCheck <= 2.0 then
				if IsControlJustPressed(0, 38) then
					DeleteEntity(packageId)
					ClearPedTasksImmediately(PlayerPedId())
					Packaging = false
					PackageID = nil
					
					TriggerServerEvent("master_jail:prisonWorkReward")
					deliverd = true
					if deliverd == true then
						jailTime = jailTime - 1
					end
				end
			end
		end
	end
end

function OpenJailMenu()
	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'jail_prison_menu',
		{
			title    = "منوی زندان",
			align    = 'center',
			elements = {
				{ label = "زندانی کردن نزدیکترین فرد", value = "jail_closest_player" },
				{ label = "آزاد کردن زندانی", value = "unjail_player" }
			}
		}, 
	function(data, menu)

		local action = data.current.value

		if action == "jail_closest_player" then
			local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
			if closestPlayer == -1 or closestDistance > 3.0 then
				exports.pNotify:SendNotification({text = "شهروندی نزدیک شما نیست.", type = "error", timeout = 3000})
			else
				menu.close()
			
				ESX.UI.Menu.Open(
					'dialog', GetCurrentResourceName(), 'jail_choose_time_menu',
					{
						title = "مدت حبس (دقیقه)"
					},
				function(data2, menu2)

					local jailTime = tonumber(data2.value)

					if jailTime == nil then
						exports.pNotify:SendNotification({text = "زمان باید بر حسب دقیقه باشد.", type = "error", timeout = 3000})
					else
						menu2.close()

						if closestPlayer == -1 or closestDistance > 3.0 then
							exports.pNotify:SendNotification({text = "شهروندی نزدیک شما نیست.", type = "error", timeout = 3000})
						else
							ESX.UI.Menu.Open(
								'dialog', GetCurrentResourceName(), 'jail_choose_reason_menu',
								{
								  title = "دلیل حبس"
								},
							function(data3, menu3)
			  
								local reason = data3.value
			  
								if reason == nil then
									exports.pNotify:SendNotification({text = "شما باید دلیلی برای زندانی کردن فرد داشته باشید.", type = "error", timeout = 3000})
								else
									menu3.close()
			  
									local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
			  
									if closestPlayer == -1 or closestDistance > 3.0 then
										exports.pNotify:SendNotification({text = "شهروندی نزدیک شما نیست.", type = "error", timeout = 3000})
									else
										TriggerServerEvent("master_jail:jailPlayer", GetPlayerServerId(closestPlayer), jailTime, reason)
									end
			  
								end
			  
							end, function(data3, menu3)
								menu3.close()
							end)
						end

					end

				end, function(data2, menu2)
					menu2.close()
				end)
			end
		elseif action == "unjail_player" then

			local elements = {}

			ESX.TriggerServerCallback("master_jail:retrieveJailedPlayers", function(playerArray)

				if #playerArray == 0 then
					exports.pNotify:SendNotification({text = "زندانی وجود ندارد.", type = "error", timeout = 3000})
					return
				end

				for i = 1, #playerArray, 1 do
					table.insert(elements, {label = "زندانی: " .. playerArray[i].name .. " | مدت حبس: " .. playerArray[i].jailTime .. " ماه", value = playerArray[i].identifier })
				end

				ESX.UI.Menu.Open(
					'default', GetCurrentResourceName(), 'jail_unjail_menu',
					{
						title = "آزاد کردن شهروند",
						align = "center",
						elements = elements
					},
				function(data2, menu2)

					local action = data2.current.value

					TriggerServerEvent("master_jail:unJailPlayer", action)

					menu2.close()

				end, function(data2, menu2)
					menu2.close()
				end)
			end)

		end

	end, function(data, menu)
		menu.close()
	end)	
end

