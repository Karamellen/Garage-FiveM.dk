local ped = PlayerPedId()
local IsMenuOpen = false

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

CreateThread(function()
    while true do 
        Wait(1)
        if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), Config.GarageCoords.x, Config.GarageCoords.y, Config.GarageCoords.z) < Config.TextDistance then
        local inVeh = IsPedInAnyVehicle(ped, true)
            if inVeh then
                DrawText3Ds(Config.GarageCoords.x, Config.GarageCoords.y, Config.GarageCoords.z+0.30, '~b~E~w~ - Parkér Køretøj')
            else
                DrawText3Ds(Config.GarageCoords.x, Config.GarageCoords.y, Config.GarageCoords.z+0.30, '~b~E~w~ - Åben Garage')
            end
                if IsControlJustPressed(1, 38) then
                    if inVeh then
                        TriggerServerEvent('Karamel-Garage:SaveCar')
                    else
                        if IsMenuOpen == false then
                        TriggerServerEvent('Karamel-Garage:Prepare')
                    end
                end
            end
        end
    end
end)

RegisterNetEvent("Karamel-Garage:RemoveCar", function()
    local car = GetVehiclePedIsIn(ped, false)
    SetEntityAsMissionEntity(car, true, true)
    DeleteVehicle(car)
end)

RegisterNetEvent("Karamel-Garage:SpawnCar", function(model, plate)
    local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(ped, 0.0, 8.0, 0.5))
    RequestModel(model)
    
    while not HasModelLoaded(model) do
        RequestModel(model)
        Wait(0)
    end

    local veh = CreateVehicle(model, Config.SpawnVehicleCoords.x, Config.SpawnVehicleCoords.y, Config.SpawnVehicleCoords.z, 1, 0.0, true, false) -- x, y, z, GetEntityHeading(ped)+90
    SetVehicleNumberPlateText(veh, plate)
    
    TaskWarpPedIntoVehicle(ped, veh, -1)
end)


RegisterNetEvent('Karamel-Garage:CarMenu', function(options)
    IsMenuOpen = true
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'general_menu', {
        title = 'Garage',
        align = 'left',
        elements = options
    }, function(data, menu)
        TriggerServerEvent('Karamel-Garage:TakeoutVehicle', data.current.label, data.current.value)
        menu.close()
    end, 
    function(data, menu)
        menu.close()
        IsMenuOpen = false
    end)
end)

function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.33, 0.33)
    SetTextFont(6)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextOutline() 
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
end