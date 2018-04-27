/****************************************************************************/
/** Copyright © CD Projekt RED 2015
/** Author : Reaperrz
/****************************************************************************/
enum EArmorInfusionType
{
	EAIT_Shock,
	EAIT_Fire,
	EAIT_Ice,
	EAIT_None
}

class W3EECombatHandler extends W3EEOptionHandler
{	
	protected var whirlPoise : float;
	private var countered : bool;
	private var Perk21Active : bool;
	private var Perk21TimerActive : bool;
	
	default Perk21Active = true;
	default Perk21TimerActive = false;
	
	public final function DamagePercentageTaken() : float
	{
		return (EnemyDodgeDamageNegation() / 100);
	}

	public final function CanUseWhirl( key : SInputAction ) : bool
	{
		return ( IsPressed(key) );
	}	

	public final function CanUseRend( key : SInputAction ) : bool
	{
		return ( IsPressed(key) );
	}
	
	public final function CheckAutoFinisher() : bool
	{
		if ( RSAutomaticFinisher() )
			return true;
		else
			return false;
	}
		
	public final function BlizzardDoubleDur() : bool
	{
		return thePlayer.GetStat(BCS_Focus) >= thePlayer.GetStatMax(BCS_Focus) && GetWitcherPlayer().GetPotionBuffLevel( EET_Blizzard ) == 3 && !FactsQuerySum("BlizzardCounter");
	}
	
	public final function BlizzardCounter() : bool
	{
		return thePlayer.HasBuff( EET_Blizzard ) && GetWitcherPlayer().GetPotionBuffLevel( EET_Blizzard ) == 3 && thePlayer.GetStat(BCS_Focus) >= thePlayer.GetStatMax(BCS_Focus);
	}
	
	public final function DismemberAdrenalineGain()
	{
		var staminaGain : SAbilityAttributeValue;
		
		staminaGain = thePlayer.GetAttributeValue('dismember_stamina_gain');
		thePlayer.GainStat(BCS_Stamina, DADRGain() + staminaGain.valueAdditive);
	}
	
	public final function SetMaximumAdrenaline()
	{
		if( thePlayer.HasBuff(EET_MariborForest) )
			thePlayer.abilityManager.SetStatPointMax( BCS_Focus, MaxFocus() + 1 );
		else
			thePlayer.abilityManager.SetStatPointMax( BCS_Focus, MaxFocus() );
	}
	
	public final function SetPerk21State( i : bool )
	{
		Perk21Active = i;
	}

	public final function SetPerk21TimerState( i : bool )
	{
		Perk21TimerActive = i;
	}
	
	public final function CalcStaminaCost( action : EStaminaActionType, optional mult : float, optional dt : float, optional abilityName : name ) : float
	{
		var armorPieces : array<SArmorCount>;
		var witcher : W3PlayerWitcher;
		
		if( thePlayer.IsCiri() )
			return 0;
		
		witcher = GetWitcherPlayer();
		armorPieces = witcher.GetArmorCount();
		if( witcher.IsHelmetEquipped(EIST_Gothic) || witcher.IsHelmetEquipped(EIST_Meteorite) || witcher.IsHelmetEquipped(EIST_Dimeritium) )
		{
			if( witcher.HasAbility('Glyphword 9 _Stats', true) )
				armorPieces[2].all += 1;
			else
				armorPieces[3].all += 1;
		}
		
		if( thePlayer.GetInjuryManager().HasInjury(EFI_Arms) || thePlayer.GetInjuryManager().HasInjury(EPI_Arms) )
			mult += 0.1f;
		if( thePlayer.GetInjuryManager().HasInjury(EFI_Legs) || thePlayer.GetInjuryManager().HasInjury(EPI_Legs) )
			mult += 0.2f;
		if( armorPieces[2].all > 3 )
			mult -= 0.1f;
		
		switch(action)
		{
			case ESAT_Roll:
				return StamCostEvade() * (1.f + (armorPieces[3].all * 0.05f + armorPieces[2].all * 0.02f - armorPieces[0].all * 0.05f)) * mult * dt;
			case ESAT_Jump:
				return StamCostEvade() * (1.f + (armorPieces[3].all * 0.05f + armorPieces[2].all * 0.02f - armorPieces[0].all * 0.05f)) * mult * dt;
			case ESAT_Dodge:
				return StamCostEvade() * (1.f + (armorPieces[3].all * 0.05f + armorPieces[2].all * 0.02f - armorPieces[0].all * 0.05f)) * mult * dt;
			case ESAT_LightAttack:
				return StamCostFast() * (1.f + (armorPieces[3].upper * 0.05f + armorPieces[2].upper * 0.02f - armorPieces[0].upper * 0.05f)) * mult * dt;
			case ESAT_HeavyAttack:
				return StamCostHeavy() * (1.f + (armorPieces[3].upper * 0.05f + armorPieces[2].upper * 0.02f - armorPieces[0].upper * 0.05f)) * mult * dt;
			case ESAT_Parry:
				return StamCostBlock() * (1.f + (armorPieces[3].upper * 0.05f + armorPieces[2].upper * 0.02f - armorPieces[0].upper * 0.05f)) * mult * dt;
			case ESAT_Counterattack:
				return StamCostCounter() * (1.f + (armorPieces[3].upper * 0.05f + armorPieces[2].upper * 0.02f - armorPieces[0].upper * 0.05f)) * mult * dt;
			case ESAT_SpecialAttackLight:
				return StamCostFast() * (1.f + (armorPieces[3].upper * 0.05f + armorPieces[2].upper * 0.02f - armorPieces[0].upper * 0.05f)) * mult * dt;
			case ESAT_SpecialAttackHeavy:
				return StamCostHeavy() * (1.f + (armorPieces[3].upper * 0.05f + armorPieces[2].upper * 0.02f - armorPieces[0].upper * 0.05f)) * mult * dt;
			default : return mult * thePlayer.GetStaminaActionCost(action, abilityName, dt);
		}
		
		return 0;
	}	
	
	public final function CalcArmorPenalty( witcher : W3PlayerWitcher, isAttack : bool ) : float
	{
		var armorPieces : array<SArmorCount> = witcher.GetArmorCountOrig();
		
		if( witcher.IsHelmetEquipped(EIST_Gothic) || witcher.IsHelmetEquipped(EIST_Meteorite) || witcher.IsHelmetEquipped(EIST_Dimeritium) )
		{
			if( witcher.HasAbility('Glyphword 9 _Stats', true) )
				armorPieces[2].all += 1;
			else
				armorPieces[3].all += 1;
		}
		
		if( isAttack )
			return ( armorPieces[0].upper * 0.02f + armorPieces[1].upper * 0.01f - armorPieces[3].upper * 0.02f );
		else
			return ( armorPieces[0].all * 0.02f + armorPieces[1].all * 0.01f - armorPieces[3].all * 0.02f );
	}	
	
	public function GetActionStaminaCost( actionType : EStaminaActionType, out regenDelay : float, optional mult : float, optional dt : float, optional abilityName : name ) : float
	{
		var witcher : W3PlayerWitcher = GetWitcherPlayer();
		var costMult, delayReduction : SAbilityAttributeValue;
		
		if( witcher.CanUseSkill(S_Perk_21) && Perk21Active )
		{
			regenDelay = 0.f;
			return 0.f;
		}
		else
		{
			delayReduction = witcher.GetAttributeValue('delayReduction');
			if( dt == 0.f )
				dt = 1.f;
			if( mult == 0.f )
				mult = 1.f;
			switch(actionType)
			{
				case ESAT_LightAttack:
					costMult = witcher.GetAttributeValue('attack_stamina_cost');
					if( witcher.WasPlayerSpamming() )
					{
						delayReduction.valueMultiplicative -= 0.3f;
						mult += 0.3f;
					}
					mult += costMult.valueMultiplicative;
					
					regenDelay = StamRegenDelay() * (1.f - delayReduction.valueMultiplicative);
				return CalcStaminaCost(actionType, mult, dt, abilityName);
				
				case ESAT_HeavyAttack:
					costMult = witcher.GetAttributeValue('attack_stamina_cost');
					if( witcher.WasPlayerSpamming() )
					{
						delayReduction.valueMultiplicative -= 0.3f;
						mult += 0.3f;
					}
					mult += costMult.valueMultiplicative;
					
					regenDelay = StamRegenDelayHeavy() * (1.f - delayReduction.valueMultiplicative);
				return CalcStaminaCost(actionType, mult, dt, abilityName);
				
				case ESAT_Dodge:
					if( ((W3Effect_SwordDancing)witcher.GetBuff(EET_SwordDancing)).GetSwordDanceActive() )
						mult = 0.f;
						
					regenDelay = StamRegenDelayDodge() * (1.f - delayReduction.valueMultiplicative);
				return CalcStaminaCost(actionType, mult, dt, abilityName);
				
				case ESAT_Parry:
					costMult = witcher.GetAttributeValue('parry_stamina_cost');
					mult += costMult.valueMultiplicative - 1.f;
					
					regenDelay = StamRegenDelayBlock() * (1.f - delayReduction.valueMultiplicative);
				return CalcStaminaCost(actionType, mult, dt, abilityName);
				
				case ESAT_Counterattack:
					costMult = witcher.GetAttributeValue('parry_stamina_cost');
					mult += costMult.valueMultiplicative - 1.f;
					if( witcher.WasPlayerSpamming() )
					{
						delayReduction.valueMultiplicative -= 0.3f;
						mult += 0.3f;
					}
					
					regenDelay = StamRegenDelayCounter() * (1.f - delayReduction.valueMultiplicative);
				return CalcStaminaCost(actionType, mult, dt, abilityName);
				
				case ESAT_Roll:
					regenDelay = StamRegenDelayDodge() * (1.3f - delayReduction.valueMultiplicative);
				return CalcStaminaCost(actionType, mult, dt, abilityName);
				
				case ESAT_Jump:
					regenDelay = StamRegenDelayDodge() * (1.2f - delayReduction.valueMultiplicative);
				return CalcStaminaCost(actionType, mult, dt, abilityName);
				
				default:
				return CalcStaminaCost(actionType, mult, dt, abilityName);
			}
		}
	}
	
	public final function StaminaLoss( actionType : EStaminaActionType, optional mult : float )
	{
		var witcher : W3PlayerWitcher = GetWitcherPlayer();
		var staminaCost, regenDelay : float;
		
		if( witcher.CanUseSkill(S_Perk_21) && Perk21Active )
		{
			SetPerk21State(false);
			if( !Perk21TimerActive )
			{
				SetPerk21TimerState(true);
				witcher.AddTimer('ReactivatePerk21', 10, false);
			}
		}
		else
		{
			staminaCost = GetActionStaminaCost(actionType, regenDelay, mult);
			witcher.DrainStamina(ESAT_FixedValue, staminaCost, regenDelay);
		}
	}
	
	public final function EnemyDodge( out damageData : W3DamageAction, actor : CActor )
	{
		if( actor != thePlayer && actor.IsCurrentlyDodging() && damageData.CanBeDodged() && ( VecDistanceSquared(actor.GetWorldPosition(),damageData.attacker.GetWorldPosition()) > 1.7 || actor.HasAbility( 'IgnoreDodgeMinimumDistance' ) ) && EnemyDodgeNegateDamage() )
		{
			damageData.SetHitAnimationPlayType(EAHA_ForceNo);
			damageData.ClearEffects();
			
			// damageData.SetWasDodged();
			damageData.processedDmg.essenceDamage *= DamagePercentageTaken();
			damageData.processedDmg.vitalityDamage *= DamagePercentageTaken();
			
			return;
		}
		else
		if( actor != thePlayer && actor.IsCurrentlyDodging() && damageData.CanBeDodged() && ( VecDistanceSquared(actor.GetWorldPosition(),damageData.attacker.GetWorldPosition()) > 1.7 || actor.HasAbility( 'IgnoreDodgeMinimumDistance' ) ) )
		{
			damageData.SetHitAnimationPlayType(EAHA_ForceNo);
			damageData.ClearEffects();
			// damageData.SetWasDodged();
		}
	}

	public final function PlayCommonHitEffect( action : W3DamageAction, actorVictim : CActor, hitAnim : bool )
	{
		if( ((CNewNPC)action.victim).GetNPCType() == ENGT_Commoner && !((CBaseGameplayEffect)action.causer) ) 
		{
			actorVictim.PlayEffect(theGame.params.LIGHT_HIT_FX);
			actorVictim.SoundEvent("cmb_play_hit_light");
			actorVictim.ProcessHitSound(action, hitAnim || !actorVictim.IsAlive());
		}
	}
	
	public final function AllowAutoFinisher( actorVictim : CActor, playerAttacker : CR4Player )
	{
		if( CheckAutoFinisher() )
		{
			if 	( theGame.GetInGameConfigWrapper().GetVarValue('Gameplay', 'AutomaticFinishersEnabled' ) == "true" || ( (W3PlayerWitcher)playerAttacker && GetWitcherPlayer().IsMutationActive( EPMT_Mutation3 ) ) ||	actorVictim.WillBeUnconscious() )
				actorVictim.AddAbility( 'ForceFinisher', false );
				
			if ( actorVictim.HasTag( 'ForceFinisher' ) )
				actorVictim.AddAbility( 'ForceFinisher', false );
		}
		actorVictim.SignalGameplayEvent( 'ForceFinisher' );
	}
	
	public final function AllowAutoFinisher2( out autofinish : bool )
	{
		if ( RSAutomaticFinisher() )
		{
			autofinish = theGame.GetInGameConfigWrapper().GetVarValue('Gameplay', 'AutomaticFinishersEnabled');
		}
		else autofinish = false;
	}
	
	public final function AdrenalineDrainHits( actorAttacker : CActor, actorVictim : CActor, attackAction : W3Action_Attack, action : W3DamageAction, modifier : float )
	{
		var focusDrain : float;
		
		if( actorVictim.HasBuff(EET_BasicQuen) || (thePlayer.IsGuarded() && (GetWitcherPlayer().IsSetBonusActive(EISB_Gothic1) || GetWitcherPlayer().IsSetBonusActive(EISB_Bear_1))) )
			return;
		
		if( (CPlayer)actorVictim && action.DealsAnyDamage() && !attackAction.IsCountered() && !action.IsDoTDamage() )
		{
			modifier = ClampF(modifier, 0.f, 1.f);
			if(actorAttacker && attackAction)
			{
				if( actorAttacker.IsHeavyAttack( attackAction.GetAttackName() ) ) 
					focusDrain = ( CalculateAttributeValue(thePlayer.GetAttributeValue('heavy_attack_focus_drain')) * FocusLossHeavyHits() );
				else  
					if( actorAttacker.IsSuperHeavyAttack( attackAction.GetAttackName() ) )
						focusDrain = ( CalculateAttributeValue(thePlayer.GetAttributeValue('super_heavy_attack_focus_drain')) * FocusLossSuperHeavyHits() );
				else
					focusDrain = ( CalculateAttributeValue(thePlayer.GetAttributeValue('light_attack_focus_drain')) * FocusLossLightHits() ); 
			}
			else
			{
				focusDrain = ( CalculateAttributeValue(thePlayer.GetAttributeValue('light_attack_focus_drain')) * FocusLossLightHits() ); 
			}
			if ( GetWitcherPlayer().CanUseSkill(S_Sword_s16) )
				focusDrain *= (1 - (CalculateAttributeValue( thePlayer.GetSkillAttributeValue(S_Sword_s16, 'focus_drain_reduction', false, true) ) * thePlayer.GetSkillLevel(S_Sword_s16) / 2));
				
			thePlayer.DrainFocus(focusDrain * modifier);
		}
	}
	
