/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/




struct SItemAttribute
{
	var attributeName	: name;
	var min, max		: float;
};

class CR4AlchemyMenu extends CR4ListBaseMenu
{	
	private var m_alchemyManager	: W3AlchemyManager;
	private var m_recipeList		: array< SAlchemyRecipe >;
	private var m_definitionsManager: CDefinitionsManagerAccessor;
	private var bCouldCraft			: bool;
	protected var _inv       		: CInventoryComponent;
	private var _playerInv			: W3GuiPlayerInventoryComponent;

	// W3EE - Begin
	private var alchemyMenuContext	: W3AlchemyMenuContext;
	private var originalRecipes		: array< SAlchemyRecipe >;
	private var m_npc	 			: CNewNPC;
	private var m_npcInventory		: CInventoryComponent;
	private var m_shopInvComponent	: W3GuiShopInventoryComponent;
	private var m_lastSelectedTag	: name;

	private var vitriol_color, rebis_color, aether_color, quebrith_color, hydragenum_color, vermilion_color, albedo_color, nigredo_color, rubedo_color : string;
	default vitriol_color		= "<font color=\"#1595b0\">";
	default rebis_color			= "<font color=\"#4db323\">";
	default aether_color		= "<font color=\"#7764a9\">";
	default quebrith_color		= "<font color=\"#be8728\">";
	default hydragenum_color	= "<font color=\"#b0b0b0\">";
	default vermilion_color		= "<font color=\"#d25212\">";
	default albedo_color		= "<font color=\"#e0e0e0\">";
	default nigredo_color		= "<font color=\"#4F4F4F\">";
	default rubedo_color		= "<font color=\"#C52C34\">";
	// W3EE - End
	
	private var m_fxSetCraftingEnabled	: CScriptedFlashFunction;
	private var m_fxSetCraftedItem 		: CScriptedFlashFunction;
	private var m_fxHideContent	 		: CScriptedFlashFunction;
	private var m_fxSetFilters			: CScriptedFlashFunction;
	private var m_fxSetPinnedRecipe		: CScriptedFlashFunction;
	
	default DATA_BINDING_NAME_SUBLIST	= "crafting.sublist.items";
	default DATA_BINDING_NAME_DESCRIPTION	= "alchemy.item.description";
	
	var itemsQuantity 						: array< int >;
	
	// W3EE - Begin
	private function CreateAlchemyMenuContext()
	{
		if( alchemyMenuContext )
			delete alchemyMenuContext;
		
		alchemyMenuContext = new W3AlchemyMenuContext in this;
		alchemyMenuContext.SetAlchemyMenuRef(this);
		ActivateContext(alchemyMenuContext);
	}
	// W3EE - End
	
	event  OnConfigUI()
	{	
		var commonMenu 			: CR4CommonMenu;
		var l_craftingFilters	: SCraftingFilters;
		var pinnedTag			: int;
		
		super.OnConfigUI();
		
		m_initialSelectionsToIgnore = 2;
		
		_inv = thePlayer.GetInventory();
		m_definitionsManager = theGame.GetDefinitionsManager();
		
		_playerInv = new W3GuiPlayerInventoryComponent in this;
		_playerInv.Initialize( _inv );
		
		// W3EE - Begin
		InitializeAlchemist();
		if( !CampfireManager().CanPerformAlchemy(isAlchemist) )
		{	
			showNotification(GetLocStringByKeyExt("menu_cannot_perform_action_now") );
		}
		
		theInput.RegisterListener(this,	'OnIngredientShiftAction', 'IngredientShift');
		
		CreateAlchemyMenuContext();
		InitIngredientLocks();
		// W3EE - End
		
		m_alchemyManager = new W3AlchemyManager in this;
		m_alchemyManager.Init();	
		m_recipeList     = m_alchemyManager.GetRecipes(false);
		
		// W3EE - Begin
		originalRecipes = m_recipeList;
		// W3EE - End
		
		m_fxSetCraftedItem = m_flashModule.GetMemberFlashFunction("setCraftedItem");
		m_fxSetCraftingEnabled = m_flashModule.GetMemberFlashFunction("setCraftingEnabled");
		m_fxHideContent = m_flashModule.GetMemberFlashFunction("hideContent");
		m_fxSetFilters = m_flashModule.GetMemberFlashFunction("SetFiltersValue");
		m_fxSetPinnedRecipe = m_flashModule.GetMemberFlashFunction("setPinnedRecipe");
		
		l_craftingFilters = GetWitcherPlayer().GetAlchemyFilters();
		m_fxSetFilters.InvokeSelfSixArgs(FlashArgString(GetLocStringByKeyExt("gui_panel_filter_has_ingredients")), FlashArgBool(l_craftingFilters.showCraftable), 
										 FlashArgString(GetLocStringByKeyExt("gui_panel_filter_elements_missing")), FlashArgBool(l_craftingFilters.showMissingIngre), 
		// W3EE - Begin
										 FlashArgString(GetLocStringByKeyExt("gui_panel_filter_already_crafted")), FlashArgBool(false));
		// W3EE - End
		
		commonMenu = (CR4CommonMenu)m_parentMenu;
		bCouldCraft = true;
		m_fxSetCraftingEnabled.InvokeSelfOneArg(FlashArgBool(bCouldCraft));
		pinnedTag = NameToFlashUInt(theGame.GetGuiManager().PinnedCraftingRecipe);
		m_fxSetPinnedRecipe.InvokeSelfOneArg(FlashArgUInt(pinnedTag));
		
		// W3EE - Begin
		SetAlchemyCategories();
		// W3EE - End
		
		PopulateData();
		
		SelectFirstModule();
		
		m_fxSetTooltipState.InvokeSelfTwoArgs( FlashArgBool( thePlayer.upscaledTooltipState ), FlashArgBool( true ) );
	}

	event  OnClosingMenu()
	{
		super.OnClosingMenu();
		theGame.GetGuiManager().SetLastOpenedCommonMenuName( GetMenuName() );
		
		// W3EE - Begin
		if( alchemyMenuContext )
		{
			alchemyMenuContext.Deactivate();
			delete alchemyMenuContext;
		}
		theInput.UnregisterListener(this, 'IngredientShift');
		// W3EE - End
	}

	event  OnCloseMenu() 
	{
		var commonMenu : CR4CommonMenu;
		
		commonMenu = (CR4CommonMenu)m_parentMenu;
		if(commonMenu)
		{
			commonMenu.ChildRequestCloseMenu();
		}
		
		theSound.SoundEvent( 'gui_global_quit' ); 
		CloseMenu();
	}

	event OnEntryRead( tag : name )
	{
		
		ShowSelectedItemInfo(selectedRecipe.recipeName);
		
	}
	
	event  OnStartCrafting()
	{
		// W3EE - Begin
		//OnPlaySoundEvent("gui_alchemy_brew");
		// W3EE - End
	}
	
	event OnCraftItem( tag : name )
	{
		CreateItem(FindRecipieID(tag));
		ShowSelectedItemInfo(tag);
	}
	
	event OnEntryPress( tag : name )
	{
	}
	
	event  OnCraftingFiltersChanged( showHasIngre : bool, showMissingIngre : bool, showAlreadyCrafted : bool )
	{
		GetWitcherPlayer().SetAlchemyFilters(showHasIngre, showMissingIngre, showAlreadyCrafted);
	}
	
	event  OnEmptyCheckListCloseFailed()
	{
		showNotification(GetLocStringByKeyExt("gui_missing_filter_error"));
		OnPlaySoundEvent("gui_global_denied");
	}
	
	event  OnChangePinnedRecipe( tag : name )
	{
		if (tag != '')
		{
			showNotification(GetLocStringByKeyExt("panel_shop_pinned_recipe_action"));
		}
		theGame.GetGuiManager().SetPinnedCraftingRecipe(tag);
	}

	// W3EE - Begin
	protected function HandleMenuLoaded() : void
	{
	}
	
	private var craftingException, previousException : EAlchemyExceptions;
	// W3EE - End
	event OnEntrySelected( tag : name ) 
	{
		
		var i : int;
		var uiState : W3TutorialManagerUIHandlerStateAlchemy;
		
		if (tag != '')
		{
			// W3EE - Begin
			m_fxHideContent.InvokeSelfOneArg(FlashArgBool(true));
			super.OnEntrySelected(tag);
			
			selectedRecipeIndex = FindRecipieID(tag);
			selectedRecipe = m_recipeList[selectedRecipeIndex];
			craftingException = m_alchemyManager.CanCookRecipe(selectedRecipe.recipeName,,isAlchemist);
			// W3EE - End
		}
		else
		{
			lastSentTag = '';
			currentTag = '';
			m_fxHideContent.InvokeSelfOneArg(FlashArgBool(false));
		}
		
		
		if(ShouldProcessTutorial('TutorialAlchemySelectRecipe'))
		{
			uiState = (W3TutorialManagerUIHandlerStateAlchemy)theGame.GetTutorialSystem().uiHandler.GetCurrentState();
			if(uiState)
				uiState.SelectedRecipe(tag, m_alchemyManager.CanCookRecipe(tag,,isAlchemist) == EAE_NoException);
		}
		
		
		
	}
	
	event  OnShowCraftedItemTooltip( tag : name )
	{
	}
		
