/// Takes a plane to offset, and the multiplier to use, and well, does the offsetting
/// Respects a blacklist we use to remove redundant plane masters, such as hud objects
#define GET_NEW_PLANE(new_value, multiplier) (SSmapping.plane_offset_blacklist?["[new_value]"] ? new_value : (new_value) - (PLANE_RANGE * (multiplier)))
/// Takes a render target and an offset, returns a canonical render target string for it
#define OFFSET_RENDER_TARGET(render_target, offset) (_OFFSET_RENDER_TARGET(render_target, SSmapping.render_offset_blacklist?["[render_target]"] ? 0 : offset))
/// Helper macro for the above
/// Honestly just exists to make the pattern of render target strings more readable
#define _OFFSET_RENDER_TARGET(render_target, offset) ("[(render_target)] #[(offset)]")
/// Takes a plane, returns TRUE if it is of critical priority, FALSE otherwise
#define PLANE_IS_CRITICAL(plane) ((SSmapping.plane_to_offset) ? !!SSmapping.critical_planes["[plane]"] : FALSE)
/// Implicit plane set. We take the turf from the object we're changing the plane of, and use ITS z as a spokesperson for our plane value
#define SET_PLANE_IMPLICIT(thing, new_value) SET_PLANE_EXPLICIT(thing, new_value, thing)
/// Takes a plane, returns the canonical, unoffset plane it represents
#define PLANE_TO_TRUE(plane) ((SSmapping.plane_offset_to_true) ? SSmapping.plane_offset_to_true["[plane]"] : plane)
/// Takes a plane, returns the offset it uses
#define PLANE_TO_OFFSET(plane) ((SSmapping.plane_to_offset) ? SSmapping.plane_to_offset["[plane]"] : plane)
/// Takes a z reference that we are unsure of, sanity checks it
/// Returns either its offset, or 0 if it's not a valid ref
/// Will return the reference's PLANE'S offset if we can't get anything out of the z level. We do our best
#define GET_TURF_PLANE_OFFSET(z_reference) ((SSmapping.max_plane_offset && isatom(z_reference)) ? (z_reference.z ? GET_Z_PLANE_OFFSET(z_reference.z) : PLANE_TO_OFFSET(z_reference.plane)) : 0)
/// Essentially just an unsafe version of GET_TURF_PLANE_OFFSET()
/// Takes a z value we returns its offset with a list lookup
/// Will runtime during parts of init. Be careful :)
#define GET_Z_PLANE_OFFSET(z) (SSmapping.z_level_to_plane_offset[z])
/// Takes a true plane, returns the offset planes that would canonically represent it
#define TRUE_PLANE_TO_OFFSETS(plane) ((SSmapping.true_to_offset_planes) ? SSmapping.true_to_offset_planes["[plane]"] : list(plane))
// This is an unrolled and optimized version of SET_PLANE, for use anywhere where you are unsure of a source's "turfness"
// We do also try and guess at what the thing's z level is, even if it's not a z
// The plane is cached to allow for fancy stuff to be eval'd once, rather then often
#define SET_PLANE_EXPLICIT(thing, new_value, source) \
	do {\
		if(SSmapping.max_plane_offset) {\
			var/_cached_plane = new_value;\
			var/turf/_our_turf = get_turf(source);\
			if(_our_turf){\
				thing.plane = GET_NEW_PLANE(_cached_plane, GET_Z_PLANE_OFFSET(_our_turf.z));\
			}\
			else if(source) {\
				thing.plane = GET_NEW_PLANE(_cached_plane, PLANE_TO_OFFSET(source.plane));\
			}\
			else {\
				thing.plane = _cached_plane;\
			}\
		}\
		else {\
			thing.plane = new_value;\
		}\
	}\
	while (FALSE)
