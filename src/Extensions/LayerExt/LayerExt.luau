--!strict

--============================
-- INSTANCES
--============================
local terrain = workspace.Terrain :: Terrain

--============================
-- MODULES
--============================
local types = require(script.Parent.Types)
local config = require(script.config)

--============================
-- LAYER-EXTENSION
--============================

local LayerExt: types.Extension = {
	Enabled = config.Enabled,
	Priority = 2, -- run after main-thickness extensions like MountainFiller
	name = "LayerExt",
	
	Initialization = function()
		warn("[EXTENSION] LayerExt Loaded")
	end,
	
	ThicknessFunc = function(params)
		for i = 1, config.Layers do
			
			local pos = params.Position + Vector3.new(0, i * config.Distance)
			
			if config.direction == "down" then
				pos = params.Position - Vector3.new(0, i * config.Distance)
			end
			
			terrain:FillBall(pos, config.BallRadius, params.Material)
			
			
		end
	end,
}

return LayerExt
