/obj/item/cane/crutch
	name = "medical crutch"
	desc = "A medical crutch used by people missing a leg. Not all that useful if you're missing both of them, though."
	icon = 'monkestation/code/modules/blood_datum/icons/staff.dmi'
	icon_state = "crutch_med"
	inhand_icon_state = "crutch_med"
	lefthand_file = 'monkestation/code/modules/blood_datum/icons/melee_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/blood_datum/icons/melee_righthand.dmi'
	force = 12
	throwforce = 8
	w_class = WEIGHT_CLASS_BULKY
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 0.5)
	attack_verb_continuous = list("bludgeons", "whacks", "thrashes")
	attack_verb_simple = list("bludgeon", "whack", "thrash")

/obj/item/cane/crutch/wood
	name = "wooden crutch"
	desc = "A handmade crutch. Also makes a decent bludgeon if you need it."
	icon_state = "crutch_wood"
	inhand_icon_state = "crutch_wood"
	custom_materials = list(/datum/material/wood = SMALL_MATERIAL_AMOUNT * 0.5)
