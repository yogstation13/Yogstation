#define ALL_POWERS_UNLOCKED 800
#define BLOOD_SUCK_BASE 25

/datum/antagonist/vampire

	name = "Vampire"
	antagpanel_category = "Vampire"
	roundend_category = "vampires"
	job_rank = ROLE_VAMPIRE

	var/usable_blood = 0
	var/total_blood = 0
	var/converted = 0
	var/fullpower = FALSE
	var/full_vampire = TRUE
	var/draining
	var/list/objectives_given = list()

	var/iscloaking = FALSE

	var/list/powers = list() // list of current powers

	var/obj/item/clothing/suit/draculacoat/coat

	var/list/upgrade_tiers = list(
		/obj/effect/proc_holder/spell/self/vampire_help = 0,
		/obj/effect/proc_holder/spell/self/rejuvenate = 0,
		/obj/effect/proc_holder/spell/pointed/gaze = 0,
		/obj/effect/proc_holder/spell/pointed/hypno = 0,
		/datum/vampire_passive/vision = 75,
		/obj/effect/proc_holder/spell/self/shapeshift = 75,
		/obj/effect/proc_holder/spell/self/cloak = 100,
		/obj/effect/proc_holder/spell/self/revive = 100,
		/obj/effect/proc_holder/spell/targeted/disease = 200,//why is spell-that-kills-people unlocked so early what the fuck
		/obj/effect/proc_holder/spell/self/batform = 200,
		/obj/effect/proc_holder/spell/self/screech = 215,
		/obj/effect/proc_holder/spell/bats = 250,
		/datum/vampire_passive/regen = 255,
		/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/mistform = 300,
		/datum/vampire_passive/full = 420,
		/obj/effect/proc_holder/spell/self/summon_coat = 420,
		/obj/effect/proc_holder/spell/targeted/vampirize = 450)

/datum/antagonist/vampire/new_blood
	full_vampire = FALSE
	roundend_category = "new bloods"
	show_in_antagpanel = FALSE

/datum/antagonist/vampire/get_admin_commands()
	. = ..()
	.["Full Power"] = CALLBACK(src,.proc/admin_set_full_power)
	.["Set Blood Amount"] = CALLBACK(src,.proc/admin_set_blood)

/datum/antagonist/vampire/proc/admin_set_full_power(mob/admin)
	usable_blood = ALL_POWERS_UNLOCKED
	total_blood = ALL_POWERS_UNLOCKED
	check_vampire_upgrade()
	message_admins("[key_name_admin(admin)] made [owner.current] a full power vampire..")
	log_admin("[key_name(admin)] made [owner.current] a full power vampire..")

/datum/antagonist/vampire/proc/admin_set_blood(mob/admin)
	total_blood = input(admin, "Set Vampire Total Blood", "Total Blood", total_blood) as null|num
	usable_blood = min((input(admin, "Set Vampire Usable Blood", "Usable Blood", usable_blood) as null|num), total_blood)
	check_vampire_upgrade()
	message_admins("[key_name_admin(admin)] set [owner.current]'s total blood to [total_blood], and usable blood to [usable_blood].")
	log_admin("[key_name(admin)] set [owner.current]'s total blood to [total_blood], and usable blood to [usable_blood].")

/datum/antagonist/vampire/on_gain()
	SSticker.mode.vampires += owner
	give_objectives()
	check_vampire_upgrade()
	owner.special_role = "vampire"
	owner.current.faction += "vampire"
	SSticker.mode.update_vampire_icons_added(owner)
	var/mob/living/carbon/human/C = owner.current
	if(istype(C))
		var/obj/item/organ/brain/B = C.getorganslot(ORGAN_SLOT_BRAIN)
		if(B)
			B.organ_flags &= ~ORGAN_VITAL
			B.decoy_override = TRUE
	..()

/datum/antagonist/vampire/on_removal()
	remove_vampire_powers()
	owner.current.faction -= "vampire"
	SSticker.mode.vampires -= owner
	owner.special_role = null
	if(ishuman(owner.current))
		var/mob/living/carbon/human/H = owner.current
		if(owner && H.hud_used && H.hud_used.vamp_blood_display)
			H.hud_used.vamp_blood_display.invisibility = INVISIBILITY_ABSTRACT
	SSticker.mode.update_vampire_icons_removed(owner)
	for(var/O in objectives_given)
		objectives -= O
	LAZYCLEARLIST(objectives_given)
	if(owner.current)
		to_chat(owner.current,"<span class='userdanger'>Your powers have been quenched! You are no longer a vampire</span>")
	owner.special_role = null
	var/mob/living/carbon/human/C = owner.current
	if(istype(C))
		var/obj/item/organ/brain/B = C.getorganslot(ORGAN_SLOT_BRAIN)
		if(B && (B.decoy_override != initial(B.decoy_override)))
			B.organ_flags |= ORGAN_VITAL
			B.decoy_override = FALSE
	..()

