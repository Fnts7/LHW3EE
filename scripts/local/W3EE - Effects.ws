class W3Effect_CombatAdrenaline extends CBaseGameplayEffect
{
	private var playerWitcher		: W3PlayerWitcher;
	private var currentAdrenaline 	: float;

	default currentAdrenaline = 0;
	default effectType = EET_CombatAdr;
	default isPositive = true;
	
	public function ManageAdrenaline( attackAction : W3Action_Attack )
	{
		var adrenalineGain : SAbilityAttributeValue;
		var adrenalineGainValue : float;
		
		if( !attackAction || attackAction.IsDoTDamage() )
			return;
		
		if( (W3PlayerWitcher)attackAction.attacker )
		{
			if( attackAction.DealsAnyDamage() && (attackAction.IsActionMelee() || attackAction.IsActionRanged()) )
			{
				adrenalineGain = playerWitcher.GetAttributeValue('focus_gain');
				adrenalineGainValue = RandRangeF(0.024f, 0.006f) * (adrenalineGain.valueAdditive + adrenalineGain.valueMultiplicative + adrenalineGain.valueBase + thePlayer.GetSkillLevel(S_Alchemy_s18) * 0.03f);
				
				if (playerWitcher.IsInCombatAction_SpecialAttackLight())
					adrenalineGainValue /= 1.5f;
				
				((W3Effect_SwordReachoftheDamned)playerWitcher.GetBuff(EET_SwordReachoftheDamned)).MultiplyAdrenaline(adrenalineGainValue);
				
				currentAdrenaline += adrenalineGainValue;
				currentAdrenaline = ClampF(currentAdrenaline, 0.f, GetMaximumAdrenaline());
			}
		}
		else
		if( (W3PlayerWitcher)attackAction.victim )
		{
			if( attackAction.IsCountered() )
			{
				adrenalineGain = playerWitcher.GetAttributeValue('focus_gain');
				adrenalineGainValue = RandRangeF(0.05f, 0.014f) * (adrenalineGain.valueAdditive + adrenalineGain.valueMultiplicative + adrenalineGain.valueBase + thePlayer.GetSkillLevel(S_Alchemy_s18) * 0.03f);
				
				currentAdrenaline += adrenalineGainValue;
				currentAdrenaline = ClampF(currentAdrenaline, 0.f, GetMaximumAdrenaline());
			}
			else
			if( attackAction.IsParried() )
			{
				if( attackAction.GetDamageDealt() > 1.f && (attackAction.GetHitAnimationPlayType() != EAHA_ForceNo || attackAction.HasBuff(EET_Stagger) || attackAction.HasBuff(EET_LongStagger) || attackAction.HasBuff(EET_Knockdown) || attackAction.HasBuff(EET_HeavyKnockdown)) )
					currentAdrenaline *= SavedAdrenalineRoll(false);
			}
			else
			if( attackAction.GetDamageDealt() > 1.f && (!((W3Effect_Toxicity)playerWitcher.GetBuff(EET_Toxicity)).isUnsafe || RandRange(100, 1) > (30 + 6 * playerWitcher.GetSkillLevel(S_Alchemy_s20)) ) )
			{
				currentAdrenaline *= SavedAdrenalineRoll(attackAction.WasPartiallyDodged());
			}
		}
	}
	
	private function SavedAdrenalineRoll( dodged : bool ) : float
	{
		var armorPieces : array<SArmorCount>;
		var savedAdrenaline : float;
		
		armorPieces = GetWitcherPlayer().GetArmorCountOrig();
		
		savedAdrenaline = (armorPieces[3].weighted * 6.0f + armorPieces[2].weighted * 3.0f) / 100.0f + RandF() - 0.5f;
		
		if (savedAdrenaline < 0)
		{
			if (dodged)
				return 0.667f;
			else
				return 0;
		}
			
		if (dodged)
			savedAdrenaline = 1.0f - ((1.0f - savedAdrenaline) * 0.333f);
			
		return savedAdrenaline;		
	}
	
	public function AddAdrenaline( value : float )
	{
		currentAdrenaline += value;
		currentAdrenaline = ClampF(currentAdrenaline, 0, GetMaximumAdrenaline());
	}
	
	public function RemoveAdrenaline( value : float )
	{
		currentAdrenaline -= value;
		currentAdrenaline = ClampF(currentAdrenaline, 0, GetMaximumAdrenaline());
	}
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		playerWitcher = GetWitcherPlayer();
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
	}
	
	private function GetMaximumAdrenaline() : float
	{
		return 1.0f + 0.1f * playerWitcher.GetSkillLevel(S_Alchemy_s18);
	}
	
	public function GetValue() : float
	{
		return currentAdrenaline;
	}
	
	public function GetDisplayCount() : int
	{
		return (int)(currentAdrenaline * 100);
	}
	
	public function GetMaxDisplayCount() : int
	{
		return (int)(GetMaximumAdrenaline() * 100);
	}
}

class W3Effect_ReflexBlast extends CBaseGameplayEffect
{
	private var skillLevel			: int;
	private var reflexMultID 		: int;
	private var effectDur			: float;
	private var timePassed			: float;
	private var signPower			: float;
	private var timeScale			: float;
	private var speedDiff			: float;
	private var playerWitcher		: W3PlayerWitcher;
	private var powerStat			: SAbilityAttributeValue;
	
	default effectType = EET_ReflexBlast;
	default isPositive = true;
	default reflexMultID = -1;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		playerWitcher = GetWitcherPlayer();
		powerStat = super.GetCreatorPowerStat();
		skillLevel = (int)powerStat.valueBase;
		signPower = powerStat.valueMultiplicative;
		
