/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <hamsandwich>
#include <fvault>

#define MAX_POINT 	50000


new const 	PluginName[]	=	"Shop System RsX",
		Version[]	=	"1.0-dev",
		Author[]	=	"Team RsX",
		db_save[] 	= 	"shop_point";
new 	cvar_tag, 
	cvar_trans_time,
	cvar_invis_time,
	cvar_god_time;
	
new _time[33], Point[33];

new PlayerHasBenef[33];

new 	cvar_price_god,
	cvar_price_invis,
	cvar_price_trans,
	cvar_price_hp,
	cvar_price_ap;

new Chat_Commands[][] =
{
	"/shop",
	"/shop_menu",
	"/point"
}


public plugin_init() 
{
	register_plugin(PluginName, Version, Author);
	register_clcmd("say", "cmd_chat");
	register_clcmd("say_team", "cmd_chat");
	cvar_tag = register_cvar("shop_tag", "RsX");
	
	cvar_trans_time = register_cvar("shop_transparency_time", "35");
	cvar_invis_time = register_cvar("shop_invisibility_time", "35");
	cvar_god_time = register_cvar("shop_godmode_time", "35");
	
	cvar_price_god = register_cvar("shop_price_godmode", "300");
	cvar_price_invis = register_cvar("shop_price_invisibility", "200");
	cvar_price_trans = register_cvar("shop_price_transparency", "100");
	cvar_price_hp = register_cvar("shop_price_health", "20");
	cvar_price_ap = register_cvar("shop_price_armor", "10");
	
	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
}

// Load DATA
public client_authorized(id) set_task(2.0, "load_data", id);

public load_data(id)
{
	new name[40], data[50], g_Point[20];
	
	get_user_name(id, name, charsmax(name));

	fvault_get_data(db_save, name, data, charsmax(data));
	parse(data, g_Point, charsmax(g_Point));

	Point[id] = str_to_num(g_Point);
	
	if(Point[id] >= MAX_POINT)
		Point[id] = MAX_POINT;
}

public client_death(killer, victim, weapon, hitplace)
{
	new victim_name[32]
	get_user_name(victim, victim_name, charsmax(victim_name))

	new killer_team = get_user_team(killer)
	new victim_team = get_user_team(victim)


	//NORMAL KILL
	if((killer != victim) && !(killer_team == victim_team) && !(hitplace == HIT_HEAD) && !(weapon == CSW_HEGRENADE) && !(weapon == CSW_KNIFE))
	{
		Point[killer]++
	}

	

	//HEADSHOT
	if(hitplace == HIT_HEAD && !(weapon == CSW_KNIFE) && !(killer_team == victim_team))
	{
		Point[killer]+=3

	}

	
	//KNIFE KILL
	if(weapon == CSW_KNIFE && !(hitplace == HIT_HEAD) && !(killer_team == victim_team))
	{
		Point[killer]+=5
	}


	//KNIFE + HEADSHOT
	if(weapon == CSW_KNIFE && (hitplace == HIT_HEAD) && !(killer_team == victim_team))
	{
		Point[killer]+=7
	}

	

	//GRENADE KILL
	if(weapon == CSW_HEGRENADE && (killer != victim) && !(killer_team == victim_team))
	{
		Point[killer]+=5
	}

	//SUICIDE
	if(killer == victim)
	{
		Point[killer]-=2
	}
	
	//TEAM KILL
	if(killer != victim && (killer_team == victim_team))
	{
		Point[killer]-=10
	}

	save_data(killer)
}


public save_data(id)
{
	if(!is_user_connected(id))
		return 1;


	new name[40], data[50];
	get_user_name(id, name, charsmax(name))

	formatex(data, charsmax(data), "%d", Point[id]);
	fvault_pset_data(db_save, name, data);

	return 1;
}

public cmd(id, say[])
{
	for(new i = 0; i < sizeof Chat_Commands;i++)
	{
		if(equal(say, Chat_Commands[i]))
		{
			switch(i)
			{
				case 0,1: cmd_menu(id);
				case 2: client_print_color(id, 0, "( ^4Shop System ^1) You Have ^4%d Points", Point[id]);
			}
			return 1;
		}
	}

	return 0;
}


