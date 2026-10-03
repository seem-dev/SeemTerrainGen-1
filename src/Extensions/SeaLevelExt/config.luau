local config = {
	Enabled = true,
	
	SeaLevel = 26, -- height of the water (from upper surface; like from a part) in world-axis.

	ExtraWater = 800, -- means: Borders + ExtraWater; Water will be filled to only the positions (not the terrain), so you need to add a little extra.

	Thickness = 20, -- simpyly the thickness of the sea

	BallRadius = 5, -- the thickness of the terrain-balls
	-- Higher = more "fluffed"
	-- lower = less "fluffed"
	-- a low ballradius, e.g. 2, will result in bad resolution (voxel connections)
}

return config
