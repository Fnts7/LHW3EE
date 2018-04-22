
struct SAlchemyItems
{
	var recipe : SAlchemyRecipe;
	var quantity : int;
	var mutagen : name;
	var nigredo, rubedo, albedo : array<name>;
}

class W3EEAlchemyExtender
{
	private var alchemyBrewingList : array<SAlchemyItems>;
	private var playerWitcher : W3PlayerWitcher;
	private var wasBrewingInterrupted : bool;
	private var alchemyManager : W3AlchemyManager;
	
	public var totalBrewTime : float;
	public var primarySubstances : array<SAlchemyRecipe>;
	public var mutagens : array<SAlchemyRecipe>;
	
	public var minPrimaryIngredients : int;
		default minPrimaryIngredients  = 3;

	public function Initialize( player : W3PlayerWitcher ) : void
	{
		StartInitialSetup(player);
	}
	
	public function GetIsItemTypeModified( recipe : SAlchemyRecipe ) : bool
	{
		if (recipe.cookedItemType == EACIT_Potion || recipe.cookedItemType == EACIT_Bomb || recipe.cookedItemType == EACIT_Substance || recipe.cookedItemType == EACIT_Alcohol || recipe.cookedItemType == EACIT_MutagenPotion || recipe.cookedItemType == EACIT_Oil || recipe.cookedItemType == EACIT_Edible)
			return true;
		
		return false;	
	}
	
	private function StartInitialSetup( player : W3PlayerWitcher )
	{
		playerWitcher = player;
		CampfireManager().Init(playerWitcher);
		InitializePrimarySubstanceRecipes();
		InitializeMutagenRecipes();
		InitializeModdedSkills(playerWitcher);
		AddOilTags(playerWitcher.inv);
		alchemyBrewingList.Clear();
		
		if( !FactsQuerySum("primer_initialized") )
		{
			playerWitcher.AddAlchemyRecipe('Recipe for Aether', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for Hydragenum', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for Rebis', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for Quebrith', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for Vermilion', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for Vitriol', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for Clearing Potion', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for White Gull 1', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for Tawny Owl 1', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for Black Blood 1', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for Blizzard 1', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for Full Moon 1', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for Golden Oriole 1', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for Killer Whale 1', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for Maribor Forest 1', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for Petris Philtre 1', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for Thunderbolt 1', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for White Honey 1', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for White Raffard Decoction 1', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for Alcohest 1', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for Grapeshot 1', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for Samum 1', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for Beast Oil 1', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for Cursed Oil 1', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for Hanged Man Venom 1', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for Hybrid Oil 1', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for Insectoid Oil 1', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for Magicals Oil 1', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for Necrophage Oil 1', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for Specter Oil 1', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for Vampire Oil 1', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for Draconide Oil 1', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for Ogre Oil 1', true, true);
			playerWitcher.AddAlchemyRecipe('Recipe for Relic Oil 1', true, true);
			NormalizeSingleItems(playerWitcher);
			FactsAdd("primer_initialized", 1, -1);
		}
	}
	
	public function AddOilTags( inv : CInventoryComponent )
	{
		var steelOils, silverOils : array<SItemUniqueId>;
		var i : int;
		
		steelOils = inv.GetItemsByTag('SteelOil');
		silverOils = inv.GetItemsByTag('SilverOil');
		
		for(i=0; i<steelOils.Size(); i+=1)
			if( !inv.ItemHasTag(steelOils[i], 'SilverOil' ) )
				inv.AddItemTag(steelOils[i], 'SilverOil');
		
		for(i=0; i<silverOils.Size(); i+=1)
			if( !inv.ItemHasTag(silverOils[i], 'SteelOil') )
				inv.AddItemTag(silverOils[i], 'SteelOil');
	}
	
