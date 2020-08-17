/datum/guardian_ability/major/healing
	name = "Healing"
	desc = "Allows the guardian to heal anything, living or inanimate, by touch."
	cost = 4
	has_mode = TRUE
	mode_on_msg = "<span class='danger'><B>You switch to healing mode.</span></B>"
	mode_off_msg = "<span class='danger'><B>You switch to combat mode.</span></B>"
	arrow_weight = 1.1
	var/healuser = TRUE

/datum/guardian_ability/major/healing/Apply()
	var/datum/atom_hud/medsensor = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medsensor.add_hud_to(guardian)

/datum/guardian_ability/major/healing/Remove()
	var/datum/atom_hud/medsensor = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medsensor.remove_hud_from(guardian)

/datum/guardian_ability/major/healing/Attack(atom/target)
	if(mode)
		var/list/guardians = guardian.summoner?.current?.hasparasites()
		if(target == guardian)
			to_chat(guardian, "<span class='danger bold'>You can't heal yourself!</span>")
			return TRUE
		if((target == guardian.summoner?.current || guardians.Find(target)) && healuser == FALSE)
			to_chat(guardian, "<span class='danger bold'>You can't heal your user!</span>")
			return TRUE
		if(isliving(target))
			var/mob/living/L = target
			guardian.do_attack_animation(L)
			L.adjustBruteLoss(-(master_stats.potential * 1.5), forced = TRUE)
			L.adjustFireLoss(-(master_stats.potential * 1.5), forced = TRUE)
			L.adjustOxyLoss(-(master_stats.potential * 1.5), forced = TRUE)
			L.adjustToxLoss(-(master_stats.potential * 1.5), forced = TRUE)
			var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal(get_turf(L))
			if(guardian.namedatum)
				H.color = guardian.namedatum.colour
			if(L == guardian.summoner?.current)
				guardian.update_health_hud()
				guardian.med_hud_set_health()
				guardian.med_hud_set_status()
			return TRUE
		else if(isobj(target))
			var/obj/O = target
			guardian.do_attack_animation(O)
			O.obj_integrity = min(O.obj_integrity + (O.max_integrity * 0.1), O.max_integrity)
			var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal(get_turf(O))
			if(guardian.namedatum)
				H.color = guardian.namedatum.colour
			return TRUE

/datum/guardian_ability/major/healing/limited
	name = "Limited Healing"
	desc = "Allows the guardian to heal anything with the exception of its user"
	cost = 3
	healuser = FALSE
