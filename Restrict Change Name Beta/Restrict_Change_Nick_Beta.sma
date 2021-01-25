#include <amxmodx> 
#include <fakemeta> 
#include <amxmisc>

new const 		PluginName[]		=	"Test Restrict Change Name",
			Version[]		= 	"1.0a-dev",
			Author[]		=	"Team RsX";

new bool:Block_Nick[MAX_PLAYERS+1]

public plugin_init() 
{ 
	register_plugin(PluginName, Version, Author) 
	register_concmd("amx_tnick", "cmdNick", ADMIN_SLAY, "<name or #userid> <new nick>")
	register_forward(FM_ClientUserInfoChanged, "ClientUserInfoChanged");
} 

public client_putinserver(id)
{
	Block_Nick[id] = true;
}

public cmdNick(id, level, cid)
{
	if (!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED
	
	new arg1[32], arg2[32], authid[32], name[32], authid2[32], name2[32]
	
	read_argv(1, arg1, 31)
	read_argv(2, arg2, 31)
	
	new player = cmd_target(id, arg1, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF)
	
	if (!player)
		return PLUGIN_HANDLED
	
	get_user_authid(id, authid, 31)
	get_user_name(id, name, 31)
	get_user_authid(player, authid2, 31)
	get_user_name(player, name2, 31)
	
	Block_Nick[player] = false

	set_user_info(player, "name", arg2)
	client_cmd(player, "name ^"%s^"", arg2)
	
	if(!Block(player))
		Block_Nick[player] = true;
	
	log_amx("Cmd: ^"%s<%d><%s><>^" change nick to ^"%s^" ^"%s<%d><%s><>^"", name, get_user_userid(id), authid, arg2, name2, get_user_userid(player), authid2)
	
	client_print_color(0, 0, "%L", id, "CHANGED_NICK", name, name2, arg2);
	
	console_print(id, "[AMXX] %L", id, "CHANGED_NICK", name2, arg2)
	
	return PLUGIN_HANDLED
}

public ClientUserInfoChanged(id) 
{ 
	if(Block(id))
		change_nick(id)
}

public change_nick(id)
{
	static const name[] = "name" 
	static szOldName[32], szNewName[32] 
	pev(id, pev_netname, szOldName, charsmax(szOldName)) 
	if( szOldName[0] ) 
	{
		get_user_info(id, name, szNewName, charsmax(szNewName)) 
		if( !equal(szOldName, szNewName) ) 
		{
			Block_Nick[id] = true;
			client_print_color(id, -2, "[^4AMXX^1] ^3You are not alowed to change nick on server");
			set_user_info(id, name, szOldName) 
			return FMRES_HANDLED
		} 
	} 
	
	return FMRES_IGNORED
}

stock bool:Block(id)
{
	switch(Block_Nick[id])
	{
		case true: return true;
		case false: return false;
	}
	return false;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1048\\ f0\\ fs16 \n\\ par }
*/
