// Used to stringify message targets before sending the signal datum.
#define STRINGIFY_PDA_TARGET(name, job) "[name] ([job])"
/**
 * program_flags
 * Used by programs to tell the ModPC any special functions it has.
 */
/* //TODO: Add these back in when TG ModPCs are ported.
///If the program requires NTNet to be online for it to work.
#define PROGRAM_REQUIRES_NTNET (1<<0)
///The program can be downloaded from the default NTNet downloader store.
#define PROGRAM_ON_NTNET_STORE (1<<1)
///The program can only be downloaded from the Syndinet store, usually nukie/emagged pda.
#define PROGRAM_ON_SYNDINET_STORE (1<<2)
///The program is unique and will delete itself upon being transferred to ensure only one copy exists.
#define PROGRAM_UNIQUE_COPY (1<<3)
///The program is a header and will show up at the top of the ModPC's UI.
#define PROGRAM_HEADER (1<<4)
///The program will run despite the ModPC not having any power in it.
#define PROGRAM_RUNS_WITHOUT_POWER (1<<5)
///The circuit ports of this program can be triggered even if the program is not open
#define PROGRAM_CIRCUITS_RUN_WHEN_CLOSED (1<<6)
*/

//Program categories
#define PROGRAM_CATEGORY_DEVICE "Device Tools"
#define PROGRAM_CATEGORY_EQUIPMENT "Equipment"
#define PROGRAM_CATEGORY_GAMES "Games"
#define PROGRAM_CATEGORY_SECURITY "Security & Records"
#define PROGRAM_CATEGORY_ENGINEERING "Engineering"
#define PROGRAM_CATEGORY_SUPPLY "Supply"
#define PROGRAM_CATEGORY_SCIENCE "Science"

///The default amount a program should take in cell use.
#define PROGRAM_BASIC_CELL_USE 15

///This app grants a minor protection against being PDA bombed if installed.
///(can sometimes prevent it from being sent, while wasting a PDA bomb from the sender).
#define DETOMATIX_RESIST_MINOR 1
///This app grants a larger protection against being PDA bombed if installed.
///(can sometimes prevent it from being sent, while wasting a PDA bomb from the sender).
#define DETOMATIX_RESIST_MAJOR 2
///This app gives a diminished protection against being PDA bombed if installed.
#define DETOMATIX_RESIST_MALUS -4

/**
 * NTNet transfer speeds, used when downloading/uploading a file/program.
 * The define is how fast it will download an app every program's process_tick.
 */
///Used for wireless devices with low signal.
#define NTNETSPEED_LOWSIGNAL 0.5
///Used for wireless devices with high signal.
#define NTNETSPEED_HIGHSIGNAL 1
///Used for laptops with a high signal, or computers, which is connected regardless of z level.
#define NTNETSPEED_ETHERNET 2

/**
 * NTNet connection signals
 * Used to calculate the defines above from NTNet Downloader, this is how
 * good a ModPC's signal is.
 */
///When you're away from the station/mining base and not on a console, you can't access the internet.
#define NTNET_NO_SIGNAL 0
///Low signal, so away from the station, but still connected
#define NTNET_LOW_SIGNAL 1
///On station with good signal.
#define NTNET_GOOD_SIGNAL 2
///Using a Computer or Laptop with good signal, ethernet-connected.
#define NTNET_ETHERNET_SIGNAL 3

/// The default ringtone of the Messenger app.
#define MESSENGER_RINGTONE_DEFAULT "beep"

/// The maximum length of the ringtone of the Messenger app.
#define MESSENGER_RINGTONE_MAX_LENGTH 20

//Modular computer part defines
#define MC_CPU "CPU"
#define MC_HDD "HDD"
#define MC_SDD "SDD"
#define MC_CARD "CARD"
#define MC_CARD2 "CARD2"
#define MC_NET "NET"
#define MC_PRINT "PRINT"
#define MC_CELL "CELL"
#define MC_CHARGE "CHARGE"
#define MC_AI "AI"
#define MC_SENSORS "SENSORS"
#define MC_AI_NETWORK "AINETWORK"

//NTNet stuff, for modular computers
									// NTNet module-configuration values. Do not change these. If you need to add another use larger number (5..6..7 etc)
#define NTNET_SOFTWAREDOWNLOAD 1 // Downloads of software from NTNet
#define NTNET_COMMUNICATION 2 // Communication (messaging)


//Caps for NTNet logging. Less than 10 would make logging useless anyway, more than 500 may make the log browser too laggy. Defaults to 100 unless user changes it.
#define MAX_NTNET_LOGS 300
#define MIN_NTNET_LOGS 10

//Program bitflags
#define PROGRAM_ALL (~0)
#define PROGRAM_CONSOLE (1<<0)
#define PROGRAM_LAPTOP (1<<1)
#define PROGRAM_TABLET (1<<2)
#define PROGRAM_PHONE (1<<3)
#define PROGRAM_PDA (1<<4)
#define PROGRAM_TELESCREEN (1<<5)
#define PROGRAM_INTEGRATED (1<<6)

#define PROGRAM_PORTABLE PROGRAM_LAPTOP | PROGRAM_TABLET | PROGRAM_PHONE | PROGRAM_PDA
#define PROGRAM_STATIONARY PROGRAM_CONSOLE | PROGRAM_TELESCREEN

//Program states
#define PROGRAM_STATE_KILLED 0
#define PROGRAM_STATE_BACKGROUND 1
#define PROGRAM_STATE_ACTIVE 2