		switch(skillLevel)
		{
			case 1:	timeScale = 0.7f;	effectDur = 1.0f;	break;
			case 2:	timeScale = 0.5f;	effectDur = 1.5f;	break;
			case 3:	timeScale = 0.3f;	effectDur = 3.0f;	break;
			case 4:	timeScale = 0.2f;	effectDur = 4.0f;	break;
			case 5:	timeScale = 0.1f;	effectDur = 4.0f;	break;
		}
		
		speedDiff = 1 / timeScale;
		theGame.SetTimeScale(timeScale, theGame.GetTimescaleSource(ETS_ReflexBlast), theGame.GetTimescalePriority(ETS_ReflexBlast), false, true);
		if( skillLevel > 2 )
		{
			if( skillLevel < 5 )
			{
				speedDiff *= 0.75f;
			}
			reflexMultID = playerWitcher.SetAnimationSpeedMultiplier(speedDiff, reflexMultID, true);
		}
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		timePassed += dt * speedDiff;
		if( timePassed >= effectDur )
		{
			playerWitcher.RemoveBuff(EET_ReflexBlast, false, "AardReflexBlast");
		}
		super.OnUpdate(dt);
	}
	
	event OnEffectRemoved()
	{
		theGame.RemoveTimeScale(theGame.GetTimescaleSource(ETS_ReflexBlast));
		if( skillLevel > 2 )
		{
			playerWitcher.ResetAnimationSpeedMultiplier(reflexMultID);
		}
		super.OnEffectRemoved();
	}
	
	public function StackEffectDuration()
	{
		effectDur *= 2.f;
	}
}	

class W3Effect_AlbedoDominance extends CBaseGameplayEffect
{
	default effectType = EET_AlbedoDominance;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	private var updateInterval : float;
	private var currentToxicity : float;
	private var savedToxicity : float;
	private var witcher	: W3PlayerWitcher;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		witcher = GetWitcherPlayer();
		savedToxicity = witcher.GetStat(BCS_Toxicity, false);	
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		updateInterval += dt;		
		if (updateInterval > 1.0f)
		{
			updateInterval = 0;
			currentToxicity = witcher.GetStat(BCS_Toxicity, false);
			if (savedToxicity < currentToxicity)
			{
				effectManager.CacheStatUpdate(BCS_Toxicity, ((currentToxicity - savedToxicity) * -0.2f));
				savedToxicity = currentToxicity;				
			}				
		}
		super.OnUpdate(dt);
	}
}

class W3Effect_RubedoDominance extends CBaseGameplayEffect
{
	default effectType = EET_RubedoDominance;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;	
	
	event OnUpdate( dt : float )
	{
		var vitality: float;
		
		vitality = target.GetStatMax(BCS_Vitality) * 0.003f * dt;
		effectManager.CacheStatUpdate(BCS_Vitality, vitality);
		super.OnUpdate(dt);
	}
}

class W3Effect_NigredoDominance extends CBaseGameplayEffect
{
	default effectType = EET_NigredoDominance;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	public function Init(params : SEffectInitInfo)
	{	
		attributeName = PowerStatEnumToName(CPS_AttackPower);
		super.Init(params);
	}
}

class W3Effect_WinterBlade extends CBaseGameplayEffect
{
	private var hitsToCharge, hitCounter : int;
	private var vigorToCharge, dischargeTime, dischargeTimer : float;
	private var isCharged : bool;
	private var swordID : SItemUniqueId;
	private var inv : CInventoryComponent;
	private var effectName : name;
	private var witcher : W3PlayerWitcher;
	
	default effectType = EET_WinterBlade;
	default isPositive = true;
	default hitsToCharge = 5;
	default vigorToCharge = 1;
	default dischargeTime = 9;
	default effectName = 'runeword_aard';
	
