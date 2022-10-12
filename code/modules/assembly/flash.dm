#define CONFUSION_STACK_MAX_MULTIPLIER 2
/obj/item/assembly/flash
	name = "flash"
	desc = "A powerful and versatile flashbulb device, with applications ranging from disorienting attackers to acting as visual receptors in robot production."
	icon_state = "flash"
	item_state = "flashtool"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	materials = list(/datum/material/iron = 300, /datum/material/glass = 300)
	light_color = LIGHT_COLOR_WHITE
	light_power = FLASH_LIGHT_POWER
	var/flashing_overlay = "flash-f"
	var/times_used = 0 //Number of times it's been used.
	var/burnt_out = FALSE     //Is the flash burnt out?
	var/burnout_resistance = 0
	var/last_used = 0 //last world.time it was used.
	var/cooldown = 0
	var/last_trigger = 0 //Last time it was successfully triggered.

/obj/item/assembly/flash/suicide_act(mob/living/user)
	if(burnt_out)
		user.visible_message(span_suicide("[user] raises \the [src] up to [user.p_their()] eyes and activates it ... but it's burnt out!"))
		return SHAME
	else if(user.eye_blind)
		user.visible_message(span_suicide("[user] raises \the [src] up to [user.p_their()] eyes and activates it ... but [user.p_theyre()] blind!"))
		return SHAME
	user.visible_message(span_suicide("[user] raises \the [src] up to [user.p_their()] eyes and activates it! It looks like [user.p_theyre()] trying to commit suicide!"))
	attack(user,user)
	return FIRELOSS

/obj/item/assembly/flash/update_icon(flash = FALSE)
	cut_overlays()
	attached_overlays = list()
	if(burnt_out)
		add_overlay("flashburnt")
		attached_overlays += "flashburnt"
	if(flash)
		add_overlay(flashing_overlay)
		attached_overlays += flashing_overlay
		addtimer(CALLBACK(src, .proc/update_icon), 5)
	if(holder)
		holder.update_icon()

/obj/item/assembly/flash/proc/clown_check(mob/living/carbon/human/user)
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		flash_carbon(user, user, 15, 0)
		return FALSE
	return TRUE

/obj/item/assembly/flash/proc/burn_out() //Made so you can override it if you want to have an invincible flash from R&D or something.
	if(!burnt_out)
		burnt_out = TRUE
		update_icon()
	if(ismob(loc))
		var/mob/M = loc
		M.visible_message(span_danger("[src] burns out!"),span_userdanger("[src] burns out!"))
	else
		var/turf/T = get_turf(src)
		T.visible_message(span_danger("[src] burns out!"))

/obj/item/assembly/flash/proc/flash_recharge(interval = 10)
	var/deciseconds_passed = world.time - last_used
	for(var/seconds = deciseconds_passed / 10, seconds >= interval, seconds -= interval) //get 1 charge every interval
		times_used--
	last_used = world.time
	times_used = max(0, times_used) //sanity
	if(max(0, prob(times_used * 3) - burnout_resistance)) //The more often it's used in a short span of time the more likely it will burn out
		burn_out()
		return FALSE
	return TRUE

//BYPASS CHECKS ALSO PREVENTS BURNOUT!
/obj/item/assembly/flash/proc/AOE_flash(bypass_checks = FALSE, range = 3, power = 5, targeted = FALSE, mob/user)
	if(!bypass_checks && !try_use_flash())
		return FALSE
	var/list/mob/targets = get_flash_targets(get_turf(src), range, FALSE)
	if(user)
		targets -= user
	for(var/mob/living/carbon/C in targets)
		flash_carbon(C, user, power, targeted, TRUE)
	return TRUE

/obj/item/assembly/flash/proc/get_flash_targets(atom/target_loc, range = 3, override_vision_checks = FALSE)
	if(!target_loc)
		target_loc = loc
	if(override_vision_checks)
		return get_hearers_in_view(range, get_turf(target_loc))
	if(isturf(target_loc) || (ismob(target_loc) && isturf(target_loc.loc)))
		return viewers(range, get_turf(target_loc))
	else
		return typecache_filter_list(target_loc.GetAllContents(), GLOB.typecache_living)

/obj/item/assembly/flash/proc/try_use_flash(mob/user = null)
	if(user && HAS_TRAIT(user, TRAIT_NO_STUN_WEAPONS))
		to_chat(user, span_warning("You can't seem to remember how this works!"))
		return FALSE
	if(burnt_out || (world.time < last_trigger + cooldown))
		return FALSE
	last_trigger = world.time
	playsound(src, 'sound/weapons/flash.ogg', 100, TRUE)
	flash_lighting_fx(FLASH_LIGHT_RANGE, light_power, light_color)
	times_used++
	flash_recharge()
	update_icon(TRUE)
	if(user && !clown_check(user))
		return FALSE
	return TRUE

