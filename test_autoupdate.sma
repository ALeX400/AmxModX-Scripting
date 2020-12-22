#include <amxmodx>

enum {
    REQUEST_GET,
    REQUEST_POST
}

native HTTPX_Download(const URL[], const Filename[] = "", const CompleteHandler[] = "", const ProgressHandler[] = "", Port = 0, RequestType = REQUEST_GET, const Username[] = "", const Password[] = "", ... /* For possible future use */)
native HTTPX_GetData(data[], len)

#define AUTOUPDATE_FILE_ID "76775"
#define AUTOUPDATE_HOW_OFTEN 0 // Only use this when checking if a new version exists.

new const VersionNum =      100;
new const VersionString[] = "1.00";

public plugin_init() {
    register_plugin("HTTP:X Test", VersionString, "[ --{-@ ]");
    register_concmd("test", "test");

    HTTPX_Download("https://github.com/ALeX400/AmxModX-Scripting/blob/master/test_autoupdate.sma", "", "Complete", "", 443, REQUEST_GET, "", "", 0, -1);
}

public test(id)
{
	console_print(id, "Your current Build is: %d", VersionNum);
}

public Complete(DownloadID, Error) {
    if ( Error )
        return;

    new temp[16];
    HTTPX_GetData(temp, charsmax(temp));

    if ( str_to_num(temp) > VersionNum )
        UpdatePlugin();
}

UpdatePlugin() {
    new hHTTPX = is_plugin_loaded("HTTP:X");
    if ( hHTTPX ) {
        new filename[64];
        get_plugin(hHTTPX, filename, charsmax(filename));
        if ( callfunc_begin("AutoupdatePlugin", filename) == 1 ) {
            callfunc_push_int(get_plugin(-1));
            callfunc_push_str(AUTOUPDATE_FILE_ID, false);
            callfunc_push_int(AUTOUPDATE_HOW_OFTEN);
            callfunc_end();
        }
    }
}
