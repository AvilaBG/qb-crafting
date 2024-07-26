local QBCore = exports['qb-core']:GetCoreObject()
Target = {}
Target.New = function(self, netid, model, icon, label, item, recipe, skill)
    print(netid, model, icon, label, item, recipe, skill)
    self.netid = netid
    self.model = model
    self.icon = icon
    self.label = label
    self.item = item
    self.recipe = recipe
    self.skill = skill
    self.distance = Config.Settings.TargetDistance
    return self
end

Target.Entity = function(self)
    exports['qb-target']:AddTargetEntity(self.netid, {
        options = {
                {
                    num = 1,
                    icon = self.icon,
                    label = self.label,
                    action = function(entity)
                        -- if entity == NetToEnt(self.netid) then TODO just need to build a check in here, just use Entity
                            Menu:New(self.recipe, self.item, self.skill):OpenMenu()
                        -- end
                    end,
                },
                {
                    num = 2,
                    icon = 'fa-solid fa-trash',
                    label = string.format(Lang:t('pickupworkBench')),
                    action = function(entity)
                        QBCore.Functions.PlayAnim("pickup_object", "pickup_low", false, 2.0)
                        TriggerServerEvent('qb-crafting:server:pickup_bench', NetworkGetNetworkIdFromEntity(entity))
                        self:Delete()
                    end,
            }
            },
            distance = Config.Settings.TargetDistance,
        })
end

Target.Model = function(self)
    exports['qb-target']:AddTargetModel(joaat(self.model), {
        options = {
                {
                    num = 1,
                    icon = self.icon,
                    label = self.label,
                    action = function(entity)
                        if GetEntityModel(entity) == joaat(self.model) then --TODO do we really care about checking it?
                            Menu:New(self.recipe, self.item, self.skill):OpenMenu()
                        end
                    end,
                },
            },
            distance = Config.Settings.TargetDistance,
        })
end

Target.Delete = function(self)
    exports['qb-target']:RemoveTargetEntity(self.netid)
end