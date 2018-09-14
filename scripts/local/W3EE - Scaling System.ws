/****************************************************************************/
/** Copyright © CD Projekt RED 2015
/** Author : Reaperrz
/****************************************************************************/
import class CEntityTemplate extends CResource
{
	import var includes : array<CEntityTemplate>;
}

enum EMeleeWeaponType
{
	EMWT_None,
	EMWT_SwordWooden,
	EMWT_Sword1H,
	EMWT_Sword1HStrong,
	EMWT_Sword2H,
	EMWT_Spear,
	EMWT_Halberd,
	EMWT_Pike,
	EMWT_MetalPole,
	EMWT_FirePoker,
	EMWT_Staff,
	EMWT_Mace,
	EMWT_Club,
	EMWT_Axe,
	EMWT_Hatchet,
	EMWT_GreatAxe,
	EMWT_GreatHammerWood,
	EMWT_GreatHammerMetal
}

enum ERangedWeaponType
{
	ERWT_None,
	ERWT_ShortBow,
	ERWT_LongBow,
	ERWT_Crossbow
}

exec function gettargetarmor()
{
	var temp : name;
	
	temp = Scaling().GetArmorType(((CNewNPC)thePlayer.GetTarget()));
}

class W3EEScalingHandler extends W3EEOptionHandler
{
	public function GetArmorType( NPC : CNewNPC ) : name
    {
        var meshComps : array<CComponent>;
        var armorTypes : array<int>;
        var i, max : int;
        var mesh : CComponent;
        var meshName : string;
		
		armorTypes.Resize(4);
        meshComps = NPC.GetComponentsByClassName('CMeshComponent');
        for(i=0; i<meshComps.Size(); i+=1)
        {
            mesh = meshComps[i];
            meshName = mesh.GetName();
            if( StrContains(meshName, "knight") )
				armorTypes[0] += 1;
			else
			if( StrContains(meshName, "twals_01_ma__guard") )
				armorTypes[1] += 3;
			else
			if( StrContains(meshName, "guard") || StrContains(meshName, "baron_thug_lvl2") || StrContains(meshName, "squire") || StrContains(meshName, "hb_10_ma__dlc") || StrContains(meshName, "skellige_warrior_lvl3") || StrContains(meshName, "t2_02_ma__bob") || StrContains(meshName, "g_02_ma__bob") || StrContains(meshName, "a_03_ma__bob") || StrContains(meshName, "c_01_ma__bob") || StrContains(meshName, "_10_ma__dlc") )
				armorTypes[1] += 1;
			else
			if( StrContains(meshName, "skellige_warrior_lvl2") || StrContains(meshName, "inquisition") || StrContains(meshName, "iquisitor") || StrContains(meshName, "baron_thug") )
				armorTypes[2] += 1;
			else
			if( StrContains(meshName, "bandit") || StrContains(meshName, "skellige_warrior_lvl1") )
				armorTypes[3] += 1;
        }
		
		for(i=0; i<armorTypes.Size(); i+=1)
			if( armorTypes[i] > max )
				max = armorTypes[i];
		
		if( max > 1 )
		{
			if( max == armorTypes[0] )
				return 'Heavy';
			if( max == armorTypes[1] )
				return 'Mixed';
			if( max == armorTypes[2] )
				return 'Medium';
			if( max == armorTypes[3] )
				return 'Light';
		}
		else
		if( max == 1 )
		{
			if( armorTypes[0] + armorTypes[1] > 1 )
				return 'Mixed';
			if( armorTypes[1] + armorTypes[2] > 1 )
				return 'Medium';
			if( max == armorTypes[3] )
				return 'Light';
		}
        return 'None';
    }
    
    private function GetMeleeWeaponFromAbilities( NPC : CNewNPC, abilities : array<name> ) : EMeleeWeaponType
    {
		if( abilities.Contains('NPC Wooden sword _Stats') )
			return EMWT_SwordWooden;
		else
		if( abilities.Contains('Spear 1 _Stats') || abilities.Contains('Spear 2 _Stats') || abilities.Contains('NPC Wild Hunt Spear _Stats') || abilities.Contains('Pitchfork _Stats') )
			return EMWT_Spear;
		else
		if( abilities.Contains('Halberd 1 _Stats') || abilities.Contains('Halberd 2 _Stats') || abilities.Contains('NPC Wild Hunt Halberd') )
			return EMWT_Halberd;
		else
		if( abilities.Contains('Guisarme 1 _Stats') || abilities.Contains('Guisarme 2 _Stats') )
			return EMWT_Pike;
		else
		if( abilities.Contains('Long metal pole _Stats') || abilities.Contains('Shovel _Stats') || abilities.Contains('Scythe _Stats') )
			return EMWT_MetalPole;
		else
		if( abilities.Contains('Poker _Stats') || abilities.Contains('q308 Iron Poker _Stats') )
			return EMWT_FirePoker;
		else
 		if( abilities.Contains('Staff _Stats') || abilities.Contains('Oar _Stats') || abilities.Contains('Rake _Stats') )
			return EMWT_Staff;
		else
 		if( abilities.Contains('Mace 1 _Stats') || abilities.Contains('Mace 2 _Stats') )
			return EMWT_Mace;
		else
 		if( abilities.Contains('Club _Stats') || abilities.Contains('Small Blackjack _Stats') || abilities.Contains('Blackjack _Stats') || abilities.Contains('Wand _Stats') || abilities.Contains('Scoop _Stats') || abilities.Contains('Paling _Stats') || abilities.Contains('Shepard stick _Stats') || abilities.Contains('Plank _Stats') || abilities.Contains('NPC torch _Stats') || abilities.Contains('Laundry stick _Stats') )
			return EMWT_Club;
		else
 		if( abilities.Contains('Axe 1 _Stats') || abilities.Contains('Axe 2 _Stats') )
			return EMWT_Axe;
		else
 		if( abilities.Contains('Hatchet _Stats') )
			return EMWT_Hatchet;
		else
 		if( abilities.Contains('Great Axe 1 _Stats') || abilities.Contains('Great Axe 2 _Stats') || abilities.Contains('Dwarven Axe _Stats') || abilities.Contains('NPC Wild Hunt Axe _Stats') )
			return EMWT_GreatAxe;
		else
 		if( abilities.Contains('Dwarven Hammer _Stats') || abilities.Contains('NPC Wild Hunt Hammer') || abilities.Contains('Twohanded Hammer 2 _Stats') || abilities.Contains('Lucerne Hammer _Stats') || abilities.Contains('Pickaxe _Stats') )
			return EMWT_GreatHammerMetal;
		else
 		if( abilities.Contains('Twohanded Hammer 1 _Stats') )
			return EMWT_GreatHammerWood;
		else
		{
			if( NPC.HasAbility('SkillElite') || NPC.HasAbility('SkillBoss') || NPC.HasAbility('mon_wild_hunt_default') )
				return EMWT_Sword2H;
			else
			if( NPC.HasAbility('SkillOfficer') || NPC.HasAbility('SkillMercenary') || NPC.HasAbility('SkillGuard') || NPC.HasAbility('SkillSoldier') )
				return EMWT_Sword1HStrong;
			else
				return EMWT_Sword1H;
		}
	}
    
    private function GetRangedWeaponFromAbilities( abilities : array<name> ) : ERangedWeaponType
    {
 		if( abilities.Contains('Bow 1 _Stats') || abilities.Contains('Bow 2 _Stats') )
			return ERWT_ShortBow;
		else
 		if( abilities.Contains('Long bow 1 _Stats') || abilities.Contains('Long bow 2 _Stats') || abilities.Contains('Elven bow _Stats') )
			return ERWT_LongBow;
		else
 		if( abilities.Contains('Crossbow 01 _Stats') || abilities.Contains('Dwarven crossbow _Stats') || abilities.Contains('Nilfgaardian crossbow _Stats') )
			return ERWT_Crossbow;
		else
			return ERWT_None;
    }
    
    private function GetWeaponTypes( NPC : CNewNPC, out opponentStats : SOpponentStats )
    {
		var rangedWeapon : ERangedWeaponType;
		var meleeWeapon : EMeleeWeaponType;
		var weapons : array<SItemUniqueId>;
		var inv : CInventoryComponent;
		var tags, abilities : array<name>;
		var i : int;
		
		opponentStats.meleeWeapon = EMWT_Sword1H;
		opponentStats.rangedWeapon = ERWT_None;
		
		inv = NPC.GetInventory();
		weapons = inv.GetItemsByTag('mod_weapon');
		for(i=0; i<weapons.Size(); i+=1)
		{
			inv.GetItemTags(weapons[i], tags);
			inv.GetItemAbilities(weapons[i], abilities);
			
			meleeWeapon = GetMeleeWeaponFromAbilities(NPC, abilities);
			rangedWeapon = GetRangedWeaponFromAbilities(abilities);
			
			if( meleeWeapon > 0 )
				opponentStats.meleeWeapon = meleeWeapon;
			if( rangedWeapon > 0 )
				opponentStats.rangedWeapon = rangedWeapon;
			
			abilities.Clear();
		}
    }
    
    private function HasTwoHandedWeapon( opponentStats : SOpponentStats ) : bool
    {
		switch(opponentStats.meleeWeapon)
		{
			case EMWT_Spear:
			case EMWT_Halberd:
			case EMWT_Halberd:
			case EMWT_Pike:
			case EMWT_MetalPole:
			case EMWT_Staff:
			case EMWT_GreatAxe:
			case EMWT_GreatHammerWood:
			case EMWT_GreatHammerMetal:
				return true;
			
			default : return false;
		}
		
		return false;
    }
    
    private function ApplyStatModifiers( NPC : CNewNPC, out opponentStats : SOpponentStats )
    {
		var armorType : name;
		var speedMult : float;
		
		if( GetAttitudeBetween(thePlayer, NPC) != AIA_Hostile || NPC.GetNPCType() == ENGT_Commoner || NPC.GetNPCType() == ENGT_Quest )
			return;
		
		speedMult = 1.f;
		armorType = GetArmorType(NPC);
		if( NPC.IsHuman() )
		{
			switch(armorType)
			{
				case 'Heavy':	speedMult -= 0.06f;	break;
				case 'Mixed':	speedMult -= 0.03f;	break;
				case 'Medium':	speedMult -= 0.02f;	break;
				case 'Light':
				default:							break;
			}
			
			if( HasTwoHandedWeapon(opponentStats) )
				speedMult -= 0.03f;
			if( opponentStats.meleeWeapon == EMWT_Club || opponentStats.meleeWeapon == EMWT_Mace )
				speedMult -= 0.1f;
		}
		else
		{
			if( NPC.HasAbility('mon_lessog_base') )
				speedMult += 0.4f;
			
			if( NPC.HasAbility('mon_golem') )
				speedMult += 0.20f;
			else
			if( NPC.HasAbility('mon_golem_base') )
				speedMult += 0.15f;
			if( NPC.HasAbility('mon_cyclops') || NPC.HasAbility('mon_ice_giant') )
				speedMult += 0.10f;
			if( NPC.HasAbility('mon_fleder') )
				speedMult -= 0.15f;
			if( NPC.HasAbility('mon_garkain') )
				speedMult -= 0.10;
			if( NPC.HasAbility('mon_nightwraith') )
				speedMult += 0.1f;
			
			if( NPC.HasAbility('mon_bies_base') )
				speedMult += 0.18f;
			
			if( NPC.HasAbility('mon_arachas_base') )
			{
				if( NPC.HasAbility('mon_arachas_armored') )
					speedMult -= 0.25f;
				else
				if( NPC.HasAbility('mon_poison_arachas') )
					speedMult -= 0.17f;
				else
					speedMult -= 0.21f;
			}
			if( NPC.HasAbility('mon_gravehag_base') && ! NPC.HasTag('fogling_doppelganger') )
				speedMult += 0.05f;
				
			if( NPC.HasAbility('mon_harpy_base') )
                speedMult += 0.1f;
			if( NPC.HasAbility('mon_siren_base') )
                speedMult += 0.06f;
			if( NPC.HasAbility('mon_wyvern_base') )
			{
				if( NPC.HasAbility('mon_wyvern') )
					speedMult += 0.1f;
				else
				if( NPC.HasAbility('mon_forktail') )
					speedMult += 0.20f;
				else
					speedMult += 0.15f;
			}
			
			if( NPC.HasAbility('mon_boar_base') || NPC.HasAbility('mon_boar_ep2_base') || NPC.HasAbility('mon_ft_boar_ep2_base') )
				speedMult -= 0.2f;
			
			if( NPC.HasAbility('mon_rotfiend') )
				speedMult += 0.1f;
			if( NPC.HasAbility('mon_gravier') )
				speedMult += 0.02f;
			
			if( NPC.HasAbility('mon_endriaga_worker') )
				speedMult += 0.12f;
			if( NPC.HasAbility('mon_endriaga_soldier_spikey') )
				speedMult -= 0.1f;
				
			if( NPC.HasAbility('mon_kikimore_small') )
				speedMult -= 0.1f;
				
			if (NPC.HasAbility('mon_archespor_base'))
				speedMult -= 0.05f;
			
			if( NPC.HasAbility('WildHunt_Eredin') )
				speedMult += 0.15f;
			
			if( NPC.HasAbility('mon_wild_hunt_default') && !NPC.HasTag('IsBoss') )
			{
				speedMult += 0.05f;
			}
		}
		
		opponentStats.spdMultID = NPC.SetAnimationSpeedMultiplier(speedMult, opponentStats.spdMultID);
    }
    
