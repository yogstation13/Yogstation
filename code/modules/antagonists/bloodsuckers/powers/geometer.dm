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
	. = ..()
	var/list/guns = list(
		"Blood shield" = image(icon = 'icons/obj/vamp_obj.dmi', icon_state = "blood_shield"),
		)
	if(level_current >= 2)
		"[level_current >= 4 ? "" : "Weak "]Bloodbolt" = image(icon = 'icons/obj/projectiles.dmi', icon_state = "bloodbolt")
	if(level_current >= 5)
		"Bloodblade" = image(icon = 'icons/obj/changeling.dmi', icon_state = "arm_blade")
	var/choice = show_radial_menu(src, src, guns, radius = 42)
	//switch(choice)            //Guns are not coded yet, sorry
	//	if("Bloodshield")
	//   if("Weak Bloodbolt")
	//   if("Bloodbolt")
	//   if("Bloodblade")

/obj/item/shield/bloodsucker
	name = "Blood shield"
	icon = 'icons/obj/vamp_obj.dmi'
	icon_state = "blood_shield"
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 0, BOMB = 30, BIO = 0, RAD = 0, FIRE = 80, ACID = 70)
