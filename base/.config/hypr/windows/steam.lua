hl.window_rule({
	name = "floating-steam",
	match = { class = "^steam$" },
	float = true,
})

hl.window_rule({
	name = "non-floating-steam",
	match = {
		class = "^steam$",
		title = "^Steam$",
	},
	workspace = "4 silent",
	tile = true,
})

hl.window_rule({
	name = "steam-login",
	match = {
		class = "^steam$",
		title = "^Sign in to Steam$",
	},
	workspace = "4 silent",
})
