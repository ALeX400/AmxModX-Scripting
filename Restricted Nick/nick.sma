#include <amxmodx>

new Array:g_Things = Invalid_Array;
new g_NamesCount = 0;
new def_name[512];
new r_name[512];

public plugin_init()
{
	register_plugin("Restricted Names", "1.1", "Hattrick (Claudiu HKS)");
	
	static File, Location[256], ConfigurationFilesDirectory[128], Line[64];

	get_localinfo("amxx_configsdir", ConfigurationFilesDirectory, charsmax(ConfigurationFilesDirectory));

	formatex(Location, charsmax(Location), "%s/Rest-Nick.ini", ConfigurationFilesDirectory);
	formatex(def_name, charsmax(def_name), "%s/Ignore_Nick.ini", ConfigurationFilesDirectory);
	formatex(r_name, charsmax(r_name), "%s/Random_Nick.ini", ConfigurationFilesDirectory);
	
	if(!file_exists(def_name))
	{
		write_file(def_name, "", -1);
	}
	if(!file_exists(r_name))
	{
		write_file(r_name, "", -1);
	}
	
	if (!file_exists(Location))
	{
		File = fopen(Location, "w+");
		
		switch (File)
		{
			case 0:
			{
				
			}
			
			default:
			{
				fclose(File);
			}
		}
	}

	File = fopen(Location, "r");

	if (!File)
	{
		log_amx("Unable to open ^"%/Rest-Nick.ini^".", ConfigurationFilesDirectory);

		return;
	}
	
	g_Things = ArrayCreate(64);
	
	if (g_Things == Invalid_Array)
	{
		set_fail_state("Plugin failed to load.");
		
		return;
	}

	while (!feof(File))
	{
		fgets(File, Line, charsmax(Line));

		trim(Line);
		
		if (strlen(Line) && Line[0] != ';')
		{
			ArrayPushString(g_Things, Line);
		}
	}
	
	fclose(File);
	
	if (g_Things == Invalid_Array || !ArraySize(g_Things))
	{
		log_amx("No restricted names found in ^"%s/Rest-Nick.ini^".", ConfigurationFilesDirectory);
	}
}

public client_putinserver(Client)
{
	if (g_Things == Invalid_Array || !ArraySize(g_Things))
	{
		return;
	}

	static Name[32], Iterator, Thing[32];	
	get_user_name(Client, Name, charsmax(Name));
	
	if(is_valid_name(Name))
	{
		return;
	}
	
	for (Iterator = 0; Iterator < ArraySize(g_Things); Iterator++)
	{
		ArrayGetString(g_Things, Iterator, Thing, charsmax(Thing));
		
		if (containi(Name, Thing) != -1)
		{
			set_random_nick(Client);
			client_cmd(Client, "name ^"%s^"", Name);
			
			break;
		}
	}
}

public client_infochanged(Client)
{
	if (g_Things == Invalid_Array || !ArraySize(g_Things))
	{
		return;
	}

	static OldName[32], Name[32], Iterator, Thing[32];

	get_user_name(Client, OldName, charsmax(OldName));
	get_user_info(Client, "name", Name, charsmax(Name));
	
	if(is_valid_name(Name))
	{
		return;
	}
	
	if (equali(Name, OldName))
	{
		return;
	}
	
	for (Iterator = 0; Iterator < ArraySize(g_Things); Iterator++)
	{
		ArrayGetString(g_Things, Iterator, Thing, charsmax(Thing));
		
		if (containi(Name, Thing) != -1)
		{
			set_random_nick(Client)
			
			client_cmd(Client, "name ^"%s^"", Name);
			
			break;
		}
	}
}
stock bool:is_valid_name(name[])
{
	new file = fopen(def_name, "rt")
	new line = file_size(def_name)
	new data[512], buff[192]
	
	for(new i = 0; i < line; i++)
	{
		if(!feof(file))
		{
			fgets(file, data, sizeof(data) -1)
			
			trim(data);
			
			parse(data,buff,sizeof(buff) -1)
			
			if(containi(name, buff) != -1)
			{
				return true
			}
		}
	}
	return false
}

stock set_random_nick(id)
{
	new file = fopen(r_name, "rt")
	new line = file_size(r_name)
	new data[512], buff[192]
	
	for(new i = 0; i < line; i++)
	{
		if(!feof(file))
		{
			fgets(file, data, sizeof(data) -1)
			
			trim(data);
			
			parse(data,buff,sizeof(buff) -1)
		}
	}
	random(line);
	
	new Name[32]
	formatex(Name, charsmax(Name), "%s [%d]", buff, ++g_NamesCount);
			
	set_user_info(id, "name", Name);
	
	return 1;
}
