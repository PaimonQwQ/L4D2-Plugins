#pragma semicolon 1
#pragma newdecls required

#include <sdktools>
#include <sourcemod>
#include <left4dhooks>

#define MAXSIZE 33
#define VERSION "1.5.2"

public Plugin myinfo =
{
	name = "Dooooooooor!!!!!!!!",
	author = "我是派蒙啊",
	description = "Let's RUSH! RUSH!! RUSH!! >_<!!!!!!",
	version = VERSION,
	url = "http://github.com/PaimonQwQ/L4D2-Plugins/l4d2_letsrush.sp",
};


public void OnPluginStart()
{
	HookEvent("player_use", Event_PlayerUse);
}

public void Event_PlayerUse(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int entity = GetEventInt(event, "targetid");

	if(!IsValidEntity(entity)) return;

	char entName[128];
	GetEdictClassname(entity, entName, sizeof(entName));
	if(StrContains(entName, "prop_door_rotating_checkpoint", false) == -1)
		return;

	if(!L4D_IsInLastCheckpoint(client))
	{
		AcceptEntityInput(entity, "Lock");
		AcceptEntityInput(entity, "Open");
		SetEntProp(entity, Prop_Data, "m_hasUnlockSequence", 1);

		return;
	}

	if(L4D2_IsTankInPlay() || HasSIBotAlive())
	{
		AcceptEntityInput(entity, "Lock");
		AcceptEntityInput(entity, "Open");
		SetEntProp(entity, Prop_Data, "m_hasUnlockSequence", 1);
		PrintHintTextToAll("你还不能进屋，附近有特感在游荡！");
	}
	else if(HasSurvivorOutside())
	{
		AcceptEntityInput(entity, "Lock");
		AcceptEntityInput(entity, "Open");
		SetEntProp(entity, Prop_Data, "m_hasUnlockSequence", 1);
		PrintHintTextToAll("救救队友吧求求你了>x<");
	}
	else
	{
		SetEntProp(entity, Prop_Data, "m_hasUnlockSequence", 0);
		AcceptEntityInput(entity, "Unlock");
		AcceptEntityInput(entity, "Close");
		AcceptEntityInput(entity, "Open");
		AcceptEntityInput(entity, "ForceClosed");
	}
}

bool IsValidClient(int client)
{
	return (client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client));
}

bool HasSIBotAlive()
{
	for(int client = 1; client <= MaxClients; client++)
		if(IsValidClient(client) && IsFakeClient(client) && IsPlayerAlive(client) && GetClientTeam(client) == 3)
			return true;
	return false;
}

bool HasSurvivorOutside()
{
	for(int client = 1; client <= MaxClients; client++)
		if(IsValidClient(client) && IsPlayerAlive(client) && GetClientTeam(client) == 2 && !L4D_IsInLastCheckpoint(client))
			return true;
	return false;
}