/datum/antagonist/vampire/greet()
	to_chat(owner, "<span class='userdanger'>You are a Vampire!</span>")
	to_chat(owner, "<span class='danger bold'>You are a creature of the night -- holy water, the chapel, and space will cause you to burn.</span>")
	to_chat(owner, "<span class='userdanger'>Hit someone in the head with harm intent to start sucking their blood. However, only blood from living, non-vampiric creatures is usable!</span>")
	to_chat(owner, "<span class='notice bold'>Coffins will heal you.</span>")
	if(full_vampire == FALSE)
		to_chat(owner, "<span class='notice bold'>You are not required to obey other vampires, however, you have gained a respect for them.</span>")
	if(LAZYLEN(objectives_given))
		owner.announce_objectives()
	owner.current.playsound_local(get_turf(owner.current), 'yogstation/sound/ambience/antag/vampire.ogg',80,0)

/datum/antagonist/vampire/proc/give_objectives()
	if(full_vampire)
		for(var/i = 1, i < CONFIG_GET(number/traitor_objectives_amount), i++)
			forge_single_objective()
		if(prob(50))
			var/datum/objective/convert/convert_objective = new
			convert_objective.owner = owner
			convert_objective.gen_amount_goal()
			add_objective(convert_objective)
		else
			var/datum/objective/blood/blood_objective = new
			blood_objective.owner = owner
			blood_objective.gen_amount_goal()
			add_objective(blood_objective)
	else
		var/datum/objective/blood/blood_objective = new
		blood_objective.owner = owner
		blood_objective.gen_amount_goal()
		add_objective(blood_objective)

	if(!(locate(/datum/objective/escape) in objectives))
		var/datum/objective/escape/escape_objective = new
		escape_objective.owner = owner
		add_objective(escape_objective)
		return

/datum/antagonist/vampire/proc/add_objective(var/datum/objective/O)
	objectives += O
	objectives_given += O

/datum/antagonist/vampire/proc/forge_single_objective() //Returns how many objectives are added
	.=1
	if(prob(50))
		var/list/active_ais = active_ais()
		if(active_ais.len && prob(100/GLOB.joined_player_list.len))
			var/datum/objective/destroy/destroy_objective = new
			destroy_objective.owner = owner
			destroy_objective.find_target()
			add_objective(destroy_objective)
		else if(prob(30))
			var/datum/objective/maroon/maroon_objective = new
			maroon_objective.owner = owner
			maroon_objective.find_target()
			add_objective(maroon_objective)
		else
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = owner
			kill_objective.find_target()
			add_objective(kill_objective)
	else
		var/datum/objective/steal/steal_objective = new
		steal_objective.owner = owner
		steal_objective.find_target()
		add_objective(steal_objective)

/datum/antagonist/vampire/proc/vamp_burn(var/severe_burn = FALSE)
	var/mob/living/L = owner.current
	if(!L)
		return
	var/burn_chance = severe_burn ? 35 : 8
	if(prob(burn_chance) && L.health >= 50)
		switch(L.health)
			if(75 to 100)
				L.visible_message("<span class='warning'>[L]'s skin begins to flake!</span>", "<span class='danger'>Your skin flakes away...</span>")
			if(50 to 75)
				L.visible_message("<span class='warning'>[L]'s skin sizzles loudly!</span>", "<span class='danger'>Your skin sizzles!</span>", "You hear sizzling.")
		L.adjustFireLoss(3)
	else if(L.health < 50)
		if(!L.on_fire)
			L.visible_message("<span class='warning'>[L] catches fire!</span>", "<span class='danger'>Your skin catches fire!</span>")
			L.emote("scream")
		else
			L.visible_message("<span class='warning'>[L] continues to burn!</span>", "<span class='danger'>Your continue to burn!</span>")
		L.adjust_fire_stacks(5)
		L.IgniteMob()
	return

/datum/antagonist/vampire/proc/check_sun()
	var/mob/living/carbon/C = owner.current
	if(!C)
		return
	var/ax = C.x
	var/ay = C.y

	for(var/i = 1 to 20)
		ax += round(sin(SSsun.azimuth), 0.01)
		ay += round(cos(SSsun.azimuth), 0.01)

		var/turf/T = locate(round(ax, 0.5), round(ay, 0.5), C.z)

		if(T.x == 1 || T.x == world.maxx || T.y == 1 || T.y == world.maxy)
			break

		if(T.density)
			return
	vamp_burn(TRUE)

