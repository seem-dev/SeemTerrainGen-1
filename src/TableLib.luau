--[[
    TableLib v1.0
    Author: Seem
    Published: 2025
    Description: A Lua utility library for shallow and deep table operations.
                 Provides copying, merging, searching, counting, and debugging helpers.

    License: MIT License

    MIT License

    Copyright (c) 2025 Seem

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
]]

--[[
PLEASE NOTE: This code may not be fully developed yet (e.g., bug fixes, etc.).
]]
local TableLib = {}

local function CheckType(givenTable)
	local TableType
	local count = 0
	local maxindex = 0

	for i, v in pairs(givenTable) do
		if typeof(i) == "number" then
			count += 1
			if i > maxindex then
				maxindex = i
			end
		else 
			TableType = "dictionary"
			return TableType, count, maxindex
		end
	end

	if count == maxindex then
		TableType = "array"
	else 
		TableType = "dictionary"
	end

	return TableType, count, maxindex
end

local function ShallowCopy(original)
	local copy = {}

	for i,v in pairs(original) do
		copy[i] = v
	end

	return copy
end

local function DeepCopy(original)
	local copy = {}

	local function recursive(givenTable, copyTable)
		for i, v in pairs(givenTable) do
			if typeof(v) == "table" then
				copyTable[i] = {}
				recursive(v, copyTable[i])
			else
				copyTable[i] = v
			end
		end
	end

	recursive(original, copy)

	return copy
end

local function ShallowCount(givenTable)
	local count = 0

	for i,v in pairs(givenTable) do
		count += 1
	end

	return count
end

local function DeepCount(givenTable)
	local KeyValue_Count = 0
	local Tbl_Count = 0

	local function recursive(tbl)
		for i,v in pairs(tbl) do
			if typeof(v) == "table" then
				Tbl_Count += 1
				recursive(v)
			else 
				KeyValue_Count += 1
			end

		end
	end

	recursive(givenTable)


	return KeyValue_Count, Tbl_Count
end

local function ShallowMerge(table1, table2, Table2OverwritesTable1)
	local copy = {}

	local function putInCopyWithoutDups(index, value, givenTable, priority:boolean)
		if priority then
			givenTable[index] = value
		else 
			if not givenTable[index] then
				givenTable[index] = value
			end
		end
	end

	for T1i,T1v in pairs(table1) do
		putInCopyWithoutDups(T1i, T1v, copy, false)
	end

	if Table2OverwritesTable1 then
		for T2i, T2v in pairs(table2) do
			putInCopyWithoutDups(T2i, T2v, copy, true)
		end
	else 
		for T2i, T2v in pairs(table2) do
			putInCopyWithoutDups(T2i, T2v, copy, false)
		end
	end

	return copy
end

local function DeepMerge_ValueBased(table1, table2, Table2OverwritesTable1)
	local copy = {}
	local DeepCopyT1 = DeepCopy(table1)
	copy = DeepCopyT1

	local function putInCopyWithoutDups(index, value, givenTable, priority:boolean)
		local tableType = CheckType(givenTable)

		if priority then
			givenTable[index] = value
		else 
			if tableType == "dictionary" then
				if not givenTable[index] then
					givenTable[index] = value
				end
			elseif tableType == "array" then
				if not table.find(givenTable, value) then
					table.insert(givenTable, value)
				end
			end

		end
	end

	local function recursive(tblToCopyValuesFrom, tblToPasteValuesInto)
		for i,v in pairs(tblToCopyValuesFrom) do
			if typeof(v) == "table" then
				if tblToPasteValuesInto[i] then
					local PTv = tblToPasteValuesInto[i]
					local PTi = i
					if typeof(PTv) == "table" then
						recursive(v, PTv)
					else
						if Table2OverwritesTable1 then
							putInCopyWithoutDups(PTi, PTv, tblToPasteValuesInto, true)
						else 
							putInCopyWithoutDups(PTi, PTv, tblToPasteValuesInto, false)
						end
					end
				else 
					tblToPasteValuesInto[i] = v
				end
			else
				if Table2OverwritesTable1 then-->>should table2 overwrite the copy(table1 - DeepCopyT1)?
					putInCopyWithoutDups(i, v, tblToPasteValuesInto, true)
				else
					putInCopyWithoutDups(i, v, tblToPasteValuesInto, false)
				end
			end
		end
	end

	recursive(table2, copy)

	return copy
end

