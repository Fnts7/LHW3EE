/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/


struct SEffectToxicity
{
	var effectToxicityOrig		: float; 
	var effectToxicity			: float;
	var effectDurationOrig		: float;
	var effectDuration			: float;
}


function FindShortestSEffectToxicity( a : array< SEffectToxicity > ) : int
{
	var i, s, index : int;
	var val, valNew : float;	
	
	s = a.Size();
	if( s > 0 )
	{			
		index = 0;
		val = a[0].effectDuration / a[0].effectDurationOrig	;
		for( i=1; i<s; i+=1 )
		{
			valNew = a[i].effectDuration / a[i].effectDurationOrig;
		
			if( valNew < val )
			{
				index = i;
				val = valNew;
			}
		}
		
		return index;
	}	
	
	return -1;			
}

class W3Effect_Toxicity extends CBaseGameplayEffect
{
	
	default effectType = EET_Toxicity;
	default attributeName = 'toxicityRegen';
	default isPositive = false;
	default isNeutral = true;
	default isNegative = false;	
		
	
	private saved var dmgTypeName 			: name;							
	private saved var toxThresholdEffect	: int;
	private var delayToNextVFXUpdate		: float;
		
	// W3EE - Begin
	public var isUnsafe						: bool;
	private var witcher 					: W3PlayerWitcher;
	private var updateInterval				: float;
	private var maxStat						: float;
	private var residualTox					: float; default residualTox = 0.0f;
	private var effectsToxicity 			: array<SEffectToxicity>;
	private var effectsRevoked				: array<float>;
	// W3EE - End
	
	public function CacheSettings()
	{
		dmgTypeName = theGame.params.DAMAGE_NAME_DIRECT;
		super.CacheSettings();
	}
	
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{	
		if( !((W3PlayerWitcher)target) )
		{
			LogAssert(false, "W3Effect_Toxicity.OnEffectAdded: effect added on non-CR4Player object - aborting!");
			return false;
		}
		
		// W3EE - Begin
		witcher = GetWitcherPlayer();
		// W3EE - End
	
		
		if( witcher.GetStatPercents(BCS_Toxicity) >= witcher.GetToxicityDamageThreshold())
			switchCameraEffect = true;
		else
			switchCameraEffect = false;
		
		super.OnEffectAdded(customParams);	
	}
	