	public final function CounterAndParry( playerVictim : CR4Player, actorAttacker : CActor, out attackAction : W3Action_Attack, out action : W3DamageAction )
	{
		var buffs : array<EEffectType>;
		
		if( playerVictim && attackAction && attackAction.IsActionMelee() )
 		{
			if( attackAction.IsCountered() )
			{
				if( actorAttacker.IsHuge() || action.IsParryStagger() )
				{
					action.MultiplyAllDamageBy(0.0925f);
					action.MultiplyAllDamageBy(1.f - 0.15f * (playerVictim.GetSkillLevel(S_Sword_s03) - 1));
				}
				else
				if( !attackAction.CanBeParried() )
				{
					action.MultiplyAllDamageBy(0.0725f);
					action.MultiplyAllDamageBy(1.f - 0.34f * playerVictim.GetSkillLevel(S_Sword_s03));
				}
				else
					action.SetAllProcessedDamageAs(0);
				
				action.SetHitAnimationPlayType(EAHA_ForceNo);
				action.SetProcessBuffsIfNoDamage(false);
				action.SetCanPlayHitParticle(false);
				action.ClearEffects();
			}
			else
			if( attackAction.IsParried() )
			{
				action.GetEffectTypes(buffs);
				if( !attackAction.CanBeParried() || action.IsParryStagger() )
				{
					if( !buffs.Contains(EET_HeavyKnockdown) )
					{
						action.SetCanPlayHitParticle(false);
						action.SetProcessBuffsIfNoDamage(true);
						action.SetHitAnimationPlayType(EAHA_ForceNo);
						
						if( BlockingStaggerImmunityCheck(playerVictim, action, attackAction) && !actorAttacker.IsHuge() )
						{
							action.ClearEffects();
							action.MultiplyAllDamageBy(0.1f);
							if( ((W3PlayerWitcher)playerVictim).IsSetBonusActive(EISB_HeavyArmor) && RandRange(100, 0) <= 20 )
								actorAttacker.AddEffectDefault(EET_Stagger, action.victim, "ParryStagger");
						}
						else
						{
							playerVictim.AddEffectDefault(EET_Stagger, action.attacker, "Parry");
							
							action.MultiplyAllDamageBy(0.4f);
							action.RemoveBuffsByType(EET_Poison);
							action.RemoveBuffsByType(EET_Bleeding);
							action.RemoveBuffsByType(EET_Knockdown);
						}
						
						StaminaLoss(ESAT_Parry, 1.5f);
					}
				}
				else
				if( !playerVictim.HasStaminaToParry(attackAction.GetAttackName()) )
				{
					if( playerVictim.IsHeavyAttack(attackAction.GetAttackName()) )
					{
						if( !buffs.Contains(EET_HeavyKnockdown) )
						{
							action.SetCanPlayHitParticle(false);
							action.SetProcessBuffsIfNoDamage(true);
							
							if( BlockingStaggerImmunityCheck(playerVictim, action, attackAction) && !actorAttacker.IsHuge() )
							{
								action.ClearEffects();
								action.MultiplyAllDamageBy(0.1f);
								action.SetHitAnimationPlayType(EAHA_ForceNo);
								if( ((W3PlayerWitcher)playerVictim).IsSetBonusActive(EISB_HeavyArmor) && RandRange(100, 0) <= 20 )
									actorAttacker.AddEffectDefault(EET_Stagger, action.victim, "ParryStagger");
							}
							else
							{
								action.SetHitAnimationPlayType(EAHA_ForceYes);
								action.SetHitReactionType(EHRT_Heavy);
								action.MultiplyAllDamageBy(0.2f);
								action.RemoveBuffsByType(EET_Poison);
								action.RemoveBuffsByType(EET_Bleeding);
								action.RemoveBuffsByType(EET_Stagger);
								action.RemoveBuffsByType(EET_LongStagger);
							}
							
							StaminaLoss(ESAT_Parry, 1.2f);
						}
					}
					else
					{
						if( !buffs.Contains(EET_HeavyKnockdown) )
						{
							action.SetCanPlayHitParticle(false);
							action.SetProcessBuffsIfNoDamage(false);
							action.SetHitAnimationPlayType(EAHA_ForceNo);
							
							if( BlockingStaggerImmunityCheck(playerVictim, action, attackAction) && !actorAttacker.IsHuge() )
							{
								action.ClearEffects();
								action.MultiplyAllDamageBy(0.05f);
							}
							else
							{
								action.ClearEffects();
								action.MultiplyAllDamageBy(0.1f);
							}
							
							if( ((W3PlayerWitcher)playerVictim).IsSetBonusActive(EISB_HeavyArmor) && RandRange(100, 0) <= 20 )
								actorAttacker.AddEffectDefault(EET_Stagger, action.victim, "ParryStagger");
								
							StaminaLoss(ESAT_Parry);
						}
					}
				}
				else
				{
					if( playerVictim.IsHeavyAttack(attackAction.GetAttackName()) )
						StaminaLoss(ESAT_Parry, 1.2f);
					else
						StaminaLoss(ESAT_Parry);
					
					if( ((W3PlayerWitcher)playerVictim).IsSetBonusActive(EISB_HeavyArmor) && RandRange(100, 0) <= 20 )
						((CActor)action.attacker).AddEffectDefault(EET_Stagger, action.victim, "ParryStagger");
					
					action.SetCanPlayHitParticle(false);
					action.SetProcessBuffsIfNoDamage(false);
					action.SetHitAnimationPlayType(EAHA_ForceNo);
					action.SetAllProcessedDamageAs(0);
					action.ClearEffects();
				}
			}
		}		
	}

	public final function WhirlBlockingModule( playerVictim : CR4Player, attackAction : W3Action_Attack, act : W3DamageAction )
	{
		var skillLevel : int;
		var poiseThreshold : float;
		var armorPieces : array<SArmorCount>;
		var witcher : W3PlayerWitcher;
		var isSpecialAttack, isLightAttack : bool;
		
		if( (W3Effect_Toxicity)act.causer )
			return;
		
		witcher = (W3PlayerWitcher)playerVictim;
		skillLevel = witcher.GetSkillLevel(S_Sword_s01);
		isSpecialAttack = witcher.GetBehaviorVariable( 'isPerformingSpecialAttack' ) > 0;
		isLightAttack = witcher.GetBehaviorVariable( 'playerAttackType' ) == (int)PAT_Light;
		
		if( witcher && isSpecialAttack && isLightAttack && skillLevel >= 3 )
		{
			armorPieces = witcher.GetArmorCountOrig();
			poiseThreshold = 1.0f;
			
			if( witcher.IsHelmetEquipped(EIST_Gothic) || witcher.IsHelmetEquipped(EIST_Meteorite) || witcher.IsHelmetEquipped(EIST_Dimeritium) )
			{
				if( witcher.HasAbility('Glyphword 9 _Stats', true) )
					armorPieces[2].all += 1;
				else
					armorPieces[3].all += 1;
			}
			
			if( playerVictim.CanUseSkill(S_Perk_06) )
				poiseThreshold -= armorPieces[2].all * 0.075f;
			
			if( attackAction.CanBeDodged() && attackAction.CanBeParried() && !((W3ArrowProjectile)act.causer) )
			{
				act.processedDmg.vitalityDamage = 0;
				act.processedDmg.essenceDamage = 0;
				act.SetHitAnimationPlayType(EAHA_ForceNo);
				act.SetCanPlayHitParticle(false);
				act.ClearEffects();
				act.RemoveBuffsByType(EET_Bleeding);
				act.RemoveBuffsByType(EET_Poison);
				((CActor)act.attacker).ReactToReflectedAttack(act.attacker);
			}
			else
			if( attackAction.CanBeDodged() && whirlPoise > poiseThreshold && skillLevel >= 5 )
			{
				act.SetHitAnimationPlayType(EAHA_ForceNo);
				act.SetCanPlayHitParticle(false);
				act.ClearEffects();
				act.RemoveBuffsByType(EET_Bleeding);
				act.RemoveBuffsByType(EET_Poison);
				
				if( !((W3ArrowProjectile)act.causer) )
				{
					((CActor)act.attacker).ReactToReflectedAttack(act.attacker);
					act.processedDmg.vitalityDamage *= 0.2;
					act.processedDmg.essenceDamage *= 0.2;
				}
			}
			else
			{
				act.SetHitAnimationPlayType(EAHA_ForceNo);
				act.AddEffectInfo(EET_LongStagger);			
			}
		}
		else
		if( witcher && isSpecialAttack && isLightAttack && skillLevel < 3 && act.DealsAnyDamage() && !act.IsDoTDamage() )
		{
			act.SetHitAnimationPlayType(EAHA_ForceNo);
			act.AddEffectInfo(EET_LongStagger);
		}
	}
	
	public final function BreakEnemyBlock( attackAction : W3Action_Attack, playerAttacker : CR4Player, actorVictim : CActor )
	{
		if( playerAttacker && playerAttacker.CanUseSkill(S_Sword_s06) && playerAttacker.IsHeavyAttack(attackAction.GetAttackName()) && (RandRange(100,0) <= (20 * playerAttacker.GetSkillLevel(S_Sword_s06))) )
		{
			if( actorVictim.IsGuarded() )
			{
				actorVictim.ResetHitCounter(0, 0);
				actorVictim.ResetDefendCounter(0, 0);
				((CNewNPC)actorVictim).LowerGuard();
			}
			return;
		}
	}	
	
	public final function SetLock( out lock : bool )
	{
		if ( !LockOn() )
			lock = false;
		else 
			lock = true;
	}

	public function SetReducedGrazeDodge( set : bool )
	{
		if( set && ((W3Effect_SwordDancing)GetWitcherPlayer().GetBuff(EET_SwordDancing)).GetSwordDanceActive() )
			GetWitcherPlayer().AddAbility('SwordDancingAbility', false);
		else
			GetWitcherPlayer().RemoveAbility('SwordDancingAbility');
	}
	
	public function ActivateSwordDance()
	{
		((W3Effect_SwordDancing)GetWitcherPlayer().GetBuff(EET_SwordDancing)).SetSwordDanceActive(true);
	}

	public final function BaseActionSpeed( isAttack : bool ) : float
	{
		var attackSpeedMult, actionSpeedMult : SAbilityAttributeValue;
		var witcher : W3PlayerWitcher;
		var baseSpeed : float;
		
		witcher = GetWitcherPlayer();
		baseSpeed = 1.f;
		
		baseSpeed -= ( PowF(1 - witcher.GetStatPercents(BCS_Stamina), 2) * StamRed() / 100 ) * witcher.GetAdrenalinePercMult();
		baseSpeed -= ( PowF(1 - witcher.GetStatPercents(BCS_Vitality), 2) * HPRed() * (1 - (witcher.GetSkillLevel(S_Sword_s16) * 0.1)) / 100 ) * witcher.GetAdrenalinePercMult();
		baseSpeed += CalcArmorPenalty(witcher, isAttack);
		
		actionSpeedMult = witcher.GetAttributeValue('action_speed');
		if( isAttack )
		{
			attackSpeedMult = witcher.GetAttributeValue('attack_speed');
			baseSpeed += attackSpeedMult.valueMultiplicative;
			if( witcher.WasPlayerSpamming() )
				baseSpeed -= 0.15f;
		}
		baseSpeed += actionSpeedMult.valueMultiplicative;
		
		if( witcher.CanUseSkill(S_Alchemy_s16) && witcher.GetStat(BCS_Toxicity, false) > witcher.GetToxicityDamageThreshold() )
			baseSpeed += (witcher.GetSkillLevel(S_Alchemy_s16) * 0.05f + 0.05f) * PowF(witcher.GetStatPercents(BCS_Toxicity), 2);
		
		return baseSpeed;
	}
	
	private var dodgeTimeStamp : float;
	public function SetDodgeTimeStamp()
	{
		dodgeTimeStamp = theGame.GetEngineTimeAsSeconds();
	}
	
	public function GetDodgeTimeDiff() : float
	{
		return theGame.GetEngineTimeAsSeconds() - dodgeTimeStamp;
	}
	
	private var lastPerformedAction : EBufferActionType;
	public function GetActionType( optional actionType : EBufferActionType )
	{
		switch( thePlayer.GetBehaviorVariable('combatActionType') )
		{
			case 0:
			case 1:
				if( thePlayer.GetBehaviorVariable('playerAttackType') == (int)PAT_Light )
				{
					if( GetWitcherPlayer().GetIsBashing() )
						lastPerformedAction = EBAT_EMPTY;
					else
						lastPerformedAction = EBAT_LightAttack;
				}
				else
					lastPerformedAction = EBAT_HeavyAttack;
			return;
			
			case 9:
				if( currentCounterType == 3 || currentCounterType == 4 )
					lastPerformedAction = EBAT_LightAttack;
				else
					lastPerformedAction = EBAT_EMPTY;
					
				if( (int)currentCounterType )
					((W3Effect_SwordSignDancer)thePlayer.GetBuff(EET_SwordSignDancer)).CountActionType(ESA_Counter);
				else
					((W3Effect_SwordSignDancer)thePlayer.GetBuff(EET_SwordSignDancer)).CountActionType(ESA_Parry);
				currentCounterType = 0;
			return;
			
			case 2:
				lastPerformedAction = EBAT_Dodge;
				((W3Effect_SwordSignDancer)thePlayer.GetBuff(EET_SwordSignDancer)).CountActionType(ESA_Dodge);
			return;
			
			case 3:
				lastPerformedAction = EBAT_Roll;
			return;
			
			default:
				lastPerformedAction = EBAT_EMPTY;
			return;
		}
	}
	
	public function SetCombatAction( actionType : EBufferActionType )
	{
		lastPerformedAction = actionType;
	}
	
	public function CombatSpeedModule()
	{
		switch(lastPerformedAction)
		{
			case EBAT_LightAttack:	FastAttackSpeedModule(); 													break;
			case EBAT_HeavyAttack:	HeavyAttackSpeedModule();													break;
			case EBAT_Dodge:		EvadeSpeedModule();	SetDodgeTimeStamp(); SetReducedGrazeDodge(true);		break;
			case EBAT_Roll:			EvadeSpeedModule();	SetDodgeTimeStamp();									break;
			default: break;
		}
		SetCombatAction(EBAT_EMPTY);
	}
	
	private var playerSpeedMultID : int;
	public function RemovePlayerSpeedMult()
	{
		thePlayer.ResetAnimationSpeedMultiplier(playerSpeedMultID);
	}
	
	public final function FastAttackSpeedModule( optional returnOnly : bool ) : float
	{
		var witcher : W3PlayerWitcher = GetWitcherPlayer();
		var fastSpeedBonus : SAbilityAttributeValue;
		var finalAttackSpeed : float;
		
		if( witcher.IsWeaponHeld('fist') )
			return 1.f;
		
		fastSpeedBonus = witcher.GetAttributeValue('attack_speed_fast_style');
		if( SkillDependant() )
			finalAttackSpeed = BaseActionSpeed(true) + fastSpeedBonus.valueMultiplicative + (witcher.GetSkillLevel(S_Sword_s21) * 3.4f + witcher.GetStat(BCS_Focus) * witcher.GetSkillLevel(S_Sword_s20) * 0.2f) / 100.f;
		else
			finalAttackSpeed = FAIN();
		
		if( !returnOnly )
			playerSpeedMultID = witcher.SetAnimationSpeedMultiplier(finalAttackSpeed, playerSpeedMultID);
			
		return finalAttackSpeed;
	}

	public final function HeavyAttackSpeedModule( optional returnOnly : bool ) : float
	{	
		var witcher : W3PlayerWitcher = GetWitcherPlayer();
		var strongSpeedBonus : SAbilityAttributeValue;
		var finalAttackSpeed : float;
		
		strongSpeedBonus = witcher.GetAttributeValue('attack_speed_heavy_style');
		if( SkillDependant() )
			finalAttackSpeed = BaseActionSpeed(true) + strongSpeedBonus.valueMultiplicative + (witcher.GetSkillLevel(S_Sword_s04) * 4.5f + witcher.GetStat(BCS_Focus) * witcher.GetSkillLevel(S_Sword_s20) * 0.4f) / 100.f;
		else
			finalAttackSpeed = HAIN();
		
		if( !returnOnly )
			playerSpeedMultID = witcher.SetAnimationSpeedMultiplier(finalAttackSpeed, playerSpeedMultID);
			
		return finalAttackSpeed;
	}
	
	public final function EvadeSpeedModule( optional returnOnly : bool ) : float
	{
		var witcher : W3PlayerWitcher = GetWitcherPlayer();
		var finalEvadeSpeed : float;
		
		if( SkillDependant() )
			finalEvadeSpeed = BaseActionSpeed(false) + FloorF(witcher.GetSkillLevel(S_Sword_s09) * 3.f) / 100.f;
		else
			finalEvadeSpeed = DAIN();
		
		if( !returnOnly )
			playerSpeedMultID = witcher.SetAnimationSpeedMultiplier(finalEvadeSpeed, playerSpeedMultID);
			
		return finalEvadeSpeed;
	}
	
