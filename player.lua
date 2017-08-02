player = {
	x = 0,
	y = 0,
	xvel = 0,
	yvel = 0,
	w = 5,
	h = 7,
	cash = 100,
	friction = 7,
	charge = 0,
	maxcharge = 100,
	stepTimer = Timer(0.25),
	stepping = 1,
	direction = "right",
	dy = soft:new(0),
	speed = 150,
	hp = 100,
	lockCamera = true,
	canMove = true,
	inInventory = false,
	isTurn = false,
	canOpenInventory = true,

	inventory = {
		
	},
	weapon = {},

	filter = function( item, other )
		
		if other.type then
			if other.type == "rigid" then
				return "slide"
			end
		end
		return "slide"
	end,

	textures = {
		left = {
			love.graphics.newImage("resources/images/playerLeft1.png"),
			love.graphics.newImage("resources/images/playerLeft2.png")
		},
		right = {
			love.graphics.newImage("resources/images/playerRight1.png"),
			love.graphics.newImage("resources/images/playerRight2.png")
		},
	},

	update = function( dt )
		local maxcharge = 0.01
		local charge = 0
		for i, v in pairs( _invslots ) do
			if v.type == "Weapon" then
				if v.item and type(v.item) ~= string and v.item.name == "battery" then
					maxcharge = maxcharge + 100
					charge = charge + v.item.charge or 0
				end
			end
		end
		if maxcharge > 1 then maxcharge = maxcharge - 0.01 end
		player.maxcharge = maxcharge
		player.charge = charge
		if player.canMove then
			local ddx = 0
			local ddy = 0

			if love.keyboard.isDown("a") then
				ddx = -player.speed * dt
				player.direction = "left"
			elseif love.keyboard.isDown("d") then
				ddx = player.speed * dt
				player.direction = "right"
			else
				ddx = -( player.xvel * ( player.friction * dt ) )
			end
			if love.keyboard.isDown("w") then
				ddy = -player.speed * dt
			elseif love.keyboard.isDown("s") then
				ddy = player.speed * dt
			else
				ddy = -( player.yvel * ( player.friction * dt ) )
			end

			if love.keyboard.isDown("a","d","s","w") then
				if player.stepTimer:update( dt ) then
					if player.stepping > 1 then
						player.stepping = 1
					else
						player.stepping = 2
					end
				end
			else
				player.stepTimer:reset()
				player.stepping = 1
			end


			player.xvel = player.xvel + ddx
			player.yvel = player.yvel + ddy

			player.xvel = love.math.clamp( player.xvel, -40, 40 )
			player.yvel = love.math.clamp( player.yvel, -40, 40 )

			local cols
			player.x, player.y, cols = WORLD:move( "player", player.x + player.xvel * dt, player.y + player.yvel * dt, player.filter )
			if #cols > 0 then
				for i, v in pairs( cols ) do
					if v.normal.x ~= 0 then
						player.xvel = 0
					end
					if v.normal.y ~= 0 then
						player.yvel = 0
					end
					if v.other.name then
						--CUSTOM OBJECT ACTIONS--
						if v.other.name == "cactus" then
							player.hp = player.hp - love.math.random( 10, 15 )
							if v.normal.x ~= 0 then
								player.xvel = love.math.random(100,150) * v.normal.x
							elseif v.normal.y ~= 0 then
								player.yvel = love.math.random(100,150) * v.normal.y
							end
						end
					end
				end
			end


			camera:lookAt(player.x, player.y)
		end
	end,
	draw = function( dt )
		love.graphics.draw( player.textures[player.direction][player.stepping], player.x-1, player.y-4 )
		if Debug.showColliders then
			love.graphics.setColor( 255, 0, 0 )
			local x, y, w, h = WORLD:getRect("player")
			love.graphics.rectangle( "line", x, y, w, h )
			love.graphics.setColor( 255, 255, 255 )
		end
	end,
	load = function()
		WORLD:add("player", player.x, player.y, player.w, player.h)
		--player.inventory = {Items.shockcartridge(),Items.batterycartridge({charge=10}),Items.healthcartridge(),Items.strengthcartridge(),Items.burncartridge()}
		player.inventory = {Items.strengthcartridge(), Items.batterycartridge({charge=love.math.random(1,1.3)*10})}
	end,

	initiateFight = function()
		local title = "In Battle!"
		local main, specialAttacks
		player.isTurn = true
		local function powerDown(amt)
			local amt = amt or 0
			local batts = 0
			for i, v in pairs( _invslots ) do
				if v.type == "Weapon" and v.item and type(v.item) ~= "string" and v.item.name == "battery" then
					if v.item.charge > 0 then
						if v.item.charge - amt < 0 then
							amt = amt - v.item.charge
							v.item.charge = 0
						else
							v.item.charge = v.item.charge - amt
							return
						end
					end
				end
			end
		end
		local function punch()
			player.isTurn = false
			local dmg = love.math.random(9,15)
			FightOpponentHP = FightOpponentHP - dmg
			Moan.new(title,{
				"You used Punch, and dealt " .. dmg .. " damage.",
			},0,0,"resources/images/dialogues/player.png",
			{
				{"OK", function() FightOpponentAttack() end }
			})
		end
		local function kick()
			player.isTurn = false
			local dmg = love.math.random(12,20)
			FightOpponentHP = FightOpponentHP - dmg
			Moan.new(title,{
				"You used Kick, and dealt " .. dmg .. " damage.",
			},0,0,"resources/images/dialogues/player.png",
			{
				{"OK", function() FightOpponentAttack() end }
			})
		end
		local function burn()
			player.isTurn = false
			if (player.charge - 10) >= 0 then
				
				powerDown(10)

				local dmg = love.math.random(25, 30)
				local effect = love.math.random(1,3)
				FightOpponentHP = FightOpponentHP - dmg
				local msg = "You used Burn and dealt " .. dmg .. " damage."
				local msg2
				if effect == 1 and #FightOpponentEffects < 1 then
					local time = love.math.random(3,5)
					table.insert(FightOpponentEffects, {"Burn", time=time})
					msg2 = "You also inflicted a Burn that will last " .. time .. " turns!"
				end
				Moan.new(title,{
					msg,
					msg2,
				},0,0,"resources/images/dialogues/player.png",
				{
					{"OK", function() FightOpponentAttack() end }
				})
			else
				Moan.new("In Battle!", {
					"You do not have enough power to do that!",
				},0,0,"resources/images/dialogues/player.png",
				{
					{"OK", function() main() end}
				})
			end
		end
		local function shock()
			player.isTurn = false
			if (player.charge - 20) >= 0 then
				
				powerDown(20)

				local dmg = love.math.random(45, 55)
				local msg = "You used Shock and dealt " .. dmg .. " damage."
				FightOpponentHP = FightOpponentHP - dmg
				Moan.new(title,{
					msg,
					msg2,
				},0,0,"resources/images/dialogues/player.png",
				{
					{"OK", function() FightOpponentAttack() end }
				})
			else
				Moan.new("In Battle!", {
					"You do not have enough power to do that!",
				},0,0,"resources/images/dialogues/player.png",
				{
					{"OK", function() main() end}
				})
			end
		end
		local function revive()
			player.isTurn = false
			if (player.charge - 25) >= 0 then
				local dmg = love.math.random( 25, 35 )
				powerDown(25)
				local msg = "You used Revive and regained " .. dmg .. " hit points!"
				player.hp = player.hp + dmg
				if player.hp > 100 then player.hp = 100 end
				Moan.new(title,{
					msg,
				},0,0,"resources/images/dialogues/player.png",
				{
					{"OK", function() FightOpponentAttack() end }
				})
			else
				Moan.new("In Battle!", {
					"You do not have enough power to do that!",
				},0,0,"resources/images/dialogues/player.png",
				{
					{"OK", function() main() end}
				})
			end
		end
		local function strength()
			player.isTurn = false
			if (player.charge - 5) >= 0 then
				
				powerDown(5)

				local dmg = love.math.random(25, 35)
				local msg = "You used Strength and dealt " .. dmg .. " damage."
				FightOpponentHP = FightOpponentHP - dmg
				Moan.new(title,{
					msg,
					msg2,
				},0,0,"resources/images/dialogues/player.png",
				{
					{"OK", function() FightOpponentAttack() end }
				})
			else
				Moan.new("In Battle!", {
					"You do not have enough power to do that!",
				},0,0,"resources/images/dialogues/player.png",
				{
					{"OK", function() FightOpponentAttack() end}
				})
			end
		end

		function standardAttacks()
			player.inInventory = false
			HIDE_WEAPONUI()
			SelectingFromInv = false
			
			Moan.new(title,{
				"What would you like to do?",
			},0,0,"resources/images/dialogues/player.png",
			{
				{"Kick (0 TPD)", function() kick() end},
				{"Punch (0 TPD)", function() punch() end},
				{"Back", function() main() end}
			})
		end

		function specialAttacks()
			player.inInventory = false
			HIDE_WEAPONUI()
			SelectingFromInv = false

			local items = {}
			for i, v in pairs( _invslots ) do
				if v.type == "Weapon" and v.item and type(v.item) ~= "string" then
					if #items < 2 and v.item.type and v.item.type == "Attack" then
						local tpd = v.item.tpd
						if v.item.attackName == "Shock" then
							table.insert(items, { "Shock (" .. tpd .. "W)", function() shock() end } )
						elseif v.item.attackName == "Strength" then
							table.insert(items, { "Strength (" .. tpd .. "W)", function() strength() end } )
						elseif v.item.attackName == "Burn" then
							table.insert(items, { "Burn (" .. tpd .. "W)", function() burn() end})
						elseif v.item.attackName == "Health" then
							table.insert(items, { "Revive (" .. tpd .. "W)", revive})
						end
					end
				end
			end
			table.insert( items, {"Back", function() main() end,})
			
			Moan.new(title,{
				"What would you like to do?",
			},0,0,"resources/images/dialogues/player.png",
			items)
		end

		function main()
			player.canOpenInventory = true
			player.isTurn = true
			Moan.new(title,{
				"What would you like to do?",
			},0,0,"resources/images/dialogues/player.png",
			{
				{"Standard Attacks", function() standardAttacks() end},
				{"Special Attacks", function() specialAttacks() end},
			})
		end
		
		player.inInventory = false
		HIDE_WEAPONUI()
		SelectingFromInv = false
		main()
	end,
}
player.textures.left[1]:setFilter("nearest","nearest")
player.textures.left[2]:setFilter("nearest","nearest")
player.textures.right[1]:setFilter("nearest","nearest")
player.textures.right[2]:setFilter("nearest","nearest")