/****************************************************************************/
/** Copyright © CD Projekt RED 2015
/** Author : Reaperrz
/****************************************************************************/

struct SMutationRequirements
{
	var skillPaths : array<ESkillSubPath>;
	var requiredPoints : array<int>;
}

struct SSkillPathEntry
{
	var expValue, maxPoints : int;
	var totalID, spentID, progressID : string;
}

class W3EEExperienceHandler
{
	private var skillPathEntries : array<SSkillPathEntry>;
	private var playerWitcher : W3PlayerWitcher;
	
	private const var POTION_TOXICITY_BONUS_MAX : float;																					
		default POTION_TOXICITY_BONUS_MAX = 0.4f;
		
	private const var DECOCTION_BONUS : float;																					
		default DECOCTION_BONUS = 0.6f;
		
	private const var WITCHER_TOXICITY_BONUS_MAX : float;																					
		default WITCHER_TOXICITY_BONUS_MAX = 0.4f;
	
	public function FactsSetValue( ID : string, value : int )
	{
		FactsRemove(ID);
		FactsAdd(ID, value, -1);
	}
	
	private function GetPathData( skillPath : ESkillSubPath ) : SSkillPathEntry
	{
		var pathEntry : SSkillPathEntry;
		switch(skillPath)
		{
			case ESSP_Sword_StyleFast:
				pathEntry.totalID = "FastAttackPoints";
				pathEntry.spentID = "FastAttackPointsSpent";
				pathEntry.progressID = "FastAttackProgress";
				pathEntry.maxPoints = 18;
				// W3EE orig value: 20
				pathEntry.expValue = RoundMath(17 * Options().GetSkillRateFast());
			break;
			
			case ESSP_Sword_StyleStrong:
				pathEntry.totalID = "HeavyAttackPoints";
				pathEntry.spentID = "HeavyAttackPointsSpent";
				pathEntry.progressID = "HeavyAttackProgress";
				pathEntry.maxPoints = 18;
				// W3EE orig value: 25
				pathEntry.expValue = RoundMath(23 * Options().GetSkillRateStrong());
			break;
			
			case ESSP_Sword_Utility:
				pathEntry.totalID = "DefensePoints";
				pathEntry.spentID = "DefensePointsSpent";
				pathEntry.progressID = "DefenseProgress";
				pathEntry.maxPoints = 14;
				// W3EE orig value: 15
				pathEntry.expValue = RoundMath(11 * Options().GetSkillRateUtility());
			break;
			
			case ESSP_Sword_Crossbow:
				pathEntry.totalID = "RangedPoints";
				pathEntry.spentID = "RangedPointsSpent";
				pathEntry.progressID = "RangedProgress";
				pathEntry.maxPoints = 16;
				// W3EE orig value: 181
				pathEntry.expValue = RoundMath(145 * Options().GetSkillRateCrossbow());
			break;
			
			case ESSP_Sword_BattleTrance:
				pathEntry.totalID = "TrancePoints";
				pathEntry.spentID = "TrancePointsSpent";
				pathEntry.progressID = "TranceProgress";
				pathEntry.maxPoints = 19;
				// W3EE orig value: 114
				pathEntry.expValue = RoundMath(22 * Options().GetSkillRateTrance());
			break;
			
			case ESSP_Signs_Aard:
				pathEntry.totalID = "AardPoints";
				pathEntry.spentID = "AardPointsSpent";
				pathEntry.progressID = "AardProgress";
				pathEntry.maxPoints = 16;
				// W3EE orig value: 125
				pathEntry.expValue = RoundMath(90 * Options().GetSkillRateAard());
			break;
			
			case ESSP_Signs_Igni:
				pathEntry.totalID = "IgniPoints";
				pathEntry.spentID = "IgniPointsSpent";
				pathEntry.progressID = "IgniProgress";
				pathEntry.maxPoints = 18;
				// W3EE orig value: 128
				pathEntry.expValue = RoundMath(80 * Options().GetSkillRateIgni());
			break;
			
			case ESSP_Signs_Yrden:
				pathEntry.totalID = "YrdenPoints";
				pathEntry.spentID = "YrdenPointsSpent";
				pathEntry.progressID = "YrdenProgress";
				pathEntry.maxPoints = 15;
				// W3EE orig value: 161
				pathEntry.expValue = RoundMath(160 * Options().GetSkillRateYrden());
			break;
			
			case ESSP_Signs_Quen:
				pathEntry.totalID = "QuenPoints";
				pathEntry.spentID = "QuenPointsSpent";
				pathEntry.progressID = "QuenProgress";
				pathEntry.maxPoints = 16;
				// W3EE orig value: 128
				pathEntry.expValue = RoundMath(125 * Options().GetSkillRateQuen());
			break;
			
			case ESSP_Signs_Axi:
				pathEntry.totalID = "AxiiPoints";
				pathEntry.spentID = "AxiiPointsSpent";
				pathEntry.progressID = "AxiiProgress";
				pathEntry.maxPoints = 14;
				// W3EE orig value: 181
				pathEntry.expValue = RoundMath(125 * Options().GetSkillRateAxii());
			break;
			
			case ESSP_Alchemy_Potions:
				pathEntry.totalID = "BrewingPoints";
				pathEntry.spentID = "BrewingPointsSpent";
				pathEntry.progressID = "BrewingProgress";
				pathEntry.maxPoints = 13;
				// W3EE orig value: 404
				pathEntry.expValue = RoundMath(390 * Options().GetSkillRatePotions());
			break;
			
			case ESSP_Alchemy_Oils:
				pathEntry.totalID = "OilingPoints";
				pathEntry.spentID = "OilingPointsSpent";
				pathEntry.progressID = "OilingProgress";
				pathEntry.maxPoints = 18;
				// W3EE orig value: 404
				pathEntry.expValue = RoundMath(500 * Options().GetSkillRateOils());
			break;
			
			case ESSP_Alchemy_Bombs:
				pathEntry.totalID = "BombPoints";
				pathEntry.spentID = "BombPointsSpent";
				pathEntry.progressID = "BombProgress";
				pathEntry.maxPoints = 16;
				// W3EE orig value: 576
				pathEntry.expValue = RoundMath(525 * Options().GetSkillRateBombs());
			break;
			
			case ESSP_Alchemy_Mutagens:
				pathEntry.totalID = "MutationPoints";
				pathEntry.spentID = "MutationPointsSpent";
				pathEntry.progressID = "MutationProgress";
				pathEntry.maxPoints = 18;
				// W3EE orig value: 349
				pathEntry.expValue = RoundMath(380 * Options().GetSkillRateMutagens());
			break;
			
			case ESSP_Alchemy_Grasses:
				pathEntry.totalID = "TrialPoints";
				pathEntry.spentID = "TrialPointsSpent";
				pathEntry.progressID = "TrialProgress";
				pathEntry.maxPoints = 17;
				pathEntry.expValue = RoundMath(300 * Options().GetSkillRateGrasses());
			break;
			
			case ESSP_Perks:
			case ESSP_Perks_col1:
			case ESSP_Perks_col2:
			case ESSP_Perks_col3:
			case ESSP_Perks_col4:
			case ESSP_Perks_col5:
				pathEntry.totalID = "GeneralPoints";
				pathEntry.spentID = "GeneralPointsSpent";
				pathEntry.progressID = "GeneralProgress";
				pathEntry.maxPoints = 20;
				// W3EE orig value: 201
				pathEntry.expValue = RoundMath(140 * Options().GetSkillRateGeneral());
			break;
		}
		return pathEntry;
	}
	