    private function EnemyDisparity( NPC : CNewNPC, out opponentStats : SOpponentStats )
    {
		if( GetAttitudeBetween(thePlayer, NPC) != AIA_Hostile || NPC.GetNPCType() == ENGT_Commoner || NPC.GetNPCType() == ENGT_Quest )
			return;
		
		opponentStats.healthValue *= RandRangeF(1.1f, 0.9f);
		opponentStats.damageValue *= RandRangeF(1.1f, 0.9f);
    }
    
	private function AddSpecterResistances( NPC : CNewNPC )
	{
		NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_STUN);
		NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FIRE);
		NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
		NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FROST);
		NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
		NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_MENTAL);
		NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_BLEEDING);
	}
	
	public function CalculateStatsBoss( NPC : CNewNPC, out opponentStats : SOpponentStats, out wasNotScaled : bool )
	{
		var weaponTags : array<name>;
		var npcStats : CCharacterStats;
		npcStats = NPC.GetCharacterStats();
		
		if( npcStats.HasAbilityWithTag('Boss') || NPC.HasTag('sq701_gregoire') || NPC.HasTag('sq202_djinn') || NPC.HasTag('q701_sharley') || NPC.HasTag('dettlaff_minion') || NPC.HasAbility('olgierd_default_stats') || NPC.HasAbility('mon_cloud_giant') || NPC.HasAbility('mon_dettlaff_bossbar_dummy') || NPC.HasAbility('mon_fairytale_witch') || NPC.HasAbility('mon_broom_base') || NPC.HasAbility('mon_dettlaff_monster_base') || NPC.HasAbility('mon_dettlaff_vampire_base') || NPC.HasAbility('mon_nightwraith_iris') || NPC.HasAbility('mon_caretaker_ep1') || NPC.HasAbility('mon_EP2_SpoonCollector') || NPC.HasAbility('mon_q701_giant') || NPC.HasAbility('q104_whboss') || NPC.HasAbility('mon_toad_base') || NPC.HasTag('q103_big_botch') || NPC.HasTag('q704_dettlaff_bossbar') || NPC.HasAbility('mon_witch1') || NPC.HasAbility('mon_witch2') || NPC.HasAbility('mon_witch3') )
		{
			NPC.AddTag('IsBoss');
			NPC.AddTag('NoImmobilize');
			opponentStats.canGetCrippled = false;
			if( NPC.HasAbility('q104_whboss') )
			{
				opponentStats.damageValue = 3755;
				opponentStats.healthValue = 38500;
				opponentStats.healthType = BCS_Vitality;
				
				opponentStats.isArmored			= true;
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 1.f;
				opponentStats.physicalResist	= 0.90f;
				opponentStats.forceResist 		= 0.4f;
				opponentStats.frostResist 		= 1.f;
				opponentStats.fireResist 		= 0.6f;
				opponentStats.shockResist 		= -0.1f;
				opponentStats.elementalResist 	= -0.1f;
				opponentStats.slowResist 		= 0.3f;
				opponentStats.confusionResist 	= 0.f;
				opponentStats.bleedingResist 	= 0.5f;
				opponentStats.poisonResist 		= 0.35f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 0.3f;
				opponentStats.armorPiercing 	= 0.7f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FROST);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasAbility('WildHunt_Imlerith') )
			{
				opponentStats.damageValue = 3400;
				opponentStats.healthValue = 32500;
				opponentStats.healthType = BCS_Vitality;
				
				opponentStats.isArmored			= true;
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 1.f;
				opponentStats.physicalResist	= 0.9f;
				opponentStats.forceResist 		= 0.4f;
				opponentStats.frostResist 		= 1.f;
				opponentStats.fireResist 		= 0.5f;
				opponentStats.shockResist 		= -0.1f;
				opponentStats.elementalResist 	= -0.1f;
				opponentStats.slowResist 		= 0.3f;
				opponentStats.confusionResist 	= 0.f;
				opponentStats.bleedingResist 	= 0.5f;
				opponentStats.poisonResist 		= 0.35f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 0.3f;
				opponentStats.armorPiercing 	= 0.7f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FROST);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasAbility('WildHunt_Caranthir') )
			{
				opponentStats.damageValue = 2000;
				opponentStats.healthValue = 23000;
				opponentStats.healthType = BCS_Vitality;
				
				opponentStats.isArmored			= true;
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.75f;
				opponentStats.physicalResist	= 0.7f;
				opponentStats.forceResist 		= 0.4f;
				opponentStats.frostResist 		= 1.f;
				opponentStats.fireResist 		= 0.6f;
				opponentStats.shockResist 		= -0.1f;
				opponentStats.elementalResist 	= -0.1f;
				opponentStats.slowResist 		= 0.3f;
				opponentStats.confusionResist 	= 0.f;
				opponentStats.bleedingResist 	= 0.5f;
				opponentStats.poisonResist 		= 0.35f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 0.3f;
				opponentStats.armorPiercing 	= 0.6f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FROST);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasAbility('WildHunt_Eredin') )
			{
				opponentStats.damageValue = 2200;
				opponentStats.healthValue = 30000;
				opponentStats.healthType = BCS_Vitality;
				
				opponentStats.isArmored			= true;
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.9f;
				opponentStats.physicalResist	= 0.85f;
				opponentStats.forceResist 		= 0.4f;
				opponentStats.frostResist 		= 1.f;
				opponentStats.fireResist 		= 0.5f;
				opponentStats.shockResist 		= -0.1f;
				opponentStats.elementalResist 	= -0.1f;
				opponentStats.slowResist 		= 0.3f;
				opponentStats.confusionResist 	= 0.f;
				opponentStats.bleedingResist 	= 0.5f;
				opponentStats.poisonResist 		= 0.35f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 0.3f;
				opponentStats.armorPiercing 	= 0.5f;
				
				opponentStats.rangedDamageValue = 4200;
				opponentStats.rangedArmorPiercing = 0.6f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FROST);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasTag('q103_big_botch') )
			{
				opponentStats.damageValue = 2850;
				opponentStats.healthValue = 21850;
				opponentStats.healthType = BCS_Vitality;
				
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.35f;
				opponentStats.physicalResist	= 0.4f;
				opponentStats.forceResist 		= 0.2f;
				opponentStats.frostResist 		= 0.2f;
				opponentStats.fireResist 		= 0.2f;
				opponentStats.shockResist 		= 0.2f;
				opponentStats.elementalResist 	= 0.2f;
				opponentStats.slowResist 		= 0.15f;
				opponentStats.confusionResist 	= 0.2f;
				opponentStats.bleedingResist 	= 0.2f;
				opponentStats.poisonResist 		= 1.0f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 0.f;
				opponentStats.armorPiercing 	= 0.45f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasAbility('olgierd_default_stats') )
			{
				NPC.AddTimer('AddHealthRegenEffect', 0.3f, false);
				opponentStats.damageValue = 2175;
				opponentStats.healthValue = 27680;
				opponentStats.healthType = BCS_Vitality;
				
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.25f;
				opponentStats.physicalResist	= 0.4f;
				opponentStats.forceResist 		= 0.15f;
				opponentStats.frostResist 		= 0.15f;
				opponentStats.fireResist 		= 0.5f;
				opponentStats.shockResist 		= 0.f;
				opponentStats.elementalResist 	= 0.f;
				opponentStats.slowResist 		= 0.1f;
				opponentStats.confusionResist 	= 0.1f;
				opponentStats.bleedingResist 	= 0.3f;
				opponentStats.poisonResist 		= 0.3f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 1.f;
				opponentStats.armorPiercing 	= 0.5f;
				opponentStats.regenDelay 		= 2.f;
				opponentStats.healthRegenFactor = 0.005f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasAbility('mon_toad_base') )
			{
				opponentStats.damageValue = 3410;
				opponentStats.healthValue = 47450;
				opponentStats.healthType = BCS_Vitality;
				
				opponentStats.isHuge			= true;
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.f;
				opponentStats.physicalResist	= 0.3f;
				opponentStats.forceResist 		= 0.35f;
				opponentStats.frostResist 		= -0.3f;
				opponentStats.fireResist 		= -0.3f;
				opponentStats.shockResist 		= -0.3f;
				opponentStats.elementalResist 	= -0.3f;
				opponentStats.slowResist 		= 0.2f;
				opponentStats.confusionResist 	= 0.2f;
				opponentStats.bleedingResist 	= 0.2f;
				opponentStats.poisonResist 		= 1.f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 0.2f;
				opponentStats.armorPiercing 	= 0.60f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasAbility('mon_q701_giant') )
			{
				NPC.RemoveBuffImmunity(EET_Frozen);
				opponentStats.damageValue = 3940;
				opponentStats.healthValue = 48990;
				opponentStats.healthType = BCS_Vitality;
				
				opponentStats.isHuge			= true;
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.f;
				opponentStats.physicalResist	= 0.75f;
				opponentStats.forceResist 		= 0.4f;
				opponentStats.frostResist 		= 0.f;
				opponentStats.fireResist 		= 0.f;
				opponentStats.shockResist 		= 0.f;
				opponentStats.elementalResist 	= 0.f;
				opponentStats.slowResist 		= 0.3f;
				opponentStats.confusionResist 	= 0.f;
				opponentStats.bleedingResist 	= 0.2f;
				opponentStats.poisonResist 		= 0.f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 0.15f;
				opponentStats.armorPiercing 	= 0.65f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasAbility('mon_EP2_SpoonCollector') )
			{
				opponentStats.damageValue = 2495;
				opponentStats.healthValue = 22880;
				opponentStats.healthType = BCS_Vitality;
				
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.25f;
				opponentStats.physicalResist	= 0.2f;
				opponentStats.forceResist 		= 0.2f;
				opponentStats.frostResist 		= 0.2f;
				opponentStats.fireResist 		= 0.4f;
				opponentStats.shockResist 		= 0.f;
				opponentStats.elementalResist 	= 0.f;
				opponentStats.slowResist 		= 0.15f;
				opponentStats.confusionResist 	= 0.15f;
				opponentStats.bleedingResist 	= 0.1f;
				opponentStats.poisonResist 		= 1.f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 0.f;
				opponentStats.armorPiercing 	= 0.45f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasAbility('mon_caretaker_ep1') )
			{
				opponentStats.damageValue = 2460;
				opponentStats.healthValue = 34100;
				opponentStats.healthType = BCS_Vitality;
				
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.f;
				opponentStats.physicalResist	= 0.3f;
				opponentStats.forceResist 		= 0.7f;
				opponentStats.frostResist 		= 0.7f;
				opponentStats.fireResist 		= 0.7f;
				opponentStats.shockResist 		= 0.7f;
				opponentStats.elementalResist 	= 0.7f;
				opponentStats.slowResist 		= 0.2f;
				opponentStats.confusionResist 	= 1.f;
				opponentStats.bleedingResist 	= 1.f;
				opponentStats.poisonResist 		= 1.f;
				opponentStats.stunResist 		= 1.f;
				opponentStats.injuryResist 		= 0.5f;
				opponentStats.armorPiercing 	= 0.55f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasAbility('mon_nightwraith_iris') )
			{
				opponentStats.damageValue = 1355;
				opponentStats.healthValue = 29380;
				opponentStats.healthType = BCS_Essence;
				
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.0f;
				opponentStats.physicalResist	= 0.f;
				opponentStats.forceResist 		= 1.f;
				opponentStats.frostResist 		= 1.f;
				opponentStats.fireResist 		= 1.f;
				opponentStats.shockResist 		= -0.3f;
				opponentStats.elementalResist 	= -0.3f;
				opponentStats.slowResist 		= 0.3f;
				opponentStats.confusionResist 	= 1.f;
				opponentStats.bleedingResist 	= 1.f;
				opponentStats.poisonResist 		= 1.f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 1.f;
				opponentStats.armorPiercing 	= 0.55f;
				AddSpecterResistances(NPC);
			}
			else
			if( NPC.HasAbility('mon_dettlaff_vampire_base') )
			{
				opponentStats.damageValue = 1855;
				opponentStats.healthValue = 40520;
				opponentStats.healthType = BCS_Essence;
				
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.45f;
				opponentStats.physicalResist	= 0.7f;
				opponentStats.forceResist 		= 0.2f;
				opponentStats.frostResist 		= 0.5f;
				opponentStats.fireResist 		= 0.3f;
				opponentStats.shockResist 		= 0.3f;
				opponentStats.elementalResist 	= 0.3f;
				opponentStats.slowResist 		= 0.1f;
				opponentStats.confusionResist 	= 1.f;
				opponentStats.bleedingResist 	= 0.f;
				opponentStats.poisonResist 		= 1.f;
				opponentStats.stunResist 		= 0.1f;
				opponentStats.injuryResist 		= 0.1f;
				opponentStats.armorPiercing 	= 0.75f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_MENTAL);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasTag('q704_dettlaff_bossbar') )
			{
				opponentStats.damageValue = 0;
				opponentStats.healthValue = 57750;
				opponentStats.healthType = BCS_Essence;
				
				opponentStats.isHuge			= true;
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 1.f;
				opponentStats.physicalResist	= 0.95f;
				opponentStats.forceResist 		= 0.8f;
				opponentStats.frostResist 		= 0.8f;
				opponentStats.fireResist 		= 0.8f;
				opponentStats.shockResist 		= 0.4f;
				opponentStats.elementalResist 	= 0.4f;
				opponentStats.slowResist 		= 0.5f;
				opponentStats.confusionResist 	= 0.5f;
				opponentStats.bleedingResist 	= 0.6f;
				opponentStats.poisonResist 		= 1.0f;
				opponentStats.stunResist 		= 0.5f;
				opponentStats.injuryResist 		= 0.5f;
				opponentStats.armorPiercing 	= 0.8f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasAbility('mon_dettlaff_monster_base') )
			{
				opponentStats.damageValue = 7820;
				opponentStats.healthValue = 57750;
				opponentStats.healthType = BCS_Essence;
				
				opponentStats.isHuge			= true;
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 1.f;
				opponentStats.physicalResist	= 0.95f;
				opponentStats.forceResist 		= 0.5f;
				opponentStats.frostResist 		= 0.5f;
				opponentStats.fireResist 		= 0.5f;
				opponentStats.shockResist 		= 0.5f;
				opponentStats.elementalResist 	= 0.5f;
				opponentStats.slowResist 		= 0.5f;
				opponentStats.confusionResist 	= 0.5f;
				opponentStats.bleedingResist 	= 0.5f;
				opponentStats.poisonResist 		= 1.0f;
				opponentStats.stunResist 		= 0.5f;
				opponentStats.injuryResist 		= 0.5f;
				opponentStats.armorPiercing 	= 0.8f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasTag('dettlaff_minion') )
			{
				opponentStats.damageValue = 2175;
				opponentStats.healthValue = 5500;
				opponentStats.healthType = BCS_Essence;
				
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.45f;
				opponentStats.physicalResist	= 0.f;
				opponentStats.forceResist 		= 1.f;
				opponentStats.frostResist 		= 1.f;
				opponentStats.fireResist 		= 1.f;
				opponentStats.shockResist 		= 1.f;
				opponentStats.elementalResist 	= 1.f;
				opponentStats.slowResist 		= 0.5f;
				opponentStats.confusionResist 	= 1.f;
				opponentStats.bleedingResist 	= 1.f;
				opponentStats.poisonResist 		= 1.f;
				opponentStats.stunResist 		= 0.1f;
				opponentStats.injuryResist 		= 1.f;
				opponentStats.armorPiercing 	= 0.65f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FIRE);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FROST);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_SHOCK);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_MENTAL);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasAbility('mon_fairytale_witch') )
			{
				opponentStats.damageValue = 1670;
				opponentStats.healthValue = 9850;
				opponentStats.healthType = BCS_Vitality;
				
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.0f;
				opponentStats.physicalResist	= 0.1f;
				opponentStats.forceResist 		= 0.f;
				opponentStats.frostResist 		= 0.f;
				opponentStats.fireResist 		= 0.f;
				opponentStats.shockResist 		= 0.f;
				opponentStats.elementalResist 	= 0.f;
				opponentStats.slowResist 		= 0.f;
				opponentStats.confusionResist 	= 0.f;
				opponentStats.bleedingResist 	= 0.f;
				opponentStats.poisonResist 		= 0.f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 0.f;
				opponentStats.armorPiercing 	= 0.5f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasAbility('mon_broom_base') )
			{
				opponentStats.damageValue = 315;
				opponentStats.healthValue = 3100;
				opponentStats.healthType = BCS_Vitality;
				
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.f;
				opponentStats.physicalResist	= 0.15f;
				opponentStats.forceResist 		= 1.f;
				opponentStats.frostResist 		= 1.f;
				opponentStats.fireResist 		= -1.f;
				opponentStats.shockResist 		= 1.f;
				opponentStats.elementalResist 	= 1.f;
				opponentStats.slowResist 		= 1.f;
				opponentStats.confusionResist 	= 1.f;
				opponentStats.bleedingResist 	= 1.f;
				opponentStats.poisonResist 		= 1.f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 1.f;
				opponentStats.armorPiercing 	= 0.15f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_SHOCK);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_BLEEDING);
			}
			else
			if( NPC.HasAbility('mon_cloud_giant') )
			{
				NPC.RemoveBuffImmunity(EET_Frozen); 
				opponentStats.damageValue = 4060;
				opponentStats.healthValue = 48990;
				opponentStats.healthType = BCS_Vitality;
				
				opponentStats.isHuge			= true;
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.f;
				opponentStats.physicalResist	= 0.75f;
				opponentStats.forceResist 		= 0.4f;
				opponentStats.frostResist 		= 0.f;
				opponentStats.fireResist 		= 0.f;
				opponentStats.shockResist 		= 0.f;
				opponentStats.elementalResist 	= 0.f;
				opponentStats.slowResist 		= 0.3f;
				opponentStats.confusionResist 	= 0.f;
				opponentStats.bleedingResist 	= 0.2f;
				opponentStats.poisonResist 		= 0.f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 0.15f;
				opponentStats.armorPiercing 	= 0.7f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasTag('q701_sharley') )
			{
				opponentStats.damageValue = 2860;
				opponentStats.healthValue = 32110;
				opponentStats.healthType = BCS_Vitality;
				
				opponentStats.isHuge			= true;
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.0f;
				opponentStats.physicalResist	= 0.45f;
				opponentStats.forceResist 		= 0.4f;
				opponentStats.frostResist 		= 0.4f;
				opponentStats.fireResist 		= 0.f;
				opponentStats.shockResist 		= 0.3f;
				opponentStats.elementalResist 	= 0.f;
				opponentStats.slowResist 		= 0.3f;
				opponentStats.confusionResist 	= -0.2f;
				opponentStats.bleedingResist 	= 0.4f;
				opponentStats.poisonResist 		= 0.f;
				opponentStats.stunResist 		= 0.4f;
				opponentStats.injuryResist 		= 0.3f;
				opponentStats.armorPiercing 	= 0.75f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasTag('sq202_djinn') )
			{
				opponentStats.damageValue = 2175;
				opponentStats.healthValue = 35430;
				opponentStats.healthType = BCS_Essence;
				
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.f;
				opponentStats.physicalResist	= 0.4f;
				opponentStats.forceResist 		= 1.f;
				opponentStats.frostResist 		= 1.f;
				opponentStats.fireResist 		= 1.f;
				opponentStats.shockResist 		= 1.f;
				opponentStats.elementalResist 	= 1.f;
				opponentStats.slowResist 		= 1.f;
				opponentStats.confusionResist 	= 1.f;
				opponentStats.bleedingResist 	= 1.f;
				opponentStats.poisonResist 		= 1.f;
				opponentStats.stunResist 		= 1.f;
				opponentStats.injuryResist 		= 1.f;
				opponentStats.armorPiercing 	= 0.7f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasTag('sq701_gregoire') )
			{
				opponentStats.damageValue = 4320;
				opponentStats.healthValue = 20130;
				opponentStats.healthType = BCS_Vitality;
				
				opponentStats.isArmored			= true;
				opponentStats.isHuge			= true;
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.f;
				opponentStats.physicalResist	= 1.0f;
				opponentStats.forceResist 		= 0.4f;
				opponentStats.frostResist 		= 0.4f;
				opponentStats.fireResist 		= 0.5f;
				opponentStats.shockResist 		= -0.2f;
				opponentStats.elementalResist 	= 0.f;
				opponentStats.slowResist 		= 0.2f;
				opponentStats.confusionResist 	= 0.3f;
				opponentStats.bleedingResist 	= 0.6f;
				opponentStats.poisonResist 		= 0.4f;
				opponentStats.stunResist 		= 0.5f;
				opponentStats.injuryResist 		= 0.4f;
				opponentStats.armorPiercing 	= 0.65f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasAbility('mon_witch1') )
			{
				opponentStats.damageValue = 1700;
				opponentStats.healthValue = 17500;
				opponentStats.healthType = BCS_Essence;
				
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.3f;
				opponentStats.physicalResist	= 0.f;
				opponentStats.forceResist 		= 0.2f;
				opponentStats.frostResist 		= 0.2f;
				opponentStats.fireResist 		= 0.2f;
				opponentStats.shockResist 		= 0.2f;
				opponentStats.elementalResist 	= 0.f;
				opponentStats.slowResist 		= 0.2f;
				opponentStats.confusionResist 	= 0.2f;
				opponentStats.bleedingResist 	= 0.2f;
				opponentStats.poisonResist 		= 0.2f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 0.2f;
				opponentStats.armorPiercing 	= 0.3f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasAbility('mon_witch2') )
			{
				opponentStats.damageValue = 1700;
				opponentStats.healthValue = 21900;
				opponentStats.healthType = BCS_Essence;
				
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.3f;
				opponentStats.physicalResist	= 0.f;
				opponentStats.forceResist 		= 0.2f;
				opponentStats.frostResist 		= 0.2f;
				opponentStats.fireResist 		= 0.2f;
				opponentStats.shockResist 		= 0.2f;
				opponentStats.elementalResist 	= 0.f;
				opponentStats.slowResist 		= 0.2f;
				opponentStats.confusionResist 	= 0.2f;
				opponentStats.bleedingResist 	= 0.2f;
				opponentStats.poisonResist 		= 0.2f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 0.2f;
				opponentStats.armorPiercing 	= 0.3f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			if( NPC.HasAbility('mon_witch3') )
			{
				opponentStats.damageValue = 1700;
				opponentStats.healthValue = 17500;
				opponentStats.healthType = BCS_Essence;
				
				opponentStats.dangerLevel		= 100;
				opponentStats.poiseValue 		= 0.3f;
				opponentStats.physicalResist	= 0.f;
				opponentStats.forceResist 		= 0.2f;
				opponentStats.frostResist 		= 0.2f;
				opponentStats.fireResist 		= 0.2f;
				opponentStats.shockResist 		= 0.2f;
				opponentStats.elementalResist 	= 0.f;
				opponentStats.slowResist 		= 0.2f;
				opponentStats.confusionResist 	= 0.2f;
				opponentStats.bleedingResist 	= 0.2f;
				opponentStats.poisonResist 		= 0.2f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 0.2f;
				opponentStats.armorPiercing 	= 0.3f;
				NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
			}
			else
			{
				wasNotScaled = true;
				opponentStats.damageValue = 1;
				opponentStats.healthValue = 1;
				opponentStats.healthType = BCS_Vitality;
				
				opponentStats.dangerLevel		= 10;
				opponentStats.poiseValue 		= 0.f;
				opponentStats.physicalResist	= 0.f;
				opponentStats.forceResist 		= 0.f;
				opponentStats.frostResist 		= 0.f;
				opponentStats.fireResist 		= 0.f;
				opponentStats.shockResist 		= 0.f;
				opponentStats.elementalResist 	= 0.f;
				opponentStats.slowResist 		= 0.f;
				opponentStats.confusionResist 	= 0.f;
				opponentStats.bleedingResist 	= 0.f;
				opponentStats.poisonResist 		= 0.f;
				opponentStats.stunResist 		= 0.f;
				opponentStats.injuryResist 		= 0.f;
				opponentStats.armorPiercing 	= 0.f;
			}
		}
	}
    
	public function CalculateStatsPart1( NPC : CNewNPC, out opponentStats : SOpponentStats, out wasNotScaled : bool )
	{
		var weapon : array<SItemUniqueId>;
		var armorType : name;
		var npcStats : CCharacterStats;
		npcStats = NPC.GetCharacterStats();
		
		if( !NPC.HasTag('IsBoss') )
		{
			switch(opponentStats.opponentType)
			{
				case MC_Human :
					if( NPC.HasAbility('mon_ethereal_ep1') )
					{
						NPC.AddTag('NoImmobilize');
						opponentStats.damageValue = 1975;
						opponentStats.healthValue = 18840;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.5f;
					}
					else
					if( NPC.HasAbility('mon_ghosts_ep1') )
					{
						NPC.AddTag('NoImmobilize');
						opponentStats.damageValue = 1885;
						opponentStats.healthValue = 6930;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.3f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.3f;
						opponentStats.elementalResist 	= -0.3f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.65f;
						AddSpecterResistances(NPC);
					}
					else
					if( NPC.HasTag('sq209_brans_warrior') )
					{
						NPC.AddTag('NoImmobilize');
						opponentStats.damageValue = 2950;
						opponentStats.healthValue = 10080;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.3f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.3f;
						opponentStats.elementalResist 	= -0.3f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.65f;
						AddSpecterResistances(NPC);
					}
					else
					if( NPC.HasTag('sq209_lugos_the_mad_vision') )
					{
						NPC.AddTag('NoImmobilize');
						opponentStats.damageValue = 3325;
						opponentStats.healthValue = 21080;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.3f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.3f;
						opponentStats.elementalResist 	= -0.3f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.7f;
						AddSpecterResistances(NPC);
					}
					else
					if( NPC.HasTag('dandelion') )
					{
						opponentStats.damageValue = 900;
						opponentStats.healthValue = 4720;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.15f;
						opponentStats.physicalResist	= 0.2f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.2f;
					}
					else
					if( NPC.HasTag('mh303_succubus') || NPC.HasTag('sq205_succubus') )
					{
						NPC.AddTag('WeakToQuen');
						opponentStats.damageValue = 2370;
						opponentStats.healthValue = 10760;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.2f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= -0.1f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.6f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.8f;
					}
					else
					if( NPC.HasAbility('SkillSorceress') )
					{
						NPC.AddTag('NoImmobilize');
						NPC.AddTag('WeakToQuen');
						opponentStats.damageValue = 2730;
						opponentStats.healthValue = 9760;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.05f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= -0.1f;
						opponentStats.frostResist 		= 0.3f;
						opponentStats.fireResist 		= 0.3f;
						opponentStats.shockResist 		= 0.3f;
						opponentStats.elementalResist 	= 0.3f;
						opponentStats.slowResist 		= 0.3f;
						opponentStats.confusionResist 	= 0.5f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.7f;
					}
					else
					if( NPC.HasAbility('mh305_doppler_geralt') || NPC.HasAbility('mh305_doppler') )
					{
						NPC.AddTag('NoImmobilize');
						opponentStats.damageValue = 1450;
						opponentStats.healthValue = 8720;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.25f;
						opponentStats.physicalResist	= 0.3f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.15f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.3f;
					}
					else
					if( NPC.HasAbility('SkillWitcher') )
					{
						NPC.AddTag('NoImmobilize');
						opponentStats.damageValue = 3425;
						opponentStats.healthValue = 9820;
						
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.3f;
						opponentStats.physicalResist	= 0.55f;
						opponentStats.forceResist 		= 0.15f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.1f;
						opponentStats.shockResist 		= 0.1f;
						opponentStats.elementalResist 	= 0.1f;
						opponentStats.slowResist 		= 0.15f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.35f;
						opponentStats.poisonResist 		= 0.2f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.45f;
					}
					else
					if( NPC.HasTag('q601_ofir_mage') )
					{
						NPC.AddTag('NoImmobilize');
						NPC.RemoveTag('MonsterHuntTarget');
						opponentStats.damageValue = 2110;
						opponentStats.healthValue = 7525;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.15f;
						opponentStats.physicalResist	= 0.2f;
						opponentStats.forceResist 		= 0.15f;
						opponentStats.frostResist 		= 0.15f;
						opponentStats.fireResist 		= 0.15f;
						opponentStats.shockResist 		= 0.2f;
						opponentStats.elementalResist 	= 0.2f;
						opponentStats.slowResist 		= 0.15f;
						opponentStats.confusionResist 	= 0.4f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.65f;
					}
					else
					if( NPC.HasAbility('mon_EP2_hermit') )
					{
						NPC.AddTag('NoImmobilize');
						NPC.RemoveTag('MonsterHuntTarget');
						opponentStats.damageValue = 1715;
						opponentStats.healthValue = 7525;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.15f;
						opponentStats.physicalResist	= 0.2f;
						opponentStats.forceResist 		= 0.35f;
						opponentStats.frostResist 		= -0.25f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.2f;
						opponentStats.elementalResist 	= 0.2f;
						opponentStats.slowResist 		= 0.25f;
						opponentStats.confusionResist 	= 0.5f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.65f;
					}
					else
					if( NPC.HasAbility('q604_shades') )
					{
						NPC.AddTag('NoImmobilize');
						opponentStats.damageValue = 0;
						opponentStats.healthValue = 1;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 0;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.3f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.3f;
						opponentStats.elementalResist 	= -0.3f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.f;
						AddSpecterResistances(NPC);
					}
					else
					{
						armorType = GetArmorType(NPC);
						GetWeaponTypes(NPC, opponentStats);
						
						if( opponentStats.meleeWeapon == EMWT_GreatAxe )
						{
							weapon = NPC.GetInventory().GetItemsByName('geralt_axe_01');
							if( !weapon.Size() )
								NPC.GetInventory().AddAnItem('geralt_axe_01', 1);
						}
						switch(opponentStats.meleeWeapon)
						{
							case EMWT_Sword1H:				opponentStats.damageValue = 2475;	opponentStats.armorPiercing = 0.20f;	break;
							case EMWT_Sword1HStrong:		opponentStats.damageValue = 2530;	opponentStats.armorPiercing = 0.25f;	break;
							case EMWT_Sword2H:				opponentStats.damageValue = 3200;	opponentStats.armorPiercing = 0.35f;	break;
							case EMWT_Hatchet:				opponentStats.damageValue = 2075;	opponentStats.armorPiercing = 0.35f;	break;
							case EMWT_Axe:					opponentStats.damageValue = 2220;	opponentStats.armorPiercing = 0.40f;	break;
							case EMWT_GreatAxe:				opponentStats.damageValue = 3560;	opponentStats.armorPiercing = 0.45f;	break;
							case EMWT_Club:					opponentStats.damageValue = 1940;	opponentStats.armorPiercing = 0.20f;	break;
							case EMWT_Mace:					opponentStats.damageValue = 2125;	opponentStats.armorPiercing = 0.45f;	break;
							case EMWT_GreatHammerWood:		opponentStats.damageValue = 3035;	opponentStats.armorPiercing = 0.30f;	break;
							case EMWT_GreatHammerMetal:		opponentStats.damageValue = 3035;	opponentStats.armorPiercing = 0.55f;	break;
							case EMWT_Halberd:				opponentStats.damageValue = 3235;	opponentStats.armorPiercing = 0.45f;	break;
							case EMWT_Pike:					opponentStats.damageValue = 3235;	opponentStats.armorPiercing = 0.55f;	break;
							case EMWT_Spear:				opponentStats.damageValue = 2585;	opponentStats.armorPiercing = 0.50f;	break;
							case EMWT_Staff:				opponentStats.damageValue = 1835;	opponentStats.armorPiercing = 0.20f;	break;
							case EMWT_SwordWooden:			opponentStats.damageValue = 1335;	opponentStats.armorPiercing = 0.10f;	break;
							case EMWT_MetalPole:			opponentStats.damageValue = 2235;	opponentStats.armorPiercing = 0.25f;	break;
							case EMWT_FirePoker:			opponentStats.damageValue = 2310;	opponentStats.armorPiercing = 0.30f;	break;
							default :						opponentStats.damageValue = 2475;	opponentStats.armorPiercing = 0.20f;	break;
						}
						
						switch(opponentStats.rangedWeapon)
						{
							/*case ERWT_ShortBow:		opponentStats.rangedDamageValue = 2870;	opponentStats.rangedArmorPiercing = 0.25f;	break;
							case ERWT_LongBow:		opponentStats.rangedDamageValue = 3860;	opponentStats.rangedArmorPiercing = 0.35f;	break;
							case ERWT_Crossbow:		opponentStats.rangedDamageValue = 3685;	opponentStats.rangedArmorPiercing = 0.80f;	break;*/
							case ERWT_ShortBow:		opponentStats.rangedDamageValue = 3000;	opponentStats.rangedArmorPiercing = 0.15f;	break;
							case ERWT_LongBow:		opponentStats.rangedDamageValue = 3600;	opponentStats.rangedArmorPiercing = 0.2f;	break;
							case ERWT_Crossbow:		opponentStats.rangedDamageValue = 2200;	opponentStats.rangedArmorPiercing = 0.8f;	break;
							default :				opponentStats.rangedDamageValue = 0;	opponentStats.rangedArmorPiercing = 0.f;	break;
						}
						
						switch(armorType)
						{
							case 'Heavy':
								opponentStats.healthValue = 5220;
								
								opponentStats.isArmored			= true;
								opponentStats.dangerLevel		= 50;
								opponentStats.canGetCrippled 	= false;
								opponentStats.poiseValue 		= 0.45f;
								opponentStats.physicalResist	= 0.90f;
								opponentStats.forceResist 		= 0.35f;
								opponentStats.frostResist 		= 0.f;
								opponentStats.fireResist 		= 0.65f;
								opponentStats.shockResist 		= 0.3f;
								opponentStats.elementalResist 	= 0.f;
								opponentStats.slowResist 		= 0.15f;
								opponentStats.confusionResist 	= 0.f;
								opponentStats.bleedingResist 	= 0.8f;
								opponentStats.poisonResist 		= 0.65f;
								opponentStats.stunResist 		= 0.3f;
								opponentStats.injuryResist 		= 0.25f;
							break;
							
							case 'Mixed':
								opponentStats.healthValue = 5220;
								
								opponentStats.isArmored			= true;
								opponentStats.dangerLevel		= 50;
								opponentStats.canGetCrippled 	= true;
								opponentStats.poiseValue 		= 0.3f;
								opponentStats.physicalResist	= 0.75f;
								opponentStats.forceResist 		= 0.25f;
								opponentStats.frostResist 		= 0.f;
								opponentStats.fireResist 		= 0.35f;
								opponentStats.shockResist 		= 0.2f;
								opponentStats.elementalResist 	= 0.f;
								opponentStats.slowResist 		= 0.1f;
								opponentStats.confusionResist 	= 0.f;
								opponentStats.bleedingResist 	= 0.7f;
								opponentStats.poisonResist 		= 0.55f;
								opponentStats.stunResist 		= 0.1f;
								opponentStats.injuryResist 		= 0.1f;
							break;
							
							case 'Medium':
								opponentStats.healthValue = 4770;
								
								opponentStats.isArmored			= true;
								opponentStats.dangerLevel		= 50;
								opponentStats.canGetCrippled 	= true;
								opponentStats.poiseValue 		= 0.2f;
								opponentStats.physicalResist	= 0.45f;
								opponentStats.forceResist 		= 0.1f;
								opponentStats.frostResist 		= 0.f;
								opponentStats.fireResist 		= 0.2f;
								opponentStats.shockResist 		= 0.15f;
								opponentStats.elementalResist 	= 0.f;
								opponentStats.slowResist 		= 0.05f;
								opponentStats.confusionResist 	= 0.f;
								opponentStats.bleedingResist 	= 0.45f;
								opponentStats.poisonResist 		= 0.3f;
								opponentStats.stunResist 		= 0.1f;
								opponentStats.injuryResist 		= 0.1f;
							break;
							
							case 'Light':
								opponentStats.healthValue = 4770;
								
								opponentStats.isArmored			= true;
								opponentStats.dangerLevel		= 10;
								opponentStats.canGetCrippled 	= true;
								opponentStats.poiseValue 		= 0.15f;
								opponentStats.physicalResist	= 0.25f;
								opponentStats.forceResist 		= 0.f;
								opponentStats.frostResist 		= 0.f;
								opponentStats.fireResist 		= 0.05f;
								opponentStats.shockResist 		= 0.f;
								opponentStats.elementalResist 	= 0.f;
								opponentStats.slowResist 		= 0.0f;
								opponentStats.confusionResist 	= 0.f;
								opponentStats.bleedingResist 	= 0.2f;
								opponentStats.poisonResist 		= 0.1f;
								opponentStats.stunResist 		= 0.f;
								opponentStats.injuryResist 		= 0.05f;
							break;
							
							default:
								opponentStats.healthValue = 4270;
								
								opponentStats.isArmored			= true;
								opponentStats.dangerLevel		= 10;
								opponentStats.canGetCrippled 	= true;
								opponentStats.poiseValue 		= 0.05f;
								opponentStats.physicalResist	= 0.05f;
								opponentStats.forceResist 		= -0.1f;
								opponentStats.frostResist 		= 0.f;
								opponentStats.fireResist 		= 0.f;
								opponentStats.shockResist 		= 0.f;
								opponentStats.elementalResist 	= 0.f;
								opponentStats.slowResist 		= -0.05f;
								opponentStats.confusionResist 	= 0.f;
								opponentStats.bleedingResist 	= -0.2f;
								opponentStats.poisonResist 		= -0.15f;
								opponentStats.stunResist 		= -0.1f;
								opponentStats.injuryResist 		= -0.15f;
							break;
						}
						opponentStats.healthType = BCS_Vitality;
					}
				break;
				
				default : return;
			}
		}
	}
    
	public function CalculateStatsSpecter( NPC : CNewNPC, out opponentStats : SOpponentStats, out wasNotScaled : bool )
	{
		var armorType : name;
		var npcStats : CCharacterStats;
		npcStats = NPC.GetCharacterStats();
		
		if( !NPC.HasTag('IsBoss') )
		{
			switch(opponentStats.opponentType)
			{
				case MC_Specter :
					if( NPC.HasAbility('mon_ghoul_base') )
					{
						opponentStats.damageValue = 2210;
						opponentStats.healthValue = 7440;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.3f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.5f;
						opponentStats.elementalResist 	= -0.3f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.65f;
						AddSpecterResistances(NPC);
					}
					else
					if( NPC.HasAbility('mon_ghosts_ep1') )
					{
						opponentStats.damageValue = 2275;
						opponentStats.healthValue = 5250;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.3f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.5f;
						opponentStats.elementalResist 	= -0.3f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.7f;
						AddSpecterResistances(NPC);
					}
					else
					if( NPC.HasAbility('mon_barghest_base') )
					{
						opponentStats.damageValue = 2185;
						opponentStats.healthValue = 9730;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.3f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.5f;
						opponentStats.elementalResist 	= -0.3f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.7f;
						AddSpecterResistances(NPC);
					}
					else
					if( NPC.HasAbility('mon_lessog_base') ) //hym
					{
						opponentStats.damageValue = 4840;
						opponentStats.healthValue = 40300;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 1.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.5f;
						opponentStats.elementalResist 	= -0.3f;
						opponentStats.slowResist 		= 0.4f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 1.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.4f;
						AddSpecterResistances(NPC);
					}
					else
					if( NPC.HasAbility('mon_wraith_base') )
					{
						NPC.AddTag('WeakToQuen');
						NPC.AddTimer('AddHealthRegenEffect', 0.3f, false);
						opponentStats.damageValue = 1950;
						opponentStats.healthValue = 4115;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.25f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.5f;
						opponentStats.elementalResist 	= -0.3f;
						opponentStats.slowResist 		= -0.4f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.5f;
						opponentStats.regenDelay 		= 3.f;
						opponentStats.healthRegenFactor = 0.1f;
						AddSpecterResistances(NPC);
					}
					else
					if( NPC.HasAbility('mh207_wraith_boss') )
					{
						NPC.AddTag('WeakToQuen');
						NPC.AddTimer('AddHealthRegenEffect', 0.3f, false);
						opponentStats.damageValue = 2935;
						opponentStats.healthValue = 34410;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.8f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.5f;
						opponentStats.elementalResist 	= -0.3f;
						opponentStats.slowResist 		= 0.3f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.7f;
						opponentStats.regenDelay 		= 2.f;
						opponentStats.healthRegenFactor = 0.003f;
						AddSpecterResistances(NPC);
					}
					else
					if( NPC.HasAbility('mon_nightwraith_banshee') )
					{
						opponentStats.damageValue = 1510;
						opponentStats.healthValue = 32380;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.4f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.5f;
						opponentStats.elementalResist 	= -0.3f;
						opponentStats.slowResist 		= 0.3f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.7f;
						AddSpecterResistances(NPC);
					}
					else
					if( NPC.HasTag('skeleton') )
					{
						opponentStats.damageValue = 2435;
						opponentStats.healthValue = 3200;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.3f;
						opponentStats.physicalResist	= 0.8f;
						opponentStats.forceResist 		= 0.3f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.3f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.4f;
						opponentStats.armorPiercing 	= 0.30f;
						AddSpecterResistances(NPC);
					}
					else
					if( NPC.HasAbility('mon_noonwraith_base') )
					{
						opponentStats.damageValue = 3685;
						opponentStats.healthValue = 32170;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.3f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.5f;
						opponentStats.elementalResist 	= -0.3f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 1.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.7f;
						AddSpecterResistances(NPC);
					}
					else
					if( NPC.HasAbility('mon_noonwraith_doppelganger') )
					{
						opponentStats.damageValue = 3685;
						opponentStats.healthValue = 32170;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.3f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.5f;
						opponentStats.elementalResist 	= -0.3f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 1.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.f;
						AddSpecterResistances(NPC);
					}
					else
					if( NPC.HasAbility('mon_black_spider_base') || NPC.HasAbility('mon_black_spider_ep2_base') )
					{
						NPC.AddTag('WeakToAxii');
						if( NPC.HasAbility('mon_black_spider_large') || NPC.HasAbility('mon_black_spider_ep2_large') )
						{
							opponentStats.damageValue = 2125;
							opponentStats.healthValue = 17780;
							opponentStats.healthType = BCS_Essence;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 50;
							opponentStats.canGetCrippled 	= false;
							opponentStats.poiseValue 		= 0.4f;
							opponentStats.physicalResist	= 0.f;
							opponentStats.forceResist 		= 0.f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= -0.5f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= -0.3f;
							opponentStats.confusionResist 	= -1.f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 0.4f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.45f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
						else
						{
							opponentStats.damageValue = 1335;
							opponentStats.healthValue = 6360;
							opponentStats.healthType = BCS_Essence;
							
							opponentStats.dangerLevel		= 10;
							opponentStats.canGetCrippled 	= false;
							opponentStats.poiseValue 		= 0.1f;
							opponentStats.physicalResist	= 0.f;
							opponentStats.forceResist 		= 0.f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= -0.5f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= -0.3f;
							opponentStats.confusionResist 	= -1.f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 0.4f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.35f;
						}
					}
					else
					if( NPC.HasAbility('mon_panther_ghost') )
					{
						opponentStats.damageValue = 2410;
						opponentStats.healthValue = 11730;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.3f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.6f;
						AddSpecterResistances(NPC);
					}
					else
					{
						wasNotScaled = true;
						opponentStats.damageValue = 1;
						opponentStats.healthValue = 1;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.poiseValue 		= 0.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.f;
					}
				break;
				
				default : return;
			}
		}
	}
	
	public function CalculateStatsPart2( NPC : CNewNPC, out opponentStats : SOpponentStats, out wasNotScaled : bool )
	{
		var armorType : name;
		var npcStats : CCharacterStats;
		npcStats = NPC.GetCharacterStats();
		
		if( !NPC.HasTag('IsBoss') )
		{
			switch(opponentStats.opponentType)
			{
				case MC_Vampire :
					if( NPC.HasAbility('mon_vampiress_base') )
					{
						opponentStats.damageValue = 1615;
						opponentStats.healthValue = 20250;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.45f;
						opponentStats.physicalResist	= 0.55f;
						opponentStats.forceResist 		= 0.3f;
						opponentStats.frostResist 		= 0.65f;
						opponentStats.fireResist 		= 0.5f;
						opponentStats.shockResist 		= 0.35f;
						opponentStats.elementalResist 	= 0.35f;
						opponentStats.slowResist 		= 0.05f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 0.4f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.1f;
						opponentStats.injuryResist 		= 0.1f;
						opponentStats.armorPiercing 	= 0.7f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_MENTAL);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
					}
					else
					if( NPC.HasAbility('mon_werewolf_base') )
					{
						if (NPC.HasAbility('mon_fleder') )
						{
							NPC.AddTag('WeakToAxii');
							opponentStats.damageValue = 2605;
							opponentStats.healthValue = 20470;
							opponentStats.healthType = BCS_Essence;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.5f;
							opponentStats.physicalResist	= 0.7f;
							opponentStats.forceResist 		= 0.2f;
							opponentStats.frostResist 		= 0.2f;
							opponentStats.fireResist 		= 0.4f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.5f;
							opponentStats.confusionResist 	= -0.7f;
							opponentStats.bleedingResist 	= 0.4f;
							opponentStats.poisonResist 		= 0.6f;
							opponentStats.stunResist 		= 0.1f;
							opponentStats.injuryResist 		= 0.7f;
							opponentStats.armorPiercing 	= 0.35f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
						else
						if (NPC.HasAbility('mon_garkain') )
						{
							opponentStats.damageValue = 4185;
							opponentStats.healthValue = 18470;
							opponentStats.healthType = BCS_Essence;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.15f;
							opponentStats.physicalResist	= 0.35f;
							opponentStats.forceResist 		= 0.2f;
							opponentStats.frostResist 		= 0.2f;
							opponentStats.fireResist 		= 0.4f;
							opponentStats.shockResist 		= 0.5f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= -0.05f;
							opponentStats.confusionResist 	= 1.0f;
							opponentStats.bleedingResist 	= 0.4f;
							opponentStats.poisonResist 		= 0.6f;
							opponentStats.stunResist 		= 0.1f;
							opponentStats.injuryResist 		= 0.1f;
							opponentStats.armorPiercing 	= 0.20f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_MENTAL);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
						else
						if( NPC.HasAbility('mon_katakan') || NPC.HasAbility('mon_ekimma'))
						{
							NPC.AddTimer('AddHealthRegenEffect', 0.3f, false);
							opponentStats.damageValue = 3105;
							opponentStats.healthValue = 20470;
							opponentStats.healthType = BCS_Essence;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.45f;
							opponentStats.physicalResist	= 0.6f;
							opponentStats.forceResist 		= 0.2f;
							opponentStats.frostResist 		= 0.2f;
							opponentStats.fireResist 		= 0.2f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.4f;
							opponentStats.poisonResist 		= 0.6f;
							opponentStats.stunResist 		= 0.1f;
							opponentStats.injuryResist 		= 0.1f;
							opponentStats.armorPiercing 	= 0.6f;
							opponentStats.regenDelay		= 4.f;
							opponentStats.healthRegenFactor = 0.008f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
						else
						if( NPC.HasAbility('mon_katakan_large') )
						{
							NPC.AddTimer('AddHealthRegenEffect', 0.3f, false);
							opponentStats.damageValue = 3330;
							opponentStats.healthValue = 23470;
							opponentStats.healthType = BCS_Essence;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.45f;
							opponentStats.physicalResist	= 0.6f;
							opponentStats.forceResist 		= 0.2f;
							opponentStats.frostResist 		= 0.2f;
							opponentStats.fireResist 		= 0.2f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= 0.1f;
							opponentStats.bleedingResist 	= 0.4f;
							opponentStats.poisonResist 		= 0.6f;
							opponentStats.stunResist 		= 0.1f;
							opponentStats.injuryResist 		= 0.1f;
							opponentStats.armorPiercing 	= 0.65f;
							opponentStats.regenDelay		= 4.f;
							opponentStats.healthRegenFactor = 0.008f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
						else
						{
							opponentStats.damageValue = 3105;
							opponentStats.healthValue = 29470;
							opponentStats.healthType = BCS_Essence;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.45f;
							opponentStats.physicalResist	= 0.6f;
							opponentStats.forceResist 		= 0.2f;
							opponentStats.frostResist 		= 0.2f;
							opponentStats.fireResist 		= 0.2f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= -0.2f;
							opponentStats.confusionResist 	= 0.25f;
							opponentStats.bleedingResist 	= 0.4f;
							opponentStats.poisonResist 		= 0.6f;
							opponentStats.stunResist 		= 0.1f;
							opponentStats.injuryResist 		= 0.1f;
							opponentStats.armorPiercing 	= 0.65f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
					}
					else
					{
						wasNotScaled = true;
						opponentStats.damageValue = 1;
						opponentStats.healthValue = 1;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.poiseValue 		= 0.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.f;
					}
				break;
				
				case MC_Magicals :
					if( NPC.HasAbility('mon_fugas_base') )
					{
						NPC.AddTag('WeakToQuen');
						opponentStats.damageValue = 2835;
						opponentStats.healthValue = 20870;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.6f;
						opponentStats.physicalResist	= 0.90f;
						opponentStats.forceResist 		= 0.8f;
						opponentStats.frostResist 		= 0.85f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= -0.3f;
						opponentStats.elementalResist 	= -0.3f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.8f;
						opponentStats.injuryResist 		= 0.2f;
						opponentStats.armorPiercing 	= 0.7f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FIRE);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_BLEEDING);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
					}
					else
					if( NPC.HasAbility('mon_golem_base') )
					{
						if (NPC.HasAbility('mon_ice_golem'))
						{
							opponentStats.damageValue = 4025;
							opponentStats.healthValue = 30540;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= false;
							opponentStats.poiseValue 		= 0.7f;
							opponentStats.physicalResist	= 1.0f;
							opponentStats.forceResist 		= 0.8f;
							opponentStats.frostResist 		= 0.85f;
							opponentStats.fireResist 		= -0.3f;
							opponentStats.shockResist 		= -0.3f;
							opponentStats.elementalResist 	= -0.3f;
							opponentStats.slowResist 		= 0.5f;
							opponentStats.confusionResist 	= 1.f;
							opponentStats.bleedingResist 	= 1.f;
							opponentStats.poisonResist 		= 1.f;
							opponentStats.stunResist 		= 1.f;
							opponentStats.injuryResist 		= 1.0f;
							opponentStats.armorPiercing 	= 0.85f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FIRE);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_BLEEDING);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_STUN);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_MENTAL);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
						else
						{
							opponentStats.damageValue = 4025;
							opponentStats.healthValue = 30540;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= false;
							opponentStats.poiseValue 		= 0.7f;
							opponentStats.physicalResist	= 1.0f;
							opponentStats.forceResist 		= 0.8f;
							opponentStats.frostResist 		= 0.85f;
							opponentStats.fireResist 		= 1.f;
							opponentStats.shockResist 		= -0.3f;
							opponentStats.elementalResist 	= -0.3f;
							opponentStats.slowResist 		= 0.5f;
							opponentStats.confusionResist 	= 1.f;
							opponentStats.bleedingResist 	= 1.f;
							opponentStats.poisonResist 		= 1.f;
							opponentStats.stunResist 		= 1.f;
							opponentStats.injuryResist 		= 1.0f;
							opponentStats.armorPiercing 	= 0.85f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FIRE);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_BLEEDING);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_STUN);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_MENTAL);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
					}
					else
					if( NPC.HasAbility('mon_wild_hunt_default') )
					{
						NPC.AddTag('NoImmobilize');
						opponentStats.healthValue = 8530;
						opponentStats.healthType = BCS_Vitality;
						
						GetWeaponTypes(NPC, opponentStats);
						switch(opponentStats.meleeWeapon)
						{
							case EMWT_Sword2H:				opponentStats.damageValue = 3385;	opponentStats.armorPiercing = 0.45f;	break;
							case EMWT_GreatAxe:				opponentStats.damageValue = 4105;	opponentStats.armorPiercing = 0.60f;	break;
							case EMWT_GreatHammerMetal:		opponentStats.damageValue = 4105;	opponentStats.armorPiercing = 0.60f;	break;
							case EMWT_Halberd:				opponentStats.damageValue = 4235;	opponentStats.armorPiercing = 0.60f;	break;
							case EMWT_Spear:				opponentStats.damageValue = 3385;	opponentStats.armorPiercing = 0.55f;	break;
							default: 						opponentStats.damageValue = 3385;	opponentStats.armorPiercing = 0.45f;	break;
						}
						
						opponentStats.isArmored			= true;
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.5f;
						opponentStats.physicalResist	= 0.9f;
						opponentStats.forceResist 		= 0.2f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.1f;
						opponentStats.confusionResist 	= 0.2f;
						opponentStats.bleedingResist 	= 0.8f;
						opponentStats.poisonResist 		= 0.5f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FROST);
					}
					else
					if( NPC.HasAbility('mon_ghoul_base') )
					{
						NPC.AddTag('WeakToAxii');
						opponentStats.damageValue = 2100;
						opponentStats.healthValue = 5200;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.35f;
						opponentStats.physicalResist	= 0.4f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= -0.45f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= -1.0f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.4f;
						opponentStats.armorPiercing 	= 0.45f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FROST);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FIRE);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_BLEEDING);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
					}
					else
					if( NPC.HasAbility('mon_nekker_base') )
					{
						opponentStats.damageValue = 1775;
						opponentStats.healthValue = 4170;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.1f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.3f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 0.2f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.1f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 0.5f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.45f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FROST);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_BLEEDING);
						//NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_MENTAL);
					}
					else
					{
						wasNotScaled = true;
						opponentStats.damageValue = 1;
						opponentStats.healthValue = 1;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.poiseValue 		= 0.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.f;
					}
				break;
				
				case MC_Cursed :
					if( NPC.HasAbility('mon_archespor_base') )
					{
						opponentStats.damageValue = 1670;
						opponentStats.healthValue = 13000;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.45f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 0.3f;
						opponentStats.fireResist 		= -0.8f;
						opponentStats.shockResist 		= 0.5f;
						opponentStats.elementalResist 	= 0.5f;
						opponentStats.slowResist 		= 1.f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 1.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.30f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_SLOW);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_MENTAL);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_BLEEDING);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
					}
					else
					if( NPC.HasAbility('mon_bear_base') )
					{
						NPC.AddTag('WeakToQuen');
						opponentStats.damageValue = 2885;
						opponentStats.healthValue = 28380;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.5f;
						opponentStats.physicalResist	= 0.5f;
						opponentStats.forceResist 		= 0.2f;
						opponentStats.frostResist 		= 0.15f;
						opponentStats.fireResist 		= -0.3f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.3f;
						opponentStats.confusionResist 	= 0.2f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.2f;
						opponentStats.stunResist 		= 0.3f;
						opponentStats.injuryResist 		= 0.15f;
						opponentStats.armorPiercing 	= 0.55f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
					}
					else
					if( NPC.HasAbility('mon_werewolf_base') )
					{
						opponentStats.damageValue = 2975;
						opponentStats.healthValue = 26380;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.45f;
						opponentStats.physicalResist	= 0.5f;
						opponentStats.forceResist 		= 0.2f;
						opponentStats.frostResist 		= 0.2f;
						opponentStats.fireResist 		= -0.35f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.3f;
						opponentStats.confusionResist 	= 0.2f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.3f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.6f;
					}
					else
					{
						wasNotScaled = true;
						opponentStats.damageValue = 1;
						opponentStats.healthValue = 1;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.poiseValue 		= 0.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.f;
					}
				break;
				
				case MC_Insectoid :
					if( NPC.HasAbility('mon_arachas_base') )
					{
						if( NPC.HasAbility('mon_arachas_armored') )
						{
							opponentStats.damageValue = 2135;
							opponentStats.healthValue = 12670;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.5f;
							opponentStats.physicalResist	= 0.90f;
							opponentStats.forceResist 		= 0.15f;
							opponentStats.frostResist 		= 0.25f;
							opponentStats.fireResist 		= 0.25f;
							opponentStats.shockResist 		= 0.25f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.2f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.4f;
							opponentStats.poisonResist 		= 1.f;
							opponentStats.stunResist 		= 0.2f;
							opponentStats.injuryResist 		= 0.4f;
							opponentStats.armorPiercing 	= 0.60f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
						if( NPC.HasAbility('mon_poison_arachas') )
						{
							opponentStats.damageValue = 2135;
							opponentStats.healthValue = 16670;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.5f;
							opponentStats.physicalResist	= 0.4f;
							opponentStats.forceResist 		= 0.15f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= -0.4f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.2f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 1.f;
							opponentStats.stunResist 		= 0.2f;
							opponentStats.injuryResist 		= 0.2f;
							opponentStats.armorPiercing 	= 0.60f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
						else
						{
							opponentStats.damageValue = 2135;
							opponentStats.healthValue = 12670;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.5f;
							opponentStats.physicalResist	= 0.7f;
							opponentStats.forceResist 		= 0.15f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= 0.f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.2f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 1.f;
							opponentStats.stunResist 		= 0.2f;
							opponentStats.injuryResist 		= 0.2f;
							opponentStats.armorPiercing 	= 0.60f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
					}
					else
					if( NPC.HasAbility('mon_black_spider_base') || NPC.HasAbility('mon_black_spider_ep2_base') )
					{
						NPC.AddTag('WeakToAxii');
						if( NPC.HasAbility('mon_black_spider_large') || NPC.HasAbility('mon_black_spider_ep2_large') )
						{
							opponentStats.damageValue = 2125;
							opponentStats.healthValue = 17780;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.4f;
							opponentStats.physicalResist	= 0.f;
							opponentStats.forceResist 		= 0.f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= -0.5f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= -0.3f;
							opponentStats.confusionResist 	= -1.f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 0.4f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.45f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
						else
						{
							opponentStats.damageValue = 1335;
							opponentStats.healthValue = 6360;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 10;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.1f;
							opponentStats.physicalResist	= 0.f;
							opponentStats.forceResist 		= 0.f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= -0.5f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= -0.3f;
							opponentStats.confusionResist 	= -1.f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 0.4f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.25f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
					}
					else
					if( NPC.HasAbility('mon_endriaga_base') )
					{
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
						if( NPC.HasAbility('mon_endriaga_worker') )
						{
							opponentStats.damageValue = 885;
							opponentStats.healthValue = 4670;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 50;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.15f;
							opponentStats.physicalResist	= 0.25f;
							opponentStats.forceResist 		= 0.1f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= 0.2f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 1.f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.8f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
						else
						if( NPC.HasAbility('mon_endriaga_soldier_tailed') )
						{
							opponentStats.damageValue = 2065;
							opponentStats.healthValue = 6810;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 50;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.25f;
							opponentStats.physicalResist	= 0.45f;
							opponentStats.forceResist 		= 0.2f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= 0.3f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.1f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 1.f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.45f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
						else
						if( NPC.HasAbility('mon_endriaga_soldier_spikey') )
						{
							opponentStats.damageValue = 1685;
							opponentStats.healthValue = 5220;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 50;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.4f;
							opponentStats.physicalResist	= 0.65f;
							opponentStats.forceResist 		= 0.2f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= 0.3f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 0.f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.60f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
					}
					else
					if( NPC.HasAbility('mon_scolopendromorph_base') )
					{
						opponentStats.damageValue = 2935;
						opponentStats.healthValue = 10330;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 1.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.6f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.4f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.7f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
					}
					else
					if( NPC.HasAbility('mon_kikimore_base') )
					{
						NPC.AddTag('WeakToAard');
						if( NPC.HasAbility('mon_kikimore_small') )
						{
							opponentStats.damageValue = 910;
							opponentStats.healthValue = 6630;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 50;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.2f;
							opponentStats.physicalResist	= 0.4f;
							opponentStats.forceResist 		= 0.2f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= 0.3f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.35f;
							opponentStats.poisonResist 		= 1.f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.2f;
							opponentStats.armorPiercing 	= 0.8f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
						else
						{
							opponentStats.damageValue = 2025;
							opponentStats.healthValue = 14250;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.f;
							opponentStats.physicalResist	= 0.75f;
							opponentStats.forceResist 		= 0.3f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= 0.4f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.1f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.5f;
							opponentStats.poisonResist 		= 1.f;
							opponentStats.stunResist 		= 0.2f;
							opponentStats.injuryResist 		= 0.2f;
							opponentStats.armorPiercing 	= 0.6f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
					}
					else
					{
						wasNotScaled = true;
						opponentStats.damageValue = 1;
						opponentStats.healthValue = 1;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.poiseValue 		= 0.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.f;
					}
				break;
				
				default : return;
			}
		}
	}
    
	public function CalculateStatsPart3( NPC : CNewNPC, out opponentStats : SOpponentStats, out wasNotScaled : bool )
	{
		var npcStats : CCharacterStats;
		npcStats = NPC.GetCharacterStats();
		
		if( !NPC.HasTag('IsBoss') )
		{
			switch(opponentStats.opponentType)
			{
				case MC_Troll :
					if( NPC.HasAbility('mon_troll_base') )
					{
						NPC.AddTag('WeakToQuen');
						NPC.AddTag('WeakToAxii');
						opponentStats.damageValue = 2985;
						opponentStats.healthValue = 17460;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.75f;
						opponentStats.physicalResist	= 0.65f;
						opponentStats.forceResist 		= 0.2f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.3f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= -0.6f;
						opponentStats.bleedingResist 	= 0.4f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 1.f;
						opponentStats.injuryResist 		= 0.2f;
						opponentStats.armorPiercing 	= 0.6f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_STUN);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
					}
					else
					if( NPC.HasAbility('mon_cyclops') )
					{
						NPC.AddTag('WeakToQuen');
						NPC.AddTag('WeakToAxii');
						opponentStats.damageValue = 3305;
						opponentStats.healthValue = 31710;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.7f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.3f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.3f;
						opponentStats.confusionResist 	= -0.6f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 1.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.65f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_STUN);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
					}
					else
					if( NPC.HasAbility('mon_ice_giant') )
					{
						NPC.AddTag('WeakToQuen');
						opponentStats.damageValue = 3560;
						opponentStats.healthValue = 45550;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.7f;
						opponentStats.physicalResist	= 0.35f;
						opponentStats.forceResist 		= 0.3f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.3f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 1.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.65f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_STUN);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
					}
					else
					if( NPC.HasAbility('mon_nekker_base') )
					{
						if( NPC.HasAbility('mon_nekker_warrior') )
						{
							opponentStats.damageValue = 2055;
							opponentStats.healthValue = 5690;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 50;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.1f;
							opponentStats.physicalResist	= 0.f;
							opponentStats.forceResist 		= -0.1f;
							opponentStats.frostResist 		= -0.1f;
							opponentStats.fireResist 		= 0.f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= -0.1f;
							opponentStats.poisonResist 		= 0.3f;
							opponentStats.stunResist 		= -0.1f;
							opponentStats.injuryResist 		= -0.1f;
							opponentStats.armorPiercing 	= 0.45f;
						}
						else
						{
							opponentStats.damageValue = 1655;
							opponentStats.healthValue = 3670;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 10;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.05f;
							opponentStats.physicalResist	= 0.f;
							opponentStats.forceResist 		= -0.15f;
							opponentStats.frostResist 		= -0.15f;
							opponentStats.fireResist 		= 0.f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= -0.1f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= -0.15f;
							opponentStats.poisonResist 		= 0.f;
							opponentStats.stunResist 		= -0.15f;
							opponentStats.injuryResist 		= -0.1f;
							opponentStats.armorPiercing 	= 0.4f;
						}
					}
					else
					{
						wasNotScaled = true;
						opponentStats.damageValue = 1;
						opponentStats.healthValue = 1;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.poiseValue 		= 0.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.f;
					}
				break;
				
				case MC_Necrophage :
					if( NPC.HasAbility('mon_ghoul_base') )
					{
						if( NPC.HasAbility('mon_alghoul') )
						{
							NPC.AddTag('WeakToAxii');
							opponentStats.damageValue = 2665;
							opponentStats.healthValue = 6880;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 50;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.3f;
							opponentStats.physicalResist	= 0.3f;
							opponentStats.forceResist 		= 0.f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= 0.f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= -0.5f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 0.3f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.6f;
						}
						else
						{
							NPC.AddTag('WeakToAxii');
							opponentStats.damageValue = 2230;
							opponentStats.healthValue = 5980;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 10;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.2f;
							opponentStats.physicalResist	= 0.15f;
							opponentStats.forceResist 		= 0.f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= 0.f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= -1.0f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 0.3f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.5f;
						}
					}
					else
					if( NPC.HasAbility('mon_drowner_base') )
					{
						if ( NPC.HasAbility('mon_drowner') )
						{
							opponentStats.damageValue = 2230;
							opponentStats.healthValue = 5630;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 50;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.15f;
							opponentStats.physicalResist	= 0.f;
							opponentStats.forceResist 		= 0.f;
							opponentStats.frostResist 		= -0.4f;
							opponentStats.fireResist 		= 0.3f;
							opponentStats.shockResist 		= -0.3f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= -0.25f;
							opponentStats.bleedingResist 	= -0.4f;
							opponentStats.poisonResist 		= 1.0f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= -0.3f;
							opponentStats.armorPiercing 	= 0.25f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
						}
						else
						if ( NPC.HasAbility('mon_gravier') )
						{
							opponentStats.damageValue = 2320;
							opponentStats.healthValue = 6130;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 50;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.4f;
							opponentStats.physicalResist	= 0.4f;
							opponentStats.forceResist 		= 0.f;
							opponentStats.frostResist 		= 0.4f;
							opponentStats.fireResist 		= 0.0f;
							opponentStats.shockResist 		= 0.1f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.3f;
							opponentStats.poisonResist 		= 0.8f;
							opponentStats.stunResist 		= 0.0f;
							opponentStats.injuryResist 		= 0.2f;
							opponentStats.armorPiercing 	= 0.5f;
						}
						else
						{
							opponentStats.damageValue = 2320;
							opponentStats.healthValue = 6130;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 50;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.4f;
							opponentStats.physicalResist	= 0.0f;
							opponentStats.forceResist 		= 0.f;
							opponentStats.frostResist 		= 0.4f;
							opponentStats.fireResist 		= -0.4f;
							opponentStats.shockResist 		= 0.1f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.4f;
							opponentStats.poisonResist 		= 0.4f;
							opponentStats.stunResist 		= 0.0f;
							opponentStats.injuryResist 		= 0.2f;
							opponentStats.armorPiercing 	= 0.30f;
						}
					}
					else
					if( NPC.HasAbility('mon_fogling_doppelganger') )
					{
						NPC.AddTag('WeakToQuen');
						opponentStats.damageValue = 835;
						opponentStats.healthValue = 10;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.25f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.1f;
						opponentStats.confusionResist 	= 0.1f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.35f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.6f;
					}
					else
					if( NPC.HasAbility('mon_gravehag_base') )
					{
						NPC.AddTag('WeakToQuen');
						if( NPC.HasAbility('mon_wight') )
						{
							opponentStats.damageValue = 2495;
							opponentStats.healthValue = 12880;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.25f;
							opponentStats.physicalResist	= 0.2f;
							opponentStats.forceResist 		= 0.2f;
							opponentStats.frostResist 		= 0.2f;
							opponentStats.fireResist 		= 0.4f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.15f;
							opponentStats.confusionResist 	= 0.15f;
							opponentStats.bleedingResist 	= 0.1f;
							opponentStats.poisonResist 		= 1.f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.40f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
						}
						else
						{
							opponentStats.damageValue = 2495;
							opponentStats.healthValue = 10280;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.25f;
							opponentStats.physicalResist	= 0.1f;
							opponentStats.forceResist 		= 0.2f;
							opponentStats.frostResist 		= 0.2f;
							opponentStats.fireResist 		= 0.4f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.15f;
							opponentStats.confusionResist 	= 0.15f;
							opponentStats.bleedingResist 	= 0.1f;
							opponentStats.poisonResist 		= 0.45f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.40f;
							opponentStats.rangedDamageValue = 10;
							opponentStats.rangedArmorPiercing = 0.f;
						}
					}
					else
					{
						wasNotScaled = true;
						opponentStats.damageValue = 1;
						opponentStats.healthValue = 1;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.poiseValue 		= 0.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.f;
					}
				break;
				
				case MC_Hybrid :
					if( NPC.HasAbility('mon_gryphon_base') )
					{
						opponentStats.damageValue = 3875;
						opponentStats.healthValue = 43790;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.7f;
						opponentStats.physicalResist	= 0.55f;
						opponentStats.forceResist 		= -0.1f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= -0.3f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.3f;
						opponentStats.confusionResist 	= 0.3f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= -1.f;
						opponentStats.stunResist 		= 0.35f;
						opponentStats.injuryResist 		= 0.15f;
						opponentStats.armorPiercing 	= 0.8f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
					}
					else
					if( NPC.HasAbility('mon_harpy_base') )
					{
						opponentStats.damageValue = 1205;
						opponentStats.healthValue = 5380;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.1f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= -0.4f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= -0.4f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= -0.2f;
						opponentStats.injuryResist 		= -0.2f;
						opponentStats.armorPiercing 	= 0.55f;
					}
					else
					if( NPC.HasAbility('SkillSorceress') )
					{
						NPC.AddTag('WeakToQuen');
						opponentStats.damageValue = 2370;
						opponentStats.healthValue = 10760;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.2f;
						opponentStats.physicalResist	= 0.1f;
						opponentStats.forceResist 		= -0.1f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.6f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.8f;
					}
					else
					if( NPC.HasAbility('mon_siren_base') )
					{
						opponentStats.damageValue = 1345;
						opponentStats.healthValue = 6960;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.1f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= -0.2f;
						opponentStats.frostResist 		= -0.3f;
						opponentStats.fireResist 		= 0.35f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.55f;
					}
					else
					{
						wasNotScaled = true;
						opponentStats.damageValue = 1;
						opponentStats.healthValue = 1;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.poiseValue 		= 0.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.f;
					}
				break;
				
				default : return;
			}
		}
	}
	
	public function CalculateStatsPart4( NPC : CNewNPC, out opponentStats : SOpponentStats, out wasNotScaled : bool )
	{
		var npcStats : CCharacterStats;
		npcStats = NPC.GetCharacterStats();
		
		if( !NPC.HasTag('IsBoss') )
		{
			switch(opponentStats.opponentType)
			{
				case MC_Relic :
					if( NPC.HasAbility('mon_bies_base') )
					{
						if( NPC.HasAbility('mon_czart') )
						{
							NPC.AddTimer('AddHealthRegenEffect', .3f, false);
							opponentStats.damageValue = 3870;
							opponentStats.healthValue = 30560;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.8f;
							opponentStats.physicalResist	= 0.45f;
							opponentStats.forceResist 		= 0.25f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= -0.25f;
							opponentStats.shockResist 		= 0.15f;
							opponentStats.elementalResist 	= 0.15f;
							opponentStats.slowResist 		= 0.35f;
							opponentStats.confusionResist 	= 1.f;
							opponentStats.bleedingResist 	= 0.2f;
							opponentStats.poisonResist 		= -0.1f;
							opponentStats.stunResist 		= 0.2f;
							opponentStats.injuryResist 		= 0.15f;
							opponentStats.armorPiercing 	= 0.70f;
							opponentStats.regenDelay		= 3.0f;
							opponentStats.healthRegenFactor	= 0.005f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_MENTAL);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
						else
						{
							NPC.AddTimer('AddHealthRegenEffect', .3f, false);
							opponentStats.damageValue = 4185;
							opponentStats.healthValue = 36560;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.8f;
							opponentStats.physicalResist	= 0.45f;
							opponentStats.forceResist 		= 0.25f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= -0.25f;
							opponentStats.shockResist 		= 0.15f;
							opponentStats.elementalResist 	= 0.15f;
							opponentStats.slowResist 		= 0.3f;
							opponentStats.confusionResist 	= 1.f;
							opponentStats.bleedingResist 	= 0.2f;
							opponentStats.poisonResist 		= -0.1f;
							opponentStats.stunResist 		= 0.2f;
							opponentStats.injuryResist 		= 0.15f;
							opponentStats.armorPiercing 	= 0.80f;
							opponentStats.regenDelay		= 3.0f;
							opponentStats.healthRegenFactor	= 0.007f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_MENTAL);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
					}
					else
					if( NPC.HasAbility('mon_lessog_base') )
					{
						opponentStats.damageValue = 3235;
						opponentStats.healthValue = 29760;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.65f;
						opponentStats.physicalResist	= 0.5f;
						opponentStats.forceResist 		= 0.8f;
						opponentStats.frostResist 		= 1.0f;
						opponentStats.fireResist 		= -0.5f;
						opponentStats.shockResist 		= 1.f;
						opponentStats.elementalResist 	= 1.f;
						opponentStats.slowResist 		= 0.6f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.5f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.75f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_ELEMENTAL);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_MENTAL);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_BLEEDING);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FROST);
					}
					else
					if( NPC.HasAbility('mon_sharley_base') )
					{
						opponentStats.damageValue = 2860;
						opponentStats.healthValue = 32110;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 1.0f;
						opponentStats.physicalResist	= 0.45f;
						opponentStats.forceResist 		= 0.4f;
						opponentStats.frostResist 		= 0.4f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.3f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.3f;
						opponentStats.confusionResist 	= -0.2f;
						opponentStats.bleedingResist 	= 0.4f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.4f;
						opponentStats.injuryResist 		= 0.3f;
						opponentStats.armorPiercing 	= 0.75f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
					}
					else
					if( NPC.HasAbility('mon_fugas_base') )
					{
						opponentStats.damageValue = 2760;
						opponentStats.healthValue = 25580;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.65f;
						opponentStats.physicalResist	= 0.10f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= -0.5f;
						opponentStats.fireResist 		= 0.7f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= 0.5f;
						opponentStats.bleedingResist 	= -0.15f;
						opponentStats.poisonResist 		= -0.15f;
						opponentStats.stunResist 		= 0.2f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.4f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
					}
					else
					{
						wasNotScaled = true;
						opponentStats.damageValue = 1;
						opponentStats.healthValue = 1;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.poiseValue 		= 0.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.f;
					}
				break;
				
				case MC_Beast :
					if( NPC.HasAbility('mon_bear_base') )
					{
						NPC.AddTag('WeakToQuen');
						if( NPC.HasTag('q201_stuffed_animal') )
						{
							opponentStats.damageValue = 75;
							opponentStats.healthValue = 5310;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.f;
							opponentStats.physicalResist	= 0.f;
							opponentStats.forceResist 		= 0.f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= 0.f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 0.f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
						else
						{
							opponentStats.damageValue = 2985;
							opponentStats.healthValue = 24420;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 10;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.4f;
							opponentStats.physicalResist	= 0.4f;
							opponentStats.forceResist 		= 0.25f;
							opponentStats.frostResist 		= 0.3f;
							opponentStats.fireResist 		= -0.2f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.25f;
							opponentStats.confusionResist 	= -0.2f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 0.f;
							opponentStats.stunResist 		= 0.2f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.55f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
					}
					else
					if( NPC.HasAbility('mon_werewolf_base') )
					{
						opponentStats.damageValue = 2975;
						opponentStats.healthValue = 26380;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.45f;
						opponentStats.physicalResist	= 0.5f;
						opponentStats.forceResist 		= 0.2f;
						opponentStats.frostResist 		= 0.2f;
						opponentStats.fireResist 		= -0.35f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.3f;
						opponentStats.confusionResist 	= 0.2f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.3f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.6f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
					}
					else
					if( NPC.HasAbility('mon_wolf_base') )
					{
						if( NPC.HasTag('q201_stuffed_animal') )
						{
							opponentStats.damageValue = 25;
							opponentStats.healthValue = 870;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 10;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.f;
							opponentStats.physicalResist	= 0.f;
							opponentStats.forceResist 		= 0.f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= 0.f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 0.f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.05f;
						}
						else
						if( NPC.GetSfxTag() == 'sfx_wild_dog' )
						{
							NPC.AddTag('WeakToAxii');
							opponentStats.damageValue = 1950;
							opponentStats.healthValue = 2850;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 10;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.1f;
							opponentStats.physicalResist	= 0.f;
							opponentStats.forceResist 		= -0.1f;
							opponentStats.frostResist 		= 0.2f;
							opponentStats.fireResist 		= -0.25f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= -0.6f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 0.f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.25f;
						}
						else
						if( NPC.UsesVitality() )
						{
							opponentStats.damageValue = 2035;
							opponentStats.healthValue = 3050;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 10;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.1f;
							opponentStats.physicalResist	= 0.f;
							opponentStats.forceResist 		= -0.1f;
							opponentStats.frostResist 		= 0.2f;
							opponentStats.fireResist 		= -0.25f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= -0.3f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 0.f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.3f;
						}
						else
						{
							opponentStats.damageValue = 2035;
							opponentStats.healthValue = 5150;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.dangerLevel		= 10;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.1f;
							opponentStats.physicalResist	= 0.f;
							opponentStats.forceResist 		= -0.1f;
							opponentStats.frostResist 		= 0.2f;
							opponentStats.fireResist 		= -0.25f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 0.f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.3f;
						}
					}
					else
					if( NPC.HasAbility('mon_panther_ghost') )
					{
						opponentStats.damageValue = 2410;
						opponentStats.healthValue = 11730;
						opponentStats.healthType = BCS_Essence;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= false;
						opponentStats.poiseValue 		= 0.3f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 1.f;
						opponentStats.frostResist 		= 1.f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= 1.f;
						opponentStats.bleedingResist 	= 1.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 1.f;
						opponentStats.armorPiercing 	= 0.6f;
						AddSpecterResistances(NPC);
					}
					else
					if( NPC.HasAbility('mon_panther_base') )
					{
						opponentStats.damageValue = 2350;
						opponentStats.healthValue = 7530;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.15f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= -0.2f;
						opponentStats.fireResist 		= -0.3f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= -0.1f;
						opponentStats.confusionResist 	= -0.3f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.4f;
					}
					else
					if( NPC.HasAbility('mon_boar_base') || NPC.HasAbility('mon_boar_ep2_base') || NPC.HasAbility('mon_ft_boar_ep2_base') )
					{
						NPC.AddTag('WeakToAxii');
						opponentStats.damageValue = 2350;
						opponentStats.healthValue = 5350;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 50;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.3f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.25f;
						opponentStats.fireResist 		= -0.35f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= -0.4f;
						opponentStats.confusionResist 	= -0.5f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.5f;
					}
					else
					{
						wasNotScaled = true;
						opponentStats.damageValue = 1;
						opponentStats.healthValue = 1;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.poiseValue 		= 0.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.f;
					}
				break;
				
				case MC_Unused :
					if( NPC.HasAbility('mon_troll_fistfight') )
					{
						NPC.AddTag('WeakToQuen');
						NPC.AddTag('WeakToAxii');
						opponentStats.damageValue = 2700;
						opponentStats.healthValue = 9460;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.5f;
						opponentStats.physicalResist	= 0.65f;
						opponentStats.forceResist 		= 0.2f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.3f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= -0.6f;
						opponentStats.bleedingResist 	= 0.4f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 1.f;
						opponentStats.injuryResist 		= 0.2f;
						opponentStats.armorPiercing 	= 0.5f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_STUN);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
					}
					else
					{
						wasNotScaled = true;
						opponentStats.damageValue = 1;
						opponentStats.healthValue = 1;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.poiseValue 		= 0.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.f;
					}
				break;
				
				case MC_NotSet :
					if( NPC.HasAbility('mon_bear_base') )
					{
						opponentStats.damageValue = 3275;
						opponentStats.healthValue = 14720;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.4f;
						opponentStats.physicalResist	= 0.4f;
						opponentStats.forceResist 		= 0.25f;
						opponentStats.frostResist 		= 0.3f;
						opponentStats.fireResist 		= -0.2f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.25f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.2f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.55f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
					}
					else
					{
						wasNotScaled = true;
						opponentStats.damageValue = 1;
						opponentStats.healthValue = 1;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.poiseValue 		= 0.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.f;
					}
				break;
				
				case MC_Draconide :
					if( NPC.HasAbility('mon_draco_base') )
					{
						opponentStats.damageValue = 3085;
						opponentStats.healthValue = 28770;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.isHuge			= true;
						opponentStats.dangerLevel		= 100;
						opponentStats.canGetCrippled 	= true;
						opponentStats.poiseValue 		= 0.3f;
						opponentStats.physicalResist	= 0.6f;
						opponentStats.forceResist 		= -0.2f;
						opponentStats.frostResist 		= -0.3f;
						opponentStats.fireResist 		= 1.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.2f;
						opponentStats.confusionResist 	= 0.2f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 1.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.15f;
						opponentStats.armorPiercing 	= 0.65f;
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
						NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
					}
					else
					if( NPC.HasAbility('mon_gryphon_base') )
					{
						if( NPC.HasAbility('mon_basilisk'))
						{
							opponentStats.damageValue = 3875;
							opponentStats.healthValue = 40790;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.7f;
							opponentStats.physicalResist	= 0.65f;
							opponentStats.forceResist 		= -0.2f;
							opponentStats.frostResist 		= -0.3f;
							opponentStats.fireResist 		= 0.3f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.3f;
							opponentStats.confusionResist 	= 0.3f;
							opponentStats.bleedingResist 	= 0.3f;
							opponentStats.poisonResist 		= 1.0f;
							opponentStats.stunResist 		= 0.35f;
							opponentStats.injuryResist 		= 0.15f;
							opponentStats.armorPiercing 	= 0.8f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
						else
						{
							opponentStats.damageValue = 3875;
							opponentStats.healthValue = 43790;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.7f;
							opponentStats.physicalResist	= 0.55f;
							opponentStats.forceResist 		= 0.0f;
							opponentStats.frostResist 		= 0.f;
							opponentStats.fireResist 		= -0.3f;
							opponentStats.shockResist 		= 0.f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.3f;
							opponentStats.confusionResist 	= 0.3f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 0.0f;
							opponentStats.stunResist 		= 0.35f;
							opponentStats.injuryResist 		= 0.15f;
							opponentStats.armorPiercing 	= 0.8f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
					}
					else
					if( NPC.HasAbility('mon_wyvern_base') )
					{
						if( NPC.HasAbility('mon_wyvern') )
						{
							opponentStats.damageValue = 3460;
							opponentStats.healthValue = 24540;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.35f;
							opponentStats.physicalResist	= 0.35f;
							opponentStats.forceResist 		= -0.1f;
							opponentStats.frostResist 		= -0.15f;
							opponentStats.fireResist 		= 0.15f;
							opponentStats.shockResist 		= 0.2f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.15f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 0.35f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.4f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
						else
						{
							opponentStats.damageValue = 3660;
							opponentStats.healthValue = 20440;
							opponentStats.healthType = BCS_Vitality;
							
							opponentStats.isHuge			= true;
							opponentStats.dangerLevel		= 100;
							opponentStats.canGetCrippled 	= true;
							opponentStats.poiseValue 		= 0.4f;
							opponentStats.physicalResist	= 0.5f;
							opponentStats.forceResist 		= 0.f;
							opponentStats.frostResist 		= -0.1f;
							opponentStats.fireResist 		= 0.2f;
							opponentStats.shockResist 		= 0.2f;
							opponentStats.elementalResist 	= 0.f;
							opponentStats.slowResist 		= 0.15f;
							opponentStats.confusionResist 	= 0.f;
							opponentStats.bleedingResist 	= 0.f;
							opponentStats.poisonResist 		= 1.f;
							opponentStats.stunResist 		= 0.f;
							opponentStats.injuryResist 		= 0.f;
							opponentStats.armorPiercing 	= 0.75f;
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_POISON);
							NPC.AddDamageImmunity(theGame.params.DAMAGE_NAME_FORCE);
						}
					}
					else
					{
						wasNotScaled = true;
						opponentStats.damageValue = 1;
						opponentStats.healthValue = 1;
						opponentStats.healthType = BCS_Vitality;
						
						opponentStats.dangerLevel		= 10;
						opponentStats.poiseValue 		= 0.f;
						opponentStats.physicalResist	= 0.f;
						opponentStats.forceResist 		= 0.f;
						opponentStats.frostResist 		= 0.f;
						opponentStats.fireResist 		= 0.f;
						opponentStats.shockResist 		= 0.f;
						opponentStats.elementalResist 	= 0.f;
						opponentStats.slowResist 		= 0.f;
						opponentStats.confusionResist 	= 0.f;
						opponentStats.bleedingResist 	= 0.f;
						opponentStats.poisonResist 		= 0.f;
						opponentStats.stunResist 		= 0.f;
						opponentStats.injuryResist 		= 0.f;
						opponentStats.armorPiercing 	= 0.f;
					}
				break;
				
				case MC_Animal : return;
				default : return;
			}
		}
	}
	
	public function OpponentSetup( NPC : CNewNPC, out opponentAbilities : W3AbilityManager, out opponentStats : SOpponentStats, originalLevel : int, out displayLevel : int)
	{
		var npcStats : CCharacterStats;
		var ciriEntity : W3ReplacerCiri;
		var damageScale, healthScale : float;
		var playerLevel : int;
		var health : EBaseCharacterStats;
		var wasNotScaled : bool;
		var ab : array<CName>;
		
		if( NPC.GetWasScaled() || NPC.HasTag('q702_bloodlust_counter') || opponentStats.opponentType == MC_Animal ) return;
		
		NPC.SetWasScaled(true);
		npcStats = NPC.GetCharacterStats();
		npcStats.GetAbilities(ab, false);
		
		if( npcStats.HasAbility('VesemirDamage') )
			NPC.RemoveAbility('VesemirDamage');
		if( npcStats.HasAbility('CiriHardcoreDebuffMonster') )
			NPC.RemoveAbility('CiriHardcoreDebuffMonster');
		if( npcStats.HasAbility('CiriHardcoreDebuffMonster') )
			NPC.RemoveAbility('CiriHardcoreDebuffMonster');
		
		npcStats.RemoveAbilityAll(theGame.params.ENEMY_BONUS_PER_LEVEL);
		npcStats.RemoveAbilityAll(theGame.params.ENEMY_GROUP_BONUS_PER_LEVEL);
		npcStats.RemoveAbilityAll(theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP_ARMORED);
		npcStats.RemoveAbilityAll(theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP);
		npcStats.RemoveAbilityAll(theGame.params.MONSTER_BONUS_PER_LEVEL_ARMORED);
		npcStats.RemoveAbilityAll(theGame.params.MONSTER_BONUS_PER_LEVEL);
		npcStats.RemoveAbilityAll(theGame.params.ENEMY_BONUS_PER_LEVEL_FIXED);
		npcStats.RemoveAbilityAll(theGame.params.ENEMY_GROUP_BONUS_PER_LEVEL_FIXED);
		npcStats.RemoveAbilityAll(theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP_ARMORED_FIXED);
		npcStats.RemoveAbilityAll(theGame.params.MONSTER_BONUS_PER_LEVEL_GROUP_FIXED);
		npcStats.RemoveAbilityAll(theGame.params.MONSTER_BONUS_PER_LEVEL_ARMORED_FIXED);
		npcStats.RemoveAbilityAll(theGame.params.MONSTER_BONUS_PER_LEVEL_FIXED);
		
		ciriEntity = (W3ReplacerCiri)thePlayer;
		if( ciriEntity )
		{
			if( NPC.IsHuman() && NPC.GetStat(BCS_Essence, true) < 0 )
				npcStats.AddAbility('CirihardcoreDebuffHuman');
			else
				npcStats.AddAbility('CiriHardcoreDebuffMonster');
		}
		
		CalculateStatsBoss(NPC, opponentStats, wasNotScaled);
		CalculateStatsPart1(NPC, opponentStats, wasNotScaled);
		CalculateStatsSpecter(NPC, opponentStats, wasNotScaled);
		CalculateStatsPart2(NPC, opponentStats, wasNotScaled);
		CalculateStatsPart3(NPC, opponentStats, wasNotScaled);
		CalculateStatsPart4(NPC, opponentStats, wasNotScaled);
		Enemies().CacheSkillValues(NPC, opponentStats);
		ApplyStatModifiers(NPC, opponentStats);
		EnemyDisparity(NPC, opponentStats);
		Enemies().NPCStaminaSetup(NPC);
		
		if( NPC.HasAbility('mon_noonwraith_doppelganger') )
			return;
		
		if( NPC.UsesEssence() )
			health = BCS_Essence;
		else
			health = BCS_Vitality;
		
		opponentStats.armorPiercing *= Options().GetEnemyAPMult();
		if( NPC.HasTag('MonsterHuntTarget') )
		{
			opponentStats.healthValue *= 1.3f;
			opponentStats.damageValue *= 1.15f;
		}
		if( FactsQuerySum("NewGamePlus") > 0 )
		{
			opponentStats.healthValue *= 1.35f;
			opponentStats.damageValue *= 1.2f;
		}
		if( !NPC.HasTag('failedFundamentalsAchievement') )
		{
			opponentAbilities.SetStatPointMax(health, opponentStats.healthValue);
			opponentAbilities.SetStatPointCurrent(health, opponentStats.healthValue);
		}
	}
}

exec function who()
{
	var ents : array< CGameplayEntity >;
	var arrNames, arrUniqueNames : array< name >;
	var i : int;
	var actor : CActor;
	var template : CEntityTemplate;
	var interactionTarget : CInteractionComponent;

	interactionTarget = theGame.GetInteractionsManager().GetActiveInteraction();
	if( interactionTarget )
	{
		theGame.witcherLog.AddMessage("Object template: " + interactionTarget.GetEntity().GetReadableName());
	}

	if( !interactionTarget )
	{
		actor = thePlayer.GetTarget();
	}

	if( !actor )
	{
		FindGameplayEntitiesCloseToPoint( ents, thePlayer.GetWorldPosition(), 3, 1, , , , 'CNewNPC');
		if( ents.Size() > 0 )
		{
			actor = (CActor)ents[0];
		}
	}

	if( actor )
	{
		theGame.witcherLog.AddMessage("NPC template: " + actor.GetReadableName());
		
		actor.GetCharacterStats().GetAbilities( arrNames, true );
		
		ArrayOfNamesAppendUnique(arrUniqueNames, arrNames);
		if(arrUniqueNames.Size() > 0)
		{
			for( i = 0; i < arrUniqueNames.Size(); i += 1 )
				theGame.witcherLog.AddMessage("Ability:" + arrUniqueNames[i]);
		}
		
		arrNames.Clear();
		arrNames = actor.GetTags();
		if(arrNames.Size() > 0)
		{
			for( i = 0; i < arrNames.Size(); i += 1 )
				theGame.witcherLog.AddMessage("Tag:" + arrNames[i]);
		}
		
		template = (CEntityTemplate)LoadResource( actor.GetReadableName(), true );
		if(template.includes.Size() > 0)
		{
			for( i = 0; i < template.includes.Size(); i += 1 )
				theGame.witcherLog.AddMessage("Includes:" + template.includes[i].GetPath());
		}
	}
}

exec function bosstest()
{
	var witcher : W3PlayerWitcher = GetWitcherPlayer();
	
	witcher.Debug_ClearCharacterDevelopment(true);
	witcher.inv.AddAnItem('Bear Armor', 1, false, false, false);
	witcher.inv.AddAnItem('Bear Boots 1', 1, false, false, false);
	witcher.inv.AddAnItem('Bear Pants 1', 1, false, false, false);
	witcher.inv.AddAnItem('Bear Gloves 1', 1, false, false, false);
	witcher.inv.AddAnItem('Bear Armor 4', 1, false, false, false);
	witcher.inv.AddAnItem('Bear Boots 5', 1, false, false, false);
	witcher.inv.AddAnItem('Bear Pants 5', 1, false, false, false);
	witcher.inv.AddAnItem('Bear Gloves 5', 1, false, false, false);
	witcher.inv.AddAnItem('Lynx Armor', 1, false, false, false);
	witcher.inv.AddAnItem('Lynx Boots 1', 1, false, false, false);
	witcher.inv.AddAnItem('Lynx Pants 1', 1, false, false, false);
	witcher.inv.AddAnItem('Lynx Gloves 1', 1, false, false, false);
}