/****************************************************************************/
/** Copyright © CD Projekt RED 2015
/** Author : Reaperrz
/****************************************************************************/

enum EHairType
{
	EHT_Preview,
	EHT_HalfTail,
	EHT_ShavedTail,
	EHT_LongLoose,
	EHT_ShortLoose,
	EHT_Mohawk,
	EHT_Nilfgaard
}

struct SArmorCount
{
	var exact : int;
	var weighted : float;
};

class W3EEEquipmentHandler extends W3EEOptionHandler
{
	public final function LevelRequirementIndicator( out colour : string, itemId : SItemUniqueId, Inv : CInventoryComponent )
	{
		var checkLevel : int;
		
		checkLevel = thePlayer.GetLevel();
		
		if(thePlayer.HasBuff(EET_WolfHour))
			checkLevel += 2;
		
		if ( Inv.GetItemLevel(itemId) <= checkLevel ) 
			colour = "<font color = '#66FF66'>";	
		else
			colour = "<font color = '#9F1919'>";
	}
	
	public final function LevelRequirementIndicator2( out colour : string, lvl_item : int, Inv : CInventoryComponent )
	{
		var checkLevel : int;
		
		checkLevel = thePlayer.GetLevel();
		
		if(thePlayer.HasBuff(EET_WolfHour))
			checkLevel += 2;
		
		if ( lvl_item > checkLevel ) 
			colour = "<font color = '#9F1919'>";
		else
			colour = "<font color = '#66FF66'>";
	}
	
	public final function LevelRequirements( item : SItemUniqueId, inv : CInventoryComponent ) : bool
	{
		return true;
	}
	
	public final function UnableToEquip( out flashObject : CScriptedFlashObject, inv : CInventoryComponent, item : SItemUniqueId ) 
	{
	}
	
	private function HairTypeToName( hairType : EHairType ) : name
	{
		switch(hairType)
		{
			case EHT_Preview:		return 'Preview Hair';
			case EHT_HalfTail:		return 'Half With Tail Hairstyle';
			case EHT_ShavedTail:	return 'Shaved With Tail Hairstyle';
			case EHT_LongLoose:		return 'Long Loose Hairstyle';
			case EHT_ShortLoose:	return 'Short Loose Hairstyle';
			case EHT_Mohawk:		return 'Mohawk With Ponytail Hairstyle';
			case EHT_Nilfgaard:		return 'Nilfgaardian Hairstyle';
			default:	return 'Preview Hair';
		}
	}
	
	private function HairNameToType( hairName : name ) : EHairType
	{
		switch(hairName)
		{
			case 'Preview Hair':					return EHT_Preview;
			case 'Half With Tail Hairstyle':		return EHT_HalfTail;
			case 'Shaved With Tail Hairstyle':		return EHT_ShavedTail;
			case 'Long Loose Hairstyle':			return EHT_LongLoose;
			case 'Short Loose Hairstyle':			return EHT_ShortLoose;
			case 'Mohawk With Ponytail Hairstyle':	return EHT_Mohawk;
			case 'Nilfgaardian Hairstyle':			return EHT_Nilfgaard;
			default :	return EHT_Preview;
		}
	}
	
	private var lastMountedItem : SItemUniqueId;
	public function ToggleHairItem( enabled : bool, witcher : W3PlayerWitcher, optional invCall : bool )
	{	
		var ids : array <SItemUniqueId>;
		var inv : CInventoryComponent;
		var hairApplied : bool;
		var i : int;
		
		inv = witcher.GetInventory();
		
		if( enabled )
		{
			if( invCall )
			{
				if( inv.IsIdValid(lastMountedItem) )
					inv.MountItem(lastMountedItem, false);
			}
			else
			{
				ids = inv.GetItemsByName(HairTypeToName((EHairType)FactsQueryLatestValue("SavedHairType")));
				if( inv.IsIdValid(ids[0]) )
				{
					inv.MountItem(ids[0], false);
					lastMountedItem = ids[0];
				}
				else
				{
					ids = inv.AddAnItem(HairTypeToName((EHairType)FactsQueryLatestValue("SavedHairType")), 1, true, false);
					inv.MountItem(ids[0], false);
					lastMountedItem = ids[0];
				}
			}
		}
		else
		{
			ids = inv.GetItemsByCategory('hair');
			for(i=0; i<ids.Size(); i+=1)
			{
				if( invCall )
				{
					if( inv.IsItemMounted(ids[i]) )
						inv.DespawnItem(ids[i]);
				}
				else
				{
					if( inv.IsItemMounted(ids[i]) )
					{
						FactsAdd("SavedHairType", (int)HairNameToType(inv.GetItemName(ids[i])), -1);
						inv.UnmountItem(ids[i], false);
					}
				}
			}
		}
	}
	
	public function GatherHerbs()
	{
		var herbs : array<CGameplayEntity>;
		var i : int;
		
		FindGameplayEntitiesInRange(herbs, GetWitcherPlayer(), 6.f, 30,, FLAG_ExcludePlayer,, 'W3Herb');
		for(i=0; i<herbs.Size(); i+=1)
			LootHerb((W3Container)herbs[i]);
	}
	
	public final function LootHerb( herb : W3Container )
	{
		var i, number, bonusNumber : int;
		var witcher : W3PlayerWitcher;
		var herbs : array<SItemUniqueId>;
		var herbInventory : CInventoryComponent;
		
		witcher = GetWitcherPlayer();
		
		herbInventory = herb.GetInventory();
		herbInventory.GetAllItems( herbs );
		
		if( herbs.Size() )
			theSound.SoundEvent("gui_loot_popup_close");
		
		for(i=0; i < herbs.Size(); i+=1)
		{
			number = herbInventory.GetItemQuantity(herbs[i]);
			bonusNumber = RandRange(2,0) + RandRange(2,1) - RandRange(2,0) + RandRange(4,0);
			
			witcher.inv.AddAnItem(herbInventory.GetItemName( herbs[i] ), bonusNumber);
			herbInventory.NotifyItemLooted(herbs[i]);
			herbInventory.GiveItemTo(witcher.inv, herbs[i], number, true, false, true);
		}
		
		herb.OnContainerClosed();
		herb.RequestUpdateContainer();
		
		witcher.FinishInvUpdateTransaction();
	}
	
	public function GetArmorTypeFromName( itemName : name ) : EArmorType
	{
		var armor : array<SItemUniqueId>;
		var armorType : EArmorType;
		
		if( !theGame.GetDefinitionsManager().IsItemAnyArmor(itemName) )
			return EAT_Undefined;
			
		armor = GetWitcherPlayer().inv.AddAnItem(itemName, 1, true, true, false);
		armorType = GetWitcherPlayer().inv.GetArmorTypeOriginal(armor[0]);
		GetWitcherPlayer().inv.RemoveItem(armor[0], 1);
		
		return armorType;
	}
	
	public final function ScaleItems( inv : CInventoryComponent )
	{
		var items : array<SItemUniqueId>;
		var i : int;
		
		inv.GetAllItems(items);
		for(i=0; i<=items.Size(); i+=1)
			switch( inv.GetItemCategory(items[i]) )
			{
				case 'steelsword': 	inv.GetItemLevel(items[i]); break;
				case 'silversword': inv.GetItemLevel(items[i]); break;
				case 'armor': 		inv.GetItemLevel(items[i]); break;
				case 'gloves': 		inv.GetItemLevel(items[i]); break;
				case 'gloves': 		inv.GetItemLevel(items[i]); break;
				case 'boots': 		inv.GetItemLevel(items[i]); break;
				case 'pants': 		inv.GetItemLevel(items[i]); break;
			}
	}
	
	public function HandleRelicAbilities( witcher : W3PlayerWitcher, item : SItemUniqueId, equip : bool )
	{
		var weaponTags 	: array<name>;
		var effectType 	: EEffectType;
		var abilityName : name;
		
		if( !witcher.inv.IsItemWeapon(item) )
			return;
			
		witcher.inv.GetItemTags(item, weaponTags);
		if( equip )
		{
			EffectNameToType(weaponTags[weaponTags.Size()-1], effectType, abilityName);
			if( effectType != EET_Undefined )
				witcher.AddEffectDefault(effectType, witcher, "RelicWeaponBuff", false);
		}
		else
		{
			EffectNameToType(weaponTags[weaponTags.Size()-1], effectType, abilityName);
			if( effectType != EET_Undefined )
				witcher.RemoveBuff(effectType, false, "RelicWeaponBuff");
		}
	}
	
	public function SetStringWhite( str : string ) : string
	{
		return "<font color='#ffffff'>" + str + "</font>";
	}
	
