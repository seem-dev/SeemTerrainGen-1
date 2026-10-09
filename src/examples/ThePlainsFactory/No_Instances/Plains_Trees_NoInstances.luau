--[[
The Plains Factory - SeemTerrainGen-1 Map-Config

Created by Seem for devs.
--
I hope to see you on the discord!!

Discord: Latest link always on socials.
Socials:
X (Twitter): https://x.com/Seem657593
Youtube: https://www.youtube.com/@Seem-dev
Tiktok: https://www.tiktok.com/@seem44014
]]

function GetBottomLeftPositionOfPart(part: BasePart)
	local BottomLeftPosition = nil;

	BottomLeftPosition = part.Position - Vector3.new(
		part.Size.X / 2,
		0,
		part.Size.Z / 2
	);

	return BottomLeftPosition;
end

-- maybe check again if they are true ones.

local MaterialList: MaterialsList = {
	
	extensions = {
		FastGen = {
			chunks = 7
		}
	},

	BallRadius = 5,
	CenterPosition = GetBottomLeftPositionOfPart(workspace.Baseplate),
	Size = Vector3.new(2048, 0, 2048),
	Seed = 2934,

	InstDistributionScale = 0.8,
	InstDistributionSeed = 242143,
	InstDistributionLength = 1,

	InstancingSteps = 30,
	InstancingSeed = 249,

	instNoiseScale = 0.8,
	instNoiseLength = 300,
	instNoiseSeed = 29434,

	Falloff = {
		Enabled = true,
		Start = 0,
		Strength = 1,
		Interpolation = "smoothstep",
		CornerRadius = 300,
		FalloffRadius = nil,
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
	Powers = {4.5},

	lacunarities = {2},
	gains = {0.5},

	RandomOctaveSeed = false,
	Octaves = 5,

	MaterialsList = {
		{
			BiomeName = "Plains_Trees",
			Threshold = 1,
			FallbackMaterial = Enum.Material.CrackedLava,

			Layers = {
				["-1000 to 53"] = {
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
							Material = Enum.Material.LeafyGrass
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
				["167 to 1000"] = {
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


	},

	BatchingEnabled = true,
	BatchTime = 0.02,
	BatchWait = 0.03,

	WaitDuration = 0.03,
	Steps = 5,
}

--[[
This module covers most types for type-annotations (type-errors, autocompletion etc.).
]]

--============================
-- SeemTerrainGen-1 TYPES
--============================

export type SingleInstTbl = {
	Threshold: number,
	Instance: Instance,
	MaxHeight: number?,
	MaxSlope: number?, -- (deg)
	Offset: number?,
	FaceNormal: boolean?,

	MinRandomRotations: {
		x: number,
		y: number,
		z: number
	}?,

	MaxRandomRotations: {
		x: number,
		y: number,
		z: number
	}?,

	MinRandomScale: number?,
	MaxRandomScale: number?
}

export type SingleLayer = { -- string = height. e.g ["-100 to 10"]
	SameMaterialLevelNoiseScale: number?,
	SameMaterialLevelNoiseLength: number?,
	SameMaterialLevelNoiseSeed: number?,

	InnerMaterialNoiseScale: number?,
	InnerMaterialNoiseStrength: number?,
	InnerMaterialNoiseSeed: number?,

	List: {
		{
			Threshold: number,
			Material: Enum.Material,

			-- idk if this is up to date, but this should've stored all the positions and materials of the whole generation.
			-- don't put this in folders, too much performance taken
			_Positions: {{pos: Vector3, mat: Enum.Material}}?,

			-- optional Instancing
			Instancing: {
				-- instance tbl
				{
					Threshold: number,

					Instances: {SingleInstTbl}
				}
			}?
		}
	}

}

export type Layers = {
	[string]: SingleLayer -- iIn and InnerMatList
}

export type Biome = { -- biome
	BiomeName: string,
	Threshold: number,
	FallbackMaterial: Enum.Material,
	_Positions: {{pos: Vector3, mat: Enum.Material}}?,
	Layers: Layers,

	-- height material noise(blending with noise)
	LayerNoiseScale: number?,
	LayerNoiseLength: number?,

	-- biome noise with other biomes
	BiomNoiseLength: number?,
	BiomNoiseScale: number?,
}

export type FastGen = {
	chunks: number
}

export type CustomExtensions = "MountainFiller" 
| "LayerExt" 
| "MountainCreator"
| "IslandCreator"
| "SeaLevelExt"

export type Extension = {
	Enabled: boolean,
	Priority: number,
	Initialization: () -> ()?,

	ThicknessFunc: (
		(
			params: {
				MaterialList: FinalizedValues,
				Position: Vector3,
				Material: Enum.Material
			}
		) -> ()	
	)?,

	ConfigOverwrite: (
		(
			params: {
				Config: MaterialsList
			}	
		) -> MaterialsList	
	)?,

	PointSkipControl: (
		(
			params: {
				Position: Vector3,
				Material: Enum.Material
			}
		) -> boolean
	)?,

	MainGenerationCallControl: (
		(
			params: {
				Config: MaterialsList
			}	
		) -> {
			IslandConfigs: {MaterialsList}, 
			CallHandlingData: {Type: "Async" | "Sync", WaitAmount: number?}
		}
	)?,

	PostProcessFunction: (
		(
			params: {
				PostProcessType: "single" | "multiple",
				Config: MaterialsList | {MaterialsList}
			}	
		) -> ()
	)?,

	[string]: any -- to enable dynamic table call (so type-checker doesnt trigger when we try to access a dynamic key which might not exist); see SeemTerrainGen1.RunCustomExtensionFunction variable func
}

export type ExtensionFunctions = "Initialization" | "ThicknessFunc" 
| "ConfigOverwrite" | "PointSkipControl" 
| "MainGenerationCallControl" | "PostProcessFunction"

export type extensions = {
	FastGen: FastGen?,

	CustomExtensions: {CustomExtensions}?
}

export type MaterialsList = {

	BallRadius: number,
	RandomOctaveSeed: boolean,
	Octaves: number,
	Size: Vector3,
	CenterPosition: Vector3,
	Seed: number,

	InstancingSteps: number,
	InstancingSeed: number,

	InstDistributionScale: number,
	InstDistributionSeed: number,
	InstDistributionLength: number,

	Falloff: { 
		Enabled: boolean,
		Start: number, -- falloff strength(sharpness)! 0-1. this is, how long long the falloff is, not really the start
		Strength: number, -- 0-inf(max 20 is enough)
		Interpolation: "linear" | "smoothstep" | "KenPerlin_smoothstep", -- only smoothstep supported currently
		CornerRadius: number?, -- relative to its own Sizes(X and Z)
		FalloffRadius: number?, -- studs; works like CornerRadius
		Reversed: boolean?,
		FallOffAxis: "X" | "Z" | "XZ"?
	},
	Thickness: {
		ThicknessNumber: number,
		Direction: "up" | "down",
		Steps: number?,
		Power: number?
	},

	instNoiseScale: number,
	instNoiseLength: number, -- studs
	instNoiseSeed: number,
	InstIgnoreWater: boolean,

	WaitDuration: number,
	Steps: number,

	BatchingEnabled: boolean,
	BatchTime: number,
	BatchWait: number,

	Amplitudes: {number},
	NoiseScales: {number},
	Powers: {number},

	-- Octaves
	lacunarities: {number},
	gains: {number},

	MaterialsList: {Biome},

	MaterialNoiseScale: number?,
	MaterialNoiseStrength: number?,
	MaterialNoiseSeed: number?,

	extensions: extensions?
}

-- minecraft is wonderful, isn't it? Was notch a good person?
-- This type is used for the function ClearProps. Read more in that function: There isn't actually chunking used, just batching.
export type ChunkConfigType = {
	ChunkSize: Vector3,
	ChunkLoadingTime: number,
	ChunkLoadingWait: number
}

--============================
-- SeemTerrainGen-1-Utils TYPES
--============================
export type DynamicTableValues = {
	NoiseScales: {number},
	Amplitudes: {number},
	Powers: {number},
	lacunarities: {number},
	gains: {number}
}

export type DynamicValues = {
	NoiseScale: number,
	Amplitude: number,
	Power: number,
	lacunarity: number,
	gain: number
}

export type FinalizedValues = {

	BallRadius: number,
	RandomOctaveSeed: boolean,
	Octaves: number,
	Size: Vector3,
	CenterPosition: Vector3,
	Seed: number,

	InstancingSteps: number,
	InstancingSeed: number,

	InstDistributionScale: number,
	InstDistributionSeed: number,
	InstDistributionLength: number,
	InstIgnoreWater: boolean,

	Falloff: { 
		Enabled: boolean,
		Start: number, -- falloff strength(sharpness)! 0-1. this is, how long long the falloff is, not really the start
		Strength: number, -- 0-inf(max 20 is enough)
		Interpolation: "linear" | "smoothstep" | "KenPerlin_smoothstep", -- only smoothstep supported currently
		CornerRadius: number?, -- relative to its own Sizes(X and Z)
		FalloffRadius: number?, -- studs; works like CornerRadius
		Reversed: boolean?,
		FallOffAxis: "X" | "Z" | "XZ"?
	},
	Thickness: {
		ThicknessNumber: number,
		Direction: "up" | "down",
		Steps: number,
		Power: number
	},

	instNoiseScale: number,
	instNoiseLength: number, -- studs
	instNoiseSeed: number,

	WaitDuration: number,
	Steps: number,

	BatchingEnabled: boolean,
	BatchTime: number,
	BatchWait: number,

	MaterialsList: {
		{ -- biome
			BiomeName: string,
			Threshold: number,
			FallbackMaterial: Enum.Material,
			_Positions: {{pos: Vector3, mat: Enum.Material}},
			Layers: Layers,

			-- height material noise(blending with noise)
			LayerNoiseScale: number?,
			LayerNoiseLength: number?,

			-- biome noise with other biomes
			BiomNoiseLength: number,
			BiomNoiseScale: number,
		}
	},

	MaterialNoiseScale: number,
	MaterialNoiseStrength: number,
	MaterialNoiseSeed: number
}

export type FinalMaterialsList = {

	BallRadius: number,
	RandomOctaveSeed: boolean,
	Octaves: number,
	Size: Vector3,
	CenterPosition: Vector3,
	Seed: number,

	InstancingSteps: number,
	InstancingSeed: number,

	InstDistributionScale: number,
	InstDistributionSeed: number,
	InstDistributionLength: number,
	InstIgnoreWater: boolean,

	Falloff: { 
		Enabled: boolean,
		Start: number, -- falloff strength(sharpness)! 0-1. this is, how long long the falloff is, not really the start
		Strength: number, -- 0-inf(max 20 is enough)
		Interpolation: "linear" | "smoothstep" | "KenPerlin_smoothstep", -- only smoothstep supported currently
		CornerRadius: number, -- relative to its own Sizes(X and Z)
		FalloffRadius: number, -- studs; works like CornerRadius
		Reversed: boolean,
		FallOffAxis: "X" | "Z" | "XZ"
	},
	Thickness: {
		ThicknessNumber: number,
		Direction: "up" | "down",
		Steps: number?,
		Power: number?
	},

	instNoiseScale: number,
	instNoiseLength: number, -- studs
	instNoiseSeed: number,

	WaitDuration: number,
	Steps: number,

	BatchingEnabled: boolean,
	BatchTime: number,
	BatchWait: number,

	Amplitudes: {number},
	NoiseScales: {number},
	Powers: {number},

	-- Octaves
	lacunarities: {number},
	gains: {number},

	MaterialsList: {
		{ -- biome
			BiomeName: string,
			Threshold: number,
			FallbackMaterial: Enum.Material,
			_Positions: {{pos: Vector3, mat: Enum.Material}},
			Layers: Layers,

			-- height material noise(blending with noise)
			LayerNoiseScale: number,
			LayerNoiseLength: number,

			-- biome noise with other biomes
			BiomNoiseLength: number,
			BiomNoiseScale: number,
		}
	},

	MaterialNoiseScale: number,
	MaterialNoiseStrength: number,
	MaterialNoiseSeed: number
}

export type STG_1_Settings = {

	BallRadius: number,
	RandomOctaveSeed: boolean,
	Octaves: number,
	Size: Vector3,
	CenterPosition: Vector3,
	Seed: number,

	InstancingSteps: number,
	InstancingSeed: number,

	InstDistributionScale: number,
	InstDistributionSeed: number,
	InstDistributionLength: number,

	Falloff: { 
		Enabled: boolean,
		Start: number, -- falloff strength(sharpness)! 0-1. this is, how long long the falloff is, not really the start
		Strength: number, -- 0-inf(max 20 is enough)
		Interpolation: "linear" | "smoothstep" | "KenPerlin_smoothstep", -- only smoothstep supported currently
		CornerRadius: number, -- relative to its own Sizes(X and Z)
		FalloffRadius: number, -- studs; works like CornerRadius
		Reversed: boolean,
		FallOffAxis: "X" | "Z" | "XZ"
	},
	Thickness: {
		ThicknessNumber: number,
		Direction: "up" | "down",
		Steps: number,
		Power: number
	},

	instNoiseScale: number,
	instNoiseLength: number, -- studs
	instNoiseSeed: number,
	InstIgnoreWater: boolean,

	WaitDuration: number,
	Steps: number,

	BatchingEnabled: boolean,
	BatchTime: number,
	BatchWait: number,

	Amplitudes: {number},
	NoiseScales: {number},
	Powers: {number},

	-- Octaves
	lacunarities: {number},
	gains: {number},

	MaterialsList: {Biome},

	MaterialNoiseScale: number,
	MaterialNoiseStrength: number,
	MaterialNoiseSeed: number,

	-- BIOME FALLBACKS
	BiomNoiseScale: number,
	BiomNoiseLength: number,

	-- LAYER FALLBACKS
	LayerNoiseScale: number,
	LayerNoiseLength: number,

	-- INNER-MATERIAL FALLBACKS
	InnerMaterialNoiseScale: number,
	InnerMaterialNoiseSeed: number,
	InnerMaterialNoiseStrength: number,

	-- SAME-MATERIAL-LEVEL FALLBACKS
	SameMaterialLevelNoiseScale: number,
	SameMaterialLevelNoiseLength: number,
	SameMaterialLevelNoiseSeed: number,

	-- SINGLE-INST-TBL FALLBACKS
	MaxHeight: number,
	MaxSlope: number,
	Offset: number,
	FaceNormal: boolean,
	MinRandomRotations: {
		x: number,
		y: number,
		z: number
	},
	MaxRandomRotations: {
		x: number,
		y: number,
		z: number
	},
	MinRandomScale: number,
	MaxRandomScale: number
}

export type FinalizedBiomeValues = {
	BiomNoiseScale: number,
	BiomNoiseLength: number,
	StrengthNoise: number,
	Threshold: number
}

export type FinalizedLayerValues = {
	LayerNoiseScale: number,
	LayerNoiseLength: number,
	LayerNoiseStrength: number,
	checkY: number
}

export type FinalizedInnerMaterialValues = {
	InnerMaterialNoiseScale: number,
	InnerMaterialNoiseSeed: number,
	InnerMaterialNoiseStrength: number,
	InnerMaterialNoise: number,
}

export type FinalizedSameMaterialLevelValues = {
	SameMaterialLevelNoiseScale: number,
	SameMaterialLevelNoiseSeed: number,
	SameMaterialLevelNoiseLength: number,
	SameMaterialLevelNoiseStrength: number,
}

export type FinalizedSingleInstTbl = {
	Threshold: number,
	Instance: Instance,
	MaxHeight: number,
	MaxSlope: number, -- (deg)
	Offset: number,
	FaceNormal: boolean,

	MinRandomRotations: {
		x: number,
		y: number,
		z: number
	},

	MaxRandomRotations: {
		x: number,
		y: number,
		z: number
	},

	MinRandomScale: number,
	MaxRandomScale: number
}


return MaterialList