	protected function AddSkillEntry( skillName : string, startingPoints : int )
	{
		FactsAdd(skillName + "Points", startingPoints, -1);
		FactsAdd(skillName + "PointsSpent", 0, -1);
		FactsAdd(skillName + "Progress", 0, -1);
	}
	
	protected function ModSpentPathPoints( skillPath : ESkillSubPath, value : int )
	{
		var id : int;
		
		value *= 10;
		id = Min((int)skillPath, 16);
		FactsSetValue(skillPathEntries[id].spentID, FactsQueryLatestValue(skillPathEntries[id].spentID) + value);
	}
	
	public function ModTotalPathPoints( skillPath : ESkillSubPath, value : float )
	{
		var id, val : int;
		
		val = (int)(value * 10);
		id = Min((int)skillPath, 16);
		FactsSetValue(skillPathEntries[id].totalID, FactsQueryLatestValue(skillPathEntries[id].totalID) + val);
		FactsSetValue("TotalPoints", FactsQueryLatestValue("TotalPoints") + val);
		((W3PlayerAbilityManager)playerWitcher.abilityManager).OnLevelGained(1);
		playerWitcher.DisplayHudMessage(GetLocStringByKeyExt(SkillSubPathToLocalisationKey(skillPath)) + " " + GetLocStringByKeyExt("W3EE_SkillGain"));
	}
	
