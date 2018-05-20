/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class W3Effect_WellFed extends W3RegenEffect
{
	default effectType = EET_WellFed;
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	var cachedValue : bool;
	default cachedValue = false;
	
	var perk15Value, perk15ValueCombat : float;
	
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		cachedValue = false;
		
		// W3EE - Begin
		/*
		if(isOnPlayer && thePlayer == GetWitcherPlayer() && GetWitcherPlayer().HasRunewordActive('Runeword 6 _Stats'))
		{		
			iconPath = theGame.effectMgr.GetPathForEffectIconTypeName('icon_effect_Dumplings');
		}
		*/
		// W3EE - End
	}
	
	event OnPerk15Unequipped()
	{
		SetTimeLeft( initialDuration );
		duration = initialDuration;
	}
	
	event OnUpdate(dt : float)
	{
		var witcher : W3PlayerWitcher;
		var min, max : SAbilityAttributeValue;
		var dm : CDefinitionsManagerAccessor;
		var value, toxPerc : float;

		witcher = GetWitcherPlayer();
		
		if( isOnPlayer && witcher && witcher.CanUseSkill( S_Perk_15 ) )
		{		
			if (!cachedValue)
			{
				dm = theGame.GetDefinitionsManager();
				dm.GetAbilityAttributeValue(abilityName, 'vitalityRegen', min, max);
				perk15Value = CalculateAttributeValue(GetAttributeRandomizedValue(min, max)) * 0.35f;
				
				dm.GetAbilityAttributeValue(abilityName, 'vitalityCombatRegen', min, max);			
				perk15ValueCombat = CalculateAttributeValue(GetAttributeRandomizedValue(min, max)) * 0.35f;
				
				cachedValue = true;
			}
			
			if(witcher.IsInCombat())
				value = perk15ValueCombat;
			else
				value = perk15Value;
				
			toxPerc = witcher.GetStatPercents(BCS_Toxicity);
	
			if (toxPerc > 0)
				value *= 1 - ( (0.6f - 0.06f * witcher.GetSkillLevel(S_Alchemy_s20)) * toxPerc );
						
			effectManager.CacheStatUpdate(BCS_Vitality, value * dt);
		}
	
		super.OnUpdate(dt);
	}
	

	
	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		var min, max : SAbilityAttributeValue;
		
		super.CalculateDuration(setInitialDuration);
		
		if( isOnPlayer && GetWitcherPlayer() )
		{	
			
			if( GetWitcherPlayer().CanUseSkill( S_Perk_15 ) )
			{
				// W3EE - Begin
				/*
				min = GetWitcherPlayer().GetSkillAttributeValue( S_Perk_15, 'duration', false, false );
				min.valueAdditive = 480;
				*/
				duration *= 1.25f; //min.valueAdditive;
				// W3EE - End
			}
			// W3EE - Begin
			/*
			if( GetWitcherPlayer().HasRunewordActive( 'Runeword 6 _Stats' ) )
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue('Runeword 6 _Stats', 'runeword6_duration_bonus', min, max);
				duration *= 1 + min.valueMultiplicative;
			}
			*/
			// W3EE - End
		}
	}
	
	public function CumulateWith(effect: CBaseGameplayEffect)
	{
		super.CumulateWith(effect);
		cachedValue = false;
	}
	
	protected function GetSelfInteraction( e : CBaseGameplayEffect) : EEffectInteract
	{
		var eff : W3Effect_WellFed;
		var dm : CDefinitionsManagerAccessor;
		var thisLevel, otherLevel : int;
		var min, max : SAbilityAttributeValue;
		
		dm = theGame.GetDefinitionsManager();
		eff = (W3Effect_WellFed)e;
		dm.GetAbilityAttributeValue(abilityName, 'level', min, max);
		thisLevel = RoundMath(CalculateAttributeValue(GetAttributeRandomizedValue(min, max)));
		dm.GetAbilityAttributeValue(eff.abilityName, 'level', min, max);
		otherLevel = RoundMath(CalculateAttributeValue(GetAttributeRandomizedValue(min, max)));
		
		if(otherLevel >= thisLevel)
			return EI_Cumulate;		
		else
			return EI_Deny;
	}
}
