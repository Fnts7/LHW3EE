class W3EEBloodEffectsHandler
{
	private var bloodEffects : array<CName>;
	
	public function Init()
	{
		bloodEffects.Resize(3);
		bloodEffects.PushBack('cutscene_blood_trail');
		bloodEffects.PushBack('cutscene_blood_trail_02');
		bloodEffects.PushBack('blood_trail_finisher');
	}
	
	public function ShouldShowBlood( act : W3DamageAction, actorVictim : CActor, victim : EMonsterCategory, playerAttacker : CR4Player, attackAction : W3Action_Attack, isCriticalHit : bool ) : bool
	{
		if( Options().IsBloodActive() && playerAttacker && actorVictim && !actorVictim.HasTag('AerondightIgnore') && actorVictim.CanBleed() && actorVictim.IsAttackableByPlayer() && act.CanPlayHitParticle() && !thePlayer.IsWeaponHeld('fist') && ( !Options().IsBloodOnlyCrit() || isCriticalHit ) ) 
		{
			if( !Options().IsBloodActiveRanged() && attackAction.IsActionRanged() )
				return false;
			else 
				return true;
		}
		else return false;
	}

	private function ImpactBloodSpray( victim : CNewNPC )
	{
		var weaponEntity : CEntity;
		var weaponSlotMatrix : Matrix;
		var bloodFxPos : Vector;
		var bloodFxRot : EulerAngles;
		var tempEntity : CEntity;
		
		weaponEntity = thePlayer.GetInventory().GetItemEntityUnsafe(thePlayer.GetInventory().GetItemFromSlot('r_weapon'));
		weaponEntity.CalcEntitySlotMatrix('blood_fx_point', weaponSlotMatrix);
		
		bloodFxPos = MatrixGetTranslation(weaponSlotMatrix);
		bloodFxRot = weaponEntity.GetWorldRotation();
		
		tempEntity = theGame.CreateEntity( (CEntityTemplate)LoadResource('finisher_blood'), bloodFxPos, bloodFxRot);
		tempEntity.PlayEffect(bloodEffects[RandRange(bloodEffects.Size())]);
	}
	
	public function ShowBlood( weaponID : SItemUniqueId, victim : CNewNPC, rangedAttack : bool )
	{
		if( Options().IsBloodTrailActive() )
		{
			if( victim.GetBloodType() == BT_Red )
			{
				thePlayer.inv.GetItemEntityUnsafe(weaponID).PlayEffect(bloodEffects[RandRange(bloodEffects.Size())]);
			}
			else
			if (victim.GetBloodType() == BT_Green )
			{
				thePlayer.inv.GetItemEntityUnsafe(weaponID).PlayEffect('aerondight_blood_green');
			}
			else
			if( victim.GetBloodType() == BT_Yellow )
			{
				thePlayer.inv.GetItemEntityUnsafe(weaponID).PlayEffect('aerondight_blood_yellow');
			}
			else
			if( victim.GetBloodType() == BT_Black )
			{
				thePlayer.inv.GetItemEntityUnsafe(weaponID).PlayEffect('aerondight_blood_black');
			}
		}
		
		if( victim.GetBloodType() == BT_Red )
		{
			if( !rangedAttack )
			{
				thePlayer.PlayEffect('covered_blood');
				thePlayer.AddTimer('RemoveBloodEffects', 45.f,,,,, true);
			}
			
			if( Options().IsBloodSprayActive() )
				ImpactBloodSpray(victim);
		}
	}
}

enum EInjuryType
{
	EFI_Head,
	EFI_Chest,
	EFI_Arms,
	EFI_Legs,
	EPI_Head,
	EPI_Spine,
	EPI_Arms,
	EPI_Legs,
	EIT_None
}

class W3EEInjurySystem
{
	private var EPIHorizontal				: array<EInjuryType>;
	private var EFIHorizontal 				: array<EInjuryType>;
	private var EFIVerticalUp				: array<EInjuryType>;
	private var EPIVerticalUp 				: array<EInjuryType>;
	private var EFIVerticalDown				: array<EInjuryType>;
	private var EPIVerticalDown 			: array<EInjuryType>;
	private var appliedInjuries 			: array<EInjuryType>;
	private var initInjuries 				: bool;
	private var cachedActor					: CActor;
	private var playerAttacker 				: W3PlayerWitcher;
	private var healthType					: EBaseCharacterStats;
	
