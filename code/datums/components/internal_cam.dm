/**
 * Internal camera component, basically a bodycam component, so it's not tied to an item
 */
/datum/component/internal_cam
	var/obj/machinery/camera/bodcam = null

/datum/component/internal_cam/Initialize(camera_name = "Internal Camera", list/networks = list("ss13"))
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	bodcam = new(parent)
	bodcam.c_tag = camera_name
	bodcam.network = networks
	bodcam.internal_light = FALSE
	bodcam.status = FALSE

/datum/component/internal_cam/RegisterWithParent()
	. = ..()
	bodcam.built_in = parent
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(update_cam))

/datum/component/internal_cam/UnregisterFromParent()
	bodcam.built_in = null
	bodcam.status = FALSE
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

/datum/component/internal_cam/proc/update_cam(mob/user)
	GLOB.cameranet.updatePortableCamera(bodcam)


