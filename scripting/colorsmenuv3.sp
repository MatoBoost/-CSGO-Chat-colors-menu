#include <sourcemod>
#include <cstrike>
#include <chat-processor>

char prefix[30] = "[\x02Relax\x01Gaming]"; //Use your own prefix here

public Plugin:myinfo = {
    name = "[CSGO] Colors menu with SQL support",
    author = "MatoBoost",
    description = "Colors menu with SQL support for players",
    url = "https://relaxgaming.eu",
}

public OnPluginStart(){
    Database DB;
    char error[256];
    RegAdminCmd("sm_colors", Command_Colors, ADMFLAG_RESERVATION, "Opens up the colors menu");
    DB = SQL_Connect("colorsmenu", true, error, sizeof(error));

    if(DB == INVALID_HANDLE){
        LogError("Unable to connect to MySQL database: %s", error);
        CloseHandle(DB);
    }
    else{
        LogMessage("SQL connection successfull. Have fun!");
    }
}

public void OnConfigsExecuted(){
    Database.Connect(SQLConnectCallback, "colorsmenu");
}

public void OnClientPostAdminCheck(int client){
    char query[200];
    char error[200];
    char steamid[50];
    char color[30];
    Database DB;
    DBResultSet result;
    DB = SQL_Connect("colorsmenu", true, error, sizeof(error));

    GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid), true);

    Format(query, sizeof(query), "SELECT color FROM colorsmenu WHERE steamid='%s'", steamid);
    result = SQL_Query(DB, query);

    if(SQL_FetchRow(result)){
    result.FetchString(0, color, sizeof(color));
    ChatProcessor_SetChatColor(client, color);
    }

    delete DB;
}

public Action Command_Colors(int client, int args){
	Handle hMenu = CreateMenu(MenuHandler_Colors, MENU_ACTIONS_ALL);
	SetMenuTitle(hMenu, "Vyber si farbu:");

	AddMenuItem(hMenu, "{default}", "Default");
	AddMenuItem(hMenu, "{darkred}", "Dark Red");
    AddMenuItem(hMenu, "{red}", "Red");
    AddMenuItem(hMenu, "{lightred}", "Light Red");
    AddMenuItem(hMenu, "{bluegrey}", "Blue Grey");
    AddMenuItem(hMenu, "{blue}", "Blue");
    AddMenuItem(hMenu, "{darkblue}", "Dark Blue");
    AddMenuItem(hMenu, "{orchid}", "Orchid");
	AddMenuItem(hMenu, "{yellow}", "Yellow");
	AddMenuItem(hMenu, "{gold}", "Gold");
	AddMenuItem(hMenu, "{lightgreen}", "Light Green");
	AddMenuItem(hMenu, "{green}", "Green");
	AddMenuItem(hMenu, "{lime}", "Lime");
    AddMenuItem(hMenu, "{grey}", "Grey");
    AddMenuItem(hMenu, "{grey2}", "Grey 2");
    
    SetMenuExitButton(hMenu, true);
    
    DisplayMenu(hMenu, client, 20);
	return Plugin_Handled;
}

public int MenuHandler_Colors(Handle hMenu, MenuAction maAction, int client, int choice){
	if(maAction == MenuAction_Select)
	{
        char color[20];
        GetMenuItem(hMenu, choice, color, 20);
        PrintToChat(client, "%s Tvoja farba bola uspesne zmenena.", prefix);
        ChatProcessor_SetChatColor(client, color);
        ZapisDoDatabazy(client, color);
    }
	else if(maAction == MenuAction_End)
	{
		CloseHandle(hMenu);
	}
    
}

public void ZapisDoDatabazy(int client, char[] color){
    char error[200];
    char query[300];
    char steamid[30];
    DBResultSet result;
    Database DB = SQL_Connect("colorsmenu", true, error, sizeof(error));
    
    GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid), true);
    Format(query, sizeof(query), "SELECT steamid FROM colorsmenu WHERE steamid='%s'", steamid);
    result = SQL_Query(DB, query);

    if(result.RowCount == 0){
        Format(query, sizeof(query), "INSERT INTO colorsmenu (steamid, color) VALUES ('%s', '%s')", steamid, color);
        SQL_Query(DB, query);
    }
    else{
        Format(query, sizeof(query), "UPDATE `colorsmenu` SET `color` = '%s' WHERE `steamid` = '%s'", color, steamid);
        SQL_Query(DB, query);
    }

    delete DB;
}

public void SQLConnectCallback(Database DB, char[] error, any data){
    if(DB == null){
        LogError("Database error: %s", error);
    }
    else{
        char createQuery[1024];
        Format(createQuery, sizeof(createQuery), "CREATE TABLE IF NOT EXISTS colorsmenu (id int(64) NOT NULL PRIMARY KEY AUTO_INCREMENT, steamid varchar(32) NOT NULL DEFAULT '0', color varchar(10) NOT NULL DEFAULT '\x01')");
        SQL_Query(DB, createQuery);
    }
}
