local Roact = require(script.Parent.Parent.Parent.Vendor.Roact)
local Roact_createElement = Roact.createElement

local function BoxAdorn(props)
	local adornee = props.Adornee
	if adornee:IsA("Attachment") then
		return Roact_createElement("BoxHandleAdornment", {
			Adornee = adornee.Parent,
			CFrame = adornee.CFrame,
			Color3 = props.Color,
			Size = Vector3.new(1.2, 1.2, 1.2),
			Transparency = 0.3,
		})
	end

	return Roact_createElement("SelectionBox", {
		Adornee = adornee,
		Color3 = props.Color,
		LineThickness = 0.03,
		SurfaceColor3 = props.Color,
		SurfaceTransparency = 0.7,
	})
end

return BoxAdorn
