/datum/antagonist/hog
	name = "HoG servant"   ///Because i plan to make guys have different datums, so... you know
	roundend_category = "HoG Cultists"
	antagpanel_category = "HoG Cult"
	var/hud_type = "dude"
	var/datum/team/hog_cult/cult
	var/list/god_actions = list(/datum/hog_god_interaction/targeted/recall, /datum/hog_god_interaction/targeted/purge, /datum/hog_god_interaction/targeted/mood, /datum/hog_god_interaction/targeted/mood) 
	var/list/magic = list()
	var/energy = 0
	var/max_energy = 100
	var/list/prepared_spells = list()
	var/banned_by_god = FALSE
	var/is_god = FALSE
	var/datum/action/innate/pray/pray
	antag_moodlet = /datum/mood_event/hog_cultist

/datum/antagonist/hog/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(.)
		if(new_owner.unconvertable)
			return FALSE

/datum/antagonist/hog/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_hog_icons_added(M)
	pray = new
	pray.Grant(owner.current)
	if((cult.state == HOG_TEAM_SUMMONING || cult.state == HOG_TEAM_SUMMONED) && ishuman(owner.current))
		owner.current.add_overlay(mutable_appearance('icons/effects/genetics.dmi', "servitude", -MUTATIONS_LAYER))
	RegisterSignal(owner.current, COMSIG_ATOM_EMP_ACT, .proc/fuck_magic)
	update_hud()

/datum/antagonist/hog/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_hog_icons_removed(M)
	M.cut_overlays()
	M.regenerate_icons()
	UnregisterSignal(owner.current, COMSIG_ATOM_EMP_ACT)
	remove_hud()

/datum/antagonist/hog/get_team()
	return cult

/datum/antagonist/hog/greet()
	to_chat(owner, span_cultlarge("You are a HoG cultist!"))

/datum/antagonist/hog/farewell()
	if(ishuman(owner.current))
		owner.current.visible_message("[span_deconversion_message("[owner.current] looks like [owner.current.p_theyve()] just returned a part of themselfes!")]", null, null, null, owner.current)
		to_chat(owner, span_userdanger("You are no longer a HoG cultist!"))

/datum/antagonist/hog/on_gain()
	if(!cult)
		create_team()
	..()
	add_to_cult()

/datum/antagonist/hog/on_removal()
	remove_from_cult()
	qdel(pray)
	for(var/A in prepared_spells)
		qdel(A)
	SEND_SIGNAL(owner.current, COMSIG_CLEAR_MOOD_EVENT, "god_moraleboost") 
	SEND_SIGNAL(owner.current, COMSIG_CLEAR_MOOD_EVENT, "pleased_gods") 
	..()

/datum/antagonist/hog/proc/update_hog_icons_added(mob/living/M)  ///Hope this shit will work, despite i brainlessly copied it from gang code
	var/datum/atom_hud/antag/hog/culthud = GLOB.huds[cult.hud_entry_num]
	if(!culthud)
		culthud = new/datum/atom_hud/antag/hog()
		cult.hud_entry_num = GLOB.huds.len+1 
		GLOB.huds += culthud
	culthud.color = cult.cult_color
	culthud.join_hud(M)
	set_antag_hud(M,hud_type)

/datum/antagonist/hog/proc/update_hog_icons_removed(mob/living/M)
	var/datum/atom_hud/antag/hog/culthud = GLOB.huds[cult.hud_entry_num]
	if(cult)
		culthud.leave_hud(M)
		set_antag_hud(M, null)

/datum/antagonist/hog/create_team(team)
	if(!cult) 
		if(team)
			cult = team
			return
		var/datum/team/hog_cult/cultteam = pick_n_take(GLOB.possible_hog_cults)
		if(cultteam)
			cult = new cultteam

/datum/antagonist/hog/proc/add_to_cult()
	cult.add_member(owner)
	owner.current.log_message("<font color='red'>Has been converted to the [cult.name] cult!</font>", INDIVIDUAL_ATTACK_LOG)

/datum/antagonist/hog/proc/remove_from_cult()
	owner.current.log_message("<font color='red'>Has been deconverted from the [cult.name] cult!</font>", INDIVIDUAL_ATTACK_LOG)

/datum/antagonist/hog/proc/equip_cultist(roundstart = TRUE)
	var/mob/living/carbon/culte = owner.current
	if(roundstart)
		var/list/slots = list(
			"backpack" = SLOT_IN_BACKPACK,
			"left pocket" = SLOT_L_STORE,
			"right pocket" = SLOT_R_STORE
		)
		var/obj/item/hog_item/T = new /obj/item/hog_item/book(culte)
		if(cult)
			T.handle_owner_change(cult)
		else
			log_game("[key_name(owner.current)] has been equiped without a cult.")
		var/item_name = initial(T.name)
		var/where = culte.equip_in_one_of_slots(T, slots)
		if(!where)
			to_chat(culte, span_userdanger("Unfortunately, you weren't able to get a [item_name]. This is very bad and you should adminhelp immediately."))
			return 0
		else
			to_chat(culte, span_danger("You have a [item_name] in your [where]."))
			if(where == "backpack")
				SEND_SIGNAL(culte.back, COMSIG_TRY_STORAGE_SHOW, culte)
			return TRUE
	else
		var/obj/item/hog_item/T = new /obj/item/hog_item/book(get_turf(culte))
		if(cult)
			T.handle_owner_change(cult)
		else
			log_game("[key_name(owner.current)] has been equiped without a cult.")
		
/datum/antagonist/hog/proc/get_energy(var/amount)
	energy += amount
	if(energy < 0)
		energy = 0
	if(energy > max_energy)
		energy= max_energy

/datum/antagonist/hog/proc/fuck_magic(severity)
	get_energy(-HOG_EMP_DAMAGE_MULTIPLER/severity)
	to_chat(owner.current, span_cultlarge("You feel your cult energy leaving you!"))
