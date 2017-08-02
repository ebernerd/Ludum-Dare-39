local base = love.filesystem.load("resources/objects/object.lua")()

return base:extend {

	drawable = Texture("store"),
	name = "store",
	hoverable = true,
	clickable = true,
	hx = 3,
	hy = 10,
	hw = 5,
	hh = 6,
	w = 32,
	colliders = {
		[1] = {
			y = 9,
			x = 0,
			w = 32,
			h = 7
		}
	},
	onClick = function( self )
		player.canMove = false
		player.lockCamera = false
		player.canOpenInventory = false

		local buy, main, exit, batteries, buyBurn, buyShock, buyHalf, buyFull, recharge, more, heal, buy
		Moan.clearMessages()

		function heal()
			Moan.new("Oakwood Country Store", {
				"What can we do for you?",
			},player.x,player.y,"resources/images/dialogues/quest.png",
			{
				{"+25 HP [$75]", buyHalfHealth},
				{"+50 HP [$125]", buyFullHealth},
				{"Back", more}
			})
		end

		function buyHalfHealth()
			if player.cash >= 75 then
				player.cash = player.cash - 125
				player.hp = player.hp + 25
				if player.hp > 100 then player.hp = 100 end
				Moan.new("Oakwood Country Store", {
					"It was a pleasure doing business with you.",
				},player.x,player.y,"resources/images/dialogues/quest.png",
				{
					{"OK", main}
				})
			else
				Moan.new("Oakwood Country Store", {
					"Sorry, you don't have enough money for that.",
				},player.x,player.y,"resources/images/dialogues/quest.png",
				{
					{"OK", heal}
				})
			end
		end
		function buyFullHealth()
			if player.cash >= 125 then
				player.cash = player.cash - 125
				player.hp = player.hp + 50
				if player.hp > 100 then player.hp = 100 end
				Moan.new("Oakwood Country Store", {
					"It was a pleasure doing business with you.",
				},player.x,player.y,"resources/images/dialogues/quest.png",
				{
					{"OK", main}
				})
			else
				Moan.new("Oakwood Country Store", {
					"Sorry, you don't have enough money for that.",
				},player.x,player.y,"resources/images/dialogues/quest.png",
				{
					{"OK", heal}
				})
			end
		end

		function more()
			Moan.new("Oakwood Country Store", {
				"How can I help you?",
			},player.x,player.y,"resources/images/dialogues/quest.png",
			{
				{"Heal", heal},
				{"Back...", main},
				{"Leave Store", exit}
			})
		end

		function exit()
			Moan.clearMessages()
			player.canMove = true
			player.lockCamera = true
			player.canOpenInventory = true
		end
		function recharge()
			local units = 0
			local canRecharge = false
			for i, v in pairs( _invslots ) do
				if v.item and type(v.item) ~= string and v.item.name == "battery" then
					if v.item.charge < 100 then
						canRecharge = true
						units = units + math.abs(v.item.charge-100)
					end
				end
			end
			if canRecharge then
			
				local cost = units
				local msg
				if cost > player.cash then
					cost = math.fmod(player.cash,cost)
					units = cost
				end
				Moan.new("Oakwood Country Store", {
					"You can afford to recharge " .. units .. "W of power.",
					"This will cost $" .. cost .. ". Okay?",
				},player.x, player.y, "resources/images/dialogues/quest.png",
				{
					{"OK", function()
						player.cash = player.cash - cost
						player.canOpenInventory = true
						for i, v in pairs( _invslots ) do
							if v.item and type(v.item) ~= string and v.item.name == "battery" then
								if v.item.charge + units > 100 then
									units = units-(100-v.item.charge)
									v.item.charge = 100
								else
									v.item.charge = v.item.charge + units
								end
							end
						end
					end},
					{"Nevermind", main}
				})
			else
				Moan.new("Oakwood Country Store", {
					"Sorry, you've got nothing left to charge."
				},player.x, player.y, "resources/images/dialogues/quest.png",
				{
					{"OK", main}
				})
			end
		end
		function buyHalf()
			if player.cash >= 100 then
				player.cash = player.cash - 100
				table.insert(player.inventory, Items.batterycartridge({charge=50}))
				GENERATE_WEAPONUI()
				Moan.new("Oakwood Country Store", {
					"It was a pleasure doing business with you.",
				},player.x,player.y,"resources/images/dialogues/quest.png",
				{
					{"OK", main}
				})
			else
				Moan.new("Oakwood Country Store", {
					"Sorry, you don't have enough money for that.",
				},player.x,player.y,"resources/images/dialogues/quest.png",
				{
					{"OK", batteries}
				})
			end
		end
		function buyFull()
			if player.cash >= 175 then
				player.cash = player.cash - 175
				GENERATE_WEAPONUI()
				table.insert(player.inventory, Items.batterycartridge({charge=100}))
				Moan.new("Oakwood Country Store", {
					"It was a pleasure doing business with you.",
				},player.x,player.y,"resources/images/dialogues/quest.png",
				{
					{"OK", main}
				})
			else
				Moan.new("Oakwood Country Store", {
					"Sorry, you don't have enough money for that.",
				},player.x,player.y,"resources/images/dialogues/quest.png",
				{
					{"OK", batteries}
				})
			end
		end
		function buyBurn()
			if player.cash >= 200 then
				GENERATE_WEAPONUI()
				player.cash = player.cash - 200
				table.insert(player.inventory, Items.healthcartridge())
				Moan.new("Oakwood Country Store", {
					"It was a pleasure doing business with you.",
				},player.x,player.y,"resources/images/dialogues/quest.png",
				{
					{"OK", main}
				})
			else
				Moan.new("Oakwood Country Store", {
					"Sorry, you don't have enough money for that.",
				},player.x,player.y,"resources/images/dialogues/quest.png",
				{
					{"OK", batteries}
				})
			end
		end
		function buyShock()
			if player.cash >= 350 then
				player.cash = player.cash - 350
				GENERATE_WEAPONUI()
				table.insert(player.inventory, Items.shockcartridge())
				Moan.new("Oakwood Country Store", {
					"It was a pleasure doing business with you.",
				},player.x,player.y,"resources/images/dialogues/quest.png",
				{
					{"OK", main}
				})
			else
				Moan.new("Oakwood Country Store", {
					"Sorry, you don't have enough money for that.",
				},player.x,player.y,"resources/images/dialogues/quest.png",
				{
					{"OK", batteries}
				})
			end
		end
		function attackCards()
			Moan.new("Oakwood Country Store", {
				"What can we do for you?",
			},player.x,player.y,"resources/images/dialogues/quest.png",
			{
				{"Revive [$200]", buyBurn},
				{"Shock [$350]", buyShock},
				{"Back", buy}
			})
		end
		function batteries()
			Moan.new("Oakwood Country Store", {
				"What can we do for you?",
			},player.x,player.y,"resources/images/dialogues/quest.png",
			{
				{"Half Charged [$100]", buyHalf},
				{"Fully Charged [$175]", buyFull},
				{"Back", buy}
			})
		end
		function buy()
			Moan.new("Oakwood Country Store", {
				"What interests you here?",
			},player.x,player.y,"resources/images/dialogues/quest.png",
			{
				{"Attack Cartridges", attackCards},
				{"Batteries", batteries},
				{"Back", main}
			})
		end
		function main()
			Moan.new("Oakwood Country Store", {
				"How can I help you?",
			},player.x,player.y,"resources/images/dialogues/quest.png",
			{
				{"Buy", buy},
				{"Recharge", recharge},
				{"More...", more}
			})
		end
		main()
	end,
}