public cmd_chat(id)
{
	new say[191]
	read_args(say, 191);
	remove_quotes(say);
	
	if(cmd(id, say) == PLUGIN_HANDLED)
		return 0;
		
	return 0;
}


public cmd_menu( id )
{
	new MenuTitle[ 168 ];
	new tag[32]
	get_pcvar_string(cvar_tag, tag, charsmax(tag));

	formatex( MenuTitle, sizeof( MenuTitle ) -1, "\wShop \yMenu \y(\r%s\y)", tag);
	new BanMenu = menu_create( MenuTitle, "MenuHandler" );
	
	new ItemT[201],ItemI[201],ItemH[201],ItemA[201],ItemG[201];
	
	format(ItemT, sizeof(ItemT) -1, "\yTransparency \r%d \yPoint", get_pcvar_num(cvar_price_trans));
	menu_additem( BanMenu, ItemT, "1");
	
	format(ItemI, sizeof(ItemI) -1, "\yInvisibility \r%d \yPoint", get_pcvar_num(cvar_price_invis));
	menu_additem( BanMenu, ItemI, "2");

	format(ItemG, sizeof(ItemG) -1, "\yGod Mode \r%d \yPoint", get_pcvar_num(cvar_price_god));
	menu_additem( BanMenu, ItemG, "3");

	format(ItemH, sizeof(ItemH) -1, "\r+\y50 HP \r%d \yPoint", get_pcvar_num(cvar_price_hp));
	menu_additem( BanMenu, ItemH, "4");

	format(ItemA, sizeof(ItemA) -1, "\r+\y50 AP \r%d \yPoint", get_pcvar_num(cvar_price_ap));
	menu_additem( BanMenu, ItemA, "5")
	
	menu_display( id, BanMenu );
}

public MenuHandler( id, menu, item)
{
	if(item == MENU_EXIT)
		return 1;
		
	new _access, callback, data[5], szName[64];
		
	menu_item_getinfo(menu, item, _access, data, charsmax(data), szName, charsmax(szName), callback);
	new key = str_to_num(data);
	static Price;
	
	switch( key )
	{
		case 1: 
		{
			Price = get_pcvar_num(cvar_price_trans)
			
			if(user_has_point(id, Price))
				_cmd_trans(id)
		}
		
		case 2:
		{
			Price = get_pcvar_num(cvar_price_invis)
			
			/*if (Point[id] <  Price)
			{
				client_print_color(id,-2, "You don't have enough points for this item (need %d)", Price);
				return 1;
			}*/
			if(user_has_point(id, Price))			
				_cmd_invis(id);
		}
		case 3: 
		{
			Price = get_pcvar_num(cvar_price_god)
			
			/*if (Point[id] <  Price)
			{
				client_print_color(id,-2, "You don't have enough points for this item (need %d)", Price);
				return 1;
			}*/
			
			if(user_has_point(id, Price))			
				_cmd_godmode(id);
			
			/*if(Point[id] >=  Price)
			{
				Point[id]-=Price
				_cmd_godmode(id);
			}*/
		}
		case 4: 
		{
			Price = get_pcvar_num(cvar_price_hp)
			
			/*if (Point[id] <  Price)
			{
				client_print_color(id,-2, "You don't have enough points for this item (need %d)", Price);
				return 1;
			}*/
			if(user_has_point(id, Price))			
				_cmd_health(id);
		}
		case 5: 
		{
			Price = get_pcvar_num(cvar_price_ap)
			
			/*if (Point[id] <  Price)
			{
				client_print_color(id, 0, "You don't have enough points for this item (need %d)", Price);
				return 1;
			}*/
			
			if(user_has_point(id, Price))			
				_cmd_armor(id)
		}	
	}
			
	menu_destroy(menu);
	return 1;  
}



stock bool:user_has_point(id, value)
{
	if(Point[id] >=  value)
	{
		Point[id]-=value;
		save_data(id)
		return true;
	}
		
	if(Point[id] < value)
	{
		client_print_color(id, -2, "^1( ^4Shop System ^1) ^3You don't have enough points for this item (^1need ^4%d^3)", value);
		return false;
	}
	return false;
}

