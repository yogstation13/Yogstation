#define DONOR_CHARACTER_SLOTS 3


#define CHAT_LOOC	(1<<11)
#define GHOST_CKEY	(1<<12)
#define CHAT_TYPING_INDICATOR (1<<13)
#define HEAR_TTS (1<<14)
#undef TOGGLES_DEFAULT_CHAT
#define TOGGLES_DEFAULT_CHAT (CHAT_OOC|CHAT_DEAD|CHAT_GHOSTEARS|CHAT_GHOSTSIGHT|CHAT_PRAYER|CHAT_RADIO|CHAT_PULLR|CHAT_GHOSTWHISPER|CHAT_GHOSTPDA|CHAT_GHOSTRADIO|CHAT_BANKCARD|CHAT_LOOC|GHOST_CKEY|CHAT_TYPING_INDICATOR|HEAR_TTS)

// TTS enums
GLOBAL_LIST_INIT(tts_enum, list("Masc1" = ":np", "Masc2" = ":nh", "Masc3" = ":nf", "Masc4" = ":nd", "Fem1" = ":nb", "Fem2" = ":nr", "Fem3" = ":nu", "Fem4" = ":nw"))
#define MASC1 ":np"
#define MASC2 ":nh"
#define MASC3 ":nf"
#define MASC4 ":nd"
#define FEM1 ":nb"
#define FEM2 ":nr"
#define FEM3 ":nu"
#define FEM4 ":nw"
GLOBAL_LIST_INIT(tts_all, list(MASC1, MASC2, MASC3, MASC4, FEM1, FEM2, FEM3, FEM4))
GLOBAL_LIST_INIT(tts_masc, list(MASC1, MASC2, MASC3, MASC4))
GLOBAL_LIST_INIT(tts_fem, list(FEM1, FEM2, FEM3, FEM4))


//YOGS pref.yogstoggles enum's

#define QUIET_ROUND				(1<<0) //Donor features, quiet round; in /~yogs_defines/, as god intended
#define PREF_MOOD				(1<<1) //Toggles the use of the Mood feature. Defaults to off, thank god.

#define YOGTOGGLES_DEFAULT 0