	public final function ReaperFinisher()
	{
		thePlayer.GainStat( BCS_Stamina, FADRGain() );
		
		if ( !RSFinishVulnerability() )
		{
			thePlayer.SetImmortalityMode( AIM_Invulnerable, AIC_SyncedAnim );
		}
	}

	public final function SwordCounterEffect( out action : W3DamageAction, attackAction : W3Action_Attack, actorVictim : CActor, playerAttacker : CR4Player )
	{
		var effectValue : SAbilityAttributeValue;
		var damageAction : W3DamageAction;
		var npcVictim : CNewNPC;
		
		npcVictim = (CNewNPC)actorVictim;
		if( playerAttacker && playerAttacker.IsCounterAttack(attackAction.GetAttackName()) )
		{
			if( thePlayer.CanUseSkill(S_Sword_s11) )
			{
				if( action.DealsAnyDamage() )
				{
					effectValue.valueAdditive = 50.f * thePlayer.GetSkillLevel(S_Sword_s11);
					action.AddEffectInfo(EET_Bleeding, 2.f * thePlayer.GetSkillLevel(S_Sword_s11), effectValue);
				}
				
				if( npcVictim && npcVictim.IsShielded( playerAttacker ) && RandRange(100,0) <= 15 )
				{
					npcVictim.ProcessShieldDestruction();
					action.AddEffectInfo(EET_Stagger);
				}
			}
			
			if( attackAction.IsParried() )
				actorVictim.AddTimer('PlayActorHitAnimation', 0.05f, false);
			else
				action.SetHitReactionType(EHRT_Heavy);
		}
	}
	
	private function IsHeavyWeapon( weaponTags : array<name> ) : bool
	{
		return (weaponTags.Contains('spear2h') || weaponTags.Contains('hammer2h') || weaponTags.Contains('axe2h') || weaponTags.Contains('halberd2h') || weaponTags.Contains('sword2h'));
	}
	
	private function SetCounterType( parryInfo: SParryInfo, isHeavyWeapon : bool ) : EPlayerRepelType
	{
		if( parryInfo.attacker.IsHuman() )
		{
			if( isHeavyWeapon )
			{
				switch( SHHCT() )
				{
					case 0:
						if( theInput.IsActionPressed('DistanceModifierMed') )
							return PRT_Kick;
						else
						if( theInput.IsActionPressed('DistanceModifier') )
							return PRT_Bash;
					return PRT_SideStepSlash;
					
					case 1: return PRT_Kick;
					case 2: return PRT_Bash;
				}
			}
			else
			if( parryInfo.attackActionName == 'attack_heavy' )
			{
				switch( HHCT() )
				{
					case 0:
						if( theInput.IsActionPressed('DistanceModifierMed') )
							return PRT_Kick;
						else
						if( theInput.IsActionPressed('DistanceModifier') )
							return PRT_Bash;
					return PRT_SideStepSlash;
					
					case 1: return PRT_Kick;
					case 2: return PRT_Bash;
				}
			}
			else
			{
				switch( HCT() )
				{
					case 0:
						if( theInput.IsActionPressed('DistanceModifierMed') )
							return PRT_Kick;
						else
						if( theInput.IsActionPressed('DistanceModifier') )
							return PRT_Bash;
					return PRT_SideStepSlash;
					
					case 1: return PRT_Kick;
					case 2: return PRT_Bash;
				}
			}
		}
		else
		{
			if( parryInfo.attackActionName == 'attack_heavy' )
			{
				switch( HMCT() )
				{
					case 0:
						if( theInput.IsActionPressed('DistanceModifierMed') )
							return PRT_Kick;
						else
						if( theInput.IsActionPressed('DistanceModifier') )
							return PRT_Bash;
					return PRT_SideStepSlash;
					
					case 1: return PRT_Kick;
					case 2: return PRT_Bash;
				}
			}
			else
			{
				switch( MCT() )
				{
					case 0:
						if( theInput.IsActionPressed('DistanceModifierMed') )
							return PRT_Kick;
						else
						if( theInput.IsActionPressed('DistanceModifier') )
							return PRT_Bash;
					return PRT_SideStepSlash;
					
					case 1: return PRT_Kick; 
					case 2: return PRT_Bash; 
				}
			}
		}
	}
	
	private var currentCounterType : EPlayerRepelType;
	public final function PerformCounter( causer : CR4Player, out counterCollisionGroupNames : array<name>, out parryInfo: SParryInfo, out weaponTags : array<name>, out hitNormal : Vector, out repelType : EPlayerRepelType, out ragdollTarget : CActor, isMutation8 : bool, npc : CNewNPC )
	{
		var thisPos, attackerPos, tracePosStart, tracePosEnd, playerToAttackerVector, hitPos : Vector;
		var bleeding : SCustomEffectParams;
		var playerToTargetRot : EulerAngles;
		var useKnockdown, isHeavyWeapon : bool;
		var zDifference, mult : float;
		var witcher : W3PlayerWitcher;
		var adrGain : SAbilityAttributeValue;
		
		witcher = GetWitcherPlayer();
		witcher.SetCountAct((CActor)parryInfo.attacker);
		
		if( BlizzardCounter() )
		{
			if((W3Potion_Blizzard)witcher.GetBuff(EET_Blizzard))
			{
				FactsAdd("BlizzardCounter");
				((W3Potion_Blizzard)witcher.GetBuff(EET_Blizzard)).KilledEnemy();
			}
		}
		
		if( witcher.IsSuperHeavyAttack(parryInfo.attackActionName) )
			mult = 1.3f;
		else
		if( witcher.IsHeavyAttack(parryInfo.attackActionName) )
			mult = 1.15f;
		else
			mult = 1.f;
		
		StaminaLoss(ESAT_Counterattack, mult);
		parryInfo.attacker.GetInventory().PlayItemEffect(parryInfo.attackerWeaponId, 'counterattack');
		
		if ( parryInfo.attacker.HasAbility('mon_gravehag') )
		{
			repelType = PRT_Slash;
			parryInfo.attacker.AddEffectDefault(EET_CounterStrikeHit, causer, "ReflexParryPerformed");
		}
		else
		if( isMutation8 && npc && !npc.IsImmuneToMutation8Finisher() )
		{
			repelType = PRT_RepelToFinisher;
			npc.AddEffectDefault(EET_CounterStrikeHit, causer, "ReflexParryPerformed");
			
			causer.SetTarget(npc, true);
			causer.PerformFinisher(0.f, 0);
		}
		else
		{
			isHeavyWeapon = IsHeavyWeapon(weaponTags) || npc.HasAbility('SkillElite') || npc.HasAbility('SkillWitcher') || npc.HasAbility('SkillBoss');
			repelType = SetCounterType(parryInfo, isHeavyWeapon);
			if( (IsUsingBattleAxe() || IsUsingBattleMace()) && repelType == PRT_SideStepSlash )
				repelType = PRT_Bash;
			
			if( npc.HasAbility('olgierd_default_stats') )
			{
				switch(repelType)
				{
					case PRT_Kick:
						parryInfo.attacker.AddEffectDefault(EET_CounterStrikeHit, causer, "ReflexParryPerformed");
						npc.DrainStamina(ESAT_FixedValue, 15.f * GetWitcherPlayer().GetSkillLevel(S_Sword_s11), 2.5f);
					break;
					
					case PRT_Bash:
						parryInfo.attacker.AddEffectDefault(EET_CounterStrikeHit, causer, "ReflexParryPerformed");
						npc.DrainStamina(ESAT_FixedValue, 15.f * GetWitcherPlayer().GetSkillLevel(S_Sword_s11), 2.5f);
					break;
					
					case PRT_SideStepSlash:
						repelType = PRT_SideStepSlash;
					break;
				}
			}
			else
			if( isHeavyWeapon )
			{
				thisPos = causer.GetWorldPosition();
				attackerPos = parryInfo.attacker.GetWorldPosition();
				playerToTargetRot = VecToRotation( thisPos - attackerPos );
				zDifference = thisPos.Z - attackerPos.Z;
				
				if ( playerToTargetRot.Pitch < -5.f && zDifference > 0.35 )
				{
					repelType = PRT_Kick;
					ragdollTarget = parryInfo.attacker;
					witcher.AddTimer('SetKnockdownStagger', 0.3f, false ,,,, true);
				}
				else
				switch(repelType)
				{
					case PRT_Kick:
						witcher.AddTimer('SetNormalStagger', 0.3f, false ,,,, true);
						npc.DrainStamina(ESAT_FixedValue, 15.f * GetWitcherPlayer().GetSkillLevel(S_Sword_s11), 2.5f);
					break;
					
					case PRT_Bash:
						useKnockdown = (witcher.CanUseSkill(S_Sword_s11) && RandRange(100, 0) <= 25 * (2 - npc.GetHealthPercents()) * (1 - PowF(1 - witcher.GetStatPercents(BCS_Stamina), 2)));
						if(useKnockdown && (!parryInfo.attacker.IsImmuneToBuff(EET_HeavyKnockdown) || !parryInfo.attacker.IsImmuneToBuff(EET_Knockdown)))
						{
							ragdollTarget = parryInfo.attacker;
							witcher.AddTimer('SetKnockdownStagger', 0.3f, false ,,,, true);
						}
						else witcher.AddTimer('SetLongStagger', 0.3f, false ,,,, true);
					break;
					
					case PRT_SideStepSlash:
						repelType = PRT_SideStepSlash;
					break;
				}
			}
			else
			if( !npc.IsHuman() )
			{
				switch(repelType)
				{
					case PRT_Kick:
						witcher.AddTimer('SetNormalStagger', 0.3f, false ,,,, true);
						npc.DrainStamina(ESAT_FixedValue, 15.f * GetWitcherPlayer().GetSkillLevel(S_Sword_s11), 2.5f);
					break;
					
					case PRT_Bash:
						useKnockdown = (witcher.CanUseSkill(S_Sword_s11) && RandRange(100, 0) <= 25 * (2 - npc.GetHealthPercents()) * (1 - PowF(1 - witcher.GetStatPercents(BCS_Stamina), 2)));
						if(useKnockdown && (!parryInfo.attacker.IsImmuneToBuff(EET_HeavyKnockdown) || !parryInfo.attacker.IsImmuneToBuff(EET_Knockdown)))
						{
							ragdollTarget = parryInfo.attacker;
							witcher.AddTimer('SetKnockdownStagger', 0.3f, false ,,,, true);
						}
						else witcher.AddTimer('SetLongStagger', 0.3f, false ,,,, true);
					break;
					
					case PRT_SideStepSlash:
						repelType = PRT_SideStepSlash;
					break;
				}
			}
			else
			{
				thisPos = causer.GetWorldPosition();
				attackerPos = parryInfo.attacker.GetWorldPosition();
				playerToTargetRot = VecToRotation( thisPos - attackerPos );
				zDifference = thisPos.Z - attackerPos.Z;
				
				if ( playerToTargetRot.Pitch < -5.f && zDifference > 0.35 )
				{
					repelType = PRT_Kick;
					ragdollTarget = parryInfo.attacker;
					witcher.AddTimer('SetKnockdownStagger', 0.3f, false ,,,, true);
				}
				else
				switch(repelType)
				{
					case PRT_Kick:
						parryInfo.attacker.AddEffectDefault(EET_CounterStrikeHit, causer, "ReflexParryPerformed");
						npc.DrainStamina(ESAT_FixedValue, 15.f * GetWitcherPlayer().GetSkillLevel(S_Sword_s11), 2.5f);
					break;
					
					case PRT_Bash:
						useKnockdown = (witcher.CanUseSkill(S_Sword_s11) && RandRange(100, 0) <= 25 * (2 - npc.GetHealthPercents()) * (1 - PowF(1 - witcher.GetStatPercents(BCS_Stamina), 2)));
						if(useKnockdown && (!parryInfo.attacker.IsImmuneToBuff(EET_HeavyKnockdown) || !parryInfo.attacker.IsImmuneToBuff(EET_Knockdown)))
						{
							ragdollTarget = parryInfo.attacker;
							witcher.AddTimer('SetKnockdownStagger', 0.3f, false ,,,, true);
						}
						else parryInfo.attacker.AddEffectDefault(EET_CounterStrikeHit, causer, "ReflexParryPerformed");
					break;
					
					case PRT_SideStepSlash:
						repelType = PRT_SideStepSlash;
					break;
				}
			}
		}
		currentCounterType = repelType;
		if( repelType == PRT_Bash )
		{
			((W3Effect_SwordQuen)witcher.GetBuff(EET_SwordQuen)).BashCounterImpulse();
		}
	}
	
	public function RedMutagenPoiseValue() : float
	{
		var points, bonus : float;
		var i, synergy : int;
		var mutagenSlots : array<SMutagenSlot>;
		var inv : CInventoryComponent;
		var mutagenName : name;
		var color : ESkillColor;
		
		inv = thePlayer.GetInventory();
		
		mutagenSlots = ((W3PlayerAbilityManager)thePlayer.abilityManager).GetPlayerSkillMutagens();
		
		bonus = 0;
		for (i=0; i<mutagenSlots.Size(); i+=1)
		{
			mutagenName = inv.GetItemName(mutagenSlots[i].item);
			color = inv.GetSkillMutagenColor(mutagenSlots[i].item);
			synergy = thePlayer.GetGroupBonusCount(color, mutagenSlots[i].skillGroupID);
			
			switch(mutagenName)
			{
				case 'Greater mutagen red' :
					bonus += 0.1f + synergy * 0.025f;
				break;
				
				case 'Mutagen red' :
					bonus += 0.07f + synergy * 0.015f;
				break;
				
				case 'Lesser mutagen red' :
				case 'Katakan mutagen' :
				case 'Volcanic Gryphon mutagen' :
				case 'Water Hag mutagen' :
				case 'Wyvern mutagen' :
				case 'Doppler mutagen' :
				case 'Succubus mutagen' :
				case 'Fogling 2 mutagen' :
				case 'Werewolf mutagen' :
				case 'Nekker Warrior mutagen' :
					bonus += 0.05f + synergy * 0.01f;
				break;
			}
		}
		bonus *= 1.f + thePlayer.GetSkillLevel(S_Alchemy_s19) * 0.05f;
		
		return bonus;
	}
	
	public final function ArmorPoiseValue( armorPieces : array<SArmorCount> ) : float
	{
		if( GetWitcherPlayer().IsSetBonusActive(EISB_Gothic2) )
			return ( armorPieces[1].all * 0.03f + armorPieces[2].all * 0.06f + armorPieces[3].all * 0.1f ) + 0.3f;
		else
			return ( armorPieces[1].all * 0.03f + armorPieces[2].all * 0.06f + armorPieces[3].all * 0.1f );
	}
	
	public final function BaseStatsPoiseValue( witcher : W3PlayerWitcher ) : float
	{
		return PowF(witcher.GetStatPercents(BCS_Toxicity), 2) * witcher.GetStatMax(BCS_Toxicity) / 500.f;
	}
	
	public final function ApplyPlayerStaggerMechanics( playerVictim : CR4Player, attackAction : W3Action_Attack, out act : W3DamageAction )
	{
		var mut15Bonus, actionPoiseBonus, poiseValue, poiseThreshold, staggerChance : float;
		var playerWitcher : W3PlayerWitcher;
		var armorPieces : array<SArmorCount>;
		
		if( playerVictim && attackAction && attackAction.GetHitAnimationPlayType() != EAHA_ForceYes )
		{
			playerWitcher = (W3PlayerWitcher)playerVictim;
			armorPieces = playerWitcher.GetArmorCountOrig();
			poiseThreshold = 1.0f;
			
			if( playerWitcher.IsHelmetEquipped(EIST_Gothic) || playerWitcher.IsHelmetEquipped(EIST_Meteorite) || playerWitcher.IsHelmetEquipped(EIST_Dimeritium) )
			{
				if( playerWitcher.HasAbility('Glyphword 9 _Stats', true) )
					armorPieces[2].all += 1;
				else
					armorPieces[3].all += 1;
			}
			
			if( playerVictim.CanUseSkill(S_Perk_06) )
				poiseThreshold -= armorPieces[2].all * 0.075f;
			
			actionPoiseBonus = 1.f;
			
			if( playerVictim.IsInCombatAction_Attack() )
			{
				actionPoiseBonus += 0.22f;
			}
			
			if( playerVictim.IsInCombatAction_SpecialAttack() )
				actionPoiseBonus += 0.10f;
			
			if( playerVictim.IsCurrentlyDodging() )
				actionPoiseBonus += 0.24f;
			
			if( playerVictim.GetIsSprinting() )
				actionPoiseBonus += 0.29f;
			else
			if( playerVictim.GetIsRunning() )
				actionPoiseBonus += 0.18f;
			
			mut15Bonus = playerWitcher.GetMutagen15() * 0.05f;
			
			poiseValue = ( BaseStatsPoiseValue(playerWitcher) + ArmorPoiseValue(armorPieces) + RedMutagenPoiseValue() ) * SensesPoiseRatio(playerWitcher) * actionPoiseBonus + mut15Bonus;
			whirlPoise = poiseValue;
			
			if( RandRangeF(1,0) <= poiseValue && ( attackAction.CanBeParried() || poiseValue >= poiseThreshold ) && playerWitcher.GetCurrentStateName() != 'W3EEAnimation' )
			{
				act.SetHitAnimationPlayType(EAHA_ForceNo);
			}
		}
	}
	
