return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				ocamllsp = {
					filetypes = {
						"ocaml",
						"ocaml.menhir",
						"ocaml.interface",
						"ocaml.ocamllex",
						"reason",
						"dune",
					},
					root_markers = {
						function(name)
							return name:match(".*%.opam$")
						end,
						"esy.json",
						"package.json",
						".git",
						"dune-project",
						"dune-workspace",
						function(name)
							return name:match(".*%.ml$")
						end,
					},
				},
			},
		},
	},
}
