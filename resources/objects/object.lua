local dist = function(x1,y1,x2,y2)
	return math.sqrt( (x2-x1)^2 + (y2-y1)^2 )
end
local base = class {
	x = 0,
	y = 0,
	w = 16,
	h = 16,

	hx = 0,
	hy = 0,
	hw = 0,
	hh = 0,

	hasColliders = true,
	colliders = {
		[1] = {
			x = 0,
			y = 8,
			w = 16,
			h = 8,
			type = "rigid",
		}
	},

	hoverable = false,
	hovered = false,

	drawable = "",

	texture = "",
	visible = true,

	init = function( self, data )

		local data = data or {}
		for i, v in pairs( data ) do
			self[i] = v or self[i]
		end

		if WORLD then
			if self.hasColliders and self.colliders then
				local cols = table.deepcopy(self.colliders)
				self.colliders = {}
				for i, v in pairs( cols ) do
					WORLD:add(v, self.x + v.x, self.y + v.y, v.w, v.h )
					table.insert( self.colliders, v )
				end
			end
		end
		table.insert( _objects, self )
	end,

	update = function( self, dt )
		if self.visible then
			if self.drawable and self.drawable.update then
				self.drawable:update( dt )
			end
			if self.hoverable and Gamestate == "Game" then
				local mx, my = camera:mousePosition()
				if mx >= self.x + self.hx and mx <= self.x + self.hx + self.hw and my >= self.y + self.hy and my <= self.y + self.hy + self.hh then
					if dist(self.x+self.hx, self.y+self.hy, player.x, player.y) < 25 then
						self.hovered = true
					else
						self.hovered = false
					end
				else
					self.hovered = false
				end
			end	
		end
	end,

	getY = function( self )
		return self.y
	end,

	remove = function( self )
		for i, v in pairs( _objects ) do
			if v == self then
				for i, v in pairs( self.colliders ) do
					if WORLD:hasItem( v ) then
						WORLD:remove(v)
					end
				end
				table.remove(_objects, i)
				self = nil
			end
		end
	end,

	draw = function( self )
		if self.visible then
			if self.drawable then
				self.drawable:draw( self.x, self.y )
				if self.hoverable and self.hovered then
					love.graphics.setColor( 255, 0, 0 )
					love.graphics.rectangle("line", self.x+self.hx, self.y+self.hy, self.hw, self.hh)
					love.graphics.setColor( 255, 255, 255 )
				end
			end
		end
	end,
	mousereleased = function( self, x, y )
		local mx, my = camera:mousePosition()
		if self.clickable and Gamestate == "Game" and player.canMove then
			if mx >= self.x + self.hx and mx <= self.x + self.hx + self.hw and my >= self.y + self.hy and my <= self.y + self.hy + self.hh then
				if dist(self.x+self.hx, self.y+self.hy, player.x, player.y) < 25 then
					if self.onClick then self:onClick() end
				end
			end
		end
	end
}
base.baseInit = base.init
return base