	public function Init( actor : CActor )
	{
		cachedActor = actor;
		if( cachedActor.UsesVitality() )
			healthType = BCS_Vitality;
		else
			healthType = BCS_Essence;
		
		// Dorsal Upper Body Injuries
		EPIVerticalDown.PushBack(EPI_Head);
		
		// Dorsal Lower Body Injuries
		EPIVerticalUp.PushBack(EPI_Legs);
		
		// Dorsal Middle Body Injuries
		EPIHorizontal.PushBack(EPI_Spine);
		EPIHorizontal.PushBack(EPI_Arms);
		
		// Frontal Upper Body Injuries
		EFIVerticalDown.PushBack(EFI_Head);
		
		// Frontal Lower Body Injuries
		EFIVerticalUp.PushBack(EFI_Legs);
		
		// Frontal Middle Body Injuries
		EFIHorizontal.PushBack(EFI_Chest);
		EFIHorizontal.PushBack(EFI_Arms);
	}
	
	public function AttackStumbles()
	{
		if( HasInjury(EFI_Arms) || HasInjury(EPI_Arms) )
			cachedActor.AddTimer('RollAttackStumble', RandRangeF(0.2f, 0.1f), false);
		
		if( HasInjury(EFI_Legs) || HasInjury(EPI_Legs) )
			cachedActor.AddTimer('RollRunningAttackStumble', RandRangeF(0.3f, 0.1f), false);
	}
	
	public function ApplyCombatInjury( attackAction : W3Action_Attack, chanceMult : float )
	{
		var injuryChanceMult : SAbilityAttributeValue;
		var appliedInjury : EInjuryType;
		var injuryChance : float;
		var injuryResist : float;
		
		if( (CPlayer)cachedActor && Options().InjuryPlayerImmunity() )
			return;
		
		if( !attackAction.DealsAnyDamage() || attackAction.IsCountered() || attackAction.IsParried() || attackAction.IsActionWitcherSign() || attackAction.IsActionEnvironment() || attackAction.IsParried() )
			return;
			
		playerAttacker = (W3PlayerWitcher)attackAction.attacker;
		if (playerAttacker)
			injuryChance = 0.06f;
		else
			injuryChance = Options().InjuryChance() / 100.0f;
			
		if( injuryChance > 0.f )
		{
			if( attackAction.GetForceInjury() )
				injuryChance = 1.0f;
			else
			{
				
				if( attackAction.IsCriticalHit() )
					injuryChance *= 2.0f;
				
				if( playerAttacker )
				{
					if( playerAttacker.IsLightAttack(attackAction.GetAttackName()) )
					{
						injuryChance *= 1.0f + 0.2f * playerAttacker.GetSkillLevel(S_Sword_s17);
						
						if (playerAttacker.GetCombatAction() == EBAT_SpecialAttack_Light)
							injuryChance /= 3.0f;
					}
					injuryChanceMult = playerAttacker.GetAttributeValue('injury_chance');
					injuryChance *= 1.f + injuryChanceMult.valueMultiplicative;
					
					if( ((W3Effect_SwordBehead)playerAttacker.GetBuff(EET_SwordBehead)).GetBeheadEffectActive() )
						injuryChance *= 2.f;
				}
				
				if( (W3PlayerWitcher)cachedActor )
				{
					injuryChanceMult = ((W3PlayerWitcher)cachedActor).GetAttributeValue('injury_resist');
					injuryChance -= injuryChance * (0.1f * GetWitcherPlayer().GetSkillLevel(S_Sword_s10));
					chanceMult = ClampF(chanceMult, 0.f, 1.f);
					injuryChance *= chanceMult * (1.f - injuryChanceMult.valueMultiplicative);
					
					injuryChance /= appliedInjuries.Size() + 1;
				}
				else
					injuryChance /= (appliedInjuries.Size() * 0.5f) + 1.0f;
			}
			
			if ( (CNewNPC)cachedActor ) 
			{
				injuryResist = ((CNewNPC)cachedActor).GetNPCCustomStat(theGame.params.DAMAGE_NAME_INJURY);
				injuryChance *= 1 - injuryResist;
			}
			
			if( RandF() < injuryChance )
			{
				appliedInjury = GetInjuryType(attackAction);
				if( appliedInjury != EIT_None )
				{
					ApplyInjuryType(appliedInjury, attackAction);
					SendInjuryMessage(appliedInjury, attackAction);
				}
			}
		}
	}
	
