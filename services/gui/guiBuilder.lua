---@class guiBuilder
---@field private element tes3uiElement
local this = {}
this.__index = this

---@public
---@param parameters createMenuParameters
---@return guiBuilder
function this.createMenu(parameters)
	local element = tes3ui.createMenu({
		id = parameters.id,
		dragFrame = parameters.dragFrame,
		fixedFrame = parameters.fixedFrame,
		modal = parameters.modal,
	})
	return this.create(element)
end

---@public
---@param parameters createParameters
---@return guiBuilder
function this.createLabel(parameters)
	local element = parameters.parent:createLabel({
		id = parameters.id,
	})
	return this.create(element)
end

---@public
---@param parameters createParameters
---@return guiBuilder
function this.createThinBorder(parameters)
	local element = parameters.parent:createThinBorder({
		id = parameters.id,
	})
	return this.create(element)
end

---@public
---@param parameters createParameters
---@return guiBuilder
function this.createBlock(parameters)
	local element = parameters.parent:createBlock({
		id = parameters.id,
	})
	return this.create(element)
end

---@public
---@param parameters createParameters
---@return guiBuilder
function this.createDivider(parameters)
	local element = parameters.parent:createDivider({
		id = parameters.id,
	})
	return this.create(element)
end

---@class createSliderParameters : createParameters
---@field current number
---@field max number
---@field step number
---@field jump number

---@public
---@param parameters createSliderParameters
---@return guiBuilder
function this.createSlider(parameters)
	local element = parameters.parent:createSlider({
		id = parameters.id,
		current = parameters.current,
		max = parameters.max,
		step = parameters.step,
		jump = parameters.jump,
	})
	return this.create(element)
end

---@class createColorPickerParameters : createParameters
---@field initialColor mwseColorTable
---@field height number
---@field mainWidth number
---@field hueWidth number
---@field previewWidth number
---@field previewHeight number

---@public
---@param parameters createColorPickerParameters
---@return guiBuilder
function this.createColorPicker(parameters)
	local element = parameters.parent:createColorPicker({
		id = parameters.id,
		initialColor = parameters.initialColor,
		height = parameters.height,
		mainWidth = parameters.mainWidth,
		hueWidth = parameters.hueWidth,
		previewWidth = parameters.previewWidth,
		previewHeight = parameters.previewHeight,
		showDataRow = true,
		showOriginal = true,
	})
	return this.create(element)
end

---@public
---@param parameters createParameters
---@return guiBuilder
function this.createButton(parameters)
	local element = parameters.parent:createButton({
		id = parameters.id,
	})
	return this.create(element)
end

---@public
---@param parameters createParameters
---@return guiBuilder
function this.createVerticalScrollPane(parameters)
	local element = parameters.parent:createVerticalScrollPane({
		id = parameters.id,
	})
	return this.create(element)
end

---@public
---@param parameters createParameters
---@return guiBuilder
function this.createTextSelect(parameters)
	local element = parameters.parent:createTextSelect({
		id = parameters.id,
	})
	return this.create(element)
end

---@public
---@param element tes3uiElement
function this.refreshLayout(element)
	local menu = element:getTopLevelMenu()

	if menu then
		menu:updateLayout()
	end
end

---@public
---@param text string
---@return guiBuilder
function this:withText(text)
	self.element.text = text
	return self
end

---@public
---@param color number[]
---@return guiBuilder
function this:withColor(color)
	self.element.color = color
	return self
end

---@public
---@param params widgetColorParams
---@return guiBuilder
function this:withWidgetColors(params)
	local widget = self.element.widget
	if not widget then
		return self
	end

	if params.idle then
		widget.idle = params.idle
	end

	if params.over then
		widget.over = params.over
	end

	if params.pressed then
		widget.pressed = params.pressed
	end

	return self
end

---@public
---@return guiBuilder
function this:withWrapText()
	self.element.wrapText = true
	self.element.widthProportional = 1.0
	return self
end

---@public
---@return guiBuilder
function this:withAutoSize()
	self.element.autoHeight = true
	self.element.autoWidth = true
	return self
end

---@public
---@param parameters sizeParameters
---@return guiBuilder
function this:withMinSize(parameters)
	if parameters.width then
		self.element.minWidth = parameters.width
	end
	if parameters.height then
		self.element.minHeight = parameters.height
	end
	return self
end

---@public
---@param parameters sizeParameters
---@return guiBuilder
function this:withMaxSize(parameters)
	if parameters.width then
		self.element.maxWidth = parameters.width
	end
	if parameters.height then
		self.element.maxHeight = parameters.height
	end
	return self
end

---@public
---@param parameters vector2Parameters
---@return guiBuilder
function this:withPosition(parameters)
	if parameters.x then
		self.element.positionX = parameters.x
	end
	if parameters.y then
		self.element.positionY = parameters.y
	end
	return self
end

---@public
---@param parameters vector2Parameters
---@return guiBuilder
function this:withPositionAlign(parameters)
	if parameters.x then
		self.element.absolutePosAlignX = parameters.x
	end
	if parameters.y then
		self.element.absolutePosAlignY = parameters.y
	end
	return self
end

---@public
---@param flowDirection string
---@return guiBuilder
function this:withFlowDirection(flowDirection)
	self.element.flowDirection = flowDirection
	return self
end

---@public
---@param parameters borderPaddingParameters
---@return guiBuilder
function this:withBorder(parameters)
	if parameters.all then
		self.element.borderAllSides = parameters.all
	end
	if parameters.left then
		self.element.borderLeft = parameters.left
	end
	if parameters.right then
		self.element.borderRight = parameters.right
	end
	if parameters.top then
		self.element.borderTop = parameters.top
	end
	if parameters.bottom then
		self.element.borderBottom = parameters.bottom
	end
	return self
end

---@public
---@param parameters borderPaddingParameters
---@return guiBuilder
function this:withPadding(parameters)
	if parameters.all then
		self.element.paddingAllSides = parameters.all
	end
	if parameters.left then
		self.element.paddingLeft = parameters.left
	end
	if parameters.right then
		self.element.paddingRight = parameters.right
	end
	if parameters.top then
		self.element.paddingTop = parameters.top
	end
	if parameters.bottom then
		self.element.paddingBottom = parameters.bottom
	end
	return self
end

---@public
---@param parameters vector2Parameters
---@return guiBuilder
function this:withChildAlignment(parameters)
	if parameters.x then
		self.element.childAlignX = parameters.x
	end
	if parameters.y then
		self.element.childAlignY = parameters.y
	end
	return self
end

---@public
---@param parameters sizeParameters
---@return guiBuilder
function this:withProportional(parameters)
	if parameters.width then
		self.element.widthProportional = parameters.width
	end
	if parameters.height then
		self.element.heightProportional = parameters.height
	end
	return self
end

---@public
---@param parameters sizeParameters
---@return guiBuilder
function this:withSize(parameters)
	if parameters.width then
		self.element.width = parameters.width
	end
	if parameters.height then
		self.element.height = parameters.height
	end
	return self
end

---@public
---@return tes3uiElement
function this:build()
	self.element:updateLayout()
	return self.element
end

---@private
---@param element tes3uiElement
---@return guiBuilder
function this.create(element)
	local instance = setmetatable({ element = element }, this)
	return instance
end

return this
