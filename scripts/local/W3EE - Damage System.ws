/****************************************************************************/
/** Copyright © CD Projekt RED 2015
/** Author : Reaperrz
/****************************************************************************/

class W3EEDamageHandler
{	
	public var pdam, pdamc, pdams, pdamb, pdot, edot, php, pap, eapl, eaph : float;

	private var Perk10Active : bool; default Perk10Active = false;

	public function RefreshSettings()
	{
		var optionHandler : W3EEOptionHandler = Options();
		
		php = optionHandler.SetHealthPlayer();
		pdam  = optionHandler.PlayerDamage();
		pdamc = optionHandler.PlayerDamageCross();
		pdams = optionHandler.PlayerDamageSign();
		pdamb = optionHandler.PlayerDamageBomb();
		pdot = optionHandler.PlayerDOTDamage();
		edot = optionHandler.EnemyDOTDamage();
		pap = optionHandler.GetPlayerAPMult();
		eapl = optionHandler.GetEnemyLightAPMult();
		eaph = optionHandler.GetEnemyHeavyAPMult();
	}
	
	public function SteelMonsterDamage( actorAttacker : CActor, out damageInfo : array< SRawDamage >, monsterCategory : EMonsterCategory )
	{
		var witcher : W3PlayerWitcher;
		var i, silverDam, steelDam : int;
		
		silverDam = -1; steelDam = -1;
		for(i=0; i<damageInfo.Size(); i+=1)
		{
			if( damageInfo[i].dmgType == 'SilverDamage' )
				silverDam = i;
			else
			if( DamageHitsVitality(damageInfo[i].dmgType) )
				steelDam = i;
				
			if( silverDam >= 0 && steelDam >= 0 )
				break;
		}
		
		if( silverDam == -1 || steelDam == -1 )
			return;
			
		witcher = (W3PlayerWitcher)actorAttacker;
		if( !witcher )
			return;
			
		if( witcher.HasAbility('Runeword 12 _Stats', true) || witcher.HasAbility('Runeword 11 _Stats', true) || witcher.inv.ItemHasTag(witcher.GetHeldSword(), 'Aerondight') )
		{
			if( witcher.IsWeaponHeld('silversword') )
				damageInfo[steelDam].dmgVal *= 2.1f;
			else
				damageInfo[silverDam].dmgVal *= 1.05f;
			return;
		}
		else
		if( (monsterCategory == MC_Specter || monsterCategory == MC_Vampire || monsterCategory == MC_Cursed) && witcher.IsWeaponHeld('steelsword') )
			damageInfo[silverDam].dmgVal = 1.f;
	}
	
	public function NPCSteelMonsterDamage( actorAttacker : CActor, out damageInfo : array< SRawDamage >, monsterCategory : EMonsterCategory )
	{
		var i, steelDam, silverDam : int;
		if( ((CR4Player)actorAttacker) || !actorAttacker.IsHuman() || monsterCategory == MC_Specter || monsterCategory == MC_Vampire || monsterCategory == MC_Cursed )
			return;
		
		silverDam = -1; steelDam = -1;
		for(i=0; i<damageInfo.Size(); i+=1)
		{
			if( damageInfo[i].dmgType == 'SilverDamage' )
				silverDam = i;
			else
			if( DamageHitsVitality(damageInfo[i].dmgType) )
				steelDam = i;
				
			if( silverDam >= 0 && steelDam >= 0 )
				break;
		}
		
		if( silverDam == 0 || steelDam == 0 )
			return;
		
		if( damageInfo[silverDam].dmgVal < damageInfo[steelDam].dmgVal )
			damageInfo[silverDam].dmgVal = damageInfo[steelDam].dmgVal * 0.7f;
	}

	public function GeraltFistDamage( attackAction : W3Action_Attack, out damageInfo : array<SRawDamage>, monsterCategory : EMonsterCategory )
	{
		var i, steelDam, silverDam : int;
		var witcher : W3PlayerWitcher;
		
		witcher = (W3PlayerWitcher)attackAction.attacker;
		if( !witcher || !attackAction.IsActionMelee() || !witcher.IsWeaponHeld('fist') || monsterCategory == MC_Specter || monsterCategory == MC_Vampire || monsterCategory == MC_Cursed )
			return;
		
		for(i=0; i<damageInfo.Size(); i+=1)
		{
			if( damageInfo[i].dmgType == 'BludgeoningDamage' )
				steelDam = i;
			if( damageInfo[i].dmgType == 'SilverDamage' )
				silverDam = i;
		}
		
		if( monsterCategory == MC_Human || monsterCategory == MC_NotSet || monsterCategory == MC_Beast || monsterCategory == MC_Unused )
			damageInfo[steelDam].dmgVal = 570.f;
		else
			damageInfo[steelDam].dmgVal = 150.f;
		damageInfo[silverDam].dmgVal = 150.f;
	}
	
	public function HookBaseDamage( actorAttacker : CActor, damageAction : W3DamageAction, out damageInfo : array< SRawDamage > )
	{
		var npcAttacker : CNewNPC;
		var sum, mult : float;
		var i : int;
		
		if( (CPlayer)actorAttacker || !actorAttacker || !damageAction || damageAction.WasDamageReturnedToAttacker() || damageAction.IsDoTDamage() )
			return;
		
		npcAttacker = (CNewNPC)actorAttacker;
        for(i=0; i<damageInfo.Size(); i+=1)
			if( damageInfo[i].dmgType != 'SilverDamage' )
				sum += damageInfo[i].dmgVal;
        
        if( (damageAction.IsActionRanged() || damageAction.IsActionEnvironment()) && npcAttacker.GetScaledRangedDamage() )
			mult = npcAttacker.GetScaledRangedDamage() / sum;
		else
			mult = npcAttacker.GetScaledDamage() / sum;
		
        for(i=0; i<damageInfo.Size(); i+=1)
        {
			if( damageInfo[i].dmgType != 'SilverDamage' )
				damageInfo[i].dmgVal = npcAttacker.GetScaledDamage();
			else
				damageInfo[i].dmgVal *= mult;
        }
	}
	
