Objects = {}	--All the objects that you can create
Items = {}	--All the items that you can create
_objects = {}	--All the objects that have been created

Debug = {
	showColliders = false,
}
Sounds = {}

for i, v in pairs( love.filesystem.getDirectoryItems("resources/sounds") ) do
	Sounds[v:sub(1,-5)] = love.audio.newSource("resources/sounds/" .. v)
end
Fonts = {
	Big = love.graphics.newFont("resources/fonts/Kubasta.ttf", 50),
	Medium = love.graphics.newFont("resources/fonts/Kubasta.ttf", 40),
	Normal = love.graphics.newFont("resources/fonts/Kubasta.ttf", 30),
	Tiny = love.graphics.newFont("resources/fonts/Kubasta.ttf", 15),
}

Gamestate = "Intro"

class = require "clasp"
--require "camera"
require "ser"


Camera = require "lib.hump.camera"
require "moan/Moan"
soft = require "lib.soft"
require "lib.extras" 
require "lib.timer"
require "lib.animation"
require "lib.texture"
require "lib.dialogue"
require "lib.notification"

require "resources.invslot"

require "editor"
require "player"

bump = require "bump"

FadeState = soft:new(0)
FadeNewState = ""
function FadeToState( state, oncomplete )
	FadeNewState = state or "Game"
	FadeState:to(255)
	FadeWhenDone = oncomplete or function() end
end

function love.load()
	--Load all the objects!--
	if not love.filesystem.isFile("world.lua") then
		local savedata = love.filesystem.load('world.lua')()
		love.filesystem.write("world.lua", table.serialize(savedata))
	end
	HasOpenedInventory = false
	love.graphics.setLineWidth( 1 )
	BirdTimer = Timer( love.math.random( 3, 5 ) )
	AmbienceTimer = Timer( love.math.random( 35, 50 ) )
	for i, v in pairs( love.filesystem.getDirectoryItems("resources/objects") ) do
		if v ~= "object.lua" then
			Objects[v:sub(1,-5)] = love.filesystem.load("resources/objects/" .. v)()
		end
	end
	for i, v in pairs( love.filesystem.getDirectoryItems("resources/items") ) do
		if v ~= "item.lua" then
			Items[v:sub(1,-5)] = love.filesystem.load("resources/items/" .. v)()
		end
	end

	editor.load()
	WORLD = bump.newWorld(4)
	player.load()

	Overlay = Texture("ingameoverlay")

	Test = Notification()

	local worldData = love.filesystem.load("world.lua")()
	for i, v in pairs( worldData ) do
		Objects[v.type](table.deepcopy(v))
	end

	camera = Camera( 0, 0, 7, 0 )
	local x, y = camera:position()
	
	SETRENDERQUEUE()

	
	WeaponUI = {
		visible = false,
		fade = soft:new(0),
		w = love.graphics.getWidth()/2,
		h = love.graphics.getHeight() * 4/6,
	}
	
	GENERATE_WEAPONUI()

	
	IntroFade = soft:new(-255)
	IntroFade:setSpeed(2)
	IntroObjFade = soft:new(-255)
	IntroObjFade:setSpeed(2)
	IntroObj2Fade = soft:new(-255)
	IntroObj2Fade:setSpeed(2)
	IntroFade:to(255)
	IntroPause = Timer(2)
	IntroPause.mode = "terminate"
	IntroTexture = Texture("items/cartridge")
	IntroTexture:scale( 10, 10 )
	IntroTexture2 = Texture("items/cartridge_battery")
	IntroTexture2:scale( 10, 10 )
	Intro = false
	if Gamestate == "Intro" then
		Sounds.theme:setLooping(true)
		Sounds.theme:play()
	end

	InvOverlay = Texture("invOverlay")
	InvOverlay2 = Texture("invOverlay2")

	FightBG = Texture("fightbg")

	HUDFade = soft:new(0)
	HUDTimer = Timer(3)
	HUDTimer.mode = "terminate"
	HUDTimer.active = false


	SelectingFromInv = false
	SelectingFromStore = false

	FightOpponent = Texture("soldierright")
	IngameOpponent = ""
	FightPlayer = Texture("playerLeft1")

	FightOpponent:scale(12,12)
	FightPlayer:scale(12,12)

	FightOpponentHP = 200
	FightOpponentEffects = {}

	WinScreen = Texture("winscreen")
	DeadScreen = Texture("deadscreen")

	FightOpponentAttack = function()
		local dmg = love.math.random( IngameOpponent.min or 10, IngameOpponent.max or 20 )
		local effectDamage = 0
		local msg2, msg3
		for i, v in pairs( FightOpponentEffects ) do
			effectDamage = love.math.random( 10, 25 )
			v.time = v.time - 1
			if v.time == 0 then
				msg3 = "The Burn has worn off."
			end
		end
		
		local cash = love.math.random( 5, 15 )*10
		if effectDamage > 0 then
			msg2 = "The enemy takes " .. effectDamage .. " damage from your Burn!"
			FightOpponentHP = FightOpponentHP - effectDamage
		end
		if FightOpponentHP <= 0 then
			Moan.new("Enemy's Turn!",
			{
				"The enemy has been defeated!",
				"You've received $" .. cash .. " for your efforts.",
			},0,0,"resources/images/dialogues/player.png", {
				{"OK", function() FadeToState("Game"); player.canMove = true; player.canOpenInventory = true; Sounds.danger:stop(); player.cash = player.cash + cash end}
			})
			
			for i, v in pairs( _objects ) do
				if v == IngameOpponent then
					v:remove()
				end
			end
		else			
			player.hp = player.hp - dmg
			Moan.new("Enemy's Turn!",
			{
				"The enemy attacks, and hits you for " .. dmg .. " damage!",
				msg2,
				msg3,
			},0,0,"resources/images/dialogues/player.png",{
				{"OK", function() 
				if player.hp > 0 then 
					player.initiateFight() 
				else 
					FadeToState("Dead") 
				end
				end}
			})
		end
	end

	--visualEffect = --s
	--[[player.initiateFight()
	love.graphics.setBackgroundColor( 25, 25, 25 )
	Sounds.danger:setLooping(true)
	Sounds.danger:play()--]]

