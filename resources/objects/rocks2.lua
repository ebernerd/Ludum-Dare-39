local base = love.filesystem.load("resources/objects/object.lua")()

return base:extend {

	drawable = Texture("rocks2"),
	hasColliders = false,
	name = "rocks2",
	alwaysBottom = true,

}