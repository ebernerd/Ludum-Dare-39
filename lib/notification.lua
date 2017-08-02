_notifications = {}

Notification = class {
	drawable = Texture("items/cartridge"),
	title = "Cartridge Found!",
	text = "Type: Inventory\nDescription: Expands amount of inventory slots",
	displayTimer = Timer(4),
	active = false,
	sound = Sounds["welcoming"],

	fade = soft:new(0),

	init = function( self, title, text, drawable )
		for i, v in pairs( _notifications ) do
			v:remove()
		end
		self.displayTimer = Timer(4)
		_notifications = {}
		self.title = title or self.title
		self.text = text or self.text
		self.drawable = drawable or self.drawable

		table.insert( _notifications, self )
	end,

	start = function( self )
		if not self.active then
			self.sound:play()
			self.active = true
			self.drawable:scale(15, 15)
			self.fade:to( 255 )
			player.canMove = false
		end
	end,
	update = function( self, dt )
		if self.active then
			self.fade:update( dt )
			self.displayTimer:update( dt )
			if self.displayTimer:getTime() > self.displayTimer.time-1 then
				self.fade:to(0)
				
				if self.fade:get() < 5 then
					self.active = false
					player.canMove = true
					self:remove()
					if self.onComplete then self.onComplete() end
				end
			end
		end
	end,
	draw = function( self )
		if self.active then
			
			camera:lookAt(player.x, player.y)
			love.graphics.setColor( 0, 0, 0, love.math.clamp(self.fade:get()-100, 0, 255 ) )
			love.graphics.rectangle("fill", love.graphics.getWidth()/4, love.graphics.getHeight()/4, love.graphics.getWidth()/2, love.graphics.getHeight()/2)
			love.graphics.setColor( 255, 255, 255, self.fade:get() )

			local tx, ty = self.drawable:getSize()
			self.drawable:draw( love.graphics.getWidth()/2 - tx/2, love.graphics.getHeight()/2 - ty/2 - 55 )
			love.graphics.setFont( Fonts.Big )
			love.graphics.printf( self.title, 0, love.graphics.getHeight()/2 + 35, love.graphics.getWidth(), "center" )
			love.graphics.setFont( Fonts.Normal )
			love.graphics.printf( self.text, love.graphics.getWidth()/4 + 10, love.graphics.getHeight()/2 + 80, (love.graphics.getWidth()-20)/2, "center" )

			love.graphics.setColor( 255, 255, 255, 255 )
		end
	end,
	remove = function( self )
		for i, v in pairs( _notifications ) do
			if v == self then
				print("REMOVING NOTIFICATION")
				_notifications[i] = nil
				self = nil
			end
		end
	end,
}