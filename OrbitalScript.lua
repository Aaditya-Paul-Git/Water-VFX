local RunService: RunService = game:GetService("RunService")
local RandomService: Random = Random.new()
local TweenService: TweenService = game:GetService("TweenService")

local templatesModel: Model = script.Parent.Templates

type Orbit = {
	Template: MeshPart,
	Speed: number,
	Radius: number,
	Angle: number,
	Motor: Motor6D,
	Lifetime: number,
	Elapsed: number,
	Destroying: boolean,
	Sine: number?,
	SineSpeed: number?
}

local orbitSize: NumberRange = NumberRange.new(0.2, 0.4)
local orbitRadius: NumberRange = NumberRange.new(8, 20)
local orbitLifetime: NumberRange = NumberRange.new(4, 7)
local orbitSpeed: NumberRange = NumberRange.new(1, 1.5)
local orbitTemplates: { MeshPart } = { 
	templatesModel:WaitForChild("Fishie"),
	templatesModel:WaitForChild("Fishie1"),
	templatesModel:WaitForChild("Shark"),
	templatesModel:WaitForChild("Bubble")
}

local orbitTable: { Orbit } = { }

local sineSpeed: number = 2
local sineScale: number = 1.5

local function createOrbit()
	local orbitTemplate: MeshPart = orbitTemplates[RandomService:NextInteger(1, #orbitTemplates)]
	local orbit: MeshPart = orbitTemplate:Clone()
	orbit.Size *= RandomService:NextNumber(orbitSize.Min, orbitSize.Max)
	orbit.Color = Color3.fromHSV(0.6, 1, RandomService:NextNumber(0, 1))
	orbit.Parent = script.Parent
	TweenService:Create(orbit, TweenInfo.new(1), {
		Transparency = 0
	}):Play()
	
	orbitTable[orbit] = {
		Template = orbitTemplate,
		Speed = RandomService:NextNumber(orbitSpeed.Min, orbitSpeed.Max),
		Radius = RandomService:NextNumber(orbitRadius.Min, orbitRadius.Max),
		Angle = RandomService:NextNumber(-360, 360),
		Motor = orbit:FindFirstChild("Motor6D"),
		Sine = (orbitTemplate == templatesModel.Bubble) and RandomService:NextNumber(-5, 5) or nil
	} :: Orbit
end

for _ = 1, 20 do
	createOrbit()
end

local currentTime: number = 0
RunService.RenderStepped:Connect(
	function(deltaTime: number)
		currentTime += deltaTime
		for _, child in ipairs(script.Parent:GetChildren()) do
			local orbitInformation: Orbit = orbitTable[child]
			if not orbitInformation then continue end
			if not child:IsA("MeshPart") then continue end
			orbitInformation.Motor.C0 = CFrame.new(
				orbitInformation.Radius,
				orbitInformation.Sine and math.sin(currentTime * sineSpeed + orbitInformation.Sine) * sineScale or 0,
				0
			) * CFrame.Angles(
				0,
				currentTime * orbitInformation.Speed + orbitInformation.Angle,
				0
			)
			child.Orientation += Vector3.new(
				0,
				orbitInformation.Template:FindFirstChild("Offset").Value,
				0
			)
		end
	end
)
