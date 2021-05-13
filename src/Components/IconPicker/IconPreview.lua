local Constants = require(script.Parent.Parent.Parent.Constants)
local Icons = require(script.Parent.Parent.Parent.FamFamFam)
local Roact = require(script.Parent.Parent.Parent.Vendor.Roact)
local RoactRodux = require(script.Parent.Parent.Parent.Vendor.RoactRodux)
local ThemedTextLabel = require(script.Parent.Parent.ThemedTextLabel)

local IconPreview = Roact.PureComponent:extend("IconPreview")

local Roact_createElement = Roact.createElement

function IconPreview:render()
	local props = self.props
	local scaleFactor = 3

	local function update()
		local image = props.icon and Icons.Lookup(props.icon)
		local rect = image and image.ImageRectOffset or Vector2.new(10000, 10000)
		for y = 0, 15 do
			for x = 0, 15 do
				local pixel = self.pixels[x * 16 + y]
				pixel.ImageRectOffset = rect + Vector2.new(x + 0.5, y + 0.5)
			end
		end
	end

	if self.pixels then
		update()
	end

	return Roact_createElement("Frame", {
		Size = UDim2.new(1, 0, 0, 56),
		Position = props.Position,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(),
	}, {
		IconName = Roact_createElement(ThemedTextLabel, {
			TextSize = 14,
			Size = UDim2.new(1, -56, 0, 20 * 3),
			Position = UDim2.fromOffset(56, 32),
			TextWrapped = true,
			Text = props.icon or "",
			TextYAlignment = Enum.TextYAlignment.Top,
		}),

		IconMagnify = Roact_createElement("Frame", {
			Size = UDim2.fromOffset(48, 48),
			BorderColor3 = Constants.DarkGrey,
			BackgroundColor3 = Constants.White,
			BackgroundTransparency = 1,

			[Roact.Ref] = function(rbx)
				if rbx == self.oldRbx then
					return
				end

				if self.pixels then
					for _, pixel in pairs(self.pixels) do
						pixel:Destroy()
					end
				end

				self.oldRbx = rbx
				self.pixels = {}

				if rbx then
					for x = 0, 15 do
						for y = 0, 15 do
							local image = Instance.new("ImageLabel")
							image.Name = string.format("Pixel [%d, %d]", x, y)
							image.Image = Icons.Asset
							image.ImageRectSize = Vector2.new()
							image.Size = UDim2.fromOffset(scaleFactor, scaleFactor)
							image.Position = UDim2.fromOffset(x * scaleFactor, y * scaleFactor)
							image.BackgroundTransparency = 1
							image.Parent = rbx
							self.pixels[x * 16 + y] = image
						end
					end

					update()
				end
			end,
		}),
	})
end

local function mapStateToProps(state)
	local icon = state.HoveredIcon

	if icon == nil then
		local tagName = state.IconPicker

		for _, tag in pairs(state.TagData) do
			if tag.Name == tagName then
				icon = tag.Icon
				break
			end
		end
	end

	return {
		icon = icon,
	}
end

IconPreview = RoactRodux.connect(mapStateToProps)(IconPreview)

return IconPreview
