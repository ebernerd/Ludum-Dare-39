editor = {
	mx = 0,
	my = 0,
	objects = {},
	selected = 1,

	cxvel = 0,
	cyvel = 0,
	cspeed = 800,
	cx = 0,
	cy = 0,
	cfriction = 0.95,
	showPos = true,
}

function editor.load()
	for i, v in pairs( Objects ) do
		table.insert( editor.objects, i )
	end
	print( table.serialize( editor.objects ) )
end

function editor.checkPos( x, y )
	for i, v in pairs( _objects ) do
		if v.x == x and v.y == y then
			return true, _objects[i]
		end
	end
	return false
end

function editor.update( dt )
	local mx, my = camera:mousePosition()
	editor.mx = math.ceil( mx / 4 ) * 4 - 4
	editor.my = math.ceil( my / 4 ) * 4 - 4

	if love.keyboard.isDown("lshift") then
		editor.cspeed = 1500
	else
		editor.cspeed = 1000
	end

	local ddx, ddy = 0,0
	if love.keyboard.isDown("a") then
		ddx = -editor.cspeed * dt
	elseif love.keyboard.isDown("d") then
		ddx = editor.cspeed * dt
	end
	if love.keyboard.isDown("w") then
		ddy = -editor.cspeed * dt
	elseif love.keyboard.isDown("s") then
		ddy = editor.cspeed * dt
	end

	editor.cxvel = editor.cxvel + ddx
	editor.cyvel = editor.cyvel + ddy

	editor.cxvel = love.math.clamp( editor.cxvel, -450, 450 )
	editor.cyvel = love.math.clamp( editor.cyvel, -450, 450 )

	editor.cxvel = editor.cxvel * editor.cfriction
	editor.cyvel = editor.cyvel * editor.cfriction

	editor.cx = editor.cx + editor.cxvel*dt
	editor.cy = editor.cy + editor.cyvel*dt

	camera:lookAt(editor.cx, editor.cy)
end

function editor.draw()
	love.graphics.rectangle("line", editor.mx, editor.my, 4, 4 )
	--love.graphics.print( editor.objects[editor.selected] )
	for i, v in pairs( _objects ) do
		if v.x == editor.mx and v.y == editor.my then
			love.graphics.rectangle("line", v.x, v.y, v.w, v.h)
		end
	end
end

function editor.mousepressed( x, y, button )

end

function editor.mousereleased( x, y, button )
	if button == 1 then
		if not editor.checkPos( editor.mx, editor.my ) then
			Objects[editor.objects[editor.selected]]({x=editor.mx, y=editor.my})
			SETRENDERQUEUE()
		end
	elseif button == 2 then
		if editor.checkPos( editor.mx, editor.my ) then
			local _, obj = editor.checkPos(editor.mx, editor.my)
			obj:remove()
		end
	end
end

function editor.wheelmoved( x, y )
	if y > 0 then
		editor.selected = editor.selected + 1
		if editor.selected > #editor.objects then editor.selected = 1 end
	elseif y < 0 then
		editor.selected = editor.selected - 1
		if editor.selected < 1 then editor.selected = #editor.objects end
	end
end

function editor.keyreleased( key )
	if key == "[" then
		editor.save()
	elseif key == "q" then
		editor.showPos = not editor.showPos
	end
end

local function checkTile( savedata, x, y, name )
	for i, v in pairs( savedata ) do
		if x == v.x and y == v.y then
			if v.type == name then
				return true, "Name"
			else
				return true, "Pos", i
			end
		end
	end
	return false
end

function editor.save()
	local savedata = {}
	for i, v in pairs( _objects ) do
		--[[local ok, type, blk = checkTile( savedata, v.x, v.y, v.name )
		if ok and type == "Pos" then
			savedata[blk] = nil
			table.insert( savedata, {
				x = v.x,
				y = v.y,
				type = v.name
			})
		elseif (ok and type ~= "Name") or not ok then
			table.insert( savedata, {
				x = v.x,
				y = v.y,
				type = v.name
			})
		end--]]

		table.insert( savedata, {
			x = v.x,
			y = v.y,
			type = v.name
		})
	end
	love.filesystem.write( "world.lua", table.serialize( savedata ) )
end