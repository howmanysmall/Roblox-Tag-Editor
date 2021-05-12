local Roact = require(script.Parent.Parent.Parent.Vendor.Roact)

local function SphereAdorn(props)
	local adorn, cframe
	if props.Adornee:IsA("Attachment") then
		adorn = props.Adornee.Parent
		cframe = props.Adornee.CFrame
	else
		adorn = props.Adornee
	end

	return Roact.createElement("SphereHandleAdornment", {
		Adornee = adorn,
		CFrame = cframe,
		Color3 = props.Color,
		AlwaysOnTop = props.AlwaysOnTop,
		Transparency = 0.3,
		ZIndex = props.AlwaysOnTop and 1 or nil,
	})
end

return SphereAdorn
