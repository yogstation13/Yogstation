#define SUCCESSFUL_SPAWN 2
#define NOT_ENOUGH_PLAYERS 3
#define MAP_ERROR 4
#define WAITING_FOR_SOMETHING 5

#define EVENT_CANT_RUN 0
#define EVENT_READY 1
#define EVENT_CANCELLED 2
#define EVENT_INTERRUPTED 3

/// Return from admin setup to stop the event from triggering entirely.
#define ADMIN_CANCEL_EVENT "cancel event"

/// Event can never be triggered by wizards
#define NEVER_TRIGGERED_BY_WIZARDS -1
/// Event can only run on a map set in space
#define EVENT_SPACE_ONLY (1 << 0)
/// Event can only run on a map which is a planet
#define EVENT_PLANETARY_ONLY (1 << 1)
/// Event timer in seconds
#define EVENT_SECONDS *0.5

///Backstory key for the fugitive solo backstories
#define FUGITIVE_BACKSTORY_WALDO "waldo"
#define FUGITIVE_BACKSTORY_INVISIBLE "invisible"
///Backstory keys for the fugitive team backstories
#define FUGITIVE_BACKSTORY_PRISONER "prisoner"
#define FUGITIVE_BACKSTORY_CULTIST "cultist"
#define FUGITIVE_BACKSTORY_SYNTH "synth"