	private function InitEffect()
	{
		witcher = (W3PlayerWitcher)target;
		witcher.inv.GetItemEquippedOnSlot(EES_SteelSword, swordID);
	}
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		InitEffect();
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( deltaTime : float )
	{
		if( dischargeTimer > 0 )
			dischargeTimer -= deltaTime;
		else
			DischargeWeapon(false);
			
		super.OnUpdate(deltaTime);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function IncreaseCounter()
	{
		if( witcher.GetStat(BCS_Focus) >= vigorToCharge )
		{
			if( !isCharged )
			{
				hitCounter += 1;
				if( hitCounter >= hitsToCharge )
					ChargeWeapon();
			}
			dischargeTimer = dischargeTime;
		}
	}
	
	private function ChargeWeapon()
	{
		var ent : CEntity;
		
		isCharged = true;
		inv.PlayItemEffect(swordID, effectName);
		ent = witcher.CreateFXEntityAtPelvis('mutation1_hit', true);
		ent.PlayEffect('mutation_1_hit_aard');
		witcher.PlayEffect('mutation_6_power');
		witcher.AddAbility('ForceDismemberment');
	}
	
	public function DischargeWeapon( attack : bool )
	{
		isCharged = false;
		hitCounter = 0;
		inv.StopItemEffect(swordID, effectName);
		if( attack )
			witcher.DrainFocus(1);
		witcher.RemoveAbility('ForceDismemberment');
	}
	
	public function DealDischargeDamage( attackAction : W3Action_Attack )
	{
		var winterDmg : W3DamageAction;
		var npc : CNewNPC;
		var ent, fx : CEntity;
		var entityTemplate : CEntityTemplate;
		var rot : EulerAngles;
		var i : int;
		var pos, basePos : Vector;
		var angle, radius : float;
		var damage : SAbilityAttributeValue;
		
		if( attackAction.attacker == witcher && IsWeaponCharged() && witcher.IsHeavyAttack(attackAction.GetAttackName()) )
		{
			npc = (CNewNPC)attackAction.victim;
			winterDmg = new W3DamageAction in theGame.damageMgr;
			winterDmg.Initialize( attackAction.attacker, attackAction.victim, attackAction.causer, "WinterBladeDamage", EHRT_None, CPS_Undefined, false, false, false, true );
			winterDmg.AddEffectInfo(EET_Frozen, 4);
			winterDmg.AddEffectInfo(EET_SlowdownFrost, 8);
			
			if( !npc.HasTag('NoImmobilize') )
				winterDmg.AddEffectInfo(EET_Immobilized, 2.5f);
			
			if( npc.IsShielded(witcher) )
			{
				npc.ProcessShieldDestruction();
				winterDmg.AddEffectInfo(EET_LongStagger);
			}
			
			winterDmg.SetHitAnimationPlayType(EAHA_ForceNo);
			winterDmg.SetCannotReturnDamage(true);
			winterDmg.SetCanPlayHitParticle(false);
			winterDmg.SetForceExplosionDismemberment();
			winterDmg.SetWasFrozen();
			
			winterDmg.AddDamage(theGame.params.DAMAGE_NAME_FROST, 1250.f);
			
			npc.SoundEvent("sign_axii_release");
			npc.SoundEvent("bomb_white_frost_explo");
			
			theGame.damageMgr.ProcessAction(winterDmg);
			delete winterDmg;
			
			DischargeWeapon(true);
			witcher.PlayEffect('mutation_6_power');
			npc.PlayEffect('critical_frozen');
			npc.AddTimer('StopMutation6FX', 7.f);
			
			theGame.GetGameCamera().PlayEffect('frost');
			witcher.AddTimer('RemoveCameraEffect', 3.f, false);
			
			fx = npc.CreateFXEntityAtPelvis('mutation2_critical', true);
			fx.PlayEffect('critical_aard');
			fx.PlayEffect('critical_aard');
			fx = npc.CreateFXEntityAtPelvis('mutation1_hit', true);
			fx.PlayEffect('mutation_1_hit_aard');
			fx.PlayEffect('mutation_1_hit_aard');
			GCameraShake(0.75f);
			
			theGame.GetSurfacePostFX().AddSurfacePostFXGroup(npc.GetWorldPosition(), 0.3f, 15, 5, 14, 0);
			
			entityTemplate = (CEntityTemplate)LoadResource("ice_spikes_large");	
			if ( entityTemplate )
			{
				pos = npc.GetWorldPosition();
				pos = TraceFloor(pos);
				rot.Pitch = 0.f;
				rot.Roll = 0.f;
				rot.Yaw = 0.f;
				
				ent = theGame.CreateEntity(entityTemplate, pos, rot);
				ent.DestroyAfter(30.f);
			}
			
			entityTemplate = (CEntityTemplate)LoadResource("ice_spikes");
			basePos = npc.GetWorldPosition();
			for( i=0; i<3; i+=1 )
			{
				radius = RandF() + 1.0;
				
				angle = i * 2 *(Pi() / 3) + RandRangeF(Pi()/18, -Pi()/18);
				
				pos = basePos + Vector( radius * CosF( angle ), radius * SinF( angle ), 0 );
				pos = TraceFloor( pos );
				
				rot.Pitch = 0.f;
				rot.Roll = 0.f;
				rot.Yaw = 0.f;
				
				ent = theGame.CreateEntity(entityTemplate, pos, rot);
				ent.DestroyAfter(30.f);
			}
		}
	}
	
	public function IsWeaponCharged() : bool
	{
		return isCharged;
	}
	
	public function GetHitCounter() : int
	{
		return hitCounter;
	}
	
	public function GetMaxHitCounter() : int
	{
		return hitsToCharge;
	}
	
	public function GetDisplayCount() : int
	{
		return GetHitCounter();
	}
	
	public function GetMaxDisplayCount() : int
	{
		return GetMaxHitCounter();
	}
}

class W3Effect_PhantomWeapon extends CBaseGameplayEffect
{
	default effectType = EET_PhantomWeapon;
	default isPositive = true;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{		
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( deltaTime : float )
	{
		super.OnUpdate(deltaTime);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function GetDisplayCount() : int
	{
		return GetWitcherPlayer().GetPhantomWeaponMgr().GetHitCounter();
	}
	
	public function GetMaxDisplayCount() : int
	{
		return GetWitcherPlayer().GetPhantomWeaponMgr().GetMaxHitCounter();
	}
}

class W3Effect_AlchemyTable extends CBaseGameplayEffect
{
	default effectType = EET_AlchemyTable;
	default dontAddAbilityOnTarget = true;
	default isPositive = true;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{		
		super.OnEffectAdded(customParams);
	}

	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
}

class W3Effect_W3EEHealthRegen extends CBaseGameplayEffect
{
	default effectType = EET_HealthRegen;
	default isPositive = true;
	
	private var healthRegenFactor : float;
	private var maximumHealth : float;
	private var npcTarget : CNewNPC;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		npcTarget = (CNewNPC)target;
		healthRegenFactor = npcTarget.GetHealthRegenFactor();
		if( target.UsesVitality() )
			maximumHealth = target.GetStatMax(BCS_Vitality);
		else
			maximumHealth = target.GetStatMax(BCS_Essence);
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	event OnUpdate( dt : float )
	{
		if( npcTarget.GetIsRegenActive() )
			target.Heal(maximumHealth * healthRegenFactor * dt);
		
		super.OnUpdate(dt);
	}
}

class W3Effect_YrdenAbilityEffect extends CBaseGameplayEffect
{
	default effectType = EET_YrdenAbilityEffect;
	default isPositive = true;
	
	private var npcTarget : CNewNPC;
	private var slowResist : float;
	private var wasEffectAdded : bool;
	private var slowdownKey, shockKey : string;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
		npcTarget = (CNewNPC)target;
		slowResist = npcTarget.GetNPCCustomStat(theGame.params.DAMAGE_NAME_SLOW);
	}
	
	event OnEffectRemoved()
	{
		EndYrdenEffects();
		super.OnEffectRemoved();
	}
	
	event OnUpdate( dt : float )
	{
		if( !wasEffectAdded && !npcTarget.IsFlying() )
			AddYrdenEffects();
		
		super.OnUpdate(dt);
	}
	
	private function BlockAbilities()
	{
		npcTarget.BlockAbility('Flying', true);
	}
	
	private function RestoreAbilities()
	{
		npcTarget.BlockAbility('Flying', false);
	}
	
	private function AddYrdenEffects()
	{
		var params, drainParams : SCustomEffectParams;
		var signPower : SAbilityAttributeValue;
		var abilityCount : int;
		
		wasEffectAdded = true;
		BlockAbilities();
		
		abilityCount = npcTarget.CountEffectsOfType(EET_YrdenAbilityEffect);
		
		slowdownKey = (string)RandRange(2000, 0);
		params.effectType = EET_Slowdown;
		params.creator = super.GetCreator();
		params.sourceName = slowdownKey;
		params.isSignEffect = true;
		params.customAbilityName = '';
		params.duration = 1000;
		
		signPower = super.GetCreatorPowerStat();
		params.effectValue.valueAdditive = 0.24f * signPower.valueMultiplicative * (1 - slowResist);
		
		npcTarget.AddEffectCustom(params);
		if( ((W3SignEntity)GetCreator()).GetActualOwner().CanUseSkill(S_Magic_s11, (W3SignEntity)GetCreator()) )
		{
			shockKey = (string)RandRange(1000, 0);
			drainParams = params;
			drainParams.sourceName = shockKey;
			drainParams.effectType = EET_YrdenHealthDrain;
			npcTarget.AddEffectCustom(drainParams);
		}
	}
	
	private function EndYrdenEffects()
	{
		RestoreAbilities();
		npcTarget.RemoveAllBuffsWithSource(shockKey);
		npcTarget.RemoveAllBuffsWithSource(slowdownKey);
	}
}

class W3Effect_DimeritiumCharge extends CBaseGameplayEffect
{
    private var armorCharges : int;
	private var chargeTime : float;
    
