// These defines are unlikely to ever change and making them global would require changing the original file a bunch.
// So while not perfect, simply copying the defines over should work fine here.

#define PRIORITY_ABSOLUTE 1
#define PRIORITY_HIGH 10
#define PRIORITY_NORMAL 100
#define PRIORITY_LOW 1000

/// Mayhem in a bottle also uses the bloodlust client colour, but this is the *persistent* client colour.
/datum/client_colour/mayhem
	priority = PRIORITY_HIGH
	colour = "#ff9e9e"

	fade_in = 0.5 SECONDS
	fade_out = 0.5 SECONDS

#undef PRIORITY_ABSOLUTE
#undef PRIORITY_HIGH
#undef PRIORITY_NORMAL
#undef PRIORITY_LOW
