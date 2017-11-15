// This is a comment
// uncomment the line below if you want to write a filterscript
//#define FILTERSCRIPT
#include <a_samp>
#include <zcmd>
#include <a_http>


#define COLOR_WHITE			0xFFFFFFAA
#define COLOR_GRAD1			0xB4B5B7FF
#define COLOR_LORANGE		0xE87732FF

#define CallBack:%1(%2) \
 	forward %1(%2); public %1(%2)

#define SMS_NUMBER_KP "7055"
#define SMS_CODE_KP "WAX.KP"
#define SMS_ID_USER "69711"

#define DIALOG_SHOP_KP 1001 

new DB:serverdb, bool:KP[MAX_PLAYERS];

public OnFilterScriptInit()
{
	serverdb = db_open("konta.db");
	db_free_result(db_query(serverdb, "CREATE TABLE IF NOT EXISTS `Wax_kp` ('Nick' TEXT(30), 'datekp' BIGINT);"));
	return 1;
}

public OnFilterScriptExit()
{
    db_close(serverdb);
	return 1;
}


public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
	return 1;
}

public OnPlayerConnect(playerid)
{
	KP[playerid] = false;
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	return 1;
}

public OnPlayerSpawn(playerid)
{
    new DBResult:result, query[64], name[MAX_PLAYER_NAME + 1], string[12];
    GetPlayerName(playerid, name, sizeof(name));
    format(query, sizeof query, "SELECT `datekp` FROM `Wax_kp` WHERE `Nick` = '%s'", name);
    result = db_query(serverdb, query);
	printf("no: %s", query);
    if(db_num_rows(result) == 1)
    {
    	db_get_field_assoc(result, "datekp", string, 64);
    	if(strval(string) > gettime())
		{
			SendClientMessage(playerid, COLOR_WHITE, "SERWER: Twoje konto jest aktywne");
			KP[playerid] = true;
		}
	}
	db_free_result(result);
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if(strcmp("/dodaj", cmdtext, true, 10) == 0)
	{
	    new string[128], namee[MAX_PLAYER_NAME+1], elo = gettime();
	    new czas = elo + 2592000;
    	GetPlayerName(playerid, namee, sizeof(namee));
	    format(string, sizeof string, "INSERT INTO `Wax_kp` (`Nick`, `datekp`) VALUES('%s', '%d');", namee, czas);
		db_query(serverdb, string);
		printf(string);
		return 1;
	}
	return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == DIALOG_SHOP_KP)
	{
		if(!response) return 1;

     	new string[64];
     	format(string, 64, "dotpay.pl/check_code.php?&check=%s&id=%d&code=%s&type=sms&del=0", inputtext, SMS_ID_USER, SMS_CODE_KP);
		HTTP(playerid, HTTP_GET, string, "", "Wax_CheckTheCodeKP");
		return 1;
	}
	return 1;
}

CallBack:Wax_CheckTheCodeKP(playerid, response_code, data[])
{
    if(strval(data) == 1)
    {
        new name[MAX_PLAYER_NAME + 1], string[64];
        GetPlayerName(playerid, name, sizeof(name));
        
        SendClientMessage(playerid, COLOR_LORANGE, "SERWER: Kod jest poprawny, na twoje konto zostaje na³o¿one konto premium na 30 dni.");
        format(string, sizeof string, "INSERT INTO `Wax_kp` (`Nick`, `datekp`) VALUES('%s', '%d');", name, gettime() + 2592000);
		db_query(serverdb, string);
    }
    else SendClientMessage(playerid, COLOR_GRAD1, "SERWER: Niepoprawny kod.");
    
    if(response_code != 500) return SendClientMessage(playerid, COLOR_WHITE, "SERWER: B³¹d serwera.");
    
    return 1;
}

CMD:buy(playerid, params[])
{
	new string[68];
    format(string, sizeof(string), "Wyœlij SMS o treœci "SMS_CODE_KP" na numer "SMS_NUMBER_KP", koszt: 3.69z³ z VAT.\nI wpisz poni¿ej kod zwrotny:");
	ShowPlayerDialog(playerid, DIALOG_SHOP_KP, DIALOG_STYLE_INPUT, "KP-Shop", string, "Kup", "Anuluj");
	return 1;
}

