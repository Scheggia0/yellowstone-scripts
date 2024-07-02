local telegrams = {}
local index = 1
local menu = false
local charLoaded = false
local todo = true

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000)
        if todo == true then
            TriggerServerEvent('scheggia_telegrams:check', source)
            Citizen.Wait(1000)
            if charLoaded == true then
                TriggerServerEvent('scheggia_telegrams:CheckAlerts', source)
                todo = false
            end
        end
	end
end)

RegisterNetEvent('scheggia_telegrams:check_return')
AddEventHandler('scheggia_telegrams:check_return', function()
	charLoaded = true
end)

local blips = {

	-- telegram blips (map)
	{ name = 'Ufficio postale', sprite = 1861010125, x= -178.90, y = 626.71, z = 114.09 }, -- valentine
	{ name = 'Ufficio postale', sprite = 1861010125, x= 2749.49, y = -1399.66, z = 46.21 }, -- sait denis
	{ name = 'Ufficio postale', sprite = 1861010125, x= 1225.57, y = -1293.87, z = 76.91 }, -- rhodes
    { name = 'Ufficio postale', sprite = 1861010125, x = -5533.28, y = -2956.28, z = -0.69 }, -- tumbleweed
    { name = 'Ufficio postale', sprite = 1861010125, x = -3733.96, y = -2597.92, z = -12.93 }, -- armadillo
    { name = 'Ufficio postale', sprite = 1861010125, x = -874.97, y = -1329.08, z = 43.96 }, -- blackwater
    { name = 'Ufficio postale', sprite = 1861010125, x = -1767.34, y = -381.43, z = 157.73 }, -- strawberry
    { name = 'Ufficio postale', sprite = 1861010125, x = 1522.05, y = 439.55, z = 90.68 }, -- emerald ranch
    { name = 'Ufficio postale', sprite = 1861010125, x = -1299.48, y = 402.01, z = 95.39 }, -- wallace
    { name = 'Ufficio postale', sprite = 1861010125, x = 2939.53, y = 1288.59, z = 44.65 }, -- annesbourg
    { name = 'Ufficio postale', sprite = 1861010125, x = -1094.38, y = -574.98, z = 82.41 },
    { name = 'Ufficio postale', sprite = 1861010125, x = -5230.15, y = -3468.2, z = -20.58 }, -- benedict point
    { name = 'Ufficio postale', sprite = 1861010125, x = -337.23, y = -360.46, z = 88.07 }, -- flatneck station
    
}


RegisterNetEvent("scheggia_telegrams:ReturnMessages")
AddEventHandler("scheggia_telegrams:ReturnMessages", function(data)
    index = 1
    telegrams = data

    if next(telegrams) == nil then
        SetNuiFocus(true, true)
        SendNUIMessage({ message = "<b>Nessun telegramma in arrivo.</b>" })
    else
        SetNuiFocus(true, true)
        SendNUIMessage({ sender = telegrams[index].sender, message = telegrams[index].message })
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)

        for key, value in pairs(blips) do
           if IsPlayerNearCoords(value.x, value.y, value.z) then
                if not menu then
                    DisplayHelpText("Premi [~e~SPAZIO~q~] per vedere i tuoi telegrammi")
                    if IsControlJustReleased(0, 0xD9D0E1C0) then
                        menu = true
                        TriggerServerEvent("scheggia_telegrams:GetMessages")
                    end
                end
            end
        end
    end
end)

function IsPlayerNearCoords(x, y, z)
    local playerx, playery, playerz = table.unpack(GetEntityCoords(PlayerPedId(), 0))
    local distance = GetDistanceBetweenCoords(playerx, playery, playerz, x, y, z, true)

    if distance < 1 then
        return true
    end
end

function DisplayHelpText(str)
    local str = CreateVarString(10, "LITERAL_STRING", str, Citizen.ResultAsLong())
   SetTextScale(0.7, 0.7)
   SetTextColor(math.floor(255), math.floor(255), math.floor(255), math.floor(255))
   SetTextCentre(true)
   SetTextDropshadow(1, 0, 0, 0, 255)
   Citizen.InvokeNative(0xADA9255D, 10);
   DisplayText(str, 0.50, 0.90)
end

function CloseTelegram()
    index = 1
    menu = false
    SetNuiFocus(false, false)
    SendNUIMessage({})
end

RegisterNUICallback('back', function()
    if index > 1 then
        index = index - 1
        SendNUIMessage({ sender = telegrams[index].sender, message = telegrams[index].message })
    end
end)

RegisterNUICallback('next', function()
    if index < #telegrams then
        index = index + 1
        SendNUIMessage({ sender = telegrams[index].sender, message = telegrams[index].message })
    end
end)

RegisterNUICallback('close', function()
    CloseTelegram()
end)

RegisterNUICallback('new', function()
    CloseTelegram()
    GetFirstname()
end)

RegisterNUICallback('delete', function()
    TriggerServerEvent("scheggia_telegrams:DeleteMessage", telegrams[index].id)
end)

function GetFirstname()
    AddTextEntry("FMMC_KEY_TIP8", "Nome del destinatario: ")
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 30)

    while (UpdateOnscreenKeyboard() == 0) do
        Wait(0);
    end

    while (UpdateOnscreenKeyboard() == 2) do
        Wait(0);
        break
    end

    while (UpdateOnscreenKeyboard() == 1) do
        Wait(0)
        if (GetOnscreenKeyboardResult()) then
            local firstname = GetOnscreenKeyboardResult()

            GetLastname(firstname)

            break
        end
    end
end

function GetLastname(firstname)
    AddTextEntry("FMMC_KEY_TIP8", "Cognome del destinatario: ")
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 30)

    while (UpdateOnscreenKeyboard() == 0) do
        Wait(0);
    end

    while (UpdateOnscreenKeyboard() == 2) do
        Wait(0);
        break
    end

    while (UpdateOnscreenKeyboard() == 1) do
        Wait(0)
        if (GetOnscreenKeyboardResult()) then
            local lastname = GetOnscreenKeyboardResult()

            GetMessage(firstname, lastname)

            break
        end
    end
end

function GetMessage(firstname, lastname)
    AddTextEntry("FMMC_KEY_TIP8", "Messaggio: ")
    DisplayOnscreenKeyboard(0, "FMMC_KEY_TIP8", "", "", "", "", "", 150)

    while (UpdateOnscreenKeyboard() == 0) do
        Wait(0);
    end

    while (UpdateOnscreenKeyboard() == 2) do
        Wait(0);
        break
    end

    while (UpdateOnscreenKeyboard() == 1) do
        Wait(0)
        if (GetOnscreenKeyboardResult()) then
            local message = GetOnscreenKeyboardResult()
            TriggerServerEvent("scheggia_telegrams:SendMessage", firstname, lastname, message, GetPlayerServerIds())
            break
        end
    end
end

function GetPlayerServerIds()
    local players = {}

    for i = 0, 31 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, GetPlayerServerId(i))
        end
    end

    return players
end

---blip---

Citizen.CreateThread(function()
	for _, info in pairs(blips) do
        local blip = N_0x554d9d53f696d002(1664425300, info.x, info.y, info.z)
        SetBlipSprite(blip, info.sprite, 1)
		SetBlipScale(blip, 0.2)
		Citizen.InvokeNative(0x9CB1A1623062F402, blip, info.name)
    end  
end)