/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/

class W3AardProjectile extends W3SignProjectile
{
	protected var staminaDrainPerc : float;
	
	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var projectileVictim : CProjectileTrajectory;
		
		projectileVictim = (CProjectileTrajectory)collidingComponent.GetEntity();
		
		if( projectileVictim )
		{
			projectileVictim.OnAardHit( this );
		}
		
		super.OnProjectileCollision( pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex );
	}
	
	protected function ProcessCollision( collider : CGameplayEntity, pos, normal : Vector )
	{
		var dmgVal : float;
		var sp : SAbilityAttributeValue;
		var isMutation6 : bool;
		var victimNPC : CNewNPC;
		var altLevel : int;
	
		
		if ( hitEntities.FindFirst( collider ) != -1 )
		{
			return;
		}
		
		
		hitEntities.PushBack( collider );
	
		super.ProcessCollision( collider, pos, normal );
		
		victimNPC = (CNewNPC) collider;
		
		
		if( IsRequiredAttitudeBetween(victimNPC, caster, true ) )
		{
			isMutation6 = ( ( W3PlayerWitcher )owner.GetPlayer() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation6 ) );
			
			// W3EE - Begin
			if( owner.GetPlayer().IsSwimming() )
				action.AddDamage(theGame.params.DAMAGE_NAME_FORCE, 20000.f);
				
			if( isMutation6 )
			{
				action.SetBuffSourceName( "Mutation6" );
			}		
			else if ( owner.CanUseSkill(S_Magic_s06, GetSignEntity()) )		
			{			
				sp = GetSignEntity().GetTotalSignIntensity();
				dmgVal = owner.GetSkillLevel(S_Magic_s06, GetSignEntity()) * 250.f;
				dmgVal *= sp.valueMultiplicative;
				
				if( signEntity.IsAlternateCast() ) {
				
					if( owner.GetSkillLevel(S_Magic_s12, GetSignEntity()) > 2 )
						dmgVal *= 1.5f;
				
					if ( (W3PlayerWitcher) owner.GetPlayer() )
						altLevel = owner.GetSkillLevel(S_Magic_s01);
					else
						altLevel = 0;
						
					if (altLevel == 3)
						dmgVal /= 3;
					else if (altLevel == 2)
						dmgVal /= 4;
					else if (altLevel == 1)
						dmgVal /= 6;
					else
						dmgVal /= 5;
				}
				action.AddDamage( theGame.params.DAMAGE_NAME_FORCE, dmgVal );
			}
			// W3EE - End
		}
		else
		{
			isMutation6 = false;
		}
		
		action.SetHitAnimationPlayType(EAHA_ForceNo);
		action.SetProcessBuffsIfNoDamage(true);
		
		
		if ( !owner.IsPlayer() )
		{
			action.AddEffectInfo( EET_KnockdownTypeApplicator );
		}
		
		
		
		
		
		
		theGame.damageMgr.ProcessAction( action );
		
		collider.OnAardHit( this );
		
		
		if( isMutation6 && victimNPC && victimNPC.IsAlive() )
		{
			ProcessMutation6( victimNPC );
		}
	}
	
	private final function ProcessMutation6( victimNPC : CNewNPC )
	{
		var result : EEffectInteract;
		var mutationAction : W3DamageAction;
		var min, max : SAbilityAttributeValue;
		var dmgVal : float;
		var instaKill, hasKnockdown, applySlowdown : bool;
		var altLevel : int;
				
		// W3EE - Begin
		var sp : SAbilityAttributeValue;
		// W3EE - End
		
		instaKill = false;
		hasKnockdown = victimNPC.HasBuff( EET_Knockdown ) || victimNPC.HasBuff( EET_HeavyKnockdown ) || victimNPC.GetIsRecoveringFromKnockdown();
		
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation6', 'full_freeze_chance', min, max );
		if( RandF() >= min.valueMultiplicative )
		{
			
			applySlowdown = true;			
			instaKill = false;
		}
		else
		{
			
			if( victimNPC.IsImmuneToInstantKill() )
			{
				result = EI_Deny;
			}
			else
			{
				result = victimNPC.AddEffectDefault( EET_Frozen, this, "Mutation 6", true );
			}
			
			
			if( EffectInteractionSuccessfull( result ) && hasKnockdown )				
			{
				
				mutationAction = new W3DamageAction in theGame.damageMgr;
				mutationAction.Initialize( action.attacker, victimNPC, this, "Mutation 6", EHRT_None, CPS_Undefined, false, false, true, false );
				mutationAction.SetInstantKill();
				mutationAction.SetForceExplosionDismemberment();
				mutationAction.SetIgnoreInstantKillCooldown();
				theGame.damageMgr.ProcessAction( mutationAction );
				delete mutationAction;
				instaKill = true;
			}
		}
		
		if( applySlowdown && !hasKnockdown )
		{
			victimNPC.AddEffectDefault( EET_SlowdownFrost, this, "Mutation 6", true );
		}
		
		
		if( !instaKill && !victimNPC.HasBuff( EET_Frozen ) )
		{		
			// W3EE - Begin
			sp = GetSignEntity().GetTotalSignIntensity();
			if ( owner.CanUseSkill(S_Magic_s06, GetSignEntity()) )
			{
				sp = GetSignEntity().GetTotalSignIntensity();
				dmgVal = owner.GetSkillLevel(S_Magic_s06, GetSignEntity()) * 250.f;
				dmgVal *= sp.valueMultiplicative;
				
				if( signEntity.IsAlternateCast() )
				{
					if( owner.GetSkillLevel(S_Magic_s12, GetSignEntity()) > 2 )
						dmgVal *= 1.5f;
					
					if ( (W3PlayerWitcher) owner.GetPlayer() )
						altLevel = owner.GetSkillLevel(S_Magic_s01);
					else
						altLevel = 0;
						
					if (altLevel == 3)
						dmgVal /= 3;
					else if (altLevel == 2)
						dmgVal /= 4;
					else if (altLevel == 1)
						dmgVal /= 6;
					else
						dmgVal /= 5;
				}
				action.AddDamage( theGame.params.DAMAGE_NAME_FORCE, dmgVal );
			}
			
			// theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation6', 'ForceDamage', min, max );
			dmgVal = 350.f * sp.valueMultiplicative; // CalculateAttributeValue( min );
			action.AddDamage( theGame.params.DAMAGE_NAME_FROST, dmgVal );
			// W3EE - End
			
			action.ClearEffects();
			action.SetProcessBuffsIfNoDamage( false );
			action.SetForceExplosionDismemberment();
			action.SetIgnoreInstantKillCooldown();
			action.SetBuffSourceName( "Mutation 6" );
			theGame.damageMgr.ProcessAction( action );
		}
	}
	
	event OnAttackRangeHit( entity : CGameplayEntity )
	{
		entity.OnAardHit( this );
	}
	
	public final function GetStaminaDrainPerc() : float
	{
		return staminaDrainPerc;
	}
	
	public final function SetStaminaDrainPerc(p : float)
	{
		staminaDrainPerc = p;
	}
}



