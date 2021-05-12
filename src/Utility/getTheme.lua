local studioStyleGuideColors = Enum.StudioStyleGuideColor:GetEnumItems()
local studioStyleGuideModifiers = Enum.StudioStyleGuideModifier:GetEnumItems()

local function getTheme()
	local studioTheme = settings().Studio.Theme
	local theme = {ThemeName = studioTheme.Name}

	for _, studioStyleGuideColor in ipairs(studioStyleGuideColors) do
		local color = {}
		for _, studioStyleGuideModifier in ipairs(studioStyleGuideModifiers) do
			color[studioStyleGuideModifier.Name] = studioTheme:GetColor(studioStyleGuideColor, studioStyleGuideModifier)
		end

		theme[studioStyleGuideColor.Name] = color
	end

	return theme
end

return getTheme
