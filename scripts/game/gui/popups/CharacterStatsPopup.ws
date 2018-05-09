/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/





class CharacterStatsPopupData extends TextPopupData
{	
	var m_flashValueStorage : CScriptedFlashValueStorage;
	
	protected  function GetContentRef() : string 
	{
		return "StatisticsFullRef";
	}
	
	protected  function DefineDefaultButtons():void
	{
		AddButtonDef("panel_button_common_exit", "escape-gamepad_B", IK_Escape);
		AddButtonDef("input_feedback_scroll_text", "gamepad_R_Scroll");
	}
	
	public function  OnUserFeedback( KeyCode:string ) : void
	{
		if (KeyCode == "escape-gamepad_B") 
		{
			ClosePopup();
		}
	}
	
	public  function GetGFxData(parentFlashValueStorage : CScriptedFlashValueStorage) : CScriptedFlashObject 
	{
		var gfxData : CScriptedFlashObject;
		
		m_flashValueStorage = parentFlashValueStorage;
		
		gfxData = parentFlashValueStorage.CreateTempFlashObject();
		GetPlayerStatsGFxData(parentFlashValueStorage);
		gfxData.SetMemberFlashString("ContentRef", GetContentRef());
		
		return gfxData;
	}
}

function GetPlayerStatsGFxData(parentFlashValueStorage : CScriptedFlashValueStorage) : CScriptedFlashObject
{ 
	var statsArray : CScriptedFlashArray;
	var gfxData    : CScriptedFlashObject;
	
	var gfxSilverDamage : CScriptedFlashObject;
	var gfxSteelDamage  : CScriptedFlashObject;
	var gfxArmor 		: CScriptedFlashObject;
	var gfxVitality 	: CScriptedFlashObject;
	var gfxSpellPower 	: CScriptedFlashObject;
	// W3EE - Begin
	var gfxVigorStat 	: CScriptedFlashObject;
	var gfxPoiseStat 	: CScriptedFlashObject;
	var gfxAtkSpdStat 	: CScriptedFlashObject;
	var gfxAdrenaline 	: CScriptedFlashObject;
	// W3EE - End
	var gfxToxicity 	: CScriptedFlashObject;
	var gfxStamina 		: CScriptedFlashObject;
	var gfxCrossbow  	: CScriptedFlashObject;
	var gfxAdditional  	: CScriptedFlashObject;
	
	var gfxSilverDamageSub : CScriptedFlashArray;
	var gfxSteelDamageSub  : CScriptedFlashArray;
	var gfxArmorSub 	   : CScriptedFlashArray;
	var gfxVitalitySub 	   : CScriptedFlashArray;
	var gfxSpellPowerSub   : CScriptedFlashArray;
	// W3EE - Begin
	var gfxVigorStatSub    : CScriptedFlashArray;
	var gfxPoiseStatSub    : CScriptedFlashArray;
	var gfxAtkSpdStatSub   : CScriptedFlashArray;
	var gfxAdrenalineSub   : CScriptedFlashArray;
	// W3EE - End
	var gfxToxicitySub 	   : CScriptedFlashArray;
	var gfxStaminaSub	   : CScriptedFlashArray;
	var gfxCrossbowSub     : CScriptedFlashArray;
	var gfxAdditionalSub   : CScriptedFlashArray;
	
	var gameTime		: GameTime;
	var gameTimeHours	: string;
	var gameTimeMinutes : string;
	
	gfxData = parentFlashValueStorage.CreateTempFlashObject();
	statsArray = parentFlashValueStorage.CreateTempFlashArray();
	
	
	
	
	
	
	
	
	
	

	
	
	gfxSilverDamage = AddCharacterStatU("mainSilverStat", 'silverdamage', "panel_common_statistics_tooltip_silver_dps", "attack_silver", statsArray, parentFlashValueStorage);
	gfxSilverDamageSub = parentFlashValueStorage.CreateTempFlashArray();
	
	AddCharacterHeader("panel_common_statistics_tooltip_silver_dps", gfxSilverDamageSub, parentFlashValueStorage, true, "Red");
	// W3EE - Begin
	AddCharacterHeader("W3EE_LightAtk", gfxSilverDamageSub, parentFlashValueStorage);
	// W3EE - End
	AddCharacterStatU("silverStat1", 'silverFastDPS', "panel_common_statistics_tooltip_silver_fast_dps", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("silverStat2", 'silverFastCritChance', "panel_common_statistics_tooltip_silver_fast_crit_chance", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("silverStat3", 'silverFastCritDmg', "panel_common_statistics_tooltip_silver_fast_crit_dmg", "", gfxSilverDamageSub, parentFlashValueStorage); 
	// W3EE - Begin
	//AddCharacterStatU("Dummy", '', "", "", gfxSilverDamageSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_StrongAtk", gfxSilverDamageSub, parentFlashValueStorage);
	// W3EE - End
	AddCharacterStatU("silverStat4", 'silverStrongDPS', "panel_common_statistics_tooltip_silver_strong_dps", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("silverStat5", 'silverStrongCritChance', "panel_common_statistics_tooltip_silver_strong_crit_chance", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("silverStat6", 'silverStrongCritDmg', "panel_common_statistics_tooltip_silver_strong_crit_dmg", "", gfxSilverDamageSub, parentFlashValueStorage); 	
	// W3EE - Begin
	AddCharacterHeader("W3EE_EffectCh", gfxSilverDamageSub, parentFlashValueStorage);
	//AddCharacterStatU("Dummy", '', "", "", gfxSilverDamageSub, parentFlashValueStorage);
	// W3EE - End
	AddCharacterStatU2("silverStat8", 'silver_desc_poinsonchance_mult', "attribute_name_desc_poinsonchance_mult", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU2("silverStat9", 'silver_desc_bleedingchance_mult', "attribute_name_desc_bleedingchance_mult", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU2("silverStat10", 'silver_desc_burningchance_mult', "attribute_name_desc_burningchance_mult", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU2("silverStat11", 'silver_desc_confusionchance_mult', "attribute_name_desc_confusionchance_mult", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU2("silverStat12", 'silver_desc_freezingchance_mult', "attribute_name_desc_freezingchance_mult", "", gfxSilverDamageSub, parentFlashValueStorage); 
	AddCharacterStatU2("silverStat13", 'silver_desc_staggerchance_mult', "attribute_name_desc_staggerchance_mult", "", gfxSilverDamageSub, parentFlashValueStorage);
	gfxSilverDamage.SetMemberFlashArray("subStats", gfxSilverDamageSub);
	
	
	
	gfxSteelDamage = AddCharacterStatU("mainSteelStat", 'steeldamage', "panel_common_statistics_tooltip_steel_dps", "attack_steel", statsArray, parentFlashValueStorage);
	gfxSteelDamageSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("panel_common_statistics_tooltip_steel_dps", gfxSteelDamageSub, parentFlashValueStorage, true, "Red");
	// W3EE - Begin
	AddCharacterHeader("W3EE_LightAtk", gfxSteelDamageSub, parentFlashValueStorage);
	// W3EE - End
	AddCharacterStatU("steelStat1", 'steelFastDPS', "panel_common_statistics_tooltip_steel_fast_dps", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat2", 'steelFastCritChance', "panel_common_statistics_tooltip_steel_fast_crit_chance", "", gfxSteelDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("steelStat3", 'steelFastCritDmg', "panel_common_statistics_tooltip_steel_fast_crit_dmg", "", gfxSteelDamageSub, parentFlashValueStorage); 
	// W3EE - Begin
	//AddCharacterStatU("defStat7", '', "", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_StrongAtk", gfxSteelDamageSub, parentFlashValueStorage);
	// W3EE - End
	AddCharacterStatU("steelStat4", 'steelStrongDPS', "panel_common_statistics_tooltip_steel_strong_dps", "", gfxSteelDamageSub, parentFlashValueStorage); 
	AddCharacterStatU("steelStat5", 'steelStrongCritChance', "panel_common_statistics_tooltip_steel_strong_crit_chance", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat7", 'steelStrongCritDmg', "panel_common_statistics_tooltip_steel_strong_crit_dmg", "", gfxSteelDamageSub, parentFlashValueStorage);
	// W3EE - Begin
	//AddCharacterStatU("steelStat8", '', "", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_EffectCh", gfxSteelDamageSub, parentFlashValueStorage);
	// W3EE - End
	AddCharacterStatU2("steelStat8", 'steel_desc_poinsonchance_mult', "attribute_name_desc_poinsonchance_mult", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU2("steelStat9", 'steel_desc_bleedingchance_mult', "attribute_name_desc_bleedingchance_mult", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU2("steelStat10", 'steel_desc_burningchance_mult', "attribute_name_desc_burningchance_mult", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU2("steelStat11", 'steel_desc_confusionchance_mult', "attribute_name_desc_confusionchance_mult", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU2("steelStat12", 'steel_desc_freezingchance_mult', "attribute_name_desc_freezingchance_mult", "", gfxSteelDamageSub, parentFlashValueStorage);
	AddCharacterStatU2("steelStat13", 'steel_desc_staggerchance_mult', "attribute_name_desc_staggerchance_mult", "", gfxSteelDamageSub, parentFlashValueStorage);
	gfxSteelDamage.SetMemberFlashArray("subStats", gfxSteelDamageSub);
	
	
	
	gfxArmor = AddCharacterStat("mainResStat", 'armor', "attribute_name_armor", "armor", statsArray, parentFlashValueStorage);
	gfxArmorSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("attribute_name_armor", gfxArmorSub, parentFlashValueStorage, true, "Red");
	// W3EE - Begin
	AddCharacterHeader("W3EE_MeleeResist", gfxArmorSub, parentFlashValueStorage);
	// W3EE - End
	AddCharacterStatF("defStat2", 'slashing_resistance_perc', "slashing_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat3", 'piercing_resistance_perc', "attribute_name_piercing_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat4", 'bludgeoning_resistance_perc', "bludgeoning_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat5", 'rending_resistance_perc', "attribute_name_rending_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	// W3EE - Begin
	AddCharacterHeader("W3EE_ElementResist", gfxArmorSub, parentFlashValueStorage);
	// W3EE - End
	AddCharacterStatF("defStat6", 'elemental_resistance_perc', "attribute_name_elemental_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	// W3EE - Begin
	//AddCharacterStatU("defStat7", '', "", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_EffectResist", gfxArmorSub, parentFlashValueStorage);
	// W3EE - End
	AddCharacterStatF("defStat8", 'poison_resistance_perc', "attribute_name_poison_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat9", 'bleeding_resistance_perc', "attribute_name_bleeding_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStatF("defStat10", 'burning_resistance_perc', "attribute_name_burning_resistance_perc", "", gfxArmorSub, parentFlashValueStorage);
	// W3EE - Begin
	AddCharacterHeader("W3EE_Modifiers", gfxArmorSub, parentFlashValueStorage);
	AddCharacterStat("armorBon", 'armorPoiseBon', "W3EE_PoiseInc", "", gfxArmorSub, parentFlashValueStorage);	
	AddCharacterStat("AtkSpdArm", 'AtkSpdArmor', "W3EE_AtkSpdMod", "", gfxArmorSub, parentFlashValueStorage);
	// W3EE - End
	gfxArmor.SetMemberFlashArray("subStats", gfxArmorSub);
	
	
	
	gfxCrossbow = AddCharacterStat("majorStat4", 'crossbow', "item_category_crossbow", "crossbow", statsArray, parentFlashValueStorage);
	gfxCrossbowSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("item_category_crossbow", gfxCrossbowSub, parentFlashValueStorage, true, "Red");
	AddCharacterHeader("W3EE_DmgValues", gfxCrossbowSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat18", 'crossbowSteelDmg', "attribute_name_piercingdamage", "", gfxCrossbowSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat19", 'crossbowSilverDmg', "attribute_name_silverdamage", "", gfxCrossbowSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_Modifiers", gfxCrossbowSub, parentFlashValueStorage);
	AddCharacterStatU("steelStat17", 'crossbowCritChance', "panel_common_statistics_tooltip_crossbow_crit_chance", "", gfxCrossbowSub, parentFlashValueStorage);
	gfxCrossbow.SetMemberFlashArray("subStats", gfxCrossbowSub);
	
	
	
	gfxVitality =  AddCharacterStat("majorStat1", 'vitality', "vitality", "vitality", statsArray, parentFlashValueStorage);
	gfxVitalitySub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("vitality", gfxVitalitySub, parentFlashValueStorage, true, "Green");
	// W3EE - Begin
	AddCharacterHeader("W3EE_RegenRates", gfxVitalitySub, parentFlashValueStorage);
	AddCharacterStat("defStat12", 'vitalityRegen', "panel_common_statistics_tooltip_outofcombat_regen", "", gfxVitalitySub, parentFlashValueStorage);
	AddCharacterStat("defStat13", 'vitalityCombatRegen', "panel_common_statistics_tooltip_incombat_regen", "", gfxVitalitySub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_Maluses", gfxVitalitySub, parentFlashValueStorage);
	AddCharacterStat("defStat17", 'healthSpeedRed', "W3EE_AtkSpdRed", "", gfxVitalitySub, parentFlashValueStorage);
	AddCharacterStat("defStat18", 'healthPoiseRed', "W3EE_PoiseRed", "", gfxVitalitySub, parentFlashValueStorage);
	AddCharacterStat("vigorStat6", 'healthRegenRed', "W3EE_StamRegenRed", "", gfxVitalitySub, parentFlashValueStorage);
	AddCharacterStat("vigorStat6", 'healthRegenRed', "W3EE_VigRegenRed", "", gfxVitalitySub, parentFlashValueStorage);
	// W3EE - End
	gfxVitality.SetMemberFlashArray("subStats", gfxVitalitySub);
	
	
	
	gfxStamina = AddCharacterStat("majorStat3", 'stamina', "stamina", "stamina", statsArray, parentFlashValueStorage);
	gfxStaminaSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("stamina", gfxStaminaSub, parentFlashValueStorage, true, "Green");
	// W3EE - Begin
	AddCharacterHeader("W3EE_RegenRates", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterStat("defStat14", 'staminaOutOfCombatRegen', "attribute_name_staminaregen_out_of_combat", "", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterStat("defStat15", 'staminaRegen', "attribute_name_staminaregen", "", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_RegenMod", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterStat("defStat19", 'healthRegenRed', "W3EE_StamRegenRedHP", "", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterStat("defStat20", 'toxicRegenRed', "W3EE_StamRegenRedTox", "", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterStat("defStat20", 'adrStamReg', "W3EE_StamRegenIncAdr", "", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_AtkSpdRedH", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterStat("defStat16", 'staminaSpeedRed', "W3EE_AtkSpdRed", "", gfxStaminaSub, parentFlashValueStorage);
	AddCharacterStat("defStat21", 'staminaDamageRed', "W3EE_MeleeDamRed", "", gfxStaminaSub, parentFlashValueStorage);
	// W3EE - End
	gfxStamina.SetMemberFlashArray("subStats", gfxStaminaSub);
	
	
	// W3EE - Begin
	gfxAdrenaline = AddCharacterStat("adrStat", 'adrenaline', "W3EE_Adr", "additional", statsArray, parentFlashValueStorage);
	gfxAdrenalineSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("W3EE_Adr", gfxAdrenalineSub, parentFlashValueStorage, true, "Green");
	AddCharacterHeader("W3EE_RegenRates", gfxAdrenalineSub, parentFlashValueStorage);
	AddCharacterStat("adrGain", 'adrGain', "W3EE_AdrHit", "", gfxAdrenalineSub, parentFlashValueStorage);
	AddCharacterStat("adrGainCounter", 'adrGainCounter', "W3EE_AdrCount", "", gfxAdrenalineSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_Bonuses", gfxAdrenalineSub, parentFlashValueStorage);
	AddCharacterStat("adrStamReg", 'adrStamReg', "W3EE_StamRegenBon", "", gfxAdrenalineSub, parentFlashValueStorage);
	AddCharacterStat("adrVigReg", 'adrVigReg', "W3EE_VigRegenBon", "", gfxAdrenalineSub, parentFlashValueStorage);
	gfxAdrenaline.SetMemberFlashArray("subStats", gfxAdrenalineSub);
	// W3EE - End
	
	
	gfxToxicity = AddCharacterStat("majorStat2", 'toxicity', "attribute_name_toxicity", "toxicity", statsArray, parentFlashValueStorage);
	gfxToxicitySub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("attribute_name_toxicity", gfxToxicitySub, parentFlashValueStorage, true, "Green");	
	// W3EE - Begin
	AddCharacterHeader("W3EE_Base", gfxToxicitySub, parentFlashValueStorage);
	AddCharacterStatToxicity("lockedToxicity", 'lockedToxicity', "toxicity_offset", "", gfxToxicitySub, parentFlashValueStorage);
	AddCharacterStatToxicity("toxicity", 'toxicity', "toxicity", "", gfxToxicitySub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_Maluses", gfxToxicitySub, parentFlashValueStorage);
	AddCharacterStat("toxicstamina", 'toxicRegenRed', "W3EE_StamRegenRed", "", gfxToxicitySub, parentFlashValueStorage);
	AddCharacterStat("toxicvigor", 'toxicRegenRed', "W3EE_VigRegenRed", "", gfxToxicitySub, parentFlashValueStorage);	
	AddCharacterHeader("W3EE_Bonuses", gfxToxicitySub, parentFlashValueStorage);
	AddCharacterStatToxicity("toxicitypoise", 'toxPoiseVal', "W3EE_PoiseInc", "", gfxToxicitySub, parentFlashValueStorage);
	// W3EE - End
	gfxToxicity.SetMemberFlashArray("subStats", gfxToxicitySub);
	
	
	
	gfxSpellPower = AddCharacterStat("mainMagicStat", 'spell_power', "stat_signs", "spell_power", statsArray, parentFlashValueStorage);
	gfxSpellPowerSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("stat_signs", gfxSpellPowerSub, parentFlashValueStorage, true, "Blue");
	AddCharacterHeader("Aard", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("aardStat1", 'spell_power_aard', "spell_power_aard", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("aardStat2", 'aard_damage', "attribute_name_forcedamage", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterHeader("Igni", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("igniStat1", 'spell_power_igni', "spell_power_igni", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("igniStat2", 'igni_damage', "attribute_name_firedamage", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterHeader("Quen", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("quenStat1", 'spell_power_quen', "spell_power_quen", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("quenStat3", 'quen_duration', "duration", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterHeader("Yrden", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("yrdenStat1", 'spell_power_yrden', "spell_power_yrden", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("yrdenStat2", 'yrden_slowdown', "SlowdownEffect", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("yrdenStat3", 'yrden_damage', "ShockDamage", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("yrdenStat4", 'yrden_duration', "duration", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterHeader("Axii", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("axiiStat1", 'spell_power_axii', "spell_power_axii", "", gfxSpellPowerSub, parentFlashValueStorage);
	AddCharacterStatSigns("axiiStat2", 'axii_duration_confusion', "duration", "", gfxSpellPowerSub, parentFlashValueStorage);
	gfxSpellPower.SetMemberFlashArray("subStats", gfxSpellPowerSub);



	// W3EE - Begin
	gfxVigorStat = AddCharacterStat("majorStat6", 'focus', "W3EE_Vigor", "toxicity", statsArray, parentFlashValueStorage);
	gfxVigorStatSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("W3EE_Vigor", gfxVigorStatSub, parentFlashValueStorage, true, "Blue");
	AddCharacterHeader("W3EE_RegenRates", gfxVigorStatSub, parentFlashValueStorage);
	AddCharacterStatSigns("vigorStat1", 'vigorRegen', "W3EE_VigReg", "", gfxVigorStatSub, parentFlashValueStorage);
	AddCharacterStatSigns("vigorStat2", 'vigorRegenDelay', "W3EE_VigDelay", "", gfxVigorStatSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_RegenMod", gfxVigorStatSub, parentFlashValueStorage);
	AddCharacterStat("vigorStat6", 'healthRegenRed', "W3EE_VigRegenRedHP", "", gfxVigorStatSub, parentFlashValueStorage);
	AddCharacterStat("vigorStat7", 'toxicRegenRed', "W3EE_VigRegenRedTox", "", gfxVigorStatSub, parentFlashValueStorage);
	AddCharacterStat("vigorStat8", 'adrVigReg', "W3EE_VigRegenIncAdr", "", gfxVigorStatSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_LossRate", gfxVigorStatSub, parentFlashValueStorage);
	AddCharacterStatSigns("vigorStat3", 'vigorLossLight', "W3EE_VigLossL", "", gfxVigorStatSub, parentFlashValueStorage);
	AddCharacterStatSigns("vigorStat4", 'vigorLossHeavy', "W3EE_VigLossH", "", gfxVigorStatSub, parentFlashValueStorage);
	AddCharacterStatSigns("vigorStat5", 'vigorLossSHeavy', "W3EE_VigLossSH", "", gfxVigorStatSub, parentFlashValueStorage);
	gfxVigorStat.SetMemberFlashArray("subStats", gfxVigorStatSub);



	gfxPoiseStat = AddCharacterStat("majorStat7", 'poise', "W3EE_Poise", "armor", statsArray, parentFlashValueStorage);
	gfxPoiseStatSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("W3EE_AvPoise", gfxPoiseStatSub, parentFlashValueStorage, true, "Brown");
	AddCharacterStat("poiseStat1", 'poiseValue', "W3EE_CurPoise", "", gfxPoiseStatSub, parentFlashValueStorage);
	AddCharacterStat("poiseStat2", 'poiseResHeavy', "W3EE_ResistUnbl", "", gfxPoiseStatSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_Modifiers", gfxPoiseStatSub, parentFlashValueStorage, true, "Brown");
	AddCharacterHeader("W3EE_HP", gfxPoiseStatSub, parentFlashValueStorage);
	AddCharacterStat("poiseStat3", 'healthPoiseRed', "W3EE_PoiseRed", "", gfxPoiseStatSub, parentFlashValueStorage);	
	AddCharacterHeader("W3EE_Tox", gfxPoiseStatSub, parentFlashValueStorage);
	AddCharacterStatToxicity("poiseStat4", 'toxPoiseVal', "W3EE_PoiseInc", "", gfxPoiseStatSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_Mut", gfxPoiseStatSub, parentFlashValueStorage);
	AddCharacterStat("poiseStat5", 'poiseMutBon', "W3EE_PoiseInc", "", gfxPoiseStatSub, parentFlashValueStorage);	
	AddCharacterHeader("attribute_name_armor", gfxPoiseStatSub, parentFlashValueStorage);
	AddCharacterStat("poiseStat6", 'armorPoiseBon', "W3EE_PoiseInc", "", gfxPoiseStatSub, parentFlashValueStorage);	
	AddCharacterHeader("W3EE_Moment", gfxPoiseStatSub, parentFlashValueStorage);
	AddCharacterStat("poiseStat7", 'poiseMomBon', "W3EE_PoiseInc", "", gfxPoiseStatSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_Other", gfxPoiseStatSub, parentFlashValueStorage);
	AddCharacterStat("poiseStat8", 'poiseDecBon', "W3EE_PoiseInc", "", gfxPoiseStatSub, parentFlashValueStorage);
	gfxPoiseStat.SetMemberFlashArray("subStats", gfxPoiseStatSub);



	gfxAtkSpdStat = AddCharacterStat("majorStat8", 'AtkSpdLight', "W3EE_AtkSpdL", "attack_silver", statsArray, parentFlashValueStorage);
	gfxAtkSpdStatSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("W3EE_AtkSpd", gfxAtkSpdStatSub, parentFlashValueStorage, true, "Brown");
	AddCharacterStat("AtkSpdStat1", 'AtkSpdBase', "W3EE_BaseAtkSpd", "", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterStat("AtkSpdStat1", 'AtkSpdLightV', "W3EE_TotalAtkSpd", "", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_AtkSpdModH", gfxAtkSpdStatSub, parentFlashValueStorage, true, "Brown");
	AddCharacterHeader("W3EE_HP", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterStat("AtkSpdStat3", 'healthSpeedRed', "W3EE_AtkSpdRed", "", gfxAtkSpdStatSub, parentFlashValueStorage);	
	AddCharacterHeader("W3EE_Stam", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterStat("AtkSpdStat4", 'staminaSpeedRed', "W3EE_AtkSpdRed", "", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterHeader("attribute_name_armor", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterStat("AtkSpdStat5", 'AtkSpdArmor', "W3EE_AtkSpdMod", "", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_Skill", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterStat("AtkSpdStat6", 'AtkSpdMM', "W3EE_AtkSpdIncSk1", "", gfxAtkSpdStatSub, parentFlashValueStorage);	
	AddCharacterStat("AtkSpdStat7", 'AtkSpdVigL', "W3EE_AtkSpdIncSk2", "", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_Other", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterStat("AtkSpdStat8", 'AtkSpdOtherL', "W3EE_AtkSpdMod", "", gfxAtkSpdStatSub, parentFlashValueStorage);
	gfxAtkSpdStat.SetMemberFlashArray("subStats", gfxAtkSpdStatSub);



	gfxAtkSpdStat = AddCharacterStat("majorStat9", 'AtkSpdHeavy', "W3EE_AtkSpdH", "attack_steel", statsArray, parentFlashValueStorage);
	gfxAtkSpdStatSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("W3EE_AtkSpd", gfxAtkSpdStatSub, parentFlashValueStorage, true, "Brown");
	AddCharacterStat("AtkSpdStat9", 'AtkSpdBase', "W3EE_BaseAtkSpd", "", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterStat("AtkSpdStat10", 'AtkSpdHeavyV', "W3EE_TotalAtkSpd", "", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_AtkSpdModH", gfxAtkSpdStatSub, parentFlashValueStorage, true, "Brown");
	AddCharacterHeader("W3EE_HP", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterStat("AtkSpdStat11", 'healthSpeedRed', "W3EE_AtkSpdRed", "", gfxAtkSpdStatSub, parentFlashValueStorage);	
	AddCharacterHeader("W3EE_Stam", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterStat("AtkSpdStat12", 'staminaSpeedRed', "W3EE_AtkSpdRed", "", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterHeader("attribute_name_armor", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterStat("AtkSpdStat13", 'AtkSpdArmor', "W3EE_AtkSpdMod", "", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_Skill", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterStat("AtkSpdStat14", 'AtkSpdST', "W3EE_AtkSpdIncSk3", "", gfxAtkSpdStatSub, parentFlashValueStorage);	
	AddCharacterStat("AtkSpdStat15", 'AtkSpdVigH', "W3EE_AtkSpdIncSk2", "", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterHeader("W3EE_Other", gfxAtkSpdStatSub, parentFlashValueStorage);
	AddCharacterStat("AtkSpdStat8", 'AtkSpdOtherH', "W3EE_AtkSpdMod", "", gfxAtkSpdStatSub, parentFlashValueStorage);
	gfxAtkSpdStat.SetMemberFlashArray("subStats", gfxAtkSpdStatSub);
	// W3EE - End



	gfxAdditional = AddCharacterStat("majorStat5", 'additional', "panel_common_statistics_category_additional", "additional", statsArray, parentFlashValueStorage);
	gfxAdditionalSub = parentFlashValueStorage.CreateTempFlashArray();
	AddCharacterHeader("panel_common_statistics_category_additional", gfxAdditionalSub, parentFlashValueStorage, true, "Brown");
	// W3EE - Begin
	AddCharacterHeader("W3EE_AddStats", gfxAdditionalSub, parentFlashValueStorage);
	// W3EE - End
	AddCharacterStatF("extraStat1", 'bonus_herb_chance', "bonus_herb_chance", "", gfxAdditionalSub, parentFlashValueStorage);
	AddCharacterStatU("extraStat2", 'instant_kill_chance_mult', "instant_kill_chance", "", gfxAdditionalSub , parentFlashValueStorage);
	AddCharacterStatU("extraStat3", 'human_exp_bonus_when_fatal', "human_exp_bonus_when_fatal", "", gfxAdditionalSub , parentFlashValueStorage);
	AddCharacterStatU("extraStat4", 'nonhuman_exp_bonus_when_fatal', "nonhuman_exp_bonus_when_fatal", "", gfxAdditionalSub , parentFlashValueStorage);
	// W3EE - Begin
	AddCharacterHeader("W3EE_EvSpeedH", gfxAdditionalSub, parentFlashValueStorage);
	AddCharacterStat("extraStat5", 'EvadeSpeed', "W3EE_EvSpeed", "", gfxAdditionalSub, parentFlashValueStorage);	
	AddCharacterHeader("W3EE_DmgMult", gfxAdditionalSub, parentFlashValueStorage);
	AddCharacterStat("damageModStat1", 'sDamMult', "W3EE_MelDamageMult", "", gfxAdditionalSub, parentFlashValueStorage);
	AddCharacterStat("damageModStat2", 'cDamMult', "W3EE_RangDamageMult", "", gfxAdditionalSub, parentFlashValueStorage);
	AddCharacterStat("damageModStat3", 'siDamMult', "W3EE_SignDamageMult", "", gfxAdditionalSub, parentFlashValueStorage);
	AddCharacterStat("damageModStat4", 'bDamMult', "W3EE_BombDamageMult", "", gfxAdditionalSub, parentFlashValueStorage);
	// W3EE - End
	gfxAdditional.SetMemberFlashArray("subStats", gfxAdditionalSub);
	
	
	
	gameTime =	theGame.CalculateTimePlayed();
	gameTimeHours = (string)(GameTimeDays(gameTime) * 24 + GameTimeHours(gameTime));
	gameTimeMinutes = (string)GameTimeMinutes(gameTime);
	
	gfxData.SetMemberFlashArray("stats", statsArray);
	gfxData.SetMemberFlashString("hoursPlayed", gameTimeHours);
	gfxData.SetMemberFlashString("minutesPlayed", gameTimeMinutes);
	
	return gfxData;
	
	
	
	
}

function AddCharacterHeader(locKey:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage, optional isSuperHeader : bool, optional color : string):void
{
	var statObject : CScriptedFlashObject;
	
	// W3EE - Begin
	var finalname 		: string;
	
	finalname = GetLocStringByKeyExt(locKey); 

	if ( finalname == "#" || finalname == "" )
		finalname = locKey;
	// W3EE - End
	
	statObject = flashMaster.CreateTempFlashObject();
	
	// W3EE - Begin
	statObject.SetMemberFlashString("name", finalname);
	// W3EE - End
	statObject.SetMemberFlashString("value", "");
	
	if (isSuperHeader)
	{
		statObject.SetMemberFlashString("tag", "SuperHeader");
		statObject.SetMemberFlashString("backgroundColor", color);
	}
	else
	{
		statObject.SetMemberFlashString("tag", "Header");
	}
	
	statObject.SetMemberFlashString("iconTag", "");
	toArray.PushBackFlashObject(statObject);
}

function AddCharacterStat(tag : string, varKey:name, locKey:string, iconTag:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage):CScriptedFlashObject
{
	var statObject 		: CScriptedFlashObject;
	var valueStr 		: string;
	var valueMaxStr 	: string;
	var valueAbility 	: float;
	var final_name 		: string;
	var sp 				: SAbilityAttributeValue;
	var itemColor		: string;
	
	var gameTime		: GameTime;
	var gameTimeDays	: string;
	var gameTimeHours	: string;
	var gameTimeMinutes	: string;
	var gameTimeSeconds	: string;

	// W3EE - Begin
	var armorPieces : array<SArmorCount>;
	var playerWitcher : W3PlayerWitcher;
	var adrGain, min : SAbilityAttributeValue;
	var actionPoiseBonus, poiseVal, poiseThreshold, clampVal : float;	
	var lightAttackSpeed, heavyAttackSpeed, evadeSpeed : float;
	var adrenalineEffect : W3Effect_CombatAdrenaline;
	
	playerWitcher = GetWitcherPlayer();
	adrenalineEffect = playerWitcher.GetAdrenalineEffect();
	armorPieces = playerWitcher.GetArmorCountOrig();		
	poiseThreshold = 100;
	
	if( playerWitcher.CanUseSkill(S_Perk_06) )
		poiseThreshold -= armorPieces[2].all * 7.5f;
	
	actionPoiseBonus = 1.f;
	
	if( playerWitcher.IsInCombatAction_Attack() )
		actionPoiseBonus += 0.22f;
	
	if( playerWitcher.IsInCombatAction_SpecialAttack() )
		actionPoiseBonus += 0.10f;
	
	if( playerWitcher.IsCurrentlyDodging() )
		actionPoiseBonus += 0.24f;
	
	if( playerWitcher.GetIsSprinting() )
		actionPoiseBonus += 0.29f;
	else
	if( playerWitcher.GetIsRunning() )
		actionPoiseBonus += 0.18f;
	
	poiseVal = ( Combat().BaseStatsPoiseValue(playerWitcher) + Combat().SkillsPoiseValue(playerWitcher) + Combat().ArmorPoiseValue(armorPieces) + Combat().RedMutagenPoiseValue() ) * Combat().HPPoiseRatio(playerWitcher) * actionPoiseBonus * 100 + (playerWitcher.GetMutagen15() * 5.f);

	if( Options().SkillDependant() )
	{
		lightAttackSpeed = Combat().FastAttackSpeedModule(true);
		heavyAttackSpeed = Combat().HeavyAttackSpeedModule(true);
		evadeSpeed = Combat().EvadeSpeedModule(true);
	}
	else
	{
		lightAttackSpeed = Options().FAIN();
		heavyAttackSpeed = Options().HAIN();
		evadeSpeed = Options().DAIN();
	}
	// W3EE - End
	
	statObject			= 	flashMaster.CreateTempFlashObject();
	
	gameTime			=	theGame.CalculateTimePlayed();
	gameTimeDays 		= 	(string)GameTimeDays(gameTime);
	gameTimeHours 		= 	(string)GameTimeHours(gameTime);
	gameTimeMinutes 	= 	(string)GameTimeMinutes(gameTime);
	gameTimeSeconds 	= 	(string)GameTimeSeconds(gameTime);
	
	valueMaxStr = "";
	itemColor = "";

	if ( varKey == 'vitality' )
	{
		valueStr = (string)RoundMath(thePlayer.GetStat(BCS_Vitality, true));
		valueMaxStr = (string)RoundMath(thePlayer.GetStatMax(BCS_Vitality));
		itemColor = "Green";
	}
	else if ( varKey == 'toxicity' )
	{
		valueStr = (string)RoundMath(thePlayer.GetStat(BCS_Toxicity, false));
		valueMaxStr = (string)RoundMath(thePlayer.GetStatMax(BCS_Toxicity));
		itemColor = "Green";
	}
	else if ( varKey == 'stamina' ) 	
	{ 
		valueStr = (string)RoundMath(thePlayer.GetStat(BCS_Stamina, true));
		valueMaxStr = (string)RoundMath(thePlayer.GetStatMax(BCS_Stamina)); 
		itemColor = "Green";
	}
	// W3EE - Begin
	else if ( varKey == 'spell_power' )
	{
		/*
		sp += GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_1);
		sp += GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_2);
		sp += GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_3);
		sp += GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_4);
		sp += GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_5);
		
		valueAbility = sp.valueMultiplicative / 5;
		*/
		sp = GetWitcherPlayer().GetTotalSpellPower();
		valueAbility = sp.valueMultiplicative;
		valueStr = (string)RoundMath(valueAbility * 100) + " %";
		
		itemColor = "Blue";
	}
	// W3EE - End
	else if ( varKey == 'vitalityRegen' ) 
	{ 
		valueStr = NoTrailZeros(RoundMath(CalculateAttributeValue( GetWitcherPlayer().GetAttributeValue( varKey ) ))) + "/" + GetLocStringByKeyExt("per_second");
	}
	else if ( varKey == 'vitalityCombatRegen' ) 
	{ 
		valueStr = NoTrailZeros(RoundMath(CalculateAttributeValue( GetWitcherPlayer().GetAttributeValue( varKey ) ))) + "/" + GetLocStringByKeyExt("per_second");
	}
	// W3EE - Begin
	else if ( varKey == 'staminaRegen' ) 
	{
		clampVal = 0.6f - 0.06f * GetWitcherPlayer().GetSkillLevel(S_Alchemy_s20);
		
		sp = GetWitcherPlayer().GetAttributeValue('staminaRegen');
		valueAbility = sp.valueAdditive + sp.valueMultiplicative * GetWitcherPlayer().GetStatMax(BCS_Stamina);
		
		valueAbility *= 1 + GetWitcherPlayer().CalculatedArmorStaminaRegenBonus();
		
		valueAbility *= GetWitcherPlayer().GetStatPercents(BCS_Vitality);
		
		valueAbility *= 1 - (clampVal * GetWitcherPlayer().GetStatPercents(BCS_Toxicity));
		
		valueAbility *= 1.f + GetWitcherPlayer().GetAdrenalineEffect().GetValue();
		
		valueStr = NoTrailZeros(RoundMath(valueAbility)) + "/" + GetLocStringByKeyExt("per_second"); 
	}
	else if ( varKey == 'staminaOutOfCombatRegen' ) 
	{
		clampVal = 0.6f - 0.06f * GetWitcherPlayer().GetSkillLevel(S_Alchemy_s20);
		
		sp = GetWitcherPlayer().GetAttributeValue('staminaRegen');
		valueAbility = sp.valueAdditive + sp.valueMultiplicative * GetWitcherPlayer().GetStatMax(BCS_Stamina);
		
		valueAbility *= 1 + GetWitcherPlayer().CalculatedArmorStaminaRegenBonus();
		
		valueAbility *= GetWitcherPlayer().GetStatPercents(BCS_Vitality);
		
		valueAbility *= 1 - (clampVal * GetWitcherPlayer().GetStatPercents(BCS_Toxicity));
		
		valueAbility *= 1.f + GetWitcherPlayer().GetAdrenalineEffect().GetValue();
		
		valueStr = NoTrailZeros(RoundMath(valueAbility)) + "/" + GetLocStringByKeyExt("per_second"); 
	}
	else if ( varKey == 'healthRegenRed' ) 
	{
		valueAbility =  ( PowF(1.f - GetWitcherPlayer().GetStatPercents(BCS_Vitality), 2) * 0.75f ) * 100;
		valueStr = NoTrailZeros(RoundMath(valueAbility)) + "%"; 
	}
	else if ( varKey == 'toxicRegenRed' ) 
	{
		valueAbility =  (0.6f - 0.06f * GetWitcherPlayer().GetSkillLevel(S_Alchemy_s20)) * GetWitcherPlayer().GetStatPercents(BCS_Toxicity) * 100;
		
		valueStr = NoTrailZeros(RoundMath(valueAbility)) + "%"; 
	}
	else if ( varKey == 'staminaSpeedRed' ) 
	{
		valueAbility =  PowF(1 - thePlayer.GetStatPercents(BCS_Stamina), 2) * Options().StamRed();
		valueStr = NoTrailZeros(RoundMath(valueAbility)) + "%"; 
	}
	else if ( varKey == 'staminaDamageRed' ) 
	{
		valueAbility =  PowF(1 - thePlayer.GetStatPercents(BCS_Stamina), 2) * 0.4f * 100;
		valueStr = NoTrailZeros(RoundMath(valueAbility)) + "%"; 
	}
	else if ( varKey == 'healthSpeedRed' ) 
	{
		valueAbility =  PowF(1 - thePlayer.GetStatPercents(BCS_Vitality), 2) * Options().HPRed() * ( 1 - (thePlayer.GetSkillLevel(S_Sword_s16) * 0.1) );
		valueStr = NoTrailZeros(RoundMath(valueAbility)) + "%"; 
	}
	else if ( varKey == 'healthPoiseRed' ) 
	{
		valueAbility =  ( 1 - ClampF( thePlayer.GetStatPercents(BCS_Vitality) * 1.3f, 0.7f, 1.0f ) ) * 100;
		valueStr = NoTrailZeros(RoundMath(valueAbility)) + "%"; 
	}
	else if ( varKey == 'armorPoiseBon' ) 
	{
		valueAbility =  Combat().ArmorPoiseValue(armorPieces) * 100;
		valueStr = NoTrailZeros(RoundMath(valueAbility)); 
	}
	else if ( varKey == 'focus' )
	{
		valueStr = (string)NoTrailZeros(RoundTo(thePlayer.GetStat(BCS_Focus, true), 2));
		valueMaxStr = (string)RoundMath(thePlayer.GetStatMax(BCS_Focus));
		itemColor = "Blue";
	}
	else if ( varKey == 'poise' )
	{
		valueStr = (string)NoTrailZeros(RoundMath(poiseVal));
		itemColor = "Brown";
	}
	else if ( varKey == 'AtkSpdLight' )
	{
		valueAbility = lightAttackSpeed;
		
		if( Options().SpeedCap() )
			valueAbility = MinF(valueAbility, 2.2f);
			
		if( Options().SpeedCapLow() )
			valueAbility = MaxF(valueAbility, 0.55f);
			
		valueAbility *= 100;
		
		valueStr = (string)NoTrailZeros(RoundMath(valueAbility)) + "%";
		itemColor = "Brown";
	}
	else if ( varKey == 'AtkSpdHeavy' )
	{
		valueAbility = heavyAttackSpeed;
		
		if( Options().SpeedCap() )
			valueAbility = MinF(valueAbility, 2.2f);
			
		if( Options().SpeedCapLow() )
			valueAbility = MaxF(valueAbility, 0.55f);
			
		valueAbility *= 100;
		
		valueStr = (string)NoTrailZeros(RoundMath(valueAbility)) + "%";
		itemColor = "Brown";
	}
	else if ( varKey == 'AtkSpdLightV' )
	{
		valueAbility = lightAttackSpeed;
		
		if( Options().SpeedCap() )
			valueAbility = MinF(valueAbility, 2.2f);
			
		if( Options().SpeedCapLow() )
			valueAbility = MaxF(valueAbility, 0.55f);
			
		valueAbility *= 100;
		
		valueStr = (string)NoTrailZeros(RoundMath(valueAbility)) + "%";
	}
	else if ( varKey == 'AtkSpdHeavyV' )
	{
		valueAbility = heavyAttackSpeed;
		
		if( Options().SpeedCap() )
			valueAbility = MinF(valueAbility, 2.2f);
			
		if( Options().SpeedCapLow() )
			valueAbility = MaxF(valueAbility, 0.55f);
			
		valueAbility *= 100;
		
		valueStr = (string)NoTrailZeros(RoundMath(valueAbility)) + "%";
	}
	else if ( varKey == 'AtkSpdBase' )
	{
		valueStr = (string)NoTrailZeros(RoundMath(Combat().BaseActionSpeed(true) * 100)) + "%";
	}
	else if ( varKey == 'AtkSpdVigH' )
	{
		valueStr = (string)NoTrailZeros(FloorF(playerWitcher.GetStat(BCS_Focus) * playerWitcher.GetSkillLevel(S_Sword_s20) * 0.4f)) + "%";
	}
	else if ( varKey == 'AtkSpdVigL' )
	{
		valueStr = (string)NoTrailZeros(FloorF(playerWitcher.GetStat(BCS_Focus) * playerWitcher.GetSkillLevel(S_Sword_s20) * 0.2f)) + "%";
	}
	else if ( varKey == 'AtkSpdMM' )
	{
		valueStr = (string)NoTrailZeros(FloorF(playerWitcher.GetSkillLevel(S_Sword_s21) * 3.4f)) + "%";
	}
	else if ( varKey == 'AtkSpdST' )
	{
		valueStr = (string)NoTrailZeros(FloorF(playerWitcher.GetSkillLevel(S_Sword_s04) * 4.5f)) + "%";
	}
	else if ( varKey == 'AtkSpdArmor' )
	{
		valueStr = (string)NoTrailZeros(RoundMath(Combat().CalcArmorPenalty(GetWitcherPlayer(), true) * 100)) + "%";
	}
	else if ( varKey == 'AtkSpdOtherL' )
	{
		min = playerWitcher.GetAttributeValue('attack_speed_fast_style');
		valueStr = (string)NoTrailZeros(RoundTo(min.valueMultiplicative * 100, 1)) + "%";
	}
	else if ( varKey == 'AtkSpdOtherH' )
	{
		min = playerWitcher.GetAttributeValue('attack_speed_strong_style');
		valueStr = (string)NoTrailZeros(RoundTo(min.valueMultiplicative * 100, 1)) + "%";
	}
	else if ( varKey == 'EvadeSpeed' )
	{
		valueStr = (string)NoTrailZeros(RoundMath(evadeSpeed * 100)) + "%";
	}
	else if ( varKey == 'sDamMult' )
	{
		valueStr = (string)NoTrailZeros(RoundMath(Damage().pdam * 100)) + "%";
	}
	else if ( varKey == 'cDamMult' )
	{
		valueStr = (string)NoTrailZeros(RoundMath(Damage().pdamc * 100)) + "%";
	}
	else if ( varKey == 'siDamMult' )
	{
		valueStr = (string)NoTrailZeros(RoundMath(Damage().pdams * 100)) + "%";
	}
	else if ( varKey == 'bDamMult' )
	{
		valueStr = (string)NoTrailZeros(RoundMath(Damage().pdamb * 100)) + "%";
	}
	else if ( varKey == 'poiseValue' )
	{
		valueStr = (string)NoTrailZeros(RoundMath(poiseVal)) + "/100";
	}
	else if ( varKey == 'poiseResHeavy' )
	{
		if( poiseVal > poiseThreshold )
			valueStr = "Yes";
		else valueStr = "No";
	}
	else if ( varKey == 'poiseMutBon' )
	{
		valueAbility = Combat().RedMutagenPoiseValue() * 100;
		valueStr = NoTrailZeros(RoundMath(valueAbility));
	}
	else if ( varKey == 'poiseMomBon' )
	{
		valueAbility = (actionPoiseBonus - 1) * 100;
		valueStr = NoTrailZeros(RoundMath(valueAbility)) + "%";
	}
	else if ( varKey == 'poiseDecBon' )
	{
		valueAbility = GetWitcherPlayer().GetMutagen15() * 0.05 * 100;
		valueAbility += Combat().SkillsPoiseValue(GetWitcherPlayer()) * 100;
		valueStr = NoTrailZeros(RoundMath(valueAbility));
	}
	else if ( varKey == 'adrenaline' )
	{
		valueStr = NoTrailZeros(adrenalineEffect.GetDisplayCount());
		valueMaxStr = IntToString(100 + 10 * playerWitcher.GetSkillLevel(S_Alchemy_s18));
		itemColor = "Green";
	}
	else if ( varKey == 'adrGain' )
	{
		adrGain = playerWitcher.GetAttributeValue('focus_gain');
		
		valueAbility = 0.006f * (adrGain.valueAdditive + adrGain.valueMultiplicative + adrGain.valueBase);
		valueStr = NoTrailZeros(RoundTo(valueAbility * 100, 2));
		valueAbility = 0.024f * (adrGain.valueAdditive + adrGain.valueMultiplicative + adrGain.valueBase);
		valueStr += " - " + NoTrailZeros(RoundTo(valueAbility * 100, 2));
	}
	else if ( varKey == 'adrGainCounter' )
	{
		adrGain = playerWitcher.GetAttributeValue('focus_gain');
		
		valueAbility = 0.014f * (adrGain.valueAdditive + adrGain.valueMultiplicative + adrGain.valueBase);
		valueStr = NoTrailZeros(RoundTo(valueAbility * 100, 2));
		valueAbility = 0.05f * (adrGain.valueAdditive + adrGain.valueMultiplicative + adrGain.valueBase);
		valueStr += " - " + NoTrailZeros(RoundTo(valueAbility * 100, 2));
	}
	else if ( varKey == 'adrStamReg' )
	{
		valueStr = NoTrailZeros(RoundMath(adrenalineEffect.GetDisplayCount() * 1.5)) + "%"; 
	}
	else if ( varKey == 'adrVigReg' )
	{
		valueStr = NoTrailZeros(RoundMath(adrenalineEffect.GetDisplayCount())) + "%"; 
	}
	else if( varKey == 'armor')
	{	
		valueAbility =  CalculateAttributeValue( GetWitcherPlayer().GetTotalArmor() );
		//valueAbility *= 1.f + ((valueAbility - 384) / 900);
		
		valueStr = IntToString( RoundMath(  valueAbility ) );
		itemColor = "Red";
	}
	// W3EE - End
	else if (varKey == 'crossbow')
	{
		valueStr = NoTrailZeros(RoundMath(GetEquippedCrossbowDamage() * Damage().pdamc));
		itemColor = "Red";
	}	
	else if (varKey == 'additional')
	{
		valueStr = "";
		itemColor = "Brown";
	}
	else
	{	
		valueAbility =  CalculateAttributeValue( GetWitcherPlayer().GetAttributeValue( varKey ) );
		valueStr = IntToString( RoundMath(  valueAbility ) );
	}
	
	final_name = GetLocStringByKeyExt(locKey);
	
	// W3EE - Begin
	if ( final_name == "#" || final_name == "" )
		final_name = locKey;
	// W3EE - End
	
	statObject.SetMemberFlashString("name", final_name);
	statObject.SetMemberFlashString("value", valueStr);
	statObject.SetMemberFlashString("maxValue", valueMaxStr);
	statObject.SetMemberFlashString("tag", tag);
	statObject.SetMemberFlashString("iconTag", iconTag);
	statObject.SetMemberFlashString("itemColor", itemColor);
	toArray.PushBackFlashObject(statObject);
	
	return statObject;
}

function AddCharacterStatToxicity(tag : string, varKey:name, locKey:string, iconTag:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage):CScriptedFlashObject
{
	var statObject : CScriptedFlashObject;
	var valueStr : string;
	var valueAbility : float;
	
	var toxicityLocked : float;
	var toxicityNoLock : float;
		
	var sp : SAbilityAttributeValue;
	var final_name 		: string;
	var itemColor		: string;
	
	statObject = flashMaster.CreateTempFlashObject();
	
	toxicityNoLock = GetWitcherPlayer().GetStat(BCS_Toxicity, true);
	toxicityLocked = GetWitcherPlayer().GetStat(BCS_Toxicity) - toxicityNoLock;
	
	// W3EE - Begin
	if ( varKey == 'lockedToxicity' )	
	{
		valueAbility = toxicityLocked;
		valueStr = NoTrailZeros(RoundMath(valueAbility));
	}
	else
	if ( varKey == 'toxPoiseVal' )
	{
		valueAbility = Combat().BaseStatsPoiseValue(GetWitcherPlayer()) * 100.f;
		valueStr = NoTrailZeros(RoundMath(valueAbility));
	}
	else
	{
		valueAbility = toxicityNoLock;
		valueStr = NoTrailZeros(RoundMath(valueAbility));
	}
	// W3EE - End
	

	final_name = GetLocStringByKeyExt(locKey);
	// W3EE - Begin
	if ( final_name == "#" || final_name == "" )
		final_name = locKey;
	// W3EE - End
	statObject.SetMemberFlashString("name", final_name);
	statObject.SetMemberFlashString("value", valueStr);
	statObject.SetMemberFlashString("tag", tag);
	statObject.SetMemberFlashString("iconTag", iconTag);
	statObject.SetMemberFlashString("itemColor", itemColor);
	toArray.PushBackFlashObject(statObject);
	
	return statObject;
}

function AddCharacterStatSigns(tag : string, varKey:name, locKey:string, iconTag:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage):CScriptedFlashObject
{
	var statObject : CScriptedFlashObject;
	var valueStr : string;
	var valueAbility : float;
	var final_name : string;
	var min, max : float;
	var sp, mutDmgMod, mutMin, mutMax : SAbilityAttributeValue;
	var sword : SItemUniqueId;
	
	statObject = flashMaster.CreateTempFlashObject();
	
	if( GetWitcherPlayer().IsMutationActive( EPMT_Mutation1 ) )
	{
		sword = thePlayer.inv.GetCurrentlyHeldSword();
			
		if( thePlayer.inv.GetItemCategory(sword) == 'steelsword' )
		{
			mutDmgMod += thePlayer.inv.GetItemAttributeValue(sword, theGame.params.DAMAGE_NAME_SLASHING);
		}
		else if( thePlayer.inv.GetItemCategory(sword) == 'silversword' )
		{
			mutDmgMod += thePlayer.inv.GetItemAttributeValue(sword, theGame.params.DAMAGE_NAME_SILVER);
		}
		theGame.GetDefinitionsManager().GetAbilityAttributeValue('Mutation1', 'dmg_bonus_factor', mutMin, mutMax);
			
		mutDmgMod.valueBase *= CalculateAttributeValue(mutMin);
	}
	
	
	if ( varKey == 'aard_knockdownchance' )	
	{ 
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_1);
		valueAbility = sp.valueMultiplicative / theGame.params.MAX_SPELLPOWER_ASSUMED - 4 * theGame.params.NPC_RESIST_PER_LEVEL;  
		valueStr = (string)RoundMath( valueAbility * 100 ) + " %";
	}
	// W3EE - Begin
	else if ( varKey == 'spell_power_aard' )
	{
		sp = GetWitcherPlayer().GetSingleSignSpellPower(S_Magic_1);
		valueAbility = sp.valueMultiplicative;
		valueStr = (string)RoundMath(valueAbility * 100) + " %";
	}
	else if ( varKey == 'spell_power_igni' )
	{
		sp = GetWitcherPlayer().GetSingleSignSpellPower(S_Magic_2);
		valueAbility = sp.valueMultiplicative;
		valueStr = (string)RoundMath(valueAbility * 100) + " %";
	}
	else if ( varKey == 'spell_power_quen' )
	{
		sp = GetWitcherPlayer().GetSingleSignSpellPower(S_Magic_4);
		valueAbility = sp.valueMultiplicative;
		valueStr = (string)RoundMath(valueAbility * 100) + " %";
	}
	else if ( varKey == 'spell_power_yrden' )
	{
		sp = GetWitcherPlayer().GetSingleSignSpellPower(S_Magic_3);
		valueAbility = sp.valueMultiplicative;
		valueStr = (string)RoundMath(valueAbility * 100) + " %";
	}
	else if ( varKey == 'spell_power_axii' )
	{
		sp = GetWitcherPlayer().GetSingleSignSpellPower(S_Magic_5);
		valueAbility = sp.valueMultiplicative;
		valueStr = (string)RoundMath(valueAbility * 100) + " %";
	}
	// W3EE - End
	else if ( varKey == 'aard_damage' ) 	
	{  
		if ( GetWitcherPlayer().GetSignOwner().CanUseSkill(S_Magic_s06) )
		{
			// W3EE - Begin
			sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_1);
			valueAbility = GetWitcherPlayer().GetSkillLevel(S_Magic_s06) * 290.f;
			valueAbility += mutDmgMod.valueBase;
			valueAbility *= sp.valueMultiplicative;
			valueStr = (string)RoundMath( valueAbility * Damage().pdams );
			// W3EE - End
		}
		else
			valueStr = "0";
	}
	else if ( varKey == 'igni_damage' ) 	
	{  
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_2);
		valueAbility = 750.f;
		valueAbility += mutDmgMod.valueBase;
		valueAbility *= sp.valueMultiplicative;
		// W3EE - Begin
		valueStr = (string)RoundMath( valueAbility * Damage().pdams );
		// W3EE - End
	}
	else if ( varKey == 'igni_burnchance' ) 	
	{  
		if (GetWitcherPlayer().GetSignOwner().CanUseSkill(S_Magic_s09))
		{
			sp = GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s09, 'chance_bonus', false, false);
			valueAbility = valueAbility * sp.valueMultiplicative * GetWitcherPlayer().GetSkillLevel(S_Magic_s09) + sp.valueAdditive * GetWitcherPlayer().GetSkillLevel(S_Magic_s09);
		}
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_2);
		valueAbility *= sp.valueMultiplicative;
		valueStr = (string)Min(100, RoundMath(valueAbility * 100)) + " %";
	}
	// W3EE - Begin
	else if ( varKey == 'quen_damageabs' )
	{
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_4);
		valueAbility = 550;
		valueAbility *= sp.valueMultiplicative;
		valueStr = (string)RoundMath( valueAbility );
	}
	else if ( varKey == 'quen_duration' )
	{
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_4);
		valueAbility = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_4, 'shield_duration', true, true));
		valueAbility *= sp.valueMultiplicative * 1.4f;
		valueStr = RoundMath(valueAbility) /*FloatToStringPrec( valueAbility, 2 )*/ + GetLocStringByKeyExt("per_second");
	}
	else if ( varKey == 'yrden_slowdown' )
	{
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_3);
		min = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_3, 'min_slowdown', false, true));
		max = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_3, 'max_slowdown', false, true));
		valueAbility =  0.2f * sp.valueMultiplicative;
		valueStr = (string)RoundMath( valueAbility * 100 ) + " %";
	}
	else if ( varKey == 'yrden_damage' )
	{
		if (GetWitcherPlayer().GetSignOwner().CanUseSkill(S_Magic_s11))
		{
			sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_3);
			valueAbility = CalculateAttributeValue( GetWitcherPlayer().GetSkillAttributeValue(S_Magic_s11, 'direct_damage_per_sec', false, true) );
			valueAbility *= sp.valueMultiplicative * GetWitcherPlayer().GetSkillLevel(S_Magic_s11) * 2.8f;
			valueStr = (string)RoundMath( valueAbility * Damage().pdams );
		}
		else
			valueStr = "0";
	}
	else if ( varKey == 'yrden_duration' )
	{
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_3);
		valueAbility = CalculateAttributeValue(GetWitcherPlayer().GetSkillAttributeValue(S_Magic_3, 'trap_duration', false, true)) * 1.75f * sp.valueMultiplicative;
		valueStr = FloatToStringPrec( valueAbility, 2 ) + GetLocStringByKeyExt("per_second");
	}
	else if ( varKey == 'axii_duration_confusion' )
	{
		sp = GetWitcherPlayer().GetTotalSignSpellPower(S_Magic_5);
		sp += GetWitcherPlayer().GetSkillAttributeValue(S_Magic_5, 'duration', false, true);
		valueStr = FloatToStringPrec( CalculateAttributeValue(sp), 2 ) + GetLocStringByKeyExt("per_second");
	}
	else if ( varKey == 'vigorRegen' ) 
	{
		sp = GetWitcherPlayer().GetAttributeValue('vigor_regen');
		sp.valueMultiplicative += 1;
		valueAbility = 0.135f * sp.valueMultiplicative * GetWitcherPlayer().GetStatPercents(BCS_Vitality) * (1 + GetWitcherPlayer().GetAdrenalineEffect().GetValue()) * Options().AdrGenSpeedMult * ClampF( (1 - GetWitcherPlayer().GetStatPercents(BCS_Toxicity)) * 1.5, 0.4f + 0.06f * GetWitcherPlayer().GetSkillLevel(S_Alchemy_s20), 1.0f );
		valueStr = NoTrailZeros(RoundTo(valueAbility, 3)) + "/" + GetLocStringByKeyExt("per_second");
	}
	else if ( varKey == 'vigorRegenDelay' ) 
	{
		valueAbility = Options().AdrPerc * GetWitcherPlayer().GetStatPercents(BCS_Vitality) * Options().AdrGenSpeedMult * (1.f - ((0.6f - 0.06f * GetWitcherPlayer().GetSkillLevel(S_Alchemy_s20)) * GetWitcherPlayer().GetStatPercents(BCS_Toxicity))) * 100;
		valueStr = NoTrailZeros(RoundTo(Options().AdrGenDelay, 1)) + " " + GetLocStringByKeyExt("per_second");
	}
	else if ( varKey == 'vigorLossLight' ) 
	{
		valueAbility = CalculateAttributeValue(thePlayer.GetAttributeValue('light_attack_focus_drain')) * Options().FocusLossLightHits();
		if ( GetWitcherPlayer().CanUseSkill(S_Sword_s16) )
			valueAbility *= (1 - (CalculateAttributeValue( thePlayer.GetSkillAttributeValue(S_Sword_s16, 'focus_drain_reduction', false, true) ) * thePlayer.GetSkillLevel(S_Sword_s16) / 2));
		valueStr = NoTrailZeros(RoundTo(valueAbility, 2));
	}
	else if ( varKey == 'vigorLossHeavy' ) 
	{
		valueAbility = CalculateAttributeValue(thePlayer.GetAttributeValue('heavy_attack_focus_drain')) * Options().FocusLossHeavyHits();
		if ( GetWitcherPlayer().CanUseSkill(S_Sword_s16) )
			valueAbility *= (1 - (CalculateAttributeValue( thePlayer.GetSkillAttributeValue(S_Sword_s16, 'focus_drain_reduction', false, true) ) * thePlayer.GetSkillLevel(S_Sword_s16) / 2));
		valueStr = NoTrailZeros(RoundTo(valueAbility, 2));
	}
	else if ( varKey == 'vigorLossSHeavy' ) 
	{
		valueAbility = CalculateAttributeValue(thePlayer.GetAttributeValue('super_heavy_attack_focus_drain')) * Options().FocusLossSuperHeavyHits();
		if ( GetWitcherPlayer().CanUseSkill(S_Sword_s16) )
			valueAbility *= (1 - (CalculateAttributeValue( thePlayer.GetSkillAttributeValue(S_Sword_s16, 'focus_drain_reduction', false, true) ) * thePlayer.GetSkillLevel(S_Sword_s16) / 2));
		valueStr = NoTrailZeros(RoundTo(valueAbility, 2));
	}
	// W3EE - End
	else
	{	
		valueAbility =  CalculateAttributeValue( GetWitcherPlayer().GetAttributeValue( varKey ) );
		valueStr = IntToString( RoundF(  valueAbility ) );
	}
	
	final_name = GetLocStringByKeyExt(locKey);
	// W3EE - Begin
	if ( final_name == "#" || final_name == "" )
		final_name = locKey;
	// W3EE - End
	statObject.SetMemberFlashString("name", final_name);
	statObject.SetMemberFlashString("value", valueStr);
	statObject.SetMemberFlashString("tag", tag);
	statObject.SetMemberFlashString("iconTag", iconTag);
	statObject.SetMemberFlashString("itemColor", "Blue");
	
	toArray.PushBackFlashObject(statObject);
	
	return statObject;
}

function AddCharacterStatF(tag : string, varKey:name, locKey:string, iconTag:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage):CScriptedFlashObject
{
	var statObject : CScriptedFlashObject;
	var valueStr : string;
	var valueAbility, pts, perc : float;
	var final_name : string;
	var witcher : W3PlayerWitcher;
	var isPointResist : bool;
	var stat : EBaseCharacterStats;
	var resist : ECharacterDefenseStats;
	var attributeValue : SAbilityAttributeValue;
	var powerStat : ECharacterPowerStats;
	
	statObject = flashMaster.CreateTempFlashObject();
		
	
	witcher = GetWitcherPlayer();
	stat = StatNameToEnum(varKey);
	if(stat != BCS_Undefined)
	{
		valueAbility = witcher.GetStat(stat);
	}
	else
	{
		resist = ResistStatNameToEnum(varKey, isPointResist);
		if(resist != CDS_None)
		{
			witcher.GetResistValue(resist, pts, perc);
			
			if(isPointResist)
				valueAbility = pts;
			else
				valueAbility = perc;
		}
		else
		{
			powerStat = PowerStatNameToEnum(varKey);
			if(powerStat != CPS_Undefined)
			{
				attributeValue = witcher.GetPowerStatValue(powerStat);
			}
			else
			{
				attributeValue = witcher.GetAttributeValue(varKey);
			}
			
			valueAbility = CalculateAttributeValue( attributeValue );
		}
	}
	
	
	valueStr = NoTrailZeros( RoundMath(valueAbility * 100) );
	
	final_name = GetLocStringByKeyExt(locKey); if ( final_name == "#" ) { final_name = ""; }
	statObject.SetMemberFlashString("name", final_name);
	statObject.SetMemberFlashString("value", valueStr + " %");
	statObject.SetMemberFlashString("tag", tag);
	statObject.SetMemberFlashString("iconTag", iconTag);
	
	toArray.PushBackFlashObject(statObject);
	
	return statObject;
}

function AddCharacterStatU(tag : string, varKey:name, locKey:string, iconTag:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage):CScriptedFlashObject
{
	var curStats:SPlayerOffenseStats;
	var statObject : CScriptedFlashObject;
	var valueStr : string;
	var valueAbility, maxHealth, curHealth : float;
	var sp : SAbilityAttributeValue;
	var final_name : string;
	var item : SItemUniqueId;

	statObject = flashMaster.CreateTempFlashObject();
	
	
	
	
	
	
	if(varKey != 'instant_kill_chance_mult' && varKey != 'human_exp_bonus_when_fatal' && varKey != 'nonhuman_exp_bonus_when_fatal' && varKey != 'area_nml' && varKey != 'area_novigrad' && varKey != 'area_skellige')
	{
		curStats = GetWitcherPlayer().GetOffenseStatsList();
	}
	
	// W3EE - Begin
	if ( varKey == 'silverdamage' ) { valueAbility = ((curStats.silverFastDPS * Damage().pdam - (( (1 - thePlayer.GetStatPercents(BCS_Stamina)) * 0.2f ) * curStats.silverFastDPS * Damage().pdam))+(curStats.silverStrongDPS * Damage().pdam - (( (1 - thePlayer.GetStatPercents(BCS_Stamina)) * 0.2f ) * curStats.silverStrongDPS * Damage().pdam))); if( Damage().GetPerk10State() ) valueAbility *= 1.15; valueAbility /= 2; valueStr = NoTrailZeros(RoundMath(valueAbility)); }
	else if ( varKey == 'steeldamage' ) { valueAbility = ((curStats.steelFastDPS * Damage().pdam - (( (1 - thePlayer.GetStatPercents(BCS_Stamina)) * 0.2f ) * curStats.steelFastDPS * Damage().pdam))+(curStats.steelStrongDPS * Damage().pdam - (( (1 - thePlayer.GetStatPercents(BCS_Stamina)) * 0.2f ) * curStats.steelStrongDPS * Damage().pdam))); if( Damage().GetPerk10State() ) valueAbility *= 1.15; valueAbility /= 2; valueStr = NoTrailZeros(RoundMath(valueAbility)); }
	else if ( varKey == 'silverFastDPS' ) { valueAbility = curStats.silverFastDmg * Damage().pdam - (( (1 - thePlayer.GetStatPercents(BCS_Stamina)) * 0.2f ) * curStats.silverFastDmg * Damage().pdam); if( Damage().GetPerk10State() ) valueAbility *= 1.15; valueStr = NoTrailZeros(RoundMath(valueAbility)); }
	// W3EE - End
	else if ( varKey == 'silverFastCritChance' ) 	valueStr = NoTrailZeros(RoundMath(curStats.silverFastCritChance))+" %";
	// W3EE - Begin
	else if ( varKey == 'silverFastCritDmg' ) { valueAbility = curStats.silverFastCritDmg * Damage().pdam - (( (1 - thePlayer.GetStatPercents(BCS_Stamina)) * 0.2f ) * curStats.silverFastCritDmg * Damage().pdam); if( Damage().GetPerk10State() ) valueAbility *= 1.15; valueStr = NoTrailZeros(RoundMath(valueAbility)); }
	else if ( varKey == 'silverStrongDPS' )	{ valueAbility = curStats.silverStrongDmg * Damage().pdam - (( (1 - thePlayer.GetStatPercents(BCS_Stamina)) * 0.2f ) * curStats.silverStrongDmg * Damage().pdam) ; if( Damage().GetPerk10State() ) valueAbility *= 1.15; valueStr = NoTrailZeros(RoundMath(valueAbility)); }
	// W3EE - End
	else if ( varKey == 'silverStrongCritChance' )	valueStr = NoTrailZeros(RoundMath(curStats.silverStrongCritChance))+" %";
	// W3EE - Begin
	else if ( varKey == 'silverStrongCritDmg' ) { valueAbility = curStats.silverStrongCritDmg * Damage().pdam - (( (1 - thePlayer.GetStatPercents(BCS_Stamina)) * 0.2f ) * curStats.silverStrongCritDmg * Damage().pdam); if( Damage().GetPerk10State() ) valueAbility *= 1.15; valueStr = NoTrailZeros(RoundMath(valueAbility)); }
	else if ( varKey == 'steelFastDPS' ) { valueAbility = curStats.steelFastDmg * Damage().pdam - (( (1 - thePlayer.GetStatPercents(BCS_Stamina)) * 0.2f ) * curStats.steelFastDmg * Damage().pdam) ; if( Damage().GetPerk10State() ) valueAbility *= 1.15; valueStr = NoTrailZeros(RoundMath(valueAbility));	}
	// W3EE - End
	else if ( varKey == 'steelFastCritChance' )		valueStr = NoTrailZeros(RoundMath(curStats.steelFastCritChance))+" %";
	// W3EE - Begin
	else if ( varKey == 'steelFastCritDmg' ) { valueAbility = curStats.steelFastCritDmg * Damage().pdam - (( (1 - thePlayer.GetStatPercents(BCS_Stamina)) * 0.2f ) * curStats.steelFastCritDmg * Damage().pdam); if( Damage().GetPerk10State() ) valueAbility *= 1.15; valueStr = NoTrailZeros(RoundMath(valueAbility)); }
	else if ( varKey == 'steelStrongDPS' )	{ valueAbility = curStats.steelStrongDmg * Damage().pdam - (( (1 - thePlayer.GetStatPercents(BCS_Stamina)) * 0.2f ) * curStats.steelStrongDmg * Damage().pdam); if( Damage().GetPerk10State() ) valueAbility *= 1.15; valueStr = NoTrailZeros(RoundMath(valueAbility)); }
	// W3EE - End
	else if ( varKey == 'steelStrongCritChance' )	valueStr = NoTrailZeros(RoundMath(curStats.steelStrongCritChance))+" %";
	// W3EE - Begin
	else if ( varKey == 'steelStrongCritDmg' ) { valueAbility = curStats.steelStrongCritDmg * Damage().pdam - (( (1 - thePlayer.GetStatPercents(BCS_Stamina)) * 0.2f ) * curStats.steelStrongCritDmg * Damage().pdam); if( Damage().GetPerk10State() ) valueAbility *= 1.15; valueStr = NoTrailZeros(RoundMath(valueAbility)); }
	// W3EE - End
	else if ( varKey == 'crossbowCritChance' )		valueStr = NoTrailZeros(RoundMath(curStats.crossbowCritChance * 100))+" %";
	else if ( varKey == 'crossbowDmg' )				valueStr = "";
	// W3EE - Begin
	else if ( varKey == 'crossbowSteelDmg' )				
	{ 
		valueStr = NoTrailZeros(RoundMath(curStats.crossbowSteelDmg * Damage().pdamc));
		switch (curStats.crossbowSteelDmgType)
		{
			case theGame.params.DAMAGE_NAME_BLUDGEONING: locKey = "attribute_name_bludgeoningdamage"; break;
			case theGame.params.DAMAGE_NAME_FIRE: locKey = "attribute_name_firedamage"; break;
			default : locKey = "attribute_name_piercingdamage"; break;
		}
	} 
	else if ( varKey == 'crossbowSilverDmg' )				
	{
		valueStr = NoTrailZeros(RoundMath(curStats.crossbowSilverDmg * Damage().pdamc));
	}
	// W3EE - End
	else if ( varKey == 'instant_kill_chance_mult') 
	{
		valueAbility = 0;
		// W3EE - Begin
		/*if (thePlayer.CanUseSkill(S_Sword_s03))
		{
			sp += GetWitcherPlayer().GetSkillAttributeValue(S_Sword_s03, 'instant_kill_chance', false, true);
			valueAbility = CalculateAttributeValue(sp);
			valueAbility *= thePlayer.GetSkillLevel(S_Sword_s03);
			valueAbility *= RoundF(thePlayer.GetStat(BCS_Focus));
		}*/
		// W3EE - End
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.inv.GetItemAttributeValue(item, varKey)); 
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.inv.GetItemAttributeValue(item, varKey)); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if (varKey == 'human_exp_bonus_when_fatal' || varKey == 'nonhuman_exp_bonus_when_fatal') 
	{
		sp = thePlayer.GetAttributeValue(varKey);

		valueStr = NoTrailZeros(RoundMath(CalculateAttributeValue(sp) * 100)) + " %";
	}
	else if (varKey == 'area_nml') 
	{
		if (!thePlayer.HasAbility(varKey))
			locKey = "";
		else
		{
			
			
		}
	}
	else if (varKey == 'area_novigrad') 
	{
		if (!thePlayer.HasAbility(varKey))
			locKey = "";
		else
		{
			
			
		}
	}
	else if (varKey == 'area_skellige') 
	{
		if (!thePlayer.HasAbility(varKey))
			locKey = "";
		else
		{
			
			
		}
	}
	
	final_name = GetLocStringByKeyExt(locKey); 

	// W3EE - Begin
	if ( final_name == "#" || final_name == "" )
		final_name = locKey;
	// W3EE - End
	
	statObject.SetMemberFlashString("name", final_name);
	statObject.SetMemberFlashString("value", valueStr );
	statObject.SetMemberFlashString("tag", tag);
	statObject.SetMemberFlashString("iconTag", iconTag);
	statObject.SetMemberFlashString("itemColor", "Red");
	
	toArray.PushBackFlashObject(statObject);
	
	return statObject;
}

function AddCharacterStatU2(tag : string, varKey:name, locKey:string, iconTag:string, toArray : CScriptedFlashArray, flashMaster:CScriptedFlashValueStorage):CScriptedFlashObject
{
	var curStats:SPlayerOffenseStats;
	var statObject : CScriptedFlashObject;
	var valueStr : string;
	var valueAbility, maxHealth, curHealth : float;
	var sp : SAbilityAttributeValue;
	var final_name : string;
	var item : SItemUniqueId;

	statObject = flashMaster.CreateTempFlashObject();
	
	if ( varKey == 'silver_desc_poinsonchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_poinsonchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'silver_desc_bleedingchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_bleedingchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'silver_desc_burningchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_burningchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'silver_desc_confusionchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_confusionchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'silver_desc_freezingchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_freezingchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'silver_desc_staggerchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SilverSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_staggerchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	}
	else if ( varKey == 'steel_desc_poinsonchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_poinsonchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'steel_desc_bleedingchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_bleedingchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'steel_desc_burningchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_burningchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'steel_desc_confusionchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_confusionchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'steel_desc_freezingchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_freezingchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	} 
	else if ( varKey == 'steel_desc_staggerchance_mult') 
	{
		valueAbility = 0;
		if (GetWitcherPlayer().GetItemEquippedOnSlot(EES_SteelSword, item))
			valueAbility += CalculateAttributeValue(thePlayer.GetInventory().GetItemAttributeValue(item, 'desc_staggerchance_mult')); 
		valueStr = NoTrailZeros(RoundMath(valueAbility * 100)) + " %";
	}
	
	final_name = GetLocStringByKeyExt(locKey); if ( final_name == "#" ) { final_name = ""; }
	statObject.SetMemberFlashString("name", final_name);
	statObject.SetMemberFlashString("value", valueStr );
	statObject.SetMemberFlashString("tag", tag);
	statObject.SetMemberFlashString("iconTag", iconTag);
	
	toArray.PushBackFlashObject(statObject);
	
	return statObject;
}

function GetEquippedCrossbowDamage():float
{
	var equippedBolt		  : SItemUniqueId;
	var equippedCrossbow	  : SItemUniqueId;
	var crossbowPower         : SAbilityAttributeValue;
	var crossbowStatValueMult : float;
	var primaryStatLabel      : string;
	var primaryStatValue      : float;
	var silverDamageValue	  : float;
	var min, max 			  : SAbilityAttributeValue;
	
	GetWitcherPlayer().GetItemEquippedOnSlot(EES_RangedWeapon, equippedCrossbow);
	if (!thePlayer.inv.IsIdValid(equippedCrossbow))
	{
		return 0;
	}
	
	crossbowPower = thePlayer.inv.GetItemAttributeValue(equippedCrossbow, 'attack_power');
	crossbowStatValueMult = 1;
	if(thePlayer.CanUseSkill(S_Perk_02))
	{				
		crossbowStatValueMult += 0.25f;
		//crossbowPower += thePlayer.GetSkillAttributeValue(S_Perk_02, PowerStatEnumToName(CPS_AttackPower), false, true);
	}
	if ( thePlayer.HasBuff(EET_Mutagen05) && (thePlayer.GetStat(BCS_Vitality) == thePlayer.GetStatMax(BCS_Vitality)) )
	{
		crossbowPower += thePlayer.GetAttributeValue('damageIncrease');
	}
	crossbowPower += thePlayer.GetPowerStatValue(CPS_AttackPower);
	

	GetWitcherPlayer().GetItemEquippedOnSlot(EES_Bolt, equippedBolt);
	if (thePlayer.inv.IsIdValid(equippedBolt))
	{
		thePlayer.inv.GetItemPrimaryStat(equippedBolt, primaryStatLabel, primaryStatValue);
		silverDamageValue = CalculateAttributeValue(GetWitcherPlayer().GetInventory().GetItemAttributeValue(equippedBolt, theGame.params.DAMAGE_NAME_SILVER));
	}
	else
	{
		// W3EE - Begin
		/*
		thePlayer.inv.GetItemStatByName('Bodkin Bolt', 'PiercingDamage', primaryStatValue);
		thePlayer.inv.GetItemStatByName('Bodkin Bolt', 'SilverDamage', silverDamageValue);
		*/
		primaryStatValue = 0;
		silverDamageValue = 0;
		// W3EE - End
	}
	
	
	if( GetWitcherPlayer().IsMutationActive( EPMT_Mutation9 ) )
	{
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation9', 'damage', min, max );
		primaryStatValue += min.valueAdditive;
		silverDamageValue += min.valueAdditive;
	}
	
	primaryStatValue = (primaryStatValue + crossbowPower.valueBase) * crossbowPower.valueMultiplicative + crossbowPower.valueAdditive;
	silverDamageValue = (silverDamageValue + crossbowPower.valueBase) * crossbowPower.valueMultiplicative + crossbowPower.valueAdditive;
	
	return (primaryStatValue + silverDamageValue) * crossbowStatValueMult / 2;
}