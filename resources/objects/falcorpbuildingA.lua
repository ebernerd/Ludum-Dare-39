local base = love.filesystem.load("resources/objects/object.lua")()

return base:extend {

	drawable = Texture("falcorpb"),
	name = "falcorpbuildingA",
	type = "obj",
	init = function( self, data )
		self:baseInit( data )
	end,

}