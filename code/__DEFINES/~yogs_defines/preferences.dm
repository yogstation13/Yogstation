#define DONOR_CHARACTER_SLOTS 6


#define CHAT_LOOC	(1<<10)

#undef TOGGLES_DEFAULT_CHAT
#define TOGGLES_DEFAULT_CHAT (CHAT_OOC|CHAT_DEAD|CHAT_GHOSTEARS|CHAT_GHOSTSIGHT|CHAT_PRAYER|CHAT_RADIO|CHAT_PULLR|CHAT_GHOSTWHISPER|CHAT_GHOSTPDA|CHAT_GHOSTRADIO|CHAT_LOOC)

#define GHOST_CKEY	(1<<11)


//YOGS pref.yogstoggles enum's

#define QUIET_ROUND				(1<<0) //Donor features, quiet round; in /~yogs_defines/, as god intended
#define PREF_MOOD				(1<<1) //Toggles the use of the Mood feature. Defaults to off, thank god.

#define YOGTOGGLES_DEFAULT 0
