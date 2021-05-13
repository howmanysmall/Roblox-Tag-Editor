local Button = require(script.Parent.Parent.Parent.Button)
local Roact = require(script.Parent.Parent.Parent.Parent.Vendor.Roact)

local DeleteButton = Roact.PureComponent:extend("DeleteButton")

local Roact_createElement = Roact.createElement

function DeleteButton:init()
	self:setState({
		confirming = false,
	})
end

function DeleteButton:render()
	local props = self.props
	local state = self.state

	return Roact_createElement(Button, {
		BorderColor3 = Color3.fromRGB(255, 0, 0),
		LayoutOrder = props.LayoutOrder,
		Position = props.Position,
		Size = props.Size,
		Text = state.confirming and "Confirm?" or "Delete",

		leftClick = function()
			if state.confirming then
				props.leftClick()
			else
				self:setState({
					confirming = true,
				})
			end
		end,
	})
end

return DeleteButton
