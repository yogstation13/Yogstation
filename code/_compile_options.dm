//#define TESTING				//By using the testing("message") proc you can create debug-feedback for people with this
								//uncommented, but not visible in the release version)

//#define DATUMVAR_DEBUGGING_MODE	//Enables the ability to cache datum vars and retrieve later for debugging which vars changed.

// Comment this out if you are debugging problems that might be obscured by custom error handling in world/Error
#ifdef DEBUG
#define USE_CUSTOM_ERROR_HANDLER
#endif

#ifdef TESTING
#define DATUMVAR_DEBUGGING_MODE

//#define GC_FAILURE_HARD_LOOKUP	//makes paths that fail to GC call find_references before del'ing.
									//implies FIND_REF_NO_CHECK_TICK

//#define FIND_REF_NO_CHECK_TICK	//Sets world.loop_checks to false and prevents find references from sleeping

///Used to find the sources of harddels, quite laggy, don't be surpised if it freezes your client for a good while
//#define REFERENCE_TRACKING
#ifdef REFERENCE_TRACKING

///Run a lookup on things hard deleting by default.

//#define GC_FAILURE_HARD_LOOKUP
#ifdef GC_FAILURE_HARD_LOOKUP
#define FIND_REF_NO_CHECK_TICK
#endif //ifdef GC_FAILURE_HARD_LOOKUP

//#define REFERENCE_TRACKING		//Enables extools-powered reference tracking system, letting you see what is
									//referencing objects that refuse to hard delete
#endif //ifdef REFERENCE_TRACKING

//#define VISUALIZE_ACTIVE_TURFS	//Highlights atmos active turfs in green
#endif //ifdef TESTING

/// If this is uncommented, we set up the ref tracker to be used in a live environment
/// And to log events to [log_dir]/harddels.log
//#define REFERENCE_DOING_IT_LIVE
#ifdef REFERENCE_DOING_IT_LIVE
// compile the backend
#define REFERENCE_TRACKING
// actually look for refs
#define GC_FAILURE_HARD_LOOKUP
#endif // REFERENCE_DOING_IT_LIVE

//#define UNIT_TESTS			//Enables unit tests via TEST_RUN_PARAMETER

#ifndef PRELOAD_RSC				//set to:
#define PRELOAD_RSC	2			//	0 to allow using external resources or on-demand behaviour;
#endif							//	1 to use the default behaviour;
								//	2 for preloading absolutely everything;

#ifdef LOWMEMORYMODE
#define FORCE_MAP "_maps/runtimestation.json"
#endif

//Update this whenever you need to take advantage of more recent byond features
#define MIN_COMPILER_VERSION 514
#if DM_VERSION < MIN_COMPILER_VERSION
//Don't forget to update this part
#error Your version of BYOND is too out-of-date to compile this project. Go to https://secure.byond.com/download and update.
#error You need version 514 or higher
#endif

//Additional code for the above flags.
#ifdef TESTING
#warn compiling in TESTING mode. testing() debug messages will be visible.
#endif

#ifdef GC_FAILURE_HARD_LOOKUP
#define FIND_REF_NO_CHECK_TICK
#endif

#ifdef TRAVISBUILDING
#define UNIT_TESTS
#endif

#ifdef TRAVISTESTING
#define TESTING
#endif

#define EXTOOLS (world.system_type == MS_WINDOWS ? "byond-extools.dll" : "libbyond-extools.so")

//If you update these values, update the message in the #error
#define MAX_BYOND_MAJOR 514
#define MAX_BYOND_MINOR 1583

///Uncomment to bypass the max version check. Note: This will likely break the game, only use if you know what you're doing
//#define IGNORE_MAX_BYOND_VERSION
#if ((DM_VERSION > MAX_BYOND_MAJOR) || (DM_BUILD > MAX_BYOND_MINOR)) && !defined(IGNORE_MAX_BYOND_VERSION)
#error Your version of BYOND is too new to compile this project. Download version 514.1569 at www.byond.com/download/build/514/514.1569_byond.exe
#endif

#ifdef TRAVISBUILDING
// Turdis is special :)
#define CBT
#endif

#ifdef TGS
// TGS performs its own build of dm.exe, but includes a prepended TGS define.
#define CBT
#endif

#if !defined(CBT) && !defined(SPACEMAN_DMM)
#warn "Building with Dream Maker is no longer supported and may result in errors."
#warn "In order to build, run BUILD.bat in the root directory."
#warn "Consider switching to VSCode editor instead, where you can press Ctrl+Shift+B to build."
#endif
