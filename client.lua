local QBCore = exports['qb-core']:GetCoreObject()

local function setupTarget(option, targetType)
    local addFunction = targetType == 'entity' and exports['qb-target'].AddTargetEntity or exports['qb-target'].AddTargetModel
    addFunction(targetType, option.netid, {
        options = {
                {
                    num = 1,
                    icon = option.useitem.icon,
                    label = option.useitem.label,
                    action = function(entity)
                        if entity == NetToEnt(option.netid) then
                            Menu:Open(option)
                        end
                    end,
                },
                {
                    num = 2,
                    icon = 'fa-solid fa-trash',
                    label = 'Pickup',
                    action = function(entity)
                        if entity == option.netid then
                            local animDict = "pickup_object"
                            RequestAnimDict(animDict)
                            while not HasAnimDictLoaded(animDict) do
                                Wait(0)
                            end
                            TaskPlayAnim(PlayerPedId(), animDict, "pickup_low", 8.0, -8.0, -1, 0, 0, false, false, false)
                            TriggerServerEvent('qb-crafting:server:pickup_bench', NetworkGetNetworkIdFromEntity(entity))
                        end
                    end,
            }
            },
            distance = Config.Settings.TargetDistance,
        })
end

local isCraftingActive = false
function PressButtonToOpenCrafting(isActive, option)
    isCraftingActive = isActive
    CreateThread(function()
        exports['qb-core']:DrawText('Press E to use Crafting', 'left')
        while isCraftingActive do
            if IsControlJustPressed(0, 38) then
                exports['qb-core']:HideText()
                Menu:Open(option)
                Menu:IsOpen(true)
                break
            end
            Wait(1)
        end
    end)
end

RegisterNetEvent('qb-crafting:client:use_create_item',function(option)
    local time = GetGameTimer()
    while not NetworkDoesEntityExistWithNetworkId(option.netid) do
        if GetGameTimer() - time > 1000 then
            return print('Error handler - NetiD: ',option.netid)
        end
        Wait(1)
    end
    if option.useitem.target then
        return setupTarget(option, 'entity')
    end
    local entity = NetToEnt(option.netid)
    local coords = GetEntityCoords(entity)
    local heading = GetEntityHeading(entity)
    Zone:New(vector4(coords.x, coords.y, coords.z, heading), option):UseableItem()
    -- setupTarget(option, 'entity')
end)

-- AddEventHandler('qb-menu:client:menuClosed', function()
--     if Menu:IsOpen() then
--         PressButtonToOpenCrafting(true, Zone:Get())
--     end
-- end)

-- local function setupUsingCraftingTable(option)
--     if not Config.Settings.target then
--         return Zone:Create(option)
--     end
--     setupTarget(option.model, 'model')
-- end

-- if not Config.Settings.UseItem then
--     for key, option in ipairs(Config.Benches) do
--         setupUsingCraftingTable(option)
--     end
-- end

-- for _, crafting in pairs(Config.Benches) do
--     if crafting.useitem then
--         print('useitem')
--         -- createUseableTables(option)
--     end
-- end




local function PickupBench(benchType)
    local playerPed = PlayerPedId()
    local propHash = Config[benchType].object
    local entity = GetClosestObjectOfType(GetEntityCoords(playerPed), 3.0, propHash, false, false, false)
    if DoesEntityExist(entity) then
        DeleteEntity(entity)
        TriggerServerEvent('qb-crafting:server:addCraftingTable', benchType)
        QBCore.Functions.Notify(string.format(Lang:t('notifications.pickupBench')), 'success')
    end
end