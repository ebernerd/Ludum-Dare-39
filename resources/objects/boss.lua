local base = love.filesystem.load("resources/objects/object.lua")()

return base:extend {

	drawable = Texture("boss"),
	name = "boss",
	hoverable = true,
	clickable = true,
	w = 6,
	h = 11,
	hx = 1,
	hy = 1,
	hw = 6,
	hh = 11,
	min = 10,
	max = 19,
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
		FightOpponentHP = 300
		FightOpponentEffects = {}
		Sounds.dangershort2:play()
		local msgs = {
			"Jeez, what does it take to hire some competent mercenaries?!?",
			"You know who I am; Rick Eagle.",
			"...",
			"Owner of Eagle Inc.?",
			"...",
			"Jeez, what does it take to hire a competent PR staff?!?",
			"Alright, enough of the funny business. This is personal."
		}
		local function start()
			FightOpponent = Texture("boss")
			FightOpponent:scale(12,12)
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
		Moan.new("Soldier", msgs, 0, 0, "resources/images/dialogues/boss.png", {
			{"Do your worst!", start}
		})
	end
}