	public function GetRelicAbilityDescription( item : SItemUniqueId, inv : CInventoryComponent ) : string
	{
		var weaponTags 		: array<name>;
		var effectType 		: EEffectType;
		var abilityString 	: string;
		var stringParams 	: array<string>;
		var abilityName		: name;
		var min, max		: SAbilityAttributeValue;
		var dm				: CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		
		if( !inv.IsItemWeapon(item) )
			return "";
			
		inv.GetItemTags(item, weaponTags);
		EffectNameToType(weaponTags[weaponTags.Size()-1], effectType, abilityName);
		if( effectType == EET_Undefined )
			return "";
			
		abilityString = "<font color='#a2a2a2'>" + GetLocStringByKeyExt("W3EE_UniqueWeaponAbility") + "<br>" +"<font color='#ca610c'>";
		switch(effectType)
		{
			case EET_SwordCritVigor:
				stringParams.PushBack(SetStringWhite("40%"));
				stringParams.PushBack(SetStringWhite("10"));
				abilityString += GetLocStringByKeyExtWithParams(weaponTags[weaponTags.Size()-1] + "Descr", , , stringParams);
			break;
			
			case EET_SwordRendBlast:
				abilityString += GetLocStringByKeyExtWithParams(weaponTags[weaponTags.Size()-1] + "Descr", , , stringParams);
			break;
			
			case EET_SwordInjuryHeal:
				stringParams.PushBack(SetStringWhite("30%"));
				abilityString += GetLocStringByKeyExtWithParams(weaponTags[weaponTags.Size()-1] + "Descr", , , stringParams);
			break;
			
			case EET_SwordDancing:
				abilityString += GetLocStringByKeyExtWithParams(weaponTags[weaponTags.Size()-1] + "Descr", , , stringParams);
			break;
			
			case EET_SwordQuen:
				abilityString += GetLocStringByKeyExtWithParams(weaponTags[weaponTags.Size()-1] + "Descr", , , stringParams);
			break;
			
			case EET_SwordWraithbane:
				abilityString += GetLocStringByKeyExtWithParams(weaponTags[weaponTags.Size()-1] + "Descr", , , stringParams);
			break;
			
			case EET_SwordBloodFrenzy:
				dm.GetAbilityAttributeValue('SwordBloodFrenzyAbility', 'attack_stamina_cost_bonus', min, max);		
				stringParams.PushBack(SetStringWhite(NoTrailZeros(RoundF(min.valueMultiplicative * 100)) + "%"));
				
				dm.GetAbilityAttributeValue('SwordBloodFrenzyAbility', 'attack_speed', min, max);		
				stringParams.PushBack(SetStringWhite(NoTrailZeros(RoundF(min.valueMultiplicative * 100)) + "%"));
				
				stringParams.PushBack(SetStringWhite("5"));
				
				abilityString += GetLocStringByKeyExtWithParams(weaponTags[weaponTags.Size()-1] + "Descr", , , stringParams);
			break;
			
			case EET_SwordKillBuff:
				abilityString += GetLocStringByKeyExtWithParams(weaponTags[weaponTags.Size()-1] + "Descr", , , stringParams);
			break;
			
			case EET_SwordBehead:
				stringParams.PushBack(SetStringWhite("10"));
				abilityString += GetLocStringByKeyExtWithParams(weaponTags[weaponTags.Size()-1] + "Descr", , , stringParams);
			break;
			
			case EET_SwordGas:
				stringParams.PushBack(SetStringWhite("15%"));
				abilityString += GetLocStringByKeyExtWithParams(weaponTags[weaponTags.Size()-1] + "Descr", , , stringParams);
			break;
			
			case EET_SwordSignDancer:
				abilityString += GetLocStringByKeyExtWithParams(weaponTags[weaponTags.Size()-1] + "Descr", , , stringParams);
			break;
			
			case EET_SwordReachoftheDamned:
				stringParams.PushBack(SetStringWhite("50%"));
				stringParams.PushBack(SetStringWhite("80"));
				stringParams.PushBack(SetStringWhite("50%"));
				stringParams.PushBack(SetStringWhite("150"));
				abilityString += GetLocStringByKeyExtWithParams(weaponTags[weaponTags.Size()-1] + "Descr", , , stringParams);
			break;
			
			case EET_SwordDarkCurse:
				stringParams.PushBack(SetStringWhite("3"));
				abilityString += GetLocStringByKeyExtWithParams(weaponTags[weaponTags.Size()-1] + "Descr", , , stringParams);
			break;
			
			case EET_SwordDesperateAct:
				stringParams.PushBack(SetStringWhite("15%"));
				stringParams.PushBack(SetStringWhite("50%"));
				abilityString += GetLocStringByKeyExtWithParams(weaponTags[weaponTags.Size()-1] + "Descr", , , stringParams);
			break;
			
			case EET_SwordRedTear:
				stringParams.PushBack(SetStringWhite("30%"));
				stringParams.PushBack(SetStringWhite("60%"));
				abilityString += GetLocStringByKeyExtWithParams(weaponTags[weaponTags.Size()-1] + "Descr", , , stringParams);
			break;
			
			case EET_WinterBlade:
				stringParams.PushBack(SetStringWhite("5"));
				abilityString += GetLocStringByKeyExtWithParams("item_desc_winterblade", , , stringParams);
			break;
			
			case EET_PhantomWeapon:
				stringParams.PushBack(SetStringWhite("5"));
				abilityString += GetLocStringByIdWithParams(2116942037, , , stringParams);
			break;
			
			case EET_Aerondight:
				dm.GetAbilityAttributeValue('AerondightEffect', 'crit_dam_bonus_stack', min, max);		
				stringParams.PushBack(SetStringWhite(NoTrailZeros(RoundF(min.valueAdditive * 100))));
				dm.GetAbilityAttributeValue('AerondightEffect', 'crit_chance_bonus', min, max);		
				stringParams.PushBack(SetStringWhite(NoTrailZeros(RoundF(min.valueAdditive * 100))));
				abilityString += GetLocStringByKeyExtWithParams("attribute_name_aerondight", , , stringParams);
				
				abilityString += "<br><br>" + GetLocStringByKeyExt("attribute_name_aerondight_abilities");
			break;
			
			default : return "";
		}
		abilityString += "</font>";
		
		return abilityString;
	}
	