	protected function ShowSelectedItemInfo( tag : name ):void
	{
		var recipe 				: SAlchemyRecipe;
		var l_DataFlashObject	: CScriptedFlashObject;
		var itemNameLoc			: string;
		var imgPath				: string;
		var canCraft			: bool;
		var itemType 			: EInventoryFilterType;
		var gridSize			: int;
		var itemName			: name;
		
		// W3EE - Begin
		var tooltip		: CScriptedFlashObject;
		var attributeList		: CScriptedFlashArray;
		var attributes			: array<SAttributeTooltip>;
		var attributeIndex, duration : int;
		var Null				: SItemUniqueId;
		// W3EE - End
		
		recipe = m_recipeList[FindRecipieID(tag)];
		itemName = recipe.cookedItemName;
		
		l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
		
		_playerInv.GetCraftedItemInfo(itemName, l_DataFlashObject);
		
		// W3EE - Begin
		attributeList = l_DataFlashObject.CreateFlashArray();		
		thePlayer.inv.GetItemStatsFromName(itemName, attributes);
		
		for(attributeIndex = attributes.Size() -1; attributeIndex >= 0; attributeIndex -= 1)
		{
			if (!attributes[attributeIndex].primaryStat)
			{
				tooltip = l_DataFlashObject.CreateFlashObject();
				tooltip.SetMemberFlashString("name",attributes[attributeIndex].attributeName);
				tooltip.SetMemberFlashString("color",attributes[attributeIndex].attributeColor);
				
				if (m_definitionsManager.ItemHasTag(itemName, 'Potion') )
					duration = (int)GetWitcherPlayer().CalculatePotionDuration(Null, m_definitionsManager.ItemHasTag(itemName, 'Mutagen'), itemName);
				else 
					duration = RoundMath(attributes[attributeIndex].value);
				
				if (attributes[attributeIndex].originName == 'duration')
					tooltip.SetMemberFlashString("value", duration + GetLocStringByKeyExt("per_second") );				
				else if (attributes[attributeIndex].originName == 'toxicity')
					tooltip.SetMemberFlashString("value", RoundMath(attributes[attributeIndex].value) );
				else if (attributes[attributeIndex].percentageValue)			
					tooltip.SetMemberFlashString("value", "+" + RoundMath(attributes[attributeIndex].value * 100) + " %" );
				else
					tooltip.SetMemberFlashString("value", "+" + RoundMath(attributes[attributeIndex].value) );
				attributeList.PushBackFlashObject(tooltip);
			}
		}
		l_DataFlashObject.SetMemberFlashArray("attributesList", attributeList);
		// W3EE - End
		
		m_flashValueStorage.SetFlashObject("alchemy.menu.crafted.item.tooltip", l_DataFlashObject);
		
		itemNameLoc = GetLocStringByKeyExt(_inv.GetItemLocalizedNameByName(itemName));
		imgPath = m_definitionsManager.GetItemIconPath(itemName);
		canCraft = m_alchemyManager.CanCookRecipe(recipe.recipeName,,isAlchemist) == EAE_NoException;
		itemType = m_definitionsManager.GetFilterTypeByItem(itemName);
		
		if (itemType == IFT_Weapons || itemType == IFT_Armors)
		{
			gridSize = 2;
		}
		else
		{
			gridSize = 1;
		}
		
		//---=== modFriendlyHUD ===---
		if (thePlayer.newCraftables.Contains(tag))
		{
			thePlayer.newCraftables.Remove(tag);
		}
		//---=== modFriendlyHUD ===---
		
		m_fxSetCraftedItem.InvokeSelfSixArgs(FlashArgUInt(NameToFlashUInt(recipe.recipeName)), FlashArgString(itemNameLoc), FlashArgString(imgPath), FlashArgBool(canCraft), FlashArgInt(gridSize), FlashArgString(""));
	}
	
	function CreateItem( recipeIndex : int )
	{
		var recipe			: SAlchemyRecipe;		
		var exception		: EAlchemyExceptions;
		var cookedItemName	: string;
		
		// W3EE - Begin
		var quantity : int;
		var isDistilling : bool;
		var bonusItem	: name;
		var bonusString : string;
		// W3EE - End
		
		recipe  = m_recipeList[ recipeIndex ];

		exception = EAE_CookNotAllowed;		
		
		LogChannel( 'Alchemy', "OnCreateItem - " + recipeIndex + " " + recipe.recipeName );
		// W3EE - Begin
		if( bCouldCraft && CampfireManager().CanPerformAlchemy(isAlchemist) )
		// W3EE - End
		{
			GetWitcherPlayer().StartInvUpdateTransaction();			
			
			// W3EE - Begin
			exception = m_alchemyManager.CanCookRecipe( recipe.recipeName,,isAlchemist );
			// W3EE - End
			if( exception == EAE_NoException )
			{
				// W3EE - Begin
				if( isAlchemist || Options().GetPerformAlchemyAnywhere() )
				{
					isDistilling = Alchemy().GetIsDistillingPrimarySubstance(recipe.recipeName);
					Alchemy().RemoveRequiredIngredients(recipe, isDistilling);
					
					quantity = Alchemy().GetBrewingQuantity(recipe, isDistilling);
					bonusItem = Alchemy().GetSideEffects(recipe, mutagens, isDistilling);
					if( bonusItem != '' )
						bonusString = "<br>" + GetLocStringByKeyExt("primer_side_effect_decr") + " " + bonusItem;
					
					GetWitcherPlayer().inv.AddAnItem(bonusItem, 1);
					m_alchemyManager.CookItem(recipe, quantity, nigredo, rubedo, albedo);
					GetWitcherPlayer().AdvanceTimeSeconds(RoundMath(Alchemy().GetBrewingDurationAlchemist(recipe, quantity, isDistilling) * 60));
				}
				else
				{
					isDistilling = Alchemy().GetIsDistillingPrimarySubstance(recipe.recipeName);
					bonusItem = Alchemy().GetSideEffects(recipe, mutagens, isDistilling);
					if( bonusItem != '' )
						bonusString = "<br>" + GetLocStringByKeyExt("primer_side_effect_decr") + " " + bonusItem;
					Alchemy().AddToBrewingList(recipe, isDistilling, bonusItem, nigredo, rubedo, albedo);
					Alchemy().ManageBrewingDuration(recipe, isDistilling);
					
					Alchemy().StartBrewingTimer();
				}
				// W3EE - End
				
				if (recipe.level > 1)
				{
					
					m_recipeList = m_alchemyManager.GetRecipes(false);
				}
				PopulateData();
				UpdateItemsById(recipeIndex);
				cookedItemName = GetLocStringByKeyExt(m_definitionsManager.GetItemLocalisationKeyName( recipe.cookedItemName ));
				// W3EE - Begin
				showNotification(GetLocStringByKeyExt("panel_crafting_successfully_crafted") + ": " + cookedItemName + bonusString);
				// W3EE - End
				OnPlaySoundEvent("gui_crafting_craft_item_complete");
			}
			
			GetWitcherPlayer().FinishInvUpdateTransaction();
		}
		
		if (exception != EAE_NoException)
		{
			showNotification(GetLocStringByKeyExt(AlchemyExceptionToString(exception)));
			OnPlaySoundEvent("gui_global_denied");
		}
	}

	// W3EE - Begin
	var initializedMenu : bool;
	
	public function GetAmmoCount(item : name, horse : bool) : int
	{
		if (!horse)
			return thePlayer.inv.SingletonItemGetAmmo(thePlayer.inv.GetItemId(item));
		
		return GetWitcherPlayer().GetHorseManager().GetInventoryComponent().SingletonItemGetAmmo(GetWitcherPlayer().GetHorseManager().GetInventoryComponent().GetItemId(item));
	}
	// W3EE - End
	
