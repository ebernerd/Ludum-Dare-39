local base = love.filesystem.load("resources/objects/object.lua")()

return base:extend {

	drawable = Texture("cactus"),
	colliders = {
		[1] = {
			x = 5,
			w = 6,
			y = 9,
			h = 7,
			type = "rigid",
			name = "cactus",
		}
	},
	name = "cactus",

}