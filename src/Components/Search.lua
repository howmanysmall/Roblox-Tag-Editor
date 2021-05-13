local Roact = require(script.Parent.Parent.Vendor.Roact)
local ThemeContext = require(script.Parent.ThemeContext)
local Roact_createElement = Roact.createElement

local Search = Roact.PureComponent:extend("Search")

function Search:init()
	self:setState({
		focus = false,
		hover = false,
	})
end

function Search:render()
	local props = self.props
	local state = self.state
	local searchBarState = "Default"

	if state.focus then
		searchBarState = "Selected"
	elseif state.hover then
		searchBarState = "Hover"
	end

	return Roact_createElement("Frame", {
		BackgroundTransparency = 1,
		Position = props.Position,
		Size = props.Size,
	}, {
		SearchBarContainer = Roact_createElement(ThemeContext.Consumer, {
			render = function(theme)
				return Roact_createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = theme.InputFieldBackground.Default,
					BorderColor3 = theme.InputFieldBorder[searchBarState],
					BorderSizePixel = 1,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.new(1, -16, 1, -16),

					[Roact.Event.MouseEnter] = function()
						self:setState({
							hover = true,
						})
					end,

					[Roact.Event.MouseLeave] = function()
						self:setState({
							hover = false,
						})
					end,
				}, {
					SearchBar = Roact_createElement("TextBox", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						ClearTextOnFocus = false,
						Font = Enum.Font.SourceSans,
						PlaceholderColor3 = theme.DimmedText.Default,
						PlaceholderText = "Search",
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.new(1, -20, 0, 20),
						Text = props.term,
						TextColor3 = theme.MainText.Default,
						TextSize = 20,
						TextXAlignment = Enum.TextXAlignment.Left,

						[Roact.Change.Text] = function(rbx)
							props.setTerm(rbx.Text)
						end,

						[Roact.Event.InputBegan] = function(_, inputObject)
							if inputObject.UserInputType == Enum.UserInputType.MouseButton2 and inputObject.UserInputState == Enum.UserInputState.Begin then
								props.setTerm("")
							end
						end,

						[Roact.Event.Focused] = function()
							self:setState({
								focus = true,
							})
						end,

						[Roact.Event.FocusLost] = function()
							self:setState({
								focus = false,
							})
						end,
					}),
				})
			end,
		}),
	})
end

return Search
