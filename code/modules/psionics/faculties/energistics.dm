/datum/psionic_faculty/energistics
	id = PSI_ENERGISTICS
	name = "Energistics"
	armour_types = list(BOMB, LASER, ENERGY, FIRE)

/datum/psionic_power/energistics
	faculty = PSI_ENERGISTICS

/datum/psionic_power/energistics/electrocute
	name =            "Electrocute"
	cost =            10
	heat =            30
	cooldown =        7.5 SECONDS
	min_rank =        PSI_RANK_OPERANT
	icon_state = "ene_ele"
	use_description = "Activate the power with z, then Enter combat mode to use a melee attack that electrocutes a victim, or charge an energy cell."

/datum/psionic_power/energistics/electrocute/invoke(mob/living/user, mob/living/target, proximity, parameters)
	if(!user.combat_mode || !istype(target) || !proximity) 
		return FALSE
	. = ..()
	if(.)
		if(istype(target))
			user.visible_message(span_danger("\The [user] sends a jolt of electricity arcing into \the [target]!"))
			target.electrocute_act(rand(15,45), user, 1, user.zone_selected, stun = (user.psi.get_rank(PSI_ENERGISTICS) >= PSI_RANK_PARAMOUNT))
			return TRUE
		else if(isatom(target))
			var/obj/item/stock_parts/cell/charging_cell = target.get_cell()
			if(istype(charging_cell))
				user.visible_message(span_danger("\The [user] sends a jolt of electricity arcing into \the [target], charging it!"))
				charging_cell.give(rand(15,45))
			return TRUE
		else
			return FALSE

/datum/psionic_power/energistics/spark
	name =            "Spark"
	cost =            1
	cooldown =        1 SECONDS
	min_rank =        PSI_RANK_OPERANT
	icon_state = "ene_spark"
	use_description = "Activate the power with z, then target a non-living thing in melee range with combat mode on to cause some sparks to appear. This can light fires."

/datum/psionic_power/energistics/spark/invoke(mob/living/user, mob/living/target, proximity, parameters)
	if(!user.combat_mode || isnull(target) || istype(target) || !proximity) 
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
			s.set_up(5, 1, target)
			s.start()
		return TRUE

/datum/psionic_power/energistics/zorch
	name =             "Zorch"
	cost =             15
	heat =             15
	cooldown =         2 SECONDS
	min_rank =         PSI_RANK_MASTER
	icon_state = "ene_zorch"
	use_description = "Activate the power with z, then use this ranged laser attack with combat mode on. Your mastery of Energistics will determine how powerful the laser is. Be wary of overuse, and try not to fry your own brain."

/datum/psionic_power/energistics/zorch/invoke(mob/living/user, mob/living/target, proximity, parameters)
	. = ..()
	if(.)
		if(HAS_TRAIT(user, TRAIT_PACIFISM) && user.psi.zorch_harm)
			to_chat(user, span_notice("You manage to stop yourself before firing a harmful laser from your eyes, you don't want to risk harming anyone..."))

		var/user_rank = user.psi.get_rank(faculty)
		var/obj/projectile/pew
		var/pew_sound

		if(user.psi.zorch_harm)
			pew = new /obj/projectile/beam/laser(get_turf(user))
		else
			pew = new /obj/projectile/beam/disabler(get_turf(user))

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

/datum/psionic_power/energistics/disrupt
	name =            "Disrupt"
	cost =            20
	heat =            20
	cooldown =        10 SECONDS
	min_rank =        PSI_RANK_GRANDMASTER
	icon_state = "ene_disrupt"
	use_description = "Activate the power with z, then attack a target while in combat mode to cause a localized electromagnetic pulse."

/datum/psionic_power/energistics/disrupt/invoke(mob/living/user, mob/living/target, proximity, parameters)
	if(!user.combat_mode || !istype(target) || !proximity)
		return FALSE
	. = ..()
	if(.)
		user.visible_message("<span class='danger'>\The [user] releases a gout of crackling static and arcing lightning over \the [target]!</span>")
		empulse(target, 5, 1)
		return TRUE
