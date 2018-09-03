class CWitcherCampfire extends W3Campfire
{
	default dontCheckForNPCs = true;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);
	}
	
	event OnDestroyed()
	{
		super.OnDestroyed();
	}
	
	event OnInteractionActivated( interactionComponentName : string, activator : CEntity )
	{
		super.OnInteractionActivated(interactionComponentName, activator);
	}
	
	event OnInteractionDeactivated( interactionComponentName : string, activator : CEntity )
	{
		super.OnInteractionDeactivated(interactionComponentName, activator);
	}
	
	public function PlayFireEffect( idx : int )
	{
		if( idx == 1 )
			PlayEffect('fire');
		else
		if( idx == 2 )
			PlayEffect('fire_01');
		else
			PlayEffect('fire_big');
	}
}

exec function playfireeffects( idx : int )
{
		if( idx == 1 )
			CampfireManager().GetPlayerCampfire().PlayEffect('fire');
		else
		if( idx == 2 )
			CampfireManager().GetPlayerCampfire().PlayEffect('fire_01');
		else
			CampfireManager().GetPlayerCampfire().PlayEffect('fire_big');
}

statemachine class CWitcherCampfireManager
{
	protected var alternateFireSource						: CGameplayLightComponent;
	protected var witcherCampfire 							: W3Campfire;
	private var playerWitcher								: W3PlayerWitcher;
	private var fireMode									: int;
	private var noFireMode									: bool;
	
	protected const var CAMPFIRE_SPAWN_DELAY				: float;
	protected const var KINDLE_DELAY						: float;
	protected const var KINDLE_DELAY_EXISTING				: float;
	protected const var EXTINGUISH_DELAY					: float;
	protected const var CAMPFIRE_DESTRUCTION_DELAY			: float;
	
	default KINDLE_DELAY = 1.43f;
	default KINDLE_DELAY_EXISTING = 5.f;
	default CAMPFIRE_SPAWN_DELAY = 3.57f;
	default EXTINGUISH_DELAY = 1.5f;
	default CAMPFIRE_DESTRUCTION_DELAY = 1.9f;
	
	/*
	-2 		- stand up
	-1 		- stand up and put out
	0		- meditate no lighting
	1		- meditate lighting and campfire
	2		- meditate lighting
	*/
	public function ManageFire( noFireCall : bool ) : int
	{
		noFireMode = noFireCall;
		if( GetCurrentStateName() == 'Lit' )
		{
			fireMode = -1;
			GotoState('Extinguished');
		}
		else
		if( GetCurrentStateName() == 'Idle' )
		{
			fireMode = -2;
			GotoState('Extinguished');
		}
		else
		{
			fireMode = GetFireMode();
			if( fireMode == 1 )
				GotoState('Spawned');
			else
			if( fireMode == 2 )
				GotoState('Lit');
			else
				GotoState('Idle');
		}
		
		return fireMode;
	}
	
	public function Init( player : W3PlayerWitcher )
	{
		playerWitcher = player;
	}
	
	public function CanPerformAlchemy( optional alchemist : bool ) : bool
	{
		if( alchemist || Options().GetPerformAlchemyAnywhere() )
			return true;
		else
			return ( (alternateFireSource || witcherCampfire) && (alternateFireSource.IsLightOn() || witcherCampfire.IsOnFire()) && (VecDistanceSquared( GetPlayerPosition(), GetFirePosition() ) <= 4) && GetPlayer().IsMeditating() );
	}
	
	public function GetPlayerCampfire() : W3Campfire
	{
		return witcherCampfire;
	}
	
	public function IsAnyFireLit() : bool
	{
		return ( alternateFireSource.IsLightOn() || witcherCampfire.IsOnFire() );
	}
	
	protected function GetParentFireMode() : int
	{
		return fireMode;
	}
	
	protected function GetCampfireZPosition( position : Vector ) : float
	{
		var position_z : float;			
		
		if( theGame.GetWorld().GetWaterLevel(position, true) >= position.Z )
			return 0;
		else
		if( theGame.GetWorld().NavigationLineTest(GetPlayer().GetWorldPosition(), position, 0.2f) )
		{
			theGame.GetWorld().PhysicsCorrectZ(position, position_z);
			return position_z;
		}
		
		return 0;
	}
	
	protected function GetSafeCampfirePosition() : Vector
	{
		return (GetPlayer().GetWorldPosition() + VecFromHeading(GetPlayer().GetHeading() ) * (Vector)(0.83f, 0.83f, 1.f, 1.f) );
	}
	
	protected function DestroyWitcherCampfire()
	{
		if( witcherCampfire )
		{
			witcherCampfire.Destroy();
		}
	}
	
	protected function GetFirePosition() : Vector
	{
		if( alternateFireSource )
			return alternateFireSource.GetWorldPosition();
		else
			return witcherCampfire.GetWorldPosition();
	}
	
	protected function GetPlayerPosition() : Vector
	{
		return playerWitcher.GetWorldPosition();
	}
	
	protected function GetPlayer() : W3PlayerWitcher
	{
		return playerWitcher;
	}
	
	private function GetFireMode() : int
	{
		if( GetIsFireSourceNear() )
		{
			if( alternateFireSource.IsLightOn() )
				return 0;
			else
				return 2;
		}
		else
		if( noFireMode )
			return 0;
		/*
		else
		if( playerWitcher.IsInInterior() )
			return 0;
		*/
		else
		if( !UseTimber() )
			return 0;
		else
		if( !GetCampfireZPosition(GetSafeCampfirePosition()) )
			return 0;
		else
			return 1;
	}
	
	private function GetIsFireSourceNear() : bool
	{
		return ( FindFireSource('CWitcherCampfire') || FindFireSource('W3Campfire') || FindFireSource('W3FireSource') );
	}
	
	private function UseTimber() : bool
	{
		var kindling, hardKindling, requiredKindling, requiredHardKindling, totalKindling, totalRequiredKindling : int;
		var inv : CInventoryComponent;
		
		inv = playerWitcher.GetInventory();
		
		kindling = Equipment().GetItemQuantityByNameForCrafting('Timber');
		hardKindling = Equipment().GetItemQuantityByNameForCrafting('Hardened timber');
		
		requiredKindling = Options().GetRequiredTimber();
		requiredHardKindling = Options().GetRequiredHardTimber();
		
		totalKindling = kindling + hardKindling;
		totalRequiredKindling = requiredKindling + requiredHardKindling;
		
		if( kindling >= requiredKindling )
		{
			Equipment().RemoveItemByNameForCrafting('Timber', requiredKindling);
			return true;
		}
		else
		if( hardKindling >= requiredHardKindling )
		{
			Equipment().RemoveItemByNameForCrafting('Hardened timber', requiredHardKindling);
			return true;
		}
		else
		if( totalRequiredKindling <= totalKindling )
		{
			if( kindling < hardKindling )
			{
				Equipment().RemoveItemByNameForCrafting('Timber', kindling);
				Equipment().RemoveItemByNameForCrafting('Hardened timber', totalRequiredKindling - (totalKindling - kindling));
			}
			else
			{
				Equipment().RemoveItemByNameForCrafting('Hardened timber', hardKindling);
				Equipment().RemoveItemByNameForCrafting('Timber', totalRequiredKindling - (totalKindling - hardKindling));
			}
			return true;
		}
		
		return false;		
	}
	
	private function FindFireSource( fireEntity : name, optional range : float ) : bool
	{
		var entities : array<CGameplayEntity>;
		var lightComponent : CGameplayLightComponent;
		var i : int;
		
		if( !range )
			range = 2.f;
		
		FindGameplayEntitiesInRange(entities, playerWitcher, range, 10,, FLAG_ExcludePlayer,, fireEntity);
		for(i=0; i<entities.Size(); i+=1)
		{
			lightComponent = (CGameplayLightComponent)entities[i].GetComponentByClassName('CGameplayLightComponent');
			if( lightComponent )
			{
				if( witcherCampfire && (CWitcherCampfire)entities[i] == witcherCampfire )
				{
					alternateFireSource = NULL;
					return true;
				}
				else
				{
					alternateFireSource = lightComponent;
					return true;
				}
			}
		}
		return false;
	}
}