end

function love.update( dt )

	UPDATE_OBJECTS( dt )
	UPDATE_NOTIFS(dt)
	Moan.update( dt )
	soft:update( dt )
	if FadeState:get() > 250 then
		Gamestate = FadeNewState
		FadeState:to(0)
		FadeWhenDone()
	end
	if Gamestate == "Game" then
		if HUDTimer:update( dt ) then
			HUDFade:to(0)
		end
		player.update( dt )
		Test:update( dt )
		UPDATE_INVSLOTS( dt )
		if BirdTimer:update( dt ) then
			BirdTimer.time = love.math.random( 4, 7 )
			Sounds["bird" .. tostring(love.math.random(1,5))]:play()
		end
	elseif Gamestate == "Fight" then
		UPDATE_INVSLOTS( dt )
		player.update( dt )
	elseif Gamestate == "Editor" then
		editor.update( dt )
	elseif Gamestate == "Intro" then
		if IntroPause:update( dt ) then
			if not Intro then
				Intro = true
				local WeaponDialogue4 = {
					"Jenkins", {
						"At the moment, there's a bit of a conflict going on in our small town.",
						"You might be the one who has to save it.",
						"So, be cautious with how you use that PowerArm.",
						"There is legend of an all powerful cartridge at FalCorp.",
						"Tales of infinite power and an unending life of bliss.",
						"FalCorp's rival, Eagle Inc, has sent their mercenaries over to attempt to hijack this cartridge.",
						"Get to FalCorp and stop them to save Oakwood.",
						"The power you possess in saving our village is only that of the power in those batteries.",
						"I believe in you. Good luck.",
					},
					0, 0,"resources/images/dialogues/advisor.png",
					{
						{"THANKS, I WON'T LET YOU DOWN.", function() IntroFade:to(0); IntroPause.time = 2; IntroPause.active = true end}
					}
				}
				local WeaponDialogue3 = {
					"Jenkins", {
						"Unfortunately, these PowerArm do-dads run on FalCorp BattMan High Power batteries.",
						"You can buy or find these around the city, but they are quite elusive at the moment.",
						"They don't run out that quick, though the cartridges you use draw power.",
						"Their TDP (Total Power Draw) is measured in W (Watts). As you attack, the battery depletes.",
						"I've given you my old battery. It's barely charged, so you'll have to charge it at the store.",
						"I've also equipped you with the \"Strength\" cartridge, so you're not outmatched.",
					},
					0, 0,"resources/images/dialogues/advisor.png",
					{
						{"WELL, THAT'S SWEET. WHAT ELSE IS THERE TO KNOW?", function() Moan.new(unpack(WeaponDialogue4)); IntroObjFade:to(0); IntroObj2Fade:to(0) end,}
					}
				}
				local WeaponDialogue2 = {
					"Jenkins", {
						"If you can get your hands on a cartridge, like this one...",
						"...you can configure your PowerArm in any way you'd like.",
						"Most cartridges allow you to customize your attack arsenal,",
						"though some are health boosts, as well as a few secrets.",
						"!!!",
						"I forgot to mention the drawback of this fine piece of technology.",
					},
					0, 0,"resources/images/dialogues/advisor.png",
					{
						{"...", function() Moan.new(unpack(WeaponDialogue3)); IntroObjFade:to(0); IntroObj2Fade:to(255) end,}
					}
				}
				local WeaponDialogue = {
					"Jenkins", {
						"It's the newest Falcon PowerArm by FalCorp.",
						"Weird that they'd call it PowerArm when none of us have arms...",
						"REGARDLESS!!",
						"It allows you to interact with the world...",
						"...and it's fully modular.",
					},
					0, 0,"resources/images/dialogues/advisor.png",
					{
						{"WHAT DOES THAT MEAN FOR ME?", function() Moan.new(unpack(WeaponDialogue2)); IntroObjFade:to(255) end,}
					}
				}
				local WeaponDialogue0 = {
					"????? ?????????",
					{
						"Wow, I'm surprised you made it.",
						"Not anything against you, heh, it's just...",
						"Anyways...",
						"I'm here to present you the newest in modern technology.",
						"If you don't remember me, well... you can call me Jenkins. ",
					},
					0,0,"resources/images/dialogues/advisor.png",
					{
						{"WHAT'S THIS TECHNOLOGY YOU'VE SPOKEN OF?", function() Moan.new(unpack(WeaponDialogue)) end },
					}
				}
				Moan.new("Controls", {
					"RETURN / ENTER: Advance messages",
					"WASD: Move character",
					"E: Open/close inventory",
					"ESC: Pause game",
					"TAB: Show HUD",
					"Some objects, like chests and signs, are clickable.",
					"Doors on some/most houses are clickable too.",
					"Got it?",
				}, 0, 0, "resources/images/dialogues/help.png",
				{
					{"Yup, got it!", function() Moan.new(unpack(WeaponDialogue0)) end }
				}
				)
			else
				Gamestate = "Game"
				IntroFade:set(255)
				IntroFade:to(0)
				Sounds.theme:setLooping(false)
				Sounds.theme:stop()
				Sounds.roomtone:setLooping(true)
				Sounds.roomtone:play()
				Sounds.roomtone2:setLooping(true)
				Sounds.roomtone2:play()

			end
		end
		if Intro then
			Sounds.theme:setVolume(IntroFade:get() / 255)
		end
		love.graphics.setBackgroundColor( IntroFade:get(), IntroFade:get(), IntroFade:get() )
	end

