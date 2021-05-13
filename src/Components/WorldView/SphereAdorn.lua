local Roact = require(script.Parent.Parent.Parent.Vendor.Roact)
local Roact_createElement = Roact.createElement

local function SphereAdorn(props)
	local adornee = props.Adornee
	local adorn, cframe
	if adornee:IsA("Attachment") then
		adorn = adornee.Parent
		cframe = adornee.CFrame
	else
		adorn = adornee
	end

	return Roact_createElement("SphereHandleAdornment", {
		Adornee = adorn,
		AlwaysOnTop = props.AlwaysOnTop,
		CFrame = cframe,
		Color3 = props.Color,
		Transparency = 0.3,
		ZIndex = props.AlwaysOnTop and 1 or nil,
	})
end

return SphereAdorn