	default effectType = EET_DimeritiumCharge;
	default isPositive = true;
 	default chargeTime = 5;
    
    private function ApplyCustomEffect( creator : CGameplayEntity, victim : CActor, source : string, effect : EEffectType, optional duration : float )
    {
		var customEffect : SCustomEffectParams;
		
		customEffect.creator = creator;
		customEffect.sourceName = source;
		customEffect.effectType = effect;
		if( duration != 0 )
			customEffect.duration = duration;
		victim.AddEffectCustom(customEffect);
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
					return true;
			}
		}
		
		return false;
    }
    
    private function IncreaseDimeritiumChargeTime()
    {
		var witcher : W3PlayerWitcher = GetWitcherPlayer();
		
		if( witcher.IsInCombat() )
		{
			armorCharges += 1;
			armorCharges = Min(armorCharges, 6);
			if( armorCharges < 6 )
				GetWitcherPlayer().PlayEffect('quen_force_discharge_bear_abl2_armour');
		}
    }
    
    public function SetDimeritiumCharge( nr : int )
    {
		armorCharges = nr;
    }
    
    public function IncreaseDimeritiumCharge( action : W3DamageAction )
    {
		var witcher : W3PlayerWitcher;
		var healthPerc : float;
		var i, diff, addCharges : int;
		
		witcher = (W3PlayerWitcher)action.victim;
		if( witcher && action.attacker && action.processedDmg.vitalityDamage > 0 && witcher.IsSetBonusActive(EISB_Dimeritium1) && !((W3Action_Attack)action).IsCountered() && IsDamageTypeCompatible(action) )
		{
			diff = armorCharges;
			healthPerc = witcher.GetStatMax(BCS_Vitality) / action.processedDmg.vitalityDamage;
			if( healthPerc < 15 )
				addCharges = 1;
			else
			if( healthPerc < 35 )
				addCharges = 2;
			else
				addCharges = 3;
			
			armorCharges = Min(armorCharges + addCharges, 6);
			diff = armorCharges - diff;
			for(i=0; i<diff; i+=1)
				witcher.PlayEffect('quen_force_discharge_bear_abl2_armour');
			
			ApplyCustomEffect(witcher, (CActor)action.attacker, "DimeritiumRepel", EET_Stagger);
		}
    }
    
    public function DischargeArmor( out action : W3DamageAction )
    {
		var dischargeEffect : W3DamageAction;
		var witcher : W3PlayerWitcher;
		var dischargeDamage : float;
		var actorAttacker : CActor;
		var surface	: CGameplayFXSurfacePost;
		var fx : CEntity;
		
		witcher = (W3PlayerWitcher)action.victim;
		actorAttacker = (CActor)action.attacker;
		if( witcher && actorAttacker && !((W3Action_Attack)action).IsCountered() && witcher.IsSetBonusActive(EISB_Dimeritium1) && action.IsActionMelee() && armorCharges >= 6 )
		{	
			dischargeDamage = 2250.f;
			dischargeEffect = new W3DamageAction in theGame.damageMgr;
			dischargeEffect.Initialize( witcher, action.attacker, witcher, 'DimeritiumDischarge', EHRT_Heavy, CPS_Undefined, false, true, false, false, 'hit_shock' );	
			dischargeEffect.AddDamage(theGame.params.DAMAGE_NAME_ELEMENTAL, dischargeDamage);
			dischargeEffect.SetCannotReturnDamage(true);
			dischargeEffect.SetCanPlayHitParticle(true);
			dischargeEffect.SetHitAnimationPlayType(EAHA_ForceNo);
			dischargeEffect.SetHitEffect('hit_electric_quen');
			dischargeEffect.SetHitEffect('hit_electric_quen', true);
			dischargeEffect.SetHitEffect('hit_electric_quen', false, true);
			dischargeEffect.SetHitEffect('hit_electric_quen', true, true);
			
			SetDimeritiumCharge(0);
			witcher.StopEffect('quen_force_discharge_bear_abl2_armour');
			actorAttacker.PlayEffect('hit_electric_quen');
			actorAttacker.PlayEffect('hit_electric_quen');
			fx = actorAttacker.CreateFXEntityAtPelvis('mutation1_hit', true);
			fx.PlayEffect('mutation_1_hit_quen');
			ApplyCustomEffect(witcher, actorAttacker, "DimeritiumDischarge", EET_LongStagger);
			action.processedDmg.vitalityDamage /= 2;
			theGame.damageMgr.ProcessAction(dischargeEffect);
			
			surface = theGame.GetSurfacePostFX();
			surface.AddSurfacePostFXGroup(actorAttacker.GetWorldPosition(), 2, 40, 10, 5, 1);
			delete dischargeEffect;
		}
    }
	
