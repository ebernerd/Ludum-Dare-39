local base = love.filesystem.load("resources/objects/object.lua")()

return base:extend {

	drawable = Texture("rose"),
	hasColliders = false,
	name = "rose",

}