--!strict

--[[
This module is simply used for handling operations such as Generations.
By "handling" are controlls meant like start and stopping.
]]

local Processor = {}

Processor.TerrainGenerationEnabled = true
Processor.PropGenerationEnabled = true

function Processor.CheckTerrainGenerationEnabled()
	if Processor.TerrainGenerationEnabled then
		return true
	else 
		return false
	end
end

function Processor.CheckPropGenerationEnabled()
	if Processor.PropGenerationEnabled then
		return true
	else 
		return false
	end
end

function Processor.EnableTerrainGeneration()
	Processor.TerrainGenerationEnabled = true
end

function Processor.EnablePropGeneration()
	Processor.PropGenerationEnabled = true
end

function Processor.CancelTerrainGeneration()
	Processor.TerrainGenerationEnabled = false
end

function Processor.CancelPropGeneration()
	Processor.PropGenerationEnabled = false
end

return Processor