	private function PopulateData()
	{
		var l_DataFlashArray		: CScriptedFlashArray;
		var l_DataFlashObject 		: CScriptedFlashObject;
		
		var recipe					: SAlchemyRecipe;
		
		var i, length				: int;
		
		var l_Title					: string;
		var l_Tag					: name;
		var l_IconPath				: string;
		var l_GroupTitle			: string;
		var l_GroupTag				: name;
		var l_IsNew					: bool;
		var canCraftResult			: EAlchemyExceptions;
		var canCraftResultFilters	: EAlchemyExceptions;
		
		
		var cookableType			: EAlchemyCookedItemType;
		var cookable				: SCookable;
		var cookables				: array<SCookable>;
		var exists					: bool;
		var j, cookableCount		: int;
		var minQuality, maxQuality  : int;
		
		// W3EE - Begin
		var cookableID				: SItemUniqueId;
		var alchemyExtender 		: W3EEAlchemyExtender = Alchemy();
		var subName					: array<name>;
		var subCountPlayer			: array<int>;
		var subCountHorse			: array<int>;
		var subSum					: int;
		// W3EE - End
		
		//---=== modFriendlyHUD ===---
		var playerItems, horseItems  : int;
		var alchYield : float;
		//---=== modFriendlyHUD ===---
		
		var expandedAlchemyCategories : array< name >;
		
		expandedAlchemyCategories = GetWitcherPlayer().GetExpandedAlchemyCategories();
		
		// W3EE - Begin
		subCountPlayer.Resize(3);
		subCountHorse.Resize(3);
		subName.Resize(4);
		subName[1] = 'Albedo';
		subName[2] = 'Rubedo';
		subName[3] = 'Nigredo';
		// W3EE - End
		
		l_DataFlashArray = m_flashValueStorage.CreateTempFlashArray();
		length = m_recipeList.Size();
		
		
		for(i=0; i<length; i+=1)
		{
			// W3EE - Begin
			ReplaceStartingIngredients(m_recipeList[i], initializedMenu);
			// W3EE - End
			
			if(m_alchemyManager.CanCookRecipe(m_recipeList[i].recipeName,,isAlchemist) == EAE_NoException)
			{
				exists = false;
				cookableType = m_recipeList[i].cookedItemType;
				
				for(j=0; j<cookables.Size(); j+=1)
				{
					if(cookables[j].type == cookableType)
					{
						cookables[j].cnt += 1;
						exists = true;
						break;
					}					
				}
				
				if(!exists)
				{
					cookable.type = cookableType;
					cookable.cnt = 1;
					cookables.PushBack(cookable);
				}				
			}
		}
		
		// W3EE - Begin
		for( i = 0; i < length; i+= 1 )
		{	
			recipe = m_recipeList[ i ];
			
			l_GroupTag = AlchemyCookedItemTypeEnumToName( recipe.cookedItemType );
			
			l_GroupTitle = GetLocStringByKeyExt( AlchemyCookedItemTypeToLocKey(recipe.cookedItemType) );
			
			l_Title = GetLocStringByKeyExt( m_definitionsManager.GetItemLocalisationKeyName( recipe.cookedItemName ) ) ;	
			l_IconPath = m_definitionsManager.GetItemIconPath(recipe.cookedItemName);
			l_IsNew	= false;
			l_Tag = recipe.recipeName;
			
			canCraftResult = m_alchemyManager.CanCookRecipe(recipe.recipeName,,isAlchemist);
			canCraftResultFilters = m_alchemyManager.CanCookRecipe(recipe.recipeName, true, isAlchemist);
			
			//---=== modFriendlyHUD ===---
			if (thePlayer.newCraftables.Contains(l_Tag))
			{
				l_IsNew = true;
			}
			//---=== modFriendlyHUD ===---
			
			/*cookableID = thePlayer.inv.GetItemId(recipe.cookedItemName);
			if (thePlayer.inv.IsItemSingletonItem(cookableID))
				cookableCount = thePlayer.inv.SingletonItemGetAmmo(cookableID);
			else
				cookableCount = thePlayer.inv.GetItemQuantity(cookableID);*/
			
			if( primary.Contains(recipe.cookedItemName) && !StrContains(recipe.recipeName, "mutagen") )
				l_GroupTitle = GetLocStringByKeyExt("primer_category_substance");
			else
			if( StrContains(recipe.recipeName, " to ") )
				l_GroupTitle = GetLocStringByKeyExt("primer_category_transmutation");
			else
			if( l_GroupTag == 'Substance' )
				l_GroupTitle = GetLocStringByKeyExt("primer_category_fusion");
			
			if (l_GroupTag == 'Substance')
			{
				if( StrContains(recipe.recipeName, "Lesser") )
					l_Title = "•     " + l_Title;
				else
				if( StrContains(recipe.recipeName, "Greater") )
					l_Title = "••• " + l_Title;
				else
				if( StrContains(recipe.recipeName, "mutagen") )
					l_Title = "••   " + l_Title;
			}
			else
			if (l_GroupTag == 'potion' || l_GroupTag == 'oil' || l_GroupTag == 'petard')
			{
				if( StrContains(recipe.recipeName, "1") )
					l_Title = "•     " + l_Title;
				else
				if( StrContains(recipe.recipeName, "2") )
					l_Title = "••   " + l_Title;
				else
				if( StrContains(recipe.recipeName, "3") )
					l_Title = "••• " + l_Title;
			}
			
			/*if (cookableCount > 0)
				l_Title += "<font color=\"#4d4d4d\"> | </font><font color=\"#a48539\">" + cookableCount + "</font>";*/
			
			
			l_DataFlashObject = m_flashValueStorage.CreateTempFlashObject();
			
			l_DataFlashObject.SetMemberFlashString(  "categoryPostfix", "" );
			
			thePlayer.inv.GetItemQualityFromName( recipe.cookedItemName, minQuality, maxQuality );
			
			l_DataFlashObject.SetMemberFlashUInt(  "tag", NameToFlashUInt(l_Tag) );
			l_DataFlashObject.SetMemberFlashString(  "dropDownLabel", l_GroupTitle );
			l_DataFlashObject.SetMemberFlashUInt(  "dropDownTag",  NameToFlashUInt(l_GroupTag) );
			l_DataFlashObject.SetMemberFlashBool(  "dropDownOpened", false );
			l_DataFlashObject.SetMemberFlashString(  "dropDownIcon", "icons/monsters/ICO_MonsterDefault.png" );
			
			l_DataFlashObject.SetMemberFlashBool( "isNew", l_IsNew );
			
			if ( m_guiManager.GetShowItemNames() )
			{
				l_Title = l_Title + "<br><font color=\"#FFDB00\">'" + recipe.recipeName + "'</font>";
			}
			
			//---=== modFriendlyHUD ===---
			if( GetFHUDConfig().showItemCountWhenCrafting )
			{
				if( recipe.cookedItemType == EACIT_Alcohol || recipe.cookedItemType == EACIT_Substance|| recipe.cookedItemType == EACIT_Edible )
				{
					playerItems = thePlayer.inv.GetItemQuantityByName(recipe.cookedItemName);
					horseItems = GetWitcherPlayer().GetHorseManager().GetInventoryComponent().GetItemQuantityByName(recipe.cookedItemName);
				}
				else
				if( recipe.cookedItemType == EACIT_Oil || recipe.cookedItemType == EACIT_Bomb || recipe.cookedItemType == EACIT_Potion || recipe.cookedItemType == EACIT_MutagenPotion )
				{
					playerItems = GetAmmoCount(recipe.cookedItemName, false);
					horseItems = GetAmmoCount(recipe.cookedItemName, true);
				}
				
				if( recipe.cookedItemType == EACIT_Potion && recipe.cookedItemName != 'White Honey 1' ) 
				{
					for(j=0; j<3; j+=1)
					{
						subName[0] = Alchemy().GetPotionNameFromSubstance(recipe.cookedItemName, subName[j + 1]);
						LogChannel('modW3EEAlchemy', subName[0] + "  :  " + subName[j + 1]);
						subCountPlayer[j] = GetAmmoCount(subName[0], false);
						subCountHorse[j] = GetAmmoCount(subName[0], true);
						subSum += subCountPlayer[j] + subCountHorse[j];
					}
				}
				
				if( playerItems + horseItems + subSum > 0 ) 
				{
					l_Title += " (<font color=\"#C0C0C0\">" + IntToString(playerItems);
					if( horseItems > 0 )
						l_Title += " + " + IntToString(horseItems);
					l_Title += "</font>)";
					
					if( subSum > 0 )
					{
						l_Title += "   +";
						
						for(j=0; j<3; j+=1)
						{
							if( subCountPlayer[j] + subCountHorse[j] > 0 ) 
							{
								l_Title += "   ";
								
								if( j == 0 )
									l_Title += albedo_color + "A</font> [";
								if( j == 1 )
									l_Title += rubedo_color + "R</font> [";
								if( j == 2 )
									l_Title += nigredo_color + "N</font> [";
								
								l_Title += "<font color=\"#C0C0C0\">" + IntToString(subCountPlayer[j]);
								if (subCountHorse[j] > 0)
									l_Title += " + " + IntToString(subCountHorse[j]);
								l_Title += "</font>]";
								
								subSum = 0;
								subCountPlayer[j] = 0;
								subCountHorse[j] = 0;
							}
						}
					}					
				}
				
				horseItems = 0;
				playerItems = recipe.cookedItemQuantity;
				if( recipe.cookedItemType == EACIT_Potion || recipe.cookedItemType == EACIT_Oil )
				{
					alchYield = Options().GetAlchemyYieldHalved();
					playerItems += FloorF(alchYield) - 1;
					
					if (alchYield - FloorF(alchYield) >= 0.001f)
						horseItems += 1;
					
					if( thePlayer.HasBuff(EET_AlchemyTable) )
						playerItems += 1;
						
					if( GetWitcherPlayer().IsSetBonusActive(EISB_RedWolf_2) )
						horseItems += 1;
				}
				
				if( recipe.cookedItemType == EACIT_Bomb && thePlayer.GetSkillLevel(S_Alchemy_s08) )
				{
					if( thePlayer.GetSkillLevel(S_Alchemy_s08) == 1 )
						horseItems += 1;
					else
					if( thePlayer.GetSkillLevel(S_Alchemy_s08) >= 2 )
						playerItems += 1;
					
					if( thePlayer.GetSkillLevel(S_Alchemy_s08) == 3 )
						horseItems += 1;
				}
				
				if( playerItems + horseItems > 1 )
				{
					l_Title += " | " + playerItems;
					if( horseItems > 0 )
						l_Title += " + " + horseItems;
					l_Title += " |";
				}
				
				if( primary.Contains(recipe.cookedItemName) && !StrContains(recipe.recipeName, "mutagen") && !strong.Contains(recipe.cookedItemName) )
				{
					l_Title += " | 5 - 12 |";
				}
			}
			//---=== modFriendlyHUD ===---
			
			l_DataFlashObject.SetMemberFlashString(  "label", l_Title );
			l_DataFlashObject.SetMemberFlashString(  "iconPath", l_IconPath );
			l_DataFlashObject.SetMemberFlashInt( "rarity", minQuality );
			
			if (canCraftResult != EAE_NoException)
			{
				l_DataFlashObject.SetMemberFlashString( "cantCookReason", GetLocStringByKeyExt(AlchemyExceptionToString(canCraftResult)));
			}
			else
			{
				l_DataFlashObject.SetMemberFlashString( "cantCookReason", "" );
			}
			
			l_DataFlashObject.SetMemberFlashBool( "isSchematic", false );
			l_DataFlashObject.SetMemberFlashInt( "canCookStatus", canCraftResult);
			l_DataFlashObject.SetMemberFlashInt( "canCookStatusForFilter", canCraftResultFilters);
			
			l_DataFlashArray.PushBackFlashObject(l_DataFlashObject);
		}
		
		if( l_DataFlashArray.GetLength() > 0 )
		{
			m_flashValueStorage.SetFlashArray( DATA_BINDING_NAME, l_DataFlashArray );
			m_fxShowSecondaryModulesSFF.InvokeSelfOneArg(FlashArgBool(true));
		}
		else
		{
			m_fxShowSecondaryModulesSFF.InvokeSelfOneArg(FlashArgBool(false));
		}
		
		initializedMenu = true;
		// W3EE - End
	}

	function UpdateDescription( tag : name )
	{
		var description : string;
		var title : string;
		var id : int;
		
		// W3EE - Begin
		m_lastSelectedTag = tag;
		// W3EE - End
		
		id = FindRecipieID(tag);
		
		title = GetLocStringByKeyExt(m_definitionsManager.GetItemLocalisationKeyName(m_recipeList[id].cookedItemName));	
		description = m_definitionsManager.GetItemLocalisationKeyDesc(m_recipeList[id].cookedItemName);	
		if(description == "" || description == "<br>" )
		{
			description = "panel_journal_quest_empty_description";
		}
		description = GetLocStringByKeyExt(description);	
		
		
		m_flashValueStorage.SetFlashString(DATA_BINDING_NAME_DESCRIPTION+".title",title);
		m_flashValueStorage.SetFlashString(DATA_BINDING_NAME_DESCRIPTION+".text",description);	
	}	

	function GetDescription( currentCharacter : CJournalCharacter ) : string
	{
		var i : int;
		var str : string;
		var locStrId : int;
		
		var description : CJournalCharacterDescription;
		
		str = "";
		for( i = 0; i < currentCharacter.GetNumChildren(); i += 1 )
		{
			description = (CJournalCharacterDescription)(currentCharacter.GetChild(i));
			if( m_journalManager.GetEntryStatus(description) == JS_Active )
			{
				locStrId = description.GetDescriptionStringId();
				str += GetLocStringById(locStrId)+"<br>";
			}
		}

		if( str == "" || str == "<br>" )
		{
			str = GetLocStringByKeyExt("panel_journal_quest_empty_description");
		}
		
		return str;
	}
	

	function FindRecipieID(tag : name ) : int
	{
		var i : int;
		for( i = 0; i < m_recipeList.Size(); i += 1 )
		{
			if( m_recipeList[i].recipeName == tag )
			{
				return i;
			}
		}
		return -1;
	}
	
	// W3EE - Begin
	function GetItemQuantity( id : int ) : int
	{
		return Equipment().GetItemQuantityByNameForCrafting(itemsNames[id]);
	}
	// W3EE - End
	
	function UpdateItems( tag : name )
	{
		UpdateItemsById(FindRecipieID(tag));
		
		if( !isModuleSelected )
			ShowSelectedItemInfo(tag);
	}
	
	private function UpdateItemsById( id : int ) : void
	{
		var itemsFlashArray	: CScriptedFlashArray;
		var i : int;
		
		itemsNames.Clear();
		itemsQuantity.Clear();
		// W3EE - Begin
		selectedRecipeIndex = id;
		selectedRecipe = m_recipeList[id];
		defaultIngredientQuantities.Clear();
		for( i = 0; i < m_recipeList[id].requiredIngredients.Size(); i += 1 )
		{
			itemsNames.PushBack(m_recipeList[id].requiredIngredients[i].itemName); 
			defaultIngredientQuantities.PushBack(originalRecipes[id].requiredIngredients[i].quantity);
			itemsQuantity.PushBack(GetIngredientQuantity(m_recipeList[id].requiredIngredients[i].itemName,  defaultIngredientQuantities.Size() - 1) );
			m_recipeList[id].requiredIngredients[i].quantity = itemsQuantity[itemsQuantity.Size() - 1];
		}
		m_alchemyManager.ModRecipe(m_recipeList[id]);
		itemsFlashArray = CreateItems(itemsNames);
		
		if( itemsFlashArray )
		{
			m_flashValueStorage.SetFlashArray( DATA_BINDING_NAME_SUBLIST, itemsFlashArray );
			FillRequiredComponentsString(m_recipeList[id], id);
		}
		// W3EE - End
	}
	