	public function ModPathProgress( skillPath : ESkillSubPath, mult : float )
	{
		var id, xp, skillValue : int;
		var xpFloat : float;
		
		id = Min((int)skillPath, 16);
		skillValue = (int)(Options().SkillPointsGained() * 10);
		
		xpFloat = skillPathEntries[id].expValue * mult;
		
		// skill path penalty
		if (skillPath == ESSP_Perks)
		{
			xpFloat *= 1.0f - (0.6f * Min(GetTotalPathPoints(skillPath), 6)) / 6;
		}
		else
			xpFloat *= 1.0f - (0.45f * GetTotalPathPoints(skillPath) / skillPathEntries[id].maxPoints);
			
		// all skill points penalty
		xpFloat *= 1.0f - (0.4f * GetTotalSkillPoints() / 256);
		
		xp = FactsQueryLatestValue(skillPathEntries[id].progressID) + FloorF(xpFloat);
		if( xp < 10000 )
		{
			FactsSetValue(skillPathEntries[id].progressID, xp);
		}
		else
		{
			while( xp >= 10000 )
			{
				xp = Max(0, xp - 10000);
				FactsSetValue(skillPathEntries[id].totalID, FactsQueryLatestValue(skillPathEntries[id].totalID) + skillValue);
				FactsSetValue("TotalPoints", FactsQueryLatestValue("TotalPoints") + skillValue);
				((W3PlayerAbilityManager)playerWitcher.abilityManager).OnLevelGained(1);
			}
			FactsSetValue(skillPathEntries[id].progressID, xp);
			playerWitcher.DisplayHudMessage(GetLocStringByKeyExt(SkillSubPathToLocalisationKey(skillPath)) + " " + GetLocStringByKeyExt("W3EE_SkillGain"));
		}
	}
	
	public function ResetPathProgress( skillPath : ESkillSubPath )
	{
		var id : int;

		id = Min((int)skillPath, 16);		
		FactsSetValue(skillPathEntries[id].progressID, 0);
	}
	
	public function GetTotalSkillPoints() : int
	{
		return FloorF(FactsQueryLatestValue("TotalPoints") / 10);
	}
	
	public function GetTotalPathPoints( skillPath : ESkillSubPath ) : int
	{
		var id : int;
		
		id = Min((int)skillPath, 16);
		return FloorF(FactsQueryLatestValue(skillPathEntries[id].totalID) / 10);
	}
	
	public function GetSpentPathPoints( skillPath : ESkillSubPath ) : int
	{
		var id : int;
		
		id = Min((int)skillPath, 16);
		return FloorF(FactsQueryLatestValue(skillPathEntries[id].spentID) / 10);
	}
	
	public function GetCurrentPathPoints( skillPath : ESkillSubPath ) : int
	{
		var id : int;
		
		id = Min((int)skillPath, 16);
		return FloorF((FactsQueryLatestValue(skillPathEntries[id].totalID) - FactsQueryLatestValue(skillPathEntries[id].spentID)) / 10);
	}
	
	public function GetPathProgress( skillPath : ESkillSubPath ) : int
	{
		var id : int;
		
		id = Min((int)skillPath, 16);
		return FloorF(FactsQueryLatestValue(skillPathEntries[id].progressID) / 100);
	}
	
