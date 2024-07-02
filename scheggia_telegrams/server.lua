local VorpCore = {}

TriggerEvent("getCore",function(core)
    VorpCore = core
end)

RegisterServerEvent("scheggia_telegrams:GetMessages")
AddEventHandler("scheggia_telegrams:GetMessages", function(src)
	local _source
	
	if not src then 
		_source = source
	else 
		_source = src
	end

	TriggerEvent("vorp:getCharacter", _source, function(user)
		local recipient = user.identifier
		
		exports.ghmattimysql:execute("SELECT * FROM telegrams WHERE recipient=@recipient ORDER BY id DESC", { ['@recipient'] = recipient }, function(result)
			TriggerClientEvent("scheggia_telegrams:ReturnMessages", _source, result)
		end)
	end)
end)

RegisterServerEvent("scheggia_telegrams:SendMessage")
AddEventHandler("scheggia_telegrams:SendMessage", function(firstname, lastname, message)
	local _source = source

	TriggerEvent("vorp:getCharacter", _source, function(user)
		local sender = user.firstname .. " " .. user.lastname

		exports.ghmattimysql:execute("SELECT identifier FROM characters WHERE LOWER(firstname)=LOWER(@firstname) AND LOWER(lastname)=LOWER(@lastname)", { ['@firstname'] = firstname, ['@lastname'] = lastname}, function(result)
			if result[1] then 
				local recipient = result[1].identifier 

				local currentMoney = user.money
				if currentMoney >= 1.5 then
					TriggerEvent("vorp:removeMoney", _source, 0, 1.5)
					
					local paramaters = { ['@sender'] = sender, ['@recipient'] = recipient, ['@recipientid'] = 1, ['@message'] = message }
					exports.ghmattimysql:execute("INSERT INTO telegrams (sender, recipient, recipientid, message) VALUES (@sender, @recipient, @recipientid, @message)",  paramaters, function()
						local finded = false
						local players = GetPlayers()
						for k, pid in pairs(players) do
							local v = tonumber(pid)
							TriggerEvent("vorp:getCharacter", v, function(user)
								local receiver = user.firstname .. " " ..user.lastname
								if receiver:lower() == firstname:lower() .. " " .. lastname:lower() then
									VorpCore.NotifyLeft(v, "Nuovo Telegramma", "Hai ricevuto un telegramma, recati ad un ufficio postale", "generic_textures", "selection_arrow_right", 10000, "COLOR_PURE_WHITE")
									finded = true
								end
							end)
						end
						if finded == false then
							exports.ghmattimysql:execute("UPDATE characters SET tgalert=@tgalert WHERE identifier=@utente", {["@tgalert"] = 1, ["@utente"] = recipient})
						end
					end)
					TriggerClientEvent("vorp:TipRight", _source, "Telegramma inviato", 5000)
				else
					TriggerClientEvent("vorp:TipRight", _source, "Non hai abbastanza soldi! Richiesti: $1.5", 5000)
				end
			else 
				TriggerClientEvent("vorp:TipRight", _source, "Destinatario non trovato!", 5000)
			end
		end)
	end)
end)

RegisterNetEvent('scheggia_telegrams:CheckAlerts')
AddEventHandler('scheggia_telegrams:CheckAlerts', function()
    local source = source
    exports.ghmattimysql:execute("SELECT tgalert FROM characters WHERE identifier = @identifier AND charidentifier = @charidentifier",{["@identifier"] = VorpCore.getUser(source).getUsedCharacter.identifier, ['@charidentifier'] = VorpCore.getUser(source).getUsedCharacter.charIdentifier}, function(result)
	    if result[1] ~= nil and result[1].tgalert ~= nil and result[1].tgalert == 1 then
			exports.ghmattimysql:execute("UPDATE characters SET tgalert=@tgalert WHERE identifier = @identifier AND charidentifier = @charidentifier", {["@tgalert"] = 0, ["@identifier"] = VorpCore.getUser(source).getUsedCharacter.identifier, ['@charidentifier'] = VorpCore.getUser(source).getUsedCharacter.charIdentifier})
			VorpCore.NotifyLeft(source, "Telegramma Recapitato", "Hai ricevuto un telegramma mentre eri offline, recati ad un ufficio postale", "generic_textures", "selection_arrow_right", 30000, "COLOR_PURE_WHITE")
        end
    end)
end)

RegisterNetEvent('scheggia_telegrams:check')
AddEventHandler('scheggia_telegrams:check', function()
    local source = source
    if VorpCore.getUser(source).getUsedCharacter.charIdentifier then
        TriggerClientEvent('scheggia_telegrams:check_return', source)
    end
end)

RegisterServerEvent("scheggia_telegrams:DeleteMessage")
AddEventHandler("scheggia_telegrams:DeleteMessage", function(id)
	local _source = source

	exports.ghmattimysql:execute("DELETE FROM telegrams WHERE id=@id",  { ['@id'] = id }, function()
		TriggerEvent("scheggia_telegrams:GetMessages", _source)
		TriggerClientEvent("vorp:TipRight", _source, 'Telegramma eliminato', 5000)
	end)
end)
