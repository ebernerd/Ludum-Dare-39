local base = love.filesystem.load("resources/objects/object.lua")()

return base:extend {
	hx = 3,
	hy = 5,
	hh = 11,
	hw = 10,

	colliders = {
		[1] = {
			x = 3,
			y = 8,
			w = 10,
			h = 8,
		}
	},

	hoverable = true,
	clickable = true,
	
	name = "chest",
	
	drawable = Texture("chest"),

	onClick = function( self )
		FadeToState("Win")
		self:remove()
	end,

}