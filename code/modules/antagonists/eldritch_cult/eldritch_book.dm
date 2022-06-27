/obj/item/forbidden_book
	name = "Codex Cicatrix"
	desc = "A book with a peculular lock on it, there's no keyhole."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "book"
	//worn_icon_state = "book"
	w_class = WEIGHT_CLASS_SMALL
	///Last person that touched this
	var/mob/living/last_user
	///Where we cannot create the rune?
	var/static/list/blacklisted_turfs = typecacheof(list(/turf/closed,/turf/open/space,/turf/open/lava))

/obj/item/forbidden_book/Destroy()
	last_user = null
	. = ..()


/obj/item/forbidden_book/examine(mob/user)
	. = ..()
	if(!IS_HERETIC(user))
		return
	. += "Use it on the floor to create a transmutation rune, used to perform rituals."
	. += "Hit an influence in the black part with it to gain a charge."
	. += "Hit a transmutation rune to destroy it."
	. += "Alt+click this book to check the list of currently available transmutations and their ingredients."

/obj/item/forbidden_book/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !IS_HERETIC(user))
		return
	if(istype(target,/obj/effect/eldritch))
		remove_rune(target,user)
	if(istype(target,/obj/effect/reality_smash))
		if(!INTERACTING_WITH(user, target))
			get_power_from_influence(target,user)
	if(istype(target,/turf/open))
		draw_rune(target,user)

/obj/item/forbidden_book/AltClick(mob/living/user)
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

///Gives you a charge and destroys a corresponding influence
/obj/item/forbidden_book/proc/get_power_from_influence(atom/target, mob/user)
	var/obj/effect/reality_smash/RS = target
	if(INTERACTING_WITH(user, RS))
		return
	if(user.mind in RS.siphoners)
		to_chat(user, span_danger("You have already studied this influence!"))
		return
	to_chat(user, span_danger("You start to study [RS]..."))
	if(do_after(user, 10 SECONDS, RS))
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

	if(do_after(user, 30 SECONDS, A))

		new /obj/effect/eldritch/big(A)

///Removes runes from the selected turf
/obj/item/forbidden_book/proc/remove_rune(atom/target,mob/user)
	to_chat(user, span_danger("You start removing a rune..."))
	if(do_after(user, 2 SECONDS, target))
		qdel(target)

/obj/item/forbidden_book/ui_interact(mob/user, datum/tgui/ui = null)
	if(!IS_HERETIC(user))
		return FALSE
	last_user = user
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		icon_state = "book_open"
		flick("book_opening", src)
		ui = new(user, src, "ForbiddenLore", name)
		ui.open()

/obj/item/forbidden_book/ui_data(mob/user)
	var/datum/antagonist/heretic/cultie = user.mind.has_antag_datum(/datum/antagonist/heretic)
	var/list/to_know = list()
	for(var/Y in cultie.get_researchable_knowledge())
		to_know += new Y
	var/list/known = cultie.get_all_knowledge()
	var/list/data = list()
	var/list/lore = list()

	data["charges"] = cultie.charge

	for(var/X in to_know)
		lore = list()
		var/datum/eldritch_knowledge/EK = X
		lore["type"] = EK.type
		lore["name"] = EK.name
		lore["cost"] = EK.cost
		lore["progression"] = EK.tier == cultie.knowledge_tier
		lore["disabled"] = EK.cost <= cultie.charge ? FALSE : TRUE
		lore["path"] = EK.route
		lore["state"] = "Research"
		lore["flavour"] = EK.gain_text
		lore["desc"] = EK.desc
		data["to_know"] += list(lore)

	for(var/X in known)
		lore = list()
		var/datum/eldritch_knowledge/EK = known[X]
		lore["name"] = EK.name
		lore["cost"] = EK.cost
		lore["disabled"] = TRUE
		lore["path"] = EK.route
		lore["state"] = "Researched"
		lore["flavour"] = EK.gain_text
		lore["desc"] = EK.desc
		data["to_know"] += list(lore)

	if(!length(data["to_know"]))
		data["to_know"] = null

	return data

/obj/item/forbidden_book/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("research")
			var/datum/antagonist/heretic/cultie = last_user.mind.has_antag_datum(/datum/antagonist/heretic)
			var/ekname = params["name"]
			for(var/X in cultie.get_researchable_knowledge())
				var/datum/eldritch_knowledge/EK = X
				if(initial(EK.name) != ekname)
					continue
				if(cultie.gain_knowledge(EK))
					return TRUE

	update_icon() // Not applicable to all objects.

/obj/item/forbidden_book/ui_close(mob/user)
	flick("book_closing",src)
	icon_state = initial(icon_state)
	return ..()
