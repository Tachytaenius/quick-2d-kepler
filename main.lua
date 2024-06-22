local vec2 = require("lib.mathsies").vec2

local tau = math.pi * 2

local maxIterations = 30
local epsilon = 0.001

local sunMass = 1000
local gravitationalConstant = 10000

local standardGravitationalParameter = sunMass * gravitationalConstant

local semiMajorAxis = 150
local eccentricity = 0.5
local argumentOfPeriapsis = tau * 0.125
local initialMeanAnomaly = tau * 0.5

local time = 0

function love.update(dt)
	time = time + dt
end

local function getOrbitPathCentre()
	-- Figured this out from one relation without finding any proper resources on the exact problem (internet access was poor)
	local periapsisDirection = vec2.fromAngle(argumentOfPeriapsis)
	local periapsisDistance = semiMajorAxis * (1 - eccentricity)
	local apoapsisDistance = semiMajorAxis * (1 + eccentricity)
	local centre = periapsisDirection * (periapsisDistance - apoapsisDistance) / 2
	return centre
end

local function getStateVectors(time)
	local meanAnomaly = initialMeanAnomaly + time * math.sqrt(standardGravitationalParameter / semiMajorAxis ^ 3)

	-- I don't understand how we got the eccentric anomaly (haven't checked out the Newton-Raphson method yet)
	local E = meanAnomaly
	local F = E - eccentricity * math.sin(E) - meanAnomaly
	local i = 0
	while math.abs(F) > epsilon and i < maxIterations do
		E = E - F / (1 - eccentricity * math.cos(E))
		F = E - eccentricity * math.sin(E) - meanAnomaly
		i = i + 1
	end
	local eccentricAnomaly = E

	local trueAnomaly = argumentOfPeriapsis + 2 * math.atan2(
		math.sqrt(1 + eccentricity) * math.sin(eccentricAnomaly / 2),
		math.sqrt(1 - eccentricity) * math.cos(eccentricAnomaly / 2)
	)
	local distance = semiMajorAxis * (1 - eccentricity * math.cos(eccentricAnomaly))

	local position = vec2.fromAngle(trueAnomaly) * distance
	local velocity = math.sqrt(standardGravitationalParameter * semiMajorAxis) / distance *
		vec2(
			-math.sin(eccentricAnomaly + argumentOfPeriapsis),
			math.sqrt(1 - eccentricity ^ 2) * math.cos(eccentricAnomaly + argumentOfPeriapsis)
		)
	return position, velocity
end

function love.draw()
	love.graphics.setPointSize(8)
	love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
	love.graphics.points(0, 0)
	local position, velocity = getStateVectors(time)
	love.graphics.points(position.x, position.y)
	local velMul = 0.25
	love.graphics.line(position.x, position.y, position.x + velocity.x * velMul, position.y + velocity.y * velMul)
	local centre = getOrbitPathCentre()
	-- love.graphics.points(centre.x, centre.y)
	love.graphics.push()
	love.graphics.translate(centre.x, centre.y)
	love.graphics.rotate(argumentOfPeriapsis)
	local semiMinorAxis = semiMajorAxis * math.sqrt(1 - eccentricity ^ 2)
	love.graphics.ellipse("line", 0, 0, semiMajorAxis, semiMinorAxis)
	love.graphics.pop()
end
