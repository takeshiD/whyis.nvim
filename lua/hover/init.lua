---@type Hover.Provider[]
local providers = {
	require("whyis.hover.clippy"),
}

return {
	name = "whyis",
	priority = 1000,
	providers = providers,
}