	// W3EE - Begin
	private function FillRequiredComponentsString( recipe : SAlchemyRecipe, index : int )
	{
		var isComponent, isMutagen, isBase, isMisc : bool;
		var componentsString : string;
		var i : int;
		
		componentsString = "<font size=\"30\">";
		for(i=0; i<recipe.requiredIngredients.Size(); i+=1)
		{
			if( vitriol.Contains(originalRecipes[index].requiredIngredients[i].itemName) )
			{
				if( !isComponent )
				{
					if( i > 0 )
						componentsString += "  ";
					componentsString += GetLocStringByKeyExt("W3EE_MainComp") + " ";
				}
				componentsString += vitriol_color + "•" + "</font>";
				isComponent = true;
			}
			else
			if( rebis.Contains(originalRecipes[index].requiredIngredients[i].itemName) )
			{
				if( !isComponent )
				{
					if( i > 0 )
						componentsString += "  ";
					componentsString += GetLocStringByKeyExt("W3EE_MainComp") + " ";
				}
				componentsString += rebis_color + "•" + "</font>";
				isComponent = true;
			}
			else
			if( aether.Contains(originalRecipes[index].requiredIngredients[i].itemName) )
			{
				if( !isComponent )
				{
					if( i > 0 )
						componentsString += "  ";
					componentsString += GetLocStringByKeyExt("W3EE_MainComp") + " ";
				}
				componentsString += aether_color + "•" + "</font>";
				isComponent = true;
			}
			else
			if( quebrith.Contains(originalRecipes[index].requiredIngredients[i].itemName) )
			{
				if( !isComponent )
				{
					if( i > 0 )
						componentsString += "  ";
					componentsString += GetLocStringByKeyExt("W3EE_MainComp") + " ";
				}
				componentsString += quebrith_color + "•" + "</font>";
				isComponent = true;
			}
			else
			if( hydragenum.Contains(originalRecipes[index].requiredIngredients[i].itemName) )
			{
				if( !isComponent )
				{
					if( i > 0 )
						componentsString += "  ";
					componentsString += GetLocStringByKeyExt("W3EE_MainComp") + " ";
				}
				componentsString += hydragenum_color + "•" + "</font>";
				isComponent = true;
			}
			else
			if( vermilion.Contains(originalRecipes[index].requiredIngredients[i].itemName) )
			{
				if( !isComponent )
				{
					if( i > 0 )
						componentsString += "  ";
					componentsString += GetLocStringByKeyExt("W3EE_MainComp") + " ";
				}
				componentsString += vermilion_color + "•" + "</font>";
				isComponent = true;
			}
			else
			if( mutagenRed.Contains(originalRecipes[index].requiredIngredients[i].itemName) )
			{
				if( !isMutagen )
				{
					if( i > 0 )
						componentsString += "  ";
					componentsString += GetLocStringByKeyExt("W3EE_MutComp") + " ";
				}
				componentsString += vermilion_color + "•" + "</font>";
				isMutagen = true;
			}
			else
			if( mutagenBlue.Contains(originalRecipes[index].requiredIngredients[i].itemName) )
			{
				if( !isMutagen )
				{
					if( i > 0 )
						componentsString += "  ";
					componentsString += GetLocStringByKeyExt("W3EE_MutComp") + " ";
				}
				componentsString += vitriol_color + "•" + "</font>";
				isMutagen = true;
			}
			else
			if( mutagenGreen.Contains(originalRecipes[index].requiredIngredients[i].itemName) )
			{
				if( !isMutagen )
				{
					if( i > 0 )
						componentsString += "  ";
					componentsString += GetLocStringByKeyExt("W3EE_MutComp") + " ";
				}
				componentsString += rebis_color + "•" + "</font>";
				isMutagen = true;
			}
			else
			if( weak.Contains(originalRecipes[index].requiredIngredients[i].itemName) || fancy.Contains(originalRecipes[index].requiredIngredients[i].itemName) )
			{
				if( !isBase )
				{
					if( i > 0 )
						componentsString += "  ";
					componentsString += GetLocStringByKeyExt("W3EE_BaseComp") + " ";
				}
				componentsString += albedo_color + "•" + "</font>";
				isBase = true;
			}
			else
			if( greaseLow.Contains(originalRecipes[index].requiredIngredients[i].itemName) )
			{
				if( !isBase )
				{
					if( i > 0 )
						componentsString += "  ";
					componentsString += GetLocStringByKeyExt("W3EE_BaseComp") + " ";
				}
				componentsString += albedo_color + "•" + "</font>";
				isBase = true;
			}
			else
			if( powderLow.Contains(originalRecipes[index].requiredIngredients[i].itemName) )
			{
				if( !isBase )
				{
					if( i > 0 )
						componentsString += "  ";
					componentsString += GetLocStringByKeyExt("W3EE_BaseComp") + " ";
				}
				componentsString += albedo_color + "•" + "</font>";
				isBase = true;
			}
			else
			{
				if( !isMisc )
				{
					if( i > 0 )
						componentsString += "  ";
					componentsString += GetLocStringByKeyExt("W3EE_MiscComp") + " ";
				}
				componentsString += "•";
				isMisc = true;
			}
		}
		
		componentsString += "</font>";
		m_flashModule.GetChildFlashSprite("mcCraftingModule").GetChildFlashTextField("txtIngredients").SetTextHtml(componentsString);
	}
	// W3EE - End
	
	public function FillItemInformation(flashObject : CScriptedFlashObject, index:int) : void
	{	
		super.FillItemInformation(flashObject, index);
		
		// W3EE - Begin
		if( m_npcInventory )
		{
			flashObject.SetMemberFlashInt( "vendorQuantity", m_npcInventory.GetItemQuantityByName( itemsNames[index] ) );
		}
		// W3EE - End
		
		flashObject.SetMemberFlashInt("reqQuantity", itemsQuantity[index]);
	}
	
	function GetItemRarityDescription( itemName : name ) : string
	{
		var itemQuality : int;
		
		itemQuality = 1; 
		return GetItemRarityDescriptionFromInt(itemQuality);
	}
	
	private function getCategoryDescription(itemCategory : name):string
	{	
		switch (itemCategory)
		{
			case 'steelsword':
			case 'silversword':
			case 'crossbow':
			case 'secondary':
			case 'armor':
			case 'pants':
			case 'gloves':
			case 'boots':
			case 'armor':
			case 'bolt':
				return GetLocStringByKeyExt("item_category_" + itemCategory + "_desc");
				break;
			default:
				return "";
				break;
		}
		return "";
	}
	
	private function addGFxItemStat(out targetArray:CScriptedFlashArray, type:string, value:string):void
	{
		var resultData : CScriptedFlashObject;
		resultData = m_flashValueStorage.CreateTempFlashObject();
		resultData.SetMemberFlashString("type", type);
		resultData.SetMemberFlashString("value", value);
		targetArray.PushBackFlashObject(resultData);
	}
	
	function PlayOpenSoundEvent()
	{
		
		
	}
	
	public final function IsInShop() : bool
	{
		var l_obj		 			: IScriptable;		
		var l_initData				: W3InventoryInitData;
		var m_npc					: CNewNPC;
		
		l_obj = GetMenuInitData();
		l_initData = (W3InventoryInitData)l_obj;
		if (l_initData)
		{
			m_npc = (CNewNPC)l_initData.containerNPC;
		}
		else
		{
			m_npc = (CNewNPC)l_obj;
		}
		
		return m_npc;
	}
	
	// W3EE - Begin
	var isAlchemist	: bool;
	private final function InitializeAlchemist() : void
	{
		var l_obj		 			: IScriptable;		
		var l_initData				: W3InventoryInitData;
		var l_merchantComponent		: W3MerchantComponent;
		
		isAlchemist = false;
		
		l_obj = GetMenuInitData();
		l_initData = (W3InventoryInitData)l_obj;
		if (l_initData)
		{
			m_npc = (CNewNPC)l_initData.containerNPC;
		}
		else
		{
			m_npc = (CNewNPC)l_obj;
		}
		
		if (m_npc)
		{
			l_merchantComponent = (W3MerchantComponent)m_npc.GetComponentByClassName('W3MerchantComponent');
			isAlchemist = l_merchantComponent.GetMapPinType() == 'Herbalist' || l_merchantComponent.GetMapPinType() == 'Alchemic';
			
			if (isAlchemist)
			{
				m_npcInventory = m_npc.GetInventory();
				UpdateMerchantData(m_npc);
				m_shopInvComponent = new W3GuiShopInventoryComponent in this;
				m_shopInvComponent.Initialize( m_npcInventory );
			}
		}
	}

	event  OnBuyIngredient( item : int, isLastItem : bool ) : void
	{
		var vendorItemId   : SItemUniqueId;	
		var vendorItems    : array< SItemUniqueId >;
		
		
		var reqQuantity    : int;
		var itemName       : name;
		var newItemID      : SItemUniqueId;
		
		if( m_npcInventory )
		{
			itemName = itemsNames[ item - 1 ];
			vendorItems = m_npcInventory.GetItemsByName( itemName );
			
			if( vendorItems.Size() > 0 )
			{
				vendorItemId = vendorItems[0];
				
				
				
				
				BuyIngredient( vendorItemId, 1, isLastItem );
				OnPlaySoundEvent( "gui_inventory_buy" );
			}
		}
	}
	
	public function BuyIngredient( itemId : SItemUniqueId, quantity : int, isLastItem : bool ) : void
	{
		var newItemID   : SItemUniqueId;
		var result 		: bool;
		var itemName	: name;
		var notifText	: string;
		var itemLocName : string;
		
		itemLocName = GetLocStringByKeyExt( m_npcInventory.GetItemLocalizedNameByUniqueID( itemId ) );
		itemName = m_npcInventory.GetItemName( itemId );
		theTelemetry.LogWithLabelAndValue( TE_INV_ITEM_BOUGHT, itemName, quantity );
		result = m_shopInvComponent.GiveItem( itemId, _playerInv, quantity, newItemID );
		
		if( result )
		{
			notifText = GetLocStringByKeyExt("panel_blacksmith_items_added") + ":" + quantity + " x " + itemLocName;
			
			if (isLastItem)
			{
				PopulateData();
			}
		}
		else
		{
			notifText = GetLocStringByKeyExt( "panel_shop_notification_not_enough_money" );
		}
		
		showNotification( notifText );
		
		UpdateMerchantData(m_npc);
		UpdateItemsCounter();
		
		previousException = craftingException;
		craftingException = m_alchemyManager.CanCookRecipe(selectedRecipe.recipeName,,isAlchemist);
		if( craftingException != previousException )
			PopulateData();
		
		if (m_lastSelectedTag != '')
		{
			UpdateItems(m_lastSelectedTag);
		}
	}

