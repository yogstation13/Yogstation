#define TIER_2_TIME 4500

GLOBAL_LIST_EMPTY(zombies)

/datum/antagonist/zombie
	name = "Zombie"
	roundend_category = "zombies"
	antagpanel_category = "Zombie"

	job_rank = ROLE_ZOMBIE

	var/datum/team/zombie/team
	antag_hud_name = "zombie"

	var/class_chosen = FALSE
	var/class_chosen_2 = FALSE

	var/spit_cooldown = 0

	var/zombified = FALSE

	var/evolution_ready = FALSE


/datum/antagonist/zombie/create_team(datum/team/zombie/new_team)
	if(!new_team)
		for(var/HU in GLOB.zombies)
			var/datum/antagonist/zombie/H = HU
			if(!H.owner)
				continue
			if(H.team)
				team = H.team
				return
		team = new /datum/team/zombie
		team.setup_objectives()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	team = new_team

/datum/antagonist/zombie/greet()
	to_chat(owner.current, "<B><font size=3 color=red>You have been infected with a zombie virus! In 15 minutes you will be able to turn into a zombie...</font><B>")
	to_chat(owner.current, "<b>Use the button at the top of the screen (When it appears) to activate the infection. It will kill you, but you will rise as a zombie shortly after!<b>") //Yogs
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ling_aler.ogg', 100, FALSE, pressure_affected = FALSE)//subject to change
	owner.announce_objectives()

/datum/antagonist/zombie/on_gain()
	. = ..()
	var/mob/living/current = owner.current
	GLOB.zombies += owner
	current.log_message("has been made a zombie!", LOG_ATTACK, color="#960000")


/datum/antagonist/zombie/apply_innate_effects()
	. = ..()
	var/mob/living/current = owner.current
	current.faction |= "zombies"

/datum/antagonist/zombie/remove_innate_effects()
	. = ..()
	var/mob/living/current = owner.current
	current.faction -= "zombies"

/datum/antagonist/zombie/on_removal()
	GLOB.zombies -= owner
	. = ..()

/datum/antagonist/zombie/admin_add(datum/mind/new_owner,mob/admin)
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has zombied'ed [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has zombied'ed [key_name(new_owner)].")

/datum/antagonist/zombie/proc/start_evolution_2()
	addtimer(CALLBACK(src, PROC_REF(finish_evolution_2)), TIER_2_TIME)

/datum/antagonist/zombie/proc/finish_evolution_2()
	evolution_ready = TRUE
	to_chat(owner.current, span_userdanger("<b>You can now evolve into a Tier 2 zombie! There can only be tier 2 zombies equal to the amount of starting zombies!<b>"))

/datum/team/zombie
	name = "Zombies"

/datum/team/zombie/proc/setup_objectives()

	var/datum/objective/custom/obj = new()
	obj.name = "Escape on the shuttle, while gathering as many infected as possible!"
	obj.explanation_text = "Escape on the shuttle, while gathering as many infected as possible!"
	obj.completed = TRUE
	objectives += obj


/datum/team/zombie/proc/zombies_on_shuttle()
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		if(IS_INFECTED(H) && (H.onCentCom() || H.onSyndieBase()))
			return TRUE
	return FALSE

/datum/team/zombie/roundend_report()
	var/list/parts = list()
	if(zombies_on_shuttle())
		parts += "<span class='greentext big'>BRAINS! The zombies have made it to CentCom!</span>"
	else
		parts += "<span class='redtext big'>Target destroyed. The crew has stopped the zombies!</span>"


	if(members.len)
		parts += span_header("The zombies were:")
		parts += printplayerlist(members)

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

#undef TIER_2_TIME

/datum/antagonist/zombie/get_preview_icon()
	var/mob/living/carbon/human/dummy/consistent/zombiedummy = new

	zombiedummy.set_species(/datum/species/zombie)

	var/icon/zombie_icon = render_preview_outfit(null, zombiedummy)

	qdel(zombiedummy)

	return finish_preview_icon(zombie_icon)
