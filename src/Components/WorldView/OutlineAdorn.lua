local Roact = require(script.Parent.Parent.Parent.Vendor.Roact)
local Roact_createElement = Roact.createElement

local function OutlineAdorn(props)
	local adornee = props.Adornee
	if adornee:IsA("Attachment") then
		return Roact_createElement("BoxHandleAdornment", {
			Adornee = adornee.Parent,
			CFrame = adornee.CFrame,
			Color3 = props.Color,
			Size = Vector3.new(1.5, 1.5, 1.5),
			Transparency = 0.3,
		})
	end

	return Roact_createElement("SelectionBox", {
		Adornee = adornee,
		Color3 = props.Color,
		LineThickness = 0.05,
	})
end

return OutlineAdorn