	public function GetRelicAbilityDescriptionByName( itemName : name ) : string
	{
		var weaponTags 		: array<name>;
		var effectType 		: EEffectType;
		var abilityString 	: string;
		var stringParams 	: array<string>;
		var abilityName		: name;
		var weapon 			: array<SItemUniqueId>;
		var min, max		: SAbilityAttributeValue;
		var dm				: CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		var inv 			: CInventoryComponent;
		
		if( !dm.IsItemWeapon(itemName) )
			return "";
			
		inv = GetWitcherPlayer().GetInventory();
		weapon = inv.AddAnItem(itemName, 1, true, true, false);
		inv.GetItemTags(weapon[0], weaponTags);
		EffectNameToType(weaponTags[weaponTags.Size()-1], effectType, abilityName);
		
		if( inv.IsItemCrossbow(weapon[0]) )
		{
			inv.RemoveItemByName('Bodkin Bolt', 60);
		}
		if( effectType == EET_Undefined )
		{
			inv.RemoveItem(weapon[0], 1);
			return "";
		}
		
		abilityString = "<font color='#a2a2a2'>" + StrUpperUTF(GetLocStringByKeyExt("W3EE_UniqueWeaponAbility")) + "<br>" + "<font color='#ca610c'>";
		switch(effectType)
		{
			case EET_SwordCritVigor:
				stringParams.PushBack(SetStringWhite("40%"));
				stringParams.PushBack(SetStringWhite("10"));
				abilityString += GetLocStringByKeyExtWithParams(weaponTags[weaponTags.Size()-1] + "Descr", , , stringParams);
			break;
			
			case EET_SwordRendBlast:
				abilityString += GetLocStringByKeyExtWithParams(weaponTags[weaponTags.Size()-1] + "Descr", , , stringParams);
			break;
			
			case EET_SwordInjuryHeal:
				stringParams.PushBack(SetStringWhite("30%"));
				abilityString += GetLocStringByKeyExtWithParams(weaponTags[weaponTags.Size()-1] + "Descr", , , stringParams);
			break;
			
			case EET_SwordDancing:
				abilityString += GetLocStringByKeyExtWithParams(weaponTags[weaponTags.Size()-1] + "Descr", , , stringParams);
			break;
			
			case EET_SwordQuen:
				abilityString += GetLocStringByKeyExtWithParams(weaponTags[weaponTags.Size()-1] + "Descr", , , stringParams);
			break;
			
			case EET_SwordWraithbane:
				abilityString += GetLocStringByKeyExtWithParams(weaponTags[weaponTags.Size()-1] + "Descr", , , stringParams);
			break;
			
			case EET_SwordBloodFrenzy:
				dm.GetAbilityAttributeValue('SwordBloodFrenzyAbility', 'attack_stamina_cost_bonus', min, max);		
				stringParams.PushBack(SetStringWhite(NoTrailZeros(RoundF(min.valueMultiplicative * 100)) + "%"));
				
				dm.GetAbilityAttributeValue('SwordBloodFrenzyAbility', 'attack_speed', min, max);		
				stringParams.PushBack(SetStringWhite(NoTrailZeros(RoundF(min.valueMultiplicative * 100)) + "%"));
				
				stringParams.PushBack(SetStringWhite("5"));
				
				abilityString += GetLocStringByKeyExtWithParams(weaponTags[weaponTags.Size()-1] + "Descr", , , stringParams);
			break;
			
			case EET_SwordKillBuff:
				abilityString += GetLocStringByKeyExtWithParams(weaponTags[weaponTags.Size()-1] + "Descr", , , stringParams);
			break;
			
			case EET_SwordBehead:
				stringParams.PushBack(SetStringWhite("10"));
				abilityString += GetLocStringByKeyExtWithParams(weaponTags[weaponTags.Size()-1] + "Descr", , , stringParams);
			break;
			
			case EET_SwordGas:
				stringParams.PushBack(SetStringWhite("15%"));
				abilityString += GetLocStringByKeyExtWithParams(weaponTags[weaponTags.Size()-1] + "Descr", , , stringParams);
			break;
			
			case EET_SwordSignDancer:
				abilityString += GetLocStringByKeyExtWithParams(weaponTags[weaponTags.Size()-1] + "Descr", , , stringParams);
			break;
			
			case EET_SwordReachoftheDamned:
				stringParams.PushBack(SetStringWhite("50%"));
				stringParams.PushBack(SetStringWhite("80"));
				stringParams.PushBack(SetStringWhite("50%"));
				stringParams.PushBack(SetStringWhite("150"));
				abilityString += GetLocStringByKeyExtWithParams(weaponTags[weaponTags.Size()-1] + "Descr", , , stringParams);
			break;
			
			case EET_SwordDarkCurse:
				stringParams.PushBack(SetStringWhite("3"));
				abilityString += GetLocStringByKeyExtWithParams(weaponTags[weaponTags.Size()-1] + "Descr", , , stringParams);
			break;
			
			case EET_SwordDesperateAct:
				stringParams.PushBack(SetStringWhite("15%"));
				stringParams.PushBack(SetStringWhite("50%"));
				abilityString += GetLocStringByKeyExtWithParams(weaponTags[weaponTags.Size()-1] + "Descr", , , stringParams);
			break;
			
			case EET_SwordRedTear:
				stringParams.PushBack(SetStringWhite("30%"));
				stringParams.PushBack(SetStringWhite("60%"));
				abilityString += GetLocStringByKeyExtWithParams(weaponTags[weaponTags.Size()-1] + "Descr", , , stringParams);
			break;
			
			case EET_WinterBlade:
				stringParams.PushBack(SetStringWhite("5"));
				abilityString += GetLocStringByKeyExtWithParams("item_desc_winterblade", , , stringParams);
			break;
			
			case EET_PhantomWeapon:
				stringParams.PushBack(SetStringWhite("5"));
				abilityString += GetLocStringByIdWithParams(2116942037, , , stringParams);
			break;
			
			case EET_Aerondight:
				dm.GetAbilityAttributeValue('AerondightEffect', 'crit_dam_bonus_stack', min, max);		
				stringParams.PushBack(SetStringWhite(NoTrailZeros(RoundF(min.valueAdditive * 100))));
				dm.GetAbilityAttributeValue('AerondightEffect', 'crit_chance_bonus', min, max);		
				stringParams.PushBack(SetStringWhite(NoTrailZeros(RoundF(min.valueAdditive * 100))));
				abilityString += GetLocStringByKeyExtWithParams("attribute_name_aerondight", , , stringParams);
				
				abilityString += "<br><br>" + GetLocStringByKeyExt("attribute_name_aerondight_abilities");
			break;
			
			default : return "";
		}
		abilityString += "</font>";
		inv.RemoveItem(weapon[0], 1);
		
		return abilityString;
	}
	
	public function DisallowUnequip( slot : EEquipmentSlots, item : SItemUniqueId, inv : CInventoryComponent ) : bool
	{
		var helmItem : array<SItemUniqueId>;
		
		if( slot == EES_Quickslot1 || slot == EES_Quickslot2 )
		{
			switch(inv.GetItemName(item))
			{
				case 'kotw_helm_v1_1_usable':	helmItem = inv.GetItemsByName('kotw_helm_v1_1');	break;
				case 'kotw_helm_v2_1_usable':	helmItem = inv.GetItemsByName('kotw_helm_v2_1');	break;
				case 'kotw_helm_v3_1_usable':	helmItem = inv.GetItemsByName('kotw_helm_v3_1');	break;
			}
			
			if( inv.IsItemMounted(helmItem[0]) )
				return true;
		}
		
		return false;
	}
	
	var horseDistance : float;
	public function GetHorseDistance() : float
	{
		var distance : float;
		
		distance = VecDistanceSquared(GetWitcherPlayer().GetWorldPosition(), GetWitcherPlayer().GetHorseWithInventory().GetWorldPosition());
		if( theGame.IsPaused() )
		{
			if( distance )
				return distance;
			else
				return horseDistance;
		}
		else
			return VecDistanceSquared(GetWitcherPlayer().GetWorldPosition(), GetWitcherPlayer().GetHorseWithInventory().GetWorldPosition());
	}
	
	public function SetHorseDistance()
	{
		horseDistance = VecDistanceSquared(GetWitcherPlayer().GetWorldPosition(), GetWitcherPlayer().GetHorseWithInventory().GetWorldPosition());
	}
	
	public function GetItemQuantityByNameForCrafting( itemName : name ) : int
	{
		var witcher : W3PlayerWitcher = GetWitcherPlayer();
		var inv : CInventoryComponent = witcher.GetInventory();
		var dm : CDefinitionsManagerAccessor;
		
		dm = theGame.GetDefinitionsManager();
		/*if( GetHorseDistance() <= 81 || Options().InvEverywhere() )
		{*/
			if( !dm.ItemHasTag(itemName, 'MutagenIngredient') )
				return inv.GetItemQuantityByName(itemName) + witcher.GetHorseManager().GetInventoryComponent().GetItemQuantityByName(itemName);
			else
				return inv.GetUnusedMutagensCount(itemName) + witcher.GetHorseManager().GetInventoryComponent().GetItemQuantityByName(itemName);
		/*}
		
		if( !dm.ItemHasTag(itemName, 'MutagenIngredient') )
			return inv.GetItemQuantityByName(itemName);
		else
			return inv.GetUnusedMutagensCount(itemName);*/
	}
	
