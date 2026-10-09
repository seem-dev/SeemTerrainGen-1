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
local TableLib = require(script.Parent.dependencies.TableLib)

--============================
-- MOUNTAIN-CREATOR EXTENSION
--============================

local IslandCreator: types.Extension = {
	Enabled = config.Enabled,
	Priority = 1,
	name = "IslandCreator",

	Initialization = function()
		warn("[EXTENSION] IslandCreator Loaded")
	end,

	PointSkipControl = function(params)
		local pos, mat = params.Position, params.Material

		if pos.Y <= config.CutTerrainUnderHeight then
			return true
		else 
			return false
		end

		--warn("called and returned: "..tostring(true))

		--return true
	end,

	MainGenerationCallControl = function(params)
		local function GenerateIsland(Position: Vector3, IslandSeed: number)
			local ConfiguredBallRadius = GetBallRadius()
			local ConfiguredSeed = IslandSeed
			local ConfiguredSize = GetSize()
			local ConfiguredHeight = GetHeight()
			local ConfiguredSteps = GetSteps(ConfiguredHeight)
			local ConfiguredOctaves = GetOctaves()
			local ConfiguredNoise = GetNoise(ConfiguredSize)
			local ConfiguredCornerRadius = GetCornerRadius(ConfiguredSize)

			--warn("------------")
			--warn("SIZE: "..tostring(ConfiguredSize))
			--warn("POSITION: "..tostring(Position))
			
			local MapConfig: types.MaterialsList = TableLib.DeepCopy(params.Config) -- ignore this warn
			
			MapConfig.BallRadius = ConfiguredBallRadius
			MapConfig.Steps = ConfiguredSteps
			MapConfig.CenterPosition = Position
			MapConfig.Seed = ConfiguredSeed
			MapConfig.Size = Vector3.new(ConfiguredSize, 0, ConfiguredSize)

			MapConfig.InstDistributionScale = 0.8
			MapConfig.InstDistributionSeed = 242143
			MapConfig.InstDistributionLength = 1

			MapConfig.InstancingSteps = 50
			MapConfig.InstancingSeed = 9923

			MapConfig.instNoiseScale = 0.8
			MapConfig.instNoiseLength = 30
			MapConfig.instNoiseSeed = 29434

			MapConfig.Falloff = {
				Enabled = true,
				Start = 0,
				Strength = 1,
				Interpolation = "smoothstep",
				CornerRadius = ConfiguredCornerRadius, -- 300 to create a circular shape
				FalloffRadius = nil,
				FallOffAxis = "XZ",
				Reversed = false
			}

			MapConfig.Thickness = {
				ThicknessNumber = 0,
				Direction = "down",
				Steps = 1,
				Power = 5
			}

			MapConfig.MaterialNoiseScale = 0.0004
			MapConfig.MaterialNoiseStrength = 1
			MapConfig.MaterialNoiseSeed = 2

			-- Dynamic Parameter Blending
			MapConfig.Amplitudes = {ConfiguredHeight}
			MapConfig.NoiseScales = {ConfiguredNoise}
			MapConfig.Powers = {4.5}

			MapConfig.lacunarities = {2}
			MapConfig.gains = {0.5}

			MapConfig.RandomOctaveSeed = false
			MapConfig.Octaves = ConfiguredOctaves

			MapConfig.MaterialsList = {
				{
					BiomeName = "Plains_Flowers_Pink",
					Threshold = 1,
					FallbackMaterial = Enum.Material.CrackedLava,

					Layers = {
						["-1000 to 35"] = {
							SameMaterialLevelNoiseScale = 0.05,
							SameMaterialLevelNoiseLength = 1,
							SameMaterialLevelNoiseSeed = 3123,

							InnerMaterialNoiseScale = 0.01,
							InnerMaterialNoiseSeed = 123,
							InnerMaterialNoiseStrength = 1,

							List = {
								{
									Threshold = 0.7,
									Material = Enum.Material.Sand
								},
								{
									Threshold = 0.8,
									Material = Enum.Material.Rock
								},
								{
									Threshold = 1.0,
									Material = Enum.Material.Grass
								}
							}

						},
						["35 to 53"] = {
							SameMaterialLevelNoiseScale = 0.8,
							SameMaterialLevelNoiseLength = 1,
							SameMaterialLevelNoiseSeed = 3123,

							InnerMaterialNoiseScale = 0.01,
							InnerMaterialNoiseSeed = 123,
							InnerMaterialNoiseStrength = 1,

							List = {
								{
									Threshold = 0.1,
									Material = Enum.Material.Mud
								},
								{
									Threshold = 0.6,
									Material = Enum.Material.Grass
								},
								{
									Threshold = 0.7,
									Material = Enum.Material.LeafyGrass,
									Instancing = {
										{
											Threshold = 1,
											Instances = {

												{
													Threshold = 0.333,
													Instance = workspace.FlowerBush1,
													MaxSlope = 30, -- 10
													MaxHeight = 53, -- 30
													Offset = -1,
													FaceNormal = false,

													MinRandomRotations = {
														x = -5,
														y = -360,
														z = -5
													},

													MaxRandomRotations = {
														x = 5,
														y = 360,
														z = 5
													},

													MinRandomScale = 0.8,
													MaxRandomScale = 1.2
												},
												{
													Threshold = 0.66,
													Instance = workspace.FlowerBush2,
													MaxSlope = 30, -- 10
													MaxHeight = 53, -- 30
													Offset = -1,
													FaceNormal = false,

													MinRandomRotations = {
														x = -5,
														y = -360,
														z = -5
													},

													MaxRandomRotations = {
														x = 5,
														y = 360,
														z = 5
													},

													MinRandomScale = 0.8,
													MaxRandomScale = 1.2
												},
												{
													Threshold = 1,
													Instance = workspace.FlowerBush2,
													MaxSlope = 30, -- 10
													MaxHeight = 53, -- 30
													Offset = -1,
													FaceNormal = false,

													MinRandomRotations = {
														x = -5,
														y = -360,
														z = -5
													},

													MaxRandomRotations = {
														x = 5,
														y = 360,
														z = 5
													},

													MinRandomScale = 0.8,
													MaxRandomScale = 1.2
												}
											}
										}
									}
								},
								{
									Threshold = 0.8,
									Material = Enum.Material.Rock
								},
								{
									Threshold = 1.0,
									Material = Enum.Material.Grass
								}
							}

						},
						["53 to 139"] = {
							SameMaterialLevelNoiseScale = 0.8,
							SameMaterialLevelNoiseLength = 1,
							SameMaterialLevelNoiseSeed = 3123,

							InnerMaterialNoiseScale = 0.03,
							InnerMaterialNoiseSeed = 123,
							InnerMaterialNoiseStrength = 1,

							-- it's not like you are going to know each other till your death.

							List = {
								{
									Threshold = 0.3,
									Material = Enum.Material.Grass,
								},
								{
									Threshold = 0.4,
									Material = Enum.Material.LeafyGrass,
								},
								{
									Threshold = .8,
									Material = Enum.Material.Rock
								},
								{
									Threshold = 1,
									Material = Enum.Material.Mud
								}
							}

						},
						["139 to 167"] = {
							SameMaterialLevelNoiseScale = 0.8,
							SameMaterialLevelNoiseLength = 1,
							SameMaterialLevelNoiseSeed = 3123,

							InnerMaterialNoiseScale = 0.03,
							InnerMaterialNoiseSeed = 123,
							InnerMaterialNoiseStrength = 1,

							-- it's not like you are going to know each other till your death.

							List = {
								{
									Threshold = 0.3,
									Material = Enum.Material.Snow,
								},
								{
									Threshold = 0.4,
									Material = Enum.Material.LeafyGrass,
								},
								{
									Threshold = .8,
									Material = Enum.Material.Rock
								},
								{
									Threshold = 1,
									Material = Enum.Material.Snow
								}
							}

						},
						["167 to 10000"] = {
							SameMaterialLevelNoiseScale = 0.8,
							SameMaterialLevelNoiseLength = 1,
							SameMaterialLevelNoiseSeed = 3123,

							InnerMaterialNoiseScale = 0.03,
							InnerMaterialNoiseSeed = 123,
							InnerMaterialNoiseStrength = 1,


							List = {
								{
									Threshold = 0.8,
									Material = Enum.Material.Snow,
								},
								{
									Threshold = 1,
									Material = Enum.Material.Rock,
								}
							}

						},

					},

					LayerNoiseScale = 0.8,
					LayerNoiseLength = 30,

					BiomNoiseLength = 20,
					BiomNoiseScale = 0.8,
				},
			}

			MapConfig.BatchingEnabled = true
			MapConfig.BatchTime = 0.02
			MapConfig.BatchWait = 0.03

			MapConfig.WaitDuration = 0.03
			
			return MapConfig
		end
		
		local IslandConfigs = {}
		
		local ConfiguredSeed = GetSeed()
		
		-- create a seed by using 1d noise. Then +0.5 to move the range to 0-1 and not -0.5 to 0.5 (roblox math.noise default).
		-- We also do config.Seed + 1 so the positions are actually different and not on the same. But this is an offset so the seed-system will always work.
		local LastSeedX = ConfiguredSeed + 5000 
		local LastSeedZ = ConfiguredSeed + 15000
		
		for i = 1, config.IslandAmout do
			--[[
			Remember: perlin noise with numbers which are close to each other
			will also give results which are close to each other.
			That's why we go with such a big step (+50 for x, +100 for z).
			Besides that, we don't want the x and z be close, so we have a space of 50 between each other (x & z).
			]]
			local Frequency = 0.8 -- frequency to ensure we have no absolute numbers (absolute numbers won't work in perlin noise; return 0 or same number). 0.8 to ensure the results of the nosie are really different(0.1 would be really close to each other).
			local OneDimensionalNoiseX = math.noise((LastSeedX + 5000) * Frequency) + 0.5
			local OneDimensionalNoiseZ = math.noise((LastSeedZ + 15000) * Frequency) + 0.5
			
			--warn("NOISE X: "..tostring(OneDimensionalNoiseX))
			--warn("NOISE Z: "..tostring(OneDimensionalNoiseZ))
			
			local ConfiguredSizeX = config.MaxMapSize * OneDimensionalNoiseX
			local ConfiguredSizeZ = config.MaxMapSize * OneDimensionalNoiseZ
			
			local RandomPosition = config.Position + Vector3.new(
				ConfiguredSizeX,
				0,
				ConfiguredSizeZ
			)
			
			local GeneratedIslandConfig = GenerateIsland(RandomPosition, ConfiguredSeed + 5000)
			
			table.insert(IslandConfigs, GeneratedIslandConfig)
			
			-- update LastSeeds. Explanation above.
			LastSeedX += 5000
			LastSeedZ += 15000
			
			LastSeedX *= Frequency
			LastSeedZ *= Frequency
		end
		
		return {
			IslandConfigs = IslandConfigs,
			CallHandlingData = {Type = config.CallHandlingType, WaitAmount = 0.1} 
		}
	end,
}

--============================
-- HELPER FUNCTIONS
--============================

function GetBallRadius()
	local resolutions = {
		smooth = 5,
		ultra = 3,
		fast = 5
	}

	return resolutions[config.Resolution]
end

function GetCornerRadius(IslandSize: number)
	return IslandSize / 2
end

function GetSteps(Height: number)
	local resolutions = {
		smooth = 3,
		ultra = 1,
		fast = 5
	}

	local ConfiguredResolution = resolutions[config.Resolution] :: number

	if Height >= 0 and Height < 500 then
		ConfiguredResolution -= 0.35
	elseif Height >= 500 and Height < 1500 then
		ConfiguredResolution -= 0.7
	elseif Height >= 1500 and Height < 2000 then
		ConfiguredResolution -= 1.3
	elseif Height >= 2000 and Height < 2500 then
		ConfiguredResolution -= 1.9
	elseif Height >= 2500 and Height < 3000 then
		ConfiguredResolution -= 2.5
	elseif Height >= 3000 and Height < 3500 then
		ConfiguredResolution -= 2.9
	end

	ConfiguredResolution = math.clamp(ConfiguredResolution, 1, 10)

	return ConfiguredResolution 
end

function GetSeed()
	local ConfiguredSeed = config.Seed
	
	if config.Seed == -1 then
		ConfiguredSeed = math.random(1, 10000)
	else 
		ConfiguredSeed = config.Seed
	end
	
	if config.PrintSeed then
		warn("[IslandCreator] Seed: "..ConfiguredSeed)
	end
	
	return ConfiguredSeed
end

function GetHeight()
	return math.random(config.MinIslandHeight, config.MaxIslandHeight)
end

function GetSize()
	return math.random(config.MinIslandSize, config.MaxIslandSize)
end

function GetNoise(Size: number)
	if Size >= 0 and Size <= 500 then
		return 0.003
	elseif Size >= 500 and Size <= 1000 then
		return 0.001
	elseif Size >= 1000 and Size <= 1500 then
		return 0.0003
	elseif Size >= 1500 and Size <= 2000 then
		return 0.0001
	elseif Size >= 2000 and Size <= 2500 then
		return 0.00003
	elseif Size >= 2500 and Size <= 3000 then
		return 0.00001
	elseif Size >= 3000 and Size <= 3500 then
		return 0.000003
	else 
		return 0.0001
	end
end

function GetOctaves()
	local styles = {
		realistic = 15,
		midrealistic = 5,
		smooth = 1
	}

	return styles[config.Style]
end

return IslandCreator
