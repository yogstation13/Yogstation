/obj/item/hog_item
	name = "hoggers"
	desc = "You shouldn't seen this.."
	resistance_flags = FIRE_PROOF | ACID_PROOF
	icon_state = "ass"
	var/datum/team/hog_cult/cult 
	var/original_icon = "ass"

/obj/item/hog_item/proc/update_icons()
	icon_state = "[original_icon]_[cult.cult_color]"
	
/obj/item/hog_item/proc/handle_owner_change(var/datum/team/hog_cult/new_cult)
	cult = new_cult
	update_icons()



