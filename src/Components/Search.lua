local Roact = require(script.Parent.Parent.Vendor.Roact)
local ThemeContext = require(script.Parent.ThemeContext)

local Search = Roact.PureComponent:extend("Search")

function Search:init()
	self:setState({
		hover = false,
		focus = false,
	})
end

function Search:render()
	local searchBarState = "Default"

	if self.state.focus then
		searchBarState = "Selected"
	elseif self.state.hover then
		searchBarState = "Hover"
	end

	return Roact.createElement("Frame", {
		Size = self.props.Size,
		Position = self.props.Position,
		BackgroundTransparency = 1,
	}, {
		SearchBarContainer = Roact.createElement(ThemeContext.Consumer, {
			render = function(theme)
				return Roact.createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(1, -16, 1, -16),
					BackgroundColor3 = theme.InputFieldBackground.Default,
					BorderSizePixel = 1,
					BorderColor3 = theme.InputFieldBorder[searchBarState],

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
					SearchBar = Roact.createElement("TextBox", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.new(0.5, 0, 0.5, 0),
						Size = UDim2.new(1, -20, 0, 20),
						BackgroundTransparency = 1,
						TextXAlignment = Enum.TextXAlignment.Left,
						Font = Enum.Font.SourceSans,
						TextSize = 20,
						PlaceholderText = "Search",
						PlaceholderColor3 = theme.DimmedText.Default,
						TextColor3 = theme.MainText.Default,
						Text = self.props.term,
						ClearTextOnFocus = false,

						[Roact.Change.Text] = function(rbx)
							self.props.setTerm(rbx.Text)
						end,

						[Roact.Event.InputBegan] = function(_, input)
							if input.UserInputType == Enum.UserInputType.MouseButton2 and input.UserInputState == Enum.UserInputState.Begin then
								self.props.setTerm("")
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
