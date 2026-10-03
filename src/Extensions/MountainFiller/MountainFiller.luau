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
-- MOUNTAIN-FILLER EXTENSION
--============================

local MountainFiller: types.Extension = {
	Enabled = config.Enabled,
	Priority = 1,
	name = "MountainFiller",
	
	Initialization = function()
		warn("[EXTENSION] MountainFiller Loaded")
	end,
	
	ThicknessFunc = function(params)
		local start = 1
		local distance = math.abs(params.Position.Y - config.FillToY)
		
		local steps = config.Steps -- positive
		
		if params.Position.Y > config.FillToY then
			-- reverse the values
			steps = -config.Steps
			start = distance
			distance = 1
		elseif params.Position.Y == config.FillToY then
			return -- return because we don't need to do any more terrain as we are on the same level.
		end
		
		local LastPos = params.Position
		for i = start, distance, steps do
			local pos = LastPos + Vector3.new(0, steps, 0)
			
			terrain:FillBall(pos, config.BallRadius, params.Material)
			
			LastPos = pos
		end
	end,
}

return MountainFiller