local function DeepMerge_IndexBased(table1, table2, Table2OverwritesTable1)
	local copy = {}
	local DeepCopyT1 = DeepCopy(table1)
	copy = DeepCopyT1

	local function putInCopyWithoutDups(index, value, givenTable, priority:boolean)
		local tableType = CheckType(givenTable)

		if priority then
			givenTable[index] = value
		else 
			if tableType == "dictionary" then
				if not givenTable[index] then
					givenTable[index] = value
				end
			elseif tableType == "array" then
				if not givenTable[index] then
					givenTable[index] = value
				end
			end

		end
	end

	local function recursive(tblToCopyValuesFrom, tblToPasteValuesInto)
		for i,v in pairs(tblToCopyValuesFrom) do
			if typeof(v) == "table" then
				if tblToPasteValuesInto[i] then
					local PTv = tblToPasteValuesInto[i]
					local PTi = i
					if typeof(PTv) == "table" then
						recursive(v, PTv)
					else
						if Table2OverwritesTable1 then
							putInCopyWithoutDups(PTi, PTv, tblToPasteValuesInto, true)
						else 
							putInCopyWithoutDups(PTi, PTv, tblToPasteValuesInto, false)
						end
					end
				else 
					tblToPasteValuesInto[i] = v
				end
			else
				if Table2OverwritesTable1 then-->>should table2 overwrite the copy(table1 - DeepCopyT1)?
					putInCopyWithoutDups(i, v, tblToPasteValuesInto, true)
				else
					putInCopyWithoutDups(i, v, tblToPasteValuesInto, false)
				end
			end
		end
	end

	recursive(table2, copy)

	return copy
end

local function ShallowValueSearch(givenTable, Value)
	local MatchedValue
	for i,v in pairs(givenTable) do
		if v == Value then
			return v
		end
	end
end

local function DeepValueSearch(givenTable, Value)
	local function func(tbl, val)
		for i, v in pairs(tbl) do
			if typeof(v) == "table" then
				local foundKey = func(v, val)
				if foundKey ~= nil then
					return foundKey
				end
			else 
				if v == val then
					return i
				end
			end
		end
	end

	return func(givenTable, Value)
end

local function ShallowKeySearch(givenTable, Key)
	for i, v in pairs(givenTable) do
		if i == Key then
			return v 
		end
	end

	return nil
end

local function DeepKeySearch(givenTable, Key)
	for i, v in pairs(givenTable) do
		if i == Key then
			return v 
		end
		if typeof(v) == "table" then
			local found = DeepKeySearch(v, Key)
			if found then
				return found
			end
		end
	end

	return nil
end

local function ShallowGetValueOrKey(givenTable, Key, Value)
	for i, v in pairs(givenTable) do
		if (not Key or i == Key) and (not Value or v == Value) then
			return i, v
		end
	end
	return nil
end

local function DeepGetValueOrKey(givenTable, Key, Value)
	for i, v in pairs(givenTable) do
		if (not Key or i == Key) and (not Value or v == Value) then
			return i, v
		end

		if typeof(v) == "table" then
			local foundKey, foundValue = DeepGetValueOrKey(v, Key, Value)
			if foundKey then
				return foundKey, foundValue
			end
		end
	end

	return nil
end

local function GetParent(givenTable, Key, nth)
	local function findParent(tbl, child)
		for k, v in pairs(tbl) do
			if typeof(v) == "table" then
				if v[child] ~= nil then
					return k
				else
					local parent = findParent(v, child)
					if parent then return k end
				end
			end
		end
	end

	local parent = Key
	for i = 1, nth do
		parent = findParent(givenTable, parent)
		if not parent then return nil end
	end

	return parent
end

local function ShallowKeyDeleteByValue(givenTable, Value)
	local deleted = false

	for i, v in pairs(givenTable) do
		if v == Value then
			deleted = true
			givenTable[i] = nil
		end
	end

	if not deleted then
		return false, "Value was not found! Could not delete key."
	end

	return true
end

local function DeepKeyDeleteByValue(givenTable, Value)
	local deleted = false

	for i, v in pairs(givenTable) do
		if typeof(v) == "table" then
			local subDeleted = DeepKeyDeleteByValue(v, Value)
			if subDeleted then
				deleted = true
			end
		elseif v == Value then
			givenTable[i] = nil
			deleted = true
		end
	end

	if not deleted then
		return false, "Value was not found! Could not delete key."
	end
	return true
end

