// This file contains defines allowing targeting byond versions newer than the supported

//Update this whenever you need to take advantage of more recent byond features
#define MIN_COMPILER_VERSION 514
#define MIN_COMPILER_BUILD 1556
#if (DM_VERSION < MIN_COMPILER_VERSION || DM_BUILD < MIN_COMPILER_BUILD) && !defined(SPACEMAN_DMM)
//Don't forget to update this part
#error Your version of BYOND is too out-of-date to compile this project. Go to https://secure.byond.com/download and update.
#error You need version 514.1556 or higher
#endif

//If you update these values, update the message in the #error
#define MAX_BYOND_MAJOR 514
#define MAX_BYOND_MINOR 1589

// You can define IGNORE_MAX_BYOND_VERSION to bypass the max version check.
// Note: This will likely break the game, especially any extools/auxtools linkage. Only use if you know what you're doing!
#ifdef OPENDREAM // Thanks, Altoids!
#define IGNORE_MAX_BYOND_VERSION
#endif

#if ((DM_VERSION > MAX_BYOND_MAJOR) || (DM_BUILD > MAX_BYOND_MINOR)) && !defined(IGNORE_MAX_BYOND_VERSION)
#error Your version of BYOND is too new to compile this project. Download version 514.1589 at www.byond.com/download/build/514/514.1589_byond.exe
#endif

// 515 split call for external libraries into call_ext
#if DM_VERSION < 515
#define LIBCALL call
#else
#define LIBCALL call_ext
#endif

// So we want to have compile time guarantees these procs exist on local type, unfortunately 515 killed the .proc/procname syntax so we have to use nameof()
#if DM_VERSION < 515
/// Call by name proc reference, checks if the proc exists on this type or as a global proc
#define PROC_REF(X) (.proc/##X)
/// Call by name proc reference, checks if the proc exists on given type or as a global proc
#define TYPE_PROC_REF(TYPE, X) (##TYPE.proc/##X)
/// Call by name proc reference, checks if the proc is existing global proc
#define GLOBAL_PROC_REF(X) (/proc/##X)
#else
/// Call by name proc reference, checks if the proc exists on this type or as a global proc
#define PROC_REF(X) (nameof(.proc/##X))
/// Call by name proc reference, checks if the proc exists on given type or as a global proc
#define TYPE_PROC_REF(TYPE, X) (nameof(##TYPE.proc/##X))
/// Call by name proc reference, checks if the proc is existing global proc
#define GLOBAL_PROC_REF(X) (/proc/##X)
#endif
