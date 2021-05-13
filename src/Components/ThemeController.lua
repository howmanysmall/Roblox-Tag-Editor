local Roact = require(script.Parent.Parent.Vendor.Roact)
local ThemeContext = require(script.Parent.ThemeContext)
local getTheme = require(script.Parent.Parent.Utility.getTheme)
local Roact_createElement = Roact.createElement

local ThemeController = Roact.PureComponent:extend("ThemeController")

function ThemeController:init()
	self:setState({
		theme = getTheme(),
	})

	self.connection = nil
end

function ThemeController:didMount()
	self.connection = settings().Studio.ThemeChanged:Connect(function()
		self:setState({
			theme = getTheme(),
		})
	end)
end

function ThemeController:willUnmount()
	self.connection:Disconnect()
end

function ThemeController:render()
	return Roact_createElement(ThemeContext.Provider, {
		value = self.state.theme,
	}, self.props[Roact.Children])
end

return ThemeController
