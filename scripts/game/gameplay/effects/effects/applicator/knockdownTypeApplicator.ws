/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




class W3Effect_KnockdownTypeApplicator extends W3ApplicatorEffect
{
	private saved var customEffectValue : SAbilityAttributeValue;		
	private saved var customDuration : float;							
	private saved var customAbilityName : name;							

	default effectType = EET_KnockdownTypeApplicator;
	default isNegative = true;
	default isPositive = false;
	
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var aardPower	: float;
		var tags : array<name>;
		var i : int;
		var appliedType : EEffectType;
		var null : SAbilityAttributeValue;
		var npc : CNewNPC;
		var params : SCustomEffectParams;
		var min, max : SAbilityAttributeValue;
		// W3EE - Begin
		var sp : SAbilityAttributeValue;
		var resPrc, rawSP : float;
		var effectArray : array<EEffectType>;
		var witcher : W3PlayerWitcher;
		// W3EE - End
		
		if(isOnPlayer)
		{
			thePlayer.OnRangedForceHolster( true, true, false );
		}
		
		
		// W3EE - Begin
		witcher = GetWitcherPlayer();
		if( effectValue.valueMultiplicative + effectValue.valueAdditive > 0 )
			sp = effectValue;
		else
		{
			if( isSignEffect && GetCreator() == witcher )
				sp = witcher.GetSignEntity(ST_Aard).GetTotalSignIntensity();
			else
				sp = creatorPowerStat;
		}
		
		if( witcher.GetSignEntity(ST_Aard).IsAlternateCast() )
		{
			if( witcher.GetSignOwner().GetSkillLevel(S_Magic_s12, witcher.GetSignEntity(ST_Aard)) > 2 )
				aardPower = 0.3f;
			else
				aardPower = MaxF(0.4f, 0.4f + sp.valueMultiplicative - 1);
		}
		else
			aardPower = MaxF(0.2f, 0.2f + sp.valueMultiplicative - 1);
		
		if( isSignEffect && GetCreator() == witcher && witcher.GetPotionBuffLevel(EET_PetriPhiltre) == 3 )
		{
			if( !witcher.GetSignEntity(ST_Aard).IsAlternateCast() || witcher.GetSignOwner().GetSkillLevel(S_Magic_s12, witcher.GetSignEntity(ST_Aard)) <= 2 )
				aardPower = 1;
		}
		
		npc = (CNewNPC)target;
		aardPower *= (1 - npc.GetNPCCustomStat(theGame.params.DAMAGE_NAME_FORCE));
		if(npc && npc.HasShieldedAbility() )
		{
			if( aardPower >= 0.65f )
				effectArray.PushBack(EET_Knockdown);
			if( aardPower >= 0.35f )
				effectArray.PushBack(EET_LongStagger);
			effectArray.PushBack(EET_Stagger);
			
			for(i=0; i<effectArray.Size(); i+=1)
			{
				if( RandF() < aardPower )
				{
					appliedType = effectArray[i];
					break;
				}
				
				if( i == effectArray.Size() - 1 )
					appliedType = effectArray[i];
			}
		}
		else if ( target.HasAbility( 'mon_type_huge' ) )
		{
			if( aardPower >= 0.45f )
				effectArray.PushBack(EET_LongStagger);
			effectArray.PushBack(EET_Stagger);
			
			for(i=0; i<effectArray.Size(); i+=1)
			{
				if( RandF() < aardPower )
				{
					appliedType = effectArray[i];
					break;
				}
				
				if( i == effectArray.Size() - 1 )
					appliedType = effectArray[i];
			}
		}
		else
		if ( target.HasAbility( 'WeakToAard' ) )
		{
			appliedType = EET_Knockdown;
		}
		else
		{
			if( aardPower >= 0.5f )
				effectArray.PushBack(EET_HeavyKnockdown);
			if( aardPower >= 0.4f )
				effectArray.PushBack(EET_Knockdown);
			if( aardPower >= 0.3f )
				effectArray.PushBack(EET_LongStagger);
			effectArray.PushBack(EET_Stagger);
			
			for(i=0; i<effectArray.Size(); i+=1)
			{
				if( RandF() < aardPower )
				{
					appliedType = effectArray[i];
					break;
				}
				
				if( i == effectArray.Size() - 1 )
					appliedType = effectArray[i];
			}
		}
		// W3EE - End
		
		
		appliedType = ModifyHitSeverityBuff(target, appliedType);
		
		
		params.effectType = appliedType;
		params.creator = GetCreator();
		params.sourceName = sourceName;
		params.isSignEffect = isSignEffect;
		params.customPowerStatValue = creatorPowerStat;
		params.customAbilityName = customAbilityName;
		params.duration = customDuration;
		params.effectValue = customEffectValue;	
		
		target.AddEffectCustom(params);
		
		
		
		isActive = true;
		duration = 0;
	}
			
	public function Init(params : SEffectInitInfo)
	{
		customDuration = params.duration;
		customEffectValue = params.customEffectValue;
		customAbilityName = params.customAbilityName;
		
		super.Init(params);
	}
}