	private function UpdateItemsCounter()
	{		
		var commonMenu 	: CR4CommonMenu;
		
		commonMenu = (CR4CommonMenu)m_parentMenu;
		if( commonMenu )
		{
			commonMenu.UpdateItemsCounter();
			commonMenu.UpdatePlayerOrens();
		}
	}

	function UpdateMerchantData(targetNpc : CNewNPC) : void
	{
		var l_merchantData	: CScriptedFlashObject;
		
		l_merchantData = m_flashValueStorage.CreateTempFlashObject();
		GetNpcInfo((CGameplayEntity)targetNpc, l_merchantData);
		m_flashValueStorage.SetFlashObject("crafting.merchant.info", l_merchantData);
	}
	
	private var ingredientLocks : array<name>;
	private var currentLockIndex : int;
	private var selectedIngredient : int;
	private var selectedRecipeIndex : int;
	private var selectedRecipe : SAlchemyRecipe;
	private var previousRecipe : SAlchemyRecipe;
	private var isModuleSelected : bool;
	private var shiftIndex : int;
	
	public function GetIsModuleSelected() : bool
	{
		return isModuleSelected;
	}
	
	event OnModuleSelected( moduleID : int, moduleBindingName : string )
	{
		if( moduleID == 1 )
			isModuleSelected = true;
		else
		{
			isModuleSelected = false;
			ShowSelectedItemInfo(selectedRecipe.recipeName);
		}
		alchemyMenuContext.UpdateContext();
	}

	private function ReplaceStartingIngredients( out alchemyRecipe : SAlchemyRecipe, isInitialized : bool )
	{
		var i : int;
		
		if( isInitialized )
			return;
		
		shiftIndex = -1;
		itemsNames.Clear();
		selectedRecipe = alchemyRecipe;
		selectedRecipeIndex = FindRecipieID(selectedRecipe.recipeName);
		defaultIngredientQuantities.Clear();
		for(i=0; i<alchemyRecipe.requiredIngredients.Size(); i+=1)
		{
			itemsNames.PushBack(alchemyRecipe.requiredIngredients[i].itemName);
			defaultIngredientQuantities.PushBack(alchemyRecipe.requiredIngredients[i].quantity);
			alchemyRecipe.requiredIngredients[i].quantity = GetIngredientQuantity(itemsNames[i], i);
			
			itemsNames[i] = PickCompatibleIngredient(i);
			alchemyRecipe.requiredIngredients[i].itemName = itemsNames[i];
			alchemyRecipe.requiredIngredients[i].quantity = GetIngredientQuantity(itemsNames[i], i);
		}
		m_alchemyManager.ModRecipe(alchemyRecipe);
		previousRecipe = alchemyRecipe;
	}
	
	private function IngredientShift()
	{
		var ingredientName, ingredientNameNext : name;
		
		if( isModuleSelected )
		{
			ingredientName = itemsNames[selectedIngredient];
			ingredientNameNext = ReplaceGridIngredient(selectedIngredient);
			if( ingredientNameNext != ingredientName )
			{
				ReplaceRecipeIngredient(ingredientName, ingredientNameNext);
				SetIngredientDescription();
				previousException = craftingException;
				craftingException = m_alchemyManager.CanCookRecipe(selectedRecipe.recipeName,,isAlchemist);
				if( craftingException != previousException )
					PopulateData();
			}
			previousRecipe = selectedRecipe;
		}
	}
	
	event OnIngredientShiftAction( action : SInputAction )
	{	
		if( action.value < 0 )
		{
			OnIngredientShiftBackward();
		}
		else
		if( action.value > 0 )
		{
			OnIngredientShiftForward();
		}
	}
	
	event OnIngredientShiftForward()
	{	
		if (shiftIndex != 1)
			shiftIndex = 1;
		IngredientShift();
	}
	
	event OnIngredientShiftBackward()
	{
		if (shiftIndex != -1)
			shiftIndex = -1;
		IngredientShift();
	}
	
	event OnIngredientLockForward()
	{
		currentLockIndex += 1;
		if( currentLockIndex > ingredientLocks.Size() - 1 )
			currentLockIndex = 0;
		
		ingredientRestriction = ingredientLocks[currentLockIndex];
		theGame.GetGuiManager().ShowNotification(GetLocStringByKeyExt("W3EE_IngredientLock") + ":<br>" + GetLocStringByKeyExt(LockNameToLocString(ingredientRestriction)));
	}
	
	event OnIngredientLockBackward()
	{
		currentLockIndex -= 1;
		if( currentLockIndex < 0 )
			currentLockIndex = ingredientLocks.Size() - 1;
		
		ingredientRestriction = ingredientLocks[currentLockIndex];
		theGame.GetGuiManager().ShowNotification(GetLocStringByKeyExt("W3EE_IngredientLock") + ":<br>" + GetLocStringByKeyExt(LockNameToLocString(ingredientRestriction)));
	}
	
	private function InitIngredientLocks()
	{
		ingredientLocks.Clear();
		ingredientLocks.PushBack('');
		ingredientLocks.PushBack('potionA');
		ingredientLocks.PushBack('potionR');
		ingredientLocks.PushBack('potionN');
	}
	
	private function LockNameToLocString( lockName : name ) : string
	{
		switch(lockName)
		{
			case 'potionA':		return "W3EE_LockAlbedo";
			case 'potionR':		return "W3EE_LockRubedo";
			case 'potionN':		return "W3EE_LockNigredo";
			default:			return "W3EE_LockNone";
		}
	}
	
	private function GetIngredientCategoryString( category : name, itemName : name ) : string
	{
		if( !IsNameValid(category) )
			return "";
		
		if( !(fancy.Contains(itemName) || weak.Contains(itemName) || medium.Contains(itemName) || strong.Contains(itemName) || greaseLow.Contains(itemName) || greaseHigh.Contains(itemName) || greaseTop.Contains(itemName) || powderLow.Contains(itemName) || powderHigh.Contains(itemName) || powderTop.Contains(itemName)) )
			return "";
		
		return GetLocStringByKeyExt("item_category_" + StrReplaceAll( StrLower(NameToString(category)), " ", "_"));
	}
	
	event OnGetItemData( item : int, compareItemType : int )
	{
		GetIngredientTooltipData(item - 1);
	}
	
	private function GetIngredientTooltipData( index : int )
	{
		var itemNameString 		: string;
		var typeStr				: string;
		var effectDescription	: string;
		var category			: name;
		var resultData 			: CScriptedFlashObject;				
		
		var vendorItemId		: SItemUniqueId;		
		var vendorItems			: array< SItemUniqueId >;
		var vendorQuantity		: int;
		var vendorPrice			: int;
		var itemName 			: name;
		var locStringBuy   		: string;
		var locStringPrice 		: string;
		
		resultData = m_flashValueStorage.CreateTempFlashObject();		
		
		selectedIngredient = index;
		if( isModuleSelected )
		{
			SetIngredientDescription();
		}
		
		itemNameString = m_definitionsManager.GetItemLocalisationKeyName(itemsNames[index]);
		itemNameString = GetLocStringByKeyExt(itemNameString);
		
		if( itemNameString == "" )
			itemNameString = GetLocStringByKeyExt("W3EE_NoIngredient");
		
		resultData.SetMemberFlashString("ItemName", itemNameString);
		
		effectDescription = GetIngredientCategory(itemsNames[index],, true);
		
		category = m_definitionsManager.GetItemCategory(itemsNames[index]);
		typeStr = GetIngredientCategoryString(category, itemsNames[index]) + effectDescription;
		resultData.SetMemberFlashString("ItemType", typeStr);
		
		if( m_npcInventory )
		{
			itemName = itemsNames[index];
			vendorItems = m_npcInventory.GetItemsByName(itemName);
			if( vendorItems.Size() > 0 )
			{
				vendorItemId = vendorItems[0];
				vendorQuantity = m_npcInventory.GetItemQuantity(vendorItemId);
				vendorPrice = m_npcInventory.GetItemPrice(vendorItemId);
				vendorPrice = m_npcInventory.GetItemScaledPrice(vendorPrice, vendorItemId, m_npcInventory, true, false);
				
				resultData.SetMemberFlashNumber("vendorQuantity", vendorQuantity);
				resultData.SetMemberFlashNumber("vendorPrice", vendorPrice);
				
				locStringBuy = GetLocStringByKeyExt("panel_inventory_quantity_popup_buy");
				
				resultData.SetMemberFlashString("vendorInfoText", locStringBuy + " (" +  vendorPrice + ")");
			}
		}
		
		m_flashValueStorage.SetFlashObject("context.tooltip.data", resultData);
	}
	
	private var ingredientRestriction : name;	
	event OnCategoryOpened (categoryName : name, opened : bool)
	{	
		var player : W3PlayerWitcher;
		
		player = GetWitcherPlayer();
		if ( !player )
		{
			return false;
		}
		
		if( opened )
		{
			player.AddExpandedAlchemyCategory( categoryName );
		}
		else
		{
			player.RemoveExpandedAlchemyCategory( categoryName );
		}
		
		//super.OnCategoryOpened(categoryName, opened);
	}
	
