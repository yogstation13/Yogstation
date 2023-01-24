#define DONOR_BYOND (1<<0)
#define DONOR_YOGS (1<<1)

#define DONOR_BYOND_SLOTS 2
#define DONOR_YOGS_SLOTS 3

#define CHAT_LOOC	(1<<11)
#define GHOST_CKEY	(1<<12)
#define CHAT_TYPING_INDICATOR (1<<13)
#undef TOGGLES_DEFAULT_CHAT
#define TOGGLES_DEFAULT_CHAT (CHAT_OOC|CHAT_DEAD|CHAT_GHOSTEARS|CHAT_GHOSTSIGHT|CHAT_PRAYER|CHAT_RADIO|CHAT_PULLR|CHAT_GHOSTWHISPER|CHAT_GHOSTPDA|CHAT_GHOSTRADIO|CHAT_BANKCARD|CHAT_LOOC|GHOST_CKEY|CHAT_TYPING_INDICATOR)




//YOGS pref.yogstoggles enum's
// !!! DO NOT ADD ANY NEW ONES HERE !!!
// Use `/datum/preference/toggle` instead.
#define QUIET_ROUND				(1<<0) //Donor features, quiet round; in /~yogs_defines/, as god intended
#define PREF_MOOD				(1<<1) //Toggles the use of the Mood feature. Defaults to off, thank god.

#define YOGTOGGLES_DEFAULT 0
