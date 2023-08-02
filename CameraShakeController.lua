-- Register the behaviour
behaviour("CameraShakeController")

function CameraShakeController:Awake()
	self.gameObject.name = "CSC"

	self.multipliers = {}

	self.baseCameraShakeMultiplier = self.script.mutator.GetConfigurationRange("CameraShakeMultiplier")
	Player.actor.onTakeDamage.AddListener(self,"onTakeDamage")
end

function CameraShakeController:onTakeDamage(actor,source,info)
	self.script.StartCoroutine(self:DelayedCameraShake(info.balanceDamage))
end

function CameraShakeController:Update()
	if(Input.GetKeyDown(KeyCode.I)) then
		Player.actor.damage(Player.actor,0,100, false ,false)
	end
end

--Apply camera shake a frame after the game itself does it
--Doing it this way interrupts the vanilla camera shake
function CameraShakeController:DelayedCameraShake(balanceDamage)
	return function()
		coroutine.yield()
		local scaledBalanceDamage = balanceDamage * self.baseCameraShakeMultiplier
		for multiplier, value in pairs(self.multipliers) do
			scaledBalanceDamage = scaledBalanceDamage * value
		end
		
		local magnitude = scaledBalanceDamage/6
		local iterations = Mathf.CeilToInt(scaledBalanceDamage / 20)
		PlayerCamera.ApplyScreenshake(magnitude,iterations)
	end
end


function CameraShakeController:AddModifier(modifierName, modifierValue)
	self.multipliers[modifierName] = modifierValue
end

function CameraShakeController:RemoveModifier(modifierName)
	self.multipliers[modifierName] = nil
end