#define SUCCESSFUL_SPAWN 2
#define NOT_ENOUGH_PLAYERS 3
#define MAP_ERROR 4
#define WAITING_FOR_SOMETHING 5

#define EVENT_CANT_RUN 0
#define EVENT_READY 1
#define EVENT_CANCELLED 2
#define EVENT_INTERRUPTED 3

/// Event can only run on a map set in space
#define EVENT_SPACE_ONLY (1 << 0)
/// Event can only run on a map which is a planet
#define EVENT_PLANETARY_ONLY (1 << 1)
