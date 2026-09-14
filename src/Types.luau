--!strict

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
	MaterialNoiseSeed: number?
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

local Types = {}

return Types