	public function RemoveItemByNameForCrafting( itemName : name, quantity : int ) : bool
	{
		var witcher : W3PlayerWitcher = GetWitcherPlayer();
		var inv : CInventoryComponent = witcher.GetInventory();
		var horseInv : CInventoryComponent = witcher.GetHorseManager().GetInventoryComponent();
		var playerQuantity, horseQuantity, quantityToRemove, removedQuantity : int;
		var alchIngredients  : array<SItemUniqueId>;
		var dm : CDefinitionsManagerAccessor;
		var equippedOnSlot : EEquipmentSlots;
		var i : int;
		
		dm = theGame.GetDefinitionsManager();
		if( dm.IsItemAlchemyItem(itemName) && !dm.IsItemFood(itemName) )
		{
			quantityToRemove = quantity;
			playerQuantity = inv.GetItemQuantityByName(itemName);
			if( playerQuantity < quantityToRemove )
			{
				quantityToRemove = playerQuantity;
			}
			
			alchIngredients = inv.GetItemsByName(itemName);
			for(i=0; i<alchIngredients.Size(); i+=1)
			{
				inv.SingletonItemRemoveAmmo(alchIngredients[i], quantityToRemove);			
				if( !inv.GetItemModifierInt(alchIngredients[i], 'ammo_current') )
				{
					equippedOnSlot = witcher.GetItemSlot(alchIngredients[i]);
					if(equippedOnSlot != EES_InvalidSlot)
						witcher.UnequipItem(alchIngredients[i]);
					
					inv.RemoveItem(alchIngredients[i]);
					break;
				}
				
				removedQuantity += 1;
				if(removedQuantity >= quantityToRemove)
					break;
			}
			
			quantityToRemove = quantity - removedQuantity;
			if( quantityToRemove > 0 )
			{
				removedQuantity = 0;
				horseQuantity = horseInv.GetItemQuantityByName(itemName);
				if( horseQuantity < quantityToRemove )
				{
					quantityToRemove = horseQuantity;
				}
				
				alchIngredients = horseInv.GetItemsByName(itemName);
				for(i=0; i<alchIngredients.Size(); i+=1)
				{
					horseInv.SingletonItemRemoveAmmo(alchIngredients[i], quantityToRemove);			
					if( !horseInv.GetItemModifierInt(alchIngredients[i], 'ammo_current') )
					{
						horseInv.RemoveItem(alchIngredients[i]);
						break;
					}
					
					removedQuantity += 1;
					if(removedQuantity >= quantityToRemove)
						break;
				}
			}
			if( removedQuantity == quantity )
			{
				return true;
			}
			return false;
		}
		else
		if( !dm.ItemHasTag(itemName, 'MutagenIngredient') )
		{
			quantityToRemove = quantity;
			playerQuantity = inv.GetItemQuantityByName(itemName);
			if( playerQuantity < quantityToRemove )
			{
				quantityToRemove = playerQuantity;
			}
			if( quantityToRemove > 0 && inv.RemoveItemByName(itemName, quantityToRemove) )
			{
				removedQuantity = quantityToRemove;
			}
			quantityToRemove = quantity - removedQuantity;
			if( quantityToRemove > 0 )
			{
				horseQuantity = horseInv.GetItemQuantityByName(itemName);
				if( horseQuantity < quantityToRemove )
				{
					quantityToRemove = horseQuantity;
				}
				if( quantityToRemove > 0 && horseInv.RemoveItemByName(itemName, quantityToRemove) )
				{
					removedQuantity += quantityToRemove;
				}
			}
			if( removedQuantity == quantity )
			{
				return true;
			}
			return false;
		}
		else
		{
			quantityToRemove = quantity;
			playerQuantity = inv.GetUnusedMutagensCount(itemName);
			if( playerQuantity < quantityToRemove )
			{
				quantityToRemove = playerQuantity;
			}
			if( quantityToRemove > 0 && inv.RemoveUnusedMutagensCount(itemName, quantityToRemove) )
			{
				removedQuantity = quantityToRemove;
			}
			quantityToRemove = quantity - removedQuantity;
			if( quantityToRemove > 0 )
			{
				horseQuantity = horseInv.GetItemQuantityByName(itemName);
				if( horseQuantity < quantityToRemove )
				{
					quantityToRemove = horseQuantity;
				}
				if( quantityToRemove > 0 && horseInv.RemoveItemByName(itemName, quantityToRemove) )
				{
					removedQuantity += quantityToRemove;
				}
			}
			if( removedQuantity == quantity )
			{
				return true;
			}
			return false;
		}
	}
	
	public function GetSetCountStringColor( item : SItemUniqueId, str : string ) : string
	{
		switch(GetWitcherPlayer().inv.GetItemQuality(item))
		{
			case 1: 
				return "<font color='#a2a2a2'>" + str + "</font>";
			case 2:
				return "<font color='#2b7bff'>" + str + "</font>";
			case 3:
				return "<font color='#e1d401'>" + str + "</font>";
			case 4:
				return "<font color='#ca610c'>" + str + "</font>";	
			case 5:
			default:
				return "<font color='#01b701'>" + str + "</font>";
		}
	}
	
	public function GetDescriptionColorByType( descr : string, setType : EItemSetType, abilityLevel : int, currentCount : int, isActive : bool ) : string
	{
		if( !isActive )
		{
			if( abilityLevel == 2 && currentCount >= theGame.params.ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS )
				return "<font color=\"#9F1919\">" + descr + "</font>";
			else
				return descr;
		}
			
		switch(setType)
		{
			case EIST_LightArmor:
			case EIST_MediumArmor:
			case EIST_HeavyArmor:
				return "<font color=\"#ffffff\">" + descr + "</font>";
				
			default:
				return "<font color='#01b701'>" + descr + "</font>";
		}
	}
	
	public function GetSetTypeString( setType : EItemSetType ) : string
	{
		switch(setType)
		{
			case EIST_LightArmor:
			case EIST_MediumArmor:
			case EIST_HeavyArmor:
				return "<font color=\"#a2a2a2\">" + GetLocStringByKeyExt("W3EE_GenericArmorAbility") + "</font>";
				
			default:
				return "<font color='#01b701'>" + GetLocStringByKeyExt("W3EE_UniqueArmorAbility") + "</font>";
		}
	}
	
	public function GetGeneralArmorAbilityDescr( item : SItemUniqueId ) : string
	{
		if( GetWitcherPlayer().inv.GetArmorTypeOriginal(item) == EAT_Light )
			return GetGeneralArmorAbilityDescrByType(EISB_LightArmor, EIST_LightArmor);
		else if ( GetWitcherPlayer().inv.GetArmorTypeOriginal(item) == EAT_Medium )
			return GetGeneralArmorAbilityDescrByType(EISB_MediumArmor, EIST_MediumArmor);
		else if( GetWitcherPlayer().inv.GetArmorTypeOriginal(item) == EAT_Heavy )
			return GetGeneralArmorAbilityDescrByType(EISB_HeavyArmor, EIST_HeavyArmor);
		else
			return "";		
	}
	
	public function GetGeneralArmorAbilityDescrByName( itemName : name ) : string
	{
		if( GetArmorTypeFromName(itemName) == EAT_Light )
			return GetGeneralArmorAbilityDescrByType(EISB_LightArmor, EIST_LightArmor);
		else
		if( GetArmorTypeFromName(itemName) == EAT_Medium )
			return GetGeneralArmorAbilityDescrByType(EISB_MediumArmor, EIST_MediumArmor);
		else
		if( GetArmorTypeFromName(itemName) == EAT_Heavy )
			return GetGeneralArmorAbilityDescrByType(EISB_HeavyArmor, EIST_HeavyArmor);
		else
			return "";
	}
	
	public function GetGeneralArmorAbilityDescrByType(setBonusType : EItemSetBonus, setType : EItemSetType) : string
	{
		var curValueString : string;
		var value : float;
		
		value = GetWitcherPlayer().CategorySetBonusNumericValue(setType);
		if (value != 0)
		{
			curValueString = "<br>Current value: ";
			if (setType != EIST_LightArmor)
				value *= 100.0f;
				
			curValueString += NoTrailZeros(RoundTo(value, 1));
			
			if (setType != EIST_LightArmor)
				curValueString += "%.";
			else
				curValueString += ".";
		}
		else
			curValueString = "";
			
		return GetWitcherPlayer().GetSetBonusTooltipDescription(setBonusType) + curValueString;
	}
	
	public function IsGeneralArmorAbilityActive( item : SItemUniqueId ) : bool
	{
		var armorCount : array<SArmorCount>;
		
		armorCount = GetWitcherPlayer().GetArmorCountOrig();
		if( GetWitcherPlayer().inv.GetArmorTypeOriginal(item) == EAT_Light )
			return armorCount[0].exact + armorCount[1].exact >= 1;
		else
		if( GetWitcherPlayer().inv.GetArmorTypeOriginal(item) == EAT_Medium )
			return armorCount[2].exact >= 1;
		else
		if( GetWitcherPlayer().inv.GetArmorTypeOriginal(item) == EAT_Heavy )
			return armorCount[3].exact >= 1;
		else
			return 0;
	}
	
	public function GetMaximumSetItemsBySet( setType : EItemSetType ) : int
	{
		switch(setType)
		{
			case EIST_LightArmor:
			case EIST_MediumArmor:
			case EIST_HeavyArmor:
				return 4;
				
			case EIST_Gothic:
			case EIST_Dimeritium:
			case EIST_Meteorite:
				return 5;
				
			default:
				return 6;
		}
	}
	
	public function GetMinimumItemsReqBySet( setType : EItemSetType ) : int
	{
		switch(setType)
		{
			case EIST_LightArmor:
			case EIST_MediumArmor:
			case EIST_HeavyArmor:
				return 1;
				
			case EIST_MinorLynx:
			case EIST_MinorGryphon:
			case EIST_MinorBear:
			case EIST_MinorWolf:
			case EIST_MinorRedWolf:
				return theGame.params.ITEMS_REQUIRED_FOR_MAJOR_SET_BONUS;
				
			case EIST_Wolf:
			case EIST_Gryphon:
			case EIST_RedWolf:
				return theGame.params.ITEMS_REQUIRED_FOR_MINOR_SET_BONUS - 1;
				
			default:
				return theGame.params.ITEMS_REQUIRED_FOR_MINOR_SET_BONUS;
		}
	}
	