	public function AddOilTagsOnCook( oilID : SItemUniqueId, inv : CInventoryComponent )
	{
		if( !inv.ItemHasTag(oilID, 'SilverOil' ) )
			inv.AddItemTag(oilID, 'SilverOil');
		
		if( !inv.ItemHasTag(oilID, 'SteelOil') )
			inv.AddItemTag(oilID, 'SteelOil');
	}
	
	// ------ Potion Count Handling ------ //
	
	public function GetItemMaxAmmo( item : SItemUniqueId ) : int
	{
		if( playerWitcher.inv.IsItemOil(item) )
			return Options().GetMaxOilCount();
		else
		if( playerWitcher.inv.IsItemPotion(item) )
			return Options().GetMaxPotionCount();		
		else
		if( playerWitcher.inv.IsItemBomb(item) )
			return Options().GetMaxBombCount();
		
		return playerWitcher.inv.SingletonItemGetMaxAmmo(item);
	}
	
	public function GetIsAmmoMaxed( recipe : SAlchemyRecipe ) : bool
	{
		var itemID : array<SItemUniqueId>;		
		
		itemID = playerWitcher.inv.GetItemsIds(recipe.cookedItemName);		
		if( playerWitcher.inv.SingletonItemGetAmmo(itemID[0]) && (playerWitcher.inv.SingletonItemGetAmmo(itemID[0]) == GetItemMaxAmmo(itemID[0]) ) )
			return true;
		
		return false;
	}	
	
	public function GetBrewingQuantity( recipe : SAlchemyRecipe, isDistilling : bool ) : int
	{
		var min, max : SAbilityAttributeValue;
		var dm : CDefinitionsManagerAccessor;
		var i, quantity : int;
		
		dm = theGame.GetDefinitionsManager();
		if( GetIsItemTypeModified(recipe) )
		{
			if( recipe.cookedItemType == EACIT_Potion || recipe.cookedItemType == EACIT_Oil )
			{
				quantity = recipe.cookedItemQuantity + Options().GetAlchemyYield() - 1;
				if( playerWitcher.IsSetBonusActive(EISB_RedWolf_2) && RandRange(100, 0) <= 30 )
					quantity += 1;
			}
			else
				quantity = recipe.cookedItemQuantity;
				
			if( recipe.cookedItemType == EACIT_Bomb && playerWitcher.GetSkillLevel(S_Alchemy_s08) )
			{
				if( playerWitcher.GetSkillLevel(S_Alchemy_s08) == 1 && RandRange(100, 1) <= 50 )
					quantity += 1;
				else
				if( playerWitcher.GetSkillLevel(S_Alchemy_s08) >= 2 )
					quantity += 1;
					
				if( playerWitcher.GetSkillLevel(S_Alchemy_s08) == 3 && RandRange(100, 1) <= 50 )
					quantity += 1;
			}
			else
			if( isDistilling )
				quantity = CalculateDistillationYield(recipe.recipeName);
			else
			if( playerWitcher.HasBuff(EET_AlchemyTable) && (recipe.cookedItemType == EACIT_Potion || recipe.cookedItemType == EACIT_Oil) )
				quantity += 1;
				
			if( recipe.cookedItemName == 'White Gull 1' )
			{
				for(i=recipe.requiredIngredients.Size() - 1; i>=0; i-=1)
				{
					if( recipe.requiredIngredients[i].itemName == 'Alcohest' )
						quantity += 1;
				}
			}
		}
		else
		{
			dm.GetItemAttributeValueNoRandom(recipe.cookedItemName, true, 'ammo', min, max);
			quantity = (int)CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
			
			if( !quantity )
				quantity = recipe.cookedItemQuantity;
		}
		
		return quantity;
	}
	
	public function GetSideEffects( recipe : SAlchemyRecipe, mutagens : array<name>, isDistilling : bool ) : name
	{
		var mutIndex : int;
		if( isDistilling && GetIsItemTypeModified(recipe) )
		{
			if( playerWitcher.GetSkillLevel(S_Alchemy_s04) && CalculateSideEffectsChance(playerWitcher.GetSkillLevel(S_Alchemy_s04)) )
			{
				mutIndex = RandRange(mutagens.Size() + 1, 0);
				return mutagens[mutIndex];
			}
		}
		return '';
	}
	
