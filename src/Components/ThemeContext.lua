local Roact = require(script.Parent.Parent.Vendor.Roact)
local getTheme = require(script.Parent.Parent.Utility.getTheme)

local ThemeContext = Roact.createContext(getTheme())

return ThemeContext
