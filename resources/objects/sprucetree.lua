local base = love.filesystem.load("resources/objects/object.lua")()

return base:extend {

	drawable = Texture("tree2"),
	colliders = {
		[1] = {
			x = 6,
			w = 4,
			y = 8,
			h = 8,
		}
	},
	name = "sprucetree",

}