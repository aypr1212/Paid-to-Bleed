export type Item = {
	Quantity: number,
}

export type Inventory = {
	[string]: Item, -- ItemId -> Item
}

export type Contract = {
	ContractId: string,
	Abilities: { string },
}

export type PlayerData = {
	Money: number,
	Inventory: Inventory,
	Race: string,
	Contracts: { Contract? }, -- up to 3
	Name: string,
	CharacterCompleted: boolean,
	Gender: string,
}

local DataTemplate: PlayerData = {
	Money = 0,
	Inventory = {
		-- Example:
		-- Sword = { Quantity = 1 },
		-- Potion = { Quantity = 5 },
	},
	Race = nil,
	Contracts = { nil, nil, nil },
	CharacterCompleted = false,
	Gender = nil,
	Name = "",
}

return DataTemplate
