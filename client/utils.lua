function LoadAnim(animDict)
	RequestAnimDict(animDict)

	while not HasAnimDictLoaded(animDict) do
		Citizen.Wait(10)
	end
end

function LoadModel(model)
	RequestModel(model)

	while not HasModelLoaded(model) do
		Citizen.Wait(10)
	end
end

function HideHUDThisFrame()
	HideHelpTextThisFrame()
	HideHudAndRadarThisFrame()
	HideHudComponentThisFrame(1)
	HideHudComponentThisFrame(2)
	HideHudComponentThisFrame(3)
	HideHudComponentThisFrame(4)
	HideHudComponentThisFrame(6)
	HideHudComponentThisFrame(7)
	HideHudComponentThisFrame(8)
	HideHudComponentThisFrame(9)
	HideHudComponentThisFrame(13)
	HideHudComponentThisFrame(11)
	HideHudComponentThisFrame(12)
	HideHudComponentThisFrame(15)
	HideHudComponentThisFrame(18)
	HideHudComponentThisFrame(19)
end

function Cutscene()
	DoScreenFadeOut(100)
	Citizen.Wait(250)

	TriggerEvent('skinchanger:getSkin', function(skin)
		if skin.sex == 0 then
			local clothesSkin = {
				['tshirt_1'] = 15,  ['tshirt_2'] = 0,
				['torso_1']  = 146, ['torso_2']  = 0,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms']     = 119, ['pants_1']  = 3,
				['pants_2']  = 7,   ['shoes_1']  = 12,
				['shoes_2']  = 12,  ['chain_1']  = 0,
				['chain_2']  = 0

			}
			TriggerEvent('skinchanger:loadClothes', skin, clothesSkin)
		else
			local clothesSkin = {
				['tshirt_1'] = 3,   ['tshirt_2'] = 0,
				['torso_1']  = 38,  ['torso_2']  = 3,
				['decals_1'] = 0,   ['decals_2'] = 0,
				['arms']     = 120,  ['pants_1'] = 3,
				['pants_2']  = 15,  ['shoes_1']  = 66,
				['shoes_2']  = 5,   ['chain_1']  = 0,
				['chain_2']  = 0
			}
			TriggerEvent('skinchanger:loadClothes', skin, clothesSkin)
		end
	end)

	LoadModel(-1320879687)

	local PolicePosition = Config.Cutscene["PolicePosition"]
	local Police = CreatePed(5, -1320879687, PolicePosition["x"], PolicePosition["y"], PolicePosition["z"], PolicePosition["h"], false)
	TaskStartScenarioInPlace(Police, "WORLD_HUMAN_PAPARAZZI", 0, false)

	local PlayerPosition = Config.Cutscene["PhotoPosition"]
	local PlayerPed = PlayerPedId()
	SetEntityCoords(PlayerPed, PlayerPosition["x"], PlayerPosition["y"], PlayerPosition["z"] - 1)
	SetEntityHeading(PlayerPed, PlayerPosition["h"])
	FreezeEntityPosition(PlayerPed, true)

	Cam()

	Citizen.Wait(1000)
	DoScreenFadeIn(100)
	Citizen.Wait(10000)
	DoScreenFadeOut(250)

	local JailPosition = Config.JailPositions["Cell"]
	SetEntityCoords(PlayerPed, JailPosition["x"], JailPosition["y"], JailPosition["z"])
	DeleteEntity(Police)
	SetModelAsNoLongerNeeded(-1320879687)

	Citizen.Wait(1000)

	DoScreenFadeIn(250)

	TriggerServerEvent("InteractSound_SV:PlayOnSource", "cell", 0.3)

	RenderScriptCams(false,  false,  0,  true,  true)
	FreezeEntityPosition(PlayerPed, false)
	DestroyCam(Config.Cutscene["CameraPos"]["cameraId"])

	InJail()
end

function Cam()
	local CamOptions = Config.Cutscene["CameraPos"]

	CamOptions["cameraId"] = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

    SetCamCoord(CamOptions["cameraId"], CamOptions["x"], CamOptions["y"], CamOptions["z"])
	SetCamRot(CamOptions["cameraId"], CamOptions["rotationX"], CamOptions["rotationY"], CamOptions["rotationZ"])

	RenderScriptCams(true, false, 0, true, true)
end

Citizen.CreateThread(function()
	local blip = AddBlipForCoord(Config.Teleports2["Boiling Broke"]["x"], Config.Teleports2["Boiling Broke"]["y"], Config.Teleports2["Boiling Broke"]["z"])

    SetBlipSprite (blip, 188)
    SetBlipDisplay(blip, 4)
    SetBlipScale  (blip, 1.4)
    SetBlipColour (blip, 73)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Prison')
    EndTextCommandSetBlipName(blip)
end)