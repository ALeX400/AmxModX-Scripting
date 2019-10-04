#include <amxmodx>
#include <cstrike>
#include <amxmisc>
#include <csdm>

new const 	Versiune[]		= "1.6.3",
		Build			= 13,
		Data[]			= "03.10.2019",
		NumePlugin[]		= "CSDM Transfer",
		Autor[]			= "Setta0629 + Edit @LeX";

new		cvar_pub_chat,
		cvar_adm_chat;

public plugin_init()
{    

	register_plugin(NumePlugin, Versiune, Autor);
		
	register_concmd("amx_ct", "cmd_ct", ADMIN_KICK,"<nume> - Transfera un jucator la echipa 'Counter-Terorist' .");
	register_concmd("amx_t", "cmd_t", ADMIN_KICK,"<nume> - Transfera un jucator la echipa 'Terorist' .");
	register_concmd("amx_spec", "cmd_spec", ADMIN_KICK,"<nume> - Transfera un jucator la echipa 'spectator' .");
	register_concmd("amx_play", "cmd_respawn", ADMIN_KICK,"<nume> - Ofera 'respawn' unui jucator .");
	
	register_cvar("csdm_transfer", Versiune, FCVAR_SERVER | FCVAR_SPONLY);

	register_dictionary("csdm_transfer.txt");
	
	cvar_pub_chat = register_cvar("csdm_transfer_adm", "1");
	cvar_adm_chat = register_cvar("csdm_transfer_pub", "1");
	
	register_clcmd("say",		 "Comenzi_Chat");
	register_clcmd("say_team",	 "Comenzi_Chat");
}

public Comenzi_Chat(id) 
{
	new Mesaj[192];
		
	read_argv(1, Mesaj, 31);
	remove_quotes(Mesaj);
	
	if( equal(Mesaj, "!csdm_transfer" ))
	{
		client_print_color(0, print_team_default, "^3[CSDM Transfer] ^1 Detineti versiunea :^4 %s^1. Bulid :^4 %d^1. Data lansarii versiunii:^4 %s^1.", Versiune, Build, Data);
		return 1;
	}
	
	if( equal(Mesaj, "!play" ))
		{
		
		if(is_user_alive(id))
		{
			client_print_color(id, print_team_red, "%L", LANG_PLAYER, "CSDM_TRANSFER_PLAY_AL");
			return 1;
		}
		
		if(cs_get_user_team(id) == CS_TEAM_SPECTATOR)
		{
			client_print_color(id, print_team_red, "%L", LANG_PLAYER, "CSDM_TRANSFER_PLAY_SP");
			return 1;
		}
		csdm_respawn (id);
		
		if(get_pcvar_num(cvar_pub_chat) == 1)
		{
			client_print_color(id, print_team_default, "%L", LANG_PLAYER, "CSDM_TRANSFER_PLAY_RSP");
			return 1;
		}
		return 1;
	}
	
	if( equal(Mesaj, "!spec" ))
	{	
		if(cs_get_user_team(id) == CS_TEAM_SPECTATOR)
		{
			client_print_color(id, print_team_grey, "%L", LANG_PLAYER, "CSDM_TRANSFER_PUB_AL_SPEC");
			return 1;
		}
		
		cs_set_user_team (id ,CS_TEAM_SPECTATOR);
		
		user_silentkill (id);
		
		if(get_pcvar_num(cvar_pub_chat) == 1)
		{
			client_print_color(id, print_team_grey, "%L", LANG_PLAYER,"CSDM_TRANSFER_PUB_SPEC");
			return 1;
		}
		return 1;
	}

	if ( equal(Mesaj, "!ct" ))
	{
		if(cs_get_user_team(id) == CS_TEAM_CT)
		{
			client_print_color(id, print_team_blue, "%L", LANG_PLAYER, "CSDM_TRANSFER_PUB_AL_CT");
			return 1;
		}
		cs_set_user_team(id ,CS_TEAM_CT);
		user_silentkill (id);
		csdm_respawn (id);
		
		if(get_pcvar_num(cvar_pub_chat) == 1)
		{	
			client_print_color(id, print_team_blue, "%L", LANG_PLAYER, "CSDM_TRANSFER_PUB_CT");
			return 1;
		}
		return 1;
	} 
	
	if ( equal(Mesaj, "!t" ))
	{
		if(cs_get_user_team(id) == CS_TEAM_T)
		{
			client_print_color(id, print_team_red, "%L", LANG_PLAYER, "CSDM_TRANSFER_PUB_AL_T");
			return 1;
		}
		cs_set_user_team(id,CS_TEAM_T);
		
		user_silentkill (id);
		csdm_respawn (id);
		
		if(get_pcvar_num(cvar_pub_chat) == 1)
		{
			client_print_color(id, print_team_red, "%L", LANG_PLAYER, "CSDM_TRANSFER_PUB_T");
			return 1;
		}
		return 1;
	}
	return 0;
}