/obj/item/assembly/flash/proc/flash_carbon(mob/living/carbon/M, mob/user, power = 15, targeted = TRUE, generic_message = FALSE)
	if(!istype(M))
		return
	if(user)
		log_combat(user, M, "[targeted? "flashed(targeted)" : "flashed(AOE)"]", src)
	else //caused by emp/remote signal
		M.log_message("was [targeted? "flashed(targeted)" : "flashed(AOE)"]",LOG_ATTACK)
	if(generic_message && M != user)
		to_chat(M, span_disarm("[src] emits a blinding light!"))
	if(targeted)
		if(M.flash_act(1, 1))
			if(M.confused < power)
				var/diff = power * CONFUSION_STACK_MAX_MULTIPLIER - M.confused
				M.confused += min(power, diff)
			if(user)
				terrible_conversion_proc(M, user)
				visible_message(span_disarm("[user] blinds [M] with the flash!"))
				to_chat(user, span_danger("You blind [M] with the flash!"))
				to_chat(M, span_userdanger("[user] blinds you with the flash!"))
			else
				to_chat(M, span_userdanger("You are blinded by [src]!"))
			M.Paralyze(rand(80,120))
		else if(user)
			visible_message(span_disarm("[user] fails to blind [M] with the flash!"))
			to_chat(user, span_warning("You fail to blind [M] with the flash!"))
			to_chat(M, span_danger("[user] fails to blind you with the flash!"))
		else
			to_chat(M, span_danger("[src] fails to blind you!"))
	else
		if(M.flash_act())
			var/diff = power * CONFUSION_STACK_MAX_MULTIPLIER - M.confused
			M.confused += min(power, diff)

/obj/item/assembly/flash/attack(mob/living/M, mob/user)
	if(!try_use_flash(user))
		return FALSE
	if(iscarbon(M))
		flash_carbon(M, user, 5, 1)
		return TRUE
	else if(issilicon(M))
		var/mob/living/silicon/robot/R = M
		if(!R.sensor_protection)
			log_combat(user, R, "flashed", src)
			update_icon(1)
			R.Paralyze(rand(80,120))
			var/diff = 5 * CONFUSION_STACK_MAX_MULTIPLIER - M.confused
			R.confused += min(5, diff)
			R.flash_act(affect_silicon = 1)
			user.visible_message(span_disarm("[user] overloads [R]'s sensors with the flash!"), span_danger("You overload [R]'s sensors with the flash!"))
			return TRUE
		else
			R.overlay_fullscreen("reducedflash", /obj/screen/fullscreen/flash/static)
			R.uneq_all()
			R.stop_pulling()
			R.break_all_cyborg_slots(TRUE)
			addtimer(CALLBACK(R, /mob/living/silicon/robot/.proc/clear_fullscreen, "reducedflash"), 5 SECONDS)
			addtimer(CALLBACK(R, /mob/living/silicon/robot/.proc/repair_all_cyborg_slots), 5 SECONDS)
			to_chat(R, span_danger("Your sensors were momentarily dazzled!"))
			user.visible_message(span_disarm("[user] overloads [R]'s sensors with the flash!"), span_danger("You overload [R]'s sensors with the flash!"))
			return TRUE

	user.visible_message(span_disarm("[user] fails to blind [M] with the flash!"), span_warning("You fail to blind [M] with the flash!"))

/obj/item/assembly/flash/attack_self(mob/living/carbon/user, flag = 0, emp = 0)
	if(holder)
		return FALSE
	if(!AOE_flash(FALSE, 3, 5, FALSE, user))
		return FALSE
	to_chat(user, span_danger("[src] emits a blinding light!"))

/obj/item/assembly/flash/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(!try_use_flash())
		return
	AOE_flash()
	burn_out()

/obj/item/assembly/flash/activate()//AOE flash on signal received
	if(!..())
		return
	AOE_flash()

/obj/item/assembly/flash/proc/terrible_conversion_proc(mob/living/carbon/H, mob/user)
	if(istype(H) && H.stat != DEAD)
		if(user.mind)
			var/datum/antagonist/rev/head/converter = user.mind.has_antag_datum(/datum/antagonist/rev/head)
			if(!converter)
				return
			if(!H.client)
				to_chat(user, span_warning("This mind is so vacant that it is not susceptible to influence!"))
				return
			if(H.stat != CONSCIOUS)
				to_chat(user, span_warning("They must be conscious before you can convert [H.p_them()]!"))
				return
			if(converter.add_revolutionary(H.mind))
				times_used -- //Flashes less likely to burn out for headrevs when used for conversion
			else
				to_chat(user, span_warning("This mind seems resistant to the flash!"))


