/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/
statemachine abstract class W3SignEntity extends CGameplayEntity
{
	
	protected 	var owner 				: W3SignOwner;
	protected 	var attachedTo 			: CEntity;
	protected 	var boneIndex 			: int;
	protected 	var fireMode 			: int;
	protected 	var skillEnum 			: ESkill;
	public    	var signType 			: ESignType;
	public    	var actionBuffs   		: array<SEffectInfo>;	
	editable  	var friendlyCastEffect	: name;
	protected		var cachedCost			: float;
	protected 	var usedFocus			: bool;
	
	// W3EE - Begin
	public var isFOACast : bool;
	protected var isFreeCast : bool;
	//protected var isMutagen17Consumed : bool;
	protected var signIntensity : SAbilityAttributeValue;
	
	protected function CheckForMutagen17Boost()
	{
		var witcher		: W3PlayerWitcher;
		var mutagen17	: W3Mutagen17_Effect;
		
		witcher = (W3PlayerWitcher)owner.GetActor();
		if(witcher && witcher.HasBuff(EET_Mutagen17))
		{
			mutagen17 = (W3Mutagen17_Effect)witcher.GetBuff(EET_Mutagen17);
			if(mutagen17.HasBoost("sign"))
			{
				mutagen17.ClearBoost();
				//isMutagen17Consumed = true;
			}
			
			FactsAdd("mutagen_17_sign", 1);
		}
	}

	public function GetTotalSignIntensity() : SAbilityAttributeValue
	{
		return signIntensity;
	}
	
	public function GetTotalSignIntensityFloat() : float
	{
		return signIntensity.valueMultiplicative;
	}
	
	public function GetActualOwner() : W3SignOwner
	{
		return owner;
	}
	// W3EE - End
	
	public function GetSignType() : ESignType
	{
		return ST_None;
	}
	
	event OnProcessSignEvent( eventName : name )
	{
		LogChannel( 'Sign', "Process anim event " + eventName );
		
		if( eventName == 'cast_begin' )
		{
			
			if(owner.GetActor() == thePlayer)
			{
				thePlayer.SetPadBacklightColorFromSign(GetSignType());				
			}
	
			OnStarted();
		}
		else if( eventName == 'cast_throw' )
		{
			OnThrowing();
		}
		else if( eventName == 'cast_end' )
		{
			OnEnded();
		}
		else if( eventName == 'cast_friendly_begin' )
		{
			Attach( true );
		}		
		else if( eventName == 'cast_friendly_throw' )
		{
			OnCastFriendly();
		}
		else
		{
			return false;
		}
		
		return true;
	}
	
	// W3EE - Begin
	protected function CacheSignStats( owner : W3SignOwner )
	{
		var witcher: W3PlayerWitcher;
		
		signIntensity = owner.GetActor().GetTotalSignSpellPower(GetSkill());
		witcher = (W3PlayerWitcher)owner.GetPlayer();
		if( witcher && witcher.CanUseSkill(S_Sword_s19) && witcher.GetStat(BCS_Focus) >= witcher.GetStatMax(BCS_Focus) )
		{
			isFOACast = true;
			signIntensity.valueMultiplicative += 0.25f;
		}
		else
			isFOACast = false;
	}
	
	public function Init( inOwner : W3SignOwner, prevInstance : W3SignEntity, optional skipCastingAnimation : bool, optional notPlayerCast : bool, optional freeCast : bool ) : bool
	// W3EE - End
	{
		var player : CR4Player;
		var focus : SAbilityAttributeValue;
		var witcher: W3PlayerWitcher;
		
		if( !signIntensity.valueMultiplicative )
			CacheSignStats(inOwner);
		
		owner = inOwner;
		fireMode = 0;
		witcher = (W3PlayerWitcher) owner.GetPlayer();
		GetSignStats();
		
		if ( skipCastingAnimation || owner.InitCastSign( this ) )
		{
			if(!notPlayerCast)
			{
				owner.SetCurrentlyCastSign( GetSignType(), this );				
				CacheActionBuffsFromSkill();
			}
			
			
			if ( !skipCastingAnimation )
			{
				AddTimer( 'BroadcastSignCast', 0.8, false, , , true );
			}
			
			// W3EE - Begin
			isFreeCast = freeCast;
			
			/*player = (CR4Player)owner.GetPlayer();
			if(player && !notPlayerCast && player.CanUseSkill(S_Perk_10))
			{
				focus = player.GetAttributeValue('focus_gain');
				
				if ( player.CanUseSkill(S_Sword_s20) )
				{
					focus += player.GetSkillAttributeValue(S_Sword_s20, 'focus_gain', false, true) * player.GetSkillLevel(S_Sword_s20);
				}
				player.GainStat(BCS_Focus, 0.1f * (1 + CalculateAttributeValue(focus)) );	
			}*/
			
			if( witcher && !notPlayerCast )
			{
				if( witcher.IsMutationActive( EPMT_Mutation1 ) )
				{
					PlayMutation1CastFX();
				}
				else if( witcher.IsMutationActive( EPMT_Mutation6 ) )
				{
					theGame.MutationHUDFeedback( MFT_PlayOnce );
				}
			}
			
			((W3Effect_SwordSignDancer)witcher.GetBuff(EET_SwordSignDancer)).RemoveSignAbility(GetSignType(), owner);
			// W3EE - End
			
 			return true;
		}
		else
		{
			owner.GetActor().SoundEvent( "gui_ingame_low_stamina_warning" );
			CleanUp();
			Destroy();
			return false;
		}
	}
	
	public final function PlayMutation1CastFX()
	{
		var i : int;
		var swordEnt : CItemEntity;
		var swordID : SItemUniqueId;
		var playerFx, swordFx : name;
		
		swordID = GetWitcherPlayer().GetHeldSword();
		if( thePlayer.inv.IsIdValid( swordID ) )
		{
			swordEnt = thePlayer.inv.GetItemEntityUnsafe( swordID );
			if( swordEnt )
			{
				
				if( ( W3AardEntity ) this )
				{
					playerFx = 'mutation_1_aard_power';
					swordFx = 'aard_power';
				}
				else if( ( W3IgniEntity ) this )
				{
					playerFx = 'mutation_1_igni_power';
					swordFx = 'igni_power';
				}
				else if( ( W3QuenEntity ) this )
				{
					playerFx = 'mutation_1_quen_power';
					swordFx = 'quen_power';
				}
				else if( ( W3YrdenEntity ) this )
				{
					playerFx = 'mutation_1_yrden_power';
					swordFx = 'yrden_power';
				}
				else
				{
					return;
				}
				
				thePlayer.PlayEffect( playerFx );
				swordEnt.PlayEffect( swordFx );
			}
		}
		
		
		theGame.MutationHUDFeedback( MFT_PlayRepeat );
	}
	
	
	event OnStarted()
	{
		var player : CR4Player;
		
		Attach();
		
		player = (CR4Player)owner.GetActor();
		if(player)
		{
			GetWitcherPlayer().FailFundamentalsFirstAchievementCondition();			
			player.AddTimer('ResetPadBacklightColorTimer', 2);
		}
	}
		
	
	event OnThrowing()
	{
		// W3EE - Begin
		var witcher : W3PlayerWitcher;
		var abilityName : name;
		
		witcher = (W3PlayerWitcher)owner.GetActor();
		
		if(witcher && witcher.HasBuff(EET_Mutagen22) && witcher.IsInCombat())
		{
			abilityName = witcher.GetBuff(EET_Mutagen22).GetAbilityName();
			witcher.AddAbility(abilityName, true);
		}
		// W3EE - End
	}
	
	
	event OnEnded(optional isEnd : bool)
	{
		var witcher : W3PlayerWitcher;
		var abilityName : name;
		var abilityCount, maxStack : float;
		var min, max : SAbilityAttributeValue;
		var addAbility : bool;
		var mutagen17 : W3Mutagen17_Effect;

		var camHeading : float;
		
		witcher = (W3PlayerWitcher)owner.GetActor();
		if(witcher && witcher.IsCurrentSignChanneled() && witcher.GetCurrentlyCastSign() != ST_Quen && witcher.bRAxisReleased )
		{
			if ( !witcher.lastAxisInputIsMovement )
			{
				camHeading = VecHeading( theCamera.GetCameraDirection() );
				if ( AngleDistance( GetHeading(), camHeading ) < 0 )
					witcher.SetCustomRotation( 'ChanneledSignCastEnd', camHeading + witcher.GetOTCameraOffset(), 0.0, 0.2, false );
				else
					witcher.SetCustomRotation( 'ChanneledSignCastEnd', camHeading - witcher.GetOTCameraOffset(), 0.0, 0.2, false );
			}
			witcher.ResetLastAxisInputIsMovement();
		}
		
		// W3EE - Begin
		
		if ( !((W3QuenEntity)this) && !((W3YrdenEntity)this) )
			CheckForMutagen17Boost();
		/*
		witcher = (W3PlayerWitcher)owner.GetActor();
		if(witcher && witcher.HasBuff(EET_Mutagen17))
		{
			 mutagen17 = (W3Mutagen17_Effect)witcher.GetBuff(EET_Mutagen17);
			 if(mutagen17.HasBoost())
			 {
				mutagen17.ClearBoost();
			 }
		}	
		
		if(witcher && witcher.HasBuff(EET_Mutagen22) && witcher.IsInCombat() && witcher.IsThreatened())
		{
			abilityName = witcher.GetBuff(EET_Mutagen22).GetAbilityName();
			abilityCount = witcher.GetAbilityCount(abilityName);
			
			if(abilityCount == 0)
			{
				addAbility = true;
			}
			else
			{
				theGame.GetDefinitionsManager().GetAbilityAttributeValue(abilityName, 'mutagen22_max_stack', min, max);
				maxStack = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
				
				if(maxStack >= 0)
				{
					addAbility = (abilityCount < maxStack);
				}
				else
				{
					addAbility = true;
				}
			}
			
			if(addAbility)
			{
				witcher.AddAbility(abilityName, true);
			}
		}
		*/
		// W3EE - End
		CleanUp();
	}

	
	
	
	event OnSignAborted( optional force : bool )
	{
		CleanUp();
		
		Destroy();
	}	

	event OnCheckChanneling()
	{
		return false;
	}

	public function GetOwner() : CActor
	{
		return owner.GetActor();
	}

	
	public function SkillUnequipped( skill : ESkill ){}
	
	
	public function SkillEquipped( skill : ESkill ){}

	
	public function OnNormalCast()
	{
		if(owner.GetActor() == thePlayer && GetWitcherPlayer().IsInitialized())
			theGame.VibrateControllerLight();	
	}

	public function SetAlternateCast( newSkill : ESkill )
	{
		fireMode = 1;
		skillEnum = newSkill;
		GetSignStats(); 
	}
	
	public function IsAlternateCast() : bool
	{
		return fireMode == 1;
	}

	protected function GetSignStats(){}
		
	protected function CleanUp()
	{	
		owner.RemoveTemporarySkills();
		
		
		if( (W3PlayerWitcher)owner.GetPlayer() && GetWitcherPlayer().IsMutationActive( EPMT_Mutation1 ) )
		{
			theGame.MutationHUDFeedback( MFT_PlayHide );
		}
	}
	
	public function GetUsedFocus() : bool
	{
		return usedFocus;
	}
	
	public function SetUsedFocus( b : bool )
	{
		usedFocus = b;
	}
			
	
	function Attach( optional toSlot : bool, optional toWeaponSlot : bool )
	{		
		var loc : Vector;
		var rot : EulerAngles;	
		var ownerActor : CActor;
		
		ownerActor = owner.GetActor();
		if ( toSlot )
		{
			if (!toWeaponSlot && ownerActor.HasSlot( 'sign_slot', true ) )
			{
				CreateAttachment( ownerActor, 'sign_slot' );			
			}
			else
			{
				CreateAttachment( ownerActor, 'l_weapon' );						
			}
			boneIndex = ownerActor.GetBoneIndex( 'l_weapon' );
			attachedTo = NULL;
		}
		else
		{
			
			
			attachedTo = ownerActor;
			boneIndex = ownerActor.GetBoneIndex( 'l_weapon' );
			
		}
		
		if ( attachedTo )
		{
			if ( boneIndex != -1 )
			{
				loc = MatrixGetTranslation( attachedTo.GetBoneWorldMatrixByIndex( boneIndex ) );
				
				
				if ( ownerActor == thePlayer && (W3AardEntity)this )
				{
					rot = VecToRotation( thePlayer.GetLookAtPosition() - MatrixGetTranslation( thePlayer.GetBoneWorldMatrixByIndex( thePlayer.GetHeadBoneIndex() ) ) );
					rot.Pitch = -rot.Pitch;
					if ( rot.Pitch < 0.f && ( thePlayer.GetPlayerCombatStance() == PCS_Normal || thePlayer.GetPlayerCombatStance() == PCS_AlertFar ) )
						rot.Pitch = 0.f;
					
					thePlayer.GetVisualDebug().AddSphere( 'signEntity', 0.3f, thePlayer.GetLookAtPosition(), true, Color( 255, 0, 0 ), 30.f ); 
					thePlayer.GetVisualDebug().AddArrow( 'signHeading', thePlayer.GetWorldPosition(), thePlayer.GetWorldPosition() + RotForward( rot )*4, 1.f, 0.2f, 0.2f, true, Color(0,128,128), true,10.f );
				}
				else
					rot = attachedTo.GetWorldRotation();
				
				
			}
			else
			{
				loc = attachedTo.GetWorldPosition();
				rot = attachedTo.GetWorldRotation();
			}
			
			
			TeleportWithRotation( loc, rot );
		}
		
		
		if ( owner.IsPlayer() )
		{
			
			
			
			
		}
	}
	
	function Detach()
	{
		BreakAttachment();
		attachedTo = NULL;
		boneIndex = -1;
	}
	
	
	public function InitSignDataForDamageAction( act : W3DamageAction)
	{
		act.SetSignSkill( skillEnum );
		FillActionDamageFromSkill( act );
		FillActionBuffsFromSkill( act );
	}	
	
	private function FillActionDamageFromSkill( act : W3DamageAction )
	{
		var attrs : array< name >;
		var i, size : int;
		var val : float;
		var dm : CDefinitionsManagerAccessor;
		var sp : SAbilityAttributeValue;
		
		if ( !act )
		{
			LogSigns( "W3SignEntity.FillActionDamageFromSkill: action does not exist!" );
			return;
		}
				
		dm = theGame.GetDefinitionsManager();
		dm.GetAbilityAttributes( owner.GetSkillAbilityName( skillEnum ), attrs );
		size = attrs.Size();
		
		for ( i = 0; i < size; i += 1 )
		{
			if ( IsDamageTypeNameValid( attrs[i] ) )
			{
				val = CalculateAttributeValue( owner.GetSkillAttributeValue( skillEnum, attrs[i], false, true ) );
				// W3EE - Begin
				if( owner.IsPlayer() )
				{
					sp = GetTotalSignIntensity();
					if ( GetSignType() == ST_Igni && !IsAlternateCast() )
						val = 750.f * sp.valueMultiplicative;
				}
				// W3EE - End
				act.AddDamage( attrs[i], val );
			}
		}
	}
	
	protected function FillActionBuffsFromSkill(act : W3DamageAction)
	{
		var i : int;
		
		for(i=0; i<actionBuffs.Size(); i+=1)
			act.AddEffectInfo(actionBuffs[i].effectType, , , actionBuffs[i].effectAbilityName);
	}
	
	protected function CacheActionBuffsFromSkill()
	{
		var attrs : array< name >;
		var i, size : int;
		var signAbilityName : name;
		var dm : CDefinitionsManagerAccessor;
		var buff : SEffectInfo;
		
		actionBuffs.Clear();
		dm = theGame.GetDefinitionsManager();
		signAbilityName = owner.GetSkillAbilityName( skillEnum );
		dm.GetContainedAbilities( signAbilityName, attrs );
		size = attrs.Size();
		
		for( i = 0; i < size; i += 1 )
		{
			if( IsEffectNameValid(attrs[i]) )
			{
				EffectNameToType(attrs[i], buff.effectType, buff.effectAbilityName);
				actionBuffs.PushBack(buff);
			}		
		}
	}
	
	public function GetSkill() : ESkill
	{
		return skillEnum;
	}
	
	timer function BroadcastSignCast( deltaTime : float , id : int)
	{		
		
		if ( owner.IsPlayer() )
		{			
			theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( thePlayer, 'CastSignAction', -1, 8.0f, -1.f, -1, true ); 
			if ( GetSignType() == ST_Aard )
			{
				theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( this, 'CastSignActionFar', -1, 30.0f, -1.f, -1, true ); 
			}
			LogReactionSystem( "'CastSignAction' was sent by Player - single broadcast - distance: 10.0" ); 
		}
		
		BroadcastSignCast_Override();
	}	
	
	function BroadcastSignCast_Override()
	{
	}

	event OnCastFriendly()
	{
		PlayEffect( friendlyCastEffect );
		AddTimer('DestroyCastFriendlyTimer', 0.1, true, , , true);
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( thePlayer, 'CastSignAction', -1, 8.0f, -1.f, -1, true ); 
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( this, 'CastSignActionFar', -1, 30.0f, -1.f, -1, true ); 
		thePlayer.GetVisualDebug().AddSphere( 'dsljkfadsa', 0.5f, this.GetWorldPosition(), true, Color( 0, 255, 255 ), 10.f );
	}
	
	timer function DestroyCastFriendlyTimer(dt : float, id : int)
	{
		var active : bool;

		active = IsEffectActive( friendlyCastEffect );
			
		if(!active)
		{
			Destroy();
		}
	}
	
	public function ManagePlayerStamina()
	{
		var l_player			: W3PlayerWitcher;
		var l_cost, l_stamina	: float;
		var l_gryphonBuff		: W3Effect_GryphonSetBonus;
		
		l_player = owner.GetPlayer();
		
		l_gryphonBuff = (W3Effect_GryphonSetBonus)l_player.GetBuff( EET_GryphonSetBonus );
		l_gryphonBuff.SetWhichSignForFree( this );
		
		// W3EE - Begin
		l_cost = 0;
		if( !isFreeCast )
		{
			if( !l_gryphonBuff || l_gryphonBuff.GetWhichSignForFree() != this )
			{
				if( l_player.CanUseSkill(S_Sword_s19) && l_player.GetStat(BCS_Focus) >= l_player.GetStatMax(BCS_Focus) )
					l_cost += 2.f;
				
				if( l_player.CanUseSkill( S_Perk_09 ) )
				{
					if( l_player.GetStat(BCS_Focus) >= 1 )
						l_cost += 1.f;
					else
						l_player.DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( skillEnum ) );
				}
				else l_cost += 1.f;
			}
			
			if( ((W3Effect_SwordCritVigor)l_player.GetBuff(EET_SwordCritVigor)).GetReductionActive() )
			{
				((W3Effect_SwordCritVigor)l_player.GetBuff(EET_SwordCritVigor)).SetReductionActive(false);
				l_cost *= 0.6;
			}
		}
		l_player.DrainFocus(l_cost);
		// W3EE - End
	}
	
	public function ManageGryphonSetBonusBuff()
	{
		var l_player		: W3PlayerWitcher;
		var l_gryphonBuff	: W3Effect_GryphonSetBonus;
		
		l_player = owner.GetPlayer();
		l_gryphonBuff = (W3Effect_GryphonSetBonus)l_player.GetBuff( EET_GryphonSetBonus );		
		
		if( l_player && l_player.IsSetBonusActive( EISB_Gryphon_1 ) && !l_gryphonBuff && !usedFocus )
		{			
			l_player.AddEffectDefault( EET_GryphonSetBonus, NULL, "gryphonSetBonus" );
		}
		else if( l_gryphonBuff && l_gryphonBuff.GetWhichSignForFree() == this )
		{
			l_player.RemoveBuff( EET_GryphonSetBonus, false, "gryphonSetBonus" );
		}
	}
}

