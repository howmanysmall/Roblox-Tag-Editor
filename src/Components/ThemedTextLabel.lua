local Roact = require(script.Parent.Parent.Vendor.Roact)
local TextLabel = require(script.Parent.TextLabel)
local ThemeContext = require(script.Parent.ThemeContext)
local Roact_createElement = Roact.createElement

local function ThemedTextLabel(props)
	local kind = props.object or "MainText"
	local state = props.state or "Default"

	return Roact_createElement(ThemeContext.Consumer, {
		render = function(theme)
			local newProps = {
				Font = Enum.Font.SourceSans,
				TextColor3 = theme[kind][state],
			}

			for key, value in pairs(props) do
				if key ~= "object" and key ~= "state" then
					newProps[key] = value
				end
			end

			return Roact_createElement(TextLabel, newProps)
		end,
	})
end

return ThemedTextLabel
