/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Potion_Blizzard extends CBaseGameplayEffect
{
	private saved var slowdownCauserIds : array<int>;		
	private var slowdownFactor : float;
	private var currentSlowMoDuration : float;
	private var currentMaxDuration : float;
	private const var SLOW_MO_DURATION : float;
	private const var SLOW_MO_DURATION_HIGH : float;
	private const var SLOW_MO_DURATION_EXT : float;

	default effectType = EET_Blizzard;
	default attributeName = 'slow_motion';
	default SLOW_MO_DURATION = 4.0f;
	// W3EE - Begin
	default SLOW_MO_DURATION_HIGH = 1.f;
	default SLOW_MO_DURATION_EXT = 1.f;
	// W3EE - End
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{	
		super.OnEffectAdded(customParams);	
		
		// W3EE - Begin
		slowdownFactor = CalculateAttributeValue(effectValue);
		// W3EE - End
		
		currentMaxDuration = 0.0f;
		currentSlowMoDuration = 0.0f;
	}
	
	public final function IsSlowMoActive() : bool
	{
		return slowdownCauserIds.Size();
	}
	
	public function KilledEnemy()
	{
		SlowMotionActivate(false);
	}
	
	public function Countered()
	{
		SlowMotionActivate(true);
	}
	
	private function SlowMotionActivate(countered : bool)
	{
		var newDuration : float;
		
		if (countered)
		{
			newDuration = SLOW_MO_DURATION / 2.0f;
			if (GetBuffLevel() == 3)
				newDuration += SLOW_MO_DURATION_HIGH;
		}
		else
		{
			if (GetBuffLevel() == 3)
			{
				newDuration = SLOW_MO_DURATION + SLOW_MO_DURATION_HIGH;
				if (IsOnPlayer() && thePlayer.GetStat(BCS_Focus) >= thePlayer.GetStatMax(BCS_Focus))
					newDuration += SLOW_MO_DURATION_EXT;
			}
			else
				newDuration = SLOW_MO_DURATION;
		}
		
		if (slowdownCauserIds.Size() == 0 || (currentMaxDuration - currentSlowMoDuration  < newDuration))
		{
			if (slowdownCauserIds.Size() != 0)
				RemoveSlowMo();
				
			theGame.SetTimeScale( slowdownFactor, theGame.GetTimescaleSource(ETS_PotionBlizzard), theGame.GetTimescalePriority(ETS_PotionBlizzard) );
			slowdownCauserIds.PushBack(target.SetAnimationSpeedMultiplier( 1 / slowdownFactor ));	
			
			currentSlowMoDuration = 0.f;
			currentMaxDuration = newDuration;
		}
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		RemoveSlowMo();
	}
	
	public function OnTimeUpdated(dt : float)
	{
		var slowMotion : float;
		if(slowdownCauserIds.Size() > 0)
		{
			// W3EE - Begin
			super.OnTimeUpdated(dt / slowdownFactor);
			
			currentSlowMoDuration += dt / slowdownFactor;
			
			if(currentSlowMoDuration > currentMaxDuration)
				RemoveSlowMo();			
			
			/*if( Combat().BlizzardDoubleDur() )
			{
				if(currentSlowMoDuration > SLOW_MO_DURATION_EXT)
					RemoveSlowMo();
			}
			else
			{
				if( (GetBuffLevel() == 3 && currentSlowMoDuration > SLOW_MO_DURATION_HIGH) || currentSlowMoDuration > SLOW_MO_DURATION)
					RemoveSlowMo();
			}*/
			// W3EE - End
		}
		else
		{
			super.OnTimeUpdated(dt);
		}
	}
	
	event OnEffectRemoved()
	{
		RemoveSlowMo();
		
		super.OnEffectRemoved();
	}
	
	private final function RemoveSlowMo()
	{
		var i : int;
		
		for(i=0; i<slowdownCauserIds.Size(); i+=1)
		{
			target.ResetAnimationSpeedMultiplier(slowdownCauserIds[i]);
		}
		
		// W3EE - Begin
		//FactsRemove("BlizzardCounter");
		theGame.RemoveTimeScale(theGame.GetTimescaleSource(ETS_PotionBlizzard));
		// W3EE - End
		
		currentMaxDuration = 0.0f;
		currentSlowMoDuration = 0.0f;
		
		slowdownCauserIds.Clear();
	}
}