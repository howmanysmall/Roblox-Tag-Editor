local TextService = game:GetService("TextService")
local Roact = require(script.Parent.Parent.Vendor.Roact)
local Roact_createElement = Roact.createElement

local function TextLabel(props)
	local update

	if props.TextWrapped then
		function update(rbx)
			if not rbx then
				return
			end

			local textSize = TextService:GetTextSize(rbx.Text, rbx.TextSize, rbx.Font, Vector2.new(rbx.AbsoluteSize.X - 2, 100000))
			rbx.Size = UDim2.new(1, 0, 0, textSize.Y)
		end
	else
		function update(rbx)
			if not rbx then
				return
			end

			local textSize = TextService:GetTextSize(rbx.Text, rbx.TextSize, rbx.Font, Vector2.new(100000, 100000))
			rbx.Size = UDim2.new(props.Width or UDim.new(0, textSize.X), UDim.new(0, textSize.Y))
		end
	end

	local autoSize = not props.Size

	return Roact_createElement("TextLabel", {
		BackgroundTransparency = 1,
		LayoutOrder = props.LayoutOrder,
		Position = props.Position,
		Size = props.Size or props.TextWrapped and UDim2.fromScale(1, 0) or nil,

		Font = props.Font or Enum.Font.SourceSans,
		Text = props.Text or "<Text Not Set>",
		TextColor3 = props.TextColor3 or Color3.new(),
		TextSize = props.TextSize or 20,
		TextWrapped = props.TextWrapped,
		TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left,
		TextYAlignment = props.TextYAlignment,

		[Roact.Ref] = autoSize and update or nil,
		[Roact.Change.TextBounds] = autoSize and update or nil,
		[Roact.Change.AbsoluteSize] = autoSize and update or nil,
		[Roact.Change.Parent] = autoSize and update or nil,
	})
end

return TextLabel
