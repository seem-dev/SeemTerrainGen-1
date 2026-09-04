--[[
Copyright (c) 2026 Seem

This source code is licensed under the MIT license found in the
LICENSE file in the root directory of this source tree.
 
---
Socials(I'd love to meet you!)
Discord: https://discord.gg/fZPqkdyqD (Latest link always on youtube, tiktok and github)
Youtube: https://www.youtube.com/@Seem-dev
TikTok: https://www.tiktok.com/@seem44014
]]

--!strict
--!native

-- it took me 3 months for this. Frustrated so many times.
-- learning has changed and it was the best choice I could've picked. 

-- I know this script is long, but only because I put everything in this one script.
-- Type annotations are used and hopefully logical names.
-- You will see the pattern

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local replicated = game:GetService("ReplicatedStorage")
local ScriptEditorService = game:GetService("ScriptEditorService")
local SeemTerrainTemp = workspace.SeemTerrain.Temp
local SeemTerrainCache = replicated.SeemTerrain.Temp

local TableLib = require(script.Parent.TableLib)

local cam = workspace.Camera

-- types
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

					Instances: {
						{
							Threshold: number,
							Instance: Instance,
							MaxHeight: number,
							MaxSlope: number, -- (deg)
							Offset: number?,
							FaceNormal: boolean?,

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
					}
				}
			}?
		}
	}

}

