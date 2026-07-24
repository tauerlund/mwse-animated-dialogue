---@class debugWindow : initializedService
local this = {}

---@private
---@type guiBuilder
this.guiBuilder = nil

---@private
---@type translations
this.translations = nil

---@private
---@type translationKey
this.translationKey = nil

---@private
---@type debugTab[]
this.tabs = nil

---@private
---@type tes3uiElement|nil
this.menu = nil

---@private
---@type tes3uiElement|nil
this.content = nil

---@private
---@type tes3uiElement[]
this.tabButtons = {}

---@private
---@type integer|nil
this.activeIndex = nil

---@private
---@type tes3reference|nil
this.actor = nil

---@public
---@param services serviceCollection
---@return boolean, string|nil
function this.initialize(services)
    this.guiBuilder = services.guiBuilder
    this.translations = services.translations
    this.translationKey = services.constants.translationKey

    this.tabs = {
        {
            title = this.translations.get(this.translationKey.debugTabAnimations),
            sections = {
                services.baseConfigurationSection,
                services.previewAnimationSection,
                services.triggerOverrideSection,
                services.propTransformSection,
            },
        },
        {
            title = this.translations.get(this.translationKey.debugTabCamera),
            sections = {
                services.cameraPresetSection,
            },
        },
        {
            title = this.translations.get(this.translationKey.debugTabLighting),
            sections = {
                services.fillLightSection,
            },
        },
    }

    return true, nil
end

---@class debugWindow.show.param
---@field public actor tes3reference

---@public
---@param params debugWindow.show.param
function this.show(params)
    if this.menu then
        return
    end

    this.actor = params.actor

    local guiBuilder = this.guiBuilder
    local viewportWidth, viewportHeight = tes3ui.getViewportSize()

    local menu = guiBuilder.createMenu({
            id = "AnimatedDialogue:DebugWindow",
            dragFrame = true,
            fixedFrame = false,
            modal = false,
        })
        :withText(this.translations.get(this.translationKey.debugWindowTitle))
        :withFlowDirection(tes3.flowDirection.topToBottom)
        :withSize({ width = 480, height = math.floor(viewportHeight * 0.75) })
        :withMinSize({ width = 320, height = 260 })
        :withPosition({ x = -viewportWidth / 2 + 24, y = viewportHeight / 2 - 24 })
        :build()

    this.buildTabBar(menu)

    local scrollPane = guiBuilder.createVerticalScrollPane({ parent = menu })
        :withProportional({ width = 1.0, height = 1.0 })
        :build()

    this.content = guiBuilder.createBlock({ parent = scrollPane:getContentElement() })
        :withFlowDirection(tes3.flowDirection.topToBottom)
        :withAutoSize()
        :withProportional({ width = 1.0 })
        :withPadding({ all = 8 })
        :build()

    menu:loadMenuPosition()

    this.menu = menu
    this.selectTab(1)
end

---@private
---@param menu tes3uiElement
function this.buildTabBar(menu)
    this.tabButtons = {}

    if #this.tabs < 2 then
        return
    end

    local guiBuilder = this.guiBuilder

    local tabBar = guiBuilder.createBlock({ parent = menu })
        :withFlowDirection(tes3.flowDirection.leftToRight)
        :withAutoSize()
        :withBorder({ bottom = 8 })
        :build()

    for i, tab in ipairs(this.tabs) do
        local button = guiBuilder.createTextSelect({ parent = tabBar })
            :withText(tab.title)
            :withBorder({ right = 12 })
            :withWidgetColors({
                idle = tes3ui.getPalette(tes3.palette.normalColor),
                over = tes3ui.getPalette(tes3.palette.normalOverColor),
                pressed = tes3ui.getPalette(tes3.palette.normalPressedColor),
            })
            :build()

        button:registerBefore(tes3.uiEvent.mouseClick, function()
            this.selectTab(i)
        end)

        table.insert(this.tabButtons, button)
    end
end

---@public
function this.hide()
    if not this.menu then
        return
    end

    if this.activeIndex then
        this.destroyTab(this.tabs[this.activeIndex])
    end

    this.menu:destroy()
    this.menu = nil
    this.content = nil
    this.tabButtons = {}
    this.activeIndex = nil
    this.actor = nil
end

---@private
---@param index integer
function this.selectTab(index)
    if this.activeIndex == index then
        return
    end

    if this.activeIndex then
        this.destroyTab(this.tabs[this.activeIndex])
    end

    this.activeIndex = index
    this.content:destroyChildren()
    this.refreshTabButtons()
    this.buildTab(this.tabs[index])

    this.menu:updateLayout()
end

---@private
---@param tab debugTab
function this.buildTab(tab)
    for _, section in ipairs(tab.sections) do
        section.build({
            parent = this.createSectionBlock(),
            actor = this.actor,
        })
    end
end

---@private
---@param tab debugTab
function this.destroyTab(tab)
    for _, section in ipairs(tab.sections) do
        section.destroy()
    end
end

---@private
---@return tes3uiElement
function this.createSectionBlock()
    return this.guiBuilder.createBlock({ parent = this.content })
        :withFlowDirection(tes3.flowDirection.topToBottom)
        :withAutoSize()
        :withProportional({ width = 1.0 })
        :build()
end

---@private
function this.refreshTabButtons()
    for i, button in ipairs(this.tabButtons) do
        if i == this.activeIndex then
            button.widget.idle = tes3ui.getPalette(tes3.palette.headerColor)
        else
            button.widget.idle = tes3ui.getPalette(tes3.palette.normalColor)
        end
    end
end

return this
