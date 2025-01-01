/obj/item/assembly/flash/explosive
	desc = "A powerful and versatile flashbulb device, with applications ranging from disorienting attackers to \
	acting as visual receptors in robot production. This one seems slightly heavier than usual."
	var/admin_log = null

/obj/item/assembly/flash/explosive/attack(mob/living/M, mob/living/user)
	prepare_boom(user)

/obj/item/assembly/flash/explosive/attack_self(mob/living/carbon/user, flag, emp)
	prepare_boom(user)

/obj/item/assembly/flash/explosive/proc/prepare_boom(mob/living/user)
	user.visible_message("[user] presses a button on top of the flash... <font color='red'>what was that sound?</font>?")
	playsound(src, 'sound/machines/beep.ogg', 100, TRUE)
	addtimer(CALLBACK(src, PROC_REF(detonate), src), 1.5 SECONDS)
	admin_log = "[user] detonates the explosive flash!"
	burn_out()

/obj/item/assembly/flash/explosive/proc/detonate()
	message_admins(admin_log)
	log_game(admin_log)
	explosion(src, devastation_range = 0, heavy_impact_range = 2, light_impact_range = 4, flame_range = 2, flash_range = 7)
	qdel(src)