	event OnUpdate( deltaTime : float )
	{
		if( chargeTime <= 0 )
		{
			IncreaseDimeritiumChargeTime();
			chargeTime = 5;
		}
		chargeTime -= deltaTime;
		
		super.OnUpdate(deltaTime);
	}
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnEffectAddedPost()
	{
		var i : int;
		var witcher : W3PlayerWitcher = GetWitcherPlayer();
		
		super.OnEffectAddedPost();
		SetDimeritiumCharge(FactsQueryLatestValue("DimeritiumCharges"));
		for(i=0; i<armorCharges; i+=1)
			witcher.PlayEffect('quen_force_discharge_bear_abl2_armour');
	}
	
	event OnEffectRemoved()
	{
		FactsSet("DimeritiumCharges", armorCharges, -1);
		GetWitcherPlayer().StopEffect('quen_force_discharge_bear_abl2_armour');
		super.OnEffectRemoved();
	}
	
	public function GetDisplayCount() : int
	{
		return armorCharges;
	}
	
	public function GetMaxDisplayCount() : int
	{
		return 6;
	}
}

class W3Effect_SwordCritVigor extends CBaseGameplayEffect
{
	private var isReductionActive : bool;
	private var reductionTimer : float;
	
	default reductionTimer = 0;
	default isReductionActive = false;
	default effectType = EET_SwordCritVigor;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		if( isReductionActive )
		{
			reductionTimer -= dt;
			if( reductionTimer <= 0 )
				isReductionActive = false;
		}
		super.OnUpdate(dt);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function SetReductionActive( b : bool )
	{
		if( b )
			reductionTimer = 10.f;
		else
			reductionTimer = 0.f;
		isReductionActive = b;
	}
	
	public function GetReductionActive() : bool
	{
		return isReductionActive;
	}
}

class W3Effect_SwordRendBlast extends CBaseGameplayEffect
{
	private var burningTimer 	: float;
	private var burningActive 	: bool;
	private var weapon 			: CEntity;
	
	default effectType = EET_SwordRendBlast;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
		
		if( burningTimer > 0 )
			burningTimer -= dt;
		
		if( burningTimer <= 0 && burningActive )
		{
			burningActive = false;
			burningTimer = 0.f;
			
			weapon.StopEffectIfActive('runeword_igni');
		}
	}	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function FireDischarge( attackAction : W3Action_Attack, playerAttacker : CR4Player, actorVictim : CActor )
	{
		var surface	: CGameplayFXSurfacePost;
		var fireDamage : W3DamageAction;
		var damageValue : SAbilityAttributeValue;
		var npcVictim : CNewNPC;
		var fx : CEntity;
		
		if(	playerAttacker && attackAction.IsActionMelee() && attackAction.DealsAnyDamage() && ((W3PlayerWitcher)playerAttacker).IsInCombatAction_SpecialAttackHeavy() && playerAttacker.GetSpecialAttackTimeRatio() > 0.75f )
		{
			npcVictim = (CNewNPC)actorVictim;
			fireDamage = new W3DamageAction in theGame.damageMgr;
			fireDamage.Initialize(attackAction.attacker, attackAction.victim, attackAction.causer, attackAction.GetBuffSourceName(), EHRT_None, CPS_Undefined, attackAction.IsActionMelee(), attackAction.IsActionRanged(), attackAction.IsActionWitcherSign(), attackAction.IsActionEnvironment());
			
			if( npcVictim.IsShielded( thePlayer ) )
			{
				npcVictim.ProcessShieldDestruction();
				fireDamage.AddEffectInfo(EET_Stagger);
			}
			else fireDamage.AddEffectInfo(EET_LongStagger);
			
			fireDamage.SetCannotReturnDamage(true);
			fireDamage.SetCanPlayHitParticle(false);
			fireDamage.SetForceExplosionDismemberment();
			
			damageValue = playerAttacker.GetInventory().GetItemAttributeValue(playerAttacker.GetInventory().GetItemFromSlot('r_weapon'), 'SlashingDamage');
			fireDamage.AddDamage(theGame.params.DAMAGE_NAME_FIRE, damageValue.valueBase * (2.f + damageValue.valueMultiplicative) + damageValue.valueAdditive);
			fireDamage.SetHitAnimationPlayType(EAHA_ForceNo);
			theGame.damageMgr.ProcessAction(fireDamage);
			
			delete fireDamage;
			
			playerAttacker.SoundEvent('sign_igni_charge_begin');
			playerAttacker.SoundEvent('sign_igni_charge_begin');
			npcVictim.AddTimer('Runeword1DisableFireFX', 6);	
			npcVictim.PlayEffect('critical_burning');
			
			surface = theGame.GetSurfacePostFX();
			surface.AddSurfacePostFXGroup(npcVictim.GetWorldPosition(), 1.f, 30, 3, 6, 1);
			
			if( !weapon )
				weapon = playerAttacker.GetInventory().GetItemEntityUnsafe(playerAttacker.GetInventory().GetItemFromSlot('r_weapon'));
			weapon.PlayEffectSingle('runeword_igni');
			burningActive = true;
			burningTimer = 7.f;
			
			fx = npcVictim.CreateFXEntityAtPelvis('mutation2_critical', true);
			fx.PlayEffect('critical_igni');
			fx.PlayEffect('critical_igni');
			fx = npcVictim.CreateFXEntityAtPelvis('mutation1_hit', true);
			fx.PlayEffect('mutation_1_hit_igni');
			fx.PlayEffect('mutation_1_hit_igni');
			GCameraShake(0.6f, false, thePlayer.GetWorldPosition(),,,, 0.85f);
		}
	}
}

