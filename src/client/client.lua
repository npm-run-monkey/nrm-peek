RegisterKeyMapping('peek', 'Use peek', 'keyboard', 'LMENU');

function GetForwardVector(rotation)
	local rot = (math.pi / 180.0) * rotation
	return vector3(-math.sin(rot.z) * math.abs(math.cos(rot.x)), math.cos(rot.z) * math.abs(math.cos(rot.x)), math.sin(rot.x))
end

function RayCast(origin, target, options, ignoreEntity, radius)
	local handle = StartExpensiveSynchronousShapeTestLosProbe(origin.x, origin.y, origin.z, target.x, target.y, target.z, -1, 0, 0)
	return GetShapeTestResult(handle)
end

function GetTargetCoords()
	local CameraCoords = GetGameplayCamCoord()
	local ForwardVectors = GetForwardVector(GetGameplayCamRot(2))
	local ForwardCoords = CameraCoords + (ForwardVectors * (IsInVehicle and 6.5 or 5.0))
	local TargetCoords = vector3(0.0, 0.0, 0.0)
	local Entity = 0
	
	if ForwardVectors then
		local _, hit, targetCoords, _, entity = RayCast(CameraCoords, ForwardCoords, 17, 0, 0.1)

		TargetCoords = targetCoords
		Entity = entity 

		if DEBUG_ENABLED and hit ~= 0 then
			DrawMarker(28, targetCoords.x, targetCoords.y, targetCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.01, 0.01, 0.01, 255, 0, 0, 255, false, false, 2, nil, nil, false)
		end
	end

    ----print(TargetCoords, Entity)
	return TargetCoords, Entity
end

local openPeek = false
local clicked = false

local openPeekUI = function(bool, entries)
    openPeek = bool
    SendReactMessage('openPeek', json.encode({ bool = bool }));
end

RegisterNUICallback('hidePeek', function()
    openPeek = false
    clicked = false
    SetNuiFocus(false, false)
end)

RegisterNUICallback('triggerEvent', function(data, cb)
    local _data = json.decode(data)
    openPeekUI(false)
    SetNuiFocus(false, false)
    TriggerEvent(_data.event, NetworkGetEntityFromNetworkId(_data.entity));
    openPeek = false
    clicked = false
end)

RegisterCommand('coords', function()
    local ped = GetPlayerPed(-1)
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    --print(coords.x, coords.y, coords.z, heading)
end)

RegisterNetEvent('nrm-peek:server:client:triggerEvent')

AddEventHandler('nrm-peek:server:client:triggerEvent', function(entries, entity)
    local _entries = json.decode(entries)

    for k,v in pairs(_entries) do
        --print(v.name, v.event)
        SendReactMessage('entryData', json.encode({ entry = { name = v.name, event = v.event, entity = entity } }));
    end

    --
end)

RegisterCommand('peek', function()
    Citizen.CreateThread(function()
        local entity

        while (IsControlPressed(0, 19) and not clicked) do
            if (not openPeek) then
                openPeekUI(true)
            end

            local TargetCoords, Entity = GetTargetCoords();

            if (Entity > 0) then
                clicked = true
                SetNuiFocus(true, true)

                NetworkRegisterEntityAsNetworked(Entity)
                TriggerServerEvent('nrm-peek:client:server:foundEntity', NetworkGetNetworkIdFromEntity(Entity));
                --SendReactMessage('entryData', json.encode({ entry = { name = "Kleding Winkel", event = "nrm-clothing:client:client:openClothingMenu" } }));
            end

            Citizen.Wait(20)
        end
        if (clicked) then
            return
        end

        openPeekUI(false)
    end)
end)