public Spawn(id)
{
	if(!is_user_alive(id) || is_user_hltv(id) || is_user_bot(id))
		return 1;
		
	if(user_has_benefit(id))
	{
		PlayerHasBenef[id] = false;
		client_print_color(id, 0, "( ^4Shop System ^1) All ^3benefits ^1have been ^4reset");
	}
	return 1;

}
stock bool:user_has_benefit(id) return (PlayerHasBenef[id]) ? true : false

_cmd_health(id)
{
	if(ist_alive(id))
		return 1;
		
	client_print_color(id, 0, "( ^4Shop System ^1) ^4Congratulations^1, you received ^3+^4 50^1 Health (^4HP^1)");
	set_user_health(id, get_user_health(id) + 50);
	
	return 1;
}

_cmd_armor(id)
{
	if(ist_alive(id))
		return 1;
		
	client_print_color(id, 0, "( ^4Shop System ^1) ^4Congratulations^1, you received ^3+^4 50^1 Armor (^4AP^1)");
	set_user_armor(id, get_user_armor(id) + 50);
	
	return 1;
}

_cmd_godmode(id)
{
	if(ist_alive(id))
		return 1;
		
	PlayerHasBenef[id] = false
	
	_time[id] = get_pcvar_num(cvar_god_time) - 1;
	
	client_print_color(id, 0, "^4Congratulations^1, you received ^4God Mode^1 for^4 %d^3 sec^1.", get_pcvar_num(cvar_god_time));

	set_task(1.0, "_godmode", id, _, _, "a", get_pcvar_num(cvar_god_time));	
	
	return 1;
}

_cmd_trans(id)
{
	if(ist_alive(id))
		return 1;
		
	PlayerHasBenef[id] = false
	
	_time[id] = get_pcvar_num(cvar_god_time) - 1;
	
	client_print_color(id, 0, "( ^4Shop System ^1) ^4Congratulations^1, you received ^4Invisibility^1 for^4 %d^3 sec^1.", get_pcvar_num(cvar_trans_time));
	
	set_task(1.0, "_trans", id, _, _, "a", get_pcvar_num(cvar_trans_time));	
	
	return 1;
}

_cmd_invis(id)
{
	if(ist_alive(id))
		return 1;
	
	PlayerHasBenef[id] = false
	_time[id] = get_pcvar_num(cvar_invis_time) - 1;
	
	client_print_color(id, 0, "( ^4Shop System ^1) ^4Congratulations^1, you received ^4Invisibility^1 for^4 %d^3 sec^1.", get_pcvar_num(cvar_invis_time));
	
	set_task(1.0, "_invis", id, _, _, "a", get_pcvar_num(cvar_invis_time));	
	
	return 1;
}
public _invis(id)
{
	PlayerHasBenef[id] = true;
	
	set_user_glow(id, 0);
	if(_time[id])
		_time[id]--;
	else
	{
		PlayerHasBenef[id] = false;
		remove_user_glow(id)
	}
}

public _trans(id)
{
	PlayerHasBenef[id] = true;
	
	set_user_glow(id, 75);
	if(_time[id])
		_time[id]--;
	else
	{	
		PlayerHasBenef[id] = false;
		remove_user_glow(id)
	}
}

public _godmode(id)
{
	PlayerHasBenef[id] = true;
		
	set_user_godmode(id, 1);
	if(_time[id])
		_time[id]--;
	else
	{
		PlayerHasBenef[id] = false;
		set_user_godmode(id);
	}
}

stock bool:ist_alive(id)
{
	if(!is_user_alive(id))
	{
		client_print_color(id, -2, "^1( ^4Shop System ^1) ^3You cannot buy this item because you are not ^4alive");
		return true
	}
	
	return false;
}

public client_infochanged(id) set_task(0.1, "load_data", id);

stock set_user_glow(id, iAlpha) set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderTransAlpha, iAlpha)
stock remove_user_glow(id) set_user_rendering(id, kRenderFxNone, 0, 0, 0, kRenderNormal, 0)
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1048\\ f0\\ fs16 \n\\ par }
*/