	public function HasPreviousTierRuneword( enchantName : name, itemID : SItemUniqueId ) : bool
	{
		var enchantment : name;
		
		enchantment = GetWitcherPlayer().GetInventory().GetEnchantment(itemID);
		if( enchantName == 'Runeword 2' && enchantment != 'Runeword 5' )
			return false;
		else
		if( enchantName == 'Runeword 1' && enchantment != 'Runeword 2' )
			return false;
		else
		if( enchantName == 'Runeword 10' && enchantment != 'Runeword 6' )
			return false;
		else
		if( enchantName == 'Runeword 4' && enchantment != 'Runeword 10' )
			return false;
		else
		if( enchantName == 'Runeword 12' && enchantment != 'Runeword 8' )
			return false;
		else
		if( enchantName == 'Runeword 11' && enchantment != 'Runeword 12' )
			return false;
		else
		return true;
	}
	
	public function UpgradeMeteoriteArmor( upgradeType : EShrineBuffs )
	{
		var i : int;
		var witcher : W3PlayerWitcher;
		var inv : CInventoryComponent;
		var meteoriteArmors : array <SItemUniqueId>;
		
		witcher = GetWitcherPlayer();
		if( witcher.IsSetBonusActive(EISB_Meteorite) )
		{
			inv = witcher.GetInventory();
			meteoriteArmors = inv.GetItemsByTag('MeteoriteSetTag');
			switch(upgradeType)
			{
				case ESB_Yrden:
						for(i=0; i<meteoriteArmors.Size(); i+=1)
							if( inv.ItemHasTag(meteoriteArmors[i],'MeteoriteBoots') )
								inv.AddItemCraftedAbility(meteoriteArmors[i], 'MeteoriteYrdenUpgrade', false);
				break;
				
				case ESB_Quen:
						for(i=0; i<meteoriteArmors.Size(); i+=1)
							if( inv.ItemHasTag(meteoriteArmors[i],'MeteoritePants') )
								inv.AddItemCraftedAbility(meteoriteArmors[i], 'MeteoriteQuenUpgrade', false);
				break;
				
				case ESB_Igni:
						for(i=0; i<meteoriteArmors.Size(); i+=1)
							if( inv.ItemHasTag(meteoriteArmors[i],'MeteoriteArmor') )
								inv.AddItemCraftedAbility(meteoriteArmors[i], 'MeteoriteIgniUpgrade', false);
				break;
				
				case ESB_Axii:
						for(i=0; i<meteoriteArmors.Size(); i+=1)
							if( inv.ItemHasTag(meteoriteArmors[i],'MeteoriteArmor') )
								inv.AddItemCraftedAbility(meteoriteArmors[i], 'MeteoriteAxiiUpgrade', false);
				break;
				
				case ESB_Aard:
						for(i=0; i<meteoriteArmors.Size(); i+=1)
							if( inv.ItemHasTag(meteoriteArmors[i],'MeteoriteGloves') )
								inv.AddItemCraftedAbility(meteoriteArmors[i], 'MeteoriteAardUpgrade', false);
				break;
			}
		}
	}
}

class kotwArmor extends CItemEntity
{
    event OnSpawned( spawnData : SEntitySpawnData )
    {
		super.OnSpawned(spawnData);
    }
}

class KOTWHelm_Base extends CItemEntity
{
	private function kotwAddAndEquipItem( item : name, witcher : W3PlayerWitcher )
	{
		var items : array <SItemUniqueId>;
		
		items = witcher.inv.AddAnItem(item);
		witcher.inv.MountItem(items[0]);
	}
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{	
		var helmCap : SItemUniqueId;
		var hairIds : array<SItemUniqueId>;
		var witcher : W3PlayerWitcher;
		var inv : CInventoryComponent;
		var helm : SItemUniqueId;
		var hasHelm : bool;
		var i : int;
		
		witcher = GetWitcherPlayer();
		inv = witcher.GetInventory();
		helmCap = inv.GetItemId( 'kotw_helm_cap' );
		hairIds = inv.GetItemsByCategory( 'hair' );
		hasHelm = inv.HasItem( 'kotw_helm_cap' );
		
		
		super.OnSpawned( spawnData );
		
		helm = inv.GetItemId( 'kotw_helm_v1_1' );
		if( inv.IsIdValid(helm) )
		{
			witcher.SetCurrentHelmet(EIST_Gothic);
		}
		
		helm = inv.GetItemId( 'kotw_helm_v2_1' );
		if( inv.IsIdValid(helm) )
		{
			witcher.SetCurrentHelmet(EIST_Meteorite);
		}
		
		helm = inv.GetItemId( 'kotw_helm_v3_1' );
		if( inv.IsIdValid(helm) )
		{
			witcher.SetCurrentHelmet(EIST_Dimeritium);
			witcher.ManageActiveSetBonuses(EIST_Dimeritium);
		}
		
		if( hasHelm )
		{
			for(i=0; i<hairIds.Size(); i+=1)
				inv.UnmountItem( hairIds[i] );
			inv.MountItem( helmCap );
		}
		else kotwAddAndEquipItem( 'kotw_helm_cap', witcher );
		
		if( !FactsDoesExist('hair_removed') )
			FactsAdd( "hair_removed", 1, -1 );
	}
}

class KOTWHelm_V1_1 extends W3QuestUsableItem
{
	private function kotwAddAndEquipItem( item : name, witcher : W3PlayerWitcher )
	{
		var items : array <SItemUniqueId>;
		
		items = witcher.inv.AddAnItem(item);
		witcher.inv.MountItem(items[0]);
	}
	
	private function kotwToggleHairItem( enabled : bool, witcher : W3PlayerWitcher )
	{	
		var ids : array <SItemUniqueId>;
		var inv : CInventoryComponent;
		var hairApplied : bool;
		var i : int;
		
		inv = witcher.GetInventory();
		ids = inv.GetItemsByCategory('hair');
		
		if( enabled )
		{
			for(i=0; i<ids.Size(); i+= 1)
			{
				if( inv.GetItemName( ids[i] ) != 'Preview Hair' )
				{
					if( hairApplied == false )
					{
						inv.MountItem(ids[i], false);
						hairApplied = true;
					}
					else inv.RemoveItem(ids[i], 1);
				}
			}
			
			if( hairApplied == false )
			{
				ids = inv.AddAnItem('Half With Tail Hairstyle', 1, true, false);
				inv.MountItem( ids[0], false );
			}
		}
		else
		for(i=0; i<ids.Size(); i+=1)
			inv.UnmountItem(ids[i],false);
	}

	private function kotwRemoveHelmItems( witcher : W3PlayerWitcher )
	{
		var i : int;
		var ids : array< SItemUniqueId >;
		
		ids = witcher.inv.GetItemsByTag( 'kotwHelm' );
		FactsRemove( "hair_removed" );
		for(i=0; i<ids.Size(); i+= 1)
		{
			witcher.inv.RemoveItem( ids[i] );
			witcher.SetCurrentHelmet(EIST_Undefined);
		}
	}

	event OnSpawned( spawnData : SEntitySpawnData )
	{	
		super.OnSpawned( spawnData );
	}
	
	event OnUsed( usedBy : CEntity )
	{
		var inv : CInventoryComponent;
		var helm : SItemUniqueId;
		var visorUp : SItemUniqueId;
		var visorDown : SItemUniqueId;
		var isHelmEquipped : bool;
		var isVisorUp : bool;
		var isVisorDown : bool;
		var witcher : W3PlayerWitcher;
		
		witcher = (W3PlayerWitcher)usedBy;
		inv = witcher.GetInventory();
		helm = inv.GetItemId( 'kotw_helm_v1_1' );
		visorUp = inv.GetItemId( 'kotw_visor_v1_1a' );
		visorDown = inv.GetItemId( 'kotw_visor_v1_1' );
		isHelmEquipped = inv.IsItemMounted( helm );
		isVisorUp = inv.IsItemMounted( visorUp );
		isVisorDown = inv.IsItemMounted( visorDown );
		
		super.OnUsed(usedBy);
			
		if( !FactsDoesExist('hair_removed') && !inv.HasItem( 'kotw_helm_v1_1') && !inv.HasItem( 'kotw_visor_v1_1a') && !inv.HasItem( 'kotw_visor_v1_1') )
		{
			kotwAddAndEquipItem( 'kotw_helm_v1_1', witcher );
			kotwAddAndEquipItem( 'kotw_visor_v1_1', witcher );
			inv.AddAnItem( 'kotw_visor_v1_1a', 1);
		}
		
		if( FactsDoesExist( 'hair_removed' ) )
		{				
			if( !isHelmEquipped && !isVisorUp && !isVisorDown )
			{
				inv.MountItem( helm );
				inv.MountItem( visorDown );
			}
			else
			if( isHelmEquipped && isVisorDown ) 
			{ 
				inv.UnmountItem( visorDown );
				inv.MountItem( visorUp );
			} 
			else
			if( isHelmEquipped && isVisorUp ) 
			{ 
				kotwRemoveHelmItems(witcher);
				kotwToggleHairItem(true, witcher);
			}
		}
	}
}

