local Roact = require(script.Parent.Parent.Parent.Vendor.Roact)
local Roact_createElement = Roact.createElement

local function BoxAdorn(props)
	local adornee = props.Adornee
	if adornee:IsA("Attachment") then
		return Roact_createElement("BoxHandleAdornment", {
			Adornee = adornee.Parent,
			CFrame = adornee.CFrame,
			Size = Vector3.new(1.2, 1.2, 1.2),
			Transparency = 0.3,
			Color3 = props.Color,
		})
	end

	return Roact_createElement("SelectionBox", {
		LineThickness = 0.03,
		SurfaceTransparency = 0.7,
		SurfaceColor3 = props.Color,
		Adornee = adornee,
		Color3 = props.Color,
	})
end

return BoxAdorn
