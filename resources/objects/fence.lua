local base = love.filesystem.load("resources/objects/object.lua")()

return base:extend {

	drawable = Texture("fence_flat"),
	colliders = {
		[1] = {
			y = 10,
			h = 5,
			x = 0,
			w = 16,
		}
	},
	name = "fence",

}