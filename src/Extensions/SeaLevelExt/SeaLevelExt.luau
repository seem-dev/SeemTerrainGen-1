--!strict

--============================
-- INSTANCES
--============================
local terrain = workspace.Terrain :: Terrain

--============================
-- VARIABLES
--============================
local resolution = 4 -- terrain resolution; 4 only supported now

--============================
-- MODULES
--============================
local types = require(script.Parent.Types)
local config = require(script.config)

--============================
-- LAYER-EXTENSION
--============================

local SeaLevelExt: types.Extension = {
	Enabled = config.Enabled,
	Priority = 100,
	name = "SeaLevelExt",

	Initialization = function()
		warn("[EXTENSION] SeaLevelExt Loaded")
	end,
	
	PostProcessFunction = function(params)
		local PostProcessType = params.PostProcessType
		local MapConfig = params.Config
		
		if PostProcessType == "single" then
			local TypeCheckedConfig = MapConfig :: types.MaterialsList
			
			local Pos = TypeCheckedConfig.CenterPosition
			local Size = Vector3.new(TypeCheckedConfig.Size.X, 0, TypeCheckedConfig.Size.Z)
			
			local SeaLevel = Vector3.new(0, config.SeaLevel,0 )
			
			local min = Pos
			local max = Pos + Size + SeaLevel
			
			local r3 = Region3.new(
				min,
				max
			):ExpandToGrid(resolution)
			
			terrain:FillRegion(r3, resolution, Enum.Material.Water)
		else
			local TypeCheckedConfig = MapConfig :: {types.MaterialsList}

			local BottomLeftPos = GetBottomLeftPos(TypeCheckedConfig)
			local BottomRightPos = GetBottomRightPos(TypeCheckedConfig)

			local SeaLevel = config.SeaLevel
			local ExtraWater = Vector3.new(config.ExtraWater, 0, config.ExtraWater)

			-- Just to be sure no errors are going to happen (with the region3 as min MUST be smaller than max)
			local minX = math.min(BottomLeftPos.X, BottomRightPos.X) - ExtraWater.X
			local maxX = math.max(BottomLeftPos.X, BottomRightPos.X) + ExtraWater.X

			local minZ = math.min(BottomLeftPos.Z, BottomRightPos.Z) - ExtraWater.Z
			local maxZ = math.max(BottomLeftPos.Z, BottomRightPos.Z) + ExtraWater.Z

			local maxY = SeaLevel
			local minY = maxY - config.Thickness

			local size = Vector3.new(
				maxX - minX, 
				maxY - minY, 
				maxZ - minZ
			)
			local centerPosition = Vector3.new(
				(minX + maxX) / 2, 
				(minY + maxY) / 2, 
				(minZ + maxZ) / 2
			)
			
			terrain:FillBlock(CFrame.new(centerPosition), size, Enum.Material.Water)
		end
	end,
}

--============================
-- HELPER FUNCTIONS
--============================

function GetBottomLeftPos(Configs: {types.MaterialsList})
	local minX = Configs[1].CenterPosition.X
	local minZ = Configs[1].CenterPosition.Z

	for _, v in ipairs(Configs) do
		local currentPos = v.CenterPosition
		
		if currentPos.X < minX then 
			minX = currentPos.X 
		end
		
		if currentPos.Z < minZ then 
			minZ = currentPos.Z 
		end
	end
	
	local y = GetLowestY(Configs)

	return Vector3.new(minX, y, minZ)
end

function GetBottomRightPos(Configs: {types.MaterialsList})
	local minX = Configs[1].CenterPosition.X
	local minZ = Configs[1].CenterPosition.Z

	for _, v in ipairs(Configs) do
		local currentPos = v.CenterPosition

		if currentPos.X > minX then 
			minX = currentPos.X 
		end

		if currentPos.Z > minZ then 
			minZ = currentPos.Z 
		end
	end

	local y = GetLowestY(Configs)

	return Vector3.new(minX, y, minZ)
end

function GetLowestY(Configs: {types.MaterialsList})
	local LastPos = Configs[1].CenterPosition

	for i, v in pairs(Configs) do
		local currentPos = v.CenterPosition

		if currentPos.Y < LastPos.Y then
			LastPos = currentPos
		end
	end

	return LastPos.Y
end

return SeaLevelExt