export type Layers = {
	[string]: SingleLayer -- iIn and InnerMatList
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
		Strength: number, -- 0-inf
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

	MaterialsList: {
		{ -- biome
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
	},

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

local terrain = workspace.Terrain :: Terrain

local MathHelp = script.Parent.MathHelp
local Formulas = require(MathHelp.Formulas)

local SeemTerrainGen1 = {}

local CurrentIterationTable: {any}

-- used to cancel the running operations (for e.g UI)
SeemTerrainGen1.TerrainGenerationEnabled = true
SeemTerrainGen1.PropGenerationEnabled = true

function SeemTerrainGen1.GenerateTerrain(
	Materials: MaterialsList
)

	local startTime = os.clock() -- for batching.

	local CenterPosition = Materials.CenterPosition or Vector3.new(0, 0, 0)
	local SizeX = Materials.Size.X
	local SizeZ = Materials.Size.Z
	local WaitDuration = Materials.WaitDuration or 0
	local Steps = Materials.Steps or Materials.BallRadius
	local Seed = Materials.Seed or 1
	local Octaves = Materials.Octaves or 5
	local BallRadius = Materials.BallRadius or 5

	local RandomOctaveSeed = Materials.RandomOctaveSeed or false

	local InstancingSteps = Materials.InstancingSteps or Materials.Steps
	local instNoiseScale = Materials.instNoiseScale or 0.8
	local instNoiseLength = Materials.instNoiseLength or 15 -- studs
	local instNoiseSeed = Materials.instNoiseSeed or 1

	local BatchingEnabled = Materials.BatchingEnabled or true
	local BatchTime = Materials.BatchTime or 0.02
	local BatchWait = Materials.BatchWait or 0.03

	local Falloff = Materials.Falloff
	local Thickness = Materials.Thickness

	local halfX, halfZ = SizeX / 2, SizeZ / 2
	local midX = CenterPosition.X + halfX
	local midZ = CenterPosition.Z + halfZ

	-- everything is stored in this table. Just look it up(ctrl + F)
	local IterationTable: {[any]: any} = {}

	local MaterialNoise = 0

	for xi = 0, SizeX, Steps do
		-- Cancel Handling
		if SeemTerrainGen1.TerrainGenerationEnabled == false then
			break
		end
		--
		local worldX = xi + CenterPosition.X

		for zi = 0, SizeZ, Steps do
			-- Cancel Handling
			if SeemTerrainGen1.TerrainGenerationEnabled == false then
				break
			end
			--
			local worldZ = zi + CenterPosition.Z

			local MaterialNoiseScale = Materials.MaterialNoiseScale or 0.001
			local MaterialNoiseSeed = Materials.MaterialNoiseSeed or 100
			local MaterialNoiseStrength = Materials.MaterialNoiseStrength or 1
			MaterialNoise = math.noise(
				worldX * MaterialNoiseScale,
				worldZ * MaterialNoiseScale,
				Seed + MaterialNoiseSeed
			) * MaterialNoiseStrength
			MaterialNoise = MaterialNoise + (0.5 * MaterialNoiseStrength)
			MaterialNoise = math.clamp(MaterialNoise, 0, 1)

			-- NoiseScale
			local NoiseScale = Formulas.GetSplineValue(
				Materials.NoiseScales,
				MaterialNoise
			)
			NoiseScale = math.clamp(NoiseScale, Formulas.GetSmallestNumInArray(Materials.NoiseScales), 10000000)

			-- Amplitude
			local Amplitude = Formulas.GetSplineValue(
				Materials.Amplitudes,
				MaterialNoise
			)
			Amplitude = math.clamp(Amplitude, Formulas.GetSmallestNumInArray(Materials.Amplitudes), 10000000000000)

			-- Power
			local Power = Formulas.GetSplineValue(
				Materials.Powers,
				MaterialNoise
			)
			Power = math.clamp(Power, Formulas.GetSmallestNumInArray(Materials.Powers), 10000000000000)

			-- lacunarity
			local lacunarity = Formulas.GetSplineValue(
				Materials.lacunarities,
				MaterialNoise
			)
			lacunarity = math.clamp(lacunarity, Formulas.GetSmallestNumInArray(Materials.lacunarities), 50000)

			-- gain
			local gain = Formulas.GetSplineValue(
				Materials.gains,
				MaterialNoise
			)
			gain = math.clamp(gain, Formulas.GetSmallestNumInArray(Materials.gains), 50000)

			-- what would you do if your brother is so much better?

			local raw = math.noise(worldX * NoiseScale, worldZ * NoiseScale, Seed)

			if Octaves then
				local lacunarity = lacunarity
				local gain = gain

				local AllNoises = 0
				local AllMultiplicators = 0

				-- initial values
				local currentFrequency = NoiseScale
				local currentAmplitude = 1

				for i = 1, Octaves or 1 do

					if RandomOctaveSeed then
						AllNoises += currentAmplitude * math.noise(worldX * currentFrequency, worldZ * currentFrequency, Seed + i)
					else
						AllNoises += currentAmplitude * math.noise(worldX * currentFrequency, worldZ * currentFrequency, Seed)
					end

					AllMultiplicators += currentAmplitude

					currentFrequency *= lacunarity
					currentAmplitude *= gain
				end

				raw = AllNoises / AllMultiplicators
			else 
				raw = math.noise(worldX * NoiseScale, worldZ * NoiseScale, Seed)
			end

			raw = raw + 0.5
			raw = math.clamp(raw, 0, 1)

			local powered = math.pow(raw, Power)

			local worldY = (powered * Amplitude)

			-- SDF. I only understand it with the docs. I forget this all the time.
			if Falloff and Falloff.Enabled == true then
				local distX = math.abs(worldX - midX)
				local distZ = math.abs(worldZ - midZ)

				local cRadius = Falloff.CornerRadius or 0
				if Falloff.FalloffRadius ~= nil and Falloff.FalloffRadius > 0 then
					cRadius = Falloff.FalloffRadius
				end

				local innerSizeX = halfX - cRadius
				local innerSizeZ = halfZ - cRadius

				local overX = math.max(0, distX - innerSizeX)
				local overZ = math.max(0, distZ - innerSizeZ)

				local distToCorner

				if Falloff.FalloffRadius ~= nil and Falloff.FalloffRadius > 0 then
					distToCorner = math.max(overX, overZ)
				else
					distToCorner = math.sqrt(overX^2 + overZ^2)
				end

				local alpha = 0

				if distToCorner > 0 then
					alpha = math.clamp(distToCorner / cRadius, 0, 1)
				end

				if alpha < Falloff.Start then
					alpha = 0
				else
					alpha = (alpha - Falloff.Start) / (1 - Falloff.Start)
				end

				-- Interpolation & Strength
				if Falloff.Interpolation == "smoothstep" then
					alpha = Formulas.SmoothStep(0, 1, alpha)
				end

				local FinalAlpha = alpha * Falloff.Strength

				if Falloff.Reversed == true then
					worldY = worldY * (1 + FinalAlpha)
				else 
					worldY = worldY * (1 - FinalAlpha)
				end
			end

			local NewPosition = Vector3.new(worldX, worldY + CenterPosition.Y, worldZ)

			local PreservedMaterial: Enum.Material = Enum.Material.Water

			-- can be 0 too. I picked -100(a really low value) because I think it's correct.
			-- noise and splines have spikes, so I just chose a "right" value.
			local LastThreshold = -100

			local currentThreshold
			for i, Biome in ipairs(Materials.MaterialsList) do

				local function CreateDataBiomeFolder()
					if not IterationTable[Biome.BiomeName] then
						IterationTable[Biome.BiomeName] = {}
					end

					return IterationTable[Biome.BiomeName]
				end
				local CurrentBiomeTable = CreateDataBiomeFolder()
				-- ..  .... .- - .  -.-. .- -. -.-. . .-. .-.-.-
				currentThreshold = Biome.Threshold

				if i == #Materials.MaterialsList then
					currentThreshold = 100
				end

				local BiomNoiseScale = Biome.BiomNoiseScale or 0
				local BiomNoiseLength = Biome.BiomNoiseLength or 0
				local StrengthNoise = math.noise(worldX * BiomNoiseScale, worldZ * BiomNoiseScale, Seed) * BiomNoiseLength
				local Threshold = currentThreshold + StrengthNoise + (0.5 * BiomNoiseLength)


				if MaterialNoise <= Threshold and MaterialNoise >= LastThreshold then
					-- we have found the correct biome

					PreservedMaterial = Biome.FallbackMaterial

					local fym = true -- I raged when doing this: I debugged and no variable names were coming into my head, so I just picked fym. No effect at all.
					for Range: string, MatList: SingleLayer in pairs(Biome.Layers) do
						if fym == false then return end

						for _, CurrentMatList in ipairs(MatList.List) do
							local function CreateDataRangeFolder()
								if not CurrentBiomeTable[Range] then
									CurrentBiomeTable[Range] = {}
								end

								return CurrentBiomeTable[Range]
							end
							local CurrentRangeTable = CreateDataRangeFolder()

							local StartNum = Range:match("^[%p%d]+")
							local EndNum = Range:match("[%p%d]+$")

							StartNum = tonumber(StartNum) :: number
							EndNum = tonumber(EndNum) :: number

							local LayerNoiseScale = Biome.LayerNoiseScale or 0.08
							local LayerNoiseLength = Biome.LayerNoiseLength or 30
							local LayerNoiseStrength = math.noise(worldX * LayerNoiseScale, worldZ * LayerNoiseScale, Seed) * LayerNoiseLength
							local checkY = NewPosition.Y + LayerNoiseStrength + (0.5 * LayerNoiseLength) --+ (InnerMaterialsStrength * InnerMaterialsScale)

							if checkY >= StartNum and checkY <= EndNum then
								-- we have found the correct layer(height material layer)
								--
								local InnerMaterialNoiseScale = MatList.InnerMaterialNoiseScale or 0.1
								local InnerMaterialNoiseSeed = MatList.InnerMaterialNoiseSeed or 123
								local InnerMaterialNoiseStrength = MatList.InnerMaterialNoiseStrength or 1
								local InnerMaterialNoise = math.noise(worldX * InnerMaterialNoiseScale, worldZ * InnerMaterialNoiseScale, Seed + InnerMaterialNoiseSeed) * InnerMaterialNoiseStrength

								InnerMaterialNoise = InnerMaterialNoise + (0.5 * InnerMaterialNoiseStrength)

								InnerMaterialNoise = math.clamp(InnerMaterialNoise, 0, 1)

								-- it's so strange being the different one, even when you have no idea.
								-- a person always needing to watch you because you are "different".

								local LastInnerThreshold = 0
								local CurrentInnerThreshold
								local InstDistance = 0

								for iIn, InnerMatList in ipairs(MatList.List) do

									local SameMaterialLevelNoiseScale = MatList.SameMaterialLevelNoiseScale or 0.8
									local SameMaterialLevelNoiseLength = MatList.SameMaterialLevelNoiseLength or 1
									local SameMaterialLevelNoiseSeed = MatList.SameMaterialLevelNoiseSeed or 2132

									local SameMaterialLevelNoiseStrength = math.noise(worldX * SameMaterialLevelNoiseScale, worldZ * SameMaterialLevelNoiseScale, Seed + SameMaterialLevelNoiseSeed) * SameMaterialLevelNoiseLength

									CurrentInnerThreshold = InnerMatList.Threshold + (0.5 * SameMaterialLevelNoiseStrength)

									if iIn == #MatList.List then
										CurrentInnerThreshold = 100 
									end

									--
									-- same height level check
									if InnerMaterialNoise <= CurrentInnerThreshold and InnerMaterialNoise >= LastInnerThreshold then
										-- we have found the correct InnerMaterial
										PreservedMaterial = InnerMatList.Material

										if not InnerMatList._Positions then
											InnerMatList._Positions = {{pos = NewPosition, mat = InnerMatList.Material}}
										else 
											table.insert(InnerMatList._Positions :: {{ mat: Enum.Material, pos: Vector3 }}, {pos = NewPosition, mat = InnerMatList.Material})
										end

										local function CreateDataMaterialFolder()
											if not CurrentRangeTable[tostring(PreservedMaterial)] then
												CurrentRangeTable[tostring(PreservedMaterial)] = {}
											end

											return CurrentRangeTable[tostring(PreservedMaterial)]
										end
										local CurrentMaterialFolder = CreateDataMaterialFolder()

										local function CreateDataPositionFolder()
											if not CurrentMaterialFolder[tostring(NewPosition)] then
												CurrentMaterialFolder[tostring(NewPosition)] = {}
											end

											return CurrentMaterialFolder[tostring(NewPosition)]
										end

										break
									else 

									end	

									LastInnerThreshold = CurrentInnerThreshold
								end

								break
							else 
								--print("not checky")
							end
						end

					end

					break
				end

				LastThreshold = Threshold
			end

			terrain:FillBall(NewPosition, BallRadius, PreservedMaterial)

			-- Depth(Y)
			if Thickness ~= nil then
				local ThicknessSteps = Thickness.Steps or 1
				local ThicknessPower = Thickness.Power or 1

				for i = 1, Thickness.ThicknessNumber, ThicknessSteps do
					local ThicknessPosition: Vector3

					if Thickness.Direction == "up" then
						ThicknessPosition = NewPosition + Vector3.new(0, i * ThicknessPower, 0)
					elseif Thickness.Direction == "down" then
						ThicknessPosition = NewPosition + Vector3.new(0, -i * ThicknessPower, 0)
					end

					terrain:FillBall(ThicknessPosition, BallRadius, PreservedMaterial)
				end
			end

			if BatchingEnabled then
				if (os.clock() - startTime) >= BatchTime then
					task.wait(BatchWait)

					startTime = os.clock()
				end
			end
		end

		if BatchingEnabled then
			task.wait(WaitDuration)
		end
	end

	CurrentIterationTable = IterationTable

	SeemTerrainGen1.TerrainGenerationEnabled = true -- automatically enable(so we dont need another function to resume generation)
end

function SeemTerrainGen1.CancelTerrainGeneration()
	SeemTerrainGen1.TerrainGenerationEnabled = false
end

function SeemTerrainGen1.CancelPropGeneration()
	SeemTerrainGen1.PropGenerationEnabled = false
end

-- LoadProps
function SeemTerrainGen1.CreateFolders()
	if typeof(CurrentIterationTable) == "table" then
		TableLib.ConvertToFolders(CurrentIterationTable, SeemTerrainTemp, 0.02)

		-- delete unnecessary folders
		for i,v in pairs(SeemTerrainTemp:GetDescendants()) do
			if v.Name == "Instances" then -- folder
				for _, child in pairs(v:GetChildren()) do
					if child:IsA("Folder") then
						child:Destroy()
					end
				end
			end
		end

		warn("Delete unnecessary folders")
	end
end

function SeemTerrainGen1.GenerateProps(
	Materials: MaterialsList
)

	-- "You are in your brother's shadow"

	--GenerateProps follows the same structure and pattern as GenerateTerrain;
	-- it was just easier for me to do and it didn't cause me any lack of performance.
	local startTime = os.clock()

	local CenterPosition = Materials.CenterPosition or Vector3.new(0, 0, 0)
	local SizeX = Materials.Size.X
	local SizeZ = Materials.Size.Z
	local WaitDuration = Materials.WaitDuration or 0
	local Steps = Materials.Steps or Materials.BallRadius
	local Seed = Materials.Seed or 1
	local Octaves = Materials.Octaves or 5
	local BallRadius = Materials.BallRadius or 5

	local RandomOctaveSeed = Materials.RandomOctaveSeed or false

	local InstancingSteps = Materials.InstancingSteps or Materials.Steps
	local InstancingSeed = Materials.InstancingSeed or 2342

	local InstDistributionScale = Materials.InstDistributionScale or 0.8
	local InstDistributionSeed = Materials.InstDistributionSeed or 2043
	local InstDistributionLength = Materials.InstDistributionLength or 1

	local instNoiseScale = Materials.instNoiseScale or 0.8
	local instNoiseLength = Materials.instNoiseLength or 15 -- studs
	local instNoiseSeed = Materials.instNoiseSeed or 1

	local BatchingEnabled = Materials.BatchingEnabled or true
	local BatchTime = Materials.BatchTime or 0.02
	local BatchWait = Materials.BatchWait or 0.03

	local Falloff = Materials.Falloff
	local Thickness = Materials.Thickness

	local halfX, halfZ = SizeX / 2, SizeZ / 2
	local midX = CenterPosition.X + halfX
	local midZ = CenterPosition.Z + halfZ

	-- Instancing
	local LastInstPosition: Vector3
	for xi = 0, SizeX, InstancingSteps do
		-- Cancel Handling
		if SeemTerrainGen1.PropGenerationEnabled == false then
			break
		end
		--
		local worldX = xi + CenterPosition.X

		for zi = 0, SizeZ, InstancingSteps do
			-- Cancel Handling
			if SeemTerrainGen1.PropGenerationEnabled == false then
				break
			end
			--
			local worldZ = zi + CenterPosition.Z

			-- would you choose to die peacefully right now as a kid(< 10 years) or continue to live?
			-- I mean do you remember that much as a kid as you do now?

			local MaterialNoiseScale = Materials.MaterialNoiseScale or 0.001
			local MaterialNoiseSeed = Materials.MaterialNoiseSeed or 100
			local MaterialNoiseStrength = Materials.MaterialNoiseStrength or 1
			local MaterialNoise = math.noise(
				worldX * MaterialNoiseScale,
				worldZ * MaterialNoiseScale,
				Seed + MaterialNoiseSeed
			) * MaterialNoiseStrength
			MaterialNoise = MaterialNoise + (0.5 * MaterialNoiseStrength)
			MaterialNoise = math.clamp(MaterialNoise, 0, 1)

			-- NoiseScale
			local NoiseScale = Formulas.GetSplineValue(
				Materials.NoiseScales,
				MaterialNoise
			)
			NoiseScale = math.clamp(NoiseScale, Formulas.GetSmallestNumInArray(Materials.NoiseScales), 10000000)

			-- Amplitude
			local Amplitude = Formulas.GetSplineValue(
				Materials.Amplitudes,
				MaterialNoise
			)
			Amplitude = math.clamp(Amplitude, Formulas.GetSmallestNumInArray(Materials.Amplitudes), 10000000000000)

			-- Power
			local Power = Formulas.GetSplineValue(
				Materials.Powers,
				MaterialNoise
			)
			Power = math.clamp(Power, Formulas.GetSmallestNumInArray(Materials.Powers), 10000000000000)

			-- lacunarity
			local lacunarity = Formulas.GetSplineValue(
				Materials.lacunarities,
				MaterialNoise
			)
			lacunarity = math.clamp(lacunarity, Formulas.GetSmallestNumInArray(Materials.lacunarities), 50000)

			-- gain
			local gain = Formulas.GetSplineValue(
				Materials.gains,
				MaterialNoise
			)
			gain = math.clamp(gain, Formulas.GetSmallestNumInArray(Materials.gains), 50000)

			local raw = math.noise(worldX * NoiseScale, worldZ * NoiseScale, Seed)

			-- fbm
			if Octaves then
				local lacunarity = lacunarity
				local gain = gain

				local AllNoises = 0
				local AllMultiplicators = 0

				-- initial values
				local currentFrequency = NoiseScale
				local currentAmplitude = 1

				for i = 1, Octaves or 1 do

					if RandomOctaveSeed then
						AllNoises += currentAmplitude * math.noise(worldX * currentFrequency, worldZ * currentFrequency, Seed + i)
					else
						AllNoises += currentAmplitude * math.noise(worldX * currentFrequency, worldZ * currentFrequency, Seed)
					end

					AllMultiplicators += currentAmplitude

					currentFrequency *= lacunarity
					currentAmplitude *= gain
				end

				raw = AllNoises / AllMultiplicators
			else 
				raw = math.noise(worldX * NoiseScale, worldZ * NoiseScale, Seed)
			end

			raw = raw + 0.5
			raw = math.clamp(raw, 0, 1)

			-- a bit like success.
			local powered = math.pow(raw, Power)
			local worldY = (powered * Amplitude)

			local BeforeFalloffY = worldY

			if Falloff and Falloff.Enabled == true then
				local distX = math.abs(worldX - midX)
				local distZ = math.abs(worldZ - midZ)

				local cRadius = Falloff.CornerRadius or 0
				if Falloff.FalloffRadius ~= nil and Falloff.FalloffRadius > 0 then
					cRadius = Falloff.FalloffRadius
				end

				local innerSizeX = halfX - cRadius
				local innerSizeZ = halfZ - cRadius

				local overX = math.max(0, distX - innerSizeX)
				local overZ = math.max(0, distZ - innerSizeZ)

				local distToCorner

				if Falloff.FalloffRadius ~= nil and Falloff.FalloffRadius > 0 then
					distToCorner = math.max(overX, overZ)
				else
					distToCorner = math.sqrt(overX^2 + overZ^2)
				end

				local alpha = 0

				if distToCorner > 0 then
					alpha = math.clamp(distToCorner / cRadius, 0, 1)
				end

				if alpha < Falloff.Start then
					alpha = 0
				else
					alpha = (alpha - Falloff.Start) / (1 - Falloff.Start)
				end

				if Falloff.Interpolation == "smoothstep" then
					alpha = Formulas.SmoothStep(0, 1, alpha)
				end

				local FinalAlpha = alpha * Falloff.Strength

				if Falloff.Reversed == true then
					worldY = worldY * (1 + FinalAlpha)
				else 
					worldY = worldY * (1 - FinalAlpha)
				end
			end

			local NewPosition = Vector3.new(worldX, worldY + CenterPosition.Y, worldZ)

			local PreservedMaterial: Enum.Material = Enum.Material.Water

			local LastThreshold = 0
			local currentThreshold
			for i, Biome in ipairs(Materials.MaterialsList) do

				-- Instancing
				--
				currentThreshold = Biome.Threshold

				if i == #Materials.MaterialsList then
					currentThreshold = 100 
				end

				local BiomNoiseScale = Biome.BiomNoiseScale or 0.1
				local BiomNoiseLength = Biome.BiomNoiseLength or 0.1

				local StrengthNoise = math.noise(worldX * BiomNoiseScale, worldZ * BiomNoiseScale, Seed) * BiomNoiseLength

				local Threshold = currentThreshold + StrengthNoise + (0.5 * BiomNoiseLength)

				-- noise is so easy if you think organic and use math in what you want(I wanted a Terrain Generator).
				-- don't think that strict, just try 

				-- here again we just check if we are in the correct area/borders/land.
				if MaterialNoise <= Threshold and MaterialNoise >= LastThreshold then
					-- we have found the correct biome
					--
					PreservedMaterial = Biome.FallbackMaterial

					for Range: string, MatList: SingleLayer in pairs(Biome.Layers) do
						-- Instancing

						local StartNum = Range:match("^[%p%d]+")
						local EndNum = Range:match("[%p%d]+$")

						StartNum = tonumber(StartNum) :: number
						EndNum = tonumber(EndNum) :: number

						local LayerNoiseScale = Biome.LayerNoiseScale or 0.08
						local LayerNoiseLength = Biome.LayerNoiseLength or 30
						local LayerNoiseStrength = math.noise(worldX * LayerNoiseScale, worldZ * LayerNoiseScale, Seed) * LayerNoiseLength
						local checkY = NewPosition.Y + LayerNoiseStrength + (0.5 * LayerNoiseLength) --+ (InnerMaterialsStrength * InnerMaterialsScale)

						-- if you'd know how much time this checkY took me.
						-- not because it was difficult, but because I coded too much and made mistakes, haha
						if checkY >= StartNum and checkY <= EndNum then
							-- we have found the correct layer(height material layer)
							--
							local InnerMaterialNoiseScale = MatList.InnerMaterialNoiseScale or 0.1
							local InnerMaterialNoiseSeed = MatList.InnerMaterialNoiseSeed or 123
							local InnerMaterialNoiseStrength = MatList.InnerMaterialNoiseStrength or 1
							local InnerMaterialNoise = math.noise(worldX * InnerMaterialNoiseScale, worldZ * InnerMaterialNoiseScale, Seed + InnerMaterialNoiseSeed) * InnerMaterialNoiseStrength
							InnerMaterialNoise = InnerMaterialNoise + (0.5 * InnerMaterialNoiseStrength)
							InnerMaterialNoise = math.clamp(InnerMaterialNoise, 0, 1)

							local LastInnerThreshold = 0
							local CurrentInnerThreshold
							for iIn, InnerMatList in ipairs(MatList.List) do

								-- always waking up in a hospital, something sticked in your chest
								-- and not being able to move, just staring at the ceiling.

								local SameMaterialLevelNoiseScale = MatList.SameMaterialLevelNoiseScale or 0.8
								local SameMaterialLevelNoiseLength = MatList.SameMaterialLevelNoiseLength or 1
								local SameMaterialLevelNoiseSeed = MatList.SameMaterialLevelNoiseSeed or 2132
								local SameMaterialLevelNoiseStrength = math.noise(worldX * SameMaterialLevelNoiseScale, worldZ * SameMaterialLevelNoiseScale, Seed + SameMaterialLevelNoiseSeed) * SameMaterialLevelNoiseLength

								CurrentInnerThreshold = InnerMatList.Threshold + (0.5 * SameMaterialLevelNoiseStrength)

								if iIn == #MatList.List then
									CurrentInnerThreshold = 100 
								end

								-- same height level check
								if InnerMaterialNoise <= CurrentInnerThreshold and InnerMaterialNoise >= LastInnerThreshold then
									-- we have found the correct InnerMaterial
									PreservedMaterial = InnerMatList.Material

									-- Instancing
									if InnerMatList.Instancing then

										local LastInstThreshold = 0

										for iInstTbl, InstTbl in pairs(InnerMatList.Instancing) do

											local InstThreshold = InstTbl.Threshold

											if iInstTbl == #InnerMatList.Instancing then
												InstThreshold = 100
											end

											-- InstancingNoise
											if InnerMaterialNoise <= InstThreshold and InnerMaterialNoise >= LastInstThreshold then
												-- we found the right Instance-Table

												local SingleInstNoise = math.noise(worldX * InstDistributionScale, worldZ * InstDistributionScale, Seed + InstDistributionSeed) * InstDistributionLength
												SingleInstNoise = SingleInstNoise + (0.5 * InstDistributionLength)
												SingleInstNoise = math.clamp(SingleInstNoise, 0, 1)

												local LastSingleInstThreshold = 0
												for iSingleInstTbl, SingleInstTbl in pairs(InstTbl.Instances) do
													local SingleInstTblInst = SingleInstTbl.Instance
													local SingleInstTblThreshold = SingleInstTbl.Threshold

													if iSingleInstTbl == #InstTbl.Instances then
														SingleInstTblThreshold = 100
													end

													if SingleInstNoise <= SingleInstTblThreshold and SingleInstNoise >= LastSingleInstThreshold then
														local inst = SingleInstTblInst:Clone()
														-- we set the parent later, so we do everything on the ram first so we have way more performance.

														local instNoise = math.noise(worldX * instNoiseScale, worldZ * instNoiseScale, Seed + instNoiseSeed) * instNoiseLength

														local InstPos = NewPosition + Vector3.new(instNoise, 0, instNoise)

														local raycastParams = RaycastParams.new()
														raycastParams.FilterDescendantsInstances = {workspace.Terrain :: Instance}
														raycastParams.FilterType = Enum.RaycastFilterType.Include -- Nur das hier beachten!
														raycastParams.IgnoreWater = true

														local rayOrigin = InstPos + Vector3.new(0, 500, 0)
														local rayDirection = Vector3.new(0, -15000, 0)
														local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

														if raycastResult then
															local groundNormal = raycastResult.Normal
															local upVector = Vector3.new(0, 1, 0)

															-- idk what exactly each of these math functions do,
															-- I understood at the time when I watched the videos, but forgot instantly,
															-- so they are copied from videos.
															local dot = groundNormal:Dot(upVector)

															local slopeAngle = math.deg(math.acos(math.clamp(dot, -1, 1)))

															if raycastResult.Position.Y > SingleInstTbl.MaxHeight then
																-- exceeded
																inst:Destroy()
																continue
															end

															if slopeAngle > SingleInstTbl.MaxSlope then
																-- exceeded
																inst:Destroy()
																continue
															end

															-- Iteration Data
															-- Get Directory
															local BiomeFolder = CurrentIterationTable[Biome.BiomeName] 
															local RangeFolder = BiomeFolder[Range]
															local MaterialFolder = RangeFolder[tostring(PreservedMaterial)]

															-- Create Folder if not done so
															local function CreateInstancesFolder()
																if not MaterialFolder["Instances"] then
																	MaterialFolder["Instances"] = {}
																end
															end
															CreateInstancesFolder()
															local InstancesFolder = MaterialFolder["Instances"] 
															local TotalPropCount = #InstancesFolder

															-- and then you are taken to the next step.
															-- I also wanted to live a normal life. Are you living a normal life?

															table.insert(InstancesFolder, inst)
															inst.Name = SingleInstTblInst.Name.."_"..TotalPropCount

															if inst:IsA("Model") then

																local randomScale = math.random(SingleInstTbl.MinRandomScale * 100, SingleInstTbl.MaxRandomScale * 100) / 100

																local randomRot = CFrame.Angles(
																	math.rad(math.random(SingleInstTbl.MinRandomRotations.x, SingleInstTbl.MaxRandomRotations.x)),
																	math.rad(math.random(SingleInstTbl.MinRandomRotations.y, SingleInstTbl.MaxRandomRotations.y)),
																	math.rad(math.random(SingleInstTbl.MinRandomRotations.z, SingleInstTbl.MaxRandomRotations.z))
																)

																local finalPos = raycastResult.Position + Vector3.new(0, (SingleInstTbl.Offset or 0), 0)
																local baseCFrame

																if SingleInstTbl.FaceNormal then
																	baseCFrame = CFrame.lookAt(finalPos, finalPos + raycastResult.Normal) 
																		* CFrame.Angles(math.rad(-90), 0, 0)
																else 
																	baseCFrame = CFrame.new(finalPos)
																end

																local finalCFrame = baseCFrame * randomRot

																inst:PivotTo(finalCFrame)
																inst:ScaleTo(randomScale)

															elseif inst:IsA("BasePart") then

																local randomScale = math.random(SingleInstTbl.MinRandomScale * 100, SingleInstTbl.MaxRandomScale * 100) / 100

																local rotMin = SingleInstTbl.MinRandomRotations or {x=0, y=0, z=0}
																local rotMax = SingleInstTbl.MaxRandomRotations or {x=0, y=0, z=0}

																local randomRot = CFrame.Angles(
																	math.rad(math.random(rotMin.x, rotMax.x)),
																	math.rad(math.random(rotMin.y, rotMax.y)),
																	math.rad(math.random(rotMin.z, rotMax.z))
																)

																if SingleInstTbl.FaceNormal then
																	local finalPos = raycastResult.Position + Vector3.new(0, (SingleInstTbl.Offset or 0), 0)

																	local finalCFrame = CFrame.lookAt(finalPos, finalPos + raycastResult.Normal) 
																		* CFrame.Angles(-math.rad(90), 0, 0) 
																		* randomRot
																	inst.CFrame = finalCFrame

																else 
																	local finalPos = raycastResult.Position + Vector3.new(0, (SingleInstTbl.Offset or 0), 0)
																	local finalCFrame = CFrame.new(finalPos) * randomRot
																	inst.CFrame = finalCFrame
																end

																inst.Size = inst.Size * randomScale

															end

															LastInstPosition = raycastResult.Position + Vector3.new(0, (SingleInstTbl.Offset or 0), 0)
														end

														break	
													end

													LastSingleInstThreshold = SingleInstTblThreshold
												end

												break
											end

											LastInstThreshold = InstThreshold
										end
									end

									break
								end	

								LastInnerThreshold = CurrentInnerThreshold
							end

							break
						end
					end

					break
				end

				LastThreshold = Threshold
			end

			if BatchingEnabled then
				if (os.clock() - startTime) >= BatchTime then
					task.wait(BatchWait)

					startTime = os.clock()
				end
			end
		end

		if BatchingEnabled then
			task.wait(WaitDuration)
		end

	end

	SeemTerrainGen1.PropGenerationEnabled = true -- automatically enable(so we dont need another function to resume generation)
end

-- is just batching, idk why I called it chunking
function SeemTerrainGen1.ClearProps(
	ChunkConfig: ChunkConfigType
)
	local ChunkSize = ChunkConfig.ChunkSize -- studs
	local ChunkLoadingTime = ChunkConfig.ChunkLoadingTime
	local ChunkLoadingWait = ChunkConfig.ChunkLoadingWait
	local startTime = os.clock()

	for i, v in pairs(workspace.SeemTerrain:GetDescendants()) do
		if v:IsA("BasePart") or v:IsA("Model") then
			v:Destroy()
		end

		if (os.clock() - startTime) >= ChunkLoadingTime then
			startTime = os.clock()

			task.wait(ChunkLoadingWait)
		end
	end
end

return SeemTerrainGen1

-- and so is this the end. I wish I never had it. 
-- I would say the actual therapy is happening years after. 0.3% (in germany), imagine... why me?

-- I hope you like SeemTerrainGen-1, there may be an unnecessary loop, but idk, I don't want to touch the code before it breaks again.