	public function InitializeSkills( player : W3PlayerWitcher )
	{
		var i : int;
		playerWitcher = player;
		
		if( !FactsQuerySum("LevelingInitialized") )
		{
			FactsAdd("LevelingInitialized", 1, -1);
			
			AddSkillEntry("FastAttack"	, 10);
			AddSkillEntry("HeavyAttack"	, 10);
			AddSkillEntry("Defense"		, 10);
			AddSkillEntry("Ranged"		, 10);
			AddSkillEntry("Trance"		, 10);
			
			AddSkillEntry("Aard"		, 0);
			AddSkillEntry("Igni"		, 0);
			AddSkillEntry("Yrden"		, 0);
			AddSkillEntry("Quen"		, 0);
			AddSkillEntry("Axii"		, 0);
			
			AddSkillEntry("Brewing"		, 10);
			AddSkillEntry("Oiling"		, 10);
			AddSkillEntry("Bomb"		, 10);
			AddSkillEntry("Mutation"	, 10);
			AddSkillEntry("Trial"		, 10);
			
			AddSkillEntry("General"		, 0);
			
			FactsAdd("TotalPoints", 100, -1);
		}
		
		skillPathEntries.Clear();
		skillPathEntries.PushBack(SSkillPathEntry(0, 0, "", "", ""));
		for(i=1; i<EnumGetMax('ESkillSubPath') - 5; i+=1)
		{
			skillPathEntries.PushBack(GetPathData((ESkillSubPath)i));
		}
	}
	
	public function AwardGeneralXP( fromQuest : bool )
	{
		if( fromQuest )
			ModPathProgress(ESSP_Perks, 1.5f);
		else
			ModPathProgress(ESSP_Perks, 1);
	}	
	
	public function AwardCombatXP( action : W3DamageAction, attackAction : W3Action_Attack, playerAttacker, playerVictim : CR4Player )
	{
		var attribute : SAbilityAttributeValue;
		var mult : float;
		
		if( playerAttacker && !playerVictim )
		{
			if( ((CActor)action.victim).IsHuman() )
				attribute = playerWitcher.GetAttributeValue('human_exp_bonus_when_fatal');
			else
				attribute = playerWitcher.GetAttributeValue('nonhuman_exp_bonus_when_fatal');
			
			mult = 1 + CalculateAttributeValue(attribute);
			if( attackAction && action.DealsAnyDamage() )
			{
				playerWitcher.IncBattleTranceHitCount();
			
				if( attackAction.IsActionMelee() )
				{
					if( playerWitcher.IsLightAttack(attackAction.GetAttackName()) )
					{
						if (playerWitcher.GetCombatAction() == EBAT_SpecialAttack_Light)
							mult *= 0.75f;
					
						ModPathProgress(ESSP_Sword_StyleFast, mult);
					}
					else
					{
						ModPathProgress(ESSP_Sword_StyleStrong, mult);
					}
				}
				else
				if( (W3BoltProjectile)attackAction.causer )
				{
					if ( (W3ExplosiveBolt)attackAction.causer )
						ModPathProgress(ESSP_Sword_Crossbow, mult * 0.35f);
					else if ( ((W3BoltProjectile)attackAction.causer).GetWasAimedBolt() )
						ModPathProgress(ESSP_Sword_Crossbow, mult);
					else						
						ModPathProgress(ESSP_Sword_Crossbow, mult * 0.6f);
				}
			}
			else if ( (W3Petard)action.causer )
			{
				if ( ((W3Petard)action.causer).IsCluster() )
					ModPathProgress(ESSP_Alchemy_Bombs, 0.05f);
				else
					ModPathProgress(ESSP_Alchemy_Bombs, 0.2f);
			}
		}
		else
		if( attackAction && playerVictim && !playerAttacker )
		{
			if( attackAction.IsParried() || attackAction.IsCountered() )
			{				
				if (attackAction.IsCountered())
				{
					playerWitcher.IncBattleTranceHitCount();
				
					if( ((CActor)attackAction.attacker).IsHuman() )
						attribute = playerWitcher.GetAttributeValue('human_exp_bonus_when_fatal');
					else
						attribute = playerWitcher.GetAttributeValue('nonhuman_exp_bonus_when_fatal');
						
					mult = 1 + CalculateAttributeValue(attribute);
				}
				else
					mult = 1;			
			
				ModPathProgress(ESSP_Sword_Utility, mult);
			}
		}
	}
	
