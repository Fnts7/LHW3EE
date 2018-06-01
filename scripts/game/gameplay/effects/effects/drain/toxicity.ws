/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



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
		var dmg, dmgCurved, toxicity, toxicityPerc, threshold, drainVal, duration, origDuration : float;
		var currentThreshold, index	: int;
		var skillAbilityName : name;
		
		super.OnUpdate(deltaTime);
		
		updateInterval += deltaTime;
		if( updateInterval < 1.0f )
			return false;
		else
		{
			UpdateEffectsTime();
			while( duration <= 0 )
			{
				index = ArrayFindMinF(effectDuration);
				if( index > -1 )
				{
					duration = effectDuration[index];
					origDuration = effectDurationOrig[index];
					if( duration <= 0 || !effectToxicity[index] )
						ClearEffects(index);
				}
				else break;				
			}			
			updateInterval = 0;
		}
		
		if (!witcher)
			witcher = GetWitcherPlayer();
		
		toxicityPerc = witcher.GetStat(BCS_Toxicity, false) / witcher.GetStatMax(BCS_Toxicity);
		threshold = witcher.GetToxicityDamageThreshold();
		
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
		
		toxicity = witcher.GetStat(BCS_Toxicity, false);
		if( toxicity > threshold )
		{
			if( !maxStat )
			{
				if( target.UsesVitality() )
					maxStat = target.GetStatMax(BCS_Vitality);
				else
					maxStat = target.GetStatMax(BCS_Essence);
			}
			dmgCurved = PowF(toxicityPerc, 2) * (1.3f + toxicity / 100) / 100;
			/*dmg = MaxF(0, dmgCurved * maxStat);*/
			dmg = MaxF(0, dmgCurved * maxStat - effectDuration.Size() * RoundMath(1.66 * thePlayer.GetSkillLevel(S_Alchemy_s03)));
			
			if( thePlayer.CanUseSkill(S_Alchemy_s01) )
				dmg *= (1 - 0.09f * thePlayer.GetSkillLevel(S_Alchemy_s01));
			
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
		if (!toxicity)	
			return false;		
		
		if( index < 0 )
			drainVal = (-1 * toxicity * Options().GetToxicityResidualDegen()) - 0.1f;
		else
		if( (duration / origDuration) < Options().GetFastToxicityDegenThreshold() )
			drainVal = -1 * GetToxicityDegen(Options().GetFastToxicityDegen());
		else			
			drainVal = -1 * GetToxicityDegen() * Options().GetStandardToxicityDegen();
		
		
		if( Options().GetSlowToxicityCombatDegen() )
		{
			if( target.IsInCombat() && index > -1 )
				drainVal = -1 * GetToxicityDegen() * Options().GetToxicityCombatDegen();
		}
		if( witcher.GetSkillLevel(S_Alchemy_s15) && (toxicity / witcher.GetStatMax(BCS_Toxicity)) >= threshold )
		{
			drainVal -= (witcher.GetSkillLevel(S_Alchemy_s15) * 0.1);
			witcher.GetAdrenalineEffect().AddAdrenaline(AbsF(drainVal) / 100.f);
		}
		
		if( isUnsafe )
		{
			if( witcher.GetSkillLevel(S_Alchemy_s15) )
			{
				drainVal -= (witcher.GetSkillLevel(S_Alchemy_s15) * 0.1);
				witcher.GetAdrenalineEffect().AddAdrenaline(AbsF(drainVal) / 100.f);
			}
		}
		
		effectManager.CacheStatUpdate(BCS_Toxicity, drainVal);
	}
	
	private var effectToxicity : array<float>;
	private var effectDuration : array<float>;
	private var effectDurationOrig : array<float>;
	public function SetEffectTime( toxicity, duration : float ) : void
	{
		effectToxicity.PushBack(toxicity);
		effectDuration.PushBack(duration);
		effectDurationOrig.PushBack(duration);
	}
	
	private function UpdateEffectsTime() : void
	{
		var i : int;
		for(i=0; i<effectDuration.Size(); i+=1)
			effectDuration[i] -= updateInterval;
	}
	
	private function ClearEffects( index : int ) : void
	{
		effectToxicity.Erase(index);
		effectDuration.Erase(index);
		effectDurationOrig.Erase(index);
	}
	
	private function GetToxicityDegen( optional multiplier : float ) : float
	{
		var index : int;
		var degenValue : float;
		
		for(index=0; index<effectToxicity.Size(); index+=1)
		{
			if( multiplier && (effectDuration[index] / effectDurationOrig[index]) < Options().GetFastToxicityDegenThreshold() )
				degenValue += (effectToxicity[index] / effectDurationOrig[index]) * multiplier;
			else 
				degenValue += (effectToxicity[index] / effectDurationOrig[index]);
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
