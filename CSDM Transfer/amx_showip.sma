#include <amxmodx>
//#include <amxmisc>


public plugin_init() 
{
	register_plugin
	(
		.plugin_name = "ShowIP",
		
		.version     = "1.0",
		
		.author      = "?"
	);
	
	register_concmd("amx_showip", "showip", ADMIN_SLAY);
	
}

public showip(id/*, level, cid*/)
{
	//if(!cmd_access(id, level, cid, 1))
		//return 1;
	if(!is_user_admin(id))
	{
		console_print(id, "Nu ai acces la aceasta comanda !");
		return 1;
	}
	
	new g_maxplayers = get_maxplayers();
	
	console_print(id, "-------------------------------------------------------");
	console_print(id, "#UserID     -     IDNume     -     IP     -     SteamID");
	console_print(id, "-------------------------------------------------------");
	static name[32], ip[33], steamid[33],userid;
	for(new i = 1; i <= g_maxplayers; i++)
	{
		if(!is_user_connected(i))
			continue;
		get_user_name(i, name, charsmax(name));
		get_user_ip(i, ip, charsmax(ip), 1); // fara port, daca vrei portul dupa 31, pui inloc de 1 valoarea 0.
		get_user_authid(i, steamid, charsmax(steamid));

		userid = get_user_userid(i);
		console_print(id, "#%d - %s - %s - %s",userid, name, ip, steamid);
	}
	console_print(id, "-------------------------------------------------------");
	console_print(id, "                       RS.FIORIGINAL.RO                ");
	console_print(id, "-------------------------------------------------------");
	return 1;
}