state Idle in CWitcherCampfireManager
{
	event OnEnterState( prevStateName : name )
	{
		RotateToFire();
	}
	
	private function RotateToFire()
	{
		if( VecDistanceSquared(parent.GetFirePosition(), parent.GetPlayerPosition()) < 15 )
			parent.GetPlayer().SetCustomRotation('LookAtFire', VecHeading(parent.GetFirePosition() - parent.GetPlayerPosition()), 360.f, 1.f, false);
	}
}

state Lit in CWitcherCampfireManager
{
	event OnEnterState( prevStateName : name )
	{
		if( prevStateName != 'Spawned' )
			RotateToFire();
		LightFire();
	}
	
	private entry function LightFire()
	{
		if( parent.GetParentFireMode() == 1 )
		{
			Sleep(parent.KINDLE_DELAY);
			parent.witcherCampfire.ToggleFire(true);
		}
		else
		{
			Sleep(parent.KINDLE_DELAY_EXISTING);
			parent.alternateFireSource.SetLight(true);
		}
	}
	
	private function RotateToFire()
	{
		parent.GetPlayer().SetCustomRotation('LookAtFire', VecHeading(parent.GetFirePosition() - parent.GetPlayerPosition()), 360.f, 1.f, false);
	}
}

state Extinguished in CWitcherCampfireManager
{
	event OnEnterState( prevStateName : name )
	{
		if( prevStateName != 'Idle' )
			ExtinguishFire();
	}
	
	private entry function ExtinguishFire()
	{
		Sleep(parent.EXTINGUISH_DELAY);
		if( parent.GetParentFireMode() == -1 )
		{
			parent.witcherCampfire.ToggleFire(false);
			parent.alternateFireSource.SetLight(false);
			parent.alternateFireSource = NULL;
		}
	}
}

state Spawned in CWitcherCampfireManager
{
	event OnEnterState( prevStateName : name )
	{
		if( prevStateName == 'None' )
			parent.PushState('Destroyed');
		else
			BuildCampfire();
	}

	private entry function BuildCampfire()
	{
		var entityTemplate : CEntityTemplate;
		var position : Vector;
		
		position = parent.GetSafeCampfirePosition();
		position.Z = parent.GetCampfireZPosition(position);
		
		entityTemplate = (CEntityTemplate)LoadResource("environment\decorations\light_sources\campfire\campfire_01.w2ent", true);
		
		Sleep(parent.CAMPFIRE_SPAWN_DELAY);
		parent.witcherCampfire = (W3Campfire)theGame.CreateEntity(entityTemplate, position);
		parent.PushState('Lit');
	}
}

state Destroyed in CWitcherCampfireManager
{
	event OnEnterState( prevStateName : name )
	{
		DestroyCampfire();
		if( prevStateName == 'Extinguished' || prevStateName == 'Spawned' )
			parent.PushState('Spawned');
	}
	
	private function DestroyCampfire()
	{
		parent.DestroyWitcherCampfire();
	}
}

