/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




abstract class W3RegenEffect extends CBaseGameplayEffect
{
	protected var regenStat : ECharacterRegenStats;			
	protected saved var stat : EBaseCharacterStats;			
	private var isOnMonster : bool;	
	// W3EE - Begin
	var playerWitcher : W3PlayerWitcher;
	// W3EE - End
	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnUpdate(dt : float)
	{
		var regenPoints : float;
		var canRegen : bool;
		var hpRegenPauseBuff : W3Effect_DoTHPRegenReduce;
		var pauseRegenVal, armorModVal : SAbilityAttributeValue;
		var baseStaminaRegenVal : float;
		// W3EE - Begin
		var regenReduction : float;
		var targetHealthPerc : float;
		// W3EE - End
		
		super.OnUpdate(dt);
		
		// W3EE - Begin
		/*
		if(stat == BCS_Vitality && isOnPlayer && target == playerWitcher && playerWitcher.HasRunewordActive('Runeword 4 _Stats'))
		{
			canRegen = true;
		}
		else
		*/
		// W3EE - End
		{
			canRegen = (target.GetStatPercents(stat) < 1);
		}
		
		if(canRegen)
		{
			// W3EE - Begin
			if(isOnPlayer && (regenStat == CRS_Stamina || regenStat == CRS_Vitality) && !StrContains(EffectTypeToName(effectType), "Auto"))
				regenPoints = 0;
			else
			// W3EE - End
			regenPoints = effectValue.valueAdditive + effectValue.valueMultiplicative * target.GetStatMax(stat);
			
			if (isOnPlayer && regenStat == CRS_Stamina && attributeName == RegenStatEnumToName(regenStat) && playerWitcher)
			{
				baseStaminaRegenVal = playerWitcher.CalculatedArmorStaminaRegenBonus();
				
				regenPoints *= 1 + baseStaminaRegenVal;
			}
			
			else if(regenStat == CRS_Vitality || regenStat == CRS_Essence)
			{
				hpRegenPauseBuff = (W3Effect_DoTHPRegenReduce)target.GetBuff(EET_DoTHPRegenReduce);
				if(hpRegenPauseBuff)
				{
					pauseRegenVal = hpRegenPauseBuff.GetEffectValue();
					regenPoints = MaxF(0, regenPoints * (1 - pauseRegenVal.valueMultiplicative) - pauseRegenVal.valueAdditive);
				}
			}

			// W3EE - Begin
			if (regenStat == CRS_Stamina && attributeName == RegenStatEnumToName(regenStat))
			{
				if(target.UsesVitality())
					targetHealthPerc = target.GetStatPercents(BCS_Vitality);
				else
					targetHealthPerc = target.GetStatPercents(BCS_Essence);
				
				regenPoints *= 1.f - PowF(1.f - targetHealthPerc, 2) * 0.75f * playerWitcher.GetAdrenalinePercMult();
				
				if ( isOnPlayer )
					regenPoints *= (1.f + playerWitcher.GetAdrenalineEffect().GetValue() * 1.5f);
				else
					regenPoints *= 0.5f;
			}
			
			if(isOnPlayer)
			{
				if (regenStat == CRS_Vitality) 
					regenReduction = 0.5f - 0.06f * playerWitcher.GetSkillLevel(S_Alchemy_s01);
				else
					regenReduction = 0.6f - 0.06f * playerWitcher.GetSkillLevel(S_Alchemy_s20);
				regenPoints *= 1 - (regenReduction * playerWitcher.GetStatPercents(BCS_Toxicity) * playerWitcher.GetAdrenalinePercMultHalf());
			}
			// W3EE - End
			
			if( regenPoints > 0 )
				effectManager.CacheStatUpdate(stat, regenPoints * dt);
		}
	}	
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		var null : SAbilityAttributeValue;
		
		super.OnEffectAdded(customParams);
		
		// W3EE - Begin
		playerWitcher = GetWitcherPlayer();
		// W3EE - End
		
		if(effectValue == null)
		{
			isActive = false;
		}
		else if(target.GetStatMax(stat) <= 0)
		{
			isActive = false;
		}
		CheckMonsterTarget();
	}
	
	private function CheckMonsterTarget()
	{
		var monsterCategory : EMonsterCategory;
		var temp_n : name;
		var temp_b : bool;
		
		theGame.GetMonsterParamsForActor(target, monsterCategory, temp_n, temp_b, temp_b, temp_b);
		isOnMonster = (monsterCategory != MC_Human);
	}
	
	public function OnLoad(t : CActor, eff : W3EffectManager)
	{
		super.OnLoad(t, eff);
		CheckMonsterTarget();
	}
	
	public function CacheSettings()
	{
		var i,size : int;
		var att : array<name>;
		var dm : CDefinitionsManagerAccessor;
		var atts : array<name>;
							
		super.CacheSettings();
		
		
		if(regenStat == CRS_Undefined)
		{
			dm = theGame.GetDefinitionsManager();
			dm.GetAbilityAttributes(abilityName, att);
			size = att.Size();
			
			for(i=0; i<size; i+=1)
			{
				regenStat = RegenStatNameToEnum(att[i]);
				if(regenStat != CRS_Undefined)
					break;
			}
		}
		stat = GetStatForRegenStat(regenStat);
		attributeName = RegenStatEnumToName(regenStat);
	}
	
	public function GetRegenStat() : ECharacterRegenStats
	{
		return regenStat;
	}
	
	public function UpdateEffectValue()
	{
		SetEffectValue();
	}
}