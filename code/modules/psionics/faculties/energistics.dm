/datum/psionic_faculty/energistics
	id = PSI_ENERGISTICS
	name = "Energistics"
	associated_intent = INTENT_HARM
	armour_types = list("bomb", "laser", "energy")

/datum/psionic_power/energistics
	faculty = PSI_ENERGISTICS

/datum/psionic_power/energistics/disrupt
	name =            "Disrupt"
	cost =            20
	heat =            20
	cooldown =        10 SECONDS
	use_melee =       TRUE
	min_rank =        PSI_RANK_MASTER
	use_description = "Target the head, eyes or mouth while on harm intent to use a melee attack that causes a localized electromagnetic pulse."

/datum/psionic_power/energistics/disrupt/invoke(var/mob/living/user, var/mob/living/target)
	if(user.zone_selected != BODY_ZONE_HEAD && user.zone_selected != BODY_ZONE_PRECISE_EYES && user.zone_selected != BODY_ZONE_PRECISE_MOUTH)
		return FALSE
	if(isturf(target))
		return FALSE
	. = ..()
	if(.)
		user.visible_message("<span class='danger'>\The [user] releases a gout of crackling static and arcing lightning over \the [target]!</span>")
		empulse(target, 0, 1)
		return TRUE

/datum/psionic_power/energistics/electrocute
	name =            "Electrocute"
	cost =            10
	heat =            30
	cooldown =        7.5 SECONDS
	use_melee =       TRUE
	min_rank =        PSI_RANK_GRANDMASTER
	use_description = "Target the chest or groin while on harm intent to use a melee attack that electrocutes a victim."

/datum/psionic_power/energistics/electrocute/invoke(var/mob/living/user, var/mob/living/target)
	if(user.zone_selected != BODY_ZONE_CHEST && user.zone_selected != BODY_ZONE_PRECISE_GROIN)
		return FALSE
	if(isturf(target))
		return FALSE
	. = ..()
	if(.)
		if(istype(target))
			user.visible_message(span_danger("\The [user] sends a jolt of electricity arcing into \the [target]!"))
			target.electrocute_act(rand(15,45), user, 1, user.zone_selected)
			return TRUE
		else if(isatom(target))
			var/obj/item/stock_parts/cell/charging_cell = target.get_cell()
			if(istype(charging_cell))
				user.visible_message(span_danger("\The [user] sends a jolt of electricity arcing into \the [target], charging it!"))
				charging_cell.give(rand(15,45))
			return TRUE
		else
			return FALSE

/datum/psionic_power/energistics/zorch
	name =             "Zorch"
	cost =             15
	heat =             15
	cooldown =         2 SECONDS
	use_ranged =       TRUE
	min_rank =         PSI_RANK_MASTER
	use_description = "Use this ranged laser attack while on harm intent. Your mastery of Energistics will determine how powerful the laser is. Be wary of overuse, and try not to fry your own brain."

/datum/psionic_power/energistics/zorch/invoke(var/mob/living/user, var/mob/living/target)
	. = ..()
	if(.)
		if(HAS_TRAIT(user, TRAIT_PACIFISM) && user.psi.zorch_harm)
			to_chat(user, span_notice("You manage to stop yourself before firing a harmful laser from your eyes, you don't want to risk harming anyone..."))

		var/user_rank = user.psi.get_rank(faculty)
		var/obj/item/projectile/pew
		var/pew_sound

		if(user.psi.zorch_harm)
			pew = new /obj/item/projectile/beam/laser(get_turf(user))
		else
			pew = new /obj/item/projectile/beam/disabler(get_turf(user))

		switch(user_rank)
			if(PSI_RANK_PARAMOUNT)
				pew.damage = 30
				pew.name = "gigawatt mental laser"
				pew_sound = 'sound/weapons/lasercannonfire.ogg'
			if(PSI_RANK_GRANDMASTER)
				pew.damage = 20
				pew.name = "megawatt mental laser"
				pew_sound = 'sound/weapons/Laser.ogg'
			if(PSI_RANK_MASTER)
				pew.damage = 10
				pew.name = "mental laser"
				pew_sound = 'sound/weapons/Taser.ogg'

		if(istype(pew))
			playsound(pew.loc, pew_sound, 25, 1)
			pew.original = target
			pew.starting = get_turf(user)
			pew.firer = user
			pew.fire(Get_Angle(user, target))
			user.visible_message(span_danger("[user]'s eyes flare with light!"))
			return TRUE

/datum/psionic_power/energistics/spark
	name =            "Spark"
	cost =            1
	cooldown =        1 SECONDS
	use_melee =       TRUE
	min_rank =        PSI_RANK_OPERANT
	use_description = "Target a non-living target in melee range on harm intent to cause some sparks to appear. This can light fires."

/datum/psionic_power/energistics/spark/invoke(var/mob/living/user, var/mob/living/target)
	if(isnull(target) || istype(target)) 
		return FALSE
	. = ..()
	if(.)
		if(istype(target,/obj/item/clothing/mask/cigarette))
			var/obj/item/clothing/mask/cigarette/S = target
			S.light("[user] snaps \his fingers and \the [S.name] lights up.")
			user.emote("snap")
			playsound(S.loc, "sparks", 50, 1)
		else
			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
			s.set_up(5, 1, src)
			s.start()
		return TRUE
