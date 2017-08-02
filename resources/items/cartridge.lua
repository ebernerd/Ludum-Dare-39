local base = love.filesystem.load("resources/items/item.lua")()

return base:extend {
	drawable = Texture("items/cartridge"),
	inInventory = false,
	tdp = 0,
	tooltip = "Blank Cartridge",
	description = "Bring this to a FalCorp store to have information written to it!",
	value = 25,
	rarity = 0,
}