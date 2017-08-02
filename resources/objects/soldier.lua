local base = love.filesystem.load("resources/objects/object.lua")()

return base:extend {

	drawable = Texture("soldier"),
	name = "soldier",
	hoverable = true,
	clickable = true,
	w = 6,
	h = 11,
	hx = 0,
	hy = 0,
	hw = 6,
	hh = 11,
	min = 8,
	max = 10,
	colliders = {
		[1] = {
			w = 6,
			h = 13,
			x = 0,
			y = 0,
		}
	},
	onClick = function(self)
		Moan.clearMessages()
		FightOpponentHP = love.math.random(8,10)*10
		FightOpponentEffects = {}
		Sounds.dangershort2:play()
		local msgs = {
			"You think you can trespass on our territory?!?",
			"...well its not our territory, but, you know what I mean.",
		}
		local function start()
			Sounds.dangershort:play()
			IngameOpponent = self
			FadeToState("Fight", function()
				Moan.clearMessages()
				player.initiateFight()
				love.graphics.setBackgroundColor( 25, 25, 25 )
				Sounds.danger:setLooping(true)
				Sounds.danger:play()
			end)
		end
		player.canMove = false
		player.canOpenInventory = false
		Moan.new("Soldier", msgs, 0, 0, "resources/images/dialogues/soldier.png", {
			{"Let's go!", start}
		})
	end
}