state W3EEMeditation in W3PlayerWitcher extends MeditationBase
{
	private var campfireManager				: CWitcherCampfireManager;
	private var fastForwardSystem			: CGameFastForwardSystem;
	private var alchemyManager				: W3EEAlchemyExtender;
	private var shouldSpinCamera			: bool;	
	private var reduceCameraSpin			: bool;	
	private var spinReductionThreshold 		: float;
	private var saveLock					: int;	
	private var stateTimeSpent				: float;
	private var hoursPerMinute 				: float;
	private var animationDelay 				: float;
	private var meditatingTime 				: float;
	private var brewingTime 				: float;
	private var meditationTimeSpent 		: float;
	private var isMeditating, isBrewing		: bool;
	private var shouldMeditate, shouldBrew	: bool;
	private var isForcedMeditation			: bool;
	
	private const var MEDITATION_ANIMATION_DELAY		: float;
	private const var FIRE_MEDITATION_ANIMATION_DELAY	: float;
	private const var MEDITATION_TIME_SCALE_MENU		: float;
	private const var MEDITATION_TIME_SCALE				: float;
	private const var BREWING_TIME_SCALE				: float;
	private const var RESET_MEDITATION_TIME				: float;
	private const var RESTED_BUFF_TIME					: float;
	
	default MEDITATION_ANIMATION_DELAY = 3.2f;
	default FIRE_MEDITATION_ANIMATION_DELAY = 7.2f;
	default MEDITATION_TIME_SCALE_MENU = 175.0f;
	default MEDITATION_TIME_SCALE = 75.0f;
	default BREWING_TIME_SCALE = 30.0f;
	default RESET_MEDITATION_TIME = 6.0f;
	default RESTED_BUFF_TIME = 25200.0f;
	
	event OnEnterState( prevStateName : name )
	{
		alchemyManager = Alchemy();
		hoursPerMinute = theGame.GetHoursPerMinute();
		campfireManager = CampfireManager();
		
		super.OnEnterState(prevStateName);
		StartMeditationState();
	}
	
	event OnLeaveState( nextStateName : name )
	{
		StopMeditationState();
		super.OnLeaveState(nextStateName);
	}	
	
	private entry function StartMeditationState()
	{
		var mutagen : CBaseGameplayEffect;
	
		fastForwardSystem = theGame.GetFastForwardSystem();
		shouldSpinCamera = false;
		reduceCameraSpin = false;
		
		theGame.CreateNoSaveLock('W3EEMeditation', saveLock);
		if( Options().GetIsCameraLocked() )
			parent.EnableManualCameraControl(false, 'W3EEMeditation');
		parent.EnableCharacterCollisions(false);
		parent.HideUsableItem();
		
		ManagePlayerDisarm();
		BlockGameplayActions(true);
		ManagePlayerBehavior(campfireManager.ManageFire(parent.GetNoFireCall()));
		if( alchemyManager.GetBrewingInterrupted() && CanPerformAlchemy() )
		{
			alchemyManager.SetBrewingInterrupted(false);
			SetShouldBrew();
		}
		
		if(parent.HasBuff(EET_Mutagen06))
		{
			mutagen = parent.GetBuff(EET_Mutagen06);
			parent.RemoveAbilityAll(mutagen.GetAbilityName());
		}
	}
	
	private entry function StopMeditationState()
	{
		if( theGame.IsBlackscreenOrFading() )
			theGame.FadeInAsync(1.f);
			
		parent.SetNoFireCall(false);
		parent.EnableCharacterCollisions(true);
		theGame.SetHoursPerMinute(hoursPerMinute);
		parent.LockEntryFunction(true);
		
		if( stateTimeSpent < animationDelay )
			Sleep(animationDelay - stateTimeSpent);
		
		ManagePlayerBehavior(campfireManager.ManageFire(false));
		Sleep(MEDITATION_ANIMATION_DELAY * 0.6f);
		fastForwardSystem.AllowFastForwardSelfCompletion();
		if( brewingTime > 0 )
		{
			alchemyManager.SetBrewingInterrupted(true);
			alchemyManager.SetBrewingDuration(brewingTime);
		}
		
		stateTimeSpent = 0;
		meditationTimeSpent = 0;
		spinReductionThreshold = 0;
		shouldSpinCamera = false;
		reduceCameraSpin = false;
		
		BlockGameplayActions(false);
		BlockGameplayActionsAll(false);
		theGame.ReleaseNoSaveLock(saveLock);
		theGame.CloseMenu('MeditationClockMenu');
		parent.EnableManualCameraControl(true, 'W3EEMeditation');
		parent.inMeditationMenu = false;
		parent.LockEntryFunction(false);
	}

	
	event OnPlayerTickTimer( dt : float )
	{
		super.OnPlayerTickTimer(dt);
		
		stateTimeSpent += dt;
		
		if( stateTimeSpent < animationDelay )
			return 0;
		
		if( shouldBrew && !isBrewing )
			BeginBrewing();
		else
		if( !shouldBrew && isBrewing )
			EndBrewing();
		
		if( isMeditating )
		{
			if( !isForcedMeditation )
			{
				parent.UpdateEffectsAccelerated(dt * MEDITATION_TIME_SCALE);
				meditationTimeSpent += dt * MEDITATION_TIME_SCALE * 60;
			}
			else
			{
				parent.UpdateEffectsAccelerated(dt * MEDITATION_TIME_SCALE_MENU);
				meditationTimeSpent += dt * MEDITATION_TIME_SCALE_MENU * 60;
				
				if( meditatingTime <= 0 && isForcedMeditation )
					shouldMeditate = false;
				meditatingTime -= dt * MEDITATION_TIME_SCALE_MENU * 60;
			}
		}
		else
		if( isBrewing )
		{
			parent.UpdateEffectsAccelerated(dt * BREWING_TIME_SCALE);
			if( brewingTime <= 0 )
				shouldBrew = false;
			
			if( shouldBrew )
			{
				brewingTime -= dt * BREWING_TIME_SCALE * 60;
				return 0;
			}
		}
		
		if( shouldMeditate && !isMeditating )
			BeginMeditation();
		else
		if( !shouldMeditate && isMeditating )
			EndMeditation();
		
		if( meditationTimeSpent > 0 )
			ManageRestedBuff();
	}
	
	public function IsActivelyMeditating() : bool
	{
		return (isMeditating || isBrewing || shouldBrew || shouldMeditate || theGame.IsBlackscreenOrFading());
	}
	
	public function CanPerformAlchemy() : bool
	{
		return campfireManager.CanPerformAlchemy();
	}
	
	public function SetShouldBrew()
	{
		if( isMeditating || isBrewing || shouldBrew || shouldMeditate )
			return;
		
		shouldBrew = true;
	}
	
	public function SetShouldMeditate( meditate : bool )
	{
		if( (isMeditating || isBrewing || shouldBrew || shouldMeditate) && meditate )
			return;
		
		shouldMeditate = meditate;
	}
	
	public function SetShouldMeditateMenu( meditate : bool )
	{
		if( (isMeditating || isBrewing || shouldBrew || shouldMeditate) && meditate )
			return;
		
		isForcedMeditation = meditate;
		shouldMeditate = meditate;
	}
	
	private entry function BeginBrewing()
	{
		var fadeTime : float;
		
		theGame.LockEntryFunction(true);
		fastForwardSystem.AllowFastForwardSelfCompletion();
		isBrewing = true;
		shouldSpinCamera = true;
		spinReductionThreshold = 0;
		brewingTime = alchemyManager.GetBrewingDuration();
		
		fadeTime = RoundTo(brewingTime / (BREWING_TIME_SCALE * 60.f), 1);
		BlockGameplayActionsAll(true);
		fastForwardSystem.BeginFastForward();
		theGame.SetHoursPerMinute(BREWING_TIME_SCALE);
		if( Options().GetShouldAlchemyFade() )
		{
			theGame.FadeOutAsync(1.5f);
			Sleep(1.5f);
			theGame.FadeInAsync(MaxF(1.5f, fadeTime));
		}
		theGame.LockEntryFunction(false);
	}
	
	private function EndBrewing()
	{
		isBrewing = false;
		reduceCameraSpin = true;
		alchemyManager.ResetBrewingDuration();
		alchemyManager.FinishBrewing();
		
		BlockGameplayActionsAll(false);
		
		theGame.SetHoursPerMinute(hoursPerMinute);
		fastForwardSystem.AllowFastForwardSelfCompletion();
	}

	private function BeginMeditation()
	{
		isMeditating = true;
		spinReductionThreshold = 0;
		if( isForcedMeditation )
		{
			shouldSpinCamera = true;
			BeginMenuMeditation();
		}
		else
		{
			shouldSpinCamera = false;
			reduceCameraSpin = false;
			
			fastForwardSystem.BeginFastForward();
			theGame.SetHoursPerMinute(MEDITATION_TIME_SCALE);
		}
	}
	
	private function EndMeditation()
	{
		if( isForcedMeditation )
		{
			reduceCameraSpin = true;
			theSound.SoundEvent("gui_global_denied");
			BlockGameplayActionsAll(false);
		}
		
		isMeditating = false;
		isForcedMeditation = false;
		
		theGame.SetHoursPerMinute(hoursPerMinute);
		fastForwardSystem.AllowFastForwardSelfCompletion();
	}
	
	private function BeginMenuMeditation()
	{
		var startTime, targetTime : GameTime;
		var targetHour : int;
		
		startTime = theGame.GetGameTime();
		targetHour = parent.GetWaitTargetHour();
		if( targetHour > GameTimeHours(startTime) )
			targetTime = GameTimeCreate(GameTimeDays(startTime), targetHour, 0, 0);
		else
			targetTime = GameTimeCreate(GameTimeDays(startTime) + 1, targetHour, 0, 0);
		
		BlockGameplayActionsAll(true);
		
		fastForwardSystem.BeginFastForward();
		theGame.SetHoursPerMinute(MEDITATION_TIME_SCALE_MENU);
		
		meditatingTime += GameTimeToSeconds(targetTime) - GameTimeToSeconds(startTime);
	}
	
	private function ManagePlayerBehavior( mode : int ) : bool
	{
		switch(mode)
		{
			case -2:
				parent.SetBehaviorVariable('HasCampfire', 0.f);
				if( parent.GetPlayerAction() == PEA_Meditation )
					parent.PlayerStopAction(PEA_Meditation);
			return false;
			
			case -1:
				parent.SetBehaviorVariable('HasCampfire', 1.f);
				if( parent.GetPlayerAction() == PEA_Meditation )
					parent.PlayerStopAction(PEA_Meditation);
			return true;
			
			case  0:
				parent.SetBehaviorVariable('MeditateWithIgnite', 0.f);
				if( !parent.PlayerStartAction(PEA_Meditation) )
				{
					parent.DisplayHudMessage(GetLocStringByKeyExt("menu_cannot_perform_action_now") );
					parent.PopState(true);
				}
				if( VecDistanceSquared( parent.GetWorldPosition(), parent.GetHorseWithInventory().GetWorldPosition() ) > 25 && !parent.IsInInterior() && campfireManager.IsAnyFireLit() )
					theGame.OnSpawnPlayerHorse();
				animationDelay = MEDITATION_ANIMATION_DELAY;
			return false;
			
			
			case  1:
			case  2:
				parent.SetBehaviorVariable('MeditateWithIgnite', 1.f);
				if( !parent.PlayerStartAction(PEA_Meditation) )
				{
					parent.DisplayHudMessage(GetLocStringByKeyExt("menu_cannot_perform_action_now") );
					parent.PopState(true);
				}
				if( VecDistanceSquared( parent.GetWorldPosition(), parent.GetHorseWithInventory().GetWorldPosition() ) > 25 && !parent.IsInInterior() )
					theGame.OnSpawnPlayerHorse();
				animationDelay = FIRE_MEDITATION_ANIMATION_DELAY;
			return false;
		}
	}
	
	private function ManagePlayerDisarm()
	{
		if( parent.GetCurrentMeleeWeaponType() != PW_None )
			parent.OnEquipMeleeWeapon(PW_None, true, false);
			
		if( parent.IsHoldingItemInLHand() )
			parent.HideUsableItem(true);
			
		if( parent.rangedWeapon )
			parent.OnRangedForceHolster(true, true, false);
	}
	
	private function BlockGameplayActionsAll( lock : bool )
	{
		if( lock )
			parent.BlockAllActions('W3EEBrewing', true);
		else
			parent.BlockAllActions('W3EEBrewing', false);
	}
	
	private function BlockGameplayActions( lock : bool )
	{
		var exceptions : array< EInputActionBlock >;
		if ( lock )
		{
			exceptions.PushBack( EIAB_MeditationWaiting );
			exceptions.PushBack( EIAB_OpenFastMenu );
			exceptions.PushBack( EIAB_OpenInventory );
			exceptions.PushBack( EIAB_OpenAlchemy );
			exceptions.PushBack( EIAB_OpenCharacterPanel );
			exceptions.PushBack( EIAB_OpenJournal );
			exceptions.PushBack( EIAB_OpenMap );
			exceptions.PushBack( EIAB_OpenGlossary );
			exceptions.PushBack( EIAB_RadialMenu );
			exceptions.PushBack( EIAB_OpenMeditation );
			exceptions.PushBack( EIAB_QuickSlots );
			parent.BlockAllActions('W3EEMeditation', true, exceptions);
		}	
		else parent.BlockAllActions('W3EEMeditation', false);
	}
	
	private function IsMeditationAllowed() : bool
	{
		return ( !theGame.IsBlackscreenOrFading() && parent.CanMeditateWait(true) && parent.CanPerformPlayerAction(true) );
	}
	
	private entry function ManageRestedBuff()
	{
		var storedMeditationTime : float;
		
		storedMeditationTime = meditationTimeSpent;
		if( meditationTimeSpent >= RESTED_BUFF_TIME && CanPerformAlchemy() )
		{
			parent.AddEffectDefault(EET_WellRested, parent, "RestedBuff");
			meditationTimeSpent = 0;
		}
		else
		{
			Sleep(RESET_MEDITATION_TIME);
			if( meditationTimeSpent <= storedMeditationTime )
				meditationTimeSpent = 0;
		}
	}
	
	event OnGameCameraTick( out moveData : SCameraMovementData, dt : float )
	{
		var rotation : EulerAngles = thePlayer.GetWorldRotation();
		
		if( !shouldSpinCamera )		
		{
			RotateCamera(moveData, rotation, 180.0f, 0.4f/*0.25f*/, -15.0f);
			DampVectorSpring( moveData.cameraLocalSpaceOffset, moveData.cameraLocalSpaceOffsetVel, Vector( 0.0f, 11.2f, -11.5f, 0.f ), 2.5f, dt );
		}
	}
	
	event OnGameCameraPostTick( out moveData : SCameraMovementData, dt : float )
	{
		var rotation : EulerAngles = moveData.pivotRotationValue;		
		var rotationSpeed : float = 0.6f;
		
		if( shouldSpinCamera )
		{
			if( reduceCameraSpin )
			{
				spinReductionThreshold += dt * 0.2625f;
				if( spinReductionThreshold > rotationSpeed )
				{
					spinReductionThreshold = 0;
					shouldSpinCamera = false;
					reduceCameraSpin = false;
				}
			}
			RotateCamera(moveData, rotation, 90.f, (rotationSpeed - spinReductionThreshold), (spinReductionThreshold * -35.0f) );
		}
	}
	
	private function RotateCamera( out moveData : SCameraMovementData, rotation : EulerAngles, angle, rotationSpeed, pitch : float ) : void
	{
		theGame.GetGameCamera().ChangePivotRotationController('Exploration');
		theGame.GetGameCamera().ChangePivotDistanceController('Default');
		theGame.GetGameCamera().ChangePivotPositionController('Default');
		
		moveData.pivotDistanceController = theGame.GetGameCamera().GetActivePivotDistanceController();
		moveData.pivotPositionController = theGame.GetGameCamera().GetActivePivotPositionController();
		moveData.pivotRotationController = theGame.GetGameCamera().GetActivePivotRotationController();
		
		moveData.pivotRotationController.SetDesiredHeading(rotation.Yaw + angle, rotationSpeed);
		moveData.pivotRotationController.SetDesiredPitch(pitch, 0.4);
		moveData.pivotPositionController.offsetZ = 0.5;
		moveData.pivotDistanceController.SetDesiredDistance(3.8);
	}
}

