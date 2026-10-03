local config = {
	Enabled = true,
	
	-- Minimum and Maximum Height. Can also be the same to ensure the same size is used.
	MinHeight = 1500,
	MaxHeight = 2500,
	
	-- The size of the map (used for both x and z)
	MinSize = 500,
	MaxSize = 500,
	
	-- Cuts the terrain under the specific height (world-axis; not offset!)
	CutTerrainUnderHeight = 0,
	
	Position = Vector3.new(-1536, 7, -1536), -- position
	
	Seed = 4184, -- -1 = random seed. Any seed above 0 (>0) is allowed otherwise.
	
	Resolution = "smooth", -- "smooth" (smooth, default)
						   -- "ultra" (takes longer, extra smooth; sharp)
						   -- "fast" (map may have gaps; good for quick results to generate in smooth in terrain later) 
			   
	Style = "realistic", -- "realistic" (realistic, sharp, hilly)
						 -- "midrealistic" (less realistic, but not unrealistic/smooth)
						 -- "smooth" (really smooth, not sharp and not hilly)
	
	-- Prints the seed; useful when you have Resolution to fast and Seed to -1 and then want to generate the terrain with Resolution set to smooth or ultra.
	PrintSeed = true,	
}

return config