	// ------ Brewing Handling ------ //
	
	public function RemoveRequiredIngredients( recipe : SAlchemyRecipe, isDistilling : bool )
	{
		var dm : CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();		
		var isIngredientUniqueMutagen, isDecoctionRecipe : bool;
		var i : int;
		
		for(i = recipe.requiredIngredients.Size() - 1; i >= 0 ; i -= 1)
		{
			isIngredientUniqueMutagen = dm.ItemHasTag(recipe.requiredIngredients[i].itemName, 'mod_alchemy_table');
			isDecoctionRecipe = recipe.cookedItemType == EACIT_MutagenPotion;
			
			if( recipe.requiredIngredients[i].itemName == 'Soltis Vodka' )
				continue;
			else
			if( isDistilling && IsIngredientBottle(recipe.requiredIngredients[i].itemName) )
				continue;
			else
			/*if( isDecoctionRecipe && isIngredientUniqueMutagen )
				continue;
			else*/
				Equipment().RemoveItemByNameForCrafting(recipe.requiredIngredients[i].itemName, recipe.requiredIngredients[i].quantity);
			
			if( dm.ItemHasTag(recipe.requiredIngredients[i].itemName, 'StrongAlcohol') && recipe.requiredIngredients[i].itemName != 'Empty bottle' )
				playerWitcher.inv.AddAnItem('Empty bottle', recipe.requiredIngredients[i].quantity);
		}
	}
	
	public function AddToBrewingList( recipe : SAlchemyRecipe, isDistilling : bool, mutagen : name, nigredo, rubedo, albedo : array<name> )
	{
		var alchemyListItem : SAlchemyItems;
		
		alchemyListItem.recipe = recipe;
		alchemyListItem.quantity = GetBrewingQuantity(recipe, isDistilling);
		alchemyListItem.nigredo = nigredo;
		alchemyListItem.rubedo = rubedo;
		alchemyListItem.albedo = albedo;
		alchemyListItem.mutagen = mutagen;
		RemoveRequiredIngredients(recipe, isDistilling);
		alchemyBrewingList.PushBack(alchemyListItem);
	}
	
	public function FinishBrewing()
	{
		var i : int;
		
		alchemyManager = new W3AlchemyManager in this;
		alchemyManager.Init();
		for(i=0; i<alchemyBrewingList.Size(); i+=1)
		{
			alchemyManager.CookItem(alchemyBrewingList[i].recipe, alchemyBrewingList[i].quantity, alchemyBrewingList[i].nigredo, alchemyBrewingList[i].rubedo, alchemyBrewingList[i].albedo);
			playerWitcher.inv.AddAnItem(alchemyBrewingList[i].mutagen, 1);
		}
		playerWitcher.SoundEvent("gui_alchemy_brew");
		alchemyBrewingList.Clear();
		delete alchemyManager;
	}
	
	public function ManageBrewingDuration( recipe : SAlchemyRecipe, distillation : bool )
	{
		if( distillation )
			totalBrewTime += Options().GetDistillLength();
		else
			totalBrewTime += alchemyBrewingList[alchemyBrewingList.Size()-1].recipe.requiredIngredients.Size() * alchemyBrewingList[alchemyBrewingList.Size()-1].quantity * Options().GetAlchemyLength();
	}
	
	public function GetBrewingDurationAlchemist( recipe : SAlchemyRecipe, quantity : int, distillation : bool ) : float
	{
		var brewTime : float;
		
		if( distillation )
			return Options().GetDistillLength();
		else
		{
			brewTime = recipe.requiredIngredients.Size() * quantity * Options().GetAlchemyLength();
			return brewTime;
		}
	}
	
