local base = love.filesystem.load("resources/objects/object.lua")()

return base:extend {

	drawable = Texture("falcorpsign"),
	name = "falcorpsign",
	type = "obj",
	colliders=  {
		[1] = {
			x = 2,
			y = 7,
			h = 3,
			w = 12
		}
	}

}