class KOTWHelm_V2_1 extends W3QuestUsableItem
{		
	private function kotwAddAndEquipItem( item : name, witcher : W3PlayerWitcher )
	{
		var items : array <SItemUniqueId>;
		
		items = witcher.inv.AddAnItem(item);
		witcher.inv.MountItem(items[0]);
	}
	
	private function kotwToggleHairItem( enabled : bool, witcher : W3PlayerWitcher )
	{	
		var ids : array <SItemUniqueId>;
		var inv : CInventoryComponent;
		var hairApplied : bool;
		var i : int;
		
		inv = witcher.GetInventory();
		ids = inv.GetItemsByCategory('hair');
		
		if( enabled )
		{
			for(i=0; i<ids.Size(); i+= 1)
			{
				if( inv.GetItemName( ids[i] ) != 'Preview Hair' )
				{
					if( hairApplied == false )
					{
						inv.MountItem(ids[i], false);
						hairApplied = true;
					}
					else inv.RemoveItem(ids[i], 1);
				}
			}
			
			if( hairApplied == false )
			{
				ids = inv.AddAnItem('Half With Tail Hairstyle', 1, true, false);
				inv.MountItem( ids[0], false );
			}
		}
		else
		for(i=0; i<ids.Size(); i+=1)
			inv.UnmountItem(ids[i],false);
	}

	private function kotwRemoveHelmItems( witcher : W3PlayerWitcher )
	{
		var i : int;
		var ids : array< SItemUniqueId >;
		
		ids = witcher.inv.GetItemsByTag( 'kotwHelm' );
		FactsRemove( "hair_removed" );
		for(i=0; i<ids.Size(); i+= 1)
		{
			witcher.inv.RemoveItem( ids[i] );
			witcher.SetCurrentHelmet(EIST_Undefined);
		}
	}

	event OnSpawned( spawnData : SEntitySpawnData )
	{	
		super.OnSpawned( spawnData );
	}
	
	event OnUsed( usedBy : CEntity )
	{
		var inv : CInventoryComponent;
		var helm : SItemUniqueId;
		var visorUp : SItemUniqueId;
		var visorDown : SItemUniqueId;
		var isHelmEquipped : bool;
		var isVisorUp : bool;
		var isVisorDown : bool;
		var witcher : W3PlayerWitcher;
		
		witcher = (W3PlayerWitcher)usedBy;
		inv = witcher.GetInventory();
		helm = inv.GetItemId( 'kotw_helm_v2_1' );
		visorUp = inv.GetItemId( 'kotw_visor_v2_1a' );
		visorDown = inv.GetItemId( 'kotw_visor_v2_1' );
		isHelmEquipped = inv.IsItemMounted( helm );
		isVisorUp = inv.IsItemMounted( visorUp );
		isVisorDown = inv.IsItemMounted( visorDown );
		
		super.OnUsed(usedBy);
			
		if( !FactsDoesExist('hair_removed') && !thePlayer.inv.HasItem('kotw_helm_v2_1') && !thePlayer.inv.HasItem('kotw_visor_v2_1a') && !thePlayer.inv.HasItem('kotw_visor_v2_1') )
		{
			kotwAddAndEquipItem( 'kotw_helm_v2_1', witcher );
			kotwAddAndEquipItem( 'kotw_visor_v2_1', witcher );
			inv.AddAnItem( 'kotw_visor_v2_1a', 1);
		}
		
		if( FactsDoesExist( 'hair_removed' ) )
		{				
			if( !isHelmEquipped && !isVisorUp && !isVisorDown )
			{
				inv.MountItem( helm );
				inv.MountItem( visorDown );
			}
			else
			if( isHelmEquipped && isVisorDown ) 
			{ 
				inv.UnmountItem( visorDown );
				inv.MountItem( visorUp );
			} 
			else
			if( isHelmEquipped && isVisorUp ) 
			{ 
				kotwRemoveHelmItems(witcher);
				kotwToggleHairItem(true, witcher);
			}
		}
	}
}

class KOTWHelm_V3_1 extends W3QuestUsableItem
{		
	private function kotwAddAndEquipItem( item : name, witcher : W3PlayerWitcher )
	{
		var items : array <SItemUniqueId>;
		
		items = witcher.inv.AddAnItem(item);
		witcher.inv.MountItem(items[0]);
	}
	
	private function kotwToggleHairItem( enabled : bool, witcher : W3PlayerWitcher )
	{	
		var ids : array <SItemUniqueId>;
		var inv : CInventoryComponent;
		var hairApplied : bool;
		var i : int;
		
		inv = witcher.GetInventory();
		ids = inv.GetItemsByCategory('hair');
		
		if( enabled )
		{
			for(i=0; i<ids.Size(); i+= 1)
			{
				if( inv.GetItemName( ids[i] ) != 'Preview Hair' )
				{
					if( hairApplied == false )
					{
						inv.MountItem(ids[i], false);
						hairApplied = true;
					}
					else inv.RemoveItem(ids[i], 1);
				}
			}
			
			if( hairApplied == false )
			{
				ids = inv.AddAnItem('Half With Tail Hairstyle', 1, true, false);
				inv.MountItem( ids[0], false );
			}
		}
		else
		for(i=0; i<ids.Size(); i+=1)
			inv.UnmountItem(ids[i],false);
	}

	private function kotwRemoveHelmItems( witcher : W3PlayerWitcher )
	{
		var i : int;
		var ids : array< SItemUniqueId >;
		
		ids = witcher.inv.GetItemsByTag( 'kotwHelm' );
		FactsRemove( "hair_removed" );
		for(i=0; i<ids.Size(); i+= 1)
		{
			witcher.inv.RemoveItem( ids[i] );
			witcher.SetCurrentHelmet(EIST_Undefined);
		}
	}

	event OnSpawned( spawnData : SEntitySpawnData )
	{	
		super.OnSpawned( spawnData );
	}
	
	event OnUsed( usedBy : CEntity )
	{
		var inv : CInventoryComponent;
		var helm : SItemUniqueId;
		var visorUp : SItemUniqueId;
		var visorDown : SItemUniqueId;
		var isHelmEquipped : bool;
		var isVisorUp : bool;
		var isVisorDown : bool;
		var witcher : W3PlayerWitcher;
		
		witcher = (W3PlayerWitcher)usedBy;
		inv = witcher.GetInventory();
		helm = inv.GetItemId( 'kotw_helm_v3_1' );
		visorUp = inv.GetItemId( 'kotw_visor_v3_1a' );
		visorDown = inv.GetItemId( 'kotw_visor_v3_1' );
		isHelmEquipped = inv.IsItemMounted( helm );
		isVisorUp = inv.IsItemMounted( visorUp );
		isVisorDown = inv.IsItemMounted( visorDown );
		
		super.OnUsed(usedBy);
			
		if( !FactsDoesExist('hair_removed') && !inv.HasItem( 'kotw_helm_v3_1') && !inv.HasItem( 'kotw_visor_v3_1a') && !inv.HasItem( 'kotw_visor_v3_1') )
		{
			kotwAddAndEquipItem( 'kotw_helm_v3_1', witcher );
			kotwAddAndEquipItem( 'kotw_visor_v3_1', witcher );
			inv.AddAnItem( 'kotw_visor_v3_1a', 1);
		}
		
		if( FactsDoesExist( 'hair_removed' ) )
		{				
			if( !isHelmEquipped && !isVisorUp && !isVisorDown )
			{
				inv.MountItem( helm );
				inv.MountItem( visorDown );
			}
			else
			if( isHelmEquipped && isVisorDown ) 
			{ 
				inv.UnmountItem( visorDown );
				inv.MountItem( visorUp );
			} 
			else
			if( isHelmEquipped && isVisorUp ) 
			{ 
				kotwRemoveHelmItems(witcher);
				kotwToggleHairItem(true, witcher);
			}
		}
	}
}

class W3DLCShield extends W3ShieldUsableItem
{
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		var witcher : W3PlayerWitcher;
		
		super.OnSpawned(spawnData);
		
