/obj/item/airlock_scaner
	name = "airlock scaner"
	desc = "A tool used to idetifying accses requiremnts without disassembling airlocks. Make sure airlocks id scan routines were activated at least once before the scan"
	icon = 'icons/obj/objects.dmi'
	icon_state = "paint sprayer"
	item_state = "paint sprayer"

	w_class = WEIGHT_CLASS_SMALL

	materials = list(MAT_METAL=50, MAT_GLASS=50)

	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT

