local base = love.filesystem.load("resources/objects/object.lua")()

return base:extend {

	hx = 4,
	hy = 7,
	hw = 9,
	hh = 9,

	drawable = Texture("sign"),
	hasColliders = false,
	hoverable = true,
	clickable = true,
	dialogue = {
		"A Random Sign",
		{
			"This is a sign!",
			"Too bad it doesn't have much text."
		}
	},
	onClick = function( self )
		player.canMove = false
		player.lockCamera = false
		local dialogue = table.deepcopy(self.dialogue)
		table.insert( dialogue, self.x + self.drawable.image:getWidth()/2 )
		table.insert( dialogue, self.y + self.drawable.image:getHeight()/2 )
		table.insert( dialogue, self.image or "resources/images/dialogues/newItem.png" )
		print( table.serialize( dialogue ) )
		Moan.clearMessages()
		Moan.new(unpack(dialogue))
	end,
	name = "sign",

}