state Finished in W3SignEntity
{
	event OnEnterState( prevStateName : name )
	{
		var player			: W3PlayerWitcher;
		
		player = GetWitcherPlayer();	
		
		
		parent.DestroyAfter( 8.f );
		
		if ( parent.owner.IsPlayer() )
		{
			
			parent.owner.GetPlayer().GetMovingAgentComponent().EnableVirtualController( 'Signs', false );	
		}
		parent.CleanUp();
	}
	
	event OnLeaveState( nextStateName : name )
	{
		if ( parent.owner.IsPlayer() )
		{
			parent.owner.GetPlayer().RemoveCustomOrientationTarget( 'Signs' );
		}
	}
	
	event OnSignAborted( optional force : bool )
	{
		
	}
}

state Active in W3SignEntity
{
	var caster : W3SignOwner;
	
	event OnEnterState( prevStateName : name )
	{
		caster = parent.owner;
	}
	
	event OnSignAborted( optional force : bool )
	{
		
		if( force )
		{
			parent.StopAllEffects();
			parent.GotoState( 'Finished' );
		}
	}
}

state BaseCast in W3SignEntity
{
	var caster : W3SignOwner;
	
	event OnEnterState( prevStateName : name )
	{
		caster = parent.owner;
		if ( caster.IsPlayer() && !( (W3QuenEntity)parent || (W3YrdenEntity)parent ) )
			caster.GetPlayer().GetMovingAgentComponent().EnableVirtualController( 'Signs', true );
	}
	
	event OnLeaveState( nextStateName : name )
	{
		caster.GetActor().SetBehaviorVariable( 'IsCastingSign', 0 );
		caster.SetCurrentlyCastSign( ST_None, NULL );
		LogChannel( 'ST_None', "ST_None" );
	}
	
	event OnThrowing()
	{		
		var l_player : W3PlayerWitcher;
		var l_gryphonBuff : W3Effect_GryphonSetBonus;
		
		l_player = caster.GetPlayer();
		
		if( l_player )
		{
			FactsAdd("ach_sign", 1, 4 );		
			theGame.GetGamerProfile().CheckLearningTheRopes();
			
			l_gryphonBuff = (W3Effect_GryphonSetBonus)l_player.GetBuff( EET_GryphonSetBonus );
			
			if( l_gryphonBuff && !l_gryphonBuff.GetWhichSignForFree() )
			{
				l_gryphonBuff.SetWhichSignForFree( parent );
			}
			
		}
		
		// W3EE - Begin
		parent.OnThrowing();
		// W3EE - End
		
		return true;
	}
	
	event OnEnded(optional isEnd : bool)
	{
		parent.OnEnded(isEnd);
		parent.GotoState( 'Finished' );
	}
	
	event OnSignAborted( optional force : bool )
	{
		var l_gryphonBuff	: W3Effect_GryphonSetBonus;
		
		l_gryphonBuff = (W3Effect_GryphonSetBonus)caster.GetActor().GetBuff( EET_GryphonSetBonus );
		if( l_gryphonBuff )
		{
			l_gryphonBuff.SetWhichSignForFree( NULL );
		}
		
		parent.CleanUp();
		parent.StopAllEffects();
		parent.GotoState( 'Finished' );
	}
}

