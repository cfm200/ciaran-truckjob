local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()

local bossPed
local ped = PlayerPedId()
local clipboard
local currentTruck
local truckBlip = nil
isTruckJobActive = false

local function DisplayNotification(text, textype, length)
   QBCore.Functions.Notify(text, textype, length)
    if type(text) == "table" then
        local ttext = text.text or 'Placeholder'
        local caption = text.caption or 'Placeholder'
        local ttype = textype or 'primary'
        local length = length or 5000
        SendNUIMessage({
            type = ttype,
            length = length,
            text = ttext,
            caption = caption
        })
    else
        local ttype = textype or 'primary'
        local length = length or 5000
        SendNUIMessage({
            type = ttype,
            length = length,
            text = text
        })
    end
end

local function CreateTruckerJobBlip()
  local truckerBlip = AddBlipForCoord(Config.BossPed.coords.x, Config.BossPed.coords.y, Config.BossPed.coords.z)
  SetBlipSprite(truckerBlip, 477)
  SetBlipColour(truckerBlip, 7)
end

-- local function CreateVehicleBlip()
--     truckBlip = AddBlipForCoord(truckCoords)
--     SetBlipSprite(truckBlip, 513)
--     SetBlipDisplay(truckBlip, 4)
--     SetBlipScale(truckBlip, 0.6)
--     SetBlipAsShortRange(truckBlip, true)
--     SetBlipColour(truckBlip, 49)
-- end

local function SpawnBoss()
  RequestModel(Config.BossPed.model)
  while (not HasModelLoaded(Config.BossPed.model)) do
    Citizen.Wait(1000)
    RequestModel(Config.BossPed.model)
 end
  bossPed = CreatePed(1, Config.BossPed.model, Config.BossPed.coords.x, Config.BossPed.coords.y, Config.BossPed.coords.z - 1, Config.BossPed.coords.w, false, false)
  FreezeEntityPosition(bossPed, true)
  SetEntityInvincible(bossPed, true)
  SetBlockingOfNonTemporaryEvents(bossPed, true)
end

local function SpawnTruck(model)
  currentTruck = CreateVehicle(model, Config.TruckSpawn.x, Config.TruckSpawn.y, Config.TruckSpawn.z, Config.TruckSpawn.w, true, false)
  TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(currentTruck))
  truckBlip = AddBlipForCoord(currentTruck)
  SetBlipSprite(truckBlip, 513)
  SetBlipDisplay(truckBlip, 4)
  SetBlipScale(truckBlip, 0.6)
  SetBlipAsShortRange(truckBlip, true)
  SetBlipColour(truckBlip, 49)
end

local function StartTruckJobAnim()
  local animDict = 'missfam4'

  RequestAnimDict(animDict)
  while (not HasAnimDictLoaded(animDict)) do
    Citizen.Wait(1)
    RequestAnimDict(animDict)
  end

  local ped = PlayerPedId()
  local playerCoords = GetEntityCoords(ped)

  local clipboardProp = `p_amb_clipboard_01`
  while (not HasModelLoaded(clipboardProp)) do
     Citizen.Wait(1)
     RequestModel(clipboardProp)
  end
  clipboard = CreateObject(clipboardProp, playerCoords.x, playerCoords.y, playerCoords.z, false, false, false)

  TaskPlayAnim(ped, 'missfam4', 'base', 2.0, 2.0, 50000000, 51, 0, false, false, false)

  AttachEntityToEntity(clipboard, ped, GetPedBoneIndex(ped, 36029, 0.16, 0.08, 0.1, -130.0, -50.0, 0.0, true, true, false, true, 1, true))
end


Citizen.CreateThread(function ()
  SpawnBoss()
  CreateTruckerJobBlip()
  RegisterNetEvent('ciaran-truckjob:client:speakWithBoss', function()
    lib.showContext('trucker_menu')
  end)
end)

RegisterNetEvent('mo-truckjob:client:startTruckJobAnim', function()
  StartTruckJobAnim()

  if lib.progressBar({
    duration = 1000,
    label = 'Signing docs..',
    useWhileDead = false,
    canCancel = true,
    disable = {
        car = true,
        move = true,
    },
    anim = {},
    prop = {},
  })
  then
    DeleteEntity(clipboard)
    ClearPedTasks(ped)
  end
end)


lib.registerContext({
  id = 'trucker_menu',
  title = 'Trucker Job',
  options = {
    {
      title = 'Trucker Reputation',
      progress = PlayerData.metadata['rep']['trucker']
    },
    {
      title = 'Hauler Truck',
      description = 'The starter truck',
      icon = 'fa-solid fa-truck',
      onSelect = function()
        if isTruckJobActive then
          DisplayNotification('Truck job already active!', 'error', 2000)
          return
        end
        PlayerData.job.name = 'trucker'
        TriggerEvent('mo-truckjob:client:startTruckJobAnim')
        DisplayNotification('Truck job started', 'success', 2000)
        SpawnTruck(Config.Trucks[1].model)
        CreateVehicleBlip()
        isTruckJobActive = true
      end
    },
    {
      title = 'Phantom Truck',
      description = 'For heavier loads',
      icon = 'fa-solid fa-truck',
      onSelect = function()
        if isTruckJobActive then
          DisplayNotification('Truck job already active!', 'error', 2000)
          return
        end
        PlayerData.job.name = 'trucker'
        TriggerEvent('mo-truckjob:client:startTruckJobAnim')
        DisplayNotification('Truck job started', 'success', 2000)
        SpawnTruck(Config.Trucks[2].model)
        isTruckJobActive = true
      end
    },
    {
      title = 'Stop Job',
      description = 'Cancel the current job',
      icon = 'fa-solid fa-ban',
      onSelect = function()
        if isTruckJobActive then
          TriggerEvent('mo-truckjob:client:startTruckJobAnim')
          DeleteVehicle(currentTruck)
          DisplayNotification('You stopped the current job', 'success', 2000)
          isTruckJobActive = false
          return
        else
          DisplayNotification('No truck job active!', 'error', 2000)
        end
      end
    },
  }
})

AddEventHandler('onResourceStart', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then
    return
  end
  DeleteEntity(bossPed)
  DeleteEntity(clipboard)
end)

AddEventHandler('onResourceStop', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then
    return
  end
end)