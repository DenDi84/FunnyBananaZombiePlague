local effectData;

local tMats = {}
tMats.Glow1 = CreateMaterial("glow1", "UnlitGeneric", {["$basetexture"] = "sprites/light_glow02", ["$spriterendermode"] = 9, ["$ignorez"] = 1, ["$illumfactor"] = 8, ["$additive"] = 1, ["$vertexcolor"] = 1, ["$vertexalpha"] = 1})
tMats.Glow2 = CreateMaterial("glow2", "UnlitGeneric", {["$basetexture"] = "sprites/flare1", ["$spriterendermode"] = 9, ["$ignorez"] = 1, ["$illumfactor"] = 8, ["$additive"] = 1, ["$vertexcolor"] = 1, ["$vertexalpha"] = 1})


function EFFECT:Init(data)

	local vOrig = data:GetOrigin();
	local emitter = ParticleEmitter(vOrig);
	
	local smoke = emitter:Add("particle/SmokeStack.vmt", vOrig);
	if smoke then
		smoke:SetColor(233, 205, 105)
		smoke:SetVelocity(VectorRand():GetNormal() * math.random(10, 30))
		smoke:SetRoll(math.Rand(0, 360))
		smoke:SetRollDelta(math.Rand(-2, 2))
		smoke:SetDieTime(4)
		smoke:SetLifeTime(0)
		smoke:SetStartSize(50)
		smoke:SetStartAlpha(255)
		smoke:SetEndSize(400)
		smoke:SetEndAlpha(0)
		smoke:SetAirResistance(1)
		smoke:SetGravity(Vector(0,0,-100))
	end
	emitter:Finish();
	
end

-- Draw the effect
function EFFECT:Render()

end
