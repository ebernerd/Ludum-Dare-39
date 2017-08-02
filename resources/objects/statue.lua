local base = love.filesystem.load("resources/objects/object.lua")()

return base:extend {

	hx = 4,
	hy = 7,
	hw = 9,
	hh = 9,

	drawable = Texture("statue"),
	hoverable = true,
	clickable = true,
	dialogue = {
		"Town Statue",
		{
			"\"THOSE WHO ARE IN THE RIGHT...",
			"...HAVE NO NEED TO FIGHT.\"",
		}
	},
	onClick = function( self )
		player.canMove = false
		player.lockCamera = false
		local dialogue = table.deepcopy(self.dialogue)
		table.insert( dialogue, self.x + self.drawable.image:getWidth()/2 )
		table.insert( dialogue, self.y + self.drawable.image:getHeight()/2 )
		table.insert( dialogue, "resources/images/dialogues/statue.png" )
		table.insert( dialogue, 
			{{"Hm...", 
				function()
					Moan.new( "You", 
					{"That looks a lot like that Old Man Jenkins...",},
					player.x,player.y,"resources/images/dialogues/player.png")
				end	
			}})
		Moan.clearMessages()
		Moan.new(unpack(dialogue))
	end,
	name = "statue",

}