local function ShallowWarnTable(givenTable)
	for i,v in pairs(givenTable) do
		warn("i: "..tostring(i),"v: "..tostring(v))
	end
end

local function DeepWarnTable(givenTable)
	for i,v in pairs(givenTable) do
		if typeof(v) == "table" then
			DeepWarnTable(v)
		else
			warn("i: "..tostring(i),"v: "..tostring(v))
		end
	end
end

local function JSONLikeWarn(givenTable, Indent)

	local function IndentFunc(Key, Value, givenIndent)
		warn(string.rep(" ",givenIndent), Key, "=" ,tostring(Value))
	end

	local function Recursive(tbl, ToIndent)

		for i,v in pairs(tbl) do
			if typeof(v) == "table" then
				warn(string.rep(" ", ToIndent), i, "=")
				Recursive(v, ToIndent + Indent)
			else 
				IndentFunc(i, v, ToIndent)
			end
		end
	end

	Recursive(givenTable, 0)
end

local function JSONLikeExport(givenTable, Indent, Parent, Name: string)

	local mdl = Instance.new("ModuleScript")
	mdl.Name = "IterationPoints"
	mdl.Parent = Parent
	mdl.Name = Name

	local function IndentFunc(Key, Value, givenIndent)
		mdl.Source ..= string.rep(" ",givenIndent)..Key.."="..tostring(Value)
	end

	local function Recursive(tbl, ToIndent)

		for i,v in pairs(tbl) do
			if typeof(v) == "table" then
				mdl.Source ..= string.rep(" ", ToIndent)..i.."="
				Recursive(v, ToIndent + Indent)
			else 
				IndentFunc(i, v, ToIndent)
			end
		end
	end

	Recursive(givenTable, 0)
end

local function ConvertToFolders(givenTable, MasterParent: Instance, MaximumElapsedFrameTime: number)
	local ComputingTimeStart = os.clock()
	local startTime = os.clock()
		
	local function _func(_givenTable, _MasterParent: Instance)
		
		for i, v in pairs(_givenTable) do
			if not _MasterParent:FindFirstChild(i) then
				local Folder = Instance.new("Folder")
				Folder.Name = i
				Folder.Parent = _MasterParent
				
				-- special case for GenerateProps Function in LandAlg
				if i == "Instances" then
					for i, Inst: Instance in pairs(v) do
						Inst.Parent = Folder
						
						if (os.clock() - startTime) >= MaximumElapsedFrameTime then
							task.wait()
							startTime = os.clock()
						end
					end
				end
			end
			local CreatedFolder = _MasterParent:FindFirstChild(i)

			if typeof(v) == "table" then
				--task.wait(WaitNumber)
				_func(v, CreatedFolder)
			end
			
			if (os.clock() - startTime) >= MaximumElapsedFrameTime then
				task.wait()
				startTime = os.clock()
			end
		end

	end

	_func(givenTable, MasterParent)
	print("Finished. Computing Time: "..(os.clock() - ComputingTimeStart))
	
	return MasterParent
end

--[[
    ========================================================================
    FUNCTION EXPLANATION: deepCompare
    ========================================================================
    This function performs a deep comparison between two tables (tab1 and tab2).
    This means it doesn't just check the top level, but automatically dives 
    into all nested sub-tables, no matter how deep they are hidden.
    
    Return Values:
    - true  -> The tables contain identical data.
    - false -> A mismatch was found somewhere.
]]
local function deepCompare(tab1, tab2)

	if tab1 == tab2 then 
		return true 
	end

	if type(tab1) ~= "table" or type(tab2) ~= "table" then 
		return false 
	end

	for key, value1 in pairs(tab1) do
		local value2 = tab2[key]

		if type(value1) == "table" and type(value2) == "table" then
			if not deepCompare(value1, value2) then 
				return false 
			end

		elseif value1 ~= value2 then
			return false
		end
	end

	for key in pairs(tab2) do
		if tab1[key] == nil then 
			return false 
		end
	end

	return true
end

-- SeemTerrain