statemachine class W3EEAnimationManager extends CEntity
{
	public var usedSlot : EEquipmentSlots;
	public var usedItem, usedSword : SItemUniqueId;

	private var playerWitcher : W3PlayerWitcher;	
	public function Init( player : W3PlayerWitcher )
	{
		playerWitcher = player;
		GotoState('Idle');
	}
	
	public function IsUsingConsumable() : bool
	{
		return GetCurrentStateName() == 'Animation';
	}
	
	public timer function StartAnimatedState( dt : float, id : int )
	{
		GotoState('Animation');
	}
	
	public function GetConsumableState() : W3EEAnimationManagerStateAnimation
	{
		if( IsUsingConsumable() )
		{
			return (W3EEAnimationManagerStateAnimation)GetState('Animation');
		}
		
		return NULL;
	}
	
	public function PerformAnimation( slot : EEquipmentSlots, itemID : SItemUniqueId, optional swordItem : SItemUniqueId ) : bool
	{
		if( playerWitcher.IsInAir() || playerWitcher.IsSwimming() )
		{
			playerWitcher.DisplayHudMessage(GetLocStringByKeyExt("menu_cannot_perform_action_here"));
			theSound.SoundEvent( "gui_global_denied" );
			return false;
		}
		
		if( GetCurrentStateName() == 'Animation' || playerWitcher.IsCurrentlyDodging() || playerWitcher.HasBuff(EET_Stagger) || playerWitcher.HasBuff(EET_LongStagger) || playerWitcher.HasBuff(EET_Knockdown) || playerWitcher.HasBuff(EET_HeavyKnockdown) )
		{
			playerWitcher.DisplayHudMessage(GetLocStringByKeyExt("menu_cannot_perform_action_now"));
			theSound.SoundEvent( "gui_global_denied" );
			return false;
		}
		
		if( playerWitcher.GetCurrentStateName() == 'HorseRiding' )
		{
			if( !(playerWitcher.inv.ItemHasTag(itemID, 'Potion') || playerWitcher.inv.ItemHasTag(itemID,'Edibles')) )
			{
				playerWitcher.DisplayHudMessage(GetLocStringByKeyExt("menu_cannot_perform_action_now"));
				theSound.SoundEvent( "gui_global_denied" );
				return false;
			}
		}
		
		usedSlot = slot;
		usedItem = itemID;
		usedSword = swordItem;
		playerWitcher.AddTimer('StartAnimatedState', 0.05f, false);
		theGame.GetGuiManager().GetCommonMenu().CloseMenu();
		((CR4HudModuleRadialMenu)theGame.GetHud().GetHudModule("RadialMenuModule")).HideRadialMenu();
		return true;
	}
	
	public var herb : W3Container;
	public function PerformLootingAnimation( herbContainer : W3Container ) : bool
	{
		var playerWitcher : W3PlayerWitcher = GetWitcherPlayer();
		if( playerWitcher.IsInAir() )
		{
			playerWitcher.DisplayHudMessage(GetLocStringByKeyExt("menu_cannot_perform_action_here"));
			theSound.SoundEvent( "gui_global_denied" );
			return false;
		}
		
		if( GetCurrentStateName() == 'Animation' || playerWitcher.GetCurrentStateName() == 'HorseRiding' || playerWitcher.IsCurrentlyDodging() || playerWitcher.HasBuff(EET_Stagger) || playerWitcher.HasBuff(EET_LongStagger) || playerWitcher.HasBuff(EET_Knockdown) || playerWitcher.HasBuff(EET_HeavyKnockdown) )
		{
			playerWitcher.DisplayHudMessage(GetLocStringByKeyExt("menu_cannot_perform_action_now"));
			theSound.SoundEvent( "gui_global_denied" );
			return false;
		}
		
		if( playerWitcher.IsSwimming() || !Options().GetUseLootAnimation() )
		{
			Equipment().LootHerb(herbContainer);
			return true;
		}
		
		herb = herbContainer;
		playerWitcher.AddTimer('StartAnimatedState', 0.05f, false);
		return true;
	}
	
	public function ResetAnimData()
	{
		usedSlot = EES_InvalidSlot;
		usedItem = GetInvalidUniqueId();
		usedSword = usedItem;
		herb = NULL;
	}
}

