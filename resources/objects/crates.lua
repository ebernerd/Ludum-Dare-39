local base = love.filesystem.load("resources/objects/object.lua")()

return base:extend {

	drawable = Texture("crate"),
	name = "crates",
	type = "obj",
	hasColliders = false,

}