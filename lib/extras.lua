function love.math.clamp(low, n, high) return math.min(math.max(n, low), high) end

function SETRENDERQUEUE()
	table.sort(_objects, function(a,b) return a:getY() < b:getY() end)
end

function UPDATE_OBJECTS( dt )
	for i, v in pairs( _objects ) do
		if v.update then v:update( dt ) end
	end
end

function DRAW_OBJECTS()
	local drawPlayer = false
	for i, v in pairs( _objects ) do
		if v.alwaysBottom then
			if v.draw then v:draw() end
		end
	end
	for i, v in pairs( _objects ) do
		if player.y + player.h >= v.y and player.y <= v.y + v.h/2 and player.x + player.w >= v.x and player.x <= v.x + v.w then
			if not drawPlayer then
				player.draw()
				drawPlayer = true
			end
		end
		
		if not v.alwaysBottom then
			if v.draw then v:draw() end
		end
	end
	if not drawPlayer then player.draw() end
end

function DRAW_OBJECTS_EDITOR()
	for i, v in pairs( _objects ) do
		if v.draw then v:draw() end
		if editor.showPos then
			love.graphics.rectangle("line", v.x, v.y, 4, 4)
		end
	end
	love.graphics.rectangle("fill", player.x, player.y, player.w, player.h)
end

function DRAW_HUD()
	local alpha = HUDFade:get()
	local perc = alpha/255
	love.graphics.setScissor( 0, 0, love.graphics.getWidth(), 50 * perc )
	love.graphics.setColor( 0, 0, 0, alpha/1.5 )
	love.graphics.rectangle( "fill", 0, 0, love.graphics.getWidth(), 50 * perc )

	love.graphics.setColor( 255, 255, 255, alpha )
	love.graphics.setFont( Fonts.Normal )
	love.graphics.print( "HP:", 10, 10 )
	love.graphics.setColor( 255, 0, 0, alpha )
	love.graphics.rectangle( "line", 40, 10, 110, perc * 30 )
	love.graphics.rectangle( "fill", 45, 15, player.hp, perc * 20 )

	love.graphics.setColor( 255, 255, 255, alpha )
	love.graphics.printf( "CASH: $" .. tostring(player.cash), 0, 10, love.graphics.getWidth(), "center")

	local sx = love.graphics.getWidth() - 130
	love.graphics.setColor( 0, 148, 255, alpha )
	love.graphics.rectangle( "line", sx, 10, 110, perc * 30 )
	love.graphics.rectangle( "fill", sx+5, 15, player.charge/player.maxcharge * 100, perc * 20 )
	love.graphics.setColor( 255, 255, 255, alpha )
	love.graphics.print( "CHARGE:", sx - Fonts.Normal:getWidth("CHARGE:")-2, 10 )

	love.graphics.setScissor()
	love.graphics.setColor( 255, 255, 255 )
end

function UPDATE_TIMERS( dt )
	for i, v in pairs( _timers ) do
		if v.globalUpdate and v.update then
			v:update( dt )
		end
	end
end

function MRELEASED_OBJECTS( x, y )
	for i, v in pairs( _objects ) do
		if v.mousereleased then v:mousereleased( x, y ) end
	end
end

function SHOW_WEAPONUI()

	for i, v in pairs( _invslots ) do
		v.visible = true
	end
	WeaponUI.visible = true
	WeaponUI.fade:to(255)
end

function HIDE_WEAPONUI()
	WeaponUI.fade:to(0)
end

function GENERATE_WEAPONUI(show)
	_invslots = {}
	local w = 560
	local invw = 128
	local y = 300
	local sx = w/2 - (invw) - 15
	for i = 0, 2 do
		local slot = InvSlot( sx + (i * invw) + love.graphics.getWidth()/4, y, invw - 20, invw - 20, player.weapon[i+1] )
		slot.index = i+1
		slot.visible = show or false
	end
	
	local sx = 40 + love.graphics.getWidth()/2-400
	local sy = love.graphics.getHeight()/2-300 + 130
	w = 700
	h = 400
	rows = 3
	columns = 9
	local size = 64
	local ydist = h/(rows*size) - 15
	local counter = 0
	for i = 0, rows-1 do
		for z = 0, columns-1 do
			local slot = InvSlot( sx + (z*(size+10)) + 10, sy + ((size+55)*i) + 35, size, size, player.inventory[counter], "Inv" )
			slot.index = counter
			counter = counter + 1
		end
	end
end

function UPDATE_INVSLOTS( dt )
	for i, v in pairs( _invslots ) do
		v:update( dt )
		if math.ceil(WeaponUI.fade:get()) == 5 and player.inInventory == false then
			for i, v in pairs( _invslots ) do
				v.visible = false
			end
		end
	end
end

function MRELEASED_INVSLOTS( x, y, button )
	for i, v in pairs( _invslots ) do
		v:mousereleased( x, y, button )
	end
end

function DRAW_NOTIFS()
	for i, v in pairs( _notifications ) do
		if v.draw then v:draw() end
	end
end

function UPDATE_NOTIFS(dt)
	for i, v in pairs( _notifications ) do
		if v.update then v:update(dt) end
	end
end

function MISC_RANDOMITEM()
	local items = {}
	for i, v in pairs( Items ) do
		local rarity = v.rarity or 1
		for _=1, rarity do
			table.insert( items, i )
		end
	end
	local itemname = items[love.math.random(1,#items)]
	local item = Items[itemname]()
	if itemname == "money" then
		player.cash = love.math.random(8, 15)*10 + player.cash
	end
	return item
end