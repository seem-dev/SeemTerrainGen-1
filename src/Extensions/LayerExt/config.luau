local config = {
	Enabled = true,
	
	Layers = 2, -- The amount of layers; note: The initial layer is not counted into the Layer, meaning the actual amount of layers would be Layers + 1
	Distance = 50, -- the distance between the layers. 
	direction = "up", -- "up" or "down"
			   
	BallRadius = 5, -- the thickness of the terrain-balls
				   -- Higher = more "fluffed"
				   -- lower = less "fluffed"
				   -- a low ballradius, e.g. 2, will result in bad resolutin (connections)
}

return config
