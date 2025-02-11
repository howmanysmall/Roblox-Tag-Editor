local CoreGui = game:GetService("CoreGui")

local BoxAdorn = require(script.Parent.BoxAdorn)
local IconAdorn = require(script.Parent.IconAdorn)
local OutlineAdorn = require(script.Parent.OutlineAdorn)
local Roact = require(script.Parent.Parent.Parent.Vendor.Roact)
local SphereAdorn = require(script.Parent.SphereAdorn)
local TextAdorn = require(script.Parent.TextAdorn)

local Roact_createElement = Roact.createElement

local function WorldVisual(props)
	local partsList = props.partsList

	local children = {}

	for key, entry in pairs(partsList) do
		local elt
		if entry.DrawType == "Outline" then
			elt = OutlineAdorn
		elseif entry.DrawType == "Box" then
			elt = BoxAdorn
		elseif entry.DrawType == "Sphere" then
			elt = SphereAdorn
		elseif entry.DrawType == "Icon" then
			elt = IconAdorn
		elseif entry.DrawType == "Text" then
			elt = TextAdorn
		else
			error("Unknown DrawType: " .. tostring(entry.DrawType))
		end

		children[key] = Roact_createElement(elt, {
			Adornee = entry.Part,
			AlwaysOnTop = entry.AlwaysOnTop,
			Color = entry.Color,
			Icon = entry.Icon,
			TagName = entry.TagName,
		})
	end

	return Roact_createElement(Roact.Portal, {
		target = CoreGui,
	}, {
		TagEditorWorldView = Roact_createElement("Folder", {}, children),
	})
end

return WorldVisual
