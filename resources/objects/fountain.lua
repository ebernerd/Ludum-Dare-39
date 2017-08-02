local base = love.filesystem.load("resources/objects/object.lua")()

return base:extend {

	drawable = Animation( 0.1, table.deepcopy({
		Texture("fountain1"),
		Texture("fountain2"),
		Texture("fountain3"),
		Texture("fountain4"),
		Texture("fountain5"),
		Texture("fountain6"),
		Texture("fountain7"),
		Texture("fountain8"),
		Texture("fountain9"),
		Texture("fountain10"),
		Texture("fountain11"),
		Texture("fountain12"),
		Texture("fountain13"),
		Texture("fountain1"),
	})),
	colliders = {
		[1] = {
			y = 5,
			h = 10,
			x = 0,
			w = 16,
		}
	},
	name = "fountain",

}