	public function AwardDodgingXP( witcher : CR4Player )
	{
		if( witcher.IsInCombat() )
			ModPathProgress(ESSP_Sword_Utility, 0.8f);
	}
	
	public function AwardCombatAdrenalineXP( witcher : W3PlayerWitcher, kills : int, noHealthLost : bool )
	{
		if( kills <= 0 )
			return;
		
		if( noHealthLost )
			ModPathProgress(ESSP_Sword_BattleTrance, 1.5f);
		else
			ModPathProgress(ESSP_Sword_BattleTrance, 1);
	}
	
	public function AwardCombatBattleTrance(witcher : W3PlayerWitcher)
	{
		var mult : float;
		
		mult = 0.5f + 0.5f * witcher.GetBattleTranceHitCount() / 5;
		mult *= witcher.GetStatPercents(BCS_Focus);
		
		ModPathProgress(ESSP_Sword_BattleTrance, mult);
	}
	
	public function AwardFloodOfAnger()
	{
		ModPathProgress(ESSP_Sword_BattleTrance, 2.5f);
	}
	
	public function AwardNonCombatXP( attackName : name )
	{
		if( playerWitcher.IsInCombat() )
			return;
		
		if( playerWitcher.IsLightAttack(attackName) )
		{
			ModPathProgress(ESSP_Sword_StyleFast, 0.4f);
		}
		else
		if( playerWitcher.IsHeavyAttack(attackName) )
		{
			ModPathProgress(ESSP_Sword_StyleStrong, 0.4f);
		}
		else
		{
			ModPathProgress(ESSP_Sword_Crossbow, 0.3f);
		}
	}
	
	public function AwardSignXP( signType : ESignType, mult : float)
	{	
		switch(signType)
		{
			case ST_Aard:
				ModPathProgress(ESSP_Signs_Aard, mult);
			break;
			
			case ST_Yrden:
				ModPathProgress(ESSP_Signs_Yrden, mult);
			break;
			
			case ST_Igni:
				ModPathProgress(ESSP_Signs_Igni, mult);
			break;
			
			case ST_Quen:
				ModPathProgress(ESSP_Signs_Quen, mult);
			break;
			
			case ST_Axii:
				ModPathProgress(ESSP_Signs_Axi, mult);
			break;
		}
	}
	
	public function AwardAlchemyBrewingXP( quantity : int, isPotion, isOil, isBomb, isDistilling, isDecoction : bool )
	{
		if( isDistilling )
			ModPathProgress(ESSP_Alchemy_Mutagens, quantity);
		else
		if( isDecoction )
		{
			ModPathProgress(ESSP_Alchemy_Potions, quantity);
			ModPathProgress(ESSP_Alchemy_Mutagens, quantity * 3.5f);
		}
		else
		if( isPotion )
			ModPathProgress(ESSP_Alchemy_Potions, quantity);
		else
		if( isOil )
			ModPathProgress(ESSP_Alchemy_Oils, quantity);
		else
		if( isBomb )
			ModPathProgress(ESSP_Alchemy_Bombs, quantity);
	}
	
	public function AwardAlchemyUsageXP( witcher : W3PlayerWitcher, isDecoction : bool, toxicity : float )
	{
		var mult, pseudoToxPercent : float;
		
		if (isDecoction)
			mult = 1.0f + DECOCTION_BONUS;
		else
		{
			mult = 1.0f + MinF( (toxicity - 25.0f) / 30.0f , 1.0f ) * POTION_TOXICITY_BONUS_MAX;
		}
		
		// current tox / mean of initial max tox and max tox
		pseudoToxPercent = 2.0f * witcher.GetStat(BCS_Toxicity) / (witcher.GetStatMax(BCS_Toxicity) + 100.0f);
		
		mult += MinF(pseudoToxPercent / 0.8f, 1.0f) * WITCHER_TOXICITY_BONUS_MAX;
		
		if ( isDecoction )
			ModPathProgress(ESSP_Alchemy_Mutagens, 1.2f);
			
		ModPathProgress(ESSP_Alchemy_Grasses, mult);
	
		/*if( isDecoction )
		{
			ModPathProgress(ESSP_Alchemy_Grasses, 1.5f);
			ModPathProgress(ESSP_Alchemy_Mutagens, 1.3f);
		}
		else
			ModPathProgress(ESSP_Alchemy_Grasses, 1);*/
	}
	
