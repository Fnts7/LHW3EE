/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Effect_AxiiGuardMe extends CBaseGameplayEffect
{
	private var drainStaminaOnExit : bool;
	private var drainStaminaChance : float;

	default effectType = EET_AxiiGuardMe;
	default resistStat = CDS_WillRes;
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	default drainStaminaOnExit = false;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var npc : CNewNPC;
		var bonusAbilityName : name;
		var skillLevel, i : int;
		
		super.OnEffectAdded(customParams);
		
		npc = (CNewNPC)target;
		
		((CAIStorageReactionData)npc.GetScriptStorageObject('ReactionData')).ResetAttitudes(npc);
		
		
		if ( npc.HasAttitudeTowards( thePlayer ) && npc.GetAttitude( thePlayer ) == AIA_Hostile )
		{
			npc.ResetAttitude( thePlayer );
		}
		
		if ( npc.HasTag('animal') || npc.IsHorse() )
		{
			npc.SetTemporaryAttitudeGroup('animals_charmed', AGP_Axii);
		}
		else
		{
			npc.SetTemporaryAttitudeGroup('npc_charmed', AGP_Axii);
		}
		
		npc.SignalGameplayEvent('AxiiGuardMeAdded');
		npc.SignalGameplayEvent('NoticedObjectReevaluation');
		
		
		skillLevel = GetWitcherPlayer().GetSkillLevel(S_Magic_s05) - 1;
		bonusAbilityName = thePlayer.GetSkillAbilityName(S_Magic_s05);
		for(i=0; i<skillLevel; i+=1)
			target.AddAbility(bonusAbilityName, true);
			
		if (npc.IsHorse())
			npc.GetHorseComponent().ResetPanic();
	}
	
	event OnEffectRemoved()
	{
		var npc : CNewNPC;
		var bonusAbilityName : name;
		
		super.OnEffectRemoved();
		
		npc = (CNewNPC)target;		
		if(npc)
		{
			npc.ResetTemporaryAttitudeGroup(AGP_Axii);
			npc.SignalGameplayEvent('NoticedObjectReevaluation');
			((CAIStorageReactionData)npc.GetScriptStorageObject('ReactionData')).ResetAttitudes(npc);
		}
		
		if(drainStaminaOnExit && RandF() < drainStaminaChance)
		{
			target.DrainStamina(ESAT_FixedValue, target.GetStat(BCS_Stamina));
		}
		
		
		bonusAbilityName = thePlayer.GetSkillAbilityName(S_Magic_s05);		
		while(target.HasAbility(bonusAbilityName))
			target.RemoveAbility(bonusAbilityName);
	}
	
	public function SetDrainStaminaOnExit(chance : float)
	{
		drainStaminaOnExit = true;
		drainStaminaChance = chance;
	}
	
	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		/*super.CalculateDuration(setInitialDuration);
		
		if ( duration > 0 )
			duration = MaxF(8.f,duration);*/
			
		var min, max : SAbilityAttributeValue;
		
		if(duration == 0)
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'duration', min, max);
			duration = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
		}
		
		if(setInitialDuration)
			initialDuration = duration;
	
		if( duration == -1)
			return;
			
				
		initialDuration *= creatorPowerStat.valueMultiplicative;
		duration = MaxF(0, MaxF(0, initialDuration) * (1 - resistance));
		
		//LogEffects("BaseEffect.CalculateDuration: " + effectType + " duration with target resistance (" + NoTrailZeros(resistance) + ") and attacker power mul of (" + NoTrailZeros(creatorPowerStat.valueMultiplicative) + ") is " + NoTrailZeros(duration) + ", base was " + NoTrailZeros(initialDuration));
	}
	
	public function GetCriticalHitChanceBonus() : float
	{
		var powerMult : float;
		
		if ( GetCreator() != thePlayer || !thePlayer.CanUseSkill(S_Magic_s18) || creatorPowerStat.valueMultiplicative < 0)
			return 0;
			
		if (creatorPowerStat.valueMultiplicative >= 1.0f)
			powerMult = 1.0f + (creatorPowerStat.valueMultiplicative - 1.0f) / 2;
		else
			powerMult = 1.0f - (1.0f - creatorPowerStat.valueMultiplicative) / 2;
			
		return thePlayer.GetSkillLevel(S_Magic_s18) * 0.03f * powerMult * (1 - resistance);
	}
	
	public function GetCriticalDamageBonus() : float
	{
		var powerMult : float;
	
		if ( GetCreator() != thePlayer || !thePlayer.CanUseSkill(S_Magic_s18) || creatorPowerStat.valueMultiplicative < 0)
			return 0;
			
		if (creatorPowerStat.valueMultiplicative >= 1.0f)
			powerMult = 1.0f + (creatorPowerStat.valueMultiplicative - 1.0f) / 2;
		else
			powerMult = 1.0f - (1.0f - creatorPowerStat.valueMultiplicative) / 2;
			
		return thePlayer.GetSkillLevel(S_Magic_s18) * 0.03f * powerMult * (1 - resistance);
	}
	
	public function TransformExtraTime(time : float) : float
	{
		return time * creatorPowerStat.valueMultiplicative * (1 - resistance);
	}
	
	public function GetCoreTimeLeft() : float
	{
		var denominator : float;
		
		denominator = creatorPowerStat.valueMultiplicative * (1 - resistance);
		if (denominator == 0)
			return 0;
	
		return timeLeft / denominator;
	}
}