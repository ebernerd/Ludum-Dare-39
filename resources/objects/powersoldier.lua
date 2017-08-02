local base = love.filesystem.load("resources/objects/object.lua")()

return base:extend {

	drawable = Texture("powersoldier"),
	name = "powersoldier",
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
		FightOpponentHP = love.math.random(15, 21)*10
		FightOpponentEffects = {}
		Sounds.dangershort2:play()
		local msgs = {
			"My colleagues below me are inferior to the strength I can put up.",
			"So how about your put your money where your mouth is and fight a real man?",
		}
		local function start()
			FightOpponent = Texture("powersoldier")
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
		Moan.new("Soldier", msgs, 0, 0, "resources/images/dialogues/powersoldier.png", {
			{"Let's go!", start}
		})
	end
}