class W3AxiiProjectile extends W3SignProjectile
{
	protected function ProcessCollision( collider : CGameplayEntity, pos, normal : Vector )
	{
		DestroyAfter( 3.f );
		
		collider.OnAxiiHit( this );	
		
	}
	
	protected function ShouldCheckAttitude() : bool
	{
		return false;
	}
}

class W3IgniProjectile extends W3SignProjectile
{
	private var channelCollided : bool;
	private var dt : float;	
	private var isUsed : bool;
	
	default channelCollided = false;
	default isUsed = false;
	
	// W3EE - Begin
	public function GetSignEntity() : W3SignEntity
	{
		return signEntity;
	}
	// W3EE - End
	
	public function SetDT(d : float)
	{
		dt = d;
	}

	public function IsUsed() : bool
	{
		return isUsed;
	}

	public function SetIsUsed( used : bool )
	{
		isUsed = used;
	}

	event OnProjectileCollision( pos, normal : Vector, collidingComponent : CComponent, hitCollisionsGroups : array< name >, actorIndex : int, shapeIndex : int )
	{
		var rot, rotImp : EulerAngles;
		var v, posF, pos2, n : Vector;
		var igniEntity : W3IgniEntity;
		var ent, colEnt : CEntity;
		var template : CEntityTemplate;
		var f : float;
		var test : bool;
		var postEffect : CGameplayFXSurfacePost;
		
		channelCollided = true;
		
		
		igniEntity = (W3IgniEntity)signEntity;
		
		if(signEntity.IsAlternateCast())
		{			
			
			test = (!collidingComponent && hitCollisionsGroups.Contains( 'Terrain' ) ) || (collidingComponent && !((CActor)collidingComponent.GetEntity()));
			
			colEnt = collidingComponent.GetEntity();
			if( (W3BoltProjectile)colEnt || (W3SignEntity)colEnt || (W3SignProjectile)colEnt )
				test = false;
			
			if(test)
			{
				f = theGame.GetEngineTimeAsSeconds();
				
				if(f - igniEntity.lastFxSpawnTime >= 1)
				{
					igniEntity.lastFxSpawnTime = f;
					
					template = (CEntityTemplate)LoadResource( "igni_object_fx" );
					
					
					rot.Pitch	= AcosF( VecDot( Vector( 0, 0, 0 ), normal ) );
					rot.Yaw		= this.GetHeading();
					rot.Roll	= 0.0f;
					
					
					posF = pos + VecNormalize(pos - signEntity.GetWorldPosition());
					if(theGame.GetWorld().StaticTrace(pos, posF, pos2, n, igniEntity.projectileCollision))
					{					
						ent = theGame.CreateEntity(template, pos2, rot );
						ent.AddTimer('TimerStopVisualFX', 5, , , , true);
						
						postEffect = theGame.GetSurfacePostFX();
						postEffect.AddSurfacePostFXGroup( pos2, 0.5f, 8.0f, 10.0f, 0.3f, 1 );
					}
				}				
			}
			
			
			if ( !hitCollisionsGroups.Contains( 'Water' ) )
			{
				
				v = GetWorldPosition() - signEntity.GetWorldPosition();
				rot = MatrixGetRotation(MatrixBuildFromDirectionVector(-v));
				
				igniEntity.ShowChannelingCollisionFx(GetWorldPosition(), rot, -v);
			}
		}
		
		return super.OnProjectileCollision(pos, normal, collidingComponent, hitCollisionsGroups, actorIndex, shapeIndex);
	}

