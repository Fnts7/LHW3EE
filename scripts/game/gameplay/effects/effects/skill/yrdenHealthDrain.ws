/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Effect_YrdenHealthDrain extends W3DamageOverTimeEffect
{
	// W3EE - Begin
	private var hitFxDelay : float;
	
	default effectType = EET_YrdenHealthDrain;
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;

	event OnEffectAdded( optional customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
		
		hitFxDelay = 0.9 + RandF() / 5;
		SetEffectValue();
	}

	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}

	event OnUpdate(dt : float)
	{
		super.OnUpdate(dt);
		
		hitFxDelay -= dt;
		if( hitFxDelay <= 0 )
		{
			hitFxDelay = 0.9 + RandF() / 5;
			target.PlayEffect('yrden_shock');
		}
	}
	
	protected function SetEffectValue()
	{
		var sp : SAbilityAttributeValue;
		
		sp = ((W3SignEntity)GetCreator()).GetTotalSignIntensity();
		effectValue = thePlayer.GetSkillAttributeValue(S_Magic_s11, 'direct_damage_per_sec', false, true);
		effectValue.valueAdditive *= sp.valueMultiplicative * ((W3SignEntity)GetCreator()).GetActualOwner().GetSkillLevel(S_Magic_s11, (W3SignEntity)GetCreator()) * 2.8f;
	}
	// W3EE - End
}