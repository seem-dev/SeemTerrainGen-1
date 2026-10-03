local config = {
	Enabled = true,
	
	FillToY = 23, -- the height (world axis Y) to fill to
	
	Steps = 5, -- the distance between the terrain-balls. 
			   -- Higher = faster, but worse resolution
			   -- lower = slower, but better resolution
	BallRadius = 5 -- the thickness of the terrain-balls
				   -- Higher = more "fluffed"
				   -- lower = less "fluffed"
				   -- a low ballradius with a big step-value will result in bad resolution (e.g. Ballradius = 2, Steps = 7)
}

return config
