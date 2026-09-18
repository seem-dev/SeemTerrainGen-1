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

--============================
-- SERVICES
--============================
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local replicated = game:GetService("ReplicatedStorage")
local ScriptEditorService = game:GetService("ScriptEditorService")

--============================
-- FOLDERS
--============================
local SeemResources = script.Parent.Parent.SeemResources
local MathHelp = script.Parent.MathHelp

--============================
-- RELEVANT INSTANCES
--============================
local cam = workspace.Camera
local terrain = workspace.Terrain :: Terrain

--============================
-- MODULES
--============================
local TableLib = require("./TableLib")
local Formulas = require(MathHelp.Formulas)
local Types = require("./Types")
local Processor = require("./Processor")
local SeemTerrainGen_1_Utils = require("./SeemTerrainGen-1-Utils")

local SeemTerrainGen1 = {}

--============================
-- GLOBAL VARIABLES
--============================
local CurrentIterationTable: {any}
-- used to cancel the running operations (for e.g UI)
Processor.TerrainGenerationEnabled = true
Processor.PropGenerationEnabled = true

function SeemTerrainGen1.GenerateTerrain(
	Materials: Types.MaterialsList
)	
	--============================
	-- IMPORTANT VARIABLES and FALLBACKS
	--============================
	local startTime = os.clock() -- for batching.
	
	local FinalizedValues = SeemTerrainGen_1_Utils.GetFinalizedValues(Materials) -- gets the finalized values (fallback-checks, etc.)
	
	--============================
	-- SETUP SeemTerrainGen_1_Utils WITH FINALIZED-VALUES
	--============================
	SeemTerrainGen_1_Utils.Setup_STG_1_Utils(FinalizedValues)
	
	--============================
	-- IMPORTANT VARIABLES
	--============================
	local halfX, halfZ = FinalizedValues.Size.X / 2, FinalizedValues.Size.Z / 2
	local midX = FinalizedValues.CenterPosition.X + halfX
	local midZ = FinalizedValues.CenterPosition.Z + halfZ
	
	-- everything is stored in this table. Just look it up(ctrl + F)
	local IterationTable: {[any]: any} = {}

	local MaterialNoise = 0
	
	for xi = 0, FinalizedValues.Size.X, FinalizedValues.Steps do
		
		--============================
		-- HANDLE PROCESSOR (CANCEL OR NOT)
		--============================
		if not Processor.CheckTerrainGenerationEnabled() then
			break
		end
		
		--============================
		-- CREATE WORLDX
		--============================
		local worldX = xi + FinalizedValues.CenterPosition.X
		
		for zi = 0, FinalizedValues.Size.Z, FinalizedValues.Steps do
			
			--============================
			-- HANDLE PROCESSOR (CANCEL OR NOT)
			--============================
			if not Processor.CheckTerrainGenerationEnabled() then
				break
			end
			
			--============================
			-- CREATE WORLDZ
			--============================
			local worldZ = zi + FinalizedValues.CenterPosition.Z

			--============================
			-- GET MATERIALNOISE
			--============================
			MaterialNoise = SeemTerrainGen_1_Utils.GetMaterialNoise(worldX, worldZ)

			--============================
			-- GET (FINALIZED-)DYNAMIC VALUES
			--============================
			local FinalizedDynamicValues = SeemTerrainGen_1_Utils.GetFinalizedDynamicValues(
				Materials,
				MaterialNoise
			)
			
			--============================
			-- GET FINAL MATERIALLIST
			--============================
			local FinalMaterialList = SeemTerrainGen_1_Utils.GetFinalMaterialList(
				FinalizedValues,
				FinalizedDynamicValues
			)
			
			-- what would you do if your brother is so much better?
			
			--============================
			-- DEFINE THE FIRST NOISE (that's why I call it "raw")
			--============================
			local raw = math.noise(worldX * FinalizedDynamicValues.NoiseScale, worldZ * FinalizedDynamicValues.NoiseScale, FinalizedValues.Seed)

			--============================
			-- FBM (fractal brownian motion)
			--============================
			if FinalizedValues.Octaves then
				raw = SeemTerrainGen_1_Utils.GetFBM(
					FinalizedDynamicValues,
					FinalizedValues,
					worldX,
					worldZ
				)
			end
			
			--============================
			-- FINALIZE RAW-NOISE (OFFSET, etc.)
			--============================
			raw = raw + 0.5 -- offset so we stay in 0-1 range instead of -0.5 to 0.5
			raw = math.clamp(raw, 0, 1) -- safe clamp (noise can have spikes)
			
			--============================
			-- CREATE & APPLY POWER (EXPONENTIAL CURVE)
			--============================
			local powered = math.pow(raw, FinalizedDynamicValues.Power) -- exponential curve for flattened areas; like a push-controller
			local worldY = (powered * FinalizedDynamicValues.Amplitude) -- actually apply to Amplitude so we are not in 0-1 range anymore

			--============================
			-- SDF (signed distance function)
			--============================
			if FinalizedValues.Falloff and FinalizedValues.Falloff.Enabled == true then
				worldY = SeemTerrainGen_1_Utils.GetSDF(
					FinalizedValues,
					worldX, worldY, worldZ,
					midX, midZ,
					halfX, halfZ
				)
			end

			--============================
			-- DEFINE POSITION AND TOP FALLOFF MATERIAL
			--============================
			local NewPosition = Vector3.new(worldX, worldY + FinalizedValues.CenterPosition.Y, worldZ)
			local PreservedMaterial = Enum.Material.Water
			
			--============================
			-- DEFINE THRESHOLDS (LAST AND CURRENT)
			--============================
			local LastThreshold = 0
			local currentThreshold = 0
			
			--============================
			-- FIND BIOME (LOOP THROUGH BIOME)
			--============================
			for i, Biome in ipairs(Materials.MaterialsList) do
				
				--============================
				-- CREATE BIOME FOLDER
				--============================
				local CurrentBiomeTable = SeemTerrainGen_1_Utils.CreateDataBiomeFolder(IterationTable, Biome)
				
				-- ..  .... .- - .  -.-. .- -. -.-. . .-. .-.-.-
				
				--============================
				-- HANDLE CURRENT-THRESHOLD (FOR SPIKES)
				--============================
				currentThreshold = Biome.Threshold
				if i == #Materials.MaterialsList then
					currentThreshold = 100 -- for spikes when we are in the last threshold
				end

				--============================
				-- GET FINALIZED-BIOME-VALUES
				--============================
				local FinalizedBiomeValues = SeemTerrainGen_1_Utils.GetFinalizedBiomeValues(
					Biome,
					FinalizedValues,
					worldX, worldZ,
					currentThreshold
				)
				
				--============================
				-- CHECK IF WE ARE IN THE RIGHT BIOME
				--============================
				if MaterialNoise <= FinalizedBiomeValues.Threshold and MaterialNoise >= LastThreshold then
					-- we have found the correct biome
					
					--============================
					-- SET THE BIOME-FALLBACKMATERIAL
					--============================
					PreservedMaterial = Biome.FallbackMaterial
					
					--============================
					-- FIND RANGE(LAYER) (LOOP THROUGH BIOME-LAYERS)
					--============================
					for Range: string, MatList: Types.SingleLayer in pairs(Biome.Layers) do
	
						local CurrentRangeTable = SeemTerrainGen_1_Utils.CreateDataRangeFolder(IterationTable, CurrentBiomeTable, Range)

						--============================
						-- DEFINE START- AND END-NUM
						--============================
						local StartNumStr = Range:match("^[%p%d]+")
						local EndNumStr = Range:match("[%p%d]+$")
						local StartNum = tonumber(StartNumStr)
						local EndNum = tonumber(EndNumStr)
						
						if not StartNum or not EndNum then continue end
						
						--============================
						-- FIND RANGE(LAYER) (LOOP THROUGH RANGE)
						--============================
						for iIn, InnerMatList in ipairs(MatList.List) do
	
							local FinalizedLayerValues = SeemTerrainGen_1_Utils.GetFinalizedLayerValues(
								Biome,
								FinalizedValues,
								worldX, worldZ,
								NewPosition
							)
							
							--============================
							-- CHECK IF WE ARE IN THE CORRECT(ALLOWED) LAYER (HEIGHT)
							--============================
							if FinalizedLayerValues.checkY >= StartNum and FinalizedLayerValues.checkY <= EndNum then
								-- we have found the correct layer(height material layer)
								
								--============================
								-- GET FINALIZED-INNER-MATERIAL-VALUES
								--============================
								local FinalizedInnerMaterialValues = SeemTerrainGen_1_Utils.GetFinalizedInnerMaterialValues(
									MatList,
									FinalizedValues,
									worldX, worldZ
								)
								
								-- it's so strange being the different one, even when you have no idea.
								-- a person always needing to watch you because you are "different".
								
								--============================
								-- DEFINE THRESHOLDS (LAST & CURRENT)
								--============================
								local LastInnerThreshold = 0
								local CurrentInnerThreshold
								
								--============================
								-- GET FINALIZED SAME-MATERIAL-LEVEL-VALUES
								--============================
								local FinalizedSameMaterialLevelValues = SeemTerrainGen_1_Utils.GetFinalizedSameMaterialLevelValues(
									MatList,
									FinalizedValues,
									worldX, worldZ
								)

								--============================
								-- HANDLE CURRENT-INNER-THRESHOLD (FOR SPIKES)
								--============================
								CurrentInnerThreshold = InnerMatList.Threshold + (0.5 * FinalizedSameMaterialLevelValues.SameMaterialLevelNoiseStrength)
								if iIn == #MatList.List then
									CurrentInnerThreshold = 100 
								end
								
								--============================
								-- CHECK IF WE ARE IN THE CORRECT INNER-MATERIAL (-AREA/NOISE)
								--============================
								if FinalizedInnerMaterialValues.InnerMaterialNoise <= CurrentInnerThreshold and FinalizedInnerMaterialValues.InnerMaterialNoise >= LastInnerThreshold then
									-- we have found the correct inner-material (-area/noise)
									
									--============================
									-- CHECK IF WE ARE IN THE RIGHT INNER-MATERIAL (-AREA/NOISE)
									--============================
									PreservedMaterial = InnerMatList.Material

									--============================
									-- DEFINE DEEP-DATA
									--============================
									if not InnerMatList._Positions then
										InnerMatList._Positions = {{pos = NewPosition, mat = InnerMatList.Material}}
									else 
										table.insert(InnerMatList._Positions :: {{ mat: Enum.Material, pos: Vector3 }}, {pos = NewPosition, mat = InnerMatList.Material})
									end

									--============================
									-- CREATE DATA-MATERIAL-FOLDER
									--============================
									local CurrentMaterialFolder = SeemTerrainGen_1_Utils.CreateDataMaterialFolder(
										CurrentRangeTable,
										PreservedMaterial
									)

									break
								end	

								--============================
								-- UPDATE LAST-INNTER-THRESHOLD
								--============================
								LastInnerThreshold = CurrentInnerThreshold
							end
						end
						
					end
					
					--============================
					-- BREAK TO SAVE PERFORMANCE (No unnecessary loops)
					--============================
					break
				end
				
				--============================
				-- UPDATE LAST-THRESHOLD
				--============================
				LastThreshold = FinalizedBiomeValues.Threshold
			end

			terrain:FillBall(NewPosition, FinalizedValues.BallRadius, PreservedMaterial)

			--============================
			-- ADD THICKNESS IF DESIRED
			--============================
			if FinalizedValues.Thickness ~= nil then
				SeemTerrainGen_1_Utils.AddThickness(
					FinalizedValues,
					NewPosition,
					PreservedMaterial
				)
			end
		
			--============================
			-- HANDLE BATCHING
			--============================
			if FinalizedValues.BatchingEnabled then
				if (os.clock() - startTime) >= FinalizedValues.BatchTime then
					task.wait(FinalizedValues.BatchWait)

					startTime = os.clock()
				end
			end
		end
		
		--============================
		-- HANDLE BATCHING
		--============================
		if FinalizedValues.BatchingEnabled then
			task.wait(FinalizedValues.WaitDuration)
		end
	end
	
	CurrentIterationTable = IterationTable
	
	--============================
	-- "RESET" PROCESSOR TO TRUE
	--============================
	Processor.EnableTerrainGeneration() -- automatically enable(so we dont need another function to resume generation)
end

-- LoadProps
function SeemTerrainGen1.CreateFolders()
	local SeemTerrainTemp = workspace.SeemTerrain.Temp -- get the latest always
	
	local function RefreshTempFolder()
		for i, v in pairs(SeemTerrainTemp:GetChildren()) do
			v:Destroy()
		end
	end
	
	--RefreshTempFolder()
	
	local function CreateFolder()
		local NewFolder = Instance.new("Folder")
		NewFolder.Parent = SeemTerrainTemp

	end
	
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
		
		warn("Successfully loaded Props.")
	end
end

function SeemTerrainGen1.GenerateProps(
	Materials: Types.MaterialsList
)	
	--============================
	-- IMPORTANT VARIABLES and FALLBACKS
	--============================
	local startTime = os.clock() -- for batching.
	local LastInstPosition: Vector3 -- for Instance

	local FinalizedValues = SeemTerrainGen_1_Utils.GetFinalizedValues(Materials) -- gets the finalized values (fallback-checks, etc.)

	--============================
	-- SETUP SeemTerrainGen_1_Utils WITH FINALIZED-VALUES
	--============================
	SeemTerrainGen_1_Utils.Setup_STG_1_Utils(FinalizedValues)

	--============================
	-- IMPORTANT VARIABLES
	--============================
	local halfX, halfZ = FinalizedValues.Size.X / 2, FinalizedValues.Size.Z / 2
	local midX = FinalizedValues.CenterPosition.X + halfX
	local midZ = FinalizedValues.CenterPosition.Z + halfZ

	-- everything is stored in this table. Just look it up(ctrl + F)
	local IterationTable: {[any]: any} = {}

	local MaterialNoise = 0

	for xi = 0, FinalizedValues.Size.X, FinalizedValues.InstancingSteps do

		--============================
		-- HANDLE PROCESSOR (CANCEL OR NOT)
		--============================
		if not Processor.CheckPropGenerationEnabled() then
			break
		end

		--============================
		-- CREATE WORLDX
		--============================
		local worldX = xi + FinalizedValues.CenterPosition.X

		for zi = 0, FinalizedValues.Size.Z, FinalizedValues.InstancingSteps do

			--============================
			-- HANDLE PROCESSOR (CANCEL OR NOT)
			--============================
			if not Processor.CheckPropGenerationEnabled() then
				break
			end

			--============================
			-- CREATE WORLDZ
			--============================
			local worldZ = zi + FinalizedValues.CenterPosition.Z

			--============================
			-- GET MATERIALNOISE
			--============================
			MaterialNoise = SeemTerrainGen_1_Utils.GetMaterialNoise(worldX, worldZ)

			--============================
			-- GET (FINALIZED-)DYNAMIC VALUES
			--============================
			local FinalizedDynamicValues = SeemTerrainGen_1_Utils.GetFinalizedDynamicValues(
				Materials,
				MaterialNoise
			)

			--============================
			-- GET FINAL MATERIALLIST
			--============================
			local FinalMaterialList = SeemTerrainGen_1_Utils.GetFinalMaterialList(
				FinalizedValues,
				FinalizedDynamicValues
			)

			-- what would you do if your brother is so much better?

			--============================
			-- DEFINE THE FIRST NOISE (that's why I call it "raw")
			--============================
			local raw = math.noise(worldX * FinalizedDynamicValues.NoiseScale, worldZ * FinalizedDynamicValues.NoiseScale, FinalizedValues.Seed)

			--============================
			-- FBM (fractal brownian motion)
			--============================
			if FinalizedValues.Octaves then
				raw = SeemTerrainGen_1_Utils.GetFBM(
					FinalizedDynamicValues,
					FinalizedValues,
					worldX,
					worldZ
				)
			end

			--============================
			-- FINALIZE RAW-NOISE (OFFSET, etc.)
			--============================
			raw = raw + 0.5 -- offset so we stay in 0-1 range instead of -0.5 to 0.5
			raw = math.clamp(raw, 0, 1) -- safe clamp (noise can have spikes)

			--============================
			-- CREATE & APPLY POWER (EXPONENTIAL CURVE)
			--============================
			local powered = math.pow(raw, FinalizedDynamicValues.Power) -- exponential curve for flattened areas; like a push-controller
			local worldY = (powered * FinalizedDynamicValues.Amplitude) -- actually apply to Amplitude so we are not in 0-1 range anymore

			--============================
			-- SDF (signed distance function)
			--============================
			if FinalizedValues.Falloff and FinalizedValues.Falloff.Enabled == true then
				worldY = SeemTerrainGen_1_Utils.GetSDF(
					FinalizedValues,
					worldX, worldY, worldZ,
					midX, midZ,
					halfX, halfZ
				)
			end

			--============================
			-- DEFINE POSITION AND TOP FALLOFF MATERIAL
			--============================
			local NewPosition = Vector3.new(worldX, worldY + FinalizedValues.CenterPosition.Y, worldZ)
			local PreservedMaterial = Enum.Material.Water

			--============================
			-- DEFINE THRESHOLDS (LAST AND CURRENT)
			--============================
			local LastThreshold = 0
			local currentThreshold = 0

			--============================
			-- FIND BIOME (LOOP THROUGH BIOME)
			--============================
			for i, Biome in ipairs(Materials.MaterialsList) do

				--============================
				-- CREATE BIOME FOLDER
				--============================
				local CurrentBiomeTable = SeemTerrainGen_1_Utils.CreateDataBiomeFolder(IterationTable, Biome)

				-- ..  .... .- - .  -.-. .- -. -.-. . .-. .-.-.-

				--============================
				-- HANDLE CURRENT-THRESHOLD (FOR SPIKES)
				--============================
				currentThreshold = Biome.Threshold
				if i == #Materials.MaterialsList then
					currentThreshold = 100 -- for spikes when we are in the last threshold
				end

				--============================
				-- GET FINALIZED-BIOME-VALUES
				--============================
				local FinalizedBiomeValues = SeemTerrainGen_1_Utils.GetFinalizedBiomeValues(
					Biome,
					FinalizedValues,
					worldX, worldZ,
					currentThreshold
				)

				--============================
				-- CHECK IF WE ARE IN THE RIGHT BIOME
				--============================
				if MaterialNoise <= FinalizedBiomeValues.Threshold and MaterialNoise >= LastThreshold then
					-- we have found the correct biome

					--============================
					-- SET THE BIOME-FALLBACKMATERIAL
					--============================
					PreservedMaterial = Biome.FallbackMaterial

					--============================
					-- FIND RANGE(LAYER) (LOOP THROUGH BIOME-LAYERS)
					--============================
					for Range: string, MatList: Types.SingleLayer in pairs(Biome.Layers) do

						local CurrentRangeTable = SeemTerrainGen_1_Utils.CreateDataRangeFolder(IterationTable, CurrentBiomeTable, Range)

						--============================
						-- DEFINE START- AND END-NUM
						--============================
						local StartNumStr = Range:match("^[%p%d]+")
						local EndNumStr = Range:match("[%p%d]+$")
						local StartNum = tonumber(StartNumStr)
						local EndNum = tonumber(EndNumStr)

						if not StartNum or not EndNum then continue end

						--============================
						-- FIND RANGE(LAYER) (LOOP THROUGH RANGE)
						--============================
						for iIn, InnerMatList in ipairs(MatList.List) do

							local FinalizedLayerValues = SeemTerrainGen_1_Utils.GetFinalizedLayerValues(
								Biome,
								FinalizedValues,
								worldX, worldZ,
								NewPosition
							)

							--============================
							-- CHECK IF WE ARE IN THE CORRECT(ALLOWED) LAYER (HEIGHT)
							--============================
							if FinalizedLayerValues.checkY >= StartNum and FinalizedLayerValues.checkY <= EndNum then
								-- we have found the correct layer(height material layer)

								--============================
								-- GET FINALIZED-INNER-MATERIAL-VALUES
								--============================
								local FinalizedInnerMaterialValues = SeemTerrainGen_1_Utils.GetFinalizedInnerMaterialValues(
									MatList,
									FinalizedValues,
									worldX, worldZ
								)

								-- it's so strange being the different one, even when you have no idea.
								-- a person always needing to watch you because you are "different".

								--============================
								-- DEFINE THRESHOLDS (LAST & CURRENT)
								--============================
								local LastInnerThreshold = 0
								local CurrentInnerThreshold

								--============================
								-- GET FINALIZED SAME-MATERIAL-LEVEL-VALUES
								--============================
								local FinalizedSameMaterialLevelValues = SeemTerrainGen_1_Utils.GetFinalizedSameMaterialLevelValues(
									MatList,
									FinalizedValues,
									worldX, worldZ
								)

								--============================
								-- HANDLE CURRENT-INNER-THRESHOLD (FOR SPIKES)
								--============================
								CurrentInnerThreshold = InnerMatList.Threshold + (0.5 * FinalizedSameMaterialLevelValues.SameMaterialLevelNoiseStrength)
								if iIn == #MatList.List then
									CurrentInnerThreshold = 100 
								end

								--============================
								-- CHECK IF WE ARE IN THE CORRECT INNER-MATERIAL (-AREA/NOISE)
								--============================
								if FinalizedInnerMaterialValues.InnerMaterialNoise <= CurrentInnerThreshold and FinalizedInnerMaterialValues.InnerMaterialNoise >= LastInnerThreshold then
									-- we have found the correct inner-material (-area/noise)

									--============================
									-- CHECK IF WE ARE IN THE RIGHT INNER-MATERIAL (-AREA/NOISE)
									--============================
									PreservedMaterial = InnerMatList.Material
									
									--============================
									-- INSTANCING
									--============================
									if InnerMatList.Instancing then

										--============================
										-- DEFINE LAST-INST-THRESHOLD
										--============================
										local LastInstThreshold = 0

										--============================
										-- FIND INST (LOOP THROUGH InnerMatList.Instancing)
										--============================
										for iInstTbl, InstTbl in pairs(InnerMatList.Instancing) do

											--============================
											-- HANDLE INST-THRESHOLD (FOR SPIKES)
											--============================
											local InstThreshold = InstTbl.Threshold
											if iInstTbl == #InnerMatList.Instancing then
												InstThreshold = 100
											end

											--============================
											-- CHECK IF WE ARE IN THE CORRECT INST-AREA(THRESHOLD)
											--============================
											if FinalizedInnerMaterialValues.InnerMaterialNoise <= InstThreshold and FinalizedInnerMaterialValues.InnerMaterialNoise >= LastInstThreshold then
												-- we found the correct Instance-Table

												--============================
												-- GET SINGLE-INST-NOISE
												--============================
												local SingleInstNoise = SeemTerrainGen_1_Utils.GetSingleInstNoise(
													FinalizedValues,
													worldX, worldZ
												)

												--============================
												-- DECLARE LAST-SINGLE-INST-THRESHOLD
												--============================
												local LastSingleInstThreshold = 0

												--============================
												-- FIND CORRECT SINGLE-INST-AREA(NOISE)
												--============================
												for iSingleInstTbl, SingleInstTbl in pairs(InstTbl.Instances) do

													local FinalizedSingleInstTbl = SeemTerrainGen_1_Utils.GetFinalizedSingleInstTbl(SingleInstTbl)

													if iSingleInstTbl == #InstTbl.Instances then
														FinalizedSingleInstTbl.Threshold = 100
													end

													--============================
													-- CHECK IF WE (SINGLE-INST-NOISE) ARE IN THE CORRECT AREA
													--============================
													if SingleInstNoise <= FinalizedSingleInstTbl.Threshold and SingleInstNoise >= LastSingleInstThreshold then
														local inst = FinalizedSingleInstTbl.Instance:Clone()
														-- we set the parent later, so we do everything on the ram first so we have way more performance.

														--============================
														-- GET INST-NOISE
														--============================
														local instNoise = SeemTerrainGen_1_Utils.GetInstNoise(
															FinalizedValues,
															worldX, worldZ
														)

														--============================
														-- DECLARE INST-POSITION
														--============================
														local InstPos = NewPosition + Vector3.new(instNoise, 0, instNoise)

														--============================
														-- START RAYCASTING FOR SLOPE, ETC.
														--============================
														local raycastResult = SeemTerrainGen_1_Utils.GetRaycastResult(InstPos)

														if raycastResult then
															--============================
															-- CHECK SLOPE
															--============================
															local SlopeExceeded = SeemTerrainGen_1_Utils.SlopeExceeded(raycastResult, FinalizedSingleInstTbl)
															if SlopeExceeded == true then
																inst:Destroy()
																continue
															end

															--============================
															-- CHECK HEIGHT
															--============================
															local HeightExceeded = SeemTerrainGen_1_Utils.HeightExceeded(raycastResult, FinalizedSingleInstTbl)
															if HeightExceeded == true then
																inst:Destroy()
																continue
															end

															--============================
															-- GET DIRECTORY TO PUT INSTANCE IN
															--============================
															local BiomeFolder = IterationTable[Biome.BiomeName] 
															local RangeFolder = BiomeFolder[Range]
															local MaterialFolder = RangeFolder[tostring(PreservedMaterial)]

															--============================
															-- GET/CREATE INSTANCE FOLDER
															--============================
															local InstancesFolder = SeemTerrainGen_1_Utils.CreateInstancesFolder(MaterialFolder)
															local TotalPropCount = #InstancesFolder

															-- and then you are taken to the next step.
															-- I also wanted to live a normal life. Are you living a normal life?

															--============================
															-- PUT INST IN INSTANCES-FOLDER
															--============================
															table.insert(InstancesFolder, inst)
															inst.Name = FinalizedSingleInstTbl.Instance.Name.."_"..TotalPropCount

															--============================
															-- HANDLE INSTANCE (CLASS-CHECK, POSITIONING, ETC.)
															--============================
															SeemTerrainGen_1_Utils.HandleInstance(raycastResult, FinalizedSingleInstTbl, inst)

															--============================
															-- UPDATE LAST-INST-POSITION
															--============================
															LastInstPosition = raycastResult.Position + Vector3.new(0, (FinalizedSingleInstTbl.Offset or 0), 0)
														end

														--============================
														-- BREAK TO SAVE PERFORMANCE (no unecessary loops)
														--============================
														break	
													end

													--============================
													-- UPDATE LAST-SINGLE-INST-THRESHOLD
													--============================
													LastSingleInstThreshold = FinalizedSingleInstTbl.Threshold
												end

												--============================
												-- BREAK TO SAVE PERFORMANCE (no unecessary loops)
												--============================
												break
											end

											--============================
											-- UPDATE LAST-INST-THRESHOLD
											--============================
											LastInstThreshold = InstThreshold
										end
									end

									--============================
									-- DEFINE DEEP-DATA
									--============================
									if not InnerMatList._Positions then
										InnerMatList._Positions = {{pos = NewPosition, mat = InnerMatList.Material}}
									else 
										table.insert(InnerMatList._Positions :: {{ mat: Enum.Material, pos: Vector3 }}, {pos = NewPosition, mat = InnerMatList.Material})
									end

									--============================
									-- CREATE DATA-MATERIAL-FOLDER
									--============================
									local CurrentMaterialFolder = SeemTerrainGen_1_Utils.CreateDataMaterialFolder(
										CurrentRangeTable,
										PreservedMaterial
									)

									break
								end	

								--============================
								-- UPDATE LAST-INNTER-THRESHOLD
								--============================
								LastInnerThreshold = CurrentInnerThreshold
							end
						end

					end

					--============================
					-- BREAK TO SAVE PERFORMANCE (No unnecessary loops)
					--============================
					break
				end

				--============================
				-- UPDATE LAST-THRESHOLD
				--============================
				LastThreshold = FinalizedBiomeValues.Threshold
			end

			--============================
			-- HANDLE BATCHING
			--============================
			if FinalizedValues.BatchingEnabled then
				if (os.clock() - startTime) >= FinalizedValues.BatchTime then
					task.wait(FinalizedValues.BatchWait)

					startTime = os.clock()
				end
			end
		end

		--============================
		-- HANDLE BATCHING
		--============================
		if FinalizedValues.BatchingEnabled then
			task.wait(FinalizedValues.WaitDuration)
		end
	end

	CurrentIterationTable = IterationTable

	--============================
	-- "RESET" PROCESSOR TO TRUE
	--============================
	Processor.EnablePropGeneration() -- automatically enable(so we dont need another function to resume generation)
end

-- is just batching, idk why I called it chunking
function SeemTerrainGen1.ClearProps(
	ChunkConfig: Types.ChunkConfigType
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


