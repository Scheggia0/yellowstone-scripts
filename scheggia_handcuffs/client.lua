TriggerEvent("menuapi:getData",function(call)
    MenuData = call
end)

Citizen.CreateThread(function()
    while true do
        local ped = GetPlayerPed()
        local coords = GetEntityCoords(PlayerPedId())

        if whenKeyJustPressed(0x4AF4D473) then
            TriggerServerEvent("scheggia_handcuffs:checkjob")
        end

        Citizen.Wait(5)
    end
end)

RegisterNetEvent('scheggia_handcuffs:use')
AddEventHandler('scheggia_handcuffs:use', function()
    MenuData.CloseAll()
	local elements = {
		{label = "Stella Sceriffo", value = 'star' , desc = "Mostra il badge"},
		{label = "Ammanetta", value = 'cuff' , desc = "Ammanetta"},
		{label = "Smanetta", value = 'uncuff' , desc = "Smanetta"},
	}
   MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
	{
		title    = "Menu Sceriffo",
		--subtext    = "Menu Sceriffo",
		align    = 'top-left',
		elements = elements,
	},
	function(data, menu)
		if (data.current.value == 'star') then 
			if not IsPedMale(ped) then
                Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(),  0x1FC12C9C, true, true, true)
                Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, false)
            else
                Citizen.InvokeNative(0xD3A7B003ED343FD9, PlayerPedId(), 0xDB4C451D, true, false, true)
                Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, false)
            end
            TriggerEvent("vorp:TipRight", "Hai mostrato la stella sceriffo", 2000)

        elseif (data.current.value == 'cuff') then
            local closestPlayer, closestDistance = GetClosestPlayer()
            if closestPlayer ~= -1 and closestDistance <= 3.0 then
                TriggerServerEvent("scheggia_handcuffs:cuffplayer", GetPlayerServerId(closestPlayer))
            end
        elseif (data.current.value == 'uncuff') then
            local closestPlayer, closestDistance = GetClosestPlayer()
            if closestPlayer ~= -1 and closestDistance <= 3.0 then
                TriggerServerEvent("scheggia_handcuffs:uncuffplayer", GetPlayerServerId(closestPlayer))
            end
		end
	end,
	function(data, menu)
		menu.close()
	end)
end)

function whenKeyJustPressed(key)
    if Citizen.InvokeNative(0x580417101DDB492F, 0, key) then
        return true
    else
        return false
    end
end

function GetClosestPlayer()
    local players, closestDistance, closestPlayer = GetActivePlayers(), -1, -1
    local playerPed, playerId = PlayerPedId(), PlayerId()
    local coords, usePlayerPed = coords, false

    if coords then
        coords = vector3(coords.x, coords.y, coords.z)
    else
        usePlayerPed = true
        coords = GetEntityCoords(playerPed)
    end

    for i = 1, #players, 1 do
        local tgt = GetPlayerPed(players[i])

        if not usePlayerPed or (usePlayerPed and players[i] ~= playerId) then
            local targetCoords = GetEntityCoords(tgt)
            local distance = #(coords - targetCoords)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = players[i]
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end

RegisterNetEvent("scheggia_handcuffs:cuff")
AddEventHandler("scheggia_handcuffs:cuff", function()
    local playerPed = PlayerPedId()
    SetEnableHandcuffs(playerPed, true)
end)

RegisterNetEvent("scheggia_handcuffs:uncuff")
AddEventHandler("scheggia_handcuffs:uncuff", function()
    local playerPed = PlayerPedId()
    UncuffPed(playerPed)
end)