		witcher = GetWitcherPlayer();
		witcher.BlockAction(EIAB_Signs, 'dlcShield');
		witcher.AddBuffImmunity(EET_Stagger, 'dlcShield', false);
		witcher.AddBuffImmunity(EET_LongStagger, 'dlcShield', false);
	}
	
	event OnHidden( usedBy : CEntity )
	{
		var witcher : W3PlayerWitcher;
		
		witcher = GetWitcherPlayer();
		witcher.UnblockAction(EIAB_Signs, 'dlcShield');
		witcher.RemoveBuffImmunity(EET_Stagger, 'dlcShield');
		witcher.RemoveBuffImmunity(EET_LongStagger, 'dlcShield');
		DestroyProjectiles();
		
		super.OnHidden(usedBy);	
	}
	
	private var projArray : array<W3ArrowProjectile>;
	public function ProcessShieldParry( witcher : CR4Player, parryInfo : SParryInfo, optional proj : W3ArrowProjectile ) : bool
	{
		var position : Vector;
		var anims : array<name>;
		var projRot : EulerAngles;
		var guard, partialGuard : bool;
		var parryHeading, angle : float;
		var parryDir : EPlayerParryDirection;
		
		if( witcher.IsCurrentlyDodging() )
			return false;
		
		if( !proj )
			angle = AngleDistance(VecHeading(parryInfo.attacker.GetWorldPosition() - witcher.GetWorldPosition()), witcher.GetHeading());	
		else
			angle = AngleDistance(VecHeading(proj.GetWorldPosition() - witcher.GetWorldPosition()), witcher.GetHeading());	
		
		if( witcher.IsGuarded() && AbsF(angle) < 70 )
		{
			anims.PushBack('geralt_shield_block_1');
			anims.PushBack('geralt_shield_block_2');
			anims.PushBack('geralt_shield_block_3');
			guard = true;
		}
		else
		if( witcher.IsInCombatAction_Attack() && angle < 70 && angle > -30 )
		{
			anims.PushBack('geralt_shield_block_1');
			anims.PushBack('geralt_shield_block_2');
			partialGuard = true;
		}
		else
		if( angle < 110 && angle > 20 )
		{
			anims.PushBack('geralt_shield_block_3');
			partialGuard = true;
		}
		else return false;
		
		if( (guard || partialGuard) && witcher.HasStaminaToParry(parryInfo.attackActionName) )
		{
			parryHeading = witcher.GetParryHeading(parryInfo, parryDir) ;
			
			witcher.ActionPlaySlotAnimationAsync('PLAYER_SLOT', anims[RandRange(anims.Size(),0)], 0.2, 0.3);
			witcher.SetBehaviorVariable('parryDirection', (float)((int)(parryDir)));
			witcher.SetBehaviorVariable('parryDirectionOverlay', (float)((int)(parryDir)));
			witcher.SetBehaviorVariable('parryType', witcher.ChooseParryTypeIndex(parryInfo));
			
			witcher.OnCombatActionStart();
			witcher.ClearCustomOrientationInfoStack();
			witcher.SetSlideTarget(parryInfo.attacker);
			witcher.SetCustomRotation('Parry', parryHeading, 1080.f, 0.1f, false);
			witcher.IncDefendCounter();
			
			if( parryInfo.attackActionName != 'attack_heavy' )
				PlayEffect('light_block');
			else
				PlayEffect('heavy_block');
			
			if( proj )
			{
				proj.StopProjectile();
				proj.StopActiveTrail();
				projRot.Pitch = RandRange(15,-5);
				projRot.Yaw = ClampF(180 + angle, 155, 205);
				projRot.Roll = RandRange(360,1);
				position.Z = RandRangeF(0.5, -0.2);
				if( position.Z > 0 )
					position.X = RandRangeF(0.27, -0.1);
				else
					position.X = RandRangeF(0.12, -0.04);
				position.Y = RandRangeF(-0.08, -0.14);
				proj.CreateAttachment(this,, position, projRot);
				AddProjectile(proj);
				witcher.AddTimer('DestroyProj', 300, false,,,, true);
			}
		}
		else
		{
			witcher.AddEffectDefault(EET_Stagger, parryInfo.attacker, "Parry");
		}
		
		return true;
	}
	
	public function AddProjectile( proj : W3ArrowProjectile )
	{
		projArray.PushBack(proj);
	}
	
	public function DestroyProjectiles()
	{
		var i : int;
		
		for(i=0; i<projArray.Size(); i+=1)
			projArray[i].Destroy();
	}
}

class W3ShieldUsableItemDLC extends W3UsableItem
{
	editable var factAddedOnUse : string;
	editable var factValue : int;
	editable var factTimeValid : int;
	editable var removeFactOnHide : bool;
	
	var i : int;
	
	event OnUsed( usedBy : CEntity )
	{
		for(i=0; i<blockedActions.Size(); i+=1)
		{
			thePlayer.BlockAction(blockedActions[i], 'UsableItem');
		}
		FactsAdd(factAddedOnUse, factValue, factTimeValid);
	}
	
	event OnHidden( hiddenBy : CEntity )
	{
		if(removeFactOnHide)
		{
			FactsRemove(factAddedOnUse);		
		}
	}
}

exec function hidehair()
{
	var inv : CInventoryComponent;
	var witcher : W3PlayerWitcher;
	var ids : array<SItemUniqueId>;
	var size : int;
	var i : int;

	witcher = GetWitcherPlayer();
	inv = witcher.GetInventory();

	ids = inv.GetItemsByCategory( 'hair' );
	size = ids.Size();
	
	if( size > 0 )
	{
		
		for( i = 0; i < size; i+=1 )
		{
			if(inv.IsItemMounted( ids[i] ) )
				inv.DespawnItem(ids[i]);
		}
		
	}
	
	ids.Clear();
}

exec function addWandererArmor()
{
	thePlayer.inv.AddAnItem('Wanderer Armor',  1);
	thePlayer.inv.AddAnItem('Wanderer Boots',  1);
	thePlayer.inv.AddAnItem('Wanderer Pants',  1);
	thePlayer.inv.AddAnItem('Wanderer Gloves', 1);
}

exec function addWardenArmor()
{
	thePlayer.inv.AddAnItem('Warden Armor',  1);
	thePlayer.inv.AddAnItem('Warden Boots',  1);
	thePlayer.inv.AddAnItem('Warden Pants',  1);
	thePlayer.inv.AddAnItem('Warden Gloves', 1);
}

exec function addDLCShields(optional dontOpenInv : bool)
{
	thePlayer.inv.AddAnItem('Nilfgaardian Shield 1', 1);
			thePlayer.inv.AddAnItem('Nilfgaardian Shield 2', 1);
			thePlayer.inv.AddAnItem('Redanian Shield 1', 1);
			thePlayer.inv.AddAnItem('Temerian Shield 1', 1);
			thePlayer.inv.AddAnItem('Novigradian Shield 1', 1);
			thePlayer.inv.AddAnItem('Novigradian Shield 2', 1);					
			thePlayer.inv.AddAnItem('Rivian Shield 1', 1);
			thePlayer.inv.AddAnItem('Ravix Shield 1', 1);
			thePlayer.inv.AddAnItem('Velen Shield 1', 1);	
			thePlayer.inv.AddAnItem('Velen Shield 2', 1);	
			thePlayer.inv.AddAnItem('Velen Shield 3', 1);
			thePlayer.inv.AddAnItem('Velen Shield 4', 1);	
			thePlayer.inv.AddAnItem('Velen Shield 5', 1);
			thePlayer.inv.AddAnItem('Flaming Rose Shield 1', 1);	
			thePlayer.inv.AddAnItem('Ofieri Shield 1', 1);	
			thePlayer.inv.AddAnItem('Olgierd Shield 1', 1);	
			thePlayer.inv.AddAnItem('Borsodi Shield 1', 1);
			thePlayer.inv.AddAnItem('Skellige Shield 1', 1);
			thePlayer.inv.AddAnItem('Skellige Shield 2', 1);	
			thePlayer.inv.AddAnItem('Skellige Shield 3', 1);	
			thePlayer.inv.AddAnItem('Skellige Shield 4', 1);	
			thePlayer.inv.AddAnItem('Skellige Shield 5', 1);	
			thePlayer.inv.AddAnItem('Skellige Shield 6', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 1', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 2', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 3', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 4', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 5', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 6', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 7', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 8', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 9', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 10', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 11', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 12', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 13', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 14', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 15', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 16', 1);	
			thePlayer.inv.AddAnItem('Toussaint Shield 17', 1);	
			thePlayer.inv.AddAnItem('Toussaint Shield 18', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 19', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 20', 1);
			thePlayer.inv.AddAnItem('Toussaint Shield 21', 1);	
			thePlayer.inv.AddAnItem('Toussaint Shield 22', 1);	
			thePlayer.inv.AddAnItem('Toussaint Shield 23', 1);
			thePlayer.inv.AddAnItem('Imlerith Shield 1', 1);			
	
	if(!dontOpenInv)
	{
		theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
	}
}