	public function HasInjury( injuryType : EInjuryType ) : bool
	{
		return appliedInjuries.Contains(injuryType);
	}
	
	public function HealRandomInjury()
	{
		var injuryHealed : int = RandRange(appliedInjuries.Size() - 1);
		
		if( !HasSimilarInjury(appliedInjuries[injuryHealed]) )
			cachedActor.RemoveAllBuffsOfType(InjuryTypeToEffect(appliedInjuries[injuryHealed]));
		appliedInjuries.Erase(injuryHealed);
	}
	
	public function ClearInjuries()
	{
		appliedInjuries.Clear();
		cachedActor.RemoveAllBuffsOfType(EET_InjuredArm);
		cachedActor.RemoveAllBuffsOfType(EET_InjuredLeg);
		cachedActor.RemoveAllBuffsOfType(EET_InjuredTorso);
		cachedActor.RemoveAllBuffsOfType(EET_InjuredHead);
	}
	
	private function InjuryTypeToEffect( injuryType : EInjuryType ) : EEffectType
	{
		switch(injuryType)
		{
			case EFI_Head:
			case EPI_Head:
				return EET_InjuredHead;
				
			case EFI_Chest:
			case EPI_Spine:
				return EET_InjuredTorso;
				
			case EFI_Arms:
			case EPI_Arms:
				return EET_InjuredArm;
				
			case EFI_Legs:
			case EPI_Legs:
				return EET_InjuredArm;
				
			default : return EET_Undefined;
		}
	}
	
	private function HasSimilarInjury( injuryType : EInjuryType ) : bool
	{
		switch(injuryType)
		{
			case EFI_Head:	return HasInjury(EPI_Head);
			case EPI_Head:	return HasInjury(EFI_Head);
			
			case EFI_Chest:	return HasInjury(EPI_Spine);
			case EPI_Spine:	return HasInjury(EFI_Chest);
			
			case EFI_Arms:	return HasInjury(EPI_Arms);
			case EPI_Arms:	return HasInjury(EFI_Arms);
			
			case EFI_Legs:	return HasInjury(EPI_Legs);
			case EPI_Legs:	return HasInjury(EFI_Legs);
			
			default : return false;
		}
	}
	
	private function GetSwingType( attackAction : W3Action_Attack ) : name
	{
		var swingDirection, swingType : int;
		
		swingType = (int)attackAction.GetSwingType();
		swingDirection = (int)attackAction.GetSwingDirection();
		
		if( swingType == 2 || ((swingType == 1 || swingType == 4) && swingDirection == 1) )
			return 'Up';
		else
		if( swingType == 3 || ((swingType == 1 || swingType == 4) && swingDirection == 0) )
			return 'Down';
		else
			return 'Horizontal';
	}
	
	private function TryForInjuryType( injuryArray : array<EInjuryType> ) : EInjuryType
	{
		var tempInjuryArray : array<EInjuryType>;
		var injuryType : EInjuryType;
		var size, i, idx : int;
		
		size = injuryArray.Size();
		tempInjuryArray = injuryArray;
		idx = RandRange(size, 0);
		injuryType = tempInjuryArray[idx];
		for(i=0; i<size; i+=1)
		{
			if( InflictInjury(injuryType) )
				return injuryType;
			
			tempInjuryArray.Erase(idx);
			idx = RandRange(tempInjuryArray.Size(), 0);
			injuryType = tempInjuryArray[idx];
		} 
		
		return EIT_None;
	}
	
