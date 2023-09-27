/obj/item/forbidden_book
	name = "Codex Cicatrix"
	desc = "A book with a peculiar lock on it, there's no keyhole."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "book"
	worn_icon_state = "book"
	w_class = WEIGHT_CLASS_SMALL
	///Last person that touched this
	var/mob/living/last_user
	///Where we cannot create the rune?
	var/static/list/blacklisted_turfs = typecacheof(list(/turf/closed,/turf/open/space,/turf/open/lava))
	var/obj/effect/eldritch/big/last_rune

/obj/item/forbidden_book/Destroy()
	last_user = null
	last_rune = null
	. = ..()


/obj/item/forbidden_book/examine(mob/user)
	. = ..()
	if(!IS_HERETIC(user))
		return
	. += "Use it on the floor to create a transmutation rune, used to perform rituals."
	. += "Hit an influence in the black part with it to gain a charge."
	. += "Hit a transmutation rune to destroy it."
	. += "Use this book in hand with Z to check the list of currently available transmutations and their ingredients."

/obj/item/forbidden_book/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !IS_HERETIC(user))
		return
	if(istype(target,/obj/effect/eldritch))
		remove_rune(target,user)
	if(istype(target,/obj/effect/reality_smash))
		if(!DOING_INTERACTION(user, target))
			get_power_from_influence(target,user)
	if(istype(target,/turf/open))
		draw_rune(target,user)

/obj/item/forbidden_book/interact(mob/user)
	. = ..()
	if(!IS_HERETIC(user))
		to_chat(user,span_userdanger("The book starts gnawing at your fingers!"))
		return
	icon_state = "book_open"
	flick("book_opening",src)
	var/list/datum/eldritch_knowledge/recall_list = list()
	var/datum/antagonist/heretic/cultie = user.mind.has_antag_datum(/datum/antagonist/heretic)
	var/list/transmutations = cultie.get_all_transmutations()
	for(var/X in transmutations)
		var/datum/eldritch_transmutation/ET = X
		if(!ET.required_shit_list)
			continue
		recall_list[ET.name] = ET.required_shit_list
	var/ctrlf = input(user, "Select a ritual to recall its reagents.", "Recall Knowledge") as null | anything in recall_list
	if(ctrlf)
		to_chat(user, span_cult("Transmutation requirements for [ctrlf]: [recall_list[ctrlf]]"))
	flick("book_closing",src)
	icon_state = initial(icon_state)
///Gives you a charge and destroys a corresponding influence
/obj/item/forbidden_book/proc/get_power_from_influence(atom/target, mob/user)
	var/obj/effect/reality_smash/RS = target
	if(DOING_INTERACTION(user, RS))
		return
	if(user.mind in RS.siphoners)
		to_chat(user, span_danger("You have already studied this influence!"))
		return
	to_chat(user, span_danger("You start to study [RS]..."))
	if(do_after(user, 4 SECONDS, RS))
		var/datum/antagonist/heretic/H = user.mind?.has_antag_datum(/datum/antagonist/heretic)
		H?.charge += 1
		to_chat(user, span_notice("You finish your study of [RS]!"))
		RS.siphoners |= user.mind

///Draws a rune on a selected turf
/obj/item/forbidden_book/proc/draw_rune(atom/target,mob/user)

	for(var/turf/T in range(1,target))
		if(is_type_in_typecache(T, blacklisted_turfs))
			to_chat(user, span_warning("The terrain doesn't support runes!"))
			return
	var/A = get_turf(target)
	to_chat(user, span_danger("You start drawing a rune..."))

	if(do_after(user, 8 SECONDS, A))
		if(!QDELETED(last_rune))
			qdel(last_rune)
		last_rune = new /obj/effect/eldritch/big(A)

///Removes runes from the selected turf
/obj/item/forbidden_book/proc/remove_rune(atom/target,mob/user)
	to_chat(user, span_danger("You start removing a rune..."))
	if(do_after(user, 2 SECONDS, target))
		qdel(target)