end

function love.draw()
	

	camera:attach()
	if Gamestate == "Game" then
		love.graphics.setBackgroundColor( 6, 50, 10 )
		DRAW_OBJECTS()
		if Debug.showColliders then
			local items = WORLD:getItems()
			for i, v in pairs( items ) do
				local x, y, w, h = WORLD:getRect( v )
				love.graphics.setColor( 255, 0, 0 )
				love.graphics.rectangle("line", x, y, w, h )
				love.graphics.setColor( 255, 255, 255 )
			end
		end
	elseif Gamestate == "Editor" then
		DRAW_OBJECTS_EDITOR()
		editor.draw()
	elseif Gamestate == "Fight" then
	

	end
	camera:detach()
	
	DRAW_NOTIFS()

	if Gamestate == "Game" then
		Overlay:draw()
		DRAW_HUD()
		if Intro then
			if IntroFade:get() < 50 then
				--Quest("Find a cartridge")
			end
			love.graphics.setColor( 0, 0, 0, IntroFade:get() )
			love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
			love.graphics.setColor( 255, 255, 255, 255 )
		end
	elseif Gamestate == "Intro" then
		love.graphics.setColor( 255, 255, 255, IntroObjFade:get() )
		local sx, sy = IntroTexture:getSize()
		IntroTexture:draw( love.graphics.getWidth()/2 - sx/2, (love.graphics.getHeight()-150)/2 - sy/2 )

		love.graphics.setColor( 255, 255, 255, IntroObj2Fade:get() )
		sx, sy = IntroTexture2:getSize()
		IntroTexture2:draw( love.graphics.getWidth()/2 - sx/2, (love.graphics.getHeight()-150)/2 - sy/2 )
	elseif Gamestate == "Fight" then
		FightBG:draw(0,0)
		local sx, sy = FightOpponent:getSize()
		FightOpponent:draw( love.graphics.getWidth()/4, love.graphics.getHeight()/2-sy/2 )
		local sx, sy = FightPlayer:getSize()
		FightPlayer:draw( love.graphics.getWidth()*.70, love.graphics.getHeight()/2-sy/2 )
		DRAW_HUD()
		HUDTimer:start()
		HUDFade:to(255)
		love.graphics.setFont(Fonts.Medium)
		love.graphics.printf( FightOpponentHP .. " HP", love.graphics.getWidth()/4 - 25, love.graphics.getHeight()/2-sy/2-Fonts.Medium:getHeight() + 5, sx + 50, "center")
		for i, v in pairs( table.reverse(_invslots) ) do
			if v.visible then
				v:drawItem()
			end
		end
	end

	if WeaponUI.visible then
		if SelectingFromInv then
			love.graphics.setColor( 170, 170, 170, WeaponUI.fade:get() )
			InvOverlay2:draw( love.graphics.getWidth()/2-400, love.graphics.getHeight()/2-300)
			love.graphics.setColor( 255, 255, 255 )
		else
			love.graphics.setColor( 170, 170, 170, WeaponUI.fade:get() )
			--love.graphics.rectangle( "fill", love.graphics.getWidth()/4, love.graphics.getHeight()/6, WeaponUI.w, WeaponUI.h )
			InvOverlay:draw( love.graphics.getWidth()/4, love.graphics.getHeight()/6 )
			love.graphics.setColor( 255, 255, 255 )	
		end
		for i, v in pairs( _invslots ) do
			v:draw()
		end
		for i, v in pairs( table.reverse(_invslots) ) do
			if v.visible then
				v:drawItem()
			end
		end
	end

	if Gamestate == "Editor" then
		love.graphics.setFont( Fonts.Normal )
		love.graphics.print(editor.objects[editor.selected], 5, 0)
	end
	
	Moan.draw()
	if Gamestate == "Dead" then
		DeadScreen:draw()
	elseif Gamestate == "Win" then
		WinScreen:draw()
	end
	love.graphics.setColor( 0, 0, 0, FadeState:get() )
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
	love.graphics.setColor( 255, 255, 255, 255 )
	