	public function SpendSkillPoints( skill : ESkill, amount : int )
	{
		if( Options().NoSkillPointReq() )
			return;
		
		ModSpentPathPoints(playerWitcher.GetSkillSubPathType(skill), amount);
	}
	
	public function SpendSkillPointsMutation( skillPath : ESkillSubPath, amount : int )
	{
		if( Options().NoSkillPointReq() )
			return;
		
		ModSpentPathPoints(skillPath, amount);
	}
	
	public function ResetCharacterSkills()
	{
		FactsSetValue("FastAttackPointsSpent", 0);
		FactsSetValue("HeavyAttackPointsSpent", 0);
		FactsSetValue("DefensePointsSpent", 0);
		FactsSetValue("RangedPointsSpent", 0);
		FactsSetValue("TrancePointsSpent", 0);
		FactsSetValue("AardPointsSpent", 0);
		FactsSetValue("IgniPointsSpent", 0);
		FactsSetValue("YrdenPointsSpent", 0);
		FactsSetValue("QuenPointsSpent", 0);
		FactsSetValue("AxiiPointsSpent", 0);
		FactsSetValue("BrewingPointsSpent", 0);
		FactsSetValue("OilingPointsSpent", 0);
		FactsSetValue("BombPointsSpent", 0);
		FactsSetValue("MutationPointsSpent", 0);
		FactsSetValue("TrialPointsSpent", 0);
		FactsSetValue("GeneralPointsSpent", 0);
	}
	