	public final function SensesPoiseRatio( playerWitcher : W3PlayerWitcher ) : float
	{
		var reduct, skillMult : float;	
		var skillLvl : int;
		
		reduct = PowF(1 - playerWitcher.GetStatPercents(BCS_Vitality), 2);
		
		if (playerWitcher.CanUseSkill(S_Sword_s10))
		{
			skillLvl = playerWitcher.GetSkillLevel(S_Sword_s10);
			reduct *= 1.0f - skillLvl * 0.1f;
			
			if (skillLvl > 2)
				skillLvl = 2;
			skillMult = 1.0f + skillLvl * 0.05f;
		}
		else 
			skillMult = 1.0f;
			
		return (1.0f - reduct) * skillMult;		
	}
	
	public final function ApplyNPCStaggerMechanics( playerVictim : CR4Player, attackAction : W3Action_Attack, out act : W3DamageAction )
	{
		var poiseDamage : SAbilityAttributeValue;
		var playerAttacker : CR4Player;
		var npcVictim : CNewNPC;
		var poiseValue : float;
		
		if( act.victim && !playerVictim && attackAction && ( attackAction.CanBeParried() || ((W3ArrowProjectile)act.causer) ) )
		{
			npcVictim = (CNewNPC)act.victim;
			poiseValue = npcVictim.GetPoiseValue() * npcVictim.GetHealthPercents();
			playerAttacker = (CR4Player)act.attacker;
			if( playerAttacker )
			{
				poiseDamage = playerAttacker.GetAttributeValue('poise_damage');
				poiseValue -= 0.05f * playerAttacker.GetSkillLevel(S_Sword_s06);
				poiseValue -= poiseDamage.valueAdditive / 100;
			}
			
			if( RandRangeF(1,0) <= poiseValue )
				act.SetHitAnimationPlayType(EAHA_ForceNo);
		}
	}
	
	public final function CrippleEnemy( playerAttacker : CPlayer, enemy : CNewNPC, action : W3DamageAction )
	{
		var initialSlowdown : float;
		var skillLevel : int;
		
		skillLevel = thePlayer.GetSkillLevel(S_Sword_s05);
		
		if( !enemy.CanGetCrippled() )
			return;
		
		if( thePlayer.CanUseSkill(S_Sword_s05) && playerAttacker && enemy && action.IsActionMelee() && action.DealsAnyDamage() && playerAttacker.GetBehaviorVariable( 'playerAttackType' ) == (int)PAT_Light )
		{
			if( RandF() < ( 0.14f * skillLevel) )
			{
				initialSlowdown = enemy.GetSlowdownFactor();
				
				if( initialSlowdown < 1 )
					enemy.SetSlowdownFactor( MinF( initialSlowdown + 0.005 * skillLevel, 0.03 * skillLevel ) );
				
				enemy.npcStats.spdMultID2 = enemy.SetAnimationSpeedMultiplier(1 - enemy.GetSlowdownFactor(), enemy.npcStats.spdMultID2);
				enemy.SetCrippled(true);
			}
			
			enemy.DrainStamina(ESAT_FixedValue, 0, Max(FloorF(skillLevel * 0.66f), 1));
			enemy.AddTimer('RemoveCripplingInjury', Max(skillLevel, 2), false,,,,true);
		}		
	}
	
	public final function ApplyDamageModifiers( out action : W3DamageAction, actorVictim : CActor )
	{
		var victimHealth : float;
		var actorAttacker : CActor;
		var witcherAttacker : W3PlayerWitcher;
		
		if( !action || !action.attacker || !action.victim || !action.DealsAnyDamage() )
			return;
			
		if( !actorVictim.IsHuge() && !((CPlayer)actorVictim) && action.DealsAnyDamage() )
			actorVictim.DrainStamina(ESAT_FixedValue, 0, 1.f);
			
		if( (!action.IsActionMelee() && !action.IsActionRanged()) || action.IsDoTDamage() )
			return;
			
		witcherAttacker = (W3PlayerWitcher)action.attacker;
		actorAttacker = (CActor)action.attacker;
		
		if( actorVictim.UsesVitality() )
			victimHealth = actorVictim.GetStatPercents(BCS_Vitality);
		else
			victimHealth = actorVictim.GetStatPercents(BCS_Essence);
			
		if( witcherAttacker && action.IsActionMelee() && witcherAttacker.HasBuff(EET_ReflexBlast) )
			action.MultiplyAllDamageBy(0.5f);
			
		if( action.IsActionMelee() )
		{
			if( witcherAttacker )
				action.MultiplyAllDamageBy(1.f - PowF(1 - actorAttacker.GetStatPercents(BCS_Stamina), 2) * 0.4f * witcherAttacker.GetAdrenalinePercMultHalf());
			else
				action.MultiplyAllDamageBy(1.f - PowF(1 - actorAttacker.GetStatPercents(BCS_Stamina), 2) * 0.4f);
		}
		
		if( actorVictim.IsAttackerAtBack(actorAttacker) )
		{
			if( actorVictim.GetInjuryManager().HasInjury(EPI_Spine) )
				action.MultiplyAllDamageBy(1.25f);
			else
				action.MultiplyAllDamageBy(1.1f);
		}
		
		action.MultiplyAllDamageBy(1.f + (0.3f * (1.f - victimHealth)) - 0.15f);
	}
	
	public function PerformLightBash() : bool
	{
		var kickAnim : name;
		var staminaCost : float;
		var witcher : W3PlayerWitcher;
		var target : CActor;
		
		witcher = GetWitcherPlayer();
		target = witcher.GetTarget();
		
		staminaCost = CalcStaminaCost(ESAT_SpecialAttackLight, 2, 1);
		if( witcher && target && !witcher.GetIsBashing() && !target.IsHuge() && witcher.GetStat(BCS_Stamina) >= staminaCost && VecDistance(witcher.GetWorldPosition(), target.GetWorldPosition()) < 2.3f )
		{
			if( witcher.HasBuff(EET_Stagger) || witcher.HasBuff(EET_LongStagger) || witcher.HasBuff(EET_Knockdown) || witcher.HasBuff(EET_HeavyKnockdown) || witcher.HasBuff(EET_Pull) )
				return false;
			
			if ( witcher.GetCombatIdleStance() <= 0.f )
				kickAnim = 'geralt_special_kick_lp';
			else
				kickAnim = 'geralt_special_kick_rp';
			
			witcher.SetIsBashing(true);
			witcher.DrainStamina(ESAT_FixedValue, staminaCost, 2.5f);
			witcher.OnCombatActionStart();
			witcher.ClearCustomOrientationInfoStack();
			witcher.SetSlideTarget(target);
			witcher.SetMoveTarget(target);
			witcher.SetCustomRotation('SpecialAttackLight', VecHeading(target.GetWorldPosition() - witcher.GetWorldPosition()), 1080.f, 1.f, false);
			witcher.ActionPlaySlotAnimationAsync('PLAYER_SLOT', kickAnim, 0.15f, 0.35f, true);
			witcher.AddTimer('RemoveBashing', 2.5f, false ,,,, true);
			
			return true;
		}
		else
		{
			return false;
		}
	}
	
	public function LightBashEffect( attackAction : W3Action_Attack, action : W3DamageAction, actorVictim : CActor )
	{
		var effects : array<EEffectType>;
		
		if( attackAction.GetAttackName() == 'geralt_kick_special' )
		{
			action.SetHitAnimationPlayType(EAHA_ForceNo);
			action.SetCanPlayHitParticle(false);
			action.SetCannotReturnDamage(true);
			attackAction.SetForceInjury(false);
			action.SetAllProcessedDamageAs(0);
			action.ClearEffects();
			
			if( actorVictim.HasBuff(EET_Stagger) || actorVictim.HasBuff(EET_LongStagger) || actorVictim.HasBuff(EET_CounterStrikeHit) )
			{
				effects.PushBack(EET_HeavyKnockdown);
				effects.PushBack(EET_Knockdown);
				effects.PushBack(EET_LongStagger);
			}
			else
			{
				effects.PushBack(EET_Stagger);
				effects.PushBack(EET_LongStagger);
			}
			
			actorVictim.DrainStamina(ESAT_FixedValue, 30.f, 3.f);
			actorVictim.AddEffectDefault(effects[RandRange(effects.Size(),0)], action.attacker, "SpecialAttackLight", false);
		}
	}
	
	public function FistFightMechanics( action : W3Action_Attack )
	{
		var actorAttacker, actorVictim : CActor;
		var effectChance : float;
		
		actorAttacker = (CActor)action.attacker;
		actorVictim = (CActor)action.victim;
		if( !actorAttacker.IsWeaponHeld('fist') )
			return;
		
		if( !(action.IsParried() || action.IsCountered()) && action.DealsAnyDamage() )
		{
			if( !actorVictim.HasBuff(EET_Knockdown) )
			{
				if( actorAttacker.IsHeavyAttack(action.GetAttackName()) )
				{
					if( (actorVictim.HasBuff(EET_Stagger) || actorVictim.HasBuff(EET_LongStagger)) && RandRange(100, 0) <= 50 )
						action.AddEffectInfo(EET_Knockdown);
					else
					{
						effectChance = 40.f * (1 - actorVictim.GetStatPercents(BCS_Vitality));
						if( RandRange(100, 0) <= effectChance )
							if( (CR4Player)actorVictim )
							action.AddEffectInfo(EET_Stagger);
						else
							action.AddEffectInfo(EET_Knockdown);
					}
				}
				else
				if( !actorVictim.HasBuff(EET_Stagger) )
				{
					effectChance = 60.f * (1 - actorVictim.GetStatPercents(BCS_Vitality));
					if( RandRange(100, 0) <= effectChance )
						action.AddEffectInfo(EET_Stagger);
				}
			}
		}
		
		if( (CR4Player)actorVictim )
		{
			if( actorAttacker.HasAbility('SkillFistsMedium') && action.IsParried() )
			{
				if( RandRange(100, 0) <= 30 )
					action.SetParryStagger();
			}
			else
			if( actorAttacker.HasAbility('SkillFistsHard') && (action.IsParried() || action.IsCountered()) )
			{
				if( action.IsParried() && RandRange(100, 0) <= 50 )
					action.SetParryStagger();
				
				if( action.IsCountered() && RandRange(100, 0) <= 30 )
					action.SetParryStagger();
			}
		}
	}
	
	public function IsImmuneToFinisher( npc : CNewNPC ) : bool
	{
		var str : string;
		
		if( !npc.IsHuman() || !npc.IsAlive() || !IsRequiredAttitudeBetween( thePlayer, npc, true ) )
		{
			return true;
		}
		
		if( npc.HasBuff(EET_Knockdown) || npc.HasBuff(EET_HeavyKnockdown) )
		{
			return true;
		}
		if( npc.HasAbility('SkillBoss') )
		{
			return true;
		}
		if( npc.HasAbility('Boss') )
		{
			return true;
		}
		if( npc.HasAbility('InstantKillImmune') )
		{
			return true;
		}
		if( npc.HasTag('olgierd_gpl') )
		{
			return true;
		}
		if( npc.HasAbility('DisableFinishers') )
		{
			return true;
		}
		
		if( npc.WillBeUnconscious() )
		{
			return true;
		}
		
		str = npc.GetName();
		if( StrStartsWith( str, "rosa_var_attre" ) )
		{
			return true;
		}
		
		return false;
	}
	
	public function PerformHeavyBash() : bool
	{
		var staminaCost : float;
		var witcher : W3PlayerWitcher;
		var target : CActor;
		
		witcher = GetWitcherPlayer();
		
		staminaCost = CalcStaminaCost(ESAT_SpecialAttackHeavy, 2, 1);
		if( witcher && !witcher.IsWeaponHeld('fist') && !witcher.GetIsBashing() && witcher.GetStat(BCS_Stamina) >= staminaCost )
		{
			target = witcher.GetTarget();
			witcher.SetIsBashing(true);
			witcher.ClearCustomOrientationInfoStack();
			witcher.DrainStamina(ESAT_FixedValue, staminaCost, 3.f);
			witcher.SetSlideTarget(target);
			witcher.SetMoveTarget(target);
			witcher.SetCustomRotation('SpecialHeavy', VecHeading(target.GetWorldPosition() - witcher.GetWorldPosition()), 1080.f, 1.6f, false);
			witcher.ActionPlaySlotAnimationAsync('PLAYER_SLOT', 'geralt_heavy_special_attack', 0.15f, 0.25f, true);
			witcher.OnCombatActionStart();
			witcher.AddTimer('RemoveBashing', 2.5f, false ,,,, true);
			
			return true;
		}
		else
		{
			return false;
		}
	}
	
	var dealtAnyDamage : bool; default dealtAnyDamage = false;
	public function SpecialAttackHeavy( action : W3Action_Attack )
	{
		var repelType : EPlayerRepelType = PRT_RepelToFinisher;
		var witcher : W3PlayerWitcher;
		var npcTarget : CNewNPC;
		
		witcher = (W3PlayerWitcher)action.attacker;
		if( witcher.HasBuff(EET_Stagger) || witcher.HasBuff(EET_LongStagger) || witcher.HasBuff(EET_Knockdown) || witcher.HasBuff(EET_HeavyKnockdown) || witcher.HasBuff(EET_Pull) )
			return;
		
		if( witcher && action.victim && action.GetAttackAnimName() == 'geralt_heavy_special_attack' )
		{
			npcTarget = (CNewNPC)action.victim;
			
			if( action.DealsAnyDamage() && action.GetAttackName() == 'geralt_heavy_special1' )
			{
				action.SetHitAnimationPlayType(EAHA_ForceYes);
				dealtAnyDamage = true;
			}
			else
			if( action.GetAttackName() == 'geralt_heavy_special2' )
			{
				action.SetHitAnimationPlayType(EAHA_ForceYes);
				action.processedDmg.vitalityDamage *= 0.45f;
				action.processedDmg.essenceDamage *= 0.45f;
				if( RandRange(100, 0) <= 20 && npcTarget.IsShielded(witcher) )
				{
					npcTarget.ProcessShieldDestruction();
					action.AddEffectInfo(EET_Stagger);
				}
				
				if( dealtAnyDamage && action.DealsAnyDamage() )
				{
					action.SetForceInjury(true);
					dealtAnyDamage = false;
				}
				
				if( action.DealsAnyDamage() && !IsImmuneToFinisher(npcTarget) && npcTarget.GetHealthPercents() < 0.3f && !(IsUsingBattleAxe() || IsUsingBattleMace()) )
				{
					npcTarget.AddEffectDefault(EET_CounterStrikeHit, witcher, "ReflexParryPerformed");
					witcher.SetCachedAct(npcTarget);
					witcher.AddTimer('FinishTarget', 0.3f, false);
					witcher.ClearCustomOrientationInfoStack();
					witcher.SetSlideTarget(npcTarget);
					witcher.SetMoveTarget(npcTarget);
					witcher.RaiseForceEvent('PerformCounter');
					witcher.OnCombatActionStart();	
				}
			}
		}
	}
	
