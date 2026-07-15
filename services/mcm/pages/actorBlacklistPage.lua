---@class actorBlacklistPage : mcmPage
local this = {}

---@public
---@param template mwseMCMTemplate
---@param services serviceCollection
function this.initialize(template, services)
    local translations = services.translations
    local keys = services.enums.translationKey

    template:createExclusionsPage({
        label = translations.get(keys.blacklistedActorsTitleLabel),
        description = translations.get(keys.blacklistedActorsDescription),
        leftListLabel = translations.get(keys.blacklistedActorsLeftLabel),
        rightListLabel = translations.get(keys.blacklistedActorsRightLabel),
        variable = mwse.mcm.createTableVariable {
            id = "blacklistedActors",
            table = services.settings,
        },
        filters = {
            {
                label = translations.get(keys.blacklistedActorsRightLabel),
                callback = function()
                    local actors = {}

                    for actor in tes3.iterateObjects({ tes3.objectType.npc, tes3.objectType.creature }) do
                        if not actor.isInstance then
                            table.insert(actors, actor.id:lower())
                        end
                    end

                    table.sort(actors)

                    return actors
                end
            },
        },
    })
end

return this