	private function GetInjuryType( attackAction : W3Action_Attack ) : EInjuryType
	{
		var appliedInjury : EInjuryType;
		var attackAngle : float;
		var swingType : name;
		
		attackAngle = AngleDistance(VecHeading(attackAction.attacker.GetWorldPosition() - cachedActor.GetWorldPosition()), cachedActor.GetHeading());
		swingType = GetSwingType(attackAction);
		if( AbsF(attackAngle) >= 130 )
		{
			if( swingType == 'Up' )
			{
				appliedInjury = TryForInjuryType(EPIVerticalUp);
				if( appliedInjury == EIT_None )
					appliedInjury = TryForInjuryType(EPIHorizontal);
				
				return appliedInjury;
			}
			
			if( swingType == 'Down' )
			{
				appliedInjury = TryForInjuryType(EPIVerticalDown);
				if( appliedInjury == EIT_None )
					appliedInjury = TryForInjuryType(EPIHorizontal);
				
				return appliedInjury;
			}
			
			if( swingType == 'Horizontal' )
			{
				appliedInjury = TryForInjuryType(EPIHorizontal);
				return appliedInjury;
			}
		}
		else
		{
			if( swingType == 'Up' )
			{
				appliedInjury = TryForInjuryType(EFIVerticalUp);
				if( appliedInjury == EIT_None )
					appliedInjury = TryForInjuryType(EFIHorizontal);
				
				return appliedInjury;
			}
			
			if( swingType == 'Down' )
			{
				appliedInjury = TryForInjuryType(EFIVerticalDown);
				if( appliedInjury == EIT_None )
					appliedInjury = TryForInjuryType(EFIHorizontal);
				
				return appliedInjury;
			}
			
			if( swingType == 'Horizontal' )
			{
				appliedInjury = TryForInjuryType(EFIHorizontal);
				return appliedInjury;
			}
		}
		
		return EIT_None;
	}
	
	public function InflictInjury( injuryType : EInjuryType ) : bool
	{
		if( HasInjury(injuryType) )
			return false;
		else
			appliedInjuries.PushBack(injuryType);
		
		return true;
	}
	
	private function GetAlternateNotificationText() : string
	{
		var enemyCategory : EMonsterCategory;
		var npcVictim : CNewNPC;
		
		npcVictim = (CNewNPC)cachedActor;
		enemyCategory = npcVictim.npcStats.opponentType;
		
		if( npcVictim.GetSfxTag() == 'sfx_ghoul' ) return GetLocStringByKeyExt("W3EE_Legs");
		switch(enemyCategory)
		{
			case MC_Beast:
			case MC_Insectoid:
			case MC_Relic:
			case MC_Animal:
				return GetLocStringByKeyExt("W3EE_Legs");
			
			case MC_Draconide:
			case MC_Hybrid:
				return GetLocStringByKeyExt("W3EE_Wings");
			
			default:	return GetLocStringByKeyExt("W3EE_Arms");
		}
	}
	
	private function SendInjuryMessage( injuryType : EInjuryType, attackAction : W3Action_Attack )
	{
		var injuryMessage, injuryMessageEnd : string;
		
		if( !((CPlayer)attackAction.attacker) && !((CPlayer)attackAction.victim) )
			return;
		
		switch(injuryType)
		{
			case EPI_Head:			injuryMessage = GetLocStringByKeyExt("W3EE_BackInjury");	injuryMessageEnd = GetLocStringByKeyExt("W3EE_Head");		break;
			case EPI_Spine:			injuryMessage = GetLocStringByKeyExt("W3EE_BackInjury");	injuryMessageEnd = GetLocStringByKeyExt("W3EE_Spine");		break;
			case EPI_Arms:			injuryMessage = GetLocStringByKeyExt("W3EE_BackInjury");	injuryMessageEnd = GetLocStringByKeyExt("W3EE_Arms");		break;
			case EPI_Legs:			injuryMessage = GetLocStringByKeyExt("W3EE_BackInjury");	injuryMessageEnd = GetLocStringByKeyExt("W3EE_Legs");		break;
			case EFI_Head:			injuryMessage = GetLocStringByKeyExt("W3EE_FrontInjury");		injuryMessageEnd = GetLocStringByKeyExt("W3EE_Head");		break;
			case EFI_Chest:			injuryMessage = GetLocStringByKeyExt("W3EE_FrontInjury");		injuryMessageEnd = GetLocStringByKeyExt("W3EE_Chest");		break;
			case EFI_Arms:			injuryMessage = GetLocStringByKeyExt("W3EE_FrontInjury");		injuryMessageEnd = GetLocStringByKeyExt("W3EE_Arms");		break;
			case EFI_Legs:			injuryMessage = GetLocStringByKeyExt("W3EE_FrontInjury");		injuryMessageEnd = GetLocStringByKeyExt("W3EE_Legs");		break;
		}
		
		if( (CPlayer)attackAction.victim )
			injuryMessage += GetLocStringByKeyExt("W3EE_InjurySustained");
		else
			injuryMessage += GetLocStringByKeyExt("W3EE_InjuryInflicted");
		
		if( injuryMessageEnd == GetLocStringByKeyExt("W3EE_Arms") )
			injuryMessageEnd = GetAlternateNotificationText();
		
		injuryMessage += injuryMessageEnd;
		
		if( Options().InjuryMessages() )
			theGame.GetGuiManager().ShowNotification(injuryMessage, 1500.f, true);
		HudShowInjuryType(injuryMessageEnd + " " + GetLocStringByKeyExt("W3EE_Injury"));
	}
	