/obj/item/assembly/flash/cyborg

/obj/item/assembly/flash/cyborg/attack(mob/living/M, mob/user)
	..()
	new /obj/effect/temp_visual/borgflash(get_turf(src))

/obj/item/assembly/flash/cyborg/attack_self(mob/user)
	..()
	new /obj/effect/temp_visual/borgflash(get_turf(src))

/obj/item/assembly/flash/cyborg/attackby(obj/item/W, mob/user, params)
	return
/obj/item/assembly/flash/cyborg/screwdriver_act(mob/living/user, obj/item/I)
	return

/obj/item/assembly/flash/memorizer
	name = "memorizer"
	desc = "If you see this, you're not likely to remember it any time soon."
	icon = 'icons/obj/device.dmi'
	icon_state = "memorizer"
	item_state = "nullrod"

/obj/item/assembly/flash/handheld //this is now the regular pocket flashes

/obj/item/assembly/flash/armimplant
	name = "photon projector"
	desc = "A high-powered photon projector implant normally used for lighting purposes, but also doubles as a flashbulb weapon. Self-repair protocols fix the flashbulb if it ever burns out."
	var/flashcd = 20
	var/overheat = 0
	var/obj/item/organ/cyberimp/arm/flash/I = null

/obj/item/assembly/flash/armimplant/burn_out()
	if(I && I.owner)
		to_chat(I.owner, span_warning("Your photon projector implant overheats and deactivates!"))
		I.Retract()
	overheat = TRUE
	addtimer(CALLBACK(src, .proc/cooldown), flashcd * 2)

/obj/item/assembly/flash/armimplant/try_use_flash(mob/user = null)
	if(user && HAS_TRAIT(user, TRAIT_NO_STUN_WEAPONS))
		to_chat(user, span_warning("You can't seem to remember how this works!"))
		return FALSE
	if(overheat)
		if(I && I.owner)
			to_chat(I.owner, span_warning("Your photon projector is running too hot to be used again so quickly!"))
		return FALSE
	overheat = TRUE
	addtimer(CALLBACK(src, .proc/cooldown), flashcd)
	playsound(src, 'sound/weapons/flash.ogg', 100, TRUE)
	update_icon(1)
	return TRUE


/obj/item/assembly/flash/armimplant/proc/cooldown()
	overheat = FALSE

/obj/item/assembly/flash/hypnotic
	desc = "A modified flash device, programmed to emit a sequence of subliminal flashes that can send a vulnerable target into a hypnotic trance."
	flashing_overlay = "flash-hypno"
	light_color = LIGHT_COLOR_PINK
	cooldown = 20

/obj/item/assembly/flash/hypnotic/burn_out()
	return

/obj/item/assembly/flash/hypnotic/flash_carbon(mob/living/carbon/M, mob/user, power = 15, targeted = TRUE, generic_message = FALSE)
	if(!istype(M))
		return
	if(user)
		log_combat(user, M, "[targeted? "hypno-flashed(targeted)" : "hypno-flashed(AOE)"]", src)
	else //caused by emp/remote signal
		M.log_message("was [targeted? "hypno-flashed(targeted)" : "hypno-flashed(AOE)"]",LOG_ATTACK)
	if(generic_message && M != user)
		to_chat(M, span_disarm("[src] emits a soothing light..."))
	if(targeted)
		if(M.flash_act(1, 1))
			var/hypnosis = FALSE
			if(M.hypnosis_vulnerable())
				hypnosis = TRUE
			if(user)
				user.visible_message(span_disarm("[user] blinds [M] with the flash!"), span_danger("You hypno-flash [M]!"))

			if(!hypnosis)
				to_chat(M, span_notice("The light makes you feel oddly relaxed..."))
				M.confused += min(M.confused + 10, 20)
				M.dizziness += min(M.dizziness + 10, 20)
				M.drowsyness += min(M.drowsyness + 10, 20)
				M.apply_status_effect(STATUS_EFFECT_PACIFY, 100)
			else
				M.apply_status_effect(/datum/status_effect/trance, 200, TRUE)

		else if(user)
			user.visible_message(span_disarm("[user] fails to blind [M] with the flash!"), span_warning("You fail to hypno-flash [M]!"))
		else
			to_chat(M, span_danger("[src] fails to blind you!"))

	else if(M.flash_act())
		to_chat(M, span_notice("Such a pretty light..."))
		M.confused += min(M.confused + 4, 20)
		M.dizziness += min(M.dizziness + 4, 20)
		M.drowsyness += min(M.drowsyness + 4, 20)
		M.apply_status_effect(STATUS_EFFECT_PACIFY, 40)
