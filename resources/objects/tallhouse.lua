local base = love.filesystem.load("resources/objects/object.lua")()

local names = {
	"Sherman",
	"Vaudville",
	"Anthony",
	"Deborah",
	"Queen",
	"Gerald",
	"Geraldine",
	"Samantha",
	"Sarah",
	"Lauren",
	"Devyn",
	"Caitlyn",
	"Tyler",
	"Simon",
}

return base:extend {

	drawable = Texture("tallhouse"),
	name = "tallhouse",
	type = "obj",
	h = 32,
	hx = 3,
	hy = 26,
	hw = 5,
	hh = 6,

	hoverable = true,
	clickable = true,
	dialogue = {
		"A Tall Cottage",
		{
			"Nothing was found inside the house."
		}
	},
	colliders = {
		[1] = {
			x = 0,
			w = 16,
			y = 9,
			h = 21
		}
	},
	inventory = {},
	onClick = function( self )
		local function func()
			player.canMove = false
			player.lockCamera = false
			local dialogue = table.deepcopy(self.dialogue)
			table.insert( dialogue, --[[self.x + self.drawable.image:getWidth()/2]] player.x )
			table.insert( dialogue, --[[self.y + self.drawable.image:getHeight()/2]] player.y )
			table.insert( dialogue, self.image or "resources/images/dialogues/sign.png" )
			Moan.clearMessages()
			Moan.new(unpack(dialogue))
		end
		print( #self.inventory )
		if #self.inventory > 0 then
			if self.notif then self.notif:remove() end
			local count = 1
			local item = MISC_RANDOMITEM()
			if item and item.tooltip ~= "Cash" then
				table.insert( player.inventory, item ); GENERATE_WEAPONUI()
			end
			self.notif= Notification( item.tooltip .." Found",  item.description, item.drawable )
			self.notif:start()
			self.inventory = {}
			self.dialogue = {
				"A Tall Cottage",
				{
					"Nothing was found inside the house."
				}
			}
			self.image = "resources/images/dialogues/sign.png"
		else
			func()
		end
	end,
	init = function( self, data )
		self:baseInit( data )
		local a = love.math.random( 1, 4 )
	
		if a == 1 then
			print("Object added!")
			self.inventory = {
				--[1] = Item[Items(love.math.random(1, #items))]
				[1] = "item",
			}
			self.image = "resources/images/dialogues/newItem.png"
			self.dialogue = {
				"A Tall Cottage",
				{
					"A Thingy was found inside!",
				}
			}
		end
	end,

}