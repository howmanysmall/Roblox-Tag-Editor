local Button = require(script.Parent.Parent.Parent.Button)
local Roact = require(script.Parent.Parent.Parent.Parent.Vendor.Roact)

local DeleteButton = Roact.PureComponent:extend("DeleteButton")

function DeleteButton:init()
	self:setState({
		confirming = false,
	})
end

function DeleteButton:render()
	return Roact.createElement(Button, {
		Text = self.state.confirming and "Confirm?" or "Delete",
		Size = self.props.Size,
		Position = self.props.Position,
		LayoutOrder = self.props.LayoutOrder,
		BorderColor3 = Color3.fromRGB(255, 0, 0),

		leftClick = function()
			if self.state.confirming then
				self.props.leftClick()
			else
				self:setState({
					confirming = true,
				})
			end
		end,
	})
end

return DeleteButton