	public function StartBrewingTimer() : void
	{
		playerWitcher.AddTimer('MeditationStartBrewing', 0.01f, false,,,, true);
	}
	
	public function GetBrewingDuration() : float
	{
		return (totalBrewTime * 60 * theGame.GetHoursPerMinute());
	}
	
	public function SetBrewingDuration( dur : float )
	{
		totalBrewTime = dur / (60 * theGame.GetHoursPerMinute());
	}
	
	public function GetBrewingInterrupted() : bool
	{
		return wasBrewingInterrupted;
	}
	
	public function SetBrewingInterrupted( b : bool )
	{
		wasBrewingInterrupted = b;
	}
	
	public function ResetBrewingDuration()
	{
		totalBrewTime = 0;
	}
	
	// ------ Substance Handling ------ //
	
	public function IsIngredientBottle( ingredientName : name ) : bool
	{
		return ( ingredientName == 'Bottle' || ingredientName == 'Empty vial' || ingredientName == 'Empty bottle' );
	}
	
	public function GetIsDistillingPrimarySubstance( recipe : name ) : bool
	{
		var i : int;
		
		for(i = primarySubstances.Size()-1; i>=0; i-=1)
		{
			if( primarySubstances[i].recipeName == recipe )
				return true;
		}
		return false;
	}
	
	private function CalculateDistillationYield( recipe : name ) : int
	{	
		var fx, x : float;
		
		x = RandRangeF(1.f, 0.f);
		fx = (PowF(x, 2) + 0.86f) * (minPrimaryIngredients * 2.1f);
		
		return RoundMath(fx);
	}
	
	public function GetSecondarySubstance( ingredients : array<SItemParts>, nigredo, rubedo, albedo : array<name> ) : name
	{
		var i, ingredientCount, nigredoCount, rubedoCount, albedoCount : int;
		var dm : CDefinitionsManagerAccessor;
		
		dm = theGame.GetDefinitionsManager();
		for(i=ingredients.Size()-1; i>=0; i-=1)
		{
			if( nigredo.Contains(ingredients[i].itemName) )
				nigredoCount += 1;
			else
			if( rubedo.Contains(ingredients[i].itemName) )
				rubedoCount += 1;
			else
			if( albedo.Contains(ingredients[i].itemName) )
				albedoCount += 1;
			if( !dm.ItemHasTag(ingredients[i].itemName, 'StrongAlcohol') && ingredients[i].itemName != 'Empty bottle' && ingredients[i].itemName != 'Bottle' && ingredients[i].itemName != 'Empty vial' )
				ingredientCount += 1;
		}
		
		if( ingredientCount )
		{
			if( nigredoCount == ingredientCount )
				return 'Nigredo';
			else
			if( rubedoCount == ingredientCount )
				return 'Rubedo';
			else
			if( albedoCount == ingredientCount )
				return 'Albedo';
		}
		
		return '';
	}
	
	public function GetPotionNameFromSubstance( itemToCook : name, substance : name ) : name
	{
		var potionName : string;
		var potions : array<name>;
		var dm : CDefinitionsManagerAccessor;
		var i : int;
		
		potionName = NameToString(itemToCook) + " " + NameToString(substance);
		dm = theGame.GetDefinitionsManager();
		potions = dm.GetItemsWithTag(substance);
		
		for(i=0; i<potions.Size(); i+=1)
		{
			if( NameToString(potions[i]) == potionName )
				return potions[i];
		}
		
 		return itemToCook;
	}
	
	private function CalculateSideEffectsChance( chance : int ) : bool
	{	
		var results : int;
		
		results = RandRange(100, 1);
		if( results <= 10 * chance )
			return true;
		return false;
	}
	
