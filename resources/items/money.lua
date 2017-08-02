local base = love.filesystem.load("resources/items/item.lua")()

return base:extend {
	drawable = Texture("items/money"),
	inInventory = false,
	tdp = 0,
	tooltip = "Cash",
	description = "Slick! Your wallet just got a little fatter.",
	value = 25,
	rarity = 7,
}