// This file contains defines allowing targeting byond versions newer than the supported

//Update this whenever you need to take advantage of more recent byond features
#define MIN_COMPILER_VERSION 515
#define MIN_COMPILER_BUILD 1630
#if (DM_VERSION < MIN_COMPILER_VERSION || DM_BUILD < MIN_COMPILER_BUILD) && !defined(SPACEMAN_DMM)
//Don't forget to update this part
#error Your version of BYOND is too out-of-date to compile this project. Go to https://secure.byond.com/download and update.
#error You need version 515.1630 or higher
#endif

//If you update these values, update the message in the #error
#define MAX_BYOND_MAJOR 516
#define MAX_BYOND_MINOR 1659
#if ((DM_VERSION > MAX_BYOND_MAJOR) || (DM_BUILD > MAX_BYOND_MINOR)) && !defined(SPACEMAN_DMM)
#error Your version of BYOND is too new to compile this project.
#error Download version 515.1659 at www.byond.com/download/build/515/515.1659_byond.exe
#endif

// 515 split call for external libraries into call_ext
#if DM_VERSION < 515
#define LIBCALL call
#else
#define LIBCALL call_ext
#endif

// So we want to have compile time guarantees these methods exist on local type, unfortunately 515 killed the .proc/procname and .verb/verbname syntax so we have to use nameof()
// For the record: GLOBAL_VERB_REF would be useless as verbs can't be global.

#if DM_VERSION < 515

/// Call by name proc reference, checks if the proc exists on this type or as a global proc
#define PROC_REF(X) (.proc/##X)
/// Call by name verb references, checks if the verb exists on either this type or as a global verb.
#define VERB_REF(X) (.verb/##X)

/// Call by name proc reference, checks if the proc exists on given type or as a global proc
#define TYPE_PROC_REF(TYPE, X) (##TYPE.proc/##X)
/// Call by name verb reference, checks if the verb exists on either the given type or as a global verb
#define TYPE_VERB_REF(TYPE, X) (##TYPE.verb/##X)

/// Call by name proc reference, checks if the proc is existing global proc
#define GLOBAL_PROC_REF(X) (/proc/##X)

#else

/// Call by name proc references, checks if the proc exists on either this type or as a global proc.
#define PROC_REF(X) (nameof(.proc/##X))
/// Call by name verb references, checks if the verb exists on either this type or as a global verb.
#define VERB_REF(X) (nameof(.verb/##X))

/// Call by name proc reference, checks if the proc exists on either the given type or as a global proc
#define TYPE_PROC_REF(TYPE, X) (nameof(##TYPE.proc/##X))
/// Call by name verb reference, checks if the verb exists on either the given type or as a global verb
#define TYPE_VERB_REF(TYPE, X) (nameof(##TYPE.verb/##X))

/// Call by name proc reference, checks if the proc is an existing global proc
#define GLOBAL_PROC_REF(X) (/proc/##X)

#endif