	public function ProcessSecondaryEffects( out attackAction : W3Action_Attack, actorAttacker : CActor )
	{
		var blockCrushValue, disarmChance, disarmShieldChance : SAbilityAttributeValue;
		var npcTarget : CNewNPC;
		
		if( !actorAttacker || (CPlayer)attackAction.victim )
			return;
		
		disarmShieldChance = actorAttacker.GetAttributeValue('shield_disarm_chance');
		blockCrushValue = actorAttacker.GetAttributeValue('damage_through_blocks');
		disarmChance = actorAttacker.GetAttributeValue('disarm_chance');
		npcTarget = (CNewNPC)attackAction.victim;
		if( attackAction && attackAction.IsActionMelee() && attackAction.IsParried() && !attackAction.IsCountered() )
		{
			if( npcTarget && (npcTarget.HasTwoHandedWeapon() || npcTarget.IsShielded(attackAction.attacker)) )
			{
				attackAction.SetAllProcessedDamageAs(0);
			}
			else
			{
				if( npcTarget && RandF() <= disarmChance.valueMultiplicative )
					npcTarget.ProcessWeaponDisarm();
				attackAction.MultiplyAllDamageBy(blockCrushValue.valueMultiplicative);
				attackAction.SetHitAnimationPlayType(EAHA_ForceNo);
			}
			if( npcTarget && npcTarget.IsShielded(attackAction.attacker) && RandF() <= disarmShieldChance.valueMultiplicative )
			{
				npcTarget.ProcessShieldDestruction();
				attackAction.AddEffectInfo(EET_Stagger);
			}
		}
	}
	
	public function AttackCameraShake( attackName : name )
	{
		if( IsUsingBattleAxe() || IsUsingBattleMace() )
		{
			if( thePlayer.IsLightAttack(attackName) )
			{
				GCameraShake(0.1f, false, thePlayer.GetWorldPosition(),,,, 1.1f);
			}
			else
			if( thePlayer.IsHeavyAttack(attackName) )
			{
				GCameraShake(0.15f, false, thePlayer.GetWorldPosition(),,,, 0.7f);
			}
		}
		else
		{
			if( thePlayer.IsLightAttack(attackName) )
			{
				GCameraShake(0.05f, false, thePlayer.GetWorldPosition(),,,, 1.5f);
			}
			else
			if( thePlayer.IsHeavyAttack(attackName) )
			{
				GCameraShake(0.1f, false, thePlayer.GetWorldPosition(),,,, 1.0f);
			}
		}
	}
	
	private function GetHitArea( action : W3Action_Attack ) : name
	{
		var hitBoneIndex : int;
		
		hitBoneIndex = action.GetHitBoneIndex();
		switch(hitBoneIndex)
		{
			case 4:
			case 5:
			case 6:
			case 7:
			case 12:
				return 'UpperBody';
			
			case 3:
			case 8:
			case 9:
			case 10:
			case 11:
			case 13:
			case 14:
			case 15:
			case 16:
				return 'MidBody';
			
			case 0:
			case 1:
			case 2:
				return 'LowerBody';
				
			case 17:
			case 18:
			case 19:
			case 20:
			case 21:
			case 22:
			case 23:
			case 24:
				return 'Legs';
		}
	}
	
	public function GetDismembermentTypes( action : W3Action_Attack ) : array<name>
	{
		var dismembermentTypes : array<name>;
		var swingType, swingDir : int;
		var hitArea : name;
		
		hitArea = GetHitArea(action);
		swingType = action.GetSwingType();
		swingDir = action.GetSwingDirection();
		switch(swingType)
		{
			case 0:
				if(swingDir == 3)
				{
					if( hitArea == 'UpperBody' )
					{
						dismembermentTypes.PushBack('cut_head');
						dismembermentTypes.PushBack('cut_neck');
						dismembermentTypes.PushBack('cut_head2');
					}
					if( hitArea == 'MiddleBody' || hitArea == 'LowerBody' )
					{
						dismembermentTypes.PushBack('gash_03');
						dismembermentTypes.PushBack('cut_forearm1_finisher');
					}
					if( hitArea == 'LowerBody' )
					{
						dismembermentTypes.PushBack('cut_torso2');
					}
					if( hitArea == 'Legs' )
					{
						dismembermentTypes.PushBack('cut_legs1_finisher');
						dismembermentTypes.PushBack('cut_legs2_finisher');
					}
				}
				else
				if(swingDir == 2)
				{
					if( hitArea == 'UpperBody' )
					{
						dismembermentTypes.PushBack('cut_head');
						dismembermentTypes.PushBack('cut_neck');
						dismembermentTypes.PushBack('cut_head2');
					}
					if( hitArea == 'MiddleBody' || hitArea == 'LowerBody' )
					{
						dismembermentTypes.PushBack('gash_03');
						dismembermentTypes.PushBack('cut_forearm2_finisher');
					}
					if( hitArea == 'LowerBody' )
					{
						dismembermentTypes.PushBack('cut_torso2');
					}
					if( hitArea == 'Legs' )
					{
						dismembermentTypes.PushBack('cut_legs1_finisher');
						dismembermentTypes.PushBack('cut_legs2_finisher');
					}
				}
			return dismembermentTypes;
			
			case 1:
				if(swingDir == 1 || swingDir == 0)
				{
					if( hitArea == 'UpperBody' || hitArea == 'MiddleBody' )
					{
						dismembermentTypes.PushBack('gash_01');
						dismembermentTypes.PushBack('cut_arm');
						dismembermentTypes.PushBack('cut_arm2');
					}
				}
			return dismembermentTypes;
			
			case 2:
				if(swingDir == 3)
				{
					if( hitArea == 'MiddleBody' || hitArea == 'LowerBody' )
					{
						dismembermentTypes.PushBack('gash_03');
					}
					if( hitArea == 'MiddleBody' || hitArea == 'UpperBody' )
					{
						dismembermentTypes.PushBack('cut_torso3');
						dismembermentTypes.PushBack('cut_torso4');
					}
					if( hitArea == 'Legs' )
					{
						dismembermentTypes.PushBack('cut_legs2_finisher');
					}
				}
				else
				if(swingDir == 2)
				{
					if( hitArea == 'MiddleBody' || hitArea == 'UpperBody' )
					{
						dismembermentTypes.PushBack('cut_torso1');
						dismembermentTypes.PushBack('cut_torso5');
					}
					if( hitArea == 'Legs' )
					{
						dismembermentTypes.PushBack('cut_legs1_finisher');
					}
				}
			return dismembermentTypes;
			
			case 3:
				if(swingDir == 3)
				{
					if( hitArea == 'MiddleBody' || hitArea == 'UpperBody' )
					{
						dismembermentTypes.PushBack('cut_torso1');
						dismembermentTypes.PushBack('cut_torso5');
					}
					if( hitArea == 'Legs' )
					{
						dismembermentTypes.PushBack('cut_legs1_finisher');
					}
				}
				else
				if(swingDir == 2)
				{
					if( hitArea == 'MiddleBody' || hitArea == 'UpperBody' )
					{
						dismembermentTypes.PushBack('gash_02');
						dismembermentTypes.PushBack('cut_torso3');
						dismembermentTypes.PushBack('cut_torso4');
					}
					if( hitArea == 'Legs' )
					{
						dismembermentTypes.PushBack('cut_legs2_finisher');
					}
				}
			return dismembermentTypes;
			
			case 4:
				if(swingDir == 1 || swingDir == 0)
				{
					if( hitArea == 'UpperBody' )
						dismembermentTypes.PushBack('gash_01');
				}
			return dismembermentTypes;
			
			default: return dismembermentTypes;
		}
	}
	
	private function GetFinisherDirection() : name
	{
		if( theInput.GetActionValue( 'GI_AxisLeftX' ) > 0 )
			return 'Right';
		else
		if( theInput.GetActionValue( 'GI_AxisLeftX' ) < 0 )
			return 'Left';
		else
		if( theInput.GetActionValue( 'GI_AxisLeftY' ) > 0 )
			return 'Forward';
		else
		if( theInput.GetActionValue( 'GI_AxisLeftY' ) < 0 )
			return 'Back';
		else
			return 'Static';
	}
	
	public function GetFinisherAnimsForDirection() : array<name>
	{
		var leftStance : bool;
		var direction : name;
		var finisherArray : array<name>;
		var headtakerEffect : W3Effect_SwordBehead;
		
		((W3Effect_SwordDesperateAct)GetWitcherPlayer().GetBuff(EET_SwordDesperateAct)).RestoreStatsExecution();
		headtakerEffect = (W3Effect_SwordBehead)GetWitcherPlayer().GetBuff(EET_SwordBehead);
		leftStance = thePlayer.GetCombatIdleStance() <= 0.f;
		direction = GetFinisherDirection();
		if( leftStance )
		{
			switch(direction)
			{
				case 'Left':
					finisherArray.PushBack('man_finisher_02_lp');
					finisherArray.PushBack('man_finisher_07_lp');
					headtakerEffect.SetBeheadEffectActive(true);
				return finisherArray;
				
				case 'Right':
					if( !headtakerEffect )
					{
						finisherArray.PushBack('man_finisher_dlc_arm_lp');
						finisherArray.PushBack('man_finisher_dlc_head_rp');
					}
					else
					{
						finisherArray.PushBack('man_finisher_dlc_head_rp');
						headtakerEffect.SetBeheadEffectActive(true);
					}
				return finisherArray;
				
				case 'Forward':
					finisherArray.PushBack('man_finisher_08_lp');
					headtakerEffect.SetBeheadEffectActive(true);
				return finisherArray;
				
				case 'Back':
					finisherArray.PushBack('man_finisher_dlc_legs_lp');
					finisherArray.PushBack('man_finisher_dlc_torso_lp');
				return finisherArray;
				
				case 'Static':
					if( !headtakerEffect )
					{
						finisherArray.PushBack('man_finisher_01_rp');
						finisherArray.PushBack('man_finisher_04_lp');
						finisherArray.PushBack('man_finisher_06_lp');
					}
					else
					{
						finisherArray.PushBack('man_finisher_01_rp');
						headtakerEffect.SetBeheadEffectActive(true);
					}
				return finisherArray;
			}
		}
		else
		{
			switch(direction)
			{
				case 'Left':
					if( !headtakerEffect )
					{
						finisherArray.PushBack('man_finisher_02_lp');
						finisherArray.PushBack('man_finisher_07_lp');
						finisherArray.PushBack('man_finisher_dlc_arm_rp');
					}
					else
					{
						finisherArray.PushBack('man_finisher_02_lp');
						finisherArray.PushBack('man_finisher_07_lp');
						headtakerEffect.SetBeheadEffectActive(true);
					}
				return finisherArray;
				
				case 'Right':
					finisherArray.PushBack('man_finisher_dlc_head_rp');
					headtakerEffect.SetBeheadEffectActive(true);
				return finisherArray;
				
				case 'Forward':
					finisherArray.PushBack('man_finisher_dlc_neck_rp');
					headtakerEffect.SetBeheadEffectActive(true);
				return finisherArray;
				
				case 'Back':
					finisherArray.PushBack('man_finisher_dlc_legs_rp');
					finisherArray.PushBack('man_finisher_dlc_torso_rp');
				return finisherArray;
				
				case 'Static':
					if( !headtakerEffect )
					{
						finisherArray.PushBack('man_finisher_01_rp');
						finisherArray.PushBack('man_finisher_03_rp');
						finisherArray.PushBack('man_finisher_05_rp');
					}
					else
					{
						finisherArray.PushBack('man_finisher_01_rp');
						headtakerEffect.SetBeheadEffectActive(true);
					}
				return finisherArray;
			}
		}
	}
	
	private var numberOfYrdens : int;
	private var slowdownID : int;
	private var isSlowdownActive : bool;
	default slowdownID = -1;
	public function EnchantedGlyphsSkill( yrden : W3YrdenEntity, activate : bool, entity : CEntity )
	{
		var witcher : W3PlayerWitcher;
		var npc : CNewNPC;
		var slowdownAmount, shakeAmount : float;
		var fx : CEntity;
		
		witcher = (W3PlayerWitcher)entity;
		npc = (CNewNPC)entity;
		
		if( activate )
		{
			if( witcher.GetSignOwner().CanUseSkill(S_Magic_s16, (W3SignEntity)yrden) )
			{
				if( npc )
				{
					npc.SoundEvent('sign_yrden_shock_activate');
					fx = npc.CreateFXEntityAtPelvis('mutation1_hit', true);
					fx.PlayEffect('mutation_1_hit_yrden');
				}
				else
				if( witcher )
				{
					if( isSlowdownActive )
					{
						numberOfYrdens += 1;
					}
					else
					{
						numberOfYrdens = 1;
						isSlowdownActive = true;
						shakeAmount = 0.05f * witcher.GetSignOwner().GetSkillLevel(S_Magic_s16, (W3SignEntity)yrden);
						slowdownAmount = 1 - 0.05f * witcher.GetSignOwner().GetSkillLevel(S_Magic_s16, (W3SignEntity)yrden);
						fx = witcher.CreateFXEntityAtPelvis('mutation2_critical', true);
						fx.PlayEffect('critical_yrden');
						theGame.SetTimeScale(slowdownAmount, theGame.GetTimescaleSource(ETS_Yrden), theGame.GetTimescalePriority(ETS_Yrden));
						slowdownID = witcher.SetAnimationSpeedMultiplier(1 + (1 - slowdownAmount), slowdownID);
						GCameraShake(shakeAmount);
					}
				}
			}
		}
		else
		{
			if( witcher && isSlowdownActive )
			{
				if( numberOfYrdens > 1 )
				{
					numberOfYrdens -= 1;
				}
				else
				{
					numberOfYrdens = 0;
					isSlowdownActive = false;
					GetWitcherPlayer().ResetAnimationSpeedMultiplier(slowdownID);
					theGame.RemoveTimeScale(theGame.GetTimescaleSource(ETS_Yrden));
					GCameraShake(0.075f);
				}
			}
		}
	}
	
	public function ForceEndGlyphsSkill()
	{
		if( numberOfYrdens < 1 )
		{
			isSlowdownActive = false;
			GetWitcherPlayer().ResetAnimationSpeedMultiplier(slowdownID);
			theGame.RemoveTimeScale(theGame.GetTimescaleSource(ETS_Yrden));
		}
	}
	
	public function EnchantedGlyphsAlt( action : W3DamageAction, yrdenEntity : W3YrdenEntity )
	{
		var slowdownEffect : SCustomEffectParams;
		var witcher : W3PlayerWitcher;
		var actorVictim : CActor;
		var skillLevel, staggerChance : int;
		var fx : CEntity;
		
		witcher = GetWitcherPlayer();
		actorVictim = ((CActor)action.victim);
		if( witcher && witcher.GetSignOwner().CanUseSkill(S_Magic_s16, (W3SignEntity)yrdenEntity) )
		{
			skillLevel = witcher.GetSignOwner().GetSkillLevel(S_Magic_s16, (W3SignEntity)yrdenEntity);
			slowdownEffect.effectType = EET_Slowdown;
			slowdownEffect.creator = witcher;
			slowdownEffect.sourceName = "S_Magic_s16";
			slowdownEffect.duration = 1.5f * skillLevel;
			slowdownEffect.effectValue.valueAdditive = 0.02f * skillLevel;
			actorVictim.AddEffectCustom(slowdownEffect);
			
			staggerChance = 3 * skillLevel;
			if( !actorVictim.IsHuge() && RandRange(100, 0) < staggerChance )
				action.AddEffectInfo(EET_Stagger);
			
			fx = actorVictim.CreateFXEntityAtPelvis('mutation2_critical', true);
			fx.PlayEffect('critical_yrden');
			fx.PlayEffect('critical_yrden');
			fx = actorVictim.CreateFXEntityAtPelvis('mutation1_hit', true);
			fx.PlayEffect('mutation_1_hit_yrden');
			fx.PlayEffect('mutation_1_hit_yrden');
		}
	}
	
	public function CombustionEffect( action : W3DamageAction )
	{
		var witcher : W3PlayerWitcher;
		var actorVictim : CActor;
		var fx : CEntity;
		
		witcher = GetWitcherPlayer();
		actorVictim = ((CActor)action.victim);
		if( action.attacker == witcher && witcher.GetSignOwner().CanUseSkill(S_Magic_s07, ((W3IgniProjectile)action.causer).GetSignEntity()) && (W3IgniProjectile)action.causer )
		{
			if( !((W3IgniProjectile)action.causer).IsProjectileFromChannelMode() )
			{
				theGame.GetSurfacePostFX().AddSurfacePostFXGroup(actorVictim.GetWorldPosition(), 0.5f, 40, 10, 5, 1);
				actorVictim.AddTimer('Runeword1DisableFireFX', 4.f);
				actorVictim.PlayEffect('critical_burning');
				fx = actorVictim.CreateFXEntityAtPelvis('mutation2_critical', true);
				fx.PlayEffect('critical_igni');
				fx = actorVictim.CreateFXEntityAtPelvis('mutation1_hit', true);
				fx.PlayEffect('mutation_1_hit_igni');
			}
		}
	}
	
