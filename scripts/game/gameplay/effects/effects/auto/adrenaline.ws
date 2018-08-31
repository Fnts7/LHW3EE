/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class W3Effect_AdrenalineDrain extends CBaseGameplayEffect
{
	// W3EE - Begin
	default effectType = EET_AdrenalineDrain;
	default attributeName = 'focus_drain';
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;

	private var customTimerRunning, isRegen : bool;
	private var playerWitcher : W3PlayerWitcher;
	private var Adr : W3EEOptionHandler;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{	
		playerWitcher = (W3PlayerWitcher)target;
		Adr = Options();
		
		if(!playerWitcher)
		{
			LogEffects("W3Effect_AdrenalineDrain.OnEffectAdded: trying to add on non-witcher, aborting!");
			isActive = false;
			return false;
		}
		super.OnEffectAdded(customParams);
		isRegen = true;
	}
	
	event OnUpdate(dt : float)
	{
		var vigorRegenBonus : SAbilityAttributeValue;
		var focusGain, reductionValue : float;
		
		if(!isRegen)
			return false;
		
		if( playerWitcher.IsQuenActive(false) || playerWitcher.IsQuenActive(true) )
			return false;
		
		vigorRegenBonus = playerWitcher.GetAttributeValue('vigor_regen');
		reductionValue = 0.6f - 0.06f * playerWitcher.GetSkillLevel(S_Alchemy_s20);
		
		focusGain = 0.135f * vigorRegenBonus.valueMultiplicative * dt;
		focusGain *= 1.f - PowF(1.f - target.GetStatPercents(BCS_Vitality), 2) * 0.75f * playerWitcher.GetAdrenalinePercMultHalf();
		focusGain *= (1.f + playerWitcher.GetAdrenalineEffect().GetValue());
		focusGain *= Adr.AdrGenSpeedMult;
		focusGain *= 1.f - (reductionValue * target.GetStatPercents(BCS_Toxicity));
		target.GainStat(BCS_Focus, focusGain);
	}
	
	public function StopRegen()
	{
		isRegen = false;
	}
	
	public function ResumeRegen()
	{
		if( !customTimerRunning )
			isRegen = true;
	}
	
	public function SetCustomTimerActive( b : bool )
	{
		customTimerRunning = b;
	}
	// W3EE - End
}