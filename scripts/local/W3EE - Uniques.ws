exec function anim( n : name )
{
	GetWitcherPlayer().ActionPlaySlotAnimationAsync('PLAYER_SLOT', n, 0, 0);
}

exec function animnpc( n : name )
{
	GetWitcherPlayer().GetTarget().ActionPlaySlotAnimationAsync('GAMEPLAY_SLOT', n, 0, 0);
}

exec function stagr()
{
	GetWitcherPlayer().GetTarget().AddEffectDefault(EET_LongStagger, GetWitcherPlayer(), "test");
}

exec function ayylmao()
{
	thePlayer.substateManager.QueueStateExternal('Jump');
}

exec function ayylmao2()
{
	GetWitcherPlayer().GotoState('Exploration');
}

exec function applydot()
{
	var i : int;
	var actors : array<CActor>;
	
	actors = thePlayer.GetNPCsAndPlayersInRange(15, 50);
	for(i=0; i<actors.Size(); i+=1)
	{
		actors[i].AddEffectDefault(EET_Bleeding, thePlayer, "framerape");
		actors[i].AddEffectDefault(EET_Poison, thePlayer, "framerape");
	}
}

exec function dumpallquests()
{
	var manager : CWitcherJournalManager;
	var questPhase : CJournalQuestPhase;
	var allQuests : array<CJournalBase>;
	var objective : CJournalQuestObjective;
	var objectiveTag : string;
	var aQuest : CJournalQuest;
	var i, j, k : int;

	theGame.GetJournalManager().GetActivatedOfType( 'CJournalQuest', allQuests );
	for( i = 0; i < allQuests.Size(); i += 1 )
	{
		aQuest = ((CJournalQuest)allQuests[i]);
		LogChannel(' ', " ");
		LogChannel('QUEST BULLSHIT', "Quest: " + aQuest.GetUniqueScriptTag());
		for( j = 0; j < aQuest.GetNumChildren(); j += 1 )
		{
			questPhase = (CJournalQuestPhase)aQuest.GetChild(j);
			if( questPhase )
			{				
				for( k = 0; k < questPhase.GetNumChildren(); k += 1 )
				{
					objective = (CJournalQuestObjective)questPhase.GetChild(k);
					objectiveTag = NameToString(objective.GetUniqueScriptTag());
					LogChannel('QUEST BULLSHIT', "     Objective: " + objectiveTag);
				}
			}
		}
	}
}

exec function ForceBolts()
{
	GetWitcherPlayer().GetInventory().AddAndEquipItem('Bodkin Bolt', EES_Bolt, 25);
}