exec function addDLCArmors(optional dontOpenInv : bool)
{
	thePlayer.inv.AddAnItem('Nilfgaardian Armor 1', 1);
			thePlayer.inv.AddAnItem('Nilfgaardian Boots 1', 1);
			thePlayer.inv.AddAnItem('Nilfgaardian Pants 1', 1);
			thePlayer.inv.AddAnItem('Nilfgaardian Gloves 1', 1);
			thePlayer.inv.AddAnItem('Nilfgaardian Armor 2', 1);
			thePlayer.inv.AddAnItem('Nilfgaardian Pants 2', 1);
			thePlayer.inv.AddAnItem('Nilfgaardian Helmet 1', 1);
			thePlayer.inv.AddAnItem('Nilfgaardian Helmet 2', 1);				
	
	if(!dontOpenInv)
	{
		theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
	}
}

exec function addDLCHoods(optional dontOpenInv : bool)
{
	thePlayer.inv.AddAnItem('Hood Red', 1);
			thePlayer.inv.AddAnItem('Hood Blue', 1);
			thePlayer.inv.AddAnItem('Hood Black', 1);
			thePlayer.inv.AddAnItem('Hood Green', 1);
			thePlayer.inv.AddAnItem('Hood Moss', 1);
			thePlayer.inv.AddAnItem('Hood Cream', 1);
			thePlayer.inv.AddAnItem('Hood Grey', 1);
			thePlayer.inv.AddAnItem('Hood White', 1);
			thePlayer.inv.AddAnItem('Hood Purple', 1);
			thePlayer.inv.AddAnItem('Hood Brown', 1);
			thePlayer.inv.AddAnItem('Hood Turquoise', 1);
			thePlayer.inv.AddAnItem('Hood Gold', 1);			
			
	if(!dontOpenInv)
	{
		theGame.RequestMenuWithBackground( 'InventoryMenu', 'CommonMenu' );
	}
}

exec function kotwAddArmor()
{
	var witcher : W3PlayerWitcher = GetWitcherPlayer();
	
	witcher.inv.AddAnItem( 'kotw_armor_v1_1' );
	witcher.inv.AddAnItem( 'kotw_boots_v1_1' );
	witcher.inv.AddAnItem( 'kotw_gloves_v1_1' );
	witcher.inv.AddAnItem( 'kotw_legs_v1_1' );
	witcher.inv.AddAnItem( 'kotw_helm_v1_1_usable' );
}

exec function kotwAddArmor2()
{
	var witcher : W3PlayerWitcher = GetWitcherPlayer();
	
	witcher.inv.AddAnItem( 'kotw_armor_v2_1' );
	witcher.inv.AddAnItem( 'kotw_boots_v2_1' );
	witcher.inv.AddAnItem( 'kotw_gloves_v2_1' );
	witcher.inv.AddAnItem( 'kotw_legs_v2_1' );
	witcher.inv.AddAnItem( 'kotw_helm_v2_1_usable' );
}

exec function kotwAddArmor3()
{
	var witcher : W3PlayerWitcher = GetWitcherPlayer();
	
	witcher.inv.AddAnItem( 'kotw_armor_v3_1' );
	witcher.inv.AddAnItem( 'kotw_boots_v3_1' );
	witcher.inv.AddAnItem( 'kotw_gloves_v3_1' );
	witcher.inv.AddAnItem( 'kotw_legs_v3_1' );
	witcher.inv.AddAnItem( 'kotw_helm_v3_1_usable' );
}

exec function kotwAddSchematics()
{
	var witcher : W3PlayerWitcher = GetWitcherPlayer();
	
	witcher.inv.AddAnItem('Gothic armor schematic');
	witcher.inv.AddAnItem('Gothic boots schematic');
	witcher.inv.AddAnItem('Gothic pants schematic');
	witcher.inv.AddAnItem('Gothic gloves schematic');
	
	witcher.inv.AddAnItem('Meteorite armor schematic');
	witcher.inv.AddAnItem('Meteorite boots schematic');
	witcher.inv.AddAnItem('Meteorite pants schematic');
	witcher.inv.AddAnItem('Meteorite gloves schematic');
	
	witcher.inv.AddAnItem('Dimeritium armor schematic');
	witcher.inv.AddAnItem('Dimeritium boots schematic');
	witcher.inv.AddAnItem('Dimeritium pants schematic');
	witcher.inv.AddAnItem('Dimeritium gloves schematic');
	
	witcher.inv.AddAnItem('Gothic light armor schematic');
	witcher.inv.AddAnItem('Gothic light boots schematic');
	witcher.inv.AddAnItem('Gothic light pants schematic');
	witcher.inv.AddAnItem('Gothic light gloves schematic');
	
	witcher.inv.AddAnItem('Meteorite light armor schematic');
	witcher.inv.AddAnItem('Meteorite light boots schematic');
	witcher.inv.AddAnItem('Meteorite light pants schematic');
	witcher.inv.AddAnItem('Meteorite light gloves schematic');
	
	witcher.inv.AddAnItem('Dimeritium light armor schematic');
	witcher.inv.AddAnItem('Dimeritium light boots schematic');
	witcher.inv.AddAnItem('Dimeritium light pants schematic');
	witcher.inv.AddAnItem('Dimeritium light gloves schematic');
	
	witcher.inv.AddAnItem('Gothic helmet schematic');
	witcher.inv.AddAnItem('Meteorite helmet schematic');
	witcher.inv.AddAnItem('Dimeritium helmet schematic');
}

exec function fixhelmets()
{
	var i : int;
	var witcher : W3PlayerWitcher = GetWitcherPlayer();
	var ids : array< SItemUniqueId >;
	
	ids = witcher.inv.GetItemsByTag( 'kotwHelm' );
	FactsRemove( "hair_removed" );
	for(i=0; i<ids.Size(); i+= 1)
	{
		witcher.inv.RemoveItem( ids[i] );
		witcher.SetCurrentHelmet(EIST_Undefined);
	}
}

exec function addtestingstuff()
{
	var witcher : W3PlayerWitcher = GetWitcherPlayer();
	
	witcher.AddAndEquipItem('Bear School steel sword 4');
	witcher.AddAndEquipItem('Wanderer Armor');
	witcher.AddAndEquipItem('Wanderer Boots');
	witcher.AddAndEquipItem('Wanderer Pants');
	witcher.AddAndEquipItem('Warden Gloves');
	witcher.AddAndEquipItem('Hood Black');
}

exec function spawnfrompath(path : string, optional quantity : int, optional distance : float, optional isHostile : bool )
{
    var ent : CEntity;
    var pos, cameraDir, player, posFin, normal, posTemp : Vector;
    var rot : EulerAngles;
    var i, sign : int;
    var s,r,x,y : float;
    var template : CEntityTemplate;
    var resourcePath    : string;
    quantity = Max(quantity, 1);
    
    rot = thePlayer.GetWorldRotation();    
    rot.Yaw += 180;        
    
    
    cameraDir = theCamera.GetCameraDirection();
    
    if( distance == 0 ) distance = 3; 
    cameraDir.X *= distance;    
    cameraDir.Y *= distance;
    
    
    player = thePlayer.GetWorldPosition();
    
    
    pos = cameraDir + player;    
    pos.Z = player.Z;
    
    
    posFin.Z = pos.Z;            
    s = quantity / 0.2;            
    r = SqrtF(s/Pi());
    
    
    template = (CEntityTemplate)LoadResource(path,true);

    for(i=0; i<quantity; i+=1)
    {        
        x = RandF() * r;            
        y = RandF() * (r - x);        
        
        if(RandRange(2))                    
            sign = 1;
        else
            sign = -1;
            
        posFin.X = pos.X + sign * x;    
        
        if(RandRange(2))                    
            sign = 1;
        else
            sign = -1;
            
        posFin.Y = pos.Y + sign * y;    
        
            if(theGame.GetWorld().StaticTrace( posFin + Vector(0,0,5), posFin - Vector(0,0,5), posTemp, normal ))
            {
                posFin = posTemp;
            }
            
            ent = theGame.CreateEntity(template, posFin, rot);
            
        if( isHostile )
        {
            ((CActor)ent).SetTemporaryAttitudeGroup( 'hostile_to_player', AGP_Default );
        }
    }
}

exec function wtf()
{
	theGame.GetGuiManager().ShowNotification(GetLocStringByKeyExt("skill_desc_bear_set_ability1"));
}