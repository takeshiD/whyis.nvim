--- @type Hover.ProviderGroup
return {
	name = "Whyis",
	priority = 1000,
	providers = {
		require("whyis.hover.ruff"),
		require("whyis.hover.clippy"),
		require("whyis.hover.bacon_ls"),
		require("whyis.hover.biome"),
		require("whyis.hover.denols"),
	},
}
