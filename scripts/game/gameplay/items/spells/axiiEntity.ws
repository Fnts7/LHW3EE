﻿/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
struct SAxiiEffects
{
	editable var castEffect		: name;
	editable var throwEffect	: name;
}

statemachine class W3AxiiEntity extends W3SignEntity
{
	editable var effects		: array< SAxiiEffects >;	
	editable var projTemplate	: CEntityTemplate;
	editable var distance		: float;	
	editable var projSpeed		: float;
	
	default skillEnum = S_Magic_5;
	
	protected var targets			: array<CActor>;
	protected var slowdownTargets	: array<CActor>;
	protected var axiiCastLevel 	: int;
	protected var applySlowdown 	: bool;
	
	protected var orientationTarget : CActor;
	
	public function GetSignType() : ESignType
	{
		return ST_Axii;
	}
	
	// W3EE - Begin
	function Init( inOwner : W3SignOwner, prevInstance : W3SignEntity, optional skipCastingAnimation : bool, optional notPlayerCast : bool, optional isFreeCast : bool ) : bool
	// W3EE - End
	{	
		var ownerActor : CActor;
		var prevSign : W3SignEntity;
		
		ownerActor = inOwner.GetActor();
		
		CacheSignStats(inOwner);
		
		axiiCastLevel = inOwner.GetSkillLevel(S_Magic_s17, this);
		
		if (inOwner.CanUseSkill(S_Magic_s05, this) && inOwner.GetSkillLevel(S_Magic_s05, this) > 1)
			axiiCastLevel += 1;
				
		if (inOwner.CanUseSkill(S_Magic_s19, this) && inOwner.GetSkillLevel(S_Magic_s19, this) > 1)
			axiiCastLevel += inOwner.GetSkillLevel(S_Magic_s19, this) - 1;		
			
		if ( owner == thePlayer && GetWitcherPlayer().GetPotionBuffLevel(EET_PetriPhiltre) == 3)
			axiiCastLevel += 2;
			
		applySlowdown = inOwner.CanUseSkill(S_Magic_s17, this);
		
		if( (CPlayer)ownerActor )
		{
			prevSign = GetWitcherPlayer().GetSignEntity(ST_Axii);
			if(prevSign)
				prevSign.OnSignAborted(true);
		}
		
		ownerActor.SetBehaviorVariable( 'bStopSign', 0.f );
		if ( inOwner.CanUseSkill(S_Magic_s17, this) && inOwner.GetSkillLevel(S_Magic_s17, this) > 1)
			ownerActor.SetBehaviorVariable( 'bSignUpgrade', 1.f );
		else
			ownerActor.SetBehaviorVariable( 'bSignUpgrade', 0.f );
		
		// W3EE - Begin
		return super.Init( inOwner, prevInstance, skipCastingAnimation, notPlayerCast, isFreeCast );
		// W3EE - End
	}
		
	event OnProcessSignEvent( eventName : name )
	{
		if ( eventName == 'axii_ready' )
		{
			PlayEffect( effects[fireMode].throwEffect );
		}
		else if ( eventName == 'horse_cast_begin' )
		{
			OnHorseStarted();
		}
		else
		{
			return super.OnProcessSignEvent( eventName );
		}
		
		return true;
	}
	
	event OnStarted()
	{
		var player : CR4Player;
		var i : int;
		var slowdown : float;
		
		SelectTargets();
		// W3EE - Begin
		//Combat().CacheAxiiLinkActors(targets);
		// W3EE - End
		
		if (slowdownTargets.Size() > 0)
			slowdown = CalcSlowdown();
		
		for(i=0; i<slowdownTargets.Size(); i+=1)
		{
			AddMagic17Effect(slowdownTargets[i], slowdown);
		}
		
		Attach(true);
		
		player = (CR4Player)owner.GetActor();
		if(player)
		{
			GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();
			player.AddTimer('ResetPadBacklightColorTimer', 2);
		}
			
		PlayEffect( effects[fireMode].castEffect );
		
		if ( owner.ChangeAspect( this, S_Magic_s05 ) )
		{
			CacheActionBuffsFromSkill();
			GotoState( 'AxiiChanneled' );
		}
		else
		{
			GotoState( 'AxiiCast' );
		}		
	}
	
	
	function OnHorseStarted()
	{
		Attach(true);
		PlayEffect( effects[fireMode].castEffect );
	}
	
	
	private final function IsTargetValid(actor : CActor, isAdditionalTarget : bool) : bool
	{
		var npc : CNewNPC;
		var horse : W3HorseComponent;
		var attitude : EAIAttitude;
		
		if(!actor)
			return false;
			
		if(!actor.IsAlive())
			return false;
		
				
		attitude = GetAttitudeBetween(owner.GetActor(), actor);
		
		
		if(isAdditionalTarget && attitude != AIA_Hostile)
			return false;
		
		npc = (CNewNPC)actor;
		
	
		if(attitude == AIA_Friendly)
		{
			
			if(npc.GetNPCType() == ENGT_Quest && !actor.HasTag(theGame.params.TAG_AXIIABLE_LOWER_CASE) && !actor.HasTag(theGame.params.TAG_AXIIABLE))
				return false;
		}
					
		
		if(npc)
		{
			horse = npc.GetHorseComponent();				
			if(horse && !horse.IsDismounted())	
			{
				if(horse.GetCurrentUser() != owner.GetActor())	
					return false;
			}
		}
		
		return true;
	}
	
	private function SelectTargets()
	{
		// W3EE - Begin
		var projCount, projCountSlowdown, i, j : int;
		var actors, finalActors : array<CActor>;
		var ownerPos : Vector;
		var ownerActor : CActor;
		var actor : CActor;
		
		if( owner.CanUseSkill(S_Magic_s19, this) ) {
			projCount = owner.GetSkillLevel(S_Magic_s19, this) + 1;
		}
		else
			projCount = 1;
			
		if (applySlowdown)
			projCountSlowdown = axiiCastLevel;
		else
			projCountSlowdown = 0;
		
		targets.Clear();
		slowdownTargets.Clear();
		actor = (CActor)thePlayer.slideTarget;	
		
		if(actor && IsTargetValid(actor, false))
		{
			targets.PushBack(actor);
			projCount -= 1;
			
			if (projCountSlowdown > 0)
			{
				slowdownTargets.PushBack(actor);
				projCountSlowdown -= 1;
			}
			
			if(projCount == 0 && projCountSlowdown == 0)
				return;
		}
		
		ownerActor = owner.GetActor();
		ownerPos = ownerActor.GetWorldPosition();
		
		
		actors = ownerActor.GetNPCsAndPlayersInCone(12 + axiiCastLevel, VecHeading(ownerActor.GetHeadingVector()), 70 + 10 * axiiCastLevel, 20, , FLAG_OnlyAliveActors);
					
		
		for(i=actors.Size()-1; i>=0; i-=1)
		{
			
			if(ownerActor == actors[i] || actor == actors[i] || !IsTargetValid(actors[i], true))
				actors.Erase(i);
		}
		
		
		if(actors.Size() > 0)
			finalActors.PushBack(actors[0]);
					
		for(i=1; i<actors.Size(); i+=1)
		{
			for(j=0; j<finalActors.Size(); j+=1)
			{
				if(VecDistance(ownerPos, actors[i].GetWorldPosition()) < VecDistance(ownerPos, finalActors[j].GetWorldPosition()))
				{
					finalActors.Insert(j, actors[i]);
					break;
				}
			}
			
			
			if(j == finalActors.Size())
				finalActors.PushBack(actors[i]);
		}
		
		
		for (i=0; i < finalActors.Size(); i += 1)
		{
			if (projCount == 0 && projCountSlowdown == 0)
				break;
				
			if (projCount > 0)
			{	
				targets.PushBack(finalActors[i]);
				projCount -= 1;
			}
			
			if (projCountSlowdown > 0)
			{	
				slowdownTargets.PushBack(finalActors[i]);
				projCountSlowdown -= 1;
			}
		}
		
		/*if(finalActors.Size() > 0)
		{
			for(i=0; i<projCount; i+=1)
			{
				if(finalActors[i])
					targets.PushBack(finalActors[i]);
				else
					break;	
			}
		}*/		
	}
	
	protected function ProcessThrow()
	{
		var proj : W3AxiiProjectile;
		var i : int;				
		var spawnPos : Vector;
		var spawnRot : EulerAngles;		
		
		
		
				
		
		spawnPos = GetWorldPosition();
		spawnRot = GetWorldRotation();
		
		
		StopEffect( effects[fireMode].castEffect );
		PlayEffect('axii_sign_push');
		
		
		for(i=0; i<targets.Size(); i+=1)
		{
			proj = (W3AxiiProjectile)theGame.CreateEntity( projTemplate, spawnPos, spawnRot );
			proj.PreloadEffect( proj.projData.flyEffect );
			proj.ExtInit( owner, skillEnum, this );			
			proj.PlayEffect(proj.projData.flyEffect );				
			proj.ShootProjectileAtNode(0, projSpeed, targets[i]);
		}		
	}
	
	event OnEnded(optional isEnd : bool)
	{
		var buff : EEffectInteract;
		var conf : W3ConfuseEffect;
		var puppet : W3Effect_AxiiGuardMe;
		var i : int;
		// W3EE - Begin
		var duration, durationAnimal, axiiPower : SAbilityAttributeValue;
		// W3EE - End
		var casterActor : CActor;
		var dur, durAnimals : float;
		var params, staggerParams : SCustomEffectParams;
		var npcTarget : CNewNPC;
		var jobTreeType : EJobTreeType;
		// W3EE - Begin
		var pts, prc, raw, chance, powerDec : float;
		// W3EE - End
		
		casterActor = owner.GetActor();		
		ProcessThrow();
		StopEffect(effects[fireMode].throwEffect);
		
		
		for(i=0; i<slowdownTargets.Size(); i+=1)
		{
			RemoveMagic17Effect(slowdownTargets[i]);
		}
		
		
		RemoveMagic17Effect(orientationTarget);
				
		if(IsAlternateCast())
		{
			thePlayer.LockToTarget( false );
			thePlayer.EnableManualCameraControl( true, 'AxiiEntity' );
		}
		
		
		if (targets.Size() > 0 )
		{
			
			duration = thePlayer.GetSkillAttributeValue(skillEnum, 'duration', false, true);
			durationAnimal = thePlayer.GetSkillAttributeValue(skillEnum, 'duration_animals', false, true);
			
			durationAnimal.valueMultiplicative = 1.0f;
			duration.valueMultiplicative = 1.0f;
			
	
			dur = CalculateAttributeValue(duration);
			durAnimals = CalculateAttributeValue(durationAnimal);
			
			
			params.creator = casterActor;
			params.sourceName = "axii_" + skillEnum;			
			//params.customPowerStatValue = super.GetTotalSignIntensity();
			params.isSignEffect = true;
			
			// W3EE - Begin
			
			axiiPower = super.GetTotalSignIntensity();
			powerDec = 0.3f - owner.GetSkillLevel(S_Magic_s19, this) * 0.05f;
			
			// W3EE - End
			
			for(i=0; i<targets.Size(); i+=1)
			{
				npcTarget = (CNewNPC)targets[i];

				prc = npcTarget.GetNPCCustomStat(theGame.params.DAMAGE_NAME_MENTAL);
				chance = 0.7f * axiiPower.valueMultiplicative * (1 - prc);				
				
				if( targets[i].IsAnimal() || npcTarget.IsHorse() )
				{
					params.duration = durAnimals;
					chance *= 1.4f;
				}
				else
				{
					params.duration = dur;
				}
				
				params.customPowerStatValue = axiiPower;

				
				jobTreeType = npcTarget.GetCurrentJTType();	
					
				if ( jobTreeType == EJTT_InfantInHand )
				{
					params.effectType = EET_AxiiGuardMe;
				}
				
				else if(IsAlternateCast() && owner.GetActor() == thePlayer && GetAttitudeBetween(targets[i], owner.GetActor()) == AIA_Friendly)
				{
					params.effectType = EET_Confusion;
				}
				else
				{
					params.effectType = actionBuffs[0].effectType;
				}
			
				
				//RemoveMagic17Effect(targets[i]);
			
				// W3EE - Begin
				if( npcTarget.UsesEssence() )
					chance *= 1 + PowF(1.0f - npcTarget.GetStatPercents(BCS_Essence), 2);
				else
					chance *= 1 + PowF(1.0f - npcTarget.GetStatPercents(BCS_Vitality), 2);
				
				if(i == 0 && owner == thePlayer && GetWitcherPlayer().GetPotionBuffLevel(EET_PetriPhiltre) == 3)
				{
					chance = 1;
				}
				
				if( npcTarget.IsHorse() || (owner.GetActor() == thePlayer && GetAttitudeBetween(targets[i], owner.GetActor()) == AIA_Friendly) )
				{
					chance = 1;
				}
				
				if(RandF() <= chance)
				{
					buff = targets[i].AddEffectCustom(params);
				}
				else
					buff = EI_Deny;
				// W3EE - End	
				
				if( buff == EI_Pass || buff == EI_Override || buff == EI_Cumulate )
				{
					targets[i].OnAxiied( casterActor );
					
					// W3EEG - Begin
					if(owner.CanUseSkill(S_Magic_s18, this) || owner.GetActor().HasAbility('Glyphword 13 _Stats', true))
					// W3EE - End
					{
						chance = 0;
						if (owner.CanUseSkill(S_Magic_s18, this))
							chance += owner.GetSkillLevel(S_Magic_s18, this) * 0.1f;
							
						if (owner.GetActor().HasAbility('Glyphword 13 _Stats', true))
							chance += 0.3f;
						
						if (params.effectType == EET_Confusion)
						{
							conf = (W3ConfuseEffect)(targets[i].GetBuff(EET_Confusion));
							conf.SetDrainStaminaOnExit(chance);
						}
						else if (params.effectType == EET_AxiiGuardMe)
						{
							puppet = (W3Effect_AxiiGuardMe)(targets[i].GetBuff(EET_AxiiGuardMe));
							puppet.SetDrainStaminaOnExit(chance);
						}
					}
				}
				else
				{
					
					if(owner.CanUseSkill(S_Magic_s17, this) && owner.GetSkillLevel(S_Magic_s17, this) == 3)
					{
						staggerParams = params;
						if ( i == 0 )
							staggerParams.effectType = EET_LongStagger;
						else
							staggerParams.effectType = EET_Stagger;
						params.duration = 0;	
						targets[i].AddEffectCustom(staggerParams);					
					}
					else
					{
						
						owner.GetActor().SetBehaviorVariable( 'axiiResisted', 1.f );
					}
				}
				
				// W3EE - Begin
				//Combat().CullAxiiLinkActors(targets[i], buff);
				// W3EE - End
				
				axiiPower.valueMultiplicative *= 1.0f - powerDec;
			}
		}
		
		casterActor.OnSignCastPerformed(ST_Axii, fireMode);
		
		//super.OnEnded();
	}
	
	event OnSignAborted( optional force : bool )
	{
		HAXX_AXII_ABORTED();
		super.OnSignAborted(force);
	}
	
	
	public function HAXX_AXII_ABORTED()
	{
		var i : int;
		
		for(i=0; i<slowdownTargets.Size(); i+=1)
		{
			RemoveMagic17Effect(slowdownTargets[i]);
		}
		RemoveMagic17Effect(orientationTarget);
	}
	
	
	public function OnDisplayTargetChange(newTarget : CActor)
	{
		var buffParams : SCustomEffectParams;
	
		
		if(!applySlowdown)
			return;
			
		if (slowdownTargets.Size() >= axiiCastLevel)
			return;
	 
		if(newTarget == orientationTarget)
			return;
			
		RemoveMagic17Effect(orientationTarget);
		orientationTarget = newTarget;
		
		AddMagic17Effect(orientationTarget, CalcSlowdown());			
	}
	
	private function AddMagic17Effect(target : CActor, slowdown : float)
	{
		var buffParams : SCustomEffectParams;
		
		if(!target || owner.GetActor() != GetWitcherPlayer() || !owner.CanUseSkill(S_Magic_s17, this))
			return;
		
		buffParams.effectType = EET_SlowdownAxii;
		buffParams.creator = this;
		buffParams.sourceName = "axii_immobilize";
		buffParams.duration = 10;
		buffParams.effectValue.valueAdditive = slowdown;
		buffParams.isSignEffect = true;
		
		target.AddEffectCustom(buffParams);
	}
	
	
	private function CalcSlowdown() : float
	{
		var slowdown : float;
		var axiiPower : SAbilityAttributeValue;
		
		axiiPower = super.GetTotalSignIntensity();
		slowdown = 0.785f + 0.015f * axiiCastLevel;
		
		slowdown = 1.0f - slowdown; // remaining speed
		
		if (axiiPower.valueMultiplicative >= 1.0f)
			slowdown /= axiiPower.valueMultiplicative;
		else if (axiiPower.valueMultiplicative >= 0)
			slowdown *= 2.0f - axiiPower.valueMultiplicative;
		else
			slowdown *= 2.0f;
			
		if (slowdown < 0.04f)
			slowdown = 0.04f;

		return 1.0f - slowdown;	
	}
	
	private function RemoveMagic17Effect(target : CActor)
	{
		if(target)
			target.RemoveBuff(EET_SlowdownAxii, true, "axii_immobilize");
	}
}

