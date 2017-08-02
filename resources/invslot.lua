_invslots = {}

local TYPE = type

InvSlot = class {

	x = 0,
	y = 0,
	w = 0,
	h = 0,

	hovered = false,
	type = "Weapon",
	visible = false,
	background = { 225, 225, 225 },

	item = "",

	init = function( self, x, y, w, h, item, type )
		self.x = x or self.x
		self.y = y or self.y
		self.w = w or self.w
		self.h = h or self.h
		if item then
			self.item = item
			if TYPE(self.item) ~= "string" then
				self.item.x = self.x
				self.item.y = self.y
			end
		end
		self.type = type or "Weapon"
		table.insert( _invslots, self )
	end,

	update = function( self, dt )
		if self.type == "Inv" then self.visible = (SelectingFromInv or SelectingFromStore) end
		if self.visible then
			local mx, my = love.mouse.getPosition()
			if self.item and TYPE(self.item)~="string" then
				self.item:update( dt )
			end
			if mx >= self.x and mx <= self.x + self.w and my >= self.y and my <= self.y + self.h then
				self.hovered = true
			else
				self.hovered = false
			end
		end
	end,
	drawInternal = function( self )
		local bg = self.background
		if self.hovered then
			bg = {
				love.math.clamp( bg[1] + 25, 0, 255 ),
				love.math.clamp( bg[2] + 25, 0, 255 ),
				love.math.clamp( bg[3] + 25, 0, 255 )
			}
		end
		bg[4] = love.math.clamp(WeaponUI.fade:get()-75, 0, 255)
		--print( table.serialize( bg ) )
		love.graphics.setColor( unpack(bg) )
		love.graphics.rectangle( "fill", self.x, self.y, self.w, self.h )
		love.graphics.setColor( 255, 255, 255 )
		love.graphics.setColor( 64, 64, 64, bg[4] )
		if self.type == "Weapon" then
			love.graphics.setFont( Fonts.Normal )
		elseif self.type == "Inv" then
			love.graphics.setFont( Fonts.Tiny )
		end
		love.graphics.printf(self.item.tooltip or "Empty", self.x, self.y + self.h, self.w, "center")
		love.graphics.setColor( 255, 255, 255, bg[4] )
		
		bg = nil
		love.graphics.setColor( 255, 255, 255 )
	end,
	drawItem = function( self )
		local bg = self.background
		if self.hovered then
			bg = {
				love.math.clamp( bg[1] + 25, 0, 255 ),
				love.math.clamp( bg[2] + 25, 0, 255 ),
				love.math.clamp( bg[3] + 25, 0, 255 )
			}
		end
		bg[4] = love.math.clamp(WeaponUI.fade:get()-75, 0, 255)
		love.graphics.setColor( bg )
		if self.item and self.item.draw then
			if self.type == "Weapon" and not SelectingFromInv then
				self.item:draw( self.w/16 )
			elseif self.type == "Inv" and SelectingFromInv then
				self.item:draw( self.w/16 )
			end
		end	
		love.graphics.setColor( 255, 255, 255 )
	end,
	draw = function( self )
		if self.visible then
			if self.type == "Weapon" and not SelectingFromInv then
				self:drawInternal()
			elseif self.type == "Inv" then
				if SelectingFromInv or SelectingFromStore then
					self:drawInternal()
				end
			end
		end
	end,
	mousereleased = function( self, mx, my, button )
		if self.visible and mx >= self.x and mx <= self.x + self.w and my >= self.y and my <= self.y + self.h then
			if button == 1 then
				if self.type == "Weapon" then
					if not SelectingFromInv then
						SelectingFromInv = true
						SelectorFromInv = self
						
					end
				else
					if SelectingFromInv then
						SelectingFromInv = false
						for i, v in pairs( _invslots ) do
							
							SelectingFromInv = false
							if v == SelectorFromInv then
								local preitem = self.item
								if v.item and TYPE(v.item) ~= "string" then
									self.item = v.item
									self.item.x = self.x
									self.item.y = self.y
								else
									self.item = nil
								end
								v.item = self.item or nil
								if type(v.item) == "table" then
									v.item.x = v.x
									v.item.y = v.y
								end
								player.weapon[v.index] = preitem
								Sounds.popout:play()
							end
							player.inventory[self.index] = self.item
							
						end
						
						GENERATE_WEAPONUI(true)
						self.visible = false
					elseif SelectingFromStore then
						--
					end
				end
			elseif button == 2 and self.type == "Weapon" then
				if self.item and type(self.item) ~= "string" then
					table.insert( player.inventory, self.item )
					self.item = nil
					player.weapon[self.index] = nil
					GENERATE_WEAPONUI(true)
					Sounds.popout:play()
				end
			end
		end
	end,
}