	private function SetIngredientDescription()
	{
		var ingredientInfo : CScriptedFlashObject;
		var ingredientDescription : CScriptedFlashArray;
		var descriptionLine : CScriptedFlashObject;
		var ingredientName, secondaryEffectDescr, secondarySubstance, ingredientDescr : string;	
		var hasSecondary : bool = true;
		
		ingredientName = m_definitionsManager.GetItemLocalisationKeyName(itemsNames[selectedIngredient]);
		ingredientName = GetLocStringByKeyExt(ingredientName);
		if( ingredientName == "" )
		{
			return;
		}
		
		if( selectedRecipe.cookedItemType != EACIT_Potion )
			hasSecondary = false;
		else
		if( albedo.Contains(itemsNames[selectedIngredient]) )
		{
			secondarySubstance =  GetLocStringByKeyExt("primer_susbstance_dominance") + " " + GetLocStringByKeyExt("primer_albedo");
			secondaryEffectDescr = GetLocStringByKeyExt("primer_effect_descr1");
		}
		else
		if( rubedo.Contains(itemsNames[selectedIngredient]) )
		{
			secondarySubstance =  GetLocStringByKeyExt("primer_susbstance_dominance") + " " + GetLocStringByKeyExt("primer_rubedo");
			secondaryEffectDescr = GetLocStringByKeyExt("primer_effect_descr2");
		}
		else
		if( nigredo.Contains(itemsNames[selectedIngredient]) )
		{
			secondarySubstance =  GetLocStringByKeyExt("primer_susbstance_dominance") + " " + GetLocStringByKeyExt("primer_nigredo");
			secondaryEffectDescr = GetLocStringByKeyExt("primer_effect_descr3");
		}
		else
			hasSecondary = false;
		
		ingredientInfo = m_flashValueStorage.CreateTempFlashObject();
		if( hasSecondary )
		{
			ingredientDescription = ingredientInfo.CreateFlashArray();
			descriptionLine = ingredientInfo.CreateFlashObject();		
			descriptionLine.SetMemberFlashString("name", GetLocStringByKeyExt("primer_effect_descr_p1") + " " + secondaryEffectDescr + " " + GetLocStringByKeyExt("primer_effect_descr_p2") );
			descriptionLine.SetMemberFlashString("value", "-");
			ingredientDescription.PushBackFlashObject(descriptionLine);
			ingredientInfo.SetMemberFlashString("type", secondarySubstance);				
			ingredientInfo.SetMemberFlashArray("attributesList", ingredientDescription);
		}		
		
		ingredientDescr = GetIngredientCategory(itemsNames[selectedIngredient]);
		ingredientInfo.SetMemberFlashString("itemName", ingredientName);
		ingredientInfo.SetMemberFlashString("itemDescription", ingredientDescr);		
		m_flashValueStorage.SetFlashObject("alchemy.menu.crafted.item.tooltip", ingredientInfo);		
	}
	
	private function ReplaceGridIngredient( ingredient : int ) : name
	{
		var ingredients : CScriptedFlashArray;
		var ingredientName : name;
		
		if( ingredient >= 0 )
		{
			ingredientName = PickCompatibleIngredient(ingredient);
			
			if( ingredientName )
			{
				if( itemsNames[ingredient] != ingredientName )
				{
					itemsNames[ingredient] = ingredientName;
					itemsQuantity[ingredient] = GetIngredientQuantity(ingredientName, ingredient);
					ingredients = CreateItems(itemsNames);
					if( ingredients )
						m_flashValueStorage.SetFlashArray(DATA_BINDING_NAME_SUBLIST, ingredients);
				}
				else
					showNotification(GetLocStringByKeyExt("primer_noingredient"));
			}
			else
				showNotification(GetLocStringByKeyExt("primer_noingredient"));
		}
		return ingredientName;
	}
	
	private function ReplaceRecipeIngredient( ingredientName, ingredientNameNext : name ) : void
	{
		var i : int;		
		
		selectedRecipe.requiredIngredients[selectedIngredient].itemName = ingredientNameNext;
		selectedRecipe.requiredIngredients[selectedIngredient].quantity = GetIngredientQuantity(ingredientNameNext, selectedIngredient);
		for(i=0; i<m_recipeList.Size(); i+=1)
		{
			if( m_recipeList[i].recipeName == selectedRecipe.recipeName )
			{
				m_recipeList[i] = selectedRecipe;
				m_alchemyManager.ModRecipe(selectedRecipe);
				break;
			}
		}
	}

	private var defaultIngredientQuantities : array <int>;
	private function GetIngredientQuantity( ingredientName : name, ingredientIndex : int, optional skipSlotQuality : bool ) : int
	{
		var quantity, i : int;
		
		if( ingredientName == '' )
			return 0;
		
		if( flasks.Contains(ingredientName) )
		{
			if( Alchemy().GetIsDistillingPrimarySubstance(selectedRecipe.recipeName) )
				return defaultIngredientQuantities[ingredientIndex];
				
			if( selectedRecipe.cookedItemType == EACIT_Potion || selectedRecipe.cookedItemType == EACIT_Oil )
				quantity = FloorF(Options().GetAlchemyYieldHalved() + RandF()) + (int)GetWitcherPlayer().HasBuff(EET_AlchemyTable);
			else
				quantity = 1 + (int)GetWitcherPlayer().HasBuff(EET_AlchemyTable);
				
			quantity = CeilF(((float)defaultIngredientQuantities[ingredientIndex]) * quantity);
			
			return quantity;
		}
		
		if( mutagens.Contains(ingredientName) )
		{
			if( selectedRecipe.cookedItemName == 'Greater mutagen blue' || selectedRecipe.cookedItemName == 'Greater mutagen red' ||selectedRecipe.cookedItemName == 'Greater mutagen green' )
			{
				if( primary.Contains(ingredientName) )
					quantity = 1;
				else
				if( rare.Contains(ingredientName) )
					quantity = 3;
				else
					quantity = 9;
			}
			else
			if( selectedRecipe.cookedItemName == 'Mutagen blue' || selectedRecipe.cookedItemName == 'Mutagen red' ||selectedRecipe.cookedItemName == 'Mutagen green' )
			{
				if( primary.Contains(ingredientName) )
					quantity = 1;
				else
				if( rare.Contains(ingredientName) )
					quantity = 1;
				else
					quantity = 3;
			}
			
			if( quantity )
				return quantity;
		}
		
		if( primary.Contains(ingredientName) )
		{
			quantity = RoundF(((float)defaultIngredientQuantities[ingredientIndex]) / 3);
			quantity = Max(1, quantity);
		}
		else
		if( rare.Contains(ingredientName) )
		{
			quantity = CeilF(((float)defaultIngredientQuantities[ingredientIndex]) * 0.5f);
		}
		else
		if( common.Contains(ingredientName) )
		{
			quantity = CeilF(((float)defaultIngredientQuantities[ingredientIndex]) * 1.5f);
		}
		else
			quantity = defaultIngredientQuantities[ingredientIndex];
		
		return quantity;
	}
	