public cmd_respawn(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return 1 ;
	
	new arg[32] ;
	read_argv(1, arg, 31); 
	new player = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF);
	if (!player)
		return 1;
	
	static Admin[32], name2[32];
	
	get_user_name(id,Admin,31);
	get_user_name(player,name2, 31);
	
	
	if(is_user_alive(player))
	{
		console_print(id, "Nu poti oferi respawn jucatorului '%s' cat timp este in viata !", name2);
		return 1;
	}
		
	if(cs_get_user_team(player) == CS_TEAM_SPECTATOR)
	{
		console_print(id,"Nu poti oferi respawn jucatorului '%s' cat timp este Spectator !", name2);
		return 1;
	}
	
	csdm_respawn (player);
	
	log_amx("Admin %s: Task amx_play %s",Admin, name2);
	
	if(get_pcvar_num(cvar_adm_chat) == 1)
	{
		client_print_color(0, print_team_grey, "%L", LANG_PLAYER, "CSDM_TRANSFER_ADM_RSP", Admin, name2);
		return 1;
	}
	return 1;
} 

public cmd_ct(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return 1 ;
	
	new arg[32] ;
	read_argv(1, arg, 31); 
	new player = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF);
	if (!player)
		return 1;
	
	if(cs_get_user_team(player) == CS_TEAM_CT)
	{
		console_print(id, "Jucatorul este deja in echipa Counter-Terorist");
		return 1;
	}
	
	cs_set_user_team (player ,CS_TEAM_CT);
	
	user_silentkill(player);
	csdm_respawn (player);
	
	static Admin[32], name2[32];
	
	get_user_name(id,Admin,31);
	get_user_name(player,name2, 31);
	
	log_amx("Admin %s: Task amx_ct %s",Admin, name2);
	
	if(get_pcvar_num(cvar_adm_chat) == 1)
	{
		client_print_color(0, print_team_blue, "%L", LANG_PLAYER, "CSDM_TRANSFER_ADM_CT", Admin, name2);
		return 1;
	}
	return 1;
} 

public cmd_t(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return 1;
	
	new arg[32];
	
	read_argv(1, arg, 31);
	
	new player = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF);
	
	if (!player)    
		return 1;
		
	if(cs_get_user_team(player) == CS_TEAM_T)
	{
		console_print(id, "Jucatorul este deja in echipa Terrorist");
		return 1;
	}
	
	cs_set_user_team (player ,CS_TEAM_T);
	
	
	user_silentkill(player);
	csdm_respawn (player);
	
	static Admin[32], name2[32];
	
	get_user_name(id,Admin,31);
	get_user_name(player,name2, 31);
	
	log_amx("Admin %s: Task amx_t %s",Admin, name2);
	
	if(get_pcvar_num(cvar_adm_chat) == 1)
	{
		client_print_color(0, print_team_red, "%L", LANG_PLAYER, "CSDM_TRANSFER_ADM_T", Admin, name2);
		return 1;
	}
	return 1;
} 

public cmd_spec(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return 1;
	
	new arg[32];
	read_argv(1, arg, 31);
	
	new player = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF);
	
	if (!player)
		return 1;
		
	if(cs_get_user_team(player) == CS_TEAM_SPECTATOR)
	{
		console_print(id, "Jucatorul este deja Spectator");
		return 1;
	}
	
	cs_set_user_team (player ,CS_TEAM_SPECTATOR);
	
	user_silentkill(player);
	
	static Admin[32], name2[32];
	
	get_user_name(id,Admin,31);
	get_user_name(player,name2, 31);
	
	log_amx("Admin %s: Task amx_spec %s",Admin, name2);
	
	if(get_pcvar_num(cvar_adm_chat) == 1)
	{
		client_print_color(0, print_team_grey, "%L", LANG_PLAYER, "CSDM_TRANSFER_ADM_SPEC", Admin, name2);
		return 1;
	}
	return 1;
}