	public function AddSecondarySubstanceEffects( potion : SItemUniqueId )
	{
		var effectParams : SCustomEffectParams;
		
		if( playerWitcher.inv.ItemHasTag(potion, 'Albedo') )
		{
			effectParams.customAbilityName = 'AlbedoDominanceEffect';
			effectParams.effectType = EET_AlbedoDominance;
			effectParams.duration = 240.0f;
		}
		else
		if( playerWitcher.inv.ItemHasTag(potion, 'Rubedo') )			
		{
			effectParams.customAbilityName = 'RubedoDominanceEffect';
			effectParams.effectType = EET_RubedoDominance;
			effectParams.duration = 960.0f;
		}
		else
		if( playerWitcher.inv.ItemHasTag(potion, 'Nigredo') )
		{
			effectParams.customAbilityName = 'NigredoDominanceEffect';
			effectParams.effectType = EET_NigredoDominance;
			effectParams.duration = 480.0f;
		}
		else return;
		
		effectParams.creator = playerWitcher;
		effectParams.sourceName = "drank_potion";
		playerWitcher.AddEffectCustom(effectParams);
	}	
	
	private function InitializePrimarySubstanceRecipes() : void
	{
		var i : int;				
		
		primarySubstances.Resize(9);		
		primarySubstances[0].recipeName = 'Recipe for Aether';
		primarySubstances[1].recipeName = 'Recipe for Hydragenum';		
		primarySubstances[2].recipeName = 'Recipe for Rebis';
		primarySubstances[3].recipeName = 'Recipe for Quebrith';
		primarySubstances[4].recipeName = 'Recipe for Vermilion';
		primarySubstances[5].recipeName = 'Recipe for Vitriol';
		primarySubstances[6].recipeName = 'Recipe for Nigredo';
		primarySubstances[7].recipeName = 'Recipe for Albedo';
		primarySubstances[8].recipeName = 'Recipe for Rubedo';
		
		for(i=0; i<primarySubstances.Size(); i+=1)
		{
			primarySubstances[i].requiredIngredients.Resize(3);
			primarySubstances[i].requiredIngredients[0].itemName = 'Alcohest';
			primarySubstances[i].requiredIngredients[2].itemName = 'Empty bottle';
			primarySubstances[i].requiredIngredients[0].quantity = 1;
			primarySubstances[i].requiredIngredients[2].quantity = 3;
			primarySubstances[i].requiredIngredients[1].quantity = minPrimaryIngredients * 2;
		}
		
		primarySubstances[0].requiredIngredients[1].itemName = 'Berbercane fruit';	
		primarySubstances[1].requiredIngredients[1].itemName = 'Mistletoe';
		primarySubstances[2].requiredIngredients[1].itemName = 'Han';
		primarySubstances[3].requiredIngredients[1].itemName = 'Verbena';
		primarySubstances[4].requiredIngredients[1].itemName = 'Wolfsbane';
		primarySubstances[5].requiredIngredients[1].itemName = 'White myrtle';		
		primarySubstances[6].requiredIngredients[1].itemName = 'Sulfur';		
		primarySubstances[7].requiredIngredients[1].itemName = 'Bryonia';		
		primarySubstances[8].requiredIngredients[1].itemName = 'Cortinarius';		
	}

	private function InitializeMutagenRecipes() : void
	{
		var i : int;
		
		mutagens.Resize(6);
		mutagens[0].recipeName = 'Recipe for Mutagen red';
		mutagens[1].recipeName = 'Recipe for Mutagen green';
		mutagens[2].recipeName = 'Recipe for Mutagen blue';
		mutagens[3].recipeName = 'Recipe for Greater mutagen red';
		mutagens[4].recipeName = 'Recipe for Greater mutagen green';
		mutagens[5].recipeName = 'Recipe for Greater mutagen blue';
		
		for(i=0; i<mutagens.Size(); i+=1)
		{
			mutagens[i].requiredIngredients.Resize(2);
			mutagens[i].requiredIngredients[0].itemName = 'Alcohest';
			mutagens[i].requiredIngredients[0].quantity = 1;
			mutagens[i].requiredIngredients[1].quantity = 3;
		}
		
		mutagens[0].requiredIngredients[1].itemName = 'Lesser mutagen red';
		mutagens[1].requiredIngredients[1].itemName = 'Lesser mutagen green';
		mutagens[2].requiredIngredients[1].itemName = 'Lesser mutagen blue';
		mutagens[3].requiredIngredients[1].itemName = 'Mutagen red';
		mutagens[4].requiredIngredients[1].itemName = 'Mutagen green';
		mutagens[5].requiredIngredients[1].itemName = 'Mutagen blue';		
	}
	
