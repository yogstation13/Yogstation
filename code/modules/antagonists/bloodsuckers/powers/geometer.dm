/datum/action/bloodsucker/shape_blood
	name = "Shape Blood"
	desc = "Shape your blood in a form of various weapons."
	power_explanation = "<b>Shape Blood</b>:\n\
		Activating Shape Blood will allow you to choose and shape a weapon from your blood.\n\
		Higher levels will increase weapon stats and variety."
	icon_icon = 'icons/mob/actions/actions_tremere_bloodsucker.dmi'
	button_icon_state = "power_thaumaturgy"
	cooldown = 8 SECONDS
	bloodcost = 55
	purchase_flags = BLOODSUCKER_CAN_BUY
	power_flags = BP_AM_TOGGLE
	constant_bloodcost = 0
	var/obj/blood_weapon = null

/datum/action/bloodsucker/shape_blood/ActivatePower()
	var/list/guns = list(
		"Blood shield" = image(icon = 'icons/obj/vamp_obj.dmi', icon_state = "blood_shield"),
		)
	if(level_current >= 2)
		"[level_current >= 4 ? "" : "Weak "]Bloodbolt" = image(icon = 'icons/obj/projectiles.dmi', icon_state = "bloodbolt")
	if(level_current >= 5)
		"Bloodblade" = image(icon = 'icons/obj/changeling.dmi', icon_state = "arm_blade")
	var/choice = show_radial_menu(owner, owner, guns, radius = 42)
	if(!choice)
		return
	switch(choice)
		if("Bloodshield")
			owner.balloon_alert(owner, "shaped a blood shield")
			blood_weapon = new /obj/item/shield/bloodsucker (owner)
			if(!owner.put_in_hands(blood_weapon))
				qdel(blood_weapon)
		//   if("Weak Bloodbolt")
		//   if("Bloodbolt")
		//   if("Bloodblade")
	if(blood_weapon || !QDELETED(blood_weapon))
		RegisterSignal(blood_weapon, COMSIG_PARENT_QDELETING, .proc/on_item_qdeleting)
		return ..()

/datum/action/bloodsucker/shape_blood/proc/on_item_qdeleting()
	UnregisterSignal(blood_weapon, COMSIG_PARENT_QDELETING)
	blood_weapon = null
	DeactivatePower()

/obj/item/shield/bloodsucker
	name = "Blood shield"
	desc = "A shield, made from blood."
	icon = 'icons/obj/vamp_obj.dmi'
	icon_state = "blood_shield"
	armor = list(MELEE = 15, BULLET = 15, LASER = 40, ENERGY = 40, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 100) //It is made from blood, so it shouldn't be very good against physical attacks
	force = 13 //Also a weak weapon
	var/block_cost = 15

/obj/item/shield/bloodsucker/Initialize(mapload,silent,synthetic)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, BLOODSUCKER_TRAIT)
	if(ismob(loc) && !silent)
		loc.visible_message(span_warning("[loc.name] form a strange shield from their blood!"))

/obj/item/shield/bloodsucker/examine(mob/user)
	. = ..()
	if(IS_BLOODSUCKER(user))
		.+= span_notice("It costs 15 blood to block an attack with it.")

/obj/item/shield/bloodsucker/on_shield_block(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	var/datum/antagonist/bloodsucker/BS = IS_BLOODSUCKER(owner)
	var/kill_me = FALSE
	if(!BS)
		kill_me = TRUE
	else
		if(owner.blood_volume <= block_cost)
			to_chat(owner, span_warning("Your [src] dissolves, as you don't have enough blood to sustain it!"))
			kill_me = TRUE
		else
			BS.AddBloodVolume(-block_cost)
			kill_me = FALSE
	if(kill_me)
		visible_message(span_warning("[src] dissolves in a puddle of blood!"))
		new /obj/effect/decal/cleanable/blood (owner ? get_turf(owner) : get_turf(src))
		qdel(src)
	return ..()

