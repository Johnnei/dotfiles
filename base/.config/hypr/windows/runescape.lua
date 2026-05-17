hl.window_rule({
	name = "hide-explorer",

	match = { class = "^explorer.exe$" },

	workspace = "6 silent",
})

hl.window_rule({
	name = "stick-launcher-with-steam",

	match = {
		class = "^jagexlauncher.exe$",
		title = "^Jagex Launcher$",
	},

	workspace = "4",
})

hl.window_rule({
	name = "rs3-render-tabbed",
	match = { class = "^rs2client.exe$" },

	render_unfocused = true,
})