	// ------ Skill Handling ------ //

	public function InitializeModdedSkills( geralt : W3PlayerWitcher )
	{
		var skillLevel : int;	
		
		skillLevel = playerWitcher.GetSkillLevel(S_Alchemy_s02);
		if( skillLevel )
			OnSkillUpdated(S_Alchemy_s02, skillLevel, geralt);
		else
			playerWitcher.RemoveAbilityAll('alchemy_potionduration');
		
		skillLevel = playerWitcher.GetSkillLevel(S_Alchemy_s18);
		if( skillLevel )
			OnSkillUpdated(S_Alchemy_s18, skillLevel, geralt);
		else
			playerWitcher.RemoveAbilityAll('alchemy_s18');		
	}
	
	private var maximumToxicity : float;
	public function OnSkillUpdated( skill : ESkill, skillLevel : int, optional geralt : W3PlayerWitcher ) : void
	{
		var skillMult : float;
		var min, max : SAbilityAttributeValue;
		var dm : CDefinitionsManagerAccessor;
		var attributes : array<name>;
		
		dm = theGame.GetDefinitionsManager();
		if( skill == S_Alchemy_s02 )
		{
			playerWitcher.RemoveAbilityAll('alchemy_potionduration');
			playerWitcher.AddAbilityMultiple('alchemy_potionduration', RoundMath(33.3f * skillLevel));
			playerWitcher.RecalcPotionsDurations();
		}
		else
		if( skill == S_Alchemy_s18 )
		{
			dm.GetAbilityAttributes('alchemy_s18', attributes);
			dm.GetAbilityAttributeValue('alchemy_s18', attributes[0], max, min);
			
			if (min.valueAdditive && min.valueAdditive != 1.f)
				skillMult = 0.1f / min.valueAdditive;
			else
				skillMult = 0.1f;
			
			playerWitcher.RemoveAbilityAll('alchemy_s18');
			playerWitcher.AddAbilityMultiple('alchemy_s18', (int)(playerWitcher.GetStatMax(BCS_Toxicity) * skillLevel * skillMult));
			maximumToxicity = playerWitcher.GetStatMax(BCS_Toxicity);
		}
	}
	
	public function ResetSkills()
	{
		playerWitcher.RemoveAbilityAll('alchemy_potionduration');		
		playerWitcher.RemoveAbilityAll('alchemy_s18');
	}
	
	public function GetHasToxicityChanged() : bool
	{
		return playerWitcher.GetStatMax(BCS_Toxicity) != maximumToxicity;
	}
	
	private function NormalizeSingleItems( playerWitcher : W3PlayerWitcher ) : void
	{
		var items :  array<SItemUniqueId>;
		var i : int;
		
		playerWitcher.inv.GetAllItems(items);
		for(i=0; i<items.Size(); i+=1)
		{
			if( playerWitcher.inv.IsItemOil(items[i]) )
				playerWitcher.inv.SetItemModifierInt(items[i],'ammo_current', 1);
			else
			if( playerWitcher.inv.IsItemPotion(items[i]) || playerWitcher.inv.IsItemBomb(items[i]) )
			{
				if( !playerWitcher.inv.GetItemModifierInt(items[i], 'ammo_current') )
					playerWitcher.inv.SetItemModifierInt(items[i],'ammo_current', 1);
			}
		}	
	}
}