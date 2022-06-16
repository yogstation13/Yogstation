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

/obj/item/hog_item/book/attack(mob/M, mob/living/carbon/human/user)
	var/datum/antagonist/hog/cultie = IS_HOG_CULTIST(user)
	if(!cultie || cultie.cult != src.cult)
		if(M != user)
			return ..()
	else
		user.visible_message(span_warning("The [src] sudennly hits [user]!"), \
			span_cultlarge("I don't think so."))
		attack(user, user)
		user.dropItemToGround(src, TRUE)
		return




