/**
 * Internal camera component, basically a bodycam component, so it's not tied to an item
 */
/datum/component/internal_cam
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
	bodcam.camnet.updatePortableCamera(bodcam)
	bodcam.built_in = parent
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(update_cam))

/datum/component/internal_cam/UnregisterFromParent()
	bodcam.status = FALSE
	bodcam.camnet.updatePortableCamera(bodcam)
	bodcam.built_in = null
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	QDEL_NULL(bodcam)

/datum/component/internal_cam/proc/change_cameranet(var/datum/cameranet/newnet)
	if(!newnet)
		return
	bodcam.change_camnet(newnet)

/datum/component/internal_cam/Destroy(force, silent)
	bodcam.built_in = null
	bodcam.status = FALSE
	bodcam.camnet.updatePortableCamera(bodcam)
	QDEL_NULL(bodcam)
	. = ..()

/datum/component/internal_cam/proc/update_cam()
	bodcam.camnet.updatePortableCamera(bodcam)


