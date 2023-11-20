// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /turf signals
#define COMSIG_TURF_CHANGE "turf_change"						//! from base of turf/ChangeTurf(): (path, list/new_baseturfs, flags, list/transferring_comps)
#define COMSIG_TURF_HAS_GRAVITY "turf_has_gravity"				//! from base of atom/has_gravity(): (atom/asker, list/forced_gravities)
#define COMSIG_TURF_MULTIZ_NEW "turf_multiz_new"				//! from base of turf/New(): (turf/source, direction)
#define COMSIG_TURF_AFTER_SHUTTLE_MOVE "turf_after_shuttle_move"	//! from base of turf/proc/afterShuttleMove: (turf/new_turf)
///from base of /datum/turf_reservation/proc/Release: (datum/turf_reservation/reservation)
#define COMSIG_TURF_RESERVATION_RELEASED "turf_reservation_released"

///from /datum/element/footstep/prepare_step(): (list/steps)
#define COMSIG_TURF_PREPARE_STEP_SOUND "turf_prepare_step_sound"
///from base of datum/thrownthing/finalize(): (turf/turf, atom/movable/thrownthing) when something is thrown and lands on us
#define COMSIG_TURF_MOVABLE_THROW_LANDED "turf_movable_throw_landed"