class W3Effect_SwordInjuryHeal extends CBaseGameplayEffect
{
	default effectType = EET_SwordInjuryHeal;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function HealCombatInjury()
	{
		if( RandRange(100, 0) <= 30 )
			GetWitcherPlayer().GetInjuryManager().HealRandomInjury();
	}
}

class W3Effect_SwordDancing extends CBaseGameplayEffect
{
	private var isSwordDanceActive : bool;
	private var swordDanceDuration : float;
	
	default isSwordDanceActive = false;
	default swordDanceDuration = 0;
	default effectType = EET_SwordDancing;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		if( isSwordDanceActive )
		{
			swordDanceDuration -= dt;
			if( swordDanceDuration <= 0 )
				SetSwordDanceActive(false);
		}
		super.OnUpdate(dt);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function SetSwordDanceActive( b : bool )
	{
		isSwordDanceActive = b;
		if( b )
			swordDanceDuration = 0.5f;
	}
	
	public function GetSwordDanceActive() : bool
	{
		return isSwordDanceActive;
	}
}

class W3Effect_SwordQuen extends CBaseGameplayEffect
{
	default effectType = EET_SwordQuen;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function BashCounterImpulse()
	{
		var player : W3PlayerWitcher = GetWitcherPlayer();
		var action : W3DamageAction;
		var ents : array<CGameplayEntity>;
		var pos : Vector;
		var i : int;
		
		if( player.GetStat(BCS_Focus) > 0.5f )
		{
			FindGameplayEntitiesInRange(ents, player, 3.f, 1000, , FLAG_OnlyAliveActors + FLAG_ExcludePlayer + FLAG_Attitude_Hostile + FLAG_Attitude_Neutral);
			for(i=0; i<ents.Size(); i+=1)
			{
				action = new W3DamageAction in theGame;
				action.Initialize(player, ents[i], player, "SwordQuenEffect", EHRT_Heavy, CPS_Undefined, true, false, false, false);
				action.SetCannotReturnDamage(true);
				action.SetProcessBuffsIfNoDamage(true);
				
				action.SetHitEffect('hit_electric_quen');
				action.SetHitEffect('hit_electric_quen', true);
				action.SetHitEffect('hit_electric_quen', false, true);
				action.SetHitEffect('hit_electric_quen', true, true);
				
				if( RandRange(100, 0) <= 15 )
					action.AddEffectInfo(EET_Knockdown);
				else
				if( RandRange(100, 0) <= 50 )
					action.AddEffectInfo(EET_LongStagger);
				else
					action.AddEffectInfo(EET_Stagger);
				((CActor)ents[i]).PlayHitEffect(action);
				
				theGame.damageMgr.ProcessAction(action);
				delete action;
			}
			
			GCameraShake(0.5f);
			
			player.PlayEffect('lasting_shield_impulse');
			
			player.DrainFocus(0.5f);
		}
	}
}

class W3Effect_SwordWraithbane extends CBaseGameplayEffect
{
	default effectType = EET_SwordWraithbane;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function StopWraithHealthRegen( action : W3DamageAction, actorVictim : CActor, victimMonsterCategory : EMonsterCategory )
	{
		if( victimMonsterCategory == MC_Specter && action.DealsAnyDamage() )
		{
			actorVictim.RemoveTimer('AddHealthRegenEffect');
			actorVictim.RemoveBuff(EET_HealthRegen, true, "W3EEHealthRegen");
		}
	}
}

class W3Effect_SwordBloodFrenzy extends CBaseGameplayEffect
{
	private var isFrenzyActive : bool;
	private var frenzyDuration : float;
	
	default frenzyDuration = 0;
	default isFrenzyActive = false;
	default effectType = EET_SwordBloodFrenzy;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		if( isFrenzyActive )
		{
			frenzyDuration -= dt;
			if( frenzyDuration <= 0 )
				SetFrenzyActive(false);
		}
		super.OnUpdate(dt);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function SetFrenzyActive( b : bool )
	{
		isFrenzyActive = b;
		if( b )
		{
			frenzyDuration = 5.f;
			target.AddAbility('SwordBloodFrenzyAbility', false);
		}
		else
			target.RemoveAbility('SwordBloodFrenzyAbility');
	}
}

class W3Effect_SwordKillBuff extends CBaseGameplayEffect
{
	private var isKillBuffActive : bool;
	
	default isKillBuffActive = false;
	default effectType = EET_SwordKillBuff;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function SetKillBuffActive( b : bool )
	{
		isKillBuffActive = b;
	}
	
	public function IsKillBuffActive() : bool
	{
		return isKillBuffActive;
	}
	
	public function BuffAttackDamage( out action : W3Action_Attack )
	{
		if( action && action.attacker == thePlayer && action.IsActionMelee() && isKillBuffActive )
		{
			action.MultiplyAllDamageBy(2.f);
			isKillBuffActive = false;
		}
	}
}

