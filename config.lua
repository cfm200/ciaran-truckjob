Config = {}

Config.Debug = true

Config.Notification = 'ox'
Config.Progress = 'ox'

Config.BossPed = {
  model = `s_m_m_trucker_01`,
  coords = vec4(-172.07, -2576.85, 6.0, 357.17)
}

Config.Trucks = {
  {minRep = 0, model = `hauler`},
  {minRep = 10, model = `phantom`},
}

Config.TruckSpawn = vector4(-153.27, -2540.08, 6.02, 140.0)


Config.Trailers = {
  {minRep = 0, model = `trailers4`},
  {minRep = 10, model = `tanker`},
}

Config.TrailerSpawn = vector4(-129.31, -2555.25, 6.01, 141.25)

AddEventHandler('onResourceStart', function()
  Wait(2000)
  if GetResourceState('ox_inventory') == 'started' then
    Config.Inventory = 'ox'
  elseif GetResourceState('qb-inventory') == 'started' then
    Config.Inventory = 'qb'
  end
end)