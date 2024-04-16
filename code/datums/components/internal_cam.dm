///The static update delay on movement of the camera in a mob we use
#define INTERNAL_CAMERA_BUFFER (0.5 SECONDS)

/**
 * Internal camera component, basically a bodycam component, so it's not tied to an item
 */
/datum/component/internal_cam
	///The camera object used to gather information for the camera net
	var/obj/machinery/camera/bodcam

/datum/component/internal_cam/Initialize(list/networks = list("ss13"))
	if (!parent || !isliving(parent))
		return COMPONENT_INCOMPATIBLE

	bodcam = new(parent)
	bodcam.c_tag = parent
	bodcam.name = parent
	bodcam.network = networks
	bodcam.setViewRange(10)//standard mob viewrange
	bodcam.internal_light = FALSE
	ADD_TRAIT(bodcam, TRAIT_EMPPROOF_SELF, type)

/datum/component/internal_cam/RegisterWithParent()
	bodcam.status = TRUE
	update_cam()
	bodcam.built_in = parent
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(update_cam))

/datum/component/internal_cam/UnregisterFromParent()
	bodcam.status = FALSE
	update_cam()
	bodcam.built_in = null
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)

/datum/component/internal_cam/Destroy(force, silent)
	. = ..()
	QDEL_NULL(bodcam)

///Changes the camera net used by the interal camera, currently only used for the darkspawn cameranet
/datum/component/internal_cam/proc/change_cameranet(var/datum/cameranet/newnet)
	if(!newnet)
		return
	bodcam.change_camnet(newnet)

///Updates the camera net, telling it that the camera has moved
/datum/component/internal_cam/proc/update_cam()
	bodcam.camnet.updatePortableCamera(bodcam, INTERNAL_CAMERA_BUFFER)


