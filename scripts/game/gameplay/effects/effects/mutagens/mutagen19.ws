/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Mutagen19_Effect extends W3Mutagen_Effect
{
	default effectType = EET_Mutagen19;
	
	private var currentPercent : float;
	default currentPercent = 0.0f;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		currentPercent = 0;
		super.OnEffectAdded(customParams);
	}
	
	public function TestTrigger(hitPerc : float) : bool
	{
		var ret : bool;

		ret = RandF() < (hitPerc * currentPercent);
		
		if (ret)
			currentPercent = MaxF(0.0f, currentPercent - 1.0f);
		
		return ret;
	}
	
	public function AddPercent(percent : float)
	{
		currentPercent += percent;
	}
}