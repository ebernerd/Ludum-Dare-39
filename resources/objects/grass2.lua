local base = love.filesystem.load("resources/objects/object.lua")()

return base:extend {

	drawable = Texture("grass2"),
	hasColliders = false,
	name = "grass2",

}