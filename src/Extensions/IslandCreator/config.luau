local config = {
	Enabled = true,
	
	-- Minimum and Maximum Island-Height. Can also be the same to ensure the same height is used.
	MinIslandHeight = 100,
	MaxIslandHeight = 350,

	-- The size of an island (used for both x and z). Can also be the same to ensure the same size is used
	MinIslandSize = 250,
	MaxIslandSize = 350,
	
	-- The size of the map, where the islands are in (used for both x and z)
	-- note: there is no MinMapSize as there is a defined Position. See below (Position).
	MaxMapSize = 1000,
	
	-- The amount of islands generated in the map
	IslandAmout = 50,

	-- Cuts the terrain under the specific height (world-axis; not offset!)
	CutTerrainUnderHeight = 17,

	-- position (the MaxMapSize starts from here to +x & +z on world-axis)
	Position = Vector3.new(-1536, 7, -1536),

	--  -1 = random seed. Any seed above 0 (>0) is allowed otherwise.
	Seed = -1,

	Resolution = "fast", -- "smooth" (smooth, default)
	-- "ultra" (takes longer, extra smooth; sharp)
	-- "fast" (map may have gaps; good for quick results to generate in smooth in terrain later) 

	Style = "realistic", -- "realistic" (realistic, sharp, hilly)
	-- "midrealistic" (less realistic, but not unrealistic/smooth)
	-- "smooth" (really smooth, not sharp and not hilly)

	-- Prints the seed; useful when you have Resolution to fast and Seed to -1 and 
	-- then want to generate the terrain with Resolution set to smooth or ultra.
	PrintSeed = true,
	
	CallHandlingType = "Async" -- or "Sync" or "Async"
}

return config