	// W3EE - Begin
	event OnUpdate(deltaTime : float)
	{
		var dmg, dmgCurved, toxicity, toxicityPerc, drainVal, lowestDurationRatio : float;
		var currentThreshold, index : int;
		var skillAbilityName : name;
		
		super.OnUpdate(deltaTime);
		
		updateInterval += deltaTime;
		if( updateInterval < 1.0f )
			return false;
		else
		{
			index = FindShortestSEffectToxicity(effectsToxicity);
			if (index > -1)
				lowestDurationRatio = effectsToxicity[index].effectDuration / effectsToxicity[index].effectDurationOrig;
		}
		
		if (!witcher)
			witcher = GetWitcherPlayer();
		
		toxicity = witcher.GetStat(BCS_Toxicity, false);
		toxicityPerc = toxicity / witcher.GetStatMax(BCS_Toxicity);
		
		if( toxicityPerc >= 0.5f && !isPlayingCameraEffect )
			switchCameraEffect = true;
		else
		if( toxicityPerc < 0.5f && isPlayingCameraEffect )
			switchCameraEffect = true;
		
		if( delayToNextVFXUpdate <= 0 )
		{		
			if( toxicityPerc < 0.25f )		currentThreshold = 0;
			else
			if( toxicityPerc < 0.5f )		currentThreshold = 1;
			else
			if( toxicityPerc < 0.75f )		currentThreshold = 2;
			else
				currentThreshold = 3;
			
			if( toxThresholdEffect != currentThreshold && !target.IsEffectActive('invisible' ) )
			{
				toxThresholdEffect = currentThreshold;
				switch ( toxThresholdEffect )
				{
					case 0: PlayHeadEffect('toxic_000_025'); break;
					case 1: PlayHeadEffect('toxic_025_050'); break;
					case 2: PlayHeadEffect('toxic_050_075'); break;
					case 3: PlayHeadEffect('toxic_075_100'); break;
				}
				
				
				delayToNextVFXUpdate = 2;
			}			
		}
		else
		{
			delayToNextVFXUpdate -= 1.0f;
		}
		
		if( toxicity > witcher.GetToxicityDamageThreshold() )
		{
			if( !maxStat )
			{
				if( target.UsesVitality() )
					maxStat = target.GetStatMax(BCS_Vitality);
				else
					maxStat = target.GetStatMax(BCS_Essence);
			}
			dmgCurved = PowF(toxicityPerc, 2) * (1.3f + 0.008f * toxicity) / 100;
			/*dmg = MaxF(0, dmgCurved * maxStat);*/
			dmg = MaxF(0, dmgCurved * maxStat - (effectsToxicity.Size() + effectsRevoked.Size()) * 2.0f * thePlayer.GetSkillLevel(S_Alchemy_s03));
			
			if( thePlayer.CanUseSkill(S_Alchemy_s01) )
				dmg *= (1 - 0.08f * thePlayer.GetSkillLevel(S_Alchemy_s01));
			
			/*A CDProjekt comment used to dwell here. Let's reminisce about it by contemplating the big chunk of space left in its place.*/
			
			
			
			
			if( dmg > 0 )
				effectManager.CacheDamage(dmgTypeName, dmg, NULL, this, 1.0f, true, CPS_Undefined, false);
			else
				LogAssert(false, "W3Effect_Toxicity: should deal damage but deals 0 damage!");
			
			/*
			if( thePlayer.CanUseSkill(S_Alchemy_s20) && !target.HasBuff(EET_IgnorePain) )
				target.AddEffectDefault(EET_IgnorePain, target, 'IgnorePain');
			*/
			isUnsafe = true;
		}
		else
		{
			skillAbilityName = SkillEnumToName(S_Alchemy_s17);
			while(thePlayer.HasAbility(skillAbilityName))
				thePlayer.RemoveAbility(skillAbilityName);
			// W3EE - Begin
			isUnsafe = false;
			// target.RemoveBuff(EET_IgnorePain);
			// W3EE - End
		}
		
		toxicity = witcher.GetStat(BCS_Toxicity, true);
		
		if (toxicity)
		{		
			drainVal = 0;
			
			if ( index < 0 || residualTox > 0 )
			{
				if( index < 0 )
					drainVal = (-1 * toxicity * Options().GetToxicityResidualDegen()) - 0.1f;
				else
					drainVal = (-1 * residualTox * Options().GetToxicityResidualDegen() / 5.0f ) - 0.02f;
				
				if (residualTox > 0)
					residualTox += drainVal;
			}			
			
			if (index >= 0)
			{			
				if( Options().GetSlowToxicityCombatDegen() && target.IsInCombat() )
				{
					drainVal -= CalcToxicityDegen( Options().GetToxicityCombatDegen() );
				}
				else if( lowestDurationRatio < Options().GetFastToxicityDegenThreshold() )
					drainVal -= CalcToxicityDegen( Options().GetStandardToxicityDegen(), Options().GetFastToxicityDegen());
				else			
					drainVal -= CalcToxicityDegen( Options().GetStandardToxicityDegen() );
			}
			
			if( isUnsafe )
				drainVal -= FastClearDegen();
		}
		
		UpdateEffectsTimeAndRemove();
		
		if (!toxicity)	
			return false;
		
		effectManager.CacheStatUpdate(BCS_Toxicity, drainVal);
	}
	
	public function SetEffectTime( toxicity, duration : float ) : void
	{
		var potionTox : SEffectToxicity;
		
		if (duration <= 0)
		{
			if (toxicity > 0)
				residualTox += toxicity;
		}
		else if (toxicity > 0)
		{
			potionTox.effectToxicityOrig = toxicity;
			potionTox.effectToxicity = toxicity;
			potionTox.effectDurationOrig = duration;
			potionTox.effectDuration = duration;
			effectsToxicity.PushBack(potionTox);
		}
	}
	
	public function GetEnzymaticToxReduction() : float
	{
		if (thePlayer.CanUseSkill(S_Alchemy_s03))
		{
			return (effectsToxicity.Size() + effectsRevoked.Size()) * (1.0f + (thePlayer.GetSkillLevel(S_Alchemy_s03) - 1) * 0.5f);			
		}
		else
			return 0;
	}
	
	public function ClearAllEffects()
	{
		var skillAbilityName : name;
		
		residualTox = 0;
		effectsToxicity.Clear();
		effectsRevoked.Clear();
		
		skillAbilityName = SkillEnumToName(S_Alchemy_s17);
		while(thePlayer.HasAbility(skillAbilityName))
			thePlayer.RemoveAbility(skillAbilityName);
	}

	private function UpdateEffectsTimeAndRemove() : void
	{
		var i : int;
		
		for(i=effectsRevoked.Size() - 1; i >= 0 ; i-=1)
		{
			effectsRevoked[i] -= updateInterval;
			if (effectsRevoked[i] <= 0 )
				effectsRevoked.Erase(i);		
		}
		
		for(i=effectsToxicity.Size() - 1; i >= 0 ; i-=1)
		{
			effectsToxicity[i].effectDuration -= updateInterval;			
			if (effectsToxicity[i].effectDuration <= 0 || effectsToxicity[i].effectToxicity <= 0 )
			{
				if (effectsToxicity[i].effectToxicity > 0)
					residualTox += effectsToxicity[i].effectToxicity;
					
				if (effectsToxicity[i].effectDuration > 0)
					effectsRevoked.PushBack(effectsToxicity[i].effectDuration);
			
				effectsToxicity.Erase(i);				
			}
		}
			
		updateInterval = 0;
	}
	