	public function GetMutationPathPointTypes( mutationID : EPlayerMutationType ) : SMutationRequirements
	{
		var mutationRequirements : SMutationRequirements;
		switch(mutationID)
		{
			case EPMT_Mutation1:
				mutationRequirements.skillPaths.PushBack(ESSP_Signs_Aard);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Signs_Yrden);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Signs_Igni);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Signs_Quen);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Signs_Axi);
				mutationRequirements.requiredPoints.PushBack(1);
			break;
			
			case EPMT_Mutation2:
				mutationRequirements.skillPaths.PushBack(ESSP_Signs_Igni);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Signs_Yrden);
				mutationRequirements.requiredPoints.PushBack(1);
			break;
			
			case EPMT_Mutation3:
				mutationRequirements.skillPaths.PushBack(ESSP_Sword_StyleFast);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Sword_StyleStrong);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Sword_BattleTrance);
				mutationRequirements.requiredPoints.PushBack(1);
			break;
			
			case EPMT_Mutation4:
				mutationRequirements.skillPaths.PushBack(ESSP_Alchemy_Mutagens);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Alchemy_Grasses);
				mutationRequirements.requiredPoints.PushBack(1);
			break;
			
			case EPMT_Mutation5:
				mutationRequirements.skillPaths.PushBack(ESSP_Alchemy_Mutagens);
				mutationRequirements.requiredPoints.PushBack(2);
				mutationRequirements.skillPaths.PushBack(ESSP_Sword_Utility);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Sword_BattleTrance);
				mutationRequirements.requiredPoints.PushBack(2);
			break;
			
			case EPMT_Mutation6:
				mutationRequirements.skillPaths.PushBack(ESSP_Signs_Aard);
				mutationRequirements.requiredPoints.PushBack(3);
			break;
			
			case EPMT_Mutation7:
				mutationRequirements.skillPaths.PushBack(ESSP_Signs_Aard);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Signs_Yrden);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Sword_StyleFast);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Sword_StyleStrong);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Sword_BattleTrance);
				mutationRequirements.requiredPoints.PushBack(1);
			break;
			
			case EPMT_Mutation8:
				mutationRequirements.skillPaths.PushBack(ESSP_Sword_Utility);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Sword_BattleTrance);
				mutationRequirements.requiredPoints.PushBack(1);
			break;
			
			case EPMT_Mutation9:
				mutationRequirements.skillPaths.PushBack(ESSP_Sword_Crossbow);
				mutationRequirements.requiredPoints.PushBack(3);
				mutationRequirements.skillPaths.PushBack(ESSP_Alchemy_Mutagens);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Alchemy_Bombs);
				mutationRequirements.requiredPoints.PushBack(1);
			break;
			
			case EPMT_Mutation10:
				mutationRequirements.skillPaths.PushBack(ESSP_Alchemy_Mutagens);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Alchemy_Grasses);
				mutationRequirements.requiredPoints.PushBack(2);
			break;
			
			case EPMT_Mutation11:
				mutationRequirements.skillPaths.PushBack(ESSP_Signs_Quen);
				mutationRequirements.requiredPoints.PushBack(2);
				mutationRequirements.skillPaths.PushBack(ESSP_Sword_Utility);
				mutationRequirements.requiredPoints.PushBack(2);
				mutationRequirements.skillPaths.PushBack(ESSP_Alchemy_Grasses);
				mutationRequirements.requiredPoints.PushBack(3);
			break;
			
			case EPMT_Mutation12:
				mutationRequirements.skillPaths.PushBack(ESSP_Sword_StyleFast);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Sword_StyleStrong);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Alchemy_Mutagens);
				mutationRequirements.requiredPoints.PushBack(1);
				mutationRequirements.skillPaths.PushBack(ESSP_Alchemy_Potions);
				mutationRequirements.requiredPoints.PushBack(2);
				mutationRequirements.skillPaths.PushBack(ESSP_Alchemy_Grasses);
				mutationRequirements.requiredPoints.PushBack(2);
			break;
		}
		return mutationRequirements;
	}
	
	public function GetTotalMutationSkillpoints( requirement : SMutationRequirements ) : int
	{
		var i, totalPoints : int;
		for(i=0; i<requirement.skillPaths.Size(); i+=1)
		{
			if( Options().NoSkillPointReq() )
				totalPoints += requirement.requiredPoints[i];
			else
				totalPoints += Min(requirement.requiredPoints[i], GetCurrentPathPoints(requirement.skillPaths[i]));
		}
		
		return totalPoints;
	}
	
	public function GetRequiredPathsString( requirement : SMutationRequirements ) : string
	{
		var i : int;
		var ret : string;
		
		ret = "<font color=\"#aa9578\">";
		ret += "<br>" + GetLocStringByKeyExt("W3EE_Required")+ ": ";
		for(i=0; i<requirement.skillPaths.Size(); i+=1)
		{
			ret += requirement.requiredPoints[i] + " " + GetLocStringByKeyExt(SkillSubPathToLocalisationKey(requirement.skillPaths[i]));
			if( i < requirement.skillPaths.Size() - 1 )
				ret += ", ";
		}
		ret += "</font>";
		
		return ret;
	}
}

exec function AddPathPoints( skillPath : ESkillSubPath, amount : float )
{
	Experience().ModTotalPathPoints(skillPath, amount);
}

exec function AddPathPointsAll( amount : float )
{
	var i, size : int;
	for(i=1; i<EnumGetMax('ESkillSubPath') - 5; i+=1)
		Experience().ModTotalPathPoints((ESkillSubPath)i, amount);
}

exec function ResetTotalPoints()
{
	var i, count : int;
	
	Experience().FactsSetValue("TotalPoints", 0);
	for(i=1; i<EnumGetMax('ESkillSubPath') - 5; i+=1)
		count += Experience().GetTotalPathPoints((ESkillSubPath)i);
	
	count *= 10;
	Experience().FactsSetValue("TotalPoints", count);
}

exec function IncreasePathXP( skillPath : ESkillSubPath, mult : float )
{
	Experience().ModPathProgress(skillPath, mult);
}

exec function ResetPathProgress ( skillPath : ESkillSubPath)
{
	Experience().ResetPathProgress(skillPath);
}

exec function fucktest()
{
	var a : Vector;
	
	a = GetWitcherPlayer().GetWorldPosition();
	a = GetWitcherPlayer().GetWorldPosition();
}