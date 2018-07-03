/*
	These defines are specific to the atom/flags_1 bitmask
*/


/*
	These defines are used specifically with the atom/pass_flags bitmask
	the atom/checkpass() proc uses them (tables will call movable atom checkpass(PASSTABLE) for example)
*/
//flags for pass_flags
//If the /tg/ pass_flags end up reaching 1<<13, please change the value below.
//DM is supposed to support 24 bits of bitshifting as of Jun 7 '18, and probably will by the time you have to do this.
#define PASSDOOR    (1<<13) //As of 19 Jun '18, only used for drones
