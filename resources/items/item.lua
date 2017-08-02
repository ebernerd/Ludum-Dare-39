local item = class {
	name = "Item",
	description = "A stock item; no real information or use.",

	x = 0,
	y = 0,

	drawable = Texture("noTexture.png"),
	visible = false,

	hovered = false,
	clicked = false,

	inInventory = false,
	
	init = function( self, data )
		local data = data or {}
		for i, v in pairs( data ) do
			self[i] = v or self[i]
		end

		self.sx, self.sy = self.drawable:getSize()
	end,
	draw = function( self, scale )
		self.drawable:scale( scale, scale )
		self.sx, self.sy = self.drawable:getSize()
		local sx, sy = self.drawable:getSize()
		self.drawable:draw( self.x, self.y )
		if self.hovered then
			if self.display then
				local mx, my = love.mouse.getPosition()
				local w, h = 150, Fonts.Normal:getHeight()+5
				love.graphics.setColor( 30, 30, 30 )
				love.graphics.rectangle("fill", mx, my, w, h )
				love.graphics.setColor( 255, 255, 255 )
				love.graphics.setFont( Fonts.Normal )
				love.graphics.printf(self.display, mx, my, w, "center")
			end
		end
	end,
	update = function( self, dt )
		--if self.visible then
			local mousex, mousey = love.mouse.getPosition()
			if mousex >= self.x and mousex <= self.x + self.sx and mousey >= self.y and mousey <= self.y + self.sy then
				self.hovered = true
			else
				self.hovered = false
			end
		--end
	end,
	mousepressed = function( self, x, y, button )
		if self.visible then
			if self.inInventory then

			end
		end
	end,
}
item.basicUpdate = item.update
return item