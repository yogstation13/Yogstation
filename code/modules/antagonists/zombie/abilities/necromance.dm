/obj/effect/proc_holder/zombie/necromance
	name = "Summon a Minion"
	desc = "Summons a zombie to help you."
	action_icon = 'icons/mob/actions/actions_cult.dmi'
	action_icon_state = "equip"
	cooldown_time = 5 MINUTES
	var/list/summoned_minions = list()
	var/max_minions = 5
	var/max_distance = 8
	var/necromancing = FALSE


/obj/effect/proc_holder/zombie/necromance/proc/necromance()
	if(total_minion_count() >= max_minions)
		return FALSE
	if(necromancing)
		return FALSE

	necromancing = TRUE
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to play as a Necromanced Zombie?", ROLE_ZOMBIE, null, ROLE_ZOMBIE, 150)
	necromancing = FALSE //Incase we runtime during the process below


	if(LAZYLEN(candidates))
		var/mob/living/carbon/human/M = new /mob/living/carbon/human(get_turf(usr))
		M.mind_initialize()
		var/mob/dead/observer/C = pick(candidates)
		M.set_species(/datum/species/zombie/infectious/gamemode/necromanced_minion)
		M.key = C.key
		var/datum/species/zombie/infectious/gamemode/necromanced_minion/species = M.dna.species
		species.master = usr
		species.max_distance = max_distance
		summoned_minions += M

		var/datum/game_mode/zombie/GM = SSticker.mode
		if(!istype(GM))
			return
		GM.add_zombie(M.mind)
		usr.visible_message("<span class='danger'>[usr] conjures up a necromanced minion!</span>")
		to_chat(M, "<span class='userdanger'>You are bound to [usr.name]. If you get too far away from them, you will start dying.</span>")
		return TRUE

	return FALSE


/obj/effect/proc_holder/zombie/necromance/proc/total_minion_count()
	var/count = 0
	for(var/MU in summoned_minions)
		var/mob/living/M = MU

		if(M.stat != DEAD)
			count++
	return count

/obj/effect/proc_holder/zombie/necromance/fire(mob/living/carbon/alien/user)
	if(user.incapacitated())
		return FALSE

	necromance()
	return ..()