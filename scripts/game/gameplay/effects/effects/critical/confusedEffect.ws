/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3ConfuseEffectCustomParams extends W3BuffCustomParams
{
	var criticalHitChanceBonus : float;
}

class W3ConfuseEffect extends W3CriticalEffect
{
	private saved var drainStaminaOnExit : bool;
	private var criticalHitBonus : float;
	private var drainStaminaChance : float;

	default criticalStateType 	= ECST_Confusion;
	default effectType 			= EET_Confusion;
	default resistStat 			= CDS_WillRes;
	default drainStaminaOnExit 	= false;
	default attachedHandling 	= ECH_Abort;
	default onHorseHandling 	= ECH_Abort;
		
	public function GetCriticalHitChanceBonus() : float
	{
		//return criticalHitBonus;
	
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
	
	public function IsWitcherAxii() : bool
	{
		return GetCreator() == thePlayer && IsSignEffect();
	}
	
	public function GetCoreTimeLeft() : float
	{
		var denominator : float;
		
		denominator = creatorPowerStat.valueMultiplicative * (1 - resistance);
		if (denominator == 0)
			return 0;
	
		return timeLeft / denominator;
	}
		
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var params : W3ConfuseEffectCustomParams;
		var npc : CNewNPC;
		
		super.OnEffectAdded(customParams);
		
		if(isOnPlayer)
		{
			thePlayer.HardLockToTarget( false );
		}
		
		
		params = (W3ConfuseEffectCustomParams)customParams;
		if(params)
		{
			criticalHitBonus = params.criticalHitChanceBonus;
		}
		
		npc = (CNewNPC)target;
		
		if(npc)
		{
			
			npc.LowerGuard();
			
			if (npc.IsHorse())
			{
				if( npc.GetHorseComponent().IsDismounted() )
					npc.GetHorseComponent().ResetPanic();
				
				if ( IsSignEffect() &&  npc.IsHorse() )
				{
					npc.SetTemporaryAttitudeGroup('animals_charmed', AGP_Axii);
					npc.SignalGameplayEvent('NoticedObjectReevaluation');
				}
			}
		}
	}
	
	public function CacheSettings()
	{
		super.CacheSettings();
	
		blockedActions.PushBack(EIAB_Signs);
		blockedActions.PushBack(EIAB_DrawWeapon);
		blockedActions.PushBack(EIAB_CallHorse);
		blockedActions.PushBack(EIAB_Fists);
		blockedActions.PushBack(EIAB_Jump);
		blockedActions.PushBack(EIAB_RunAndSprint);
		blockedActions.PushBack(EIAB_ThrowBomb);
		blockedActions.PushBack(EIAB_Crossbow);
		blockedActions.PushBack(EIAB_UsableItem);
		blockedActions.PushBack(EIAB_SwordAttack);
		blockedActions.PushBack(EIAB_Parry);
		blockedActions.PushBack(EIAB_Sprint);
		blockedActions.PushBack(EIAB_Explorations);
		blockedActions.PushBack(EIAB_Counter);
		blockedActions.PushBack(EIAB_LightAttacks);
		blockedActions.PushBack(EIAB_HeavyAttacks);
		blockedActions.PushBack(EIAB_SpecialAttackLight);
		blockedActions.PushBack(EIAB_SpecialAttackHeavy);
		blockedActions.PushBack(EIAB_QuickSlots);
		
		
		
	}
		
	event OnEffectRemoved()
	{
		var npc : CNewNPC;
		super.OnEffectRemoved();
		
		npc = (CNewNPC)target;
		
		if(npc)
		{
			npc.ResetTemporaryAttitudeGroup(AGP_Axii);
			npc.SignalGameplayEvent('NoticedObjectReevaluation');
		}
		
		if (npc && npc.IsHorse())
			npc.SignalGameplayEvent('WasCharmed');
			
		if(drainStaminaOnExit && RandF() < drainStaminaChance)
		{
			target.DrainStamina(ESAT_FixedValue, target.GetStat(BCS_Stamina));
		}
	}
	
	public function SetDrainStaminaOnExit(chance : float)
	{
		drainStaminaOnExit = true;
		drainStaminaChance = chance;
	}
	
	protected function CalculateDuration(optional setInitialDuration : bool)
	{		
		var min, max : SAbilityAttributeValue;
		
		if ( GetCreator() != thePlayer || !IsSignEffect())
		{
			super.CalculateDuration(setInitialDuration);
			return;
		}
		
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
}