class W3Effect_SwordBehead extends CBaseGameplayEffect
{
	private var isBeheadEffectActive : bool;
	private var beheadEffectDur : float;
	
	default beheadEffectDur = 0;
	default isBeheadEffectActive = false;
	default effectType = EET_SwordBehead;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		if( isBeheadEffectActive )
		{
			beheadEffectDur -= dt;
			if( beheadEffectDur <= 0 )
				SetBeheadEffectActive(false);
		}
		super.OnUpdate(dt);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function SetBeheadEffectActive( b : bool )
	{
		isBeheadEffectActive = b;
		if( b )
			beheadEffectDur = 10.f;
		else
			beheadEffectDur = 0.f;
	}
	
	public function GetBeheadEffectActive() : bool
	{
		return isBeheadEffectActive;
	}
}

class W3Effect_SwordGas extends CBaseGameplayEffect
{
	private var gasEntity : W3ToxicCloud;
	
	default effectType = EET_SwordGas;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function SpawnGasCloud( action : W3DamageAction, playerAttacker : CR4Player )
	{
		var ent : CEntityTemplate;
		
		if( playerAttacker && action.IsActionMelee() && action.DealsAnyDamage() && RandRange(100, 0) <= 15 )
		{
			gasEntity = (W3ToxicCloud)theGame.CreateEntity((CEntityTemplate)LoadResource("items\weapons\projectiles\petards\petard_dragons_dream_gas.w2ent", true), playerAttacker.GetWorldPosition(), playerAttacker.GetWorldRotation());
			gasEntity.explosionDamage.valueAdditive = 1850.f;
			gasEntity.SetBurningChance(0.1f);
			gasEntity.SetFromBomb(playerAttacker);
			gasEntity.SetIsFromClusterBomb(false);
			gasEntity.SetFriendlyFire(true);
			gasEntity.DestroyAfter(30.f);
		}
	}
}

enum EStoredAction
{
	ESA_FastAttack,
	ESA_StrongAttack,
	ESA_Counter,
	ESA_Parry,
	ESA_Dodge,
	ESA_None
}

enum EBuffedSign
{
	EBS_Aard,
	EBS_Igni,
	EBS_Yrden,
	EBS_Quen,
	EBS_Axii,
	EBS_None
}

class W3Effect_SwordSignDancer extends CBaseGameplayEffect
{
	private var actionCount : int;
	private var effectTimer : float;
	private var buffedSignType : EBuffedSign;
	private var storedActionType : EStoredAction;
	
	default actionCount = 0;
	default effectTimer = 0.f;
	default buffedSignType = EBS_None;
	default storedActionType = ESA_None;
	default effectType = EET_SwordSignDancer;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		if( buffedSignType != EBS_None )
		{
			effectTimer -= dt;
			if( effectTimer <= 0 )
			{
				RemoveAbilities(GetWitcherPlayer());
				actionCount = 0;
			}
		}
		super.OnUpdate(dt);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	private function StopWeaponEffects( player : W3PlayerWitcher )
	{
		var weapon : CEntity =  player.inv.GetItemEntityUnsafe(player.inv.GetItemFromSlot('r_weapon'));
		
		weapon.StopEffect('runeword_aard');
		weapon.StopEffect('runeword_igni');
		weapon.StopEffect('runeword_axii');
		weapon.StopEffect('runeword_quen');
		weapon.StopEffect('runeword_yrden');
		buffedSignType = EBS_None;
	}
	
	private function RemoveAbilities( player : W3PlayerWitcher )
	{
		StopWeaponEffects(player);
		player.RemoveAbility('SignDancerAard');
		player.RemoveAbility('SignDancerIgni');
		player.RemoveAbility('SignDancerYrden');
		player.RemoveAbility('SignDancerQuen');
		player.RemoveAbility('SignDancerAxii');
	}
	
	private function HandleAbilities( actionType : EStoredAction, player : W3PlayerWitcher )
	{
		var weapon : CEntity =  player.inv.GetItemEntityUnsafe(player.inv.GetItemFromSlot('r_weapon'));
		
		RemoveAbilities(player);
		switch(actionType)
		{
			case ESA_FastAttack:
				if( actionCount > 3 && buffedSignType == EBS_None )
				{
					player.AddAbility('SignDancerAard', false);
					weapon.PlayEffect('runeword_aard');
					buffedSignType = EBS_Aard;
					effectTimer = 15.f;
					actionCount = 0;
				}
			break;
			
			case ESA_StrongAttack:
				if( actionCount > 2 && buffedSignType == EBS_None )
				{
					player.AddAbility('SignDancerIgni', false);
					weapon.PlayEffect('runeword_igni');
					buffedSignType = EBS_Igni;
					effectTimer = 15.f;
					actionCount = 0;
				}
			break;
			
			case ESA_Counter:
				if( actionCount > 2 && buffedSignType == EBS_None )
				{
					player.AddAbility('SignDancerAxii', false);
					weapon.PlayEffect('runeword_axii');
					buffedSignType = EBS_Axii;
					effectTimer = 15.f;
					actionCount = 0;
				}
			break;
			
			case ESA_Parry:
				if( actionCount > 3 && buffedSignType == EBS_None )
				{
					player.AddAbility('SignDancerQuen', false);
					weapon.PlayEffect('runeword_quen');
					buffedSignType = EBS_Quen;
					effectTimer = 15.f;
					actionCount = 0;
				}
			break;
			
			case ESA_Dodge:
				if( actionCount > 3 && buffedSignType == EBS_None )
				{
					player.AddAbility('SignDancerYrden', false);
					weapon.PlayEffect('runeword_yrden');
					buffedSignType = EBS_Yrden;
					effectTimer = 15.f;
					actionCount = 0;
				}
			break;
			
		}
	}
	
