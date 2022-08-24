/obj/effect/proc_holder/spell/disguise
	name = "Mimicry"
	desc = "Why fight your foes when you can simply outwit them? Disguises the caster as a random crewmember."
	invocation = "CONJR DIS GUISE"
	invocation_type = "whisper"
	school = "transmutation"
	charge_max = 30 SECONDS
	level_max = 2
	cooldown_min = 25 SECONDS
	clothes_req = FALSE
	var/is_disguised = FALSE
	action_icon = 'icons/mob/actions/actions_spells.dmi'
	action_icon_state = "disguise"

/obj/effect/proc_holder/spell/disguise/can_cast(mob/user = usr)
	if(!iscarbon(user))
		to_chat(user, span_danger("You cannot disguise as a non-humanoid!"))
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/disguise/choose_targets(mob/user = usr)
	perform(user=user)

/obj/effect/proc_holder/spell/disguise/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/C = user //Turns the user into a carbon, we'll need this later.
	var/list/potentials = list()
	for(var/mob/living/carbon/human/H in GLOB.carbon_list) //Checks all the humanoid mobs.
		if(H.job) //Checks if they're crew.
			potentials += H //Adds the crewmember to the list.
	if(potentials.len == 0)
		to_chat(C, span_notice("There's nobody to disguise as!"))
		revert_cast(user)
		return
	var/mob/living/carbon/human/man = pick(potentials) //Picks a random subject from the viable targets.
	cloak(C, man)
	start_cooldown()



/obj/effect/proc_holder/spell/disguise/proc/cloak(var/mob/living/carbon/human/C, var/mob/living/carbon/human/man) //Code shortcut to enable the disguise.
	if(is_disguised)
		message_admins("[ADMIN_LOOKUPFLW(C)] just tried to disguise while disguised! That shouldn't happen!") 
		return
	C.name_override = man.name
	C.SetSpecialVoice(man.name)
	new /obj/effect/temp_visual/dir_setting/ninja/cloak(get_turf(C), C.dir) //Cloaking disguise.
	C.icon = man.icon
	C.icon_state = man.icon_state
	C.cut_overlays()
	C.add_overlay(man.get_overlays_copy(list(HANDS_LAYER)))
	C.update_inv_hands()
	log_game("[C.name] has disguised as [man.name]!") 
	is_disguised = TRUE
	addtimer(CALLBACK(src, .proc/undoCloak, C), (15 SECONDS + (spell_level * 3 SECONDS)))
	return

/obj/effect/proc_holder/spell/disguise/proc/undoCloak(var/mob/living/carbon/human/C) //Code shortcut to disable the disguise.
	if(!is_disguised)
		message_admins("[ADMIN_LOOKUPFLW(C)] just tried to undo their disguise while not disguised! That shouldn't happen!") 
		return
	new /obj/effect/temp_visual/dir_setting/ninja(get_turf(C), C.dir) //Makes an animation for disguising.
	C.name_override = null
	C.UnsetSpecialVoice()
	C.cut_overlays()
	C.regenerate_icons()
	log_game("[C.name] has shed their disguise!") 
	is_disguised = FALSE
	return

/datum/spellbook_entry/disguise //Spellbook entry, needed for the spell to be purchasable in game.
	name = "Mimicry"
	spell_type = /obj/effect/proc_holder/spell/disguise
	category = "Assistance"
	cost = 1