	private var getShouldIgniExplode : bool;
	public function CombustionSkill( action : W3DamageAction )
	{
		var burning : SCustomEffectParams;
		var witcher : W3PlayerWitcher;
		var actors : array<CActor>;
		var actorVictim : CActor;
		var fx : CEntity;
		var i, targets, skillLevel : int;
		var sp : SAbilityAttributeValue;
		
		witcher = GetWitcherPlayer();
		actorVictim = ((CActor)action.victim);
		if( action.attacker == witcher && witcher.GetSignOwner().CanUseSkill(S_Magic_s07, ((W3IgniProjectile)action.causer).GetSignEntity()) && (W3IgniProjectile)action.causer )
		{
			if( ((W3IgniProjectile)action.causer).IsProjectileFromChannelMode() )
			{
				theGame.GetSurfacePostFX().AddSurfacePostFXGroup(actorVictim.GetWorldPosition(), 0.5f, 40, 10, 5, 1);
				actorVictim.AddTimer('Runeword1DisableFireFX', 4.f);
				actorVictim.PlayEffect('critical_burning');
				fx = actorVictim.CreateFXEntityAtPelvis('mutation2_critical', true);
				fx.PlayEffect('critical_igni');
				fx = actorVictim.CreateFXEntityAtPelvis('mutation1_hit', true);
				fx.PlayEffect('mutation_1_hit_igni');
			}
			
			getShouldIgniExplode = false;
			sp = ((W3IgniProjectile)action.causer).GetSignEntity().GetTotalSignIntensity();
			skillLevel = witcher.GetSignOwner().GetSkillLevel(S_Magic_s07, ((W3IgniProjectile)action.causer).GetSignEntity());
			if( RandRange(100, 0) < (12 * skillLevel * sp.valueMultiplicative) )
			{
				getShouldIgniExplode = true;
				GCameraShake(0.08f * skillLevel);
				targets = (skillLevel / 2) + RoundMath(sp.valueMultiplicative); 
				actors = GetActorsInRange(actorVictim, 8, targets,, true);
				burning.effectType = EET_Burning;
				burning.creator = witcher;
				burning.sourceName = "S_Magic_s07";
				burning.duration = 0.7f * skillLevel * sp.valueMultiplicative;
				action.SetForceExplosionDismemberment();
				
				for(i=0; i<actors.Size(); i+=1)
				{
					if( !((W3PlayerWitcher)actors[i]) && !actors[i].HasBuff(EET_Burning) )
					{
						burning.effectValue.valueAdditive = 30.f * skillLevel * sp.valueMultiplicative;
						actors[i].IncBurnCounter();
						actors[i].AddEffectCustom(burning);
						actors[i].PlayEffect('demonic_possession');
						((CNewNPC)actors[i]).AddTimer('StopPossessionEffect', 1.f, false);
					}
				}
			}
		}
	}
	