/datum/antagonist/vampire/proc/vampire_life()
	var/mob/living/carbon/C = owner.current
	if(!C)
		return
	if(owner && C.hud_used && C.hud_used.vamp_blood_display)
		C.hud_used.vamp_blood_display.invisibility = FALSE
		C.hud_used.vamp_blood_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#dd66dd'>[round(usable_blood, 1)]</font></div>"
	handle_vampire_cloak()
	if(istype(C.loc, /obj/structure/closet/crate/coffin))
		C.adjustBruteLoss(-4)
		C.adjustFireLoss(-4)
		C.adjustToxLoss(-4)
		C.adjustOxyLoss(-4)
		C.adjustCloneLoss(-4)
		return
	if(!get_ability(/datum/vampire_passive/full) && istype(get_area(C.loc), /area/chapel))
		vamp_burn()
	if(isspaceturf(C.loc))
		check_sun()


/datum/antagonist/vampire/proc/handle_bloodsucking(mob/living/carbon/human/H)
	draining = H
	var/mob/living/carbon/human/O = owner.current
	var/blood = 0
	var/blood_coeff = 1 //how much blood is gained as a % from the amount drained, currently changed by how dead the victim is
	var/old_bloodtotal = 0 //used to see if we increased our blood total
	var/old_bloodusable = 0 //used to see if we increased our blood usable
	var/silent = FALSE //if the succ gives a message/sounds
	var/warned = FALSE //has the vampire been warned they're about to alert a target while stealth sucking?
	var/blood_to_take = BLOOD_SUCK_BASE //how much blood should be removed per succ? changes depending on grab state
	log_attack("[O] ([O.ckey]) bit [H] ([H.ckey]) in the neck")
	if(!(O.pulling == H))
		silent = TRUE
		blood_to_take *= 0.5 //half blood from targets that aren't being pulled, but they also don't get warned until it starts to cause damage
	else if(O.grab_state >= GRAB_NECK)
		blood_to_take *= 1.5 //50% more blood from targets that are being neck grabbed or above
	if(!silent)
		O.visible_message("<span class='danger'>[O] grabs [H]'s neck harshly and sinks in their fangs!</span>", "<span class='danger'>You sink your fangs into [H] and begin to [blood_to_take > BLOOD_SUCK_BASE ? "quickly" : ""] drain their blood.</span>", "<span class='notice'>You hear a soft puncture and a wet sucking noise.</span>")
		playsound(O.loc, 'sound/weapons/bite.ogg', 50, 1)
	else
		to_chat(O, "<span class='notice'>You stealthily begin to drain blood from [H], be careful, as they will notice if their blood gets too low.</span>")
		O.playsound_local(O, 'sound/weapons/bite.ogg', 50, 1)
	if(!iscarbon(owner))
		H.LAssailant = null
	else
		H.LAssailant = O
	while(do_mob(O, H, 50))
		if(!is_vampire(O))
			to_chat(O, "<span class='warning'>Your fangs have disappeared!</span>")
			return
		if(blood_to_take > BLOOD_SUCK_BASE && (!(O.pulling == H) || O.grab_state < GRAB_NECK))//smooth movement from aggressive suck to normal suck
			blood_to_take = BLOOD_SUCK_BASE
			to_chat(O, "<span class='warning'>You lose your grip on [H], reducing your bloodsucking speed.</span>")
		if(blood_to_take == BLOOD_SUCK_BASE && (O.pulling == H && O.grab_state >= GRAB_NECK))//smooth movement from normal suck to aggressive suck
			blood_to_take *= 1.5
			to_chat(O, "<span class='warning'>Your enchanced grip on [H] allows you to extract blood faster.</span>")
		if(silent && O.pulling == H) //smooth movement from stealth suck to normal suck
			silent = FALSE
			blood_to_take = BLOOD_SUCK_BASE
			O.visible_message("<span class='danger'>[O] grabs [H]'s neck harshly and sinks in their fangs!</span>", "<span class='danger'>You sink your fangs into [H] and begin to drain their blood.</span>", "<span class='notice'>You hear a soft puncture and a wet sucking noise.</span>")
			playsound(O.loc, 'sound/weapons/bite.ogg', 50, 1)
		old_bloodtotal = total_blood
		old_bloodusable = usable_blood
		if(!H.blood_volume)
			to_chat(O, "<span class='warning'>They've got no blood left to give.</span>")
			break
		blood_coeff = 0.8 //20 blood gain at base for living, 30 with aggressive grab, 10 with stealth
		if(H.stat == DEAD)
			blood_coeff = 0.2 //5 blood gain at base for dead, 7 with aggressive grab, 2 with stealth
		blood = round(min(blood_to_take * blood_coeff, H.blood_volume))	//if the victim has less than the amount of blood left to take, just take all of it.
		total_blood += blood			//get total blood 100% efficiency because fuck waiting out 5 fucking minutes and 1500 actual blood to get your 600 blood for the objective
		usable_blood += blood * 0.75	//75% usable blood since it's actually used for stuff
		check_vampire_upgrade()
		if(old_bloodtotal != total_blood)
			to_chat(O, "<span class='notice'><b>You have accumulated [total_blood] [total_blood > 1 ? "units" : "unit"] of blood[usable_blood != old_bloodusable ? ", and have [usable_blood] left to use" : ""].</b></span>")
		H.blood_volume = max(H.blood_volume - blood_to_take, 0)
		if(silent && !warned && (H.blood_volume <= (BLOOD_VOLUME_SAFE(H) + 20)))
			to_chat(O, "<span class='boldwarning'>Their blood is at a dangerously low level, they will likely begin to feel the effects if you continue...</span>")
			warned = TRUE
		if(ishuman(O))
			O.nutrition = min(O.nutrition + (blood * 0.5), NUTRITION_LEVEL_WELL_FED)
		if(!silent)
			playsound(O.loc, 'sound/items/eatfood.ogg', 40, 1, extrarange = -4)//have to be within 3 tiles to hear the sucking
		else if(H.get_blood_state() <= BLOOD_OKAY)
			to_chat(H, "<span class='warning'>You feel oddly faint...</span>")

	draining = null
	to_chat(owner, "<span class='notice'>You stop draining [H.name] of blood.</span>")

