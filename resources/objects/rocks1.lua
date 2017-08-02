local base = love.filesystem.load("resources/objects/object.lua")()

return base:extend {

	drawable = Texture("rocks1"),
	hasColliders = false,
	name = "rocks1",
	alwaysBottom = true,

}