state Idle in W3EEAnimationManager
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
	}
	
	event OnLeaveState( nextStateName : name )
	{
		super.OnLeaveState(nextStateName);
	}
}

state Animation in W3EEAnimationManager
{
	private var playerWitcher			: W3PlayerWitcher;
	private var playerWeapon			: EPlayerWeapon;
	private var oiledWeapon				: EPlayerWeapon;
	private var usedItemSlot			: EEquipmentSlots;
	private var usedItem				: SItemUniqueId;
	private var swordItem				: SItemUniqueId;
	private var animName				: name;
	private var saveLock				: int;
	private var usingFood				: bool;
	private var usingOil				: bool;
	private var wasPlayerHit			: bool;
	private var wasHolstering			: bool;
	private var speedMultID				: int;
	
	private const var DRINK_ANIM_ACTIVATE_TIME : float;
	private const var DRINK_ANIM_FINISH_TIME : float;
	
	default DRINK_ANIM_ACTIVATE_TIME = 1.55f;
	default DRINK_ANIM_FINISH_TIME = 0.75f;

	private const var OIL_ANIM_ACTIVATE_TIME : float;
	private const var OIL_ANIM_HALF_TIME : float;
	private const var OIL_ANIM_FINISH_TIME : float;
	
	default OIL_ANIM_ACTIVATE_TIME = 1.85f;
	default OIL_ANIM_HALF_TIME = 0.9f;
	default OIL_ANIM_FINISH_TIME = 1.2f;
	
	private const var EAT_ANIM_ACTIVATE_TIME : float;
	private const var EAT_ANIM_FINISH_TIME : float;
	
	default EAT_ANIM_ACTIVATE_TIME = 1.55f;
	default EAT_ANIM_FINISH_TIME = 0.75f;
	
	private const var LOOT_ANIM_START_TIME : float;
	private const var LOOT_ANIM_PART1_TIME : float;
	private const var LOOT_ANIM_PART2_TIME : float;
	private const var LOOT_ANIM_FINISH_TIME : float;
	
	default LOOT_ANIM_START_TIME = 2.25f;
	default LOOT_ANIM_PART1_TIME = 2.87f;
	default LOOT_ANIM_PART2_TIME = 3.34f;
	default LOOT_ANIM_FINISH_TIME = 3.00f;
	
	private var error : int;
	event OnEnterState( prevStateName : name )
	{
		playerWitcher = GetWitcherPlayer();
		super.OnEnterState(prevStateName);
		
		SetConsumptionItem(parent.usedSlot, parent.usedItem, parent.usedSword);
		GetAnimationType();
		error = GetExceptions();
		if( !error || parent.herb )
		{
			theGame.CreateNoSaveLock('W3EEAnimation', saveLock);
			if( usingOil || parent.herb )
				playerWitcher.BlockAllActions('W3EEAnimation', true);
			else
				BlockActiveAnimationActions('W3EEAnimation');
			PerformAnimations();
			return true;
		}
		ShowErrorMessage(error);
		parent.GotoState('Idle');
	}
	
	event OnLeaveState( nextStateName : name )
	{
		if( parent.herb && !playerWitcher.GetWeaponHolster().IsOnTheMiddleOfHolstering() )
			playerWitcher.OnEquipMeleeWeapon(playerWeapon, false);
		
		parent.ResetAnimData();
		playerWeapon = PW_None;
		oiledWeapon = PW_None;
		wasPlayerHit = false;
		usingFood = false;
		usingOil = false;
		playerWitcher.BlockAllActions('W3EEAnimation', false);
		playerWitcher.ResetAnimationSpeedMultiplier(speedMultID);
		theGame.ReleaseNoSaveLock(saveLock);
		
		super.OnLeaveState(nextStateName);
	}
	
	public function OnTakeDamage( action : W3DamageAction )
	{
		if( (W3PlayerWitcher)action.victim && action.DealsAnyDamage() && !((W3Effect_Toxicity)action.causer) )
		{
			wasPlayerHit = true;
			if( !usingOil && !parent.herb )
				playerWitcher.RaiseForceEvent('ItemEndL');
			else
			{
				playerWitcher.PlayerStopAction(playerWitcher.GetPlayerAction());
				playerWitcher.LockEntryFunction(false);
				parent.GotoState('Idle');
			}
		}
	}
	
	private entry function PerformAnimations()
	{
		parent.LockEntryFunction(true);
		if( playerWitcher.IsWeaponHeld('silversword') )
			playerWeapon = PW_Silver;
		else
		if( playerWitcher.IsWeaponHeld('steelsword') )
			playerWeapon = PW_Steel;
		
		playerWitcher.OnRangedForceHolster(true, true);
		if( playerWitcher.RaiseEvent('ForcedUsableItemUnequip') )
			Sleep(0.3f);
		if( usingOil || parent.herb )
			playerWitcher.OnEquipMeleeWeapon(oiledWeapon, true);	
		
		wasHolstering = false;
		while( playerWitcher.GetWeaponHolster().IsOnTheMiddleOfHolstering() )
		{
			wasHolstering = true;
			Sleep(0.2f);
		}
		
		if( parent.herb )
			PerformLootingAnim();
		else
		if( usingOil )
			PerformOilingAnim(animName);
		else
		if( usingFood )
			PerformEatingAnim(animName);
		else
			PerformDrinkingAnim(animName);
	}
	
	private latent function PerformDrinkingAnim( animName : name )
	{
		var items : array<SItemUniqueId>;
		
		items = playerWitcher.inv.AddAnItem(animName, 1, true, true);
		playerWitcher.inv.MountItem(items[0], true);
		
		playerWitcher.SetBehaviorVariable('SelectedItemL', (int)UI_Horn, true);
		playerWitcher.RaiseEvent('ItemUseL');
		Sleep(DRINK_ANIM_ACTIVATE_TIME);
		
		if( !wasPlayerHit )
		{
			UseCachedItem();
			Sleep(DRINK_ANIM_FINISH_TIME);
		}
		playerWitcher.inv.UnmountItem(items[0]);
		playerWitcher.inv.RemoveItem(items[0], 1);
		Sleep(0.5f);
		parent.LockEntryFunction(false);
		parent.GotoState('Idle');
	}
	
	private latent function PerformEatingAnim( animName : name )
	{
		var items : array<SItemUniqueId>;
		
		items = playerWitcher.inv.AddAnItem(animName, 1, true, true);
		playerWitcher.inv.MountItem(items[0], true);
		
		playerWitcher.SetBehaviorVariable('SelectedItemL', (int)UI_Horn, true);
		playerWitcher.RaiseEvent('ItemUseL');
		Sleep(EAT_ANIM_ACTIVATE_TIME);
		
		if( !wasPlayerHit )
		{
			UseCachedItem();
			Sleep(EAT_ANIM_FINISH_TIME);
		}
		playerWitcher.inv.UnmountItem(items[0]);
		playerWitcher.inv.RemoveItem(items[0], 1);
		Sleep(0.5f);
		parent.LockEntryFunction(false);
		parent.GotoState('Idle');
	}
	
	private latent function PerformOilingAnim( animName : name )
	{
		if( wasHolstering )
			Sleep(0.8f);
		speedMultID = playerWitcher.SetAnimationSpeedMultiplier(0.4f, speedMultID);
		playerWitcher.PlayerStartAnim(PEA_SlotAnimation, animName, 0.25f, 0.2f);
		Sleep(OIL_ANIM_HALF_TIME);
		
		playerWitcher.ResetAnimationSpeedMultiplier(speedMultID);
		Sleep(OIL_ANIM_ACTIVATE_TIME);
		
		if( !wasPlayerHit )
		{
			UseCachedItem();
			
			Sleep(OIL_ANIM_FINISH_TIME);
		}
		parent.LockEntryFunction(false);
		parent.GotoState('Idle');
	}
	
	private latent function PerformLootingAnim()
	{
		playerWitcher.SetCustomRotation('LootHerb', VecHeading(parent.herb.GetWorldPosition() - playerWitcher.GetWorldPosition()), 360.f, 1.f, false);
		speedMultID = playerWitcher.SetAnimationSpeedMultiplier(1.2f, speedMultID);
		playerWitcher.ActionPlaySlotAnimationAsync('PLAYER_SLOT', 'man_work_picking_up_herbs_start', 0.15f, 0.f);
		Sleep(LOOT_ANIM_START_TIME);
		
		if( !wasPlayerHit )
		{
			playerWitcher.ActionPlaySlotAnimationAsync('PLAYER_SLOT', 'man_work_picking_up_herbs_loop_01', 0.f, 1.7f);
			Sleep(LOOT_ANIM_PART1_TIME);
		}
		
		if( !wasPlayerHit )
		{
			Equipment().LootHerb(parent.herb);
			Sleep(LOOT_ANIM_PART2_TIME);
		}
		
		playerWitcher.ResetAnimationSpeedMultiplier(speedMultID);
		parent.LockEntryFunction(false);
		parent.GotoState('Idle');
	}
	
	private function BlockActiveAnimationActions( sourceName : name )
	{
		var inputHandler : CPlayerInput = playerWitcher.GetInputHandler();
		var exceptions : array<EInputActionBlock>;
		
		if( inputHandler )
		{
			exceptions.PushBack(EIAB_DrawWeapon);
			exceptions.PushBack(EIAB_RadialMenu);
			exceptions.PushBack(EIAB_Movement);
			exceptions.PushBack(EIAB_HighlightObjective);
			exceptions.PushBack(EIAB_ExplorationFocus);
			exceptions.PushBack(EIAB_OpenFastMenu);
			exceptions.PushBack(EIAB_HardLock);
			exceptions.PushBack(EIAB_MeditationWaiting);
			exceptions.PushBack(EIAB_InteractionContainers);
			
			inputHandler.BlockAllActions(sourceName, true, exceptions);
		}
	}
	
	private function GetAnimationType()
	{
		if( playerWitcher.inv.GetItemCategory(swordItem) == 'steelsword' )
		{
			usingOil = true;
			oiledWeapon = PW_Steel;
			animName = 'man_work_sword_sharpening_02';
		}
		else
		if( playerWitcher.inv.GetItemCategory(swordItem) == 'silversword' )
		{
			usingOil = true;
			oiledWeapon = PW_Silver;
			animName = 'man_work_sword_sharpening_02';
		}
		else
		if( !playerWitcher.inv.ItemHasTag(usedItem, 'Drinks') && playerWitcher.inv.ItemHasTag(usedItem,'Edibles') )
		{
			usingFood = true;
			animName = 'goods_apple';
		}
		else
		if( playerWitcher.inv.ItemHasTag(usedItem, 'Drinks') )
		{
			animName = 'PN_Bottle';
		}
		else
		{
			animName = 'PN_Potion';
		}	
	}

	private function UseCachedItem()
	{
		if( playerWitcher.inv.ItemHasTag(usedItem, 'Potion') && playerWitcher.inv.ItemHasTag(usedItem, 'SingletonItem') )
			playerWitcher.DrinkPreparedPotion(usedItemSlot, usedItem);
		else
		if( usingFood || playerWitcher.inv.ItemHasTag(usedItem, 'Drinks') )
			playerWitcher.ConsumeItem(usedItem);
		else
		if( usingOil )
			playerWitcher.ApplyOilHack(usedItem, swordItem);
	}
	
	private function GetExceptions() : int
	{
		if( usedItem == GetInvalidUniqueId() )
			return 3;
		else
		if( !usingFood && !usingOil )
		{
			if( !playerWitcher.ToxicityLowEnoughToDrinkPotion(EES_InvalidSlot, usedItem) )
				return 1;		
		}
		else
		if( usingFood && playerWitcher.IsInCombat() )
			return 2;
		
		return 0;		
	}
	
	private function ShowErrorMessage(error : int)
	{
		var exceptionMessage : string;
		
		if( error == 1 )
		{
			exceptionMessage = GetLocStringByKeyExt("menu_cannot_perform_action_now") + " " + GetLocStringByKeyExt("panel_common_statistics_tooltip_current_toxicity") +
			": " + (int)(playerWitcher.abilityManager.GetStat(BCS_Toxicity, false)) + " / " +  (int)(playerWitcher.abilityManager.GetStatMax(BCS_Toxicity));
			playerWitcher.DisplayHudMessage(exceptionMessage);
		}
		else
		if( error == 2 )
			playerWitcher.DisplayHudMessage(GetLocStringByKeyExt("menu_cannot_perform_action_now") );
	}
	
	private function SetConsumptionItem( itemSlot : EEquipmentSlots, itemID : SItemUniqueId, swordID : SItemUniqueId )
	{
		usedItemSlot = itemSlot;
		swordItem = swordID;
		usedItem = itemID;
	}
}