	protected function ProcessCollision( collider : CGameplayEntity, pos, normal : Vector )
	{
		var signPower, channelDmg : SAbilityAttributeValue;
		var burnChance : float;					
		var maxArmorReduction : float;			
		var applyNbr : int;						
		var i : int;
		var npc : CNewNPC;
		var armorRedAblName : name;
		var actorVictim : CActor;
		var ownerActor : CActor;
		var dmg : float;
		var performBurningTest : bool;
		var igniEntity : W3IgniEntity;
		var postEffect : CGameplayFXSurfacePost = theGame.GetSurfacePostFX();
		// W3EE - Begin
		var armorRedAttr : SAbilityAttributeValue;
		var currentReduction, perHitReduction, armorRedVal, pts, prc, reductionFactor, maxReductionFactor : float;
		// W3EE - End
		
		postEffect.AddSurfacePostFXGroup( pos, 0.5f, 8.0f, 10.0f, 2.5f, 1 );
		
		
		if ( hitEntities.Contains( collider ) )
		{
			return;
		}
		hitEntities.PushBack( collider );		
		
		super.ProcessCollision( collider, pos, normal );	
		
		ownerActor = owner.GetActor();
		actorVictim = ( CActor ) action.victim;
		npc = (CNewNPC)collider;
		
		signPower = signEntity.GetTotalSignIntensity();
		if(signEntity.IsAlternateCast())		
		{
			igniEntity = (W3IgniEntity)signEntity;
			// W3EE - Begin
			performBurningTest = false;
			if(!actorVictim.HasBuff(EET_Burning))
				performBurningTest = igniEntity.UpdateBurningChance(actorVictim, dt);
			// W3EE - End
			
			
			
			// signPower = signEntity.GetTotalSignIntensity();
			if( igniEntity.hitEntities.Contains( collider ) )
			{
				channelCollided = true;
				action.SetHitEffect('');
				action.SetHitEffect('', true );
				action.SetHitEffect('', false, true);
				action.SetHitEffect('', true, true);
				action.ClearDamage();
				
				
				// W3EE - Begin
				// channelDmg = owner.GetSkillAttributeValue(signSkill, 'channeling_damage', false, true);
				dmg = 630.f * signPower.valueMultiplicative;
				// W3EE - End
				dmg *= dt;
				action.AddDamage(theGame.params.DAMAGE_NAME_FIRE, dmg);
				action.SetIsDoTDamage(dt);
				
				if(!collider)	
					return;
			}
			else
			{
				igniEntity.hitEntities.PushBack( collider );
			}
			
			if(!performBurningTest)
			{
				action.ClearEffects();
			}
		}
		
		
		if ( npc && npc.IsShielded( ownerActor ) )
		{
			collider.OnIgniHit( this );	
			return;
		}
		
		
		// signPower = ownerActor.GetTotalSignSpellPower(S_Magic_s02);

		
		if ( !owner.IsPlayer() )
		{
			signPower = ownerActor.GetTotalSignSpellPower(S_Magic_s02);
			burnChance = signPower.valueMultiplicative;
			if ( RandF() < burnChance )
			{
				action.AddEffectInfo(EET_Burning);
			}
			
			dmg = CalculateAttributeValue(signPower);
			if ( dmg <= 0 )
			{
				dmg = 20;
			}			
			action.AddDamage( theGame.params.DAMAGE_NAME_FIRE, dmg);
		}
		
		if(signEntity.IsAlternateCast())
		{
			action.SetHitAnimationPlayType(EAHA_ForceNo);
		}
		else		
		{
			action.SetHitEffect('igni_cone_hit', false, false);
			action.SetHitEffect('igni_cone_hit', true, false);
			action.SetHitReactionType(EHRT_Igni, false);
		}
		
		theGame.damageMgr.ProcessAction( action );	
		
		
		// W3EE - Begin
		if ( owner.CanUseSkill(S_Magic_s08, GetSignEntity()) && npc && npc.IsProtectedByArmor() )
		{	
			prc = npc.GetNPCCustomStat(theGame.params.DAMAGE_NAME_FIRE);
			
			maxArmorReduction = CalculateAttributeValue(owner.GetSkillAttributeValue(S_Magic_s08, 'max_armor_reduction', false, true)) * GetSignEntity().GetActualOwner().GetSkillLevel(S_Magic_s08, GetSignEntity());
			maxReductionFactor = 0.05f * signPower.valueMultiplicative;
			reductionFactor = MinF(1, maxReductionFactor * MaxF(0.25f, 1 - prc));
			if( signEntity.IsAlternateCast() )
			{
				reductionFactor = MinF(1, reductionFactor * dt);
			}
			
			reductionFactor = ClampF(reductionFactor, 0.f, maxArmorReduction - npc.GetTotalArmorReduction()) * -1.f;
			npc.ModifyArmorValue(reductionFactor);
			// W3EE - End
		}	
		collider.OnIgniHit( this );		
	}	

	event OnAttackRangeHit( entity : CGameplayEntity )
	{
		entity.OnIgniHit( this );
	}

	
	event OnRangeReached()
	{
		var v : Vector;
		var rot : EulerAngles;
				
		
		if(!channelCollided)
		{			
			
			v = GetWorldPosition() - signEntity.GetWorldPosition();
			rot = MatrixGetRotation(MatrixBuildFromDirectionVector(-v));
			((W3IgniEntity)signEntity).ShowChannelingRangeFx(GetWorldPosition(), rot);
		}
		
		isUsed = false;
		
		super.OnRangeReached();
	}
	
	public function IsProjectileFromChannelMode() : bool
	{
		return signSkill == S_Magic_s02;
	}
}