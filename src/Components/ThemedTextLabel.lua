local Roact = require(script.Parent.Parent.Vendor.Roact)
local TextLabel = require(script.Parent.TextLabel)
local ThemeContext = require(script.Parent.ThemeContext)

local function ThemedTextLabel(props)
	local kind = props.object or "MainText"
	local state = props.state or "Default"

	return Roact.createElement(ThemeContext.Consumer, {
		render = function(theme)
			local newProps = {
				TextColor3 = theme[kind][state],
				Font = Enum.Font.SourceSans,
			}

			for key, value in pairs(props) do
				if key ~= "object" and key ~= "state" then
					newProps[key] = value
				end
			end

			return Roact.createElement(TextLabel, newProps)
		end,
	})
end

return ThemedTextLabel
