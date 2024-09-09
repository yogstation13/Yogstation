/obj/item/organ/internal/cyberimp/chest/gyro
	name = "Gyrotron-3000"
	desc = "Blood sweat and tears went into this bad boy."
	encode_info = AUGMENT_NO_REQ
	icon_state = "sandy"
	actions_types = list(/datum/action/item_action/organ_action/sandy)
	icon = 'monkestation/code/modules/cybernetics/icons/implants.dmi'

	/// The bodypart overlay datum we should apply to whatever mob we are put into
	visual_implant = TRUE
	bodypart_overlay = /datum/bodypart_overlay/simple/gyro


/datum/bodypart_overlay/simple/gyro
	icon = 'monkestation/code/modules/factory_type_beat/icons/mining_machines.dmi'
	icon_state = "gyrotron-3000"
	layers = EXTERNAL_FRONT
