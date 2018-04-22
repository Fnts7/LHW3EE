/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class W3Potion_MariborForest extends CBaseGameplayEffect
{
	default effectType = EET_MariborForest;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		// W3EE - Begin		
		super.OnEffectAdded(customParams);
		
		target.abilityManager.SetStatPointMax(BCS_Focus, Options().MaxFocus() + 1);
		
		if(GetBuffLevel() == 3)
		{
			target.GainStat(BCS_Focus, 1);
		}
		// W3EE - End
	}
	
	// W3EE - Begin
	event OnEffectRemoved()
	{
		target.abilityManager.SetStatPointMax(BCS_Focus, Options().MaxFocus());
		
		super.OnEffectRemoved();
	}
	// W3EE - End
}
