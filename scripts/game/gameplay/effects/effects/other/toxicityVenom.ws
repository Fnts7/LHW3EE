/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
class W3Effect_ToxicityVenom extends CBaseGameplayEffect
{
	default effectType = EET_ToxicityVenom;
	default isNegative = true;
	default dontAddAbilityOnTarget = false;
	
	event OnUpdate( dt : float )
	{
		var maxTox, toxToAdd : float;
		var toxicityEffect : W3Effect_Toxicity;
		
		super.OnUpdate( dt );
		
		maxTox = target.GetStatMax( BCS_Toxicity );
		toxToAdd = effectValue.valueAdditive + effectValue.valueMultiplicative * maxTox;
		toxToAdd *= dt;
		
		if (target.HasBuff(EET_GoldenOriole))
		{
			toxToAdd *= 1.0f - (0.4f + target.GetBuff(EET_GoldenOriole).GetBuffLevel() * 0.15f);
		}		
		
		target.GainStat( BCS_Toxicity, toxToAdd );
		toxicityEffect = (W3Effect_Toxicity)target.GetBuff(EET_Toxicity);
		if (toxicityEffect)
			toxicityEffect.SetEffectTime(toxToAdd, 0.0f); // 0 duration means, the toxicity will be added to residual
	}
}