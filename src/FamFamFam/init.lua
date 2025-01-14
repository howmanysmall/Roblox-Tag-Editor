local FamFamFam = {}

-- Asset ID of the spritesheet
FamFamFam.Asset = "rbxassetid://1170440750"
-- The mapping from names to positions in the spritesheet
FamFamFam.Table = require(script.SpritesheetData)

-- Returns a new ImageLabel object representing the icon.
function FamFamFam.Create(name)
	assert(type(name) == "string", "expected string name, got " .. typeof(name))
	local data = assert(FamFamFam.Table[name], "no such icon named `" .. name .. "`")

	local img = Instance.new("ImageLabel")
	img.BackgroundTransparency = 1
	img.Size = UDim2.fromOffset(16, 16)
	img.Image = FamFamFam.Asset
	img.ImageRectOffset = Vector2.new(data[1], data[2])
	img.ImageRectSize = Vector2.new(16, 16)

	return img
end

-- Returns a table with the keys Image, ImageRectOffset, and
-- ImageRectSize which correspond to properties on ImageLabel.
function FamFamFam.Lookup(name)
	assert(type(name) == "string", "expected string name, got " .. typeof(name))
	local data = assert(FamFamFam.Table[name], "no such icon named `" .. name .. "`")

	return {
		Image = FamFamFam.Asset,
		ImageRectOffset = Vector2.new(data[1], data[2]),
		ImageRectSize = Vector2.new(16, 16),
	}
end

return FamFamFam
