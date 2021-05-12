local Roact = require(script.Parent.Parent.Parent.Vendor.Roact)

local function OutlineAdorn(props)
	if props.Adornee:IsA("Attachment") then
		return Roact.createElement("BoxHandleAdornment", {
			Adornee = props.Adornee.Parent,
			CFrame = props.Adornee.CFrame,
			Size = Vector3.new(1.5, 1.5, 1.5),
			Transparency = 0.3,
			Color3 = props.Color,
		})
	end

	return Roact.createElement("SelectionBox", {
		LineThickness = 0.05,
		Adornee = props.Adornee,
		Color3 = props.Color,
	})
end

return OutlineAdorn