state AxiiCast in W3AxiiEntity extends NormalCast
{
	event OnEnded(optional isEnd : bool)
	{
		var player			: CR4Player;
		
		
		parent.OnEnded(isEnd);
		super.OnEnded(isEnd);
			
		player = caster.GetPlayer();
		
		if( player )
		{
			parent.ManagePlayerStamina();
			parent.ManageGryphonSetBonusBuff();
		}
		else
		{
			caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
		}
	}
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		parent.owner.GetActor().SetBehaviorVariable( 'axiiResisted', 0.f );
	}
	
	event OnThrowing()
	{
		if( super.OnThrowing() )
		{
			// W3EE - Begin
			Experience().AwardSignXP(parent.GetSignType(), 1.0f);
			// W3EE - End
			caster.GetActor().SetBehaviorVariable( 'bStopSign', 1.f );
		}
	}
	
	event OnSignAborted( optional force : bool )
	{
		parent.HAXX_AXII_ABORTED();
		parent.StopEffect( parent.effects[parent.fireMode].throwEffect );
		parent.StopEffect( parent.effects[parent.fireMode].castEffect );
		
		super.OnSignAborted(force);
	}
}

state AxiiChanneled in W3AxiiEntity extends Channeling
{
	event OnEnded(optional isEnd : bool)
	{
		
		parent.OnEnded(isEnd);
		super.OnEnded(isEnd);
	}
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		
		parent.owner.GetActor().SetBehaviorVariable( 'axiiResisted', 0.f );
		caster.OnDelayOrientationChange();
	}

	event OnProcessSignEvent( eventName : name )
	{
		if( eventName == 'axii_alternate_ready' )
		{
			
			
		}
		else
		{
			return parent.OnProcessSignEvent( eventName );
		}
		
		return true;
	}
	
	event OnThrowing()
	{
		if( super.OnThrowing() )
		// W3EE - Begin
		{
			ChannelAxii();	
			Experience().AwardSignXP(parent.GetSignType(), 1.0f);
		}
		// W3EE - End
	}
		
	event OnSignAborted( optional force : bool )
	{
		parent.HAXX_AXII_ABORTED();
		parent.StopEffect( parent.effects[parent.fireMode].throwEffect );
		parent.StopEffect( parent.effects[parent.fireMode].castEffect );

		if ( caster.IsPlayer() )
		{
			caster.GetPlayer().LockToTarget( false );
		}
	
		super.OnSignAborted( force );
	}
	
	// W3EE - Begin
	private var timeStamp : float;	default timeStamp = 0;
	entry function ChannelAxii()
	{	
		var DT : float = 0.006f;
		timeStamp = theGame.GetEngineTimeAsSeconds();
		while( Update(DT) )
		{
			Sleep(DT);
			DT = theGame.GetEngineTimeAsSeconds() - timeStamp;
			timeStamp = theGame.GetEngineTimeAsSeconds();
		}
	}
	// W3EE - End
}