	public function RemoveSignAbility( signType : ESignType, signOwner : W3SignOwner )
	{
		switch(signType)
		{
			case ST_Aard:
				if( buffedSignType == EBS_Aard )
					RemoveAbilities(signOwner.GetPlayer());
			break;
			
			case ST_Igni:
				if( buffedSignType == EBS_Igni )
					RemoveAbilities(signOwner.GetPlayer());
			break;
			
			case ST_Yrden:
				if( buffedSignType == EBS_Yrden )
					RemoveAbilities(signOwner.GetPlayer());
			break;
			
			case ST_Quen:
				if( buffedSignType == EBS_Quen )
					RemoveAbilities(signOwner.GetPlayer());
			break;
			
			case ST_Axii:
				if( buffedSignType == EBS_Axii )
					RemoveAbilities(signOwner.GetPlayer());
			break;
			
		}
	}
	
	private var lastActionCount : float;	default lastActionCount = 0.f;
	public function CountActionType( actionType : EStoredAction )
	{
		var player : W3PlayerWitcher = GetWitcherPlayer();
		
		if( !player.IsInCombat() )
			return;
			
		if( theGame.GetEngineTimeAsSeconds() - lastActionCount > 0.15f )
		{
			if( storedActionType == actionType )
			{
				actionCount += 1;
			}
			else
			{
				storedActionType = actionType;
				actionCount = 1;
			}
			
			HandleAbilities(actionType, player);
		}
		lastActionCount = theGame.GetEngineTimeAsSeconds();
	}
}

class W3Effect_SwordReachoftheDamned extends CBaseGameplayEffect
{
	default effectType = EET_SwordReachoftheDamned;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function ExpandDamageTypes( out damages : array<SRawDamage>, action : W3DamageAction, playerAttacker : CR4Player, actorVictim : CActor )
	{
		var i : int;
		var elementalIdx : int;
		var elementalDmg : SRawDamage;
		var damageValue : float;
		
		if( playerAttacker && action.IsActionMelee() )
		{
			elementalIdx = -1;
			for(i=0; i<damages.Size(); i+=1)
			{
				if( damages[i].dmgType == theGame.params.DAMAGE_NAME_ELEMENTAL )
				{
					elementalIdx = i;
					break;
				}
			}
			
			damageValue = 0.f;
			if( playerAttacker.GetStatPercents(BCS_Vitality) <= 0.5f )
				damageValue += 150.f;
			if( actorVictim.GetHealthPercents() <= 0.5f )
				damageValue += 80.f;
				
			if( elementalIdx != -1 )
			{
				damages[elementalIdx].dmgVal += damageValue;
			}
			else
			{
				elementalDmg.dmgType = theGame.params.DAMAGE_NAME_ELEMENTAL;
				elementalDmg.dmgVal = damageValue;
				damages.PushBack(elementalDmg);
			}
		}
	}
	
	public function MultiplyAdrenaline( out adrenalineVal : float )
	{
		if( GetWitcherPlayer().GetStatPercents(BCS_Vitality) <= 0.5f )
			adrenalineVal *= 2.f;
	}
}

class W3Effect_SwordDarkCurse extends CBaseGameplayEffect
{
	private var effectTimer : float;
	
	default effectTimer = 0;
	default effectType = EET_SwordDarkCurse;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
		effectTimer = 3.f;
	}
	
	event OnUpdate( dt : float )
	{
		effectTimer -= dt;
		if( effectTimer <= 0 )
		{
			target.DrainVitality(target.GetStatMax(BCS_Vitality) * 0.02f * dt);
			if( target.GetHealth() <= 20.0f )
				target.Kill('DarkCurse', true);
		}
		super.OnUpdate(dt);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function ResetCurseAttackTimer()
	{
		effectTimer = 3.f;
	}
}

class W3Effect_SwordDesperateAct extends CBaseGameplayEffect
{
	default effectType = EET_SwordDesperateAct;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function RestoreStatsExecution()
	{
		if( GetWitcherPlayer().GetStatPercents(BCS_Vitality) <= 0.15f )
		{
			GetWitcherPlayer().GainStat(BCS_Vitality, GetWitcherPlayer().GetStatMax(BCS_Vitality) * 0.5f);
			GetWitcherPlayer().GainStat(BCS_Stamina, GetWitcherPlayer().GetStatMax(BCS_Stamina) - GetWitcherPlayer().GetStat(BCS_Stamina));
		}
	}
}

class W3Effect_SwordRedTear extends CBaseGameplayEffect
{
	default effectType = EET_SwordRedTear;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{
		super.OnEffectAdded(customParams);
	}
	
	event OnUpdate( dt : float )
	{
		super.OnUpdate(dt);
	}
	
	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
	
	public function BoostAttackDamage( action : W3DamageAction, playerAttacker : CR4Player )
	{
		if( playerAttacker && playerAttacker.GetStatPercents(BCS_Vitality) <= 0.3f && action.IsActionMelee() )
			action.MultiplyAllDamageBy(1.6f);
	}
}

class W3Effect_InjuredArm extends CBaseGameplayEffect
{
	default effectType = EET_InjuredArm;
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{		
		super.OnEffectAdded(customParams);
	}

	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
}

class W3Effect_InjuredLeg extends CBaseGameplayEffect
{
	default effectType = EET_InjuredLeg;
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{		
		super.OnEffectAdded(customParams);
	}

	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
}

class W3Effect_InjuredTorso extends CBaseGameplayEffect
{
	default effectType = EET_InjuredTorso;
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{		
		super.OnEffectAdded(customParams);
	}

	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
}

class W3Effect_InjuredHead extends CBaseGameplayEffect
{
	default effectType = EET_InjuredHead;
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	
	event OnEffectAdded( customParams : W3BuffCustomParams )
	{		
		super.OnEffectAdded(customParams);
	}

	event OnEffectRemoved()
	{
		super.OnEffectRemoved();
	}
}