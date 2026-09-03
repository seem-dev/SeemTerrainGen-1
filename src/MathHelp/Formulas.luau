--!strict

local Formulas = {}

function Formulas.SmoothStep(edge0: number, edge1: number, x: number): number

	if edge0 == edge1 then return 0 end

	local t = (x - edge0) / (edge1 - edge0)

	t = math.clamp(t, 0, 1)

	return t * t * (3 - (2 * t))
end

local function pCatmullRom(t: number, p0: number, p1: number, p2: number, p3: number): number
	return 0.5 * (
		(2 * p1) +
			(-p0 + p2) * t +
			(2 * p0 - 5 * p1 + 4 * p2 - p3) * (t^2) +
			(-p0 + 3 * p1 - 3 * p2 + p3) * (t^3)
	)
end

function Formulas.GetSplineValue(points: {number}, t: number): number
	local numPoints = #points
	if numPoints < 2 then return points[1] end

	t = math.clamp(t, 0, 1)

	
	local numSegments = numPoints - 1
	local globalT = t * numSegments
	local segmentIndex = math.floor(globalT) + 1
	local localT = globalT - math.floor(globalT)

	
	if segmentIndex > numSegments then
		segmentIndex = numSegments
		localT = 1
	end

	local p1 = points[segmentIndex]
	local p2 = points[segmentIndex + 1]

	local p0 = segmentIndex > 1 and points[segmentIndex - 1] or (p1 + (p1 - p2))
	local p3 = (segmentIndex + 1) < numPoints and points[segmentIndex + 2] or (p2 + (p2 - p1))

	return pCatmullRom(localT, p0, p1, p2, p3)
end

function Formulas.GetSmallestNumInArray(Array: {number})
	local smallesNum = Array[1]
	
	for i = 1, #Array do
		if Array[i] < smallesNum then
			smallesNum = Array[i]
		end
	end
	
	return smallesNum
end

return Formulas
