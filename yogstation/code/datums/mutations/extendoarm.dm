/datum/mutation/human/extendoarm
	name = "Extendo Arm"
	desc = "Allows the affected to stretch their arms to grab objects from a distance."
	quality = POSITIVE
	difficulty = 16
	text_gain_indication = span_notice("Your arms feel stretchy.")
	text_lose_indication = span_warning("Your arms feel solid again.")
	power_path = /datum/action/cooldown/spell/pointed/projectile/extendoarm
	instability = 30

/datum/action/cooldown/spell/pointed/projectile/extendoarm
	name = "Arm"
	desc = "Stretch your arm to grab or put stuff down."
	button_icon = 'yogstation/icons/mob/actions/actions_spells.dmi'
	button_icon_state = "arm"
	base_icon_state = "arm"

	cooldown_time = 5 SECONDS
	spell_requirements = NONE

	cast_range = 50
	projectile_type = /obj/projectile/bullet/arm
	active_msg = "You loosen up your arm!"
	deactive_msg = "You relax your arm."
	projectile_amount = 64

/datum/action/cooldown/spell/pointed/projectile/extendoarm/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(!iscarbon(owner))
		return FALSE

	var/mob/living/carbon/carbon_user = owner
	if(carbon_user.handcuffed) //this doesnt mix well with the whole arm removal thing
		return FALSE

	return TRUE

/datum/action/cooldown/spell/pointed/projectile/extendoarm/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/carbon_user = owner
	if(!carbon_user.hand_bodyparts[carbon_user.active_hand_index]) //all these checks are here, because we dont want to adjust the spell icon thing in your screen and break it. wich it otherwise does in can_cast
		return FALSE
	if(HAS_TRAIT(owner, TRAIT_NODISMEMBER))
		owner.balloon_alert(owner, "can't dismember limbs!")
		return FALSE
	if(!owner.canUnEquip(owner.get_active_held_item()))
		owner.balloon_alert(owner, "can't drop active item!")
		return FALSE

	return TRUE

/datum/action/cooldown/spell/pointed/projectile/extendoarm/ready_projectile(obj/projectile/bullet/arm/firing_arm, atom/target, mob/user, iteration)
	. = ..()
	var/mob/living/carbon/carbon_user = user
	var/new_color
	if(carbon_user.dna && !carbon_user.dna.species.use_skintones)
		new_color = carbon_user.dna.features["mcolor"]
		firing_arm.add_atom_colour(new_color, FIXED_COLOUR_PRIORITY)

	
	firing_arm.set_homing_target(target)
	firing_arm.beam = firing_arm.Beam(carbon_user, icon_state = "2-full", time = 20 SECONDS, maxdistance = 150, beam_color = new_color)

	var/obj/item/I = carbon_user.get_active_held_item()
	if(I && carbon_user.dropItemToGround(I, FALSE))
		var/obj/projectile/bullet/arm/ARM = firing_arm
		ARM.grab(I)
	firing_arm.arm = carbon_user.hand_bodyparts[carbon_user.active_hand_index]
	firing_arm.arm.drop_limb()
	firing_arm.arm.forceMove(firing_arm)

/obj/projectile/bullet/arm
	name = "arm"
	icon = 'yogstation/icons/obj/projectiles.dmi'
	icon_state = "arm"
	suppressed = TRUE
	damage = 0
	range = 100
	speed = 2
	nodamage = 1
	homing = TRUE
	homing_turn_speed = 360
	var/obj/item/grabbed
	var/obj/item/bodypart/arm
	var/returning = FALSE
	var/datum/beam/beam

/obj/projectile/bullet/arm/prehit(atom/target, blocked = FALSE)
	if(returning)
		if(target == firer)
			var/mob/living/L = firer
			if(arm && firer)
				arm.attach_limb(firer, TRUE)
				arm = null
			L.put_in_hands(ungrab())
			qdel(src) //If we let it run it's course, it's going to awkwardly hit you
	else if(!isitem(target) && !grabbed && firer)
		target.attack_hand(firer)
		go_home()
	else
		if(grabbed)
			ungrab()
		else if(isitem(target))
			var/obj/item/I = target
			if(!I.anchored)
				grab(target)
		go_home()

/obj/projectile/bullet/arm/proc/go_home()
	homing_target = firer
	returning = TRUE
	icon_state += "-reverse"
	range = decayedRange
	ignore_source_check = TRUE

/obj/projectile/bullet/arm/proc/grab(obj/item/I)
	if(!I)
		return
	I.forceMove(src)
	var/image/IM = image(I, src)
	IM.appearance_flags = RESET_COLOR //Otherwise skin color leaks to the object
	grabbed = I
	overlays += IM

/obj/projectile/bullet/arm/proc/ungrab()
	if(!grabbed)
		return
	grabbed.forceMove(drop_location())
	overlays.Cut()
	. = grabbed
	grabbed = null

/obj/projectile/bullet/arm/Destroy()
	if(grabbed)
		grabbed.forceMove(drop_location())
	if(arm)
		arm.forceMove(drop_location())
	qdel(beam)
	return ..()