	public function QuenJoltSkill( quen : W3QuenEntity )
	{
		var witcher : W3PlayerWitcher;
		var shock : W3DamageAction;
		var target : CActor;
		var damage : float;
		var i, skillLevel : int;
		var fx : CEntity;
		var sp, min, max : SAbilityAttributeValue;
		
		witcher = GetWitcherPlayer();
		if( witcher && witcher.GetSignOwner().CanUseSkill(S_Magic_s15, (W3SignEntity)quen) )
		{
			target = witcher.GetTarget();
			if( !target || VecDistanceSquared(witcher.GetWorldPosition(), target.GetWorldPosition()) > 49 || GetAttitudeBetween(target, witcher) == AIA_Friendly )
				return;
			
			shock = new W3DamageAction in theGame.damageMgr;
			shock.Initialize(witcher, target, quen, 'S_Magic_s15', EHRT_Heavy, CPS_SpellPower, false, false, true, false);	
			
			skillLevel = witcher.GetSignOwner().GetSkillLevel(S_Magic_s15, (W3SignEntity)quen);
			sp = ((W3SignEntity)quen).GetTotalSignIntensity();
			damage = 155.f * skillLevel * sp.valueMultiplicative;
			if( witcher.IsSetBonusActive(EISB_Bear_2) )
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue(GetSetBonusAbility(EISB_Bear_2), 'quen_dmg_boost', min, max);
				damage *= 1 + min.valueMultiplicative;						
			}
			
			shock.AddDamage(theGame.params.DAMAGE_NAME_SHOCK, damage);
			shock.SetForceExplosionDismemberment();
			shock.SetCannotReturnDamage(true);
			shock.SetCanPlayHitParticle(true);
			
			shock.SetHitEffect('hit_electric_quen');
			shock.SetHitEffect('hit_electric_quen', true);
			shock.SetHitEffect('hit_electric_quen', false, true);
			shock.SetHitEffect('hit_electric_quen', true, true);
			fx = target.CreateFXEntityAtPelvis('mutation2_critical', true);
			fx.PlayEffect('critical_quen');
			fx = target.CreateFXEntityAtPelvis('mutation1_hit', true);
			fx.PlayEffect('mutation_1_hit_quen');
			GCameraShake(0.08f * skillLevel);
			
			theGame.damageMgr.ProcessAction(shock);
			delete shock;
		}
	}
	
	public function GetSignSkillDismember( action : W3DamageAction ) : bool
	{
		if( (W3PlayerWitcher)action.attacker && (W3IgniProjectile)action.causer /*&& !((W3IgniProjectile)action.causer).GetSignEntity().IsAlternateCast()*/ && ((W3PlayerWitcher)action.attacker).GetSignOwner().CanUseSkill(S_Magic_s07, ((W3IgniProjectile)action.causer).GetSignEntity()) && getShouldIgniExplode )
			return true;
		else
		if( (W3YrdenEntityStateYrdenShock)action.causer && ((W3PlayerWitcher)action.attacker).GetSignOwner().CanUseSkill(S_Magic_s16, (W3SignEntity)(((W3YrdenEntityStateYrdenShock)action.causer).GetParent())) )
			return true;
		else
		if( (W3QuenEntity)action.causer && ((W3PlayerWitcher)action.attacker).GetSignOwner().CanUseSkill(S_Magic_s15, (W3QuenEntity)action.causer) )
			return true;
		
		return false;
	}
	
	public function GetSkillDismemberType( action : W3DamageAction ) : EDismembermentEffectTypeFlags
	{
		if( (W3PlayerWitcher)action.attacker && (W3IgniProjectile)action.causer && ((W3PlayerWitcher)action.attacker).GetSignOwner().CanUseSkill(S_Magic_s07, ((W3IgniProjectile)action.causer).GetSignEntity()) && getShouldIgniExplode )
			return DETF_Igni;
		else
		if( (W3YrdenEntityStateYrdenShock)action.causer && ((W3PlayerWitcher)action.attacker).GetSignOwner().CanUseSkill(S_Magic_s16, (W3SignEntity)(((W3YrdenEntityStateYrdenShock)action.causer).GetParent())) )
			return DETF_Yrden;
		else
		if( (W3QuenEntity)action.causer && ((W3PlayerWitcher)action.attacker).GetSignOwner().CanUseSkill(S_Magic_s15, (W3QuenEntity)action.causer) )
			return DETF_Quen;
		
		return 0;
	}
	
	public function SeveranceRunewordStaminaAbsorb( attackAction : W3Action_Attack )
	{
		var witcher : W3PlayerWitcher;
		
		witcher = (W3PlayerWitcher)attackAction.attacker;
		if( witcher.HasAbility('Runeword 5 _Stats', true) || witcher.HasAbility('Runeword 2 _Stats', true) || witcher.HasAbility('Runeword 1 _Stats', true) )
		{
			if( witcher.IsInCombatAction_SpecialAttack() )
			{
				witcher.GainStat(BCS_Stamina, witcher.GetStatMax(BCS_Stamina) * 0.25f);
				witcher.PlayEffectSingle('drain_energy_caretaker_shovel');
			}
		}
	}
	
	public function SeveranceRunewordRangeExtension() : bool
	{
		var witcher : W3PlayerWitcher;
		
		witcher = GetWitcherPlayer();
		if( witcher.HasAbility('Runeword 2 _Stats', true) || witcher.HasAbility('Runeword 1 _Stats', true) )
		{
			return true;
		}
		return false;
	}
	
	public function SeveranceRunewordSignEffect( infusion : ESignType )
	{
		var infusionType : ESignType;
		var witcher : W3PlayerWitcher;
		var weaponEntity : CEntity;
		var slotMatrix : Matrix;
		var actors : array<CActor>;
		var i : int;
		
		witcher = GetWitcherPlayer();
		infusionType = infusion;
		if( witcher.HasAbility('Runeword 1 _Stats', true) )
		{
			if( witcher.IsInCombatAction_SpecialAttack() )
			{
				weaponEntity = witcher.GetInventory().GetItemEntityUnsafe(witcher.GetInventory().GetItemFromSlot('r_weapon'));
				if( witcher.IsInCombatAction_SpecialAttackHeavy() )
				{
					switch(infusionType)
					{
						case ST_Aard:
							weaponEntity.CalcEntitySlotMatrix('blood_fx_point', slotMatrix);
							witcher.CastDesiredSign(infusionType, true, false, MatrixGetTranslation(slotMatrix), witcher.GetWorldRotation());
							witcher.SetRunewordInfusionType(ST_None);
							weaponEntity.StopEffect('runeword_aard');
						break;
						
						case ST_Axii:
							weaponEntity.CalcEntitySlotMatrix('blood_fx_point', slotMatrix);
							witcher.CastDesiredSign(infusionType, true, false, MatrixGetTranslation(slotMatrix), witcher.GetWorldRotation());
							witcher.SetRunewordInfusionType(ST_None);
							weaponEntity.StopEffect('runeword_axii');
						break;
						
						case ST_Igni:
							weaponEntity.CalcEntitySlotMatrix('blood_fx_point', slotMatrix);
							witcher.CastDesiredSign(infusionType, true, false, MatrixGetTranslation(slotMatrix), witcher.GetWorldRotation());
							witcher.SetRunewordInfusionType(ST_None);
							weaponEntity.StopEffect('runeword_igni');
						break;
						
						case ST_Quen:
							witcher.PlayEffectSingle('drain_energy_caretaker_shovel');
							actors = witcher.GetNPCsAndPlayersInCone(3, VecHeading(witcher.GetHeadingVector()), 110, 20, , FLAG_OnlyAliveActors);
							witcher.GainStat(BCS_Stamina, witcher.GetStatMax(BCS_Stamina) * 0.15f);
							for(i=0; i<actors.Size(); i+=1)
							{
								if( !((W3PlayerWitcher)actors[i]) )
								{
									actors[i].DrainStamina(ESAT_FixedValue, actors[i].GetStat(BCS_Stamina) * 0.3f, 3.f);
									actors[i].AddEffectDefault(EET_Stagger, witcher, "Runeword 1", true);
								}
							}
							witcher.SetRunewordInfusionType(ST_None);
							weaponEntity.StopEffect('runeword_quen');
						break;
						
						case ST_Yrden:
							weaponEntity.CalcEntitySlotMatrix('blood_fx_point', slotMatrix);
							witcher.CastDesiredSign(infusionType, true, true, MatrixGetTranslation(slotMatrix), witcher.GetWorldRotation());
							witcher.SetRunewordInfusionType(ST_None);
							witcher.SetRunewordInfusionType(ST_None);
							weaponEntity.StopEffect('runeword_yrden');
							weaponEntity.StopEffect('runeword_yrden');
						break;
					}
				}
				else
				{
					switch(infusionType)
					{
						case ST_Aard:
							witcher.CastDesiredSign(infusionType, true, true, witcher.GetWorldPosition(), witcher.GetWorldRotation());
							witcher.SetRunewordInfusionType(ST_None);
							weaponEntity.StopEffect('runeword_aard');
						break;
						
						case ST_Axii:
							actors = GetActorsInRange(witcher, 5, 10,, true);
							ApplyAxiiEffect(witcher, actors);
							witcher.SetRunewordInfusionType(ST_None);
							weaponEntity.StopEffect('runeword_axii');
						break;
						
						case ST_Igni:
							actors = GetActorsInRange(witcher, 5, 10,, true);
							ApplyIgniEffect(witcher, actors);
							witcher.SetRunewordInfusionType(ST_None);
							weaponEntity.StopEffect('runeword_igni');
						break;
						
						case ST_Quen:
							witcher.PlayEffectSingle('drain_energy_caretaker_shovel');
							actors = witcher.GetNPCsAndPlayersInCone(3, VecHeading(witcher.GetHeadingVector()), 110, 20, , FLAG_OnlyAliveActors);
							witcher.GainStat(BCS_Stamina, witcher.GetStatMax(BCS_Stamina) * 0.15f);
							for(i=0; i<actors.Size(); i+=1)
							{
								if( !((W3PlayerWitcher)actors[i]) )
								{
									actors[i].DrainStamina(ESAT_FixedValue, actors[i].GetStat(BCS_Stamina) * 0.3f, 3.f);
									actors[i].AddEffectDefault(EET_Stagger, witcher, "Runeword 1", true);
								}
							}
							witcher.SetRunewordInfusionType(ST_None);
							weaponEntity.StopEffect('runeword_quen');
						break;
						
						case ST_Yrden:
							weaponEntity.CalcEntitySlotMatrix('blood_fx_point', slotMatrix);
							witcher.CastDesiredSign(infusionType, true, false, MatrixGetTranslation(slotMatrix), witcher.GetWorldRotation());
							witcher.SetRunewordInfusionType(ST_None);
							weaponEntity.StopEffect('runeword_yrden');
						break;
					}
				}
			}
			witcher.infusionCooldown = true;
			witcher.AddTimer('InfusionCooldown', 1.5f, false);
		}
	}
	
	public function ApplyAxiiEffect( witcher : W3PlayerWitcher, actors : array<CActor> )
	{
		var fx : CEntity;
		var i : int;
		
		fx = witcher.CreateFXEntityAtPelvis('glyphword_10_18', true);
		fx.PlayEffect('out');
		
		for(i=0; i<actors.Size(); i+=1)
		{
			if( witcher != actors[i] && RandRange(100, 0) > 50 )
			{
				actors[i].AddEffectDefault(EET_Confusion, witcher, "Runeword 2", true);
				fx = actors[i].CreateFXEntityAtPelvis('glyphword_10_18', true);
				fx.PlayEffect('axii_extra_time');
				fx.PlayEffect('in');
			}
		}
	}
	
	public function ApplyIgniEffect( witcher : W3PlayerWitcher, actors : array<CActor> )
	{
		var fx : CEntity;
		var i : int;
		
		for(i=0; i<actors.Size(); i+=1)
		{
			if( witcher != actors[i] && RandRange(100, 0) > 50 )
			{
				actors[i].PlayEffect('demonic_possession');
				((CNewNPC)actors[i]).AddTimer('StopPossessionEffect', 2.5f, false);
				actors[i].AddEffectDefault(EET_Burning, witcher, "Runeword 2", true);
				actors[i].IncBurnCounter();
				fx = actors[i].CreateFXEntityAtPelvis('mutation2_critical', true);
				fx.PlayEffect('critical_igni');
				fx = actors[i].CreateFXEntityAtPelvis('mutation1_hit', true);
				fx.PlayEffect('mutation_1_hit_igni');
			}
		}
	}
	
	public function ObliterationRunewordEffectAttack( attackAction : W3Action_Attack )
	{
		var witcher : W3PlayerWitcher;
		var fireEffect : W3DamageAction;
		var position : Vector;
		var totalDmg : float;
		var npc : CNewNPC;
		var weaponEntity, sparks, fx : CEntity;
		
		witcher = (W3PlayerWitcher)attackAction.attacker;
		if( witcher.HasAbility('Runeword 6 _Stats', true) || witcher.HasAbility('Runeword 10 _Stats', true) || witcher.HasAbility('Runeword 4 _Stats', true) )
		{
			if( attackAction.IsActionMelee() && attackAction.DealsAnyDamage() )
			{
				npc = (CNewNPC)attackAction.victim;
				if( witcher.HasAbility('Runeword 6 _Stats', true) )
					totalDmg = attackAction.GetDamageDealt() * 0.05f;
				else
				if( witcher.HasAbility('Runeword 10 _Stats', true) )
					totalDmg = attackAction.GetDamageDealt() * 0.065f;
				else
				if( witcher.HasAbility('Runeword 4 _Stats', true) )
					totalDmg = attackAction.GetDamageDealt() * 0.075f;
				
				fireEffect = new W3DamageAction in theGame;
				fireEffect.Initialize(attackAction.attacker, attackAction.victim, attackAction.causer, attackAction.GetBuffSourceName(), EHRT_None, CPS_Undefined, attackAction.IsActionMelee(), attackAction.IsActionRanged(), attackAction.IsActionWitcherSign(), attackAction.IsActionEnvironment());
				fireEffect.SetCannotReturnDamage(true);
				fireEffect.SetCanPlayHitParticle(false);
				fireEffect.SetHitAnimationPlayType(EAHA_ForceNo);		
				fireEffect.AddDamage(theGame.params.DAMAGE_NAME_FIRE, totalDmg);
				if( witcher.HasAbility('Runeword 6 _Stats', true) )
				{
					position = npc.GetWorldPosition();
					position.Z += 0.4f;
					sparks = theGame.CreateEntity((CEntityTemplate)LoadResource('sword_colision_fx'), position);
					sparks.PlayEffect('sparks');
					fx = npc.CreateFXEntityAtPelvis('mutation1_hit', true);
					fx.PlayEffect('mutation_1_hit_igni');
				}
				else
				if( witcher.HasAbility('Runeword 10 _Stats', true) )
				{
					attackAction.victim.AddTimer('Runeword1DisableFireFX', 1.f);	
					attackAction.victim.PlayEffectSingle('critical_burning');
					fx = npc.CreateFXEntityAtPelvis('mutation1_hit', true);
					fx.PlayEffect('mutation_1_hit_igni');
				}
				else
				if( witcher.HasAbility('Runeword 4 _Stats', true) )
				{
					fx = npc.CreateFXEntityAtPelvis('mutation2_critical', true);
					fx.PlayEffect('critical_igni');
					fx = npc.CreateFXEntityAtPelvis('mutation1_hit', true);
					fx.PlayEffect('mutation_1_hit_igni');
					npc.SoundEvent('sign_igni_charge_begin');
				}
				
				theGame.damageMgr.ProcessAction(fireEffect);
				delete fireEffect;
			}
		}
	}
	
	public function ObliterationRunewordEffectBlock( attackAction : W3Action_Attack )
	{
		var witcher : W3PlayerWitcher;
		var fireEffect : W3DamageAction;
		var totalDmg : float;
		var npc : CNewNPC;
		var matrix : Matrix;
		var sparks, fx, weapon : CEntity;
		
		witcher = (W3PlayerWitcher)attackAction.victim;
		if( witcher.HasAbility('Runeword 6 _Stats', true) )
		{
			weapon = witcher.GetInventory().GetItemEntityUnsafe(witcher.GetInventory().GetItemFromSlot('r_weapon'));
			weapon.CalcEntitySlotMatrix('blood_fx_point', matrix);
			sparks = theGame.CreateEntity((CEntityTemplate)LoadResource('sword_colision_fx'), MatrixGetTranslation(matrix));
			sparks.PlayEffect('sparks');
		}
		else
		if( witcher.HasAbility('Runeword 10 _Stats', true) || witcher.HasAbility('Runeword 4 _Stats', true) )
		{
			npc = (CNewNPC)attackAction.attacker;
			if( attackAction.IsParried() && attackAction.IsActionMelee() )
			{
				if( witcher.HasAbility('Runeword 10 _Stats', true) )
					totalDmg = 160.f;
				else
				if( witcher.HasAbility('Runeword 4 _Stats', true) )
					totalDmg = 220.f;
				
				fireEffect = new W3DamageAction in theGame;
				fireEffect.Initialize(attackAction.victim, attackAction.attacker, NULL, attackAction.GetBuffSourceName(), EHRT_Light, CPS_Undefined, false, false, false, true);
				fireEffect.SetCannotReturnDamage(true);
				fireEffect.SetCanPlayHitParticle(false);
				fireEffect.SetHitAnimationPlayType(EAHA_ForceNo);
				fireEffect.AddDamage(theGame.params.DAMAGE_NAME_FIRE, totalDmg);
				
				weapon = witcher.GetInventory().GetItemEntityUnsafe(witcher.GetInventory().GetItemFromSlot('r_weapon'));
				weapon.CalcEntitySlotMatrix('blood_fx_point', matrix);
				sparks = theGame.CreateEntity((CEntityTemplate)LoadResource('sword_colision_fx'), MatrixGetTranslation(matrix));
				sparks.PlayEffect('sparks');
				
				if( witcher.HasAbility('Runeword 10 _Stats', true) )
				{
					fx = npc.CreateFXEntityAtPelvis('mutation1_hit', true);
					fx.PlayEffect('mutation_1_hit_igni');
				}
				else
				{
					fx = npc.CreateFXEntityAtPelvis('mutation1_hit', true);
					fx.PlayEffect('mutation_1_hit_igni');
					attackAction.attacker.AddTimer('Runeword1DisableFireFX', 0.5f);	
					attackAction.attacker.PlayEffectSingle('critical_burning');
				}
				
				theGame.damageMgr.ProcessAction(fireEffect);
				delete fireEffect;
			}
		}
	}
	
	public function ObliterationRunewordLvl1Flame()
	{
		var witcher : W3PlayerWitcher;
		var weaponEntity : CEntity;
		
		witcher = GetWitcherPlayer();
		if( witcher.HasAbility('Runeword 6 _Stats', true) || witcher.HasAbility('Runeword 10 _Stats', true) )
		{
			weaponEntity = witcher.GetInventory().GetItemEntityUnsafe(witcher.GetInventory().GetItemFromSlot('r_weapon'));
			weaponEntity.PlayEffectSingle('runeword_igni');
			weaponEntity.StopAllEffectsAfter(0.5f);
		}
	}
	
	private var getShouldRunewordExplode : bool;
	public function ObliterationRunewordExplosion( attackAction : W3Action_Attack )
	{
		var damage : float;
		var witcher : W3PlayerWitcher;
		var actor : CActor;
		var fx : CEntity;
		var actors : array<CActor>;
		var explosion : W3DamageAction;
		var i : int;
		var effects : array<EEffectType>;
		
		witcher = (W3PlayerWitcher)attackAction.attacker;
		actor = (CActor)attackAction.victim;
		getShouldRunewordExplode = false;
		if( witcher && witcher.HasAbility('Runeword 4 _Stats', true) && attackAction.IsActionMelee() && RandRange(100, 0) < 50 )
		{
			GCameraShake(0.8f);
			fx = actor.CreateFXEntityAtPelvis('mutation2_critical', true);
			fx.PlayEffect('critical_igni');
			fx = actor.CreateFXEntityAtPelvis('mutation1_hit', true);
			fx.PlayEffect('mutation_1_hit_igni');
			actor.SoundEvent("bomb_dancing_star_explo");
			getShouldRunewordExplode = true;
			
			actors = GetActorsInRange(actor, 5, 20,, true);
			explosion = new W3DamageAction in theGame;
			damage = 1110.f;
			effects.PushBack(EET_Stagger);
			effects.PushBack(EET_LongStagger);
			for(i=0; i<actors.Size(); i+=1)
			{
				if( witcher != actors[i] )
				{
					fx = actors[i].CreateFXEntityAtPelvis('mutation1_hit', true);
					fx.PlayEffect('mutation_1_hit_igni');
					if( RandRange(2, 0) < 1 )
					{
						actors[i].AddTimer('Runeword1DisableFireFX', 5.f);
						actors[i].PlayEffectSingle('critical_burning');
					}
					else
					{
						fx = actor.CreateFXEntityAtPelvis('mutation2_critical', true);
						fx.PlayEffect('critical_igni');
					}
					explosion.Initialize(witcher, actors[i], NULL, attackAction.GetBuffSourceName(), EHRT_Heavy, CPS_Undefined, false, false, false, true);
					explosion.SetCannotReturnDamage(true);
					explosion.SetCanPlayHitParticle(true);
					explosion.AddEffectInfo(effects[RandRange(effects.Size(), 0)]);
					explosion.AddDamage(theGame.params.DAMAGE_NAME_FIRE, damage);
					theGame.damageMgr.ProcessAction(explosion);
				}
			}
			delete explosion;
		}
	}
	
	public function GetObliterationRunewordDism( action : W3DamageAction ) : bool
	{
		var witcher : W3PlayerWitcher;
		
		witcher = (W3PlayerWitcher)action.attacker;
		if( witcher && witcher.HasAbility('Runeword 4 _Stats', true) && action.IsActionMelee() && getShouldRunewordExplode )
			return true;
		
		return false;
	}
	
	public function GetObliterationDismType( action : W3DamageAction ) : EDismembermentEffectTypeFlags
	{
		var witcher : W3PlayerWitcher;
		
		witcher = (W3PlayerWitcher)action.attacker;
		if( witcher && witcher.HasAbility('Runeword 4 _Stats', true) && action.IsActionMelee() && getShouldRunewordExplode )
			return DETF_Igni;
		
		return 0;
	}
	
	public function ObliterationRunewordGroundFX( attackAction : W3Action_Attack )
	{
		var witcher : W3PlayerWitcher;
		
		witcher = (W3PlayerWitcher)attackAction.attacker;
		if( witcher.HasAbility('Runeword 6 _Stats', true) )
			theGame.GetSurfacePostFX().AddSurfacePostFXGroup(attackAction.victim.GetWorldPosition(), 0.5f, 40, 4.5, 5, 1);
		else
		if( witcher.HasAbility('Runeword 10 _Stats', true) )
			theGame.GetSurfacePostFX().AddSurfacePostFXGroup(attackAction.victim.GetWorldPosition(), 0.5f, 40, 6, 5, 1);
		else
		if( witcher.HasAbility('Runeword 4 _Stats', true) )
			theGame.GetSurfacePostFX().AddSurfacePostFXGroup(attackAction.victim.GetWorldPosition(), 0.5f, 40, 8, 5, 1);
	}
	
	public function GetShouldTargetExplode() : bool
	{
		return getShouldRunewordExplode || getShouldIgniExplode;
	}
	
	public function BereavementRunewordAttack( attackAction : W3Action_Attack )
	{
		var witcher : W3PlayerWitcher;
		var shockEffect : W3DamageAction;
		var position : Vector;
		var totalDmg : float;
		var npc : CNewNPC;
		var weaponEntity, sparks, fx : CEntity;
		
		witcher = (W3PlayerWitcher)attackAction.attacker;
		if( witcher.HasAbility('Runeword 11 _Stats', true) )
		{
			if( attackAction.IsActionMelee() )
			{
				npc = (CNewNPC)attackAction.victim;
				totalDmg = attackAction.GetDamageDealt() * 0.055f;
				
				shockEffect = new W3DamageAction in theGame;
				shockEffect.Initialize(attackAction.attacker, attackAction.victim, attackAction.causer, attackAction.GetBuffSourceName(), EHRT_None, CPS_Undefined, attackAction.IsActionMelee(), attackAction.IsActionRanged(), attackAction.IsActionWitcherSign(), attackAction.IsActionEnvironment());
				shockEffect.SetCannotReturnDamage(true);
				shockEffect.SetCanPlayHitParticle(false);
				shockEffect.SetHitAnimationPlayType(EAHA_ForceNo);
				shockEffect.AddDamage(theGame.params.DAMAGE_NAME_DIRECT, totalDmg);
				
				theGame.damageMgr.ProcessAction(shockEffect);
				delete shockEffect;
			}
		}
	}
	
	public function SetPerkArmorBonuses()
	{
		var item : SItemUniqueId;
		var armors : array<SItemUniqueId>;
		var light, medium, heavy, i, cnt, j : int;
		var armorType : EArmorType;
		var witcher : W3PlayerWitcher;
		var inventory : CInventoryComponent;
		var skills : array<ESkill>;
		
		skills.PushBack(S_Perk_05);
		skills.PushBack(S_Perk_06);
		skills.PushBack(S_Perk_07);
		
		witcher = GetWitcherPlayer();
		for(j=0; j<3; j+=1)
		{
			if( !witcher.CanUseSkill( skills[j] ) )
			{
				cnt = 0;
			}
			else
			{
				
				armors.Resize(4);
				if( witcher.GetItemEquippedOnSlot(EES_Armor, item) )
					armors[0] = item;
					
				if( witcher.GetItemEquippedOnSlot(EES_Boots, item) )
					armors[1] = item;
					
				if( witcher.GetItemEquippedOnSlot(EES_Pants, item) )
					armors[2] = item;
					
				if( witcher.GetItemEquippedOnSlot(EES_Gloves, item) )
					armors[3] = item;
				
				light = 0;
				medium = 0;
				heavy = 0;
				inventory = witcher.GetInventory();
				for(i=0; i<armors.Size(); i+=1)
				{
					armorType = inventory.GetArmorTypeOriginal(armors[i]);
					if(armorType == EAT_Light)
						light += 1;
					else if(armorType == EAT_Medium)
						medium += 1;
					else if(armorType == EAT_Heavy)
						heavy += 1;
				}
				
				if( skills[j] == S_Perk_05 )
					cnt = light;
				else
				if( skills[j] == S_Perk_06 )
					cnt = medium;
				else
					cnt = heavy;
			}
			
			UpdateArmorPerks(skills[j], cnt);
			witcher.UpdateEncumbrance();
		}
	}
	
	private function UpdateArmorPerks( skill : ESkill, count : int )
	{
		var abilityName : name;
		var charStats : CCharacterStats;
		
		charStats = GetWitcherPlayer().GetCharacterStats();
		abilityName = GetWitcherPlayer().GetSkillAbilityName(skill);
		charStats.RemoveAbilityAll( abilityName );
		if( count > 0 )
			charStats.AddAbilityMultiple( abilityName, count );
	}
	
	public function IsUsingSecondaryWeapon() : bool
	{
		var inv : CInventoryComponent = GetWitcherPlayer().GetInventory();
		
		return inv.ItemHasTag(inv.GetItemFromSlot('r_weapon'), 'SecondaryWeapon');
	}
	
	public function IsUsingBattleAxe() : bool
	{
		var inv : CInventoryComponent = GetWitcherPlayer().GetInventory();
		
		return inv.ItemHasTag(inv.GetItemFromSlot('r_weapon'), 'TypeBattleaxe');
	}
	
	public function IsUsingBattleMace() : bool
	{
		var inv : CInventoryComponent = GetWitcherPlayer().GetInventory();
		
		return inv.ItemHasTag(inv.GetItemFromSlot('r_weapon'), 'TypeBattlemace');
	}
	
	public function IsUsingShield() : W3DLCShield
	{
		var inv : CInventoryComponent;
		
		inv = GetWitcherPlayer().GetInventory();
		
		return (W3DLCShield)inv.GetItemEntityUnsafe(inv.GetItemFromSlot('l_weapon'));
	}
	
	public function CripplingShotEffects( action : W3DamageAction )
	{
		var witcher : W3PlayerWitcher;
		var skillLevel : int;
		
		witcher = (W3PlayerWitcher)action.attacker;
		skillLevel = witcher.GetSkillLevel(S_Sword_s12);
		if( witcher && action.IsActionRanged() && action.DealsAnyDamage() && skillLevel )
		{
			if( RandRange(100, 0) <= RoundMath(7.5f * skillLevel) )
				action.AddEffectInfo(EET_Bleeding);
			
			if( skillLevel > 1 && action.IsCriticalHit() )
			{
				if( RandRange(100, 0) <= 33.4f * (skillLevel - 1) && !action.victim.HasTag('NoImmobilize') )
					action.AddEffectInfo(EET_Immobilized);
			}
		}
	}
	
	private var compatibleDamage : name;
	private var infusionDamage, dischargeTime : float;
    private var dimeritiumInfusion : EArmorInfusionType;
    
    default dischargeTime = 15;
    default dimeritiumInfusion = EAIT_None;
    
    private function InfusionTypeToDamage( infusion : EArmorInfusionType ) : name
    {
		switch(infusion)
		{
			case EAIT_Shock :	return theGame.params.DAMAGE_NAME_SHOCK;
			case EAIT_Fire :	return theGame.params.DAMAGE_NAME_FIRE;
			case EAIT_Ice :		return theGame.params.DAMAGE_NAME_FROST;
			default: return 'none';
		}
    }
    
    private function InfusionTypeToEffect( infusion : EArmorInfusionType ) : name
    {
		switch(infusion)
		{
			case EAIT_Shock :	return 'runeword_yrden';
			case EAIT_Fire :	return 'runeword_igni';
			case EAIT_Ice :		return 'runeword_aard';
			default: return 'none';
		}
    }
    
    private function SignTypeToInfusion( signType : ESignType ) : EArmorInfusionType
    {
		switch(signType)
		{
			case ST_Yrden :
			case ST_Quen :		return EAIT_Shock;
			
			case ST_Igni :		return EAIT_Fire;
			
			case ST_Axii :
			case ST_Aard :		return EAIT_Ice;
			
			case ST_None :
			default : return EAIT_None;
		}
    }
    
    private function IsDamageTypeCompatible( action : W3DamageAction ) : bool
    {
		var i, DTCount : int;
		var damages : array <SRawDamage>;
		
		DTCount = action.GetDTs(damages);
		for(i=0; i<DTCount; i+=1)
		{
			switch(damages[i].dmgType)
			{
				case theGame.params.DAMAGE_NAME_ELEMENTAL :
				case theGame.params.DAMAGE_NAME_SHOCK :
				case theGame.params.DAMAGE_NAME_FIRE :
				case theGame.params.DAMAGE_NAME_FROST :
					compatibleDamage = damages[i].dmgType; return true;
			}
		}
		
		return false;
    }
    
    private function PlayInfusionHitEffect( type : EArmorInfusionType, victim : CEntity )
    {
		var fx : CEntity;
		
		switch(type)
		{
			case EAIT_Shock :
				fx = ((CActor)victim).CreateFXEntityAtPelvis('mutation2_critical', true);
				fx.PlayEffect('critical_yrden');
				fx = ((CActor)victim).CreateFXEntityAtPelvis('mutation1_hit', true);
				fx.PlayEffect('mutation_1_hit_yrden');
			break;
			
			case EAIT_Fire :
				fx = ((CActor)victim).CreateFXEntityAtPelvis('mutation2_critical', true);
				fx.PlayEffect('critical_igni');
				fx = ((CActor)victim).CreateFXEntityAtPelvis('mutation1_hit', true);
				fx.PlayEffect('mutation_1_hit_igni');
				victim.AddTimer('Runeword1DisableFireFX', 2.5f);
				victim.PlayEffect('critical_burning');
			break;
			
			case EAIT_Ice :
				fx = ((CActor)victim).CreateFXEntityAtPelvis('mutation1_hit', true);
				fx.PlayEffect('mutation_1_hit_aard');
				victim.PlayEffect('critical_frozen');
				((CNewNPC)victim).AddTimer( 'StopMutation6FX', 4.f );
			break;
		}
    }
    
    private function SetInfusionType( type : EArmorInfusionType )
    {
		dimeritiumInfusion = type;
    }
    
    private function GetInfusionType() : EArmorInfusionType
    {
		return dimeritiumInfusion;
    }
    
    private function GetInfusionDamage() : float
    {
		return infusionDamage;
    }
    
	private function SignTypeToSkillType( signType : ESignType ) : ESkill
	{
		switch(signType)
		{
			case ST_Aard :		return S_Magic_1;
			case ST_Igni :		return S_Magic_2;
			case ST_Yrden :		return S_Magic_3;
			case ST_Quen : 		return S_Magic_4;
			case ST_Axii :		return S_Magic_5;
			default: return S_SUndefined;
		}
	}
	
    public function SetInfusionVariables( player : W3PlayerWitcher, signType : ESignType )
    {
		var spellPower : SAbilityAttributeValue;
		var infusionType : EArmorInfusionType;
		
		if( player.IsSetBonusActive(EISB_Dimeritium2) && ((W3Effect_DimeritiumCharge)player.GetBuff(EET_DimeritiumCharge, "DimeritiumSetBonus")).GetDisplayCount() >= 6 )
		{
			spellPower = player.GetTotalSignSpellPower(SignTypeToSkillType(signType));
			infusionDamage = 240.f * spellPower.valueMultiplicative;
			infusionType = SignTypeToInfusion(signType);
			
			SetInfusionType(infusionType);
			PlayInfusionEffect();
			player.AddTimer('RemoveWeaponCharge', dischargeTime, , , , , true);
		}
    }
    
    public function DealInfusionDamage( action : W3DamageAction )
    {
		var infusionDamage : W3DamageAction;
		var infusionType : EArmorInfusionType;
		var surface	: CGameplayFXSurfacePost;
		
		infusionType = GetInfusionType();
		if( (W3PlayerWitcher)action.attacker && action.IsActionMelee() && infusionType != EAIT_None && ((W3PlayerWitcher)action.attacker).IsSetBonusActive(EISB_Dimeritium2) )
		{
			infusionDamage = new W3DamageAction in theGame;
			infusionDamage.Initialize( action.attacker, action.victim, action.causer, action.GetBuffSourceName(), EHRT_Heavy, CPS_Undefined, action.IsActionMelee(), action.IsActionRanged(), action.IsActionWitcherSign(), action.IsActionEnvironment() );
			infusionDamage.SetCannotReturnDamage(true);
			infusionDamage.SetCanPlayHitParticle(false);
			infusionDamage.SetHitAnimationPlayType(EAHA_ForceYes);
			infusionDamage.AddDamage(InfusionTypeToDamage(infusionType), GetInfusionDamage());
			
			surface = theGame.GetSurfacePostFX();
			switch(infusionType)
			{
				case EAIT_Shock :
					
				break;
				
				case EAIT_Fire :
					surface.AddSurfacePostFXGroup(action.victim.GetWorldPosition(), 5, 40, 10, 4, 1);
				break;
				
				case EAIT_Ice :
					surface.AddSurfacePostFXGroup(action.victim.GetWorldPosition(), 2, 40, 6, 3.5f, 0);
				break;
			}
			
			RemoveInfusionEffects();
			PlayInfusionHitEffect(infusionType, action.victim);
			PlayInfusionSound(infusionType, (CActor)GetWitcherPlayer());
			theGame.damageMgr.ProcessAction(infusionDamage);
			delete infusionDamage;
		}
    }
    
    public function PlayInfusionSound( type : EArmorInfusionType, actor : CActor )
    {
		switch(type)
		{
			case EAIT_Shock :
				actor.SoundEvent('sign_yrden_shock_activate');
			break;
			
			case EAIT_Fire :
				actor.SoundEvent('sign_igni_charge_begin');
			break;
			
			case EAIT_Ice :
				actor.SoundEvent('bomb_white_frost_explo');
			break;
		}
    }
    
    public function RemoveInfusionEffects()
    {
		var weapon : CItemEntity;
		var inv : CInventoryComponent;
		
		inv = GetWitcherPlayer().GetInventory();
		weapon = inv.GetItemEntityUnsafe(inv.GetItemFromSlot('r_weapon'));
		weapon.StopEffect('runeword_aard');
		weapon.StopEffect('runeword_igni');
		weapon.StopEffect('runeword_yrden');
		SetInfusionType(EAIT_None);
    }
    
    public function PlayInfusionEffect()
    {
		var weapon : CItemEntity;
		var inv : CInventoryComponent;
		var infusionType : EArmorInfusionType;
		
		infusionType = GetInfusionType();
		if( infusionType != EAIT_None )
		{
			inv = GetWitcherPlayer().GetInventory();
			weapon = inv.GetItemEntityUnsafe(inv.GetItemFromSlot('r_weapon'));
			weapon.StopEffect('runeword_aard');
			weapon.StopEffect('runeword_igni');
			weapon.StopEffect('runeword_yrden');
			weapon.PlayEffect(InfusionTypeToEffect(infusionType));
		}
    }
    
    public function BlockingStaggerImmunityCheck( playerVictim : CR4Player, out action : W3DamageAction, attackAction : W3Action_Attack ) : bool
    {
		if( playerVictim && attackAction && attackAction.IsActionMelee() && attackAction.IsParried() && (((W3PlayerWitcher)playerVictim).IsSetBonusActive(EISB_Gothic1) || ((W3PlayerWitcher)playerVictim).IsSetBonusActive(EISB_Bear_1)) )
			return true;
		
		return false;
    }
    
    public function BlockingStaggerImmunity( playerVictim : CR4Player, out action : W3DamageAction, attackAction : W3Action_Attack )
    {
		if( playerVictim && attackAction && attackAction.IsActionMelee() && attackAction.IsParried() && ((W3PlayerWitcher)playerVictim).IsSetBonusActive(EISB_Gothic1) )
		{
			action.SetHitAnimationPlayType(EAHA_ForceNo);
			action.processedDmg.vitalityDamage /= 2;
		}
    }
    
    public function KnockdownNegation( actor : CActor, out effectType : EEffectType )
    {
		var witcher : W3PlayerWitcher;
		
		witcher = GetWitcherPlayer();
		if( actor == witcher && witcher.IsSetBonusActive(EISB_Gothic2) )
		{
			if( effectType == EET_Knockdown )
				effectType = EET_Stagger;
			else
			if( effectType == EET_HeavyKnockdown )
				effectType = EET_LongStagger;
		}
    }
    
    public function ShouldIgniStagger( action : W3DamageAction ) : bool
    {
		var npcVictim : CNewNPC;
		npcVictim = (CNewNPC)action.victim;
		
		return !(npcVictim.IsHuge() || RandRange(100,0) > 30 || npcVictim.GetOpponentType() == MC_Insectoid);
    }
    
    public function HandleAttackSpamming( attackAction : W3Action_Attack, playerAttacker : CR4Player, actorVictim : CActor )
    {
		var hitReactionType : EHitReactionType;
		var damageAction : W3DamageAction;
		
		if( playerAttacker && actorVictim && attackAction && attackAction.IsParried() && playerAttacker.IsPlayerSpamming() )
		{
			if( playerAttacker.HasBuff(EET_Stagger) || playerAttacker.HasBuff(EET_LongStagger) || playerAttacker.HasBuff(EET_Knockdown) )
				return;
			
			playerAttacker.SetPlayerSpamming(false);
			playerAttacker.SetPlayerAttacking(false);
			damageAction = new W3DamageAction in theGame.damageMgr;
			damageAction.Initialize(NULL, playerAttacker, NULL, "AttackSpamming", EHRT_Heavy, CPS_Undefined, false, false, false, true);
			damageAction.SetHitAnimationPlayType(EAHA_ForceYes);
			damageAction.SetCannotReturnDamage(true);
			damageAction.SetSuppressHitSounds(true);
			damageAction.SetCanPlayHitParticle(false);
			theGame.damageMgr.ProcessAction(damageAction);
			delete damageAction;
		}
    }
    
    public function PlayHitDamageEffects( attackAction : W3Action_Attack, dmgInfos : array<SRawDamage>, playerAttacker : CR4Player, actorVictim : CActor )
    {
		var template : CEntityTemplate;
		var pos : Vector;
		var fx : CEntity;
		var i : int;
		
		if( playerAttacker && actorVictim && attackAction && attackAction.IsActionMelee() && attackAction.DealsAnyDamage() && attackAction.GetAttackName() != 'geralt_kick_special' )
		{
			for(i=0; i<dmgInfos.Size(); i+=1)
			{
				if( dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_ELEMENTAL )
				{
					actorVictim.PlayEffect('yrden_shock');
				}
				else
				if( dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_SHOCK )
				{
					actorVictim.SoundEvent("sign_yrden_shock_activate");
					template = (CEntityTemplate)LoadResource('sword_colision_fx');
					pos = actorVictim.GetWorldPosition();
					pos.Z += 0.4f;
					fx = theGame.CreateEntity(template, pos);
					fx.PlayEffect('sparks');
					pos.X += 0.1f;
					fx = theGame.CreateEntity(template, pos);
					fx.PlayEffect('sparks');
					pos.Y -= 0.1f;
					fx = theGame.CreateEntity(template, pos);
					fx.PlayEffect('sparks');
					pos.X -= 0.2f;
					fx = theGame.CreateEntity(template, pos);
					fx.PlayEffect('sparks');
					pos.Y -= 0.2f;
					fx = theGame.CreateEntity(template, pos);
					fx.PlayEffect('sparks');
					pos.Y += 0.2f;
					fx = theGame.CreateEntity(template, pos);
					fx.PlayEffect('sparks');
					pos.X += 0.2f;
					fx = theGame.CreateEntity(template, pos);
					fx.PlayEffect('sparks');
				}
				else
				if( dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_FIRE )
				{
					actorVictim.AddTimer('Runeword1DisableFireFX', 0.25f);
					actorVictim.PlayEffect('critical_burning');
				}
				else
				if( dmgInfos[i].dmgType == theGame.params.DAMAGE_NAME_PHYSICAL )
				{
					((CNewNPC)actorVictim).AddTimer('StopMutation6FX', 0.6f);
					actorVictim.PlayEffect('critical_frozen');
				}
			}
		}
    }
    
    public function GetSafeDodgeAngle() : int
    {
		var angle : int;
		
		angle = 90 + (int)(CalculateAttributeValue(GetWitcherPlayer().GetAttributeValue('safe_dodge_angle_bonus')));
		if( GetWitcherPlayer().IsSetBonusActive(EISB_LightArmor) )
			angle += 10;
			
		return angle;
    }
    
    var linkedActors : array<CActor>;
    public function CacheAxiiLinkActors( finalTargets : array<CActor> )
    {
		var i : int;
		linkedActors.Clear();
		linkedActors.Resize(finalTargets.Size());
		for(i=0; i<finalTargets.Size(); i+=1)
			linkedActors[i] = finalTargets[i];
    }
    
    public function CullAxiiLinkActors( actor : CActor, effectInteraction : EEffectInteract )
    {
		var idx : int;
		if( effectInteraction == EI_Deny )
		{
			idx = linkedActors.FindFirst(actor);
			linkedActors.EraseFast(idx);
		}
    }
    
    public function ProcessAxiiLink( action : W3DamageAction )
    {
		var axiiLinkReaction : W3DamageAction;
		var witcherAttacker : W3PlayerWitcher;
		var effectTypes : array<EEffectType>;
		var npcVictim : CNewNPC;
		var size, i : int;
		
		witcherAttacker = (W3PlayerWitcher)action.attacker;
		if( !witcherAttacker || action.GetBuffSourceName() == "AxiiLink" || !witcherAttacker.CanUseSkill(S_Magic_s18) )
			return;
		
		npcVictim = (CNewNPC)action.victim;
		if( !linkedActors.Contains(npcVictim) )
			return;
			
		for(i=0; i<linkedActors.Size(); i+=1)
		{
			if( linkedActors[i] == npcVictim || !linkedActors[i].IsAlive() || RandRange(100, 0) > witcherAttacker.GetSkillLevel(S_Magic_s18) * 12.f )
				continue;
				
			axiiLinkReaction = new W3DamageAction in theGame.damageMgr;
			axiiLinkReaction.Initialize(action.attacker, linkedActors[i], action.causer, "AxiiLink", action.GetHitReactionType(), CPS_Undefined, action.IsActionMelee(), action.IsActionRanged(), action.IsActionWitcherSign(), action.IsActionEnvironment());
			axiiLinkReaction.SetHitAnimationPlayType(EAHA_ForceYes);
			axiiLinkReaction.SetCanPlayHitParticle(false);
			axiiLinkReaction.SetCannotReturnDamage(true);
			axiiLinkReaction.SetSuppressHitSounds(true);
			
			action.GetEffectTypes(effectTypes);
			if( RandRange(100, 0) <= 30.f && (effectTypes.Contains(EET_Stagger) || effectTypes.Contains(EET_LongStagger) || effectTypes.Contains(EET_Knockdown)) )
			{
				axiiLinkReaction.SetHitAnimationPlayType(EAHA_ForceNo);
				axiiLinkReaction.AddEffectInfo(EET_Stagger);
			}
			theGame.damageMgr.ProcessAction(axiiLinkReaction);
			delete axiiLinkReaction;
		}
    }
}

exec function applypoison()
{
	thePlayer.GetTarget().AddEffectDefault(EET_Poison, thePlayer, "lulz", false);
}