local base = love.filesystem.load("resources/items/item.lua")()

return base:extend {
	drawable = Texture("items/cartridge_battery"),
	inInventory = false,
	tooltip = "Battery Cartridge",
	description = "When equipped, you gain +100 max charge!",
	value = 50,
	name = "battery",
	charge = 50,
	rarity = 0,
	update = function( self )
		self:basicUpdate()
		self.display = self.charge .. "% Charged!"
		self.value = 100 + self.charge
	end
}