state NormalCast in W3SignEntity extends BaseCast
{
	event OnEnterState( prevStateName : name )
	{
		var player : CR4Player;
		var cost, stamina : float;
		
		super.OnEnterState(prevStateName);
		
		
		
		return true;
	}
	
	event OnEnded(optional isEnd : bool)
	{
		var player : CR4Player;
		var cost, stamina : float;
		
		
		
		super.OnEnded(isEnd);
	}
}

state Channeling in W3SignEntity extends BaseCast
{
	event OnEnterState( prevStateName : name )
	{
		
		super.OnEnterState( prevStateName );
		parent.cachedCost = -1.0f;
		
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( parent.owner.GetActor(), 'CastSignAction', -1, 8.0f, 0.2f, -1, true );
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( parent, 'CastSignActionFar', -1, 30.0f, -1.f, -1, true );
	}

	event OnLeaveState( nextStateName : name )
	{
		caster.GetActor().ResumeStaminaRegen( 'SignCast' );
		
		theGame.GetBehTreeReactionManager().RemoveReactionEvent( parent.owner.GetActor(), 'CastSignAction' );
		theGame.GetBehTreeReactionManager().RemoveReactionEvent( parent, 'CastSignActionFar' );
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( parent.owner.GetActor(), 'CastSignAction', -1, 8.0f, -1.f, -1, true );
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( parent, 'CastSignActionFar', -1, 30.0f, -1.f, -1, true );
		
		
		super.OnLeaveState( nextStateName );
	}
	
	event OnThrowing()
	{
		var actor : CActor;
		var player : CR4Player;
		var stamina : float;
		
		if( super.OnThrowing() )
		{
			actor = caster.GetActor();
			player = (CR4Player)actor;
			
			// W3EE - Begin
			if( !parent.isFreeCast )
			{
				if(player)
				{
					if( parent.cachedCost <= 0.0f )
					{
						parent.cachedCost = player.GetStaminaActionCost( ESAT_Ability, SkillEnumToName( parent.skillEnum ), 0 );
					}
					
					stamina = player.GetStat(BCS_Stamina);
					
					// W3EE - Begin
					//if ( theInput.GetActionValue( 'CastSignHold' ) < 1.f )
					if( !GetWitcherPlayer().GetIsAlternateCast() )
					// W3EE - End
					{
						if( player.CanUseSkill(S_Sword_s19) && player.GetStat(BCS_Focus) >= 3 )
							player.DrainFocus(2.0f);
						
						if( player.GetStat(BCS_Focus) >= 1 )
							player.DrainFocus(1.0f);
						else
						if( player.CanUseSkill( S_Perk_09 ) && parent.cachedCost <= stamina && player.GetStat(BCS_Focus, true) < 1 )
						{
							player.DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
							player.StartStaminaRegen();
							player.PauseStaminaRegen( 'SignCast' );
						}
					}
				}
				else
				{
					actor.DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ) );
					actor.StartStaminaRegen();
					actor.PauseStaminaRegen( 'SignCast' );
				}
			}
			// W3EE - End
				
			return true;
		}
		
		return false;
	}
	
	event OnCheckChanneling()
	{
		return true;
	}
	
	
	// W3EE - Begin
	function Update(dt : float) : bool
	{
		var multiplier, stamina, leftStaminaCostPerc, leftStaminaCost, focus : float;
		// W3EE - End
		var player : CR4Player;
		var reductionCounter : int;
		var stop, abortAxii : bool;
		var costReduction : SAbilityAttributeValue;
		
		player = caster.GetPlayer();
		abortAxii = false;
		
		if(player)
		{
			if( player.HasBuff( EET_Mutation11Buff ) )
			{
				return true;
			}
			
			stop = false;
			if( ShouldStopChanneling() )
			{
				stop = true;
				abortAxii = true;
			}
			else
			{
			// W3EE - Begin
				if(player.CanUseSkill(S_Perk_09))
				{
					if(player.GetStat( BCS_Stamina ) <= 5 && player.GetStat(BCS_Focus) <= 0)
						stop = true;
				}
				else
				{
					stop = (player.GetStat(BCS_Focus) <= 0);
				}
			// W3EE - End
			}
		}		
		
		if(stop)
		{
			if( parent.skillEnum == S_Magic_s05 && abortAxii )		
			{
				OnSignAborted( true );
			}
			else
			{
				OnEnded();
			}
			
			return false;
		}
		else
		{
			if(player && !((W3QuenEntity)parent) )	
			{
				theGame.VibrateControllerLight();	
			}
			
			
			reductionCounter = caster.GetSkillLevel(virtual_parent.skillEnum, parent) - 1;
			multiplier = 1;
			if(reductionCounter > 0)
			{
				costReduction = caster.GetSkillAttributeValue(virtual_parent.skillEnum, 'stamina_cost_reduction_after_1', false, false) * reductionCounter;
				multiplier = 1 - costReduction.valueMultiplicative;
			}
			
			
			if (!(virtual_parent.GetSignType() == ST_Quen && caster.CanUseSkill(S_Magic_s04, parent) && multiplier == 0))
			{
				if(player)
				{
					if( parent.cachedCost <= 0.0f )
					{	
						parent.cachedCost = multiplier * player.GetStaminaActionCost( ESAT_Ability, SkillEnumToName( parent.skillEnum ), dt );
					}
					
					stamina = player.GetStat(BCS_Stamina);
					// W3EE - Begin
					focus = player.GetStat(BCS_Focus);
					// W3EE - End
				}
			}
			
			// W3EE - Begin
			if ( player )
			{
				if(multiplier > 0.f)
				{
					if( parent.isFOACast )
						player.DrainFocus(parent.cachedCost * multiplier * 6, dt);
					else
						player.DrainFocus(parent.cachedCost * multiplier * 2, dt);
					
					if( /*parent.cachedCost < stamina &&*/ player.CanUseSkill( S_Perk_09 ) && focus <= 0 )
					{
							player.DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ), dt, multiplier );
							player.PauseStaminaRegen('SignCast');
					}
				}
			}
			else
			{
				if(multiplier > 0.f)
					caster.GetActor().DrainStamina( ESAT_Ability, 0, 0, SkillEnumToName( parent.skillEnum ), dt, multiplier );
			}
			// W3EE - End
			caster.OnProcessCastingOrientation( true );
		}
		return true;
	}
	
	protected function ShouldStopChanneling() : bool
	{
		var currentInputContext : name;
		
		// W3EE - Begin
		//if ( theInput.GetActionValue( 'CastSignHold' ) > 0.f )
		if( GetWitcherPlayer().GetIsAlternateCast() )
		// W3EE - End
		{
			return false;
		}
		else if( caster.GetPlayer().HasBuff( EET_Mutation11Buff ) )
		{
			return false;
		}
		else
		{
			return true;
		}
		
	}
}