function TableLib.DynamicWeights(DefaultWeights: {number}, pushedWeightIndex: number, pushedWeightValue: number): {number}
	local unnormalizedWeights = {}
	local normalizedTo_0_Weights = {}
	local normalizedTo_AddValue_Weights = {}
	local normalizedTo_Limit_Weights = {}
	local addValue = 0
	local unnormalizedTotalWeight = 0
	local limit = #DefaultWeights
	local positives = 0
	local subtractingWeightsValue = pushedWeightValue / (#DefaultWeights - 1)
	
	-- Step 1: create unnormalizedWeights
	for i = 1, #DefaultWeights do
		if i == pushedWeightIndex then
			unnormalizedWeights[i] = DefaultWeights[i] + pushedWeightValue
		else 
			unnormalizedWeights[i] = DefaultWeights[i] - subtractingWeightsValue
		end
	end
	
	-- Step 2: normalize negatives
	for i, weight in ipairs(unnormalizedWeights) do
		if weight < 0 then -- negatives get set to 0
			addValue += math.abs(weight)
			
			normalizedTo_0_Weights[i] = 0
		else -- positives remain the same
			normalizedTo_0_Weights[i] = weight
		end
	end
	
	-- Step 3: add the addValue(from the negatives) to the positives
	for i, weight in ipairs(normalizedTo_0_Weights) do
		if weight > 0 then -- do not add to the ones who were negative(or just dont have any influence)
			positives += 1 -- add for later(for possible surplus; step 4)
			
			normalizedTo_AddValue_Weights[i] = weight + addValue
		else -- the ones who were negatives remain the same(could've also done = 0 instead of = weight, as weight is 0)
			normalizedTo_AddValue_Weights[i] = weight
		end
	end
	
	-- Step 4: calculate unnormalizedTotalWeight
	for i, weight in ipairs(normalizedTo_AddValue_Weights) do
		unnormalizedTotalWeight += weight -- basically catches only the ones who are positive(have influence)
	end
	
	-- Step 5: create normalizedTo_Limit_Weights(fix a surplus)
	if unnormalizedTotalWeight > limit then
		local surplus = unnormalizedTotalWeight - limit
		local allocatedValue = surplus / positives
		
		for i, weight in ipairs(normalizedTo_AddValue_Weights) do
			if weight > 0 then -- catch positives
				normalizedTo_Limit_Weights[i] = weight - allocatedValue
			else -- the ones who were negatives remain the same(could've also done = 0 instead of = weight, as weight is 0)
				normalizedTo_Limit_Weights[i] = weight
			end
		end
	else 
		normalizedTo_Limit_Weights = normalizedTo_AddValue_Weights
	end

	return normalizedTo_Limit_Weights
end

-------------------------------------
-------------------------------------
-------------------------------------

--==================================================
-- Debugging & Visualization
--==================================================

--[[
    Prints a table in a JSON-like, indented structure using warnings.
    Intended for debugging and visualization purposes.
]]
function TableLib.JSONLikeWarn(givenTable, Indent)
	return JSONLikeWarn(givenTable, Indent)
end

--[[
    Outputs all key-value pairs of a table (non-recursive) using warnings.
    Intended for debugging shallow table structures.
]]
function TableLib.ShallowWarnTable(givenTable)
	return ShallowWarnTable(givenTable)
end

--[[
    Recursively outputs all key-value pairs of a table using warnings.
    Intended for debugging deeply nested table structures.
]]
function TableLib.DeepWarnTable(givenTable)
	return DeepWarnTable(givenTable)
end

--[[
Recursively converts all tables to folders starting from the MasterParent.
The content of the tables is NOT converted to anything.
The tables are converted to a folder whose name is the index.
MaximumElapsedFrameTime is used for batching.
Whenever MaximumElapsedFrameTime is passed, task.wait() is called(batching)
]]
function TableLib.ConvertToFolders(givenTable, MasterParent, MaximumElapsedFrameTime)
	return ConvertToFolders(givenTable, MasterParent, MaximumElapsedFrameTime)
end


--==================================================
-- Deletion Utilities
--==================================================

--[[
    Removes all keys from a table whose value matches the given value.
    Operates only on the first level of the table.
    Returns true if at least one key was removed, otherwise false.
]]
function TableLib.ShallowKeyDeleteByValue(givenTable, Value)
	return ShallowKeyDeleteByValue(givenTable, Value)
end

--[[
    Recursively removes all keys from a table whose value matches the given value.
    Returns true if at least one key was removed, otherwise false.
]]
function TableLib.DeepKeyDeleteByValue(givenTable, Value)
	return DeepKeyDeleteByValue(givenTable, Value)
end


--==================================================
-- Hierarchy & Relationship Utilities
--==================================================

--[[
    Finds the parent key of a given key inside a nested table structure.
    The nth parameter specifies how many levels up the parent should be resolved.
    Returns the parent key or nil if not found.
]]
function TableLib.GetParent(givenTable, Key, nth)
	return GetParent(givenTable, Key, nth)
end


--==================================================
-- Search Utilities (Key / Value)
--==================================================

--[[
    Searches for a key and/or value on the first level of a table.
    Returns the matched key and value, or nil if no match is found.
]]
function TableLib.ShallowGetValueOrKey(givenTable, Key, Value)
	return ShallowGetValueOrKey(givenTable, Key, Value)
end

--[[
    Recursively searches for a key and/or value inside a nested table.
    Returns the matched key and value, or nil if no match is found.
]]
function TableLib.DeepGetValueOrKey(givenTable, Key, Value)
	return DeepGetValueOrKey(givenTable, Key, Value)
end

--[[
    Searches for a value in a table (non-recursive).
    Returns the matched value or nil.
]]
function TableLib.ShallowValueSearch(givenTable, Value)
	return ShallowValueSearch(givenTable, Value)
end

--[[
    Recursively searches for a value inside a table.
    Returns the first matched value or nil.
]]
function TableLib.DeepValueSearch(givenTable, Value)
	return DeepValueSearch(givenTable, Value)
end

--[[
    Searches for a key on the first level of a table.
    Returns the value or nil.
]]
function TableLib.ShallowKeySearch(givenTable, Key)
	return ShallowKeySearch(givenTable, Key)
end

--[[
    Recursively searches for a key inside a table.
    Returns the associated value or nil.
]]
function TableLib.DeepKeySearch(givenTable, Key)
	return DeepKeySearch(givenTable, Key)
end


--==================================================
-- Table Analysis & Inspection
--==================================================

--[[
    Determines whether a table behaves like an array or a dictionary.
    Returns:
    - table type ("array" or "dictionary")
    - count of numeric indices
    - highest numeric index found
]]
function TableLib.CheckType(givenTable)
	return CheckType(givenTable)
end

--[[
    Counts the number of key-value pairs on the first level of a table.
]]
function TableLib.ShallowCount(givenTable)
	return ShallowCount(givenTable)
end

--[[
    Counts all non-table values and nested tables recursively.
    Returns:
    - number of non-table values
    - number of nested tables
]]
function TableLib.DeepCount(givenTable)
	return DeepCount(givenTable) 
end

--[[
    ========================================================================
    FUNCTION EXPLANATION: deepCompare
    ========================================================================
    This function performs a deep comparison between two tables (tab1 and tab2).
    This means it doesn't just check the top level, but automatically dives 
    into all nested sub-tables, no matter how deep they are hidden.
    
    Return Values:
    - true  -> The tables contain identical data.
    - false -> A mismatch was found somewhere.
]]
function TableLib.DeepCompare(t1, t2)
	return deepCompare(t1, t2)
end


--==================================================
-- Copying Utilities
--==================================================

--[[
    Creates a shallow copy of a table.
    Nested tables are copied by reference.
]]
function TableLib.ShallowCopy(original)
	return ShallowCopy(original)
end

--[[
    Creates a deep copy of a table.
    All nested tables are recursively duplicated.
]]
function TableLib.DeepCopy(original)
	return DeepCopy(original)
end


--==================================================
-- Merge Utilities
--==================================================

--[[
    Shallowly merges two tables into a new table.
    Optionally allows table2 values to overwrite table1 values.
]]
function TableLib.ShallowMerge(table1, table2, Table2OverwritesTable1)
	return ShallowMerge(table1, table2, Table2OverwritesTable1)
end

--[[
    Deeply merges table2 into table1 based on values.
    Arrays avoid duplicate values.
    Dictionaries avoid duplicate keys unless overwriting is enabled.
]]
function TableLib.DeepMerge_ValueBased(table1, table2, Table2OverwritesTable1)
	return DeepMerge_ValueBased(table1, table2, Table2OverwritesTable1)
end

--[[
    Deeply merges table2 into table1 based on indices.
    Array indices are preserved instead of comparing values.
]]
function TableLib.DeepMerge_IndexBased(table1, table2, Table2OverwritesTable1)
	return DeepMerge_IndexBased(table1, table2, Table2OverwritesTable1)
end

--==================================================
-- Replace Utilities
--==================================================

function TableLib.CreateReversedMaskedArray(size: number, customIndex: number, customValue: any)
	return CreateReversedMaskedArray(size, customIndex, customValue)
end

return TableLib