	private function PickCompatibleIngredient( ingredient : int ) : name
	{	
		var ingredientName : name;
		
		if( vitriol.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[ingredient].itemName))
			ingredientName = GetArrayNextIngredient(vitriol, ingredient);
		else
		if( rebis.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[ingredient].itemName))
			ingredientName = GetArrayNextIngredient(rebis, ingredient);
		else
		if( aether.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[ingredient].itemName))
			ingredientName = GetArrayNextIngredient(aether, ingredient);
		else
		if( quebrith.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[ingredient].itemName))
			ingredientName = GetArrayNextIngredient(quebrith, ingredient);
		else
		if( hydragenum.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[ingredient].itemName))
			ingredientName = GetArrayNextIngredient(hydragenum, ingredient);
		else
		if( vermilion.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[ingredient].itemName))
			ingredientName = GetArrayNextIngredient(vermilion, ingredient);
		else
		if( flasks.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[ingredient].itemName))
			ingredientName = GetArrayNextIngredient(flasks, ingredient, true);
		else
		if( fancy.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[ingredient].itemName))
			ingredientName = GetArrayNextIngredient(fancy, ingredient, true);
		else
		if( mutagens.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[ingredient].itemName))
			ingredientName = HandleMutagens(ingredient);
		else
			ingredientName = HandleAlchemyBase(ingredient);
		
		return ingredientName;		
	}
	
	private function HandleAlchemyBase( ingredient : int ) : name
	{
		if( weak.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[ingredient].itemName))
			return GetAlchemyBaseIngredient(weak, medium, strong, ingredient);
		else
		if( greaseLow.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[ingredient].itemName))
			return GetAlchemyBaseIngredient(greaseLow, greaseHigh, greaseTop, ingredient);
		else
		if( powderLow.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[ingredient].itemName))
			return GetAlchemyBaseIngredient(powderLow, powderHigh, powderTop, ingredient);
		else			
			return originalRecipes[selectedRecipeIndex].requiredIngredients[ingredient].itemName;
	}
	
	private function HandleMutagens( ingredient : int ) : name
	{
		if( selectedRecipe.cookedItemType == EACIT_MutagenPotion && mutagenUnique.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[ingredient].itemName) )
		{
			if( Equipment().GetItemQuantityByNameForCrafting(originalRecipes[selectedRecipeIndex].requiredIngredients[ingredient].itemName) < originalRecipes[selectedRecipeIndex].requiredIngredients[ingredient].quantity )
				return '';
			else
				return originalRecipes[selectedRecipeIndex].requiredIngredients[ingredient].itemName;
		}
		else
		if( mutagenRed.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[ingredient].itemName))
			return GetArrayNextIngredient(mutagenRed, ingredient, true);
		else
		if( mutagenGreen.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[ingredient].itemName))
			return GetArrayNextIngredient(mutagenGreen, ingredient, true);
		else
		if( mutagenBlue.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[ingredient].itemName))
			return GetArrayNextIngredient(mutagenBlue, ingredient, true);	
		else
			return originalRecipes[selectedRecipeIndex].requiredIngredients[ingredient].itemName;
	}
	
	private function GetArrayNextIngredient( source : array<name>, ingredient : int, optional exclude : bool ) : name
	{
		var index, invCount, totalIngredients : int;
		var ingredients, secondaryIngredients : array<name>;
		var inShop, invCheck, shouldSkip : bool;
		var vendorItems : array< SItemUniqueId >;
		var i : int;
		
		inShop = IsInShop();
		shouldSkip = true;
		
		secondaryIngredients.Clear();
		if( !exclude )
		{
			if( ingredientRestriction == 'potionA' )
				secondaryIngredients = albedo;
			else
			if( ingredientRestriction == 'potionR' )
				secondaryIngredients = rubedo;
			else
			if( ingredientRestriction == 'potionN' )
				secondaryIngredients = nigredo;
		}
		
		ingredients = source;
		totalIngredients = ingredients.Size();
		index = ingredients.FindFirst(itemsNames[ingredient]);
		for(i=shiftIndex; shouldSkip; i+=shiftIndex)
		{
			if( shiftIndex > 0 && index >= totalIngredients )
				index =  0;
			else
			if( shiftIndex < 0 && index < 0 )
				index = ingredients.Size() - 1;
			
			invCount = Equipment().GetItemQuantityByNameForCrafting(ingredients[index]);
			if (initializedMenu)
			{			
				if( inShop )
				{					
					vendorItems = m_npcInventory.GetItemsByName(ingredients[index]);
					invCheck = vendorItems.Size() > 0 || invCount > 0;
				}
				else
				{
					invCheck = invCount > 0;
				}
			}
			else
			{
				invCheck = invCount >= GetIngredientQuantity(ingredients[index], ingredient, true);
			}
			
			shouldSkip = (!invCheck) || (itemsNames[ingredient] == ingredients[index] && initializedMenu) || (selectedRecipe.cookedItemName == ingredients[index]);
			if( secondaryIngredients.Size() && !secondaryIngredients.Contains(ingredients[index]) )
				shouldSkip = true;
			
			if( shouldSkip )
			{
				index += shiftIndex;
				if( Abs(i) == totalIngredients )
				{
					if( !initializedMenu )
						return emptyIngr[0];
					else
						return itemsNames[ingredient];
				}
			}
		}
		
		return ingredients[index];
	}
	
	private function GetAlchemyBaseIngredient( out standard, high, top : array <name>, ingredient : int ) : name
	{
		if( top.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[ingredient].itemName) )
			return GetArrayNextIngredient(top, ingredient, true);
		else
		if( high.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[ingredient].itemName) )
			return GetArrayNextIngredient(high, ingredient, true);
		else		
			return GetArrayNextIngredient(standard, ingredient, true);
	}
	
	public function GetIngredientCategory( ingredient : name, optional tooltipText : bool, optional menuText : bool, optional popupText : bool ) : string
	{	
		var category, menuCategory : string;
		
		if( ingredient == '' )
		{
			category = GetLocStringByKeyExt("W3EE_NoIngredientDescr1") + " ";
			if( vitriol.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[selectedIngredient].itemName) )
				category += vitriol_color + GetLocStringByKeyExt("primer_vitriol") + "</font>";
			else
			if( rebis.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[selectedIngredient].itemName) )
				category += rebis_color + GetLocStringByKeyExt("primer_rebis") + "</font>";
			else
			if( aether.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[selectedIngredient].itemName) )
				category += aether_color + GetLocStringByKeyExt("primer_aether") + "</font>";
			else
			if( quebrith.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[selectedIngredient].itemName) )
				category += quebrith_color + GetLocStringByKeyExt("primer_quebrith") + "</font>";
			else
			if( hydragenum.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[selectedIngredient].itemName) )
				category += hydragenum_color + GetLocStringByKeyExt("primer_hydragenum") + "</font>";
			else
			if( vermilion.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[selectedIngredient].itemName) )
				category += vermilion_color + GetLocStringByKeyExt("primer_vermilion") + "</font>";
			else
			if( mutRedUnique.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[selectedIngredient].itemName) )
				category += vermilion_color + originalRecipes[selectedRecipeIndex].requiredIngredients[selectedIngredient].itemName + "</font>";
			else
			if( mutGreenUnique.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[selectedIngredient].itemName) )
				category += rebis_color + originalRecipes[selectedRecipeIndex].requiredIngredients[selectedIngredient].itemName + "</font>";
			else
			if( mutBlueUnique.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[selectedIngredient].itemName) )
				category += vitriol_color + originalRecipes[selectedRecipeIndex].requiredIngredients[selectedIngredient].itemName + "</font>";
			else
			if( mutagenRed.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[selectedIngredient].itemName) )
				category += vermilion_color + GetLocStringByKeyExt("W3EE_MutagenRed") + "</font>";
			else
			if( mutagenGreen.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[selectedIngredient].itemName) )
				category += rebis_color + GetLocStringByKeyExt("W3EE_MutagenGreen") + "</font>";
			else
			if( mutagenBlue.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[selectedIngredient].itemName) )
				category += vitriol_color + GetLocStringByKeyExt("W3EE_MutagenBlue") + "</font>";
			else
			if( strong.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[selectedIngredient].itemName) )
				category += GetLocStringByKeyExt("primer_ing_cat1");
			else
			if( medium.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[selectedIngredient].itemName) )
				category += GetLocStringByKeyExt("primer_ing_cat2");
			else
			if( weak.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[selectedIngredient].itemName) || fancy.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[selectedIngredient].itemName) )
				category += GetLocStringByKeyExt("primer_ing_cat3");
			else
			if( greaseTop.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[selectedIngredient].itemName) )
				category += GetLocStringByKeyExt("primer_ing_cat4");
			else
			if( greaseHigh.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[selectedIngredient].itemName) )
				category += GetLocStringByKeyExt("primer_ing_cat5");
			else
			if( greaseLow.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[selectedIngredient].itemName) )
				category += GetLocStringByKeyExt("primer_ing_cat6");
			else
			if( powderTop.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[selectedIngredient].itemName) )
				category += GetLocStringByKeyExt("primer_ing_cat7");
			else
			if( powderHigh.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[selectedIngredient].itemName) )
				category += GetLocStringByKeyExt("primer_ing_cat8");
			else
			if( powderLow.Contains(originalRecipes[selectedRecipeIndex].requiredIngredients[selectedIngredient].itemName) )
				category += GetLocStringByKeyExt("primer_ing_cat9");
			else
				category += GetLocStringByKeyExt("W3EE_Flask");
				
			category += " " + GetLocStringByKeyExt("W3EE_NoIngredientDescr2");
			return category;
		}
		
		if( primary.Contains(ingredient) && !mutagens.Contains(ingredient) && !strong.Contains(ingredient) )
		{
			category = "";
			if( tooltipText || popupText )
				category += "<br>";
			category += GetLocStringByKeyExt("primer_ing_quantity0");
			
			if( (tooltipText || popupText) && StrFindLast(category, ".") != StrLen(category) - 1 )
				category += ".";
				
			return category;
		}
		else
		if( rare.Contains(ingredient) )
			category = GetLocStringByKeyExt("primer_ing_quantity1");
		else
		if( common.Contains(ingredient) )
			category = GetLocStringByKeyExt("primer_ing_quantity2");
		else
			category = GetLocStringByKeyExt("primer_ing_quantity3");
		
		if( vitriol.Contains(ingredient) )
			category += " " + vitriol_color + GetLocStringByKeyExt("primer_vitriol") + "</font>";
		else
		if( rebis.Contains(ingredient) )
			category += " " + rebis_color + GetLocStringByKeyExt("primer_rebis") + "</font>";
		else
		if( aether.Contains(ingredient) )
			category += " " + aether_color + GetLocStringByKeyExt("primer_aether") + "</font>";
		else
		if( quebrith.Contains(ingredient) )
			category += " " + quebrith_color + GetLocStringByKeyExt("primer_quebrith") + "</font>";
		else
		if( hydragenum.Contains(ingredient) )
			category += " " + hydragenum_color + GetLocStringByKeyExt("primer_hydragenum") + "</font>";
		else
		if( vermilion.Contains(ingredient) )
			category += " " + vermilion_color + GetLocStringByKeyExt("primer_vermilion") + "</font>";
		else
		if( strong.Contains(ingredient) )
		{
			category = GetLocStringByKeyExt("primer_ing_cat1");
			if( menuText && !popupText )
				category = " - " + category;
		}
		else
		if( medium.Contains(ingredient) )
		{
			category = GetLocStringByKeyExt("primer_ing_cat2");
			if( menuText && !popupText )
				category = " - " + category;
		}
		else
		if( weak.Contains(ingredient) || weak.Contains(ingredient) )
		{
			category = GetLocStringByKeyExt("primer_ing_cat3");
			if( menuText && !popupText )
				category = " - " + category;
		}
		else
		if( greaseTop.Contains(ingredient) )
		{
			category = GetLocStringByKeyExt("primer_ing_cat4");
			if( menuText && !popupText )
				category = " - " + category;
		}
		else
		if( greaseHigh.Contains(ingredient) )
		{
			category = GetLocStringByKeyExt("primer_ing_cat5");
			if( menuText && !popupText )
				category = " - " + category;
		}
		else
		if( greaseLow.Contains(ingredient) )
		{
			category = GetLocStringByKeyExt("primer_ing_cat6");
			if( menuText && !popupText )
				category = " - " + category;
		}
		else
		if( powderTop.Contains(ingredient) )
		{
			category = GetLocStringByKeyExt("primer_ing_cat7");
			if( menuText && !popupText )
				category = " - " + category;
		}
		else
		if( powderHigh.Contains(ingredient) )
		{
			category = GetLocStringByKeyExt("primer_ing_cat8");
			if( menuText && !popupText )
				category = " - " + category;
		}
		else
		if( powderLow.Contains(ingredient) )
		{
			category = GetLocStringByKeyExt("primer_ing_cat9");
			if( menuText && !popupText )
				category = " - " + category;
		}
		else
		if( mutagenRed.Contains(ingredient) )
		{
			category = vermilion_color + GetLocStringByKeyExt("W3EE_MutagenRed") + "</font>";
		}
		else
		if( mutagenGreen.Contains(ingredient) )
		{
			category = rebis_color + GetLocStringByKeyExt("W3EE_MutagenGreen") + "</font>";
		}
		else
		if( mutagenBlue.Contains(ingredient) )
		{
			category = vitriol_color + GetLocStringByKeyExt("W3EE_MutagenBlue") + "</font>";
		}
		else
		if( flasks.Contains(ingredient) )
		{
			category = GetLocStringByKeyExt("W3EE_Flask");
		}
		else 
			category = "";
		
		if( category != "" && tooltipText )
			category = "<br>" + category;
		
		if( category != "" && !menuText )
			category += ".";
		
		if( menuText )
		{
			if( albedo.Contains(ingredient) )
				menuCategory = albedo_color + GetLocStringByKeyExt("primer_albedo") + "</font>";
			else
			if( nigredo.Contains(ingredient) )
				menuCategory = nigredo_color + GetLocStringByKeyExt("primer_nigredo") + "</font>";
			else
			if( rubedo.Contains(ingredient) )
				menuCategory = rubedo_color + GetLocStringByKeyExt("primer_rubedo") + "</font>";
			
			if( menuCategory != "" )
				category += " / " + menuCategory;
		}
		else
		{
			if( albedo.Contains(ingredient) )
				category += "<br>" + GetLocStringByKeyExt("W3EE_SecondarySubstance") + albedo_color + GetLocStringByKeyExt("primer_albedo") + "</font>";
			else
			if( nigredo.Contains(ingredient) )
				category += "<br>" + GetLocStringByKeyExt("W3EE_SecondarySubstance") + nigredo_color + GetLocStringByKeyExt("primer_nigredo") + "</font>";
			else
			if( rubedo.Contains(ingredient) )
				category += "<br>" + GetLocStringByKeyExt("W3EE_SecondarySubstance") + rubedo_color + GetLocStringByKeyExt("primer_rubedo") + "</font>";
			
			if( StrFindLast(category, ".") != StrLen(category) - 1 )
				category += ".";
		}
		
		if( category == "" )
			category = GetLocStringByKeyExt(theGame.GetDefinitionsManager().GetItemLocalisationKeyDesc(ingredient));
			
		if( popupText && StrFindLast(category, ".") != StrLen(category) - 1 )
			category += ".";
			
		return category;
	}
	
	private var vitriol, rebis, aether, quebrith, hydragenum, vermilion, albedo, nigredo, rubedo, mutagenRed, mutagenGreen, mutagenBlue, mutRedLow, mutRedHigh, mutRedTop, mutBlueLow, mutBlueHigh, mutBlueTop, mutGreenLow, mutGreenHigh, mutGreenTop, mutRedUnique, mutBlueUnique, mutGreenUnique, mutagenUnique, mutagens, common, rare, primary, flasks : array <name>;
	private var fancy, weak, medium, strong, greaseLow, greaseHigh, greaseTop, powderLow, powderHigh, powderTop : array <name>;
	private var emptyIngr : array <name>;
	public function SetAlchemyCategories()
	{
		var index, mutIndex : int = 3;
		var mutagenArray : array<name>;
		
		SetIngredientCategories();
		while(mutIndex)
		{
			if( mutIndex == 3 )
				mutagenArray = mutagenRed;		
			else
			if( mutIndex == 2 )
				mutagenArray = mutagenGreen;
			else
			if( mutIndex == 1 )
				mutagenArray = mutagenBlue;
			
			mutIndex -= 1;			
			for(index=0; index<mutagenArray.Size(); index+=1)
			{
				mutagens.PushBack(mutagenArray[index]);
			}
		}	
	}
	
	private function SetIngredientCategories()
	{
		var dm : CDefinitionsManagerAccessor;
		var tmpArray : array<name>;
		var i : int;
		
		dm = theGame.GetDefinitionsManager();
		primary		= dm.GetItemsWithTag('primer_primary');
		rare 		= dm.GetItemsWithTag('primer_rare');
		common		= dm.GetItemsWithTag('primer_common');
		
		albedo		= dm.GetItemsWithTag('primer_albedo');
		nigredo		= dm.GetItemsWithTag('primer_nigredo');
		rubedo		= dm.GetItemsWithTag('primer_rubedo');
		
		weak		= dm.GetItemsWithTag('primer_alcohol_weak');
		medium		= dm.GetItemsWithTag('primer_alcohol_medium');
		strong		= dm.GetItemsWithTag('primer_alcohol_strong');
		
		greaseLow	= dm.GetItemsWithTag('primer_grease_low');
		greaseHigh	= dm.GetItemsWithTag('primer_grease_high');
		greaseTop	= dm.GetItemsWithTag('primer_grease_top');
		
		powderLow	= dm.GetItemsWithTag('primer_powder_low');
		powderHigh	= dm.GetItemsWithTag('primer_powder_high');
		powderTop	= dm.GetItemsWithTag('primer_powder_top');
		
		mutagenRed.PushBack('Lesser mutagen red');
		mutagenRed.PushBack('Mutagen red');
		mutagenRed.PushBack('Greater mutagen red');
		ArrayOfNamesAppend(mutagenRed, dm.GetItemsWithTag('primer_mutagen_red'));
		mutagenGreen.PushBack('Lesser mutagen green');
		mutagenGreen.PushBack('Mutagen green');
		mutagenGreen.PushBack('Greater mutagen green');
		ArrayOfNamesAppend(mutagenGreen, dm.GetItemsWithTag('primer_mutagen_green'));
		mutagenBlue.PushBack('Lesser mutagen blue');
		mutagenBlue.PushBack('Mutagen blue');
		mutagenBlue.PushBack('Greater mutagen blue');
		ArrayOfNamesAppend(mutagenBlue, dm.GetItemsWithTag('primer_mutagen_blue'));
		
		mutRedLow.PushBack('Lesser mutagen red');
		mutRedHigh.PushBack('Mutagen red');
		mutRedTop.PushBack('Greater mutagen red');
		
		mutGreenLow.PushBack('Lesser mutagen green');
		mutGreenHigh.PushBack('Mutagen green');
		mutGreenTop.PushBack('Greater mutagen green');
		
		mutBlueLow.PushBack('Lesser mutagen blue');
		mutBlueHigh.PushBack('Mutagen blue');
		mutBlueTop.PushBack('Greater mutagen blue');
		
		for(i=0; i<mutagenRed.Size(); i+=1)
		{
			if( mutagenRed[i] != 'Lesser mutagen red' && mutagenRed[i] != 'Mutagen red' && mutagenRed[i] != 'Greater mutagen red' )
			{
				mutRedUnique.PushBack(mutagenRed[i]);
				mutagenUnique.PushBack(mutagenRed[i]);
			}
		}
		for(i=0; i<mutagenGreen.Size(); i+=1)
		{
			if( mutagenGreen[i] != 'Lesser mutagen green' && mutagenGreen[i] != 'Mutagen green' && mutagenGreen[i] != 'Greater mutagen green' )
			{
				mutGreenUnique.PushBack(mutagenGreen[i]);
				mutagenUnique.PushBack(mutagenGreen[i]);
			}
		}
		for(i=0; i<mutagenBlue.Size(); i+=1)
		{
			if( mutagenBlue[i] != 'Lesser mutagen blue' && mutagenBlue[i] != 'Mutagen blue' && mutagenBlue[i] != 'Greater mutagen blue' )
			{
				mutBlueUnique.PushBack(mutagenBlue[i]);
				mutagenUnique.PushBack(mutagenBlue[i]);
			}
		}
		
		ArrayOfNamesAppend(mutRedTop, dm.GetItemsWithTag('primer_mutagen_red'));
		ArrayOfNamesAppend(mutGreenTop, dm.GetItemsWithTag('primer_mutagen_green'));
		ArrayOfNamesAppend(mutBlueTop, dm.GetItemsWithTag('primer_mutagen_blue'));
		
		ArrayOfNamesAppend(medium, strong);
		ArrayOfNamesAppend(weak, medium);
		
		ArrayOfNamesAppend(common, weak);
		ArrayOfNamesAppend(common, greaseLow);
		ArrayOfNamesAppend(common, powderLow);
		
		ArrayOfNamesAppend(greaseHigh, greaseTop);
		ArrayOfNamesAppend(greaseLow, greaseHigh);
		
		ArrayOfNamesAppend(powderHigh, powderTop);
		ArrayOfNamesAppend(powderLow, powderHigh);
		
		ArrayOfNamesAppend(rare, medium);
		ArrayOfNamesAppend(rare, greaseHigh);
		ArrayOfNamesAppend(rare, powderHigh);
		ArrayOfNamesAppend(rare, mutRedHigh);
		ArrayOfNamesAppend(rare, mutGreenHigh);
		ArrayOfNamesAppend(rare, mutBlueHigh);
		
		ArrayOfNamesAppend(primary, strong);
		ArrayOfNamesAppend(primary, mutRedTop);
		ArrayOfNamesAppend(primary, mutGreenTop);
		ArrayOfNamesAppend(primary, mutBlueTop);
		
		ArrayOfNamesAppend(mutRedHigh, mutRedTop);
		ArrayOfNamesAppend(mutRedLow, mutRedHigh);
		
		ArrayOfNamesAppend(mutGreenHigh, mutGreenTop);
		ArrayOfNamesAppend(mutGreenLow, mutGreenHigh);
		
		ArrayOfNamesAppend(mutBlueHigh, mutBlueTop);
		ArrayOfNamesAppend(mutBlueLow, mutBlueHigh);
		
		vitriol		= GetSortedIngredientCategory('primer_vitriol');
		rebis		= GetSortedIngredientCategory('primer_rebis');
		aether		= GetSortedIngredientCategory('primer_aether');
		quebrith	= GetSortedIngredientCategory('primer_quebrith');
		hydragenum	= GetSortedIngredientCategory('primer_hydragenum');
		vermilion	= GetSortedIngredientCategory('primer_vermilion');
		
		flasks.PushBack('Bottle');
		flasks.PushBack('Empty vial');
		flasks.PushBack('Empty bottle');
		
		fancy.PushBack('Local pepper vodka');
		fancy.PushBack('Beauclair White');
		fancy.PushBack('Dijkstra Dry');
		fancy.PushBack('Erveluce');
		fancy.PushBack('Est Est');
	}
	
	private function GetSortedIngredientCategory( substanceTag : name ) : array<name>
	{
		var unsortedIngredients, sortedIngredients : array<name>;
		var index, size : int;
		var dm : CDefinitionsManagerAccessor;
		var positiveFilters, negativeFilters: array<name>;
		var isHerb, isMonstrous, isMineral, isCommon, isRare : bool;
		
		dm = theGame.GetDefinitionsManager();
		
		unsortedIngredients = dm.GetItemsWithTag(substanceTag);
		
		positiveFilters.PushBack('primer_primary');
		FilterIngredientsByTags(sortedIngredients, unsortedIngredients, positiveFilters, negativeFilters);
		
		positiveFilters.PushBack('primer_herb');
		positiveFilters.PushBack('primer_common');
		FilterIngredientsByTags(sortedIngredients, unsortedIngredients, positiveFilters, negativeFilters);
		
		positiveFilters.PushBack('primer_herb');
		negativeFilters.PushBack('primer_common');
		FilterIngredientsByTags(sortedIngredients, unsortedIngredients, positiveFilters, negativeFilters);
		
		positiveFilters.PushBack('primer_mineral');
		FilterIngredientsByTags(sortedIngredients, unsortedIngredients, positiveFilters, negativeFilters);
		
		positiveFilters.PushBack('primer_monstrous');
		negativeFilters.PushBack('primer_rare');
		FilterIngredientsByTags(sortedIngredients, unsortedIngredients, positiveFilters, negativeFilters);
		
		positiveFilters.PushBack('primer_monstrous');
		positiveFilters.PushBack('primer_rare');
		FilterIngredientsByTags(sortedIngredients, unsortedIngredients, positiveFilters, negativeFilters);
		
		return sortedIngredients;
	}

	private function FilterIngredientsByTags( out sortedList, unsortedList, positiveTags, negativeTags : array<name> )
	{
		var ingredientIndex, filterIndex, size : int;
		var positiveFilter, negativeFilter, positiveTagsPresent, negativeTagsPresent: bool;
		var dm : CDefinitionsManagerAccessor;
		
		dm = theGame.GetDefinitionsManager();
		
		positiveTagsPresent = positiveTags.Size() > 0;
		negativeTagsPresent = negativeTags.Size() > 0;
		
		size = unsortedList.Size();
		for(ingredientIndex = 0; ingredientIndex < size; ingredientIndex += 1)
		{
			positiveFilter = true;
			negativeFilter = false;
			
			if( positiveTagsPresent )
				for(filterIndex = 0; filterIndex < positiveTags.Size(); filterIndex += 1)
					positiveFilter = positiveFilter && dm.ItemHasTag(unsortedList[ingredientIndex], positiveTags[filterIndex]);
			
			if( negativeTagsPresent )
				for(filterIndex = 0; filterIndex < negativeTags.Size(); filterIndex += 1)
					negativeFilter = negativeFilter || dm.ItemHasTag(unsortedList[ingredientIndex], negativeTags[filterIndex]);
			
			if( positiveFilter && !negativeFilter )
			{
				sortedList.PushBack(unsortedList[ingredientIndex]);
				unsortedList.Erase(ingredientIndex);
				ingredientIndex -= 1;
				size -= 1;
			}
		}
		
		positiveTags.Clear();
		negativeTags.Clear();
	}
	// W3EE - End
}
