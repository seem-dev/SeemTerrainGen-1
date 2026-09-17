--!strict

--[[
This module is used to make scripts more organized by putting functions here.
It just looks cleaner in the MainScript (SeemTerrainGen-1) and make changes/updates easier.
]]

local SeemTerrainGen_1_Utils = {}

--============================
-- INSTANCES
--============================
local terrain = workspace.Terrain

--============================
-- FOLDERS
--============================
local MathHelp = script.Parent.MathHelp

--============================
-- MODULES
--============================
local Types = require("./Types")
local Formulas = require(MathHelp.Formulas)
local TableLib = require("./TableLib")

--============================
-- VARIABLES BEING DECLARED BY SeemTerrainGen-1
--============================
SeemTerrainGen_1_Utils.MaterialNoiseScale = 0
SeemTerrainGen_1_Utils.MaterialNoiseSeed = 0
SeemTerrainGen_1_Utils.MaterialNoiseStrength = 0
SeemTerrainGen_1_Utils.Seed = 0

--============================
-- HELPER FUNCTIONS
--============================
function GetBottomLeftPositionOfPart(part: BasePart)
	local BottomLeftPosition = nil;

	BottomLeftPosition = part.Position - Vector3.new(
		part.Size.X / 2,
		0,
		part.Size.Z / 2
	);

	return BottomLeftPosition;
end

