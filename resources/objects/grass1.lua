local base = love.filesystem.load("resources/objects/object.lua")()

return base:extend {

	drawable = Texture("grass1"),
	hasColliders = false,
	name = "grass1",

}