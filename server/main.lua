RegisterNetEvent('Karamel-Garage:SaveCar', function()
    local source = source

    local veh = GetVehiclePedIsIn(GetPlayerPed(source), false)
    if veh == 0 then
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'Du er ikke i et køretøj!', style = { ['background-color'] = '#FF0000', ['color'] = '#000000' } })
    else    
        local model = GetEntityModel(veh)
        local plate = GetVehicleNumberPlateText(veh)

        local steam = false
        for k,v in pairs(GetPlayerIdentifiers(source)) do
            if string.sub(v, 1, string.len("steam:")) == "steam:" then
                steam = v
            end
        end

        local data = MySQL.query.await('SELECT * FROM garage WHERE steam = ? AND model = ?', {steam, model})

        if #data == 0 then
            MySQL.query.await('INSERT INTO garage (steam, model, plate) VALUES (?, ?, ?)', {steam, model, plate})
            TriggerClientEvent('Karamel-Garage:RemoveCar', source)
            TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = 'Du har indsat en ny bil', style = { ['background-color'] = '#00FF00', ['color'] = '#000000' } })
        else
            TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'Du har allerede denne bil i din garage', style = { ['background-color'] = '#FF0000', ['color'] = '#000000' } })
        end
    end
end)

RegisterNetEvent('Karamel-Garage:Prepare', function()
    local source = source

    local steam = false
    for k,v in pairs(GetPlayerIdentifiers(source)) do
        if string.sub(v, 1, string.len("steam:")) == "steam:" then
            steam = v
        end
    end

    local data = MySQL.Sync.fetchAll('SELECT * FROM garage WHERE steam = ?', {steam})

    local options = {}
    for i,v in pairs(data) do
        table.insert(options, {
            label = ''..v.plate,
            value = ''..v.model
        })
    end
    TriggerClientEvent('Karamel-Garage:CarMenu', source, options)
end)

RegisterNetEvent('Karamel-Garage:TakeoutVehicle', function(license, model)
    local source = source

    print(license, model)

    local steam = false
    for k,v in pairs(GetPlayerIdentifiers(source)) do
        if string.sub(v, 1, string.len("steam:")) == "steam:" then
            steam = v
        end
    end

    local data = MySQL.Sync.fetchAll('SELECT * FROM garage WHERE steam = ? AND plate = ?', {steam, license})
    if #data == 0 then
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'Kan ikke finde denne bil!', style = { ['background-color'] = '#FF0000', ['color'] = '#000000' } })
    else
        TriggerClientEvent('Karamel-Garage:SpawnCar', source, tonumber(model), license)

        MySQL.query.await('DELETE FROM garage WHERE steam = ? AND plate = ?', {steam, license})
        TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = 'Du har taget din bil ud!', style = { ['background-color'] = '#00FF00', ['color'] = '#000000' } })
    end
end)