end

function love.keyreleased( key )
	editor.keyreleased( key )
	if key == "h" then
		print( table.serialize( player.inventory ) )
	end
	if key == "j" then
		for i, v in pairs( _objects ) do
			if v.name == "cactus" then
				print("CACTUS!")
			end
		end
	end
	if key == "tab" and not player.inInventory then
		HUDTimer:start()
		HUDFade:to(255)
	end
	if key == "e" and (Gamestate == "Game" or Gamestate == "Fight") then
		local cont = true
		if Gamestate == "Fight" then
			cont = player.isTurn
		elseif Gamestate == "Game" then
			
			cont = player.canOpenInventory
			if not HasOpenedInventory then
				player.canMove = false
				player.canOpenInventory = false
				cont = false
				Moan.clearMessages()
				Moan.new("Inventory",{
					"Your inventory is comprised of two parts: your backpack, and your PowerArm.",
					"Your PowerArm is shown by default, with its three slots. To access your backpack...",
					"...click on one of the PowerArm slots. Selecting an item from here will replace the...",
					"...items in their respective slots.",
					"When in battle, you can access your inventory by pressing \"E\".",
				},player.x,player.y,"resources/images/dialogues/help.png",
				{
					{"OK", function() HasOpenedInventory = true; player.canOpenInventory = true; love.keyreleased("e") end}
				})
			end
		end
		if cont then
			if player.inInventory then
				player.canMove = true
				Sounds["drawer_close"]:play()
				player.inInventory = false
				HIDE_WEAPONUI()
				SelectingFromInv = false
				if Gamestate == "Fight" then
					Moan.clearMessages()
					player.initiateFight()
				end
			else

				player.inInventory = true
				GENERATE_WEAPONUI(true)
				HUDTimer:stop()
				HUDTimer:reset()
				HUDFade:to(0)
				Sounds["drawer_open"]:play()
				player.canMove = false
				SHOW_WEAPONUI()
			end
		end
	end
	if key == "e" and Gamestate == "Fight" then
		Moan.showingMessage = not player.inInventory
		if not Moan.showingMessage then return end
	end
	
	Moan.keyreleased( key )
end

function love.mousepressed( x, y, button )
	editor.mousepressed( x, y, button )
end

function love.mousereleased( x, y, button )
	MRELEASED_OBJECTS( x, y )
	MRELEASED_INVSLOTS( x, y, button )
	if Gamestate == "Editor" then
		editor.mousereleased( x, y, button )
	end
end

function love.wheelmoved( x, y )
	editor.wheelmoved( x, y )
end