	private function FastClearDegen() : float
	{
		var drainVal : float;
		
		if( !witcher.CanUseSkill(S_Alchemy_s15) )
			return 0.0f;
		
		drainVal = witcher.GetSkillLevel(S_Alchemy_s15) * 0.05f;
		witcher.GetAdrenalineEffect().AddAdrenaline(drainVal / 40.f);
		FastClearUpdate(drainVal);		
		
		return drainVal;			
	}

	
	private function FastClearUpdate(drainVal : float)
	{
		var i			: int;
		var unitDegen 	: float;
		
		unitDegen = drainVal;
		if (residualTox > 0)
		{
			unitDegen /= (effectsToxicity.Size() + 1);
			residualTox -= unitDegen;
			if (residualTox < 0)
				residualTox = 0;
		}
		else
			unitDegen /= effectsToxicity.Size();
			
		for( i = 0; i < effectsToxicity.Size(); i += 1 )
		{
			effectsToxicity[i].effectToxicity -= unitDegen;
		}	
	}


	private function CalcToxicityDegen( multiplierStandard : float, optional multiplierFast : float) : float
	{
		var index : int;
		var degenValue, unitValue : float;
		
		for(index=0; index < effectsToxicity.Size(); index+=1 )		
		{
			if( multiplierFast && (effectsToxicity[index].effectDuration / effectsToxicity[index].effectDurationOrig) < Options().GetFastToxicityDegenThreshold() )
			{
				unitValue = (effectsToxicity[index].effectToxicityOrig / effectsToxicity[index].effectDurationOrig) * multiplierFast;
			}
			else
				unitValue = (effectsToxicity[index].effectToxicityOrig / effectsToxicity[index].effectDurationOrig) * multiplierStandard;
				
			unitValue *= MinF(updateInterval, effectsToxicity[index].effectDuration);
			
			unitValue = MinF(unitValue, effectsToxicity[index].effectToxicity);				
			effectsToxicity[index].effectToxicity -= unitValue;
				
			degenValue += unitValue;
		}
		
		return degenValue;
	}
	// W3EE - End
	
	function PlayHeadEffect( effect : name, optional stop : bool )
	{
		var inv : CInventoryComponent;
		var headIds : array<SItemUniqueId>;
		var headId : SItemUniqueId;
		var head : CItemEntity;
		var i : int;
		
		inv = target.GetInventory();
		headIds = inv.GetItemsByCategory('head');
		
		for ( i = 0; i < headIds.Size(); i+=1 )
		{
			if ( !inv.IsItemMounted( headIds[i] ) )
			{
				continue;
			}
			
			headId = headIds[i];
					
			if(!inv.IsIdValid( headId ))
			{
				LogAssert(false, "W3Effect_Toxicity : Can't find head item");
				return;
			}
			
			head = inv.GetItemEntityUnsafe( headId );
			
			if( !head )
			{
				LogAssert(false, "W3Effect_Toxicity : head item is null");
				return;
			}

			if ( stop )
			{
				head.StopEffect( effect );
			}
			else
			{
				head.PlayEffectSingle( effect );
			}
		}
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		
		toxThresholdEffect = -1;
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
		
		// W3EE - Begin
		/*
		if(thePlayer.CanUseSkill(S_Alchemy_s20) && target.HasBuff(EET_IgnorePain))
			target.RemoveBuff(EET_IgnorePain);
		*/
		// W3EE - End
		
		ClearAllEffects();		
		
		PlayHeadEffect( 'toxic_000_025', true );
		PlayHeadEffect( 'toxic_025_050', true );
		PlayHeadEffect( 'toxic_050_075', true );
		PlayHeadEffect( 'toxic_075_100', true );
		
		PlayHeadEffect( 'toxic_025_000', true );
		PlayHeadEffect( 'toxic_050_025', true );
		PlayHeadEffect( 'toxic_075_050', true );
		PlayHeadEffect( 'toxic_100_075', true );
		
		toxThresholdEffect = 0;
	}
	
	protected function SetEffectValue()
	{
		RecalcEffectValue();
	}
	
	public function RecalcEffectValue()
	{
		var min, max : SAbilityAttributeValue;
		var dm : CDefinitionsManagerAccessor;
	
		if(!IsNameValid(abilityName))
			return;
	
		
		dm = theGame.GetDefinitionsManager();
		dm.GetAbilityAttributeValue(abilityName, attributeName, min, max);
		effectValue = GetAttributeRandomizedValue(min, max);
		
		
		if(thePlayer.CanUseSkill(S_Alchemy_s15))
			effectValue += thePlayer.GetSkillAttributeValue(S_Alchemy_s15, attributeName, false, true) * thePlayer.GetSkillLevel(S_Alchemy_s15);
		
		
		// W3EE - Begin
		/*if(thePlayer.HasAbility('Runeword 8 Regen'))
			effectValue += thePlayer.GetAbilityAttributeValue('Runeword 8 Regen', 'toxicityRegen');*/
		// W3EE - End
	}
}