/datum/antagonist/vampire/proc/force_add_ability(path)
	var/spell = new path(owner)
	if(istype(spell, /obj/effect/proc_holder/spell))
		owner.AddSpell(spell)
	powers += spell

/datum/antagonist/vampire/proc/get_ability(path)
	for(var/P in powers)
		var/datum/power = P
		if(power.type == path)
			return power
	return null

/datum/antagonist/vampire/proc/add_ability(path)
	if(!get_ability(path))
		force_add_ability(path)

/datum/antagonist/vampire/proc/remove_ability(ability)
	if(ability && (ability in powers))
		powers -= ability
		owner.spell_list.Remove(ability)
		qdel(ability)


/datum/antagonist/vampire/proc/remove_vampire_powers()
	for(var/P in powers)
		remove_ability(P)
	owner.current.alpha = 255

/datum/antagonist/vampire/proc/check_vampire_upgrade(var/announce = TRUE)
	var/list/old_powers = powers.Copy()
	for(var/ptype in upgrade_tiers)
		var/level = upgrade_tiers[ptype]
		if(total_blood >= level)
			add_ability(ptype)
	if(announce)
		announce_new_power(old_powers)
	owner.current.update_sight() //deal with sight abilities

/datum/antagonist/vampire/proc/announce_new_power(list/old_powers)
	for(var/p in powers)
		if(!(p in old_powers))
			if(istype(p, /obj/effect/proc_holder/spell))
				var/obj/effect/proc_holder/spell/power = p
				to_chat(owner.current, "<span class='notice'>[power.gain_desc]</span>")
			else if(istype(p, /datum/vampire_passive))
				var/datum/vampire_passive/power = p
				to_chat(owner, "<span class='notice'>[power.gain_desc]</span>")

/datum/antagonist/vampire/proc/handle_vampire_cloak()
	if(!ishuman(owner.current))
		owner.current.alpha = 255
		return
	var/mob/living/carbon/human/H = owner.current
	var/turf/T = get_turf(H)
	var/light_available = T.get_lumcount()

	if(!istype(T))
		return 0

	if(!iscloaking)
		H.alpha = 255
		return 0

	if(light_available <= 0.25)
		H.alpha = round((255 * 0.15))
		return 1
	else
		H.alpha = round((255 * 0.80))

/datum/antagonist/vampire/roundend_report()
	var/list/result = list()

	var/vampwin = TRUE

	result += printplayer(owner)

	var/objectives_text = ""
	if(objectives_given.len)//If the vampire had no objectives, don't need to process this.
		var/count = 1
		for(var/datum/objective/objective in objectives_given)
			if(objective.check_completion())
				objectives_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <span class='greentext'>Success!</span>"
			else
				objectives_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <span class='redtext'>Fail.</span>"
				vampwin = FALSE
			count++

	result += objectives_text

	if(vampwin)
		result += "<span class='greentext'>The vampire was successful!</span>"
		SSachievements.unlock_achievement(/datum/achievement/greentext/vampire, owner.current.client)
	else
		result += "<span class='redtext'>The vampire has failed!</span>"
		SEND_SOUND(owner.current, 'sound/ambience/ambifailure.ogg')

	return result.Join("<br>")
#undef BLOOD_SUCK_BASE
#undef ALL_POWERS_UNLOCKED