	private function HudShowInjuryType( injuryName : string )
	{
		var hud : CR4ScriptedHud;
		var module : CR4HudModuleEnemyFocus;
		
		if( playerAttacker.GetTarget() == cachedActor )
		{
			hud = (CR4ScriptedHud)theGame.GetHud();
			if( hud )
			{
				module = (CR4HudModuleEnemyFocus)hud.GetHudModule("EnemyFocusModule");
				if( module )
					module.ShowDamageType(EFVT_Buff, 0, , injuryName);
			}
		}
	}
	
	private function ApplyInjuryType( injuryType : EInjuryType, attackAction : W3Action_Attack )
	{
		var damageAction : W3DamageAction;
		var effectParams : SCustomEffectParams;
		var playerWitcher : W3PlayerWitcher;
		
		playerWitcher = (W3PlayerWitcher)cachedActor;
		if( ((W3PlayerWitcher)attackAction.attacker) && ((W3PlayerWitcher)attackAction.attacker).HasBuff(EET_Mutagen24) && RandRange(100, 0) <= 50 )
			((W3PlayerWitcher)attackAction.attacker).GetInjuryManager().HealRandomInjury();
		
		attackAction.SetHitReactionType(EHRT_Heavy);
		switch(injuryType)
		{
			case EFI_Head:
				if( playerWitcher && !playerWitcher.HasBuff(EET_InjuredHead) )
					playerWitcher.AddEffectDefault(EET_InjuredHead, playerWitcher, "injury", false);
				
				cachedActor.PlayEffect('heavy_hit');
				if( (CPlayer)cachedActor )
				{
					cachedActor.PlayEffect('stunned_ghost');
					cachedActor.AddTimer('StopHeadHitEffect', 5.f, false);
				}
				effectParams.effectType = EET_Blindness;
				effectParams.creator = attackAction.attacker;
				effectParams.sourceName = 'CombatInjury';
				effectParams.duration = 5.f;
				cachedActor.AddEffectCustom(effectParams);
				cachedActor.DrainStamina(ESAT_FixedValue, cachedActor.GetStat(BCS_Stamina) * 0.15f, 6.f);
				attackAction.AddEffectInfo(EET_Stagger);
			break;
			
			case EFI_Chest:
				if( playerWitcher && !playerWitcher.HasBuff(EET_InjuredTorso) )
					playerWitcher.AddEffectDefault(EET_InjuredTorso, playerWitcher, "injury", false);
					
				cachedActor.PlayEffect('death_hit');
				effectParams.effectType = EET_Bleeding;
				effectParams.creator = attackAction.attacker;
				effectParams.sourceName = 'CombatInjury';
				effectParams.duration = 5.f;
				if( ((CActor)attackAction.victim).UsesVitality() )
					effectParams.effectValue.valueAdditive = MinF(attackAction.processedDmg.vitalityDamage * 0.15f, 350);
				else
					effectParams.effectValue.valueAdditive = MinF(attackAction.processedDmg.essenceDamage * 0.15f, 350);
				cachedActor.AddEffectCustom(effectParams);
				attackAction.AddEffectInfo(EET_Stagger);
			break;
			
			case EFI_Arms:
				if( playerWitcher && !playerWitcher.HasBuff(EET_InjuredArm) )
					playerWitcher.AddEffectDefault(EET_InjuredArm, playerWitcher, "injury", false);
					
				cachedActor.PlayEffect('heavy_hit');
				attackAction.AddEffectInfo(EET_Stagger);
			break;
			
			case EFI_Legs:
				if( playerWitcher && !playerWitcher.HasBuff(EET_InjuredLeg) )
					playerWitcher.AddEffectDefault(EET_InjuredLeg, playerWitcher, "injury", false);
					
				cachedActor.PlayEffect('heavy_hit');
				attackAction.AddEffectInfo(EET_Stagger);
			break;
			
			case EPI_Head:
				if( playerWitcher && !playerWitcher.HasBuff(EET_InjuredHead) )
					playerWitcher.AddEffectDefault(EET_InjuredHead, playerWitcher, "injury", false);
					
				cachedActor.PlayEffect('heavy_hit_back');
				if( (CPlayer)cachedActor )
				{
					cachedActor.PlayEffect('stunned_ghost');
					cachedActor.AddTimer('StopHeadHitEffect', 7.5f, false);
				}
				damageAction = new W3DamageAction in theGame.damageMgr;
				damageAction.Initialize( attackAction.attacker, attackAction.victim, attackAction.causer, "CombatInjury", EHRT_None, CPS_Undefined, attackAction.IsActionMelee(), attackAction.IsActionRanged(), attackAction.IsActionWitcherSign(), attackAction.IsActionEnvironment() );
				damageAction.SetHitAnimationPlayType(EAHA_ForceNo);
				damageAction.SetCannotReturnDamage(true);
				damageAction.SetCanPlayHitParticle(false);
				if( ((CActor)damageAction.victim).UsesVitality() )
					damageAction.AddDamage(theGame.params.DAMAGE_NAME_DIRECT, attackAction.processedDmg.vitalityDamage);
				else
					damageAction.AddDamage(theGame.params.DAMAGE_NAME_DIRECT, attackAction.processedDmg.essenceDamage);
				theGame.damageMgr.ProcessAction(damageAction);
				delete damageAction;
				attackAction.AddEffectInfo(EET_LongStagger);
			break;
			
			case EPI_Spine:
				if( playerWitcher && !playerWitcher.HasBuff(EET_InjuredTorso) )
					playerWitcher.AddEffectDefault(EET_InjuredTorso, playerWitcher, "injury", false);
					
				cachedActor.PlayEffect('heavy_hit_back');
				attackAction.AddEffectInfo(EET_LongStagger);
			break;
			
			case EPI_Arms:
				if( playerWitcher && !playerWitcher.HasBuff(EET_InjuredArm) )
					playerWitcher.AddEffectDefault(EET_InjuredArm, playerWitcher, "injury", false);
					
				cachedActor.PlayEffect('heavy_hit_back');
				attackAction.AddEffectInfo(EET_LongStagger);
			break;
			
			case EPI_Legs:
				if( playerWitcher && !playerWitcher.HasBuff(EET_InjuredLeg) )
					playerWitcher.AddEffectDefault(EET_InjuredLeg, playerWitcher, "injury", false);
					
				cachedActor.PlayEffect('heavy_hit_back');
				attackAction.AddEffectInfo(EET_LongStagger);
			break;
		}
	}
}

exec function AddInjury( player : bool, type : EInjuryType )
{
	if( player )
		GetWitcherPlayer().GetInjuryManager().InflictInjury(type);
	else
		GetWitcherPlayer().GetTarget().GetInjuryManager().InflictInjury(type);
}

exec function RemoveInjuries( player : bool )
{
	if( player )
		GetWitcherPlayer().GetInjuryManager().ClearInjuries();
	else
		GetWitcherPlayer().GetTarget().GetInjuryManager().ClearInjuries();
}