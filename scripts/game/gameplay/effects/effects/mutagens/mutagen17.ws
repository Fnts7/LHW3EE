/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Mutagen17_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen17;
	default dontAddAbilityOnTarget = true;
	
	// W3EE - Begin
	//private var lightCounter, heavyCounter, signCounter : int;
	private var hasLightBoost, hasHeavyBoost, hasSignBoost, hasCounterBoost, hasCrossbowBoost : bool;
	
	default hasLightBoost = false;
	default hasHeavyBoost = false;
	default hasSignBoost = false;
	default hasCounterBoost = false;
	default hasCrossbowBoost = false;

	private var pauseDuration, pauseDT : float;
	default pauseDuration = 3.f;

	private var abilityNameHeavy, abilityNameSign : name;
	//default abilityNameLight	= 'Mutagen17EffectLight';
	default abilityNameHeavy	= 'Mutagen17EffectHeavy';
	default abilityNameSign		= 'Mutagen17EffectSign';

	event OnUpdate(dt : float)
	{
		var chargeCount : int;
		
		var counters : array<int>;
		
		super.OnUpdate(dt);
		
		if (pauseDT > 0)
			pauseDT -= dt;
		
		if (pauseDT <= 0)
		{
			counters.PushBack(FactsQuerySum("mutagen_17_attack_light"));
			counters.PushBack(FactsQuerySum("mutagen_17_attack_heavy") * 2);
			counters.PushBack(FactsQuerySum("mutagen_17_sign") * 2);
			counters.PushBack(FactsQuerySum("mutagen_17_counter") * 2);
			counters.PushBack(FactsQuerySum("mutagen_17_crossbow") * 2);
			
		
			if (!hasLightBoost)
			{
				chargeCount = GetCount(counters, 0);
				
				if (chargeCount >= 12)
				{
					hasLightBoost = true;
				}
			}
			
			if (!hasHeavyBoost)
			{
				chargeCount = GetCount(counters, 1);
				if (chargeCount >= 12)
				{
					AddBoost(abilityNameHeavy);
					hasHeavyBoost = true;
				}
			}
			
			if (!hasSignBoost)
			{
				chargeCount = GetCount(counters, 2);
				if (chargeCount >= 12)
				{
					AddBoost(abilityNameSign);
					hasSignBoost = true;
				}
			}
			
			if (!hasCounterBoost)
			{
				chargeCount = GetCount(counters, 3);
				
				if (chargeCount >= 12)
				{
					hasCounterBoost = true;
				}
			}
			
			if (!hasCrossbowBoost)
			{
				chargeCount = GetCount(counters, 4);
				
				if (chargeCount >= 12)
				{
					hasCrossbowBoost = true;
				}
			}
		}
	}
	
	private function GetCount( counters : array<int>, exclude : int) : int
	{
		var charges, nonZeros, i : int;
		
		charges = 0;
		nonZeros = 0;
		for (i = 0; i < 5; i += 1)
		{
			if (i == exclude)
				continue;
				
			if (counters[i] > 0)
				nonZeros += 1;
				
			charges += counters[i];			
		}
		
		if (nonZeros >= 3)
		{
			charges *= 2;
		}
		else if (nonZeros == 2)
		{
			charges = (int) RoundMath(charges * 1.5f);
		}
		
		return charges;
	}

	private function AddBoost(boostName : name)
	{
		target.AddAbility(boostName, false);
	}
	
	public function HasBoost(type : string) : bool
	{
		switch (type) 
		{
			case "light"	:	return hasLightBoost;
			case "heavy"	:	return hasHeavyBoost;
			case "sign"		:	return hasSignBoost;
			case "counter"	:	return hasCounterBoost;
			case "crossbow"	:	return hasCrossbowBoost;
			default			:	return false;
		}
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		target.RemoveAbility(abilityName);	
	}
	
	public function BlockBoost()
	{
		ClearBoost();
		pauseDT = pauseDuration;
	}

	public function ClearBoost()
	{
		FactsRemove("mutagen_17_attack_light");
		FactsRemove("mutagen_17_attack_heavy");
		FactsRemove("mutagen_17_sign");
		FactsRemove("mutagen_17_counter");
		FactsRemove("mutagen_17_crossbow");
		
		hasLightBoost = false;
		hasHeavyBoost = false;
		hasSignBoost = false;
		hasCounterBoost = false;
		hasCrossbowBoost = false;
		
		//target.RemoveAbility(abilityNameLight);
		target.RemoveAbility(abilityNameHeavy);
		target.RemoveAbility(abilityNameSign);
		
		/*switch (type) 
		{
			case "light" :
				target.RemoveAbility(abilityNameLight);
				hasLightBoost = false;
				break;
			case "heavy" :
				target.RemoveAbility(abilityNameHeavy);
				hasHeavyBoost = false;
				break;
			case "attack" :
				target.RemoveAbility(abilityNameLight);
				target.RemoveAbility(abilityNameHeavy);
				hasLightBoost = false;
				hasHeavyBoost = false;
				break;
			case "sign" :
				target.RemoveAbility(abilityNameSign);
				hasSignBoost = false;
				break;
			default:
				target.RemoveAbility(abilityNameLight);
				target.RemoveAbility(abilityNameHeavy);
				target.RemoveAbility(abilityNameSign);
				hasLightBoost = false;
				hasHeavyBoost = false;
				hasSignBoost = false;
				break;
		}*/
	}
	// W3EE - End
}
