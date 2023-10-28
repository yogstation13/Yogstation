/**
 * Internal camera component, basically a bodycam component, so it's not tied to an item
 */
/datum/component/internal_cam
	var/obj/machinery/camera/bodcam = null

/datum/component/internal_cam/Initialize(list/networks = list("ss13"))
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	bodcam = new(parent)
	bodcam.c_tag = parent
	bodcam.network = networks
	bodcam.view_range = 10 //standard mob viewrange
	bodcam.internal_light = FALSE

/datum/component/internal_cam/RegisterWithParent()
	. = ..()
	bodcam.status = TRUE
	bodcam.built_in = parent
	GLOB.cameranet.updatePortableCamera(bodcam)
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(update_cam))

/datum/component/internal_cam/UnregisterFromParent()
	bodcam.status = FALSE
	bodcam.built_in = null
	GLOB.cameranet.updatePortableCamera(bodcam)
	qdel(bodcam)
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	. = ..()

/datum/component/internal_cam/Destroy(force, silent)
	bodcam.built_in = null
	bodcam.status = FALSE
	GLOB.cameranet.updatePortableCamera(bodcam)
	QDEL_NULL(bodcam)
	. = ..()

/datum/component/internal_cam/proc/update_cam()
	GLOB.cameranet.updatePortableCamera(bodcam)


