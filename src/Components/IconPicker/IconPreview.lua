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
		AnchorPoint = Vector2.new(),
		BackgroundTransparency = 1,
		Position = props.Position,
		Size = UDim2.new(1, 0, 0, 56),
	}, {
		IconName = Roact_createElement(ThemedTextLabel, {
			Position = UDim2.fromOffset(56, 32),
			Size = UDim2.new(1, -56, 0, 20 * 3),
			Text = props.icon or "",
			TextSize = 14,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
		}),

		IconMagnify = Roact_createElement("Frame", {
			BackgroundColor3 = Constants.White,
			BackgroundTransparency = 1,
			BorderColor3 = Constants.DarkGrey,
			Size = UDim2.fromOffset(48, 48),

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
							local imageLabel = Instance.new("ImageLabel")
							imageLabel.Name = string.format("Pixel [%d, %d]", x, y)
							imageLabel.Image = Icons.Asset
							imageLabel.ImageRectSize = Vector2.new()
							imageLabel.Size = UDim2.fromOffset(scaleFactor, scaleFactor)
							imageLabel.Position = UDim2.fromOffset(x * scaleFactor, y * scaleFactor)
							imageLabel.BackgroundTransparency = 1
							imageLabel.Parent = rbx
							self.pixels[x * 16 + y] = imageLabel
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

		for _, tag in ipairs(state.TagData) do
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
