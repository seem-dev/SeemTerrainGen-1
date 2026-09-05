-- you really can't trust anyone than your family
-- but why do people switch up so fast?? 
-- are you sure your "friends" are not talking bad about you?

export type SingleLayer = { 
	--[[
	SameMaterialLevelNoise is applied to the thresholds of the layer thresholds to
	get more realism (so the thresholds are not static and completely linear, which would be like using the terrain editor's paint tool with a big brush size)
	]]
	SameMaterialLevelNoiseScale: number?, -- 0-1: controlls how realistic the layer-threshold-noise should be; softer/less realistic(less noisy) = low, more realistic(more noisy) = high
	SameMaterialLevelNoiseLength: number?, -- studs: controlls the length of the nois (the "points" are being pushed out more)
	SameMaterialLevelNoiseSeed: number?, -- infinite

	--[[
	works like MaterialNoiseScale;
	InnerMaterialNoise controlls how much the inner materials (materials of a layer)
	should be put/squashed in the layer.
	Works strongly together with SameMaterialLevelNoise (visible effects may only come dependant on SameMaterialLevelNoise)
	]]
	InnerMaterialNoiseScale: number?, -- 0-1: controlls how much the inner materials (materials of a layer) should be put/squashed in(and so together). less mixed (less-distributed-materials) = lower, more mixed (more-distributed-materials) = higher
	InnerMaterialNoiseStrength: number?, -- studs: controlls the strength of the amount of distributed materials 
	InnerMaterialNoiseSeed: number?, -- infinite

	List: {
		{
			Threshold: number, -- the threshold for this layer
			Material: Enum.Material, -- the material for this layer

			-- stores all the positions of each loops. I've stopped using this at some point, because
			-- i didn't have a use for this and loading it in the created folders too, just was unnecessary..
			-- still works though. You can completely use this (it is meant for e.g biome-detection, coordinates, metadata, etc.)
			_Positions: {{pos: Vector3, mat: Enum.Material}}?,
			
			-- optional Instancing
			Instancing: {
				-- instance tbl
				{
					Threshold: number, -- the threshold of the instance-category

					Instances: { -- instance-group in instance-category
						{
							Threshold: number, -- 0-1 the threshold of the instance
							Instance: Instance, -- the instance
							MaxHeight: number, -- studs: max height of the instance. independant of the range
							MaxSlope: number, -- deg: the maximum slope of the instance. this controlls wether the instance should spawn on e.g cliffs or smooth ills, flattened areas, etc. just play around to find your fitting space: > 0
							Offset: number?, -- the offset on the y-axis (negative also allowed)
							FaceNormal: boolean?, -- wethere the instance should face the normal of the ground (raycasting)

							-- these rotations are used to get more realism(variation); rotating the instance on axis
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

							-- these rotations are used to get more realism(variation); rotating the instance on axis
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
	-- the string here is the range. Format:
	--(starting height) to (ending height)
	-- pay attention to the whitespaces(they should be included to).
	-- both heights may be negative, but ending height must always be bigger than starting height.
	-- how to know which heights to do? Simply generate a prototype first(first-generation),
	-- then spawn a part and move it to whereever you want your materials(layers) to be, then copy the position, etc.
	[string]: SingleLayer
}

export type MaterialsList = {
	-- have you talked bad about a friend before?
	-- if you did, imagine how many are doing this too - about you.

	BallRadius: number,
	Size: Vector3, -- size of the map
	CenterPosition: Vector3, -- from where the Generation should start. The Generation is going to the +x and +z of the global axis.
	Seed: number, -- infinite
	
	--[[
	Used in GenerateProps. InstancingSteps is the same as Step, but just for GenerateProps.
	]]
	InstancingSteps: number, -- density: > 1: less density(instances being placed) = higher (e.g 50), more density = lower (e.g 30). Don't go to low as this may freeze Studio (be careful at < 15-20). like steps in GenerateTerrain
	InstancingSeed: number, -- infinite
	
	--[[
	InstDistribution noise controlls the noise distribution of the instances:
	e.g a lower scale that the instances-borders are smoothly ending.
	(think of like a top-down view from a forest)
	]]
	InstDistributionScale: number, -- 0-1: more realistic instance-ending = higher, smoother/less realistic instance-ending = lower
	InstDistributionSeed: number, -- infinite
	InstDistributionLength: number, -- studs

	Falloff: { 
		Enabled: boolean, -- wethere falloff is enabled or not
		Start: number, -- where the falloff should start within the map/texture. 0-1: e.g 0.5 everything till 0.5 (0.5 in 50% of the map's radius to the center) is a normal map, but then at 0.5% the falloff(wether reversed or not) is applied.
		Strength: number, -- 0-inf
		Interpolation: "linear" | "smoothstep" | "KenPerlin_smoothstep", -- only smoothstep supported currently
		CornerRadius: number?, -- relative to its own Sizes(X and Z)
		FalloffRadius: number?, -- studs; works like CornerRadius
		Reversed: boolean?, -- wether the falloff should be reversed or not (true are like "organic walls", false is a normal falloff)
		FallOffAxis: "X" | "Z" | "XZ"? -- choose XZ (only supported one)
	},
	
	Thickness: {
		ThicknessNumber: number, -- how much of a thickness/depth (loops) should be proceeded
		Direction: "up" | "down", -- where the direction should be done.
		Steps: number?, -- > 1 (e.g 1) steps of the loops. Remember your BallRadius to set the correct step here, so you save speed and performance.
		Power: number? -- > 0 (e.g 5) Multiplied to the Steps(in thickness), meaning this acts as a controller of how much to spread the thickness.
	},


	--[[
	instNoise is applied to the position of the point on the x and z (noisy offset)
	]]
	instNoiseScale: number, -- 0-1: controlls on how randomized(noisy) the x&z offset should be.
	instNoiseLength: number, -- studs: controlls the length of the noisy offset. more grid/perfect-like = lower (e.g 15), more realistic = higher (e.g 300)
	instNoiseSeed: number, -- infinite

	WaitDuration: number, -- called every x loop
	Steps: number, -- faster/low-resolution = higher (e.g 5), slower/better-resolution = lower (e.g 2)

	-- batching so studio doesn't freeze
	BatchingEnabled: boolean,
	BatchTime: number, -- when the wait is called (0.02 is what I use, but is that important, or am I just being laughed at?)
	BatchWait: number, -- wait-time: set this to low or directly 0(will be rounded to ~0.03 due to task.wait). This is called every z loop.

	-- these tables indicate biome-properties.
	-- you always need to make a new value in each table for another biome
	Amplitudes: {number}, -- amplitudes, describing the height of the mountains/hills
	NoiseScales: {number}, -- 0-1: softer/stretched/longer = smaller, steeper/shortened/smaller = higher
	Powers: {number}, -- how much flattened areas there should be (smaller mountains, less hills; everything(hills, mountains) are sunken in the ground)
					  -- 0-1: push mountains/hills even more out (than normal), > 1: more flattened areas(as described above)

	-- Octaves (FBM)
	--[[
	fbm are layers of different noise-maps being stacked onto each other, meaning
	you get more details (as in each octave the map gets more densed; scale is being pushed).
	Use this for setting the details of the map (e.g octave of 1 makes the map, like mountains really smooth)
	]]
	lacunarities: {number}, -- > 1 controlls how many details are being pushed into the texture, meaning more details, which results in more steepness
	gains: {number}, -- 0-1: directly controlls how steep the points of the noise-maps should be (they are being pushed up)
	RandomOctaveSeed: boolean, -- wethere the generated fbm noise-maps, should have a different seed (meaning they are not stacked onto each other with having their position; mostly set to false. But making it true is also cool!)
	Octaves: number, -- octaves for fbm (how many noise-maps should be generated). 1-5 makes the biggest visible effect, 5-10 still gives visible changes, but > 10 does not make any visible change at all.
	
	--[[
	Remember the thresholds when adding a new table(like biome, layer, singlelayer, etc!).
	They need to be in order(from small to big(1 at the end)).
	If you don't understand what I mean with that, look at some example MaterialLists.
	]]
	MaterialsList: {
		{ -- biome
			BiomeName: string, -- biome name, used in temporary memory table and folder in loaded-props(workspace)
			Threshold: number, -- threshold, 0-1
			FallbackMaterial: Enum.Material, -- fallback material if you've configured something wrong (e.g CrackedLaval so you see where your mistake is)
			_Positions: {{pos: Vector3, mat: Enum.Material}}?,
			Layers: Layers, -- material layers storing instances, materials

			-- height material blending
			LayerNoiseScale: number?, -- 0-1: how realistic and randomized(noisy) the layer-blending should be
			LayerNoiseLength: number?,  -- studs: how long the blending should be (e.g 15)

			-- biome blending (with other biomes)
			BiomNoiseLength: number?, -- studs: how long the blending should be (e.g 15)
			BiomNoiseScale: number?, -- 0-1: how realistic and randomized(noisy) the layer-blending should be
		}
	},

	MaterialNoiseScale: number?, -- 0-1. this controlls how many of the biomes (in MaterialsList) should be put/squashed into the map. less biomes/bigger biomes = low, more biomes/smaller biomes = high
	MaterialNoiseStrength: number?, -- mostly 1, must be > 0. never tested it with lower than 0, but is completely ok from the logic. this acts just like a strength (easier controll for MaterialNoiseScale)
	MaterialNoiseSeed: number? -- infinite
}

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
	
	BallRadius = 5,
	CenterPosition = GetBottomLeftPositionOfPart(workspace.Baseplate),
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
		FallOffAxis = "XZ",
		FalloffRadius = nil,
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
	
	BatchingEnabled = false,
	BatchTime = 0.1,
	BatchWait = 0.03,
	
	WaitDuration = 0.03,
	Steps = 3,
	
	
}

return MaterialList