--============================
-- SETTINGS
--============================
-- These are the fallback/default Materials that are used in SeemTerrainGen_1_Utils.GetValues
local STG_1_Settings: Types.STG_1_Settings = { -- DeadMountainIsland Map
	BallRadius = 5,
	CenterPosition = Vector3.new(-512, 7, -512),
	Size = Vector3.new(1024, 0, 1024),
	Seed = 2934,

	InstDistributionScale = 0.8,
	InstDistributionSeed = 242143,
	InstDistributionLength = 1,

	InstancingSteps = 60,
	InstancingSeed = 249,

	instNoiseScale = 0.8,
	instNoiseLength = 300,
	instNoiseSeed = 29434,

	Falloff = {
		Enabled = true,
		Start = 0,
		Strength = 1,
		Interpolation = "smoothstep",
		CornerRadius = 500,
		FalloffRadius = 0,
		FallOffAxis = "XZ",
		Reversed = false
	},

	Thickness = {
		ThicknessNumber = 1,
		Direction = "down",
		Steps = 1,
		Power = 5
	},

	MaterialNoiseScale = 0.0004,
	MaterialNoiseStrength = 1,
	MaterialNoiseSeed = 2,

	-- Dynamic Parameter Blending
	Amplitudes = {1000},
	NoiseScales = {0.0005},
	Powers = {4},

	lacunarities = {2.1},
	gains = {0.9},

	RandomOctaveSeed = false,
	Octaves = 5,

	MaterialsList = {
		{
			BiomeName = "DeadMountainIsland",
			Threshold = 1,
			FallbackMaterial = Enum.Material.CrackedLava,

			Layers = {
				["-1000 to 53"] = {
					SameMaterialLevelNoiseScale = 0.8,
					SameMaterialLevelNoiseLength = 1,
					SameMaterialLevelNoiseSeed = 3123,

					InnerMaterialNoiseScale = 0.8,
					InnerMaterialNoiseSeed = 123,
					InnerMaterialNoiseStrength = 1,

					List = {
						{
							Threshold = 0.7,
							Material = Enum.Material.Grass,
						},
						{
							Threshold = .8,
							Material = Enum.Material.LeafyGrass
						},
						{
							Threshold = .9,
							Material = Enum.Material.Grass
						},
						{
							Threshold = .95,
							Material = Enum.Material.Rock
						},
						{
							Threshold = 1,
							Material = Enum.Material.Mud
						}
					}

				},
				["53 to 214"] = {
					SameMaterialLevelNoiseScale = 0.1,
					SameMaterialLevelNoiseLength = 1,
					SameMaterialLevelNoiseSeed = 3123,

					InnerMaterialNoiseScale = 0.1,
					InnerMaterialNoiseSeed = 123,
					InnerMaterialNoiseStrength = 1,

					-- it's not like you are going to know each other till your death.

					List = {
						{
							Threshold = 1,
							Material = Enum.Material.Rock
						},
					}

				},
				["214 to 1000"] = {
					SameMaterialLevelNoiseScale = 0.8,
					SameMaterialLevelNoiseLength = 1,
					SameMaterialLevelNoiseSeed = 3123,

					InnerMaterialNoiseScale = 0.8,
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
			LayerNoiseLength = 100,

			BiomNoiseLength = 20,
			BiomNoiseScale = 0.8,
		},


	},

	BatchingEnabled = true,
	BatchTime = 0.02,
	BatchWait = 0.03,

	WaitDuration = 0.03,
	Steps = 3,
	
	-- BIOME FALLBACKS
	BiomNoiseScale = 0,
	BiomNoiseLength = 0,
	
	-- LAYER FALLBACKS
	LayerNoiseScale = 0.08,
	LayerNoiseLength = 30,
	
	-- INNER-MATERIAL FALLBACKS
	InnerMaterialNoiseScale = 0.01,
	InnerMaterialNoiseSeed = 123,
	InnerMaterialNoiseStrength = 1,
	
	-- SAME-MATERIAL-LEVEL FALLBACKS
	SameMaterialLevelNoiseScale = 0.8,
	SameMaterialLevelNoiseLength = 1,
	SameMaterialLevelNoiseSeed = 2132,
	
	-- SINGLE-INST-TBL FALLBACKS
	MaxHeight = 10000,
	MaxSlope = 30,
	Offset = 0,
	FaceNormal = false,
	MinRandomRotations = {
		x = -10,
		y = -10,
		z = -10
	},
	MaxRandomRotations = {
		x = 10,
		y = 10,
		z = 10
	},
	MinRandomScale = 0.75,
	MaxRandomScale = 1.25
}

--============================
-- SETUP FUNCTIONS
--============================

--[[
 Gets the (Finalized-)Values from the MaterialList with fallbacks. Returns a Table containing those values.
 Does not finalize the Dynamic Values like gains and amplitudes.
 This means, that the Materials - values remain. The finalized Values are just being added or replaced.
]]
function SeemTerrainGen_1_Utils.GetFinalizedValues(
	Materials: Types.MaterialsList
): Types.FinalizedValues

	local Values = {}

	-- static values (fallbacks applied)
	Values.CenterPosition = Materials.CenterPosition or STG_1_Settings.CenterPosition
	Values.Size = Materials.Size or STG_1_Settings.Size
	Values.WaitDuration = Materials.WaitDuration or STG_1_Settings.WaitDuration
	Values.Steps = Materials.Steps or STG_1_Settings.Steps
	Values.Seed = Materials.Seed or STG_1_Settings.Seed
	Values.Octaves = Materials.Octaves or STG_1_Settings.Octaves
	Values.BallRadius = Materials.BallRadius or STG_1_Settings.BallRadius

	Values.RandomOctaveSeed = Materials.RandomOctaveSeed or STG_1_Settings.RandomOctaveSeed

	Values.InstancingSteps = Materials.InstancingSteps or STG_1_Settings.InstancingSteps
	Values.instNoiseScale = Materials.instNoiseScale or STG_1_Settings.instNoiseScale
	Values.instNoiseLength = Materials.instNoiseLength or STG_1_Settings.instNoiseLength -- studs
	Values.instNoiseSeed = Materials.instNoiseSeed or STG_1_Settings.instNoiseSeed
	
	Values.InstDistributionScale = Materials.InstDistributionScale or STG_1_Settings.InstDistributionScale
	Values.InstDistributionSeed = Materials.InstDistributionSeed or STG_1_Settings.InstDistributionSeed
	Values.InstDistributionLength = Materials.InstDistributionLength or STG_1_Settings.InstDistributionLength

	Values.BatchingEnabled = Materials.BatchingEnabled or STG_1_Settings.BatchingEnabled
	Values.BatchTime = Materials.BatchTime or STG_1_Settings.BatchTime
	Values.BatchWait = Materials.BatchWait or STG_1_Settings.BatchWait

	Values.Falloff = Materials.Falloff or STG_1_Settings.Falloff
	Values.Thickness = Materials.Thickness or STG_1_Settings.Thickness

	Values.MaterialNoiseScale = Materials.MaterialNoiseScale or STG_1_Settings.MaterialNoiseScale
	Values.MaterialNoiseSeed = Materials.MaterialNoiseSeed or STG_1_Settings.MaterialNoiseSeed
	Values.MaterialNoiseStrength = Materials.MaterialNoiseStrength or STG_1_Settings.MaterialNoiseStrength
	
	return Values :: Types.FinalizedValues
end

--[[
Applies the FinalizedValues (created via SeemTerrainGen_1_Utils.GetFinalizedValues) to SeemTerrainGen_1_Utils
so other SeemTerrainGen_1_Utils using keys in SeemTerrainGen_1_Utils can be used.
]]
function SeemTerrainGen_1_Utils.Setup_STG_1_Utils(
	FinalizedValues: Types.FinalizedValues
)
	SeemTerrainGen_1_Utils.MaterialNoiseScale = FinalizedValues.MaterialNoiseScale
	SeemTerrainGen_1_Utils.MaterialNoiseStrength = FinalizedValues.MaterialNoiseStrength
	SeemTerrainGen_1_Utils.MaterialNoiseSeed = FinalizedValues.MaterialNoiseSeed
	SeemTerrainGen_1_Utils.Seed = FinalizedValues.Seed
end

--============================
-- NOISE FUNCTIONS
--============================

-- Gets the MaterialNoise out of the worldX and worldZ
function SeemTerrainGen_1_Utils.GetMaterialNoise(
	worldX: number,
	worldZ: number
)
	local MaterialNoise = math.noise(
		worldX * SeemTerrainGen_1_Utils.MaterialNoiseScale,
		worldZ * SeemTerrainGen_1_Utils.MaterialNoiseScale,
		SeemTerrainGen_1_Utils.Seed + SeemTerrainGen_1_Utils.MaterialNoiseSeed
	) * SeemTerrainGen_1_Utils.MaterialNoiseStrength
	MaterialNoise = MaterialNoise + (0.5 * SeemTerrainGen_1_Utils.MaterialNoiseStrength)
	MaterialNoise = math.clamp(MaterialNoise, 0, 1)
	
	return MaterialNoise
end

-- Gets the SingleInstNoise by using the worldX and worldZ
function SeemTerrainGen_1_Utils.GetSingleInstNoise(
	FinalizedValues: Types.FinalizedValues,
	worldX: number,
	worldZ: number
)
	local SingleInstNoise = math.noise(worldX * FinalizedValues.InstDistributionScale, worldZ * FinalizedValues.InstDistributionScale, FinalizedValues.Seed + FinalizedValues.InstDistributionSeed) * FinalizedValues.InstDistributionLength
	SingleInstNoise = SingleInstNoise + (0.5 * FinalizedValues.InstDistributionLength)
	SingleInstNoise = math.clamp(SingleInstNoise, 0, 1)
	
	return SingleInstNoise
end

-- Gets the instNoise by using the worldX and worldZ
function SeemTerrainGen_1_Utils.GetInstNoise(
	FinalizedValues: Types.FinalizedValues,
	worldX: number,
	worldZ: number
)
	local instNoise = math.noise(
		worldX * FinalizedValues.instNoiseScale, 
		worldZ * FinalizedValues.instNoiseScale, 
		FinalizedValues.Seed + FinalizedValues.instNoiseSeed
	) * FinalizedValues.instNoiseLength

	return instNoise
end

--[[
Get the dynamic values of the FinalizedValues (created via SeemTerrainGen_1_Utils.GetFinalizedValues).
Does apply fallbacks (if value is not defined).
]]
function SeemTerrainGen_1_Utils.GetFinalizedDynamicValues(
	FinalizedValues: Types.MaterialsList, -- result of SeemTerrainGen_1_Utils.GetFinalizedValues
	MaterialNoise: number -- result of SeemTerrainGen_1_Utils.GetMaterialNoise
): Types.DynamicValues
	local DynamicValues = {}
	
	-- fallbacks
	local finalizedNoiseScale = FinalizedValues.NoiseScales or STG_1_Settings.NoiseScales
	local finalizedAmplitude = FinalizedValues.Amplitudes or STG_1_Settings.Amplitudes
	local finalizedPower = FinalizedValues.Powers or STG_1_Settings.Powers
	local finalizedLacunarity = FinalizedValues.lacunarities or STG_1_Settings.lacunarities
	local finalizedGain = FinalizedValues.gains or STG_1_Settings.gains
	
	-- NoiseScale
	DynamicValues.NoiseScale = Formulas.GetSplineValue(
		finalizedNoiseScale,
		MaterialNoise
	)
	DynamicValues.NoiseScale = math.clamp(DynamicValues.NoiseScale, Formulas.GetSmallestNumInArray(finalizedNoiseScale), 10000000)

	-- Amplitude
	DynamicValues.Amplitude = Formulas.GetSplineValue(
		finalizedAmplitude,
		MaterialNoise
	)
	DynamicValues.Amplitude = math.clamp(DynamicValues.Amplitude, Formulas.GetSmallestNumInArray(finalizedAmplitude), 10000000000000)

	-- Power
	DynamicValues.Power = Formulas.GetSplineValue(
		finalizedPower,
		MaterialNoise
	)
	DynamicValues.Power = math.clamp(DynamicValues.Power, Formulas.GetSmallestNumInArray(finalizedPower), 10000000000000)

	-- lacunarity
	DynamicValues.lacunarity = Formulas.GetSplineValue(
		finalizedLacunarity,
		MaterialNoise
	)
	DynamicValues.lacunarity = math.clamp(DynamicValues.lacunarity, Formulas.GetSmallestNumInArray(finalizedLacunarity), 50000)

	-- gain
	DynamicValues.gain = Formulas.GetSplineValue(
		finalizedGain,
		MaterialNoise
	)
	DynamicValues.gain = math.clamp(DynamicValues.gain, Formulas.GetSmallestNumInArray(finalizedGain), 50000)
	
	return DynamicValues
end

function SeemTerrainGen_1_Utils.GetFinalizedSingleInstTbl(
	SingleInstTbl: Types.SingleInstTbl
): Types.FinalizedSingleInstTbl
	local Values = {}
	
	Values.Threshold = SingleInstTbl.Threshold
	Values.Instance = SingleInstTbl.Instance
	
	Values.MaxHeight = SingleInstTbl.MaxHeight or STG_1_Settings.MaxHeight
	Values.MaxSlope = SingleInstTbl.MaxSlope or STG_1_Settings.MaxSlope
	Values.Offset = SingleInstTbl.Offset or STG_1_Settings.Offset
	Values.FaceNormal = SingleInstTbl.FaceNormal or STG_1_Settings.FaceNormal
	Values.MinRandomRotations = SingleInstTbl.MinRandomRotations or STG_1_Settings.MinRandomRotations
	Values.MaxRandomRotations = SingleInstTbl.MaxRandomRotations or STG_1_Settings.MaxRandomRotations
	Values.MinRandomScale = SingleInstTbl.MinRandomScale or STG_1_Settings.MinRandomScale
	Values.MaxRandomScale = SingleInstTbl.Threshold or STG_1_Settings.MaxRandomScale
	
	return Values
end

function SeemTerrainGen_1_Utils.GetFinalMaterialList(
	FinalizedValues: Types.FinalizedValues,
	FinalizedDynamicValues: Types.DynamicValues
): Types.FinalMaterialsList
	local FinalMaterialList = {}
	
	TableLib.DeepMerge_IndexBased(FinalMaterialList, FinalizedValues)
	TableLib.DeepMerge_IndexBased(FinalMaterialList, FinalizedDynamicValues)	
	
	return FinalMaterialList :: Types.FinalMaterialsList
end

--[[
Returns the FBM using FinalizedDynamicValues (created via SeemTerrainGen_1_Utils.GetFinalizedDynamicValues) and FinalizedValues (created via GetFinalizedValues).
]]
function SeemTerrainGen_1_Utils.GetFBM(
	FinalizedDynamicValues: Types.DynamicValues,
	FinalizedValues: Types.FinalizedValues,
	worldX: number,
	worldZ: number
)
	local lacunarity = FinalizedDynamicValues.lacunarity
	local gain = FinalizedDynamicValues.gain

	local AllNoises = 0
	local AllMultiplicators = 0

	-- initial values
	local currentFrequency = FinalizedDynamicValues.NoiseScale
	local currentAmplitude = 1

	for i = 1, FinalizedValues.Octaves or 1 do

		if FinalizedValues.RandomOctaveSeed then
			AllNoises += currentAmplitude * math.noise(worldX * currentFrequency, worldZ * currentFrequency, FinalizedValues.Seed + i)
		else
			AllNoises += currentAmplitude * math.noise(worldX * currentFrequency, worldZ * currentFrequency, FinalizedValues.Seed)
		end

		AllMultiplicators += currentAmplitude

		currentFrequency *= lacunarity
		currentAmplitude *= gain
	end

	local raw = AllNoises / AllMultiplicators
	
	return raw
end

--[[
Returns the SDF for smooth curved falloffs.
]]
function SeemTerrainGen_1_Utils.GetSDF(
	FinalizedValues: Types.FinalizedValues,
	worldX: number,
	worldY: number,
	worldZ: number,
	midX: number,
	midZ: number,
	halfX: number,
	halfZ: number
): number
	
	local FinalWorldY = 0
	
	local distX = math.abs(worldX - midX)
	local distZ = math.abs(worldZ - midZ)

	local cRadius = FinalizedValues.Falloff.CornerRadius or 0
	if FinalizedValues.Falloff.FalloffRadius ~= nil and FinalizedValues.Falloff.FalloffRadius > 0 then
		cRadius = FinalizedValues.Falloff.FalloffRadius
	end

	local innerSizeX = halfX - cRadius
	local innerSizeZ = halfZ - cRadius

	local overX = math.max(0, distX - innerSizeX)
	local overZ = math.max(0, distZ - innerSizeZ)

	local distToCorner

	if FinalizedValues.Falloff.FalloffRadius ~= nil and FinalizedValues.Falloff.FalloffRadius > 0 then
		distToCorner = math.max(overX, overZ)
	else
		distToCorner = math.sqrt(overX^2 + overZ^2)
	end

	local alpha = 0

	if distToCorner > 0 then
		alpha = math.clamp(distToCorner / cRadius, 0, 1)
	end

	if alpha < FinalizedValues.Falloff.Start then
		alpha = 0
	else
		alpha = (alpha - FinalizedValues.Falloff.Start) / (1 - FinalizedValues.Falloff.Start)
	end

	-- Interpolation & Strength
	if FinalizedValues.Falloff.Interpolation == "smoothstep" then
		alpha = Formulas.SmoothStep(0, 1, alpha)
	end

	local FinalAlpha = alpha * FinalizedValues.Falloff.Strength

	if FinalizedValues.Falloff.Reversed == true then
		FinalWorldY = worldY * (1 + FinalAlpha)
	else 
		FinalWorldY = worldY * (1 - FinalAlpha)
	end
	
	return FinalWorldY
end

--[[
Adds the depth(Y)/thickness using Terrain:FillBall().
]]
function SeemTerrainGen_1_Utils.AddThickness(
	FinalizedValues: Types.FinalizedValues,
	NewPosition: Vector3,
	PreservedMaterial: Enum.Material
)
	local ThicknessSteps = FinalizedValues.Thickness.Steps or 1
	local ThicknessPower = FinalizedValues.Thickness.Power or 1

	for i = 1, FinalizedValues.Thickness.ThicknessNumber, ThicknessSteps do
		local ThicknessPosition: Vector3

		if FinalizedValues.Thickness.Direction == "up" then
			ThicknessPosition = NewPosition + Vector3.new(0, i * ThicknessPower, 0)
		elseif FinalizedValues.Thickness.Direction == "down" then
			ThicknessPosition = NewPosition + Vector3.new(0, -i * ThicknessPower, 0)
		end

		terrain:FillBall(ThicknessPosition, FinalizedValues.BallRadius, PreservedMaterial)
	end
end

--============================
-- BIOME FUNCTIONS | NOISE FUNCTIONS
--============================

function SeemTerrainGen_1_Utils.PickByThreshold(
	TableToPickFrom: {},
	Threshold: number,
	LastThreshold: number,
	Noise: number
)
	for i, v in pairs(TableToPickFrom) do
		
	end
end

--[[
Creates a Biome-Folder if not created already (no dups) and returns it.
]]
function SeemTerrainGen_1_Utils.CreateDataBiomeFolder(
	IterationTable: {},
	Biome: Types.Biome
): Types.Biome
	if not IterationTable[Biome.BiomeName] then
		IterationTable[Biome.BiomeName] = {}
	end

	return IterationTable[Biome.BiomeName]
end

--[[
Creates a Biome-Range-Folder if not created already (no dups) and returns it.
]]
function SeemTerrainGen_1_Utils.CreateDataRangeFolder(
	IterationTable: {},
	CurrentBiomeTable: Types.Biome,
	Range: string
)
	if not CurrentBiomeTable[Range] then
		CurrentBiomeTable[Range] = {}
	end

	return CurrentBiomeTable[Range]
end

--[[
Creates a Instances-Folder if not created already (no dups) and returns it.
]]
function SeemTerrainGen_1_Utils.CreateInstancesFolder(
	MaterialFolder: {}
)
	if not MaterialFolder["Instances"] then
		MaterialFolder["Instances"] = {}
	end

	return MaterialFolder["Instances"]
end

--[[
Creates a Biome-Material-Folder if not created already (no dups) and returns it.
]]
function SeemTerrainGen_1_Utils.CreateDataMaterialFolder(
	CurrentRangeTable: {},
	PreservedMaterial: Enum.Material
)
	if not CurrentRangeTable[tostring(PreservedMaterial)] then
		CurrentRangeTable[tostring(PreservedMaterial)] = {}
	end

	return CurrentRangeTable[tostring(PreservedMaterial)]
end

--[[
Returns the Finalized-Biome-Values with Fallback-Checks in a Table.
]]
function SeemTerrainGen_1_Utils.GetFinalizedBiomeValues(
	Biome: Types.Biome,
	FinalizedValues: Types.FinalizedValues,
	worldX: number,
	worldZ: number,
	currentThreshold: number
): Types.FinalizedBiomeValues
	local FinalizedBiomeValues = {}
	
	-- BIOME FALLBACKS
	FinalizedBiomeValues.BiomNoiseScale = Biome.BiomNoiseScale or STG_1_Settings.BiomNoiseScale
	FinalizedBiomeValues.BiomNoiseLength = Biome.BiomNoiseLength or STG_1_Settings.BiomNoiseLength
	
	FinalizedBiomeValues.StrengthNoise = math.noise(
		worldX * FinalizedBiomeValues.BiomNoiseScale, 
		worldZ * FinalizedBiomeValues.BiomNoiseScale, 
		FinalizedValues.Seed
	) * FinalizedBiomeValues.BiomNoiseLength
	
	FinalizedBiomeValues.Threshold = currentThreshold + 
		FinalizedBiomeValues.StrengthNoise + 
		(0.5 * FinalizedBiomeValues.BiomNoiseLength)
	
	return FinalizedBiomeValues
end

--[[
Returns the Finalized-Layer-Values with Fallback-Checks in a Table.
]]
function SeemTerrainGen_1_Utils.GetFinalizedLayerValues(
	Biome: Types.Biome,
	FinalizedValues: Types.FinalizedValues,
	worldX: number,
	worldZ: number,
	NewPosition: Vector3
): Types.FinalizedLayerValues
	local FinalizedLayerValues = {}

	-- LAYER FALLBACKS
	FinalizedLayerValues.LayerNoiseScale = Biome.LayerNoiseScale or STG_1_Settings.LayerNoiseScale
	FinalizedLayerValues.LayerNoiseLength = Biome.LayerNoiseLength or STG_1_Settings.LayerNoiseLength
	
	FinalizedLayerValues.LayerNoiseStrength = math.noise(worldX * FinalizedLayerValues.LayerNoiseScale, worldZ * FinalizedLayerValues.LayerNoiseScale, FinalizedValues.Seed) * FinalizedLayerValues.LayerNoiseLength
	FinalizedLayerValues.checkY = NewPosition.Y + FinalizedLayerValues.LayerNoiseStrength + (0.5 * FinalizedLayerValues.LayerNoiseLength) --+ (InnerMaterialsStrength * InnerMaterialsScale)

	return FinalizedLayerValues
end

--[[
Returns the Finalized-InnerMaterial-Values with Fallback-Checks in a Table.
]]
function SeemTerrainGen_1_Utils.GetFinalizedInnerMaterialValues(
	MatList: Types.SingleLayer,
	FinalizedValues: Types.FinalizedValues,
	worldX: number,
	worldZ: number
): Types.FinalizedInnerMaterialValues
	local FinalizedInnerMaterialValues = {}

	-- LAYER FALLBACKS
	FinalizedInnerMaterialValues.InnerMaterialNoiseScale = MatList.InnerMaterialNoiseScale or STG_1_Settings.InnerMaterialNoiseScale
	FinalizedInnerMaterialValues.InnerMaterialNoiseSeed = MatList.InnerMaterialNoiseSeed or STG_1_Settings.InnerMaterialNoiseSeed
	FinalizedInnerMaterialValues.InnerMaterialNoiseStrength = MatList.InnerMaterialNoiseStrength or STG_1_Settings.InnerMaterialNoiseStrength
	FinalizedInnerMaterialValues.InnerMaterialNoise = math.noise(
		worldX * FinalizedInnerMaterialValues.InnerMaterialNoiseScale, 
		worldZ * FinalizedInnerMaterialValues.InnerMaterialNoiseScale, 
		FinalizedValues.Seed + FinalizedInnerMaterialValues.InnerMaterialNoiseSeed
	) * FinalizedInnerMaterialValues.InnerMaterialNoiseStrength
	
	FinalizedInnerMaterialValues.InnerMaterialNoise = FinalizedInnerMaterialValues.InnerMaterialNoise + (0.5 * FinalizedInnerMaterialValues.InnerMaterialNoiseStrength)

	FinalizedInnerMaterialValues.InnerMaterialNoise = math.clamp(FinalizedInnerMaterialValues.InnerMaterialNoise, 0, 1)

	return FinalizedInnerMaterialValues
end

--[[
Returns the Finalized-SameMaterialLevel-Values with Fallback-Checks in a Table.
]]
function SeemTerrainGen_1_Utils.GetFinalizedSameMaterialLevelValues(
	MatList: Types.SingleLayer,
	FinalizedValues: Types.FinalizedValues,
	worldX: number,
	worldZ: number
): Types.FinalizedSameMaterialLevelValues
	local FinalizedSameMaterialLevelValues = {}

	-- LAYER FALLBACKS
	FinalizedSameMaterialLevelValues.SameMaterialLevelNoiseScale = MatList.SameMaterialLevelNoiseScale or STG_1_Settings.SameMaterialLevelNoiseScale
	FinalizedSameMaterialLevelValues.SameMaterialLevelNoiseLength = MatList.SameMaterialLevelNoiseLength or STG_1_Settings.SameMaterialLevelNoiseLength
	FinalizedSameMaterialLevelValues.SameMaterialLevelNoiseSeed = MatList.SameMaterialLevelNoiseSeed or STG_1_Settings.SameMaterialLevelNoiseSeed

	FinalizedSameMaterialLevelValues.SameMaterialLevelNoiseStrength = math.noise(
		worldX * FinalizedSameMaterialLevelValues.SameMaterialLevelNoiseScale,
		worldZ * FinalizedSameMaterialLevelValues.SameMaterialLevelNoiseScale, 
		FinalizedValues.Seed + FinalizedSameMaterialLevelValues.SameMaterialLevelNoiseSeed
	) * FinalizedSameMaterialLevelValues.SameMaterialLevelNoiseLength

	return FinalizedSameMaterialLevelValues
end

--============================
-- RAYCAST FUNCTIONS | NOISE FUNCTIONS
--============================

--[[
Returns the RaycastResult by using specific raycast-settings and InstPos.
]]
function SeemTerrainGen_1_Utils.GetRaycastResult(
	InstPos: Vector3
)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {workspace.Terrain :: Instance}
	raycastParams.FilterType = Enum.RaycastFilterType.Include -- Nur das hier beachten!
	raycastParams.IgnoreWater = true

	local rayOrigin = InstPos + Vector3.new(0, 500, 0)
	local rayDirection = Vector3.new(0, -15000, 0)
	local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
	
	return raycastResult
end

--[[
Checks if the slopeAngle calculated with the raycastResult.Normal
is bigger than the SingleInstTbl.MaxSlope.

If the slopeAngle is bigger, the func returns true, otherwise false.
]]
function SeemTerrainGen_1_Utils.SlopeExceeded(
	raycastResult: RaycastResult,
	FinalizedSingleInstTbl: Types.FinalizedSingleInstTbl
)
	local groundNormal = raycastResult.Normal
	local upVector = Vector3.new(0, 1, 0)
	local dot = groundNormal:Dot(upVector)
	local slopeAngle = math.deg(math.acos(math.clamp(dot, -1, 1)))
	
	if slopeAngle > FinalizedSingleInstTbl.MaxSlope then
		-- exceeded
		return true
	else 
		return false
	end
end

--[[
Checks if the raycastResult Height is bigger than the SingleInstTbl.MaxHeight.

If the raycastResult Height is bigger then true is returned, otherwise false.
]]
function SeemTerrainGen_1_Utils.HeightExceeded(
	raycastResult: RaycastResult,
	FinalizedSingleInstTbl: Types.FinalizedSingleInstTbl
)
	if raycastResult.Position.Y > FinalizedSingleInstTbl.MaxHeight then
		-- exceeded
		return true
	else 
		return false
	end
end

--[[
Applies the FinalizedSingleInstTbl-Values onto the inst, like Offset, Normal, etc.
Also identifies the Class of the inst.
]]
function SeemTerrainGen_1_Utils.HandleInstance(
	raycastResult: RaycastResult,
	FinalizedSingleInstTbl: Types.FinalizedSingleInstTbl,
	inst: Instance
)
	if inst:IsA("Model") then

		local randomScale = math.random(FinalizedSingleInstTbl.MinRandomScale * 100, FinalizedSingleInstTbl.MaxRandomScale * 100) / 100

		local randomRot = CFrame.Angles(
			math.rad(math.random(FinalizedSingleInstTbl.MinRandomRotations.x, FinalizedSingleInstTbl.MaxRandomRotations.x)),
			math.rad(math.random(FinalizedSingleInstTbl.MinRandomRotations.y, FinalizedSingleInstTbl.MaxRandomRotations.y)),
			math.rad(math.random(FinalizedSingleInstTbl.MinRandomRotations.z, FinalizedSingleInstTbl.MaxRandomRotations.z))
		)

		local finalPos = raycastResult.Position + Vector3.new(0, (FinalizedSingleInstTbl.Offset or 0), 0)
		local baseCFrame

		if FinalizedSingleInstTbl.FaceNormal then
			baseCFrame = CFrame.lookAt(finalPos, finalPos + raycastResult.Normal) 
				* CFrame.Angles(math.rad(-90), 0, 0)
		else 
			baseCFrame = CFrame.new(finalPos)
		end

		local finalCFrame = baseCFrame * randomRot

		inst:PivotTo(finalCFrame)
		inst:ScaleTo(randomScale)

	elseif inst:IsA("BasePart") then

		local randomScale = math.random(FinalizedSingleInstTbl.MinRandomScale * 100, FinalizedSingleInstTbl.MaxRandomScale * 100) / 100

		local rotMin = FinalizedSingleInstTbl.MinRandomRotations or {x=0, y=0, z=0}
		local rotMax = FinalizedSingleInstTbl.MaxRandomRotations or {x=0, y=0, z=0}

		local randomRot = CFrame.Angles(
			math.rad(math.random(rotMin.x, rotMax.x)),
			math.rad(math.random(rotMin.y, rotMax.y)),
			math.rad(math.random(rotMin.z, rotMax.z))
		)

		if FinalizedSingleInstTbl.FaceNormal then
			local finalPos = raycastResult.Position + Vector3.new(0, (FinalizedSingleInstTbl.Offset or 0), 0)

			local finalCFrame = CFrame.lookAt(finalPos, finalPos + raycastResult.Normal) 
				* CFrame.Angles(-math.rad(90), 0, 0) 
				* randomRot
			inst.CFrame = finalCFrame

		else 
			local finalPos = raycastResult.Position + Vector3.new(0, (FinalizedSingleInstTbl.Offset or 0), 0)
			local finalCFrame = CFrame.new(finalPos) * randomRot
			inst.CFrame = finalCFrame
		end

		inst.Size = inst.Size * randomScale

	end
end

return SeemTerrainGen_1_Utils