	public function PlayerModule( out damageData : W3DamageAction )
	{
		if( thePlayer.IsInFistFightMiniGame() || ((CActor)damageData.victim).IsImmortal() )
			return;
		
		if( (CPlayer)damageData.victim )
		{
			damageData.processedDmg.vitalityDamage /= php;
			damageData.processedDmg.essenceDamage /= php;
			return;
		}
		else
 		if( (CPlayer)damageData.attacker )
		{
			if( damageData.IsActionWitcherSign() && (W3SignProjectile)damageData.causer )
			{
				damageData.processedDmg.vitalityDamage *= pdams;
				damageData.processedDmg.essenceDamage *= pdams;
				return;
			}
			else
			if( damageData.IsActionRanged() && (W3BoltProjectile)damageData.causer )
			{
				damageData.processedDmg.vitalityDamage *= pdamc;
				damageData.processedDmg.essenceDamage *= pdamc;
				return;
			}
			else
			if( damageData.IsActionRanged() && (W3Petard)damageData.causer )
			{
				damageData.processedDmg.vitalityDamage *= pdamb * 0.85f;
				damageData.processedDmg.essenceDamage *= pdamb * 0.85f;
				return;
			}
			else
			{
				damageData.processedDmg.vitalityDamage *= pdam;
				damageData.processedDmg.essenceDamage *= pdam;
				return;
			}
		}
		
	}
	
	public function NPCModule( out damageData : W3DamageAction, actorAttacker : CActor, actorVictim : CActor )
	{
		var npcAttacker, npcVictim : CNewNPC;
		var cachedDamage, cachedHealth : float;
		
		if( actorVictim.IsImmortal() )
			return;
		
		npcAttacker = (CNewNPC)actorAttacker;
		npcVictim = (CNewNPC)actorVictim;
		
		if( npcAttacker && npcAttacker != thePlayer )
		{
			cachedDamage = npcAttacker.GetCachedDamage();
			if( cachedDamage <= 0 )
				cachedDamage = 1;
			damageData.processedDmg.vitalityDamage *= cachedDamage;
			damageData.processedDmg.essenceDamage *= cachedDamage;
		}
		
		if( npcVictim && npcVictim != thePlayer )
		{
			cachedHealth = npcVictim.GetCachedHealth();
			if( cachedHealth <= 0 )
				cachedHealth = 1;
			damageData.processedDmg.vitalityDamage /= cachedHealth;
			damageData.processedDmg.essenceDamage /= cachedHealth;
		}
	}
	
	public function DOTModule( out damageData : W3DamageAction )
	{
		if( thePlayer.IsInFistFightMiniGame() )
			return;
		
		if( (CPlayer)damageData.attacker )
		{
			damageData.processedDmg.vitalityDamage *= pdot;
			damageData.processedDmg.essenceDamage *= pdot;
			return;
		}
		else
		{
			damageData.processedDmg.vitalityDamage *= edot;
			damageData.processedDmg.essenceDamage *= edot;
			return;
		}
	}
	
	public function SetPerk10State( i : bool )
	{
		Perk10Active = i;
	}

	public function GetPerk10State() : bool
	{
		return Perk10Active;
	}

	public function Perk10DamageBoost( out damageData : W3DamageAction )
	{
		/*if( (CPlayer)damageData.attacker && Perk10Active )
		{
			damageData.processedDmg.vitalityDamage *= 1.1f;
			damageData.processedDmg.essenceDamage *= 1.1f;
			
			GetWitcherPlayer().AddTimer('ResetPerk10', 0.65f, false,,,,true);
		}*/
		
		if( damageData.IsActionMelee() && (CPlayer)damageData.attacker && thePlayer.CanUseSkill(S_Perk_10) )
		{
			SetPerk10State(true);
			GetWitcherPlayer().AddTimer('ResetPerk10', 4.0f, false,,,,true);
		}
	}
	
	public function ColdBloodDamage( out damageData : W3DamageAction, Enemy : CActor )
	{
		var skillLevel, i : int;
		var damageMult : float;
		
		if( thePlayer.CanUseSkill(S_Sword_s15) )
		{
			if( !Enemy.IsColdBloodActive() )
			{
				Enemy.SetColdBloodActive(true);
				Enemy.IncColdBloodCharge();
			}
			else
			{
				skillLevel = thePlayer.GetSkillLevel(S_Sword_s15);
				
				if( (CPlayer)damageData.attacker && (((CThrowable)damageData.causer).HasTag('ThrowingKnifeObject') || (W3BoltProjectile)damageData.causer) )
				{
					if( Enemy.ColdBloodCharge() > 0 )
					{
						damageMult = MinF( 1.f + (0.02f * skillLevel * Enemy.ColdBloodCharge() ), 1.f + 0.1f * skillLevel );
						damageData.processedDmg.vitalityDamage *= damageMult;
						damageData.processedDmg.essenceDamage *= damageMult;
					}
					Enemy.IncColdBloodCharge();
					Enemy.AddTimer('ResetCB', 7, false,,,,true);
				}
			}
		}
	}
}