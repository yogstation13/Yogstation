#define SERVER_LOG_STORAGE_MAX 400 // Number of chat logs the telecomms servers will store before they start deleting the older ones.
#define TELECOMMS_SCAN_RANGE 25 // The range at which the telecomms computers can scan for telecomm servers.

///If something is an 'object' to scripting.
#define IS_OBJECT(thing) (istype(thing, /datum) || istype(thing, /list) || istype(thing, /savefile) || istype(thing, /client) || (thing==world))
