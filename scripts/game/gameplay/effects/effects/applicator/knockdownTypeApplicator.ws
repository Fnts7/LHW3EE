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
		//var effectArray : array<EEffectType>;
		var witcher : W3PlayerWitcher;
		var penaltyLevel : int; 
		var refBlastMod : bool;
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
		
		refBlastMod = false;
		if (witcher.GetSignEntity(ST_Aard).IsAlternateCast())
		{
			penaltyLevel = 3 - witcher.GetSignOwner().GetSkillLevel(S_Magic_s01);				
			if(penaltyLevel > 0)
			{
				if (penaltyLevel > 2) penaltyLevel = 2;							
				sp.valueMultiplicative -= 0.15f * penaltyLevel;
			}
			
			if( witcher.GetSignOwner().GetSkillLevel(S_Magic_s12, witcher.GetSignEntity(ST_Aard)) > 2 )
				refBlastMod = true;			
		}
		
		if (sp.valueMultiplicative >= 1.0f)
		{
			aardPower = - 0.6f + sp.valueMultiplicative;
		}
		else
		{
			aardPower = MaxF(0.0f, 0.4f - 0.4f * (1.0f - sp.valueMultiplicative));
		}
		
		if( isSignEffect && GetCreator() == witcher && witcher.GetPotionBuffLevel(EET_PetriPhiltre) == 3 )
		{
			aardPower += 0.2f;
		}
		
		npc = (CNewNPC)target;
		aardPower *= (1 - npc.GetNPCCustomStat(theGame.params.DAMAGE_NAME_FORCE));
		
		if (refBlastMod)
			aardPower = MinF(0.25f, aardPower);		


		if(npc && npc.HasShieldedAbility() )
		{
			aardPower = MinF(1.2f, aardPower);
			aardPower += RandF();
			
			if( aardPower >= 1.5f )
				appliedType = EET_Knockdown;
			else if( aardPower >= 0.85f )
				appliedType = EET_LongStagger;
			else
				appliedType = EET_Stagger;
			
			/*if( aardPower >= 0.65f )
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
			}*/
		}
		else if ( target.HasAbility( 'mon_type_huge' ) )
		{
			aardPower = MinF(1.0f, aardPower);
			aardPower += RandF();
			
			if( aardPower >= 1.1f )
				appliedType = EET_LongStagger;
			else
				appliedType = EET_Stagger;
		
			/*if( aardPower >= 0.45f )
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
			}*/
		}
		else
		if ( target.HasAbility( 'WeakToAard' ) )
		{
			aardPower = MinF(0.8f, aardPower);
			aardPower += RandF();
			
			if( aardPower >= 1.0f )
				appliedType = EET_HeavyKnockdown;
			else
				appliedType = EET_Knockdown;
		}
		else
		{
			aardPower = MinF(1.05f, aardPower);
			aardPower += RandF();
			
			if( aardPower >= 1.3f )
				appliedType = EET_HeavyKnockdown;
			else if( aardPower >= 1.0f )
				appliedType = EET_Knockdown;
			else if( aardPower >= 0.7f )
				appliedType = EET_LongStagger;
			else
				appliedType = EET_Stagger;
		
			/*if( aardPower >= 0.5f )
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
			}*/
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