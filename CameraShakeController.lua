-- Register the behaviour
behaviour("CameraShakeController")

function CameraShakeController:Awake()
	self.gameObject.name = "CSC"

	self.multipliers = {}

	
	self.baseCameraShakeMultiplier = self.script.mutator.GetConfigurationRange("CameraShakeMultiplier")
	self.shakeLimit = self.script.mutator.GetConfigurationInt("ShakeLimit")
	Player.actor.onTakeDamage.AddListener(self,"onTakeDamage")
	GameEvents.onActorSpawn.AddListener(self,"onActorSpawn")

	self.currentMultiplier = self.baseCameraShakeMultiplier
end

function CameraShakeController:Start()
	local damageSystemObj = self.gameObject.Find("DamageCore")
	if damageSystemObj then
		self.damageSystem = damageSystemObj.GetComponent(ScriptedBehaviour)
		local function postCalc(actor, source, info)
			self:PostDamageCalculation(actor, source, info)
		end
		self.damageSystem.self:AddListener("PostCalculation", Player.actor, self,postCalc)
	else
		Player.actor.onTakeDamage.AddListener(self,"onTakeDamage")
	end
end

function CameraShakeController:onTakeDamage(actor,source,info)
	self.script.StartCoroutine(self:DelayedCameraShake(info.balanceDamage))
end

function CameraShakeController:PostDamageCalculation(actor,source,info)
	print(info.balanceDamage)
	self.script.StartCoroutine(self:DelayedCameraShake(info.balanceDamage))
end

--Apply camera shake a frame after the game itself does it
--Doing it this way interrupts the vanilla camera shake
function CameraShakeController:DelayedCameraShake(balanceDamage)
	return function()
		coroutine.yield()
		local scaledBalanceDamage = balanceDamage * self.currentMultiplier
		
		local magnitude = scaledBalanceDamage/6
		local iterations = Mathf.CeilToInt(scaledBalanceDamage / 20)
		if self.shakeLimit > -1 then
			iterations = Mathf.Clamp(iterations,0,self.shakeLimit)
		end

		PlayerCamera.ApplyScreenshake(magnitude,iterations)
	end
end


function CameraShakeController:AddModifier(modifierName, modifierValue)
	self.multipliers[modifierName] = modifierValue

	self:CalculateMultiplier()
end

function CameraShakeController:RemoveModifier(modifierName)
	self.multipliers[modifierName] = nil

	self:CalculateMultiplier()
end

function CameraShakeController:CalculateMultiplier()
	self.currentMultiplier = self.baseCameraShakeMultiplier

	for multiplier, value in pairs(self.multipliers) do
		self.currentMultiplier = self.currentMultiplier * value
	end
end

function CameraShakeController:onActorSpawn(actor)
	if actor.isPlayer then
		self:CalculateMultiplier()
	end
end