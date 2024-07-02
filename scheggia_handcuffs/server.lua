local VorpCore = {}

TriggerEvent("getCore",function(core)
    VorpCore = core
end)
VorpInv = exports.vorp_inventory:vorp_inventoryApi()

RegisterNetEvent('scheggia_handcuffs:checkjob')
AddEventHandler('scheggia_handcuffs:checkjob', function()
    local _source = source
    local Character = VorpCore.getUser(_source).getUsedCharacter
    local job = Character.job
    if job == 'police' then
        TriggerClientEvent('scheggia_handcuffs:use', _source)
    end
end)

RegisterServerEvent('scheggia_handcuffs:cuffplayer')
AddEventHandler('scheggia_handcuffs:cuffplayer', function(target)
    local _source = source
    local HasHandcuffs = VorpInv.getItem(_source, 'handcuffs')
    if HasHandcuffs ~= nil then
        VorpInv.addItem(_source, "handcuffs_key", 1)
        VorpInv.subItem(_source, "handcuffs", 1)
        TriggerClientEvent('scheggia_handcuffs:cuff', target)
        TriggerClientEvent("vorp:TipRight", _source, "Giocatore ammanettato", 3000)
    else
        TriggerClientEvent("vorp:TipRight", _source, "Non hai delle manette!", 3000)
    end
end)

RegisterServerEvent('scheggia_handcuffs:uncuffplayer')
AddEventHandler('scheggia_handcuffs:uncuffplayer', function(target)
    local _source = source

    local HasHandcuffsKeys = VorpInv.getItem(_source, 'handcuffs_key')

    if HasHandcuffsKeys ~= nil then
        VorpInv.addItem(_source, "handcuffs", 1)
        VorpInv.subItem(_source, "handcuffs_key", 1)
        TriggerClientEvent('scheggia_handcuffs:uncuff', target)
        TriggerClientEvent("vorp:TipRight", _source, "Giocatore smanettato", 3000)
    else
        TriggerClientEvent("vorp:TipRight", _source, "Non hai le chiavi delle manette!", 3000)
    end
end)