/obj/effect/proc_holder/hog/book_charge
	name = "Empower"
	desc = "Empowers your book with your deity's power, allowing to stun people with it."
	panel = "HoG Spells"
	has_action = TRUE
	action_icon = 'icons/mob/actions/actions_xeno.dmi'
	action_icon_state = "spell_default"
	action_background_icon_state = "bg_alien"
	energy_cost = 20
	preparation_time = 3 SECONDS
	availible = TRUE
	var/charging_amount = 3
	var/item/hog_item/book/tome = null
	
/obj/effect/proc_holder/hog/prepare(obj/item/hog_item/book/book, mob/living/user, datum/antagonist/hog/hog)
	. = ..()
	book.charges += charging_amount /// A bit stupid way to do this, but just cry about it
	if(book.charges > 4)
		book.charges = 4
	hog.prepared_spells -= src
	qdel(src)
