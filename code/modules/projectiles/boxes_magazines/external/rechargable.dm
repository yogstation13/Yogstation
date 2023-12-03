//Laser Rifle

/obj/item/ammo_box/magazine/recharge
	name = "power pack"
	desc = "A rechargeable, detachable battery that serves as a magazine for laser rifles."
	icon_state = "powerpack"
	ammo_type = /obj/item/ammo_casing/caseless/laser
	caliber = LASER
	max_ammo = 20

/obj/item/ammo_box/magazine/recharge/update_desc(updates=ALL)
	. = ..()
	desc = "[initial(desc)] It has [stored_ammo.len] shot\s left."

/obj/item/ammo_box/magazine/recharge/update_overlays()
	. = ..()
	var/cur_ammo = ammo_count()
	if(cur_ammo)
		if(cur_ammo >= max_ammo)
			. += "[icon_state]_o_full"
		else
			. += "[icon_state]_o_mid"


/obj/item/ammo_box/magazine/recharge/attack_self() //No popping out the "bullets"
	return

/obj/item/ammo_box/magazine/recharge/lasgun
	max_ammo = 30
	icon = 'icons/obj/guns/grimdark.dmi'
	icon_state = "lasgunmag"
	desc = "A rechargeable, detachable battery that serves as a magazine for las weaponry."

/obj/item/ammo_box/magazine/recharge/lasgun/update_icon_state()
	. = ..()
	if(ammo_count())
		icon_state = "[initial(icon_state)]"
	else
		icon_state = "[initial(icon_state)]_0"

/obj/item/ammo_box/magazine/recharge/lasgun/attack_self() //No popping out the "bullets"
	return

/obj/item/ammo_box/magazine/recharge/lasgun/pistol
	max_ammo = 15
	desc = "A smaller, lighter version of the standard lasgun power-pack. Holds less charge but fits into handguns."
	icon_state = "laspistolmag"

/obj/item/ammo_box/magazine/recharge/lasgun/hotshot
	max_ammo = 20
	desc = "A power-pack tuned to discharge more power with each shot, allowing for the hotshot lasgun to deal more damage."

/obj/item/ammo_box/magazine/recharge/lasgun/sniper
	max_ammo = 8
	desc = "A standard power-pack for las weaponry, this one expending more power into focusing shots so they land on far-away targets."

/obj/item/gun/ballistic/automatic/pistol/ntusp
	name = "NT-USP pistol"
	desc = "The NT-HL3, later renamed to the NT-USP, is a small pistol that uses hardlight technology to synthesize bullets. Due to its low power, it doesn't have much use besides tiring out criminals."
	icon_state = "ntusp"
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/recharge/ntusp
	can_suppress = TRUE // based and suppressor pilled
	can_flashlight = TRUE
	flight_x_offset = 16
	flight_y_offset = 13
	bolt_type = BOLT_TYPE_LOCKING
	fire_sound = "sound/weapons/gunshot.ogg"
	vary_fire_sound = FALSE
	fire_sound_volume = 80
	rack_sound = "sound/weapons/pistolrack.ogg"
	bolt_drop_sound = "sound/weapons/pistolslidedrop.ogg"
	bolt_wording = "slide"
	feedback_types = list(
		"fire" = 2
	)

/obj/item/gun/ballistic/automatic/pistol/ntusp/update_icon(updates=ALL)
	. = ..()
	icon_state = initial(icon_state)
	if(istype(magazine, /obj/item/ammo_box/magazine/recharge/ntusp/laser))
		// Tricks the parent proc into thinking we have a skin so it uses the laser-variant icon_state
		// I sure hope no one tries to add skins to NT-USP in the future
		current_skin = "ntusp-l"
		unique_reskin = list()
		unique_reskin[current_skin] = current_skin
	current_skin = null
	unique_reskin = null

//NT-USP Clip
/obj/item/ammo_box/magazine/recharge/ntusp
	name = "small power pack"
	desc = "A small, rechargeable power pack for the NT-USP. Synthesizes up to twelve .22HL bullets that tire targets."
	icon_state = "powerpack_small"
	ammo_type = /obj/item/ammo_casing/caseless/c22hl
	max_ammo = 12

/obj/item/ammo_box/magazine/recharge/ntusp/empty
	start_empty = TRUE

/obj/item/ammo_box/magazine/recharge/ntusp/emp_act(severity) //shooting physical bullets wont stop you dying to an EMP
	. = ..()
	if(!(. & EMP_PROTECT_CONTENTS))
		var/bullet_count = ammo_count()
		var/bullets_to_remove = round(bullet_count * (0.5**(severity/EMP_HEAVY)))
		for(var/i = 0; i < bullets_to_remove, i++)
			qdel(get_round())
		update_appearance(UPDATE_ICON)
		if(isgun(loc))
			var/obj/item/gun/ballistic/G = loc
			if(!G.magazine == src)
				return
			G.semicd = TRUE
			// up to 10 seconds depending on severity, then give or take 0.2 seconds to prevent piercing ears
			var/unjam_time = (min(severity, EMP_HEAVY) + (rand(-20,20)*0.01)) SECONDS
			addtimer(CALLBACK(G, TYPE_PROC_REF(/obj/item/gun, reset_semicd)), unjam_time)

/obj/item/ammo_casing/caseless/c22hl
	caliber = ENERGY
	harmful = FALSE
	projectile_type = /obj/projectile/bullet/c22hl

/obj/projectile/bullet/c22hl //.22 HL
	name = "hardlight beam"
	icon_state = "disabler_bullet"
	armor_flag = ENERGY
	damage = 0 // maybe don't do actual damage so pacifists can use it and silicons won't be mad
	damage_type = BURN
	stamina = 25
	speed = 0.55

//NT-USP Lethal Clip
/obj/item/ammo_box/magazine/recharge/ntusp/laser
	desc = "A small, rechargeable power pack for the NT-USP that has been modified. Synthesizes up to eight .22LS bullets that fire lasers."
	ammo_type = /obj/item/ammo_casing/caseless/c22ls
	icon_state = "powerpack_small-l"
	max_ammo = 8

/obj/item/ammo_box/magazine/recharge/ntusp/laser/update_overlays()
	. = ..()
	var/cur_ammo = ammo_count()
	if(cur_ammo)
		if(cur_ammo >= max_ammo)
			. += "powerpack_small_o_full"
		else
			. += "powerpack_small_o_mid"

/obj/item/ammo_box/magazine/recharge/ntusp/laser/empty
	start_empty = TRUE

/obj/item/ammo_casing/caseless/c22ls
	caliber = LASER
	harmful = TRUE
	projectile_type = /obj/projectile/bullet/c22ls

/obj/projectile/bullet/c22ls //.22 LS
	name = "laser beam"
	icon_state = "disabler_bullet"
	armor_flag = LASER
	damage = 18
	damage_type = BURN
	color = "#ff0000"
	speed = 0.55
	wound_bonus = -15
	bare_wound_bonus = 5
	splatter = TRUE

/obj/item/ntusp_conversion_kit
	name = "NT-USP magazine conversion kit"
	desc = "A standard conversion kit for use in converting NT-USP magazines to be more lethal or less lethal."
	icon = 'icons/obj/objects.dmi'
	icon_state = "modkit_ntusp"
	w_class = WEIGHT_CLASS_TINY

/obj/item/ammo_box/magazine/recharge/ntusp/attackby(obj/item/A, mob/user)
	if(istype(A, /obj/item/ntusp_conversion_kit))
		to_chat(user, span_danger("[A] makes a whirring sound as it modifies \the [src]'s lens to fabricate more lethal rounds."))
		new /obj/item/ammo_box/magazine/recharge/ntusp/laser/empty(get_turf(src)) // you thought you were getting free bullets?
		qdel(src)
	else
		return ..()

/obj/item/ammo_box/magazine/recharge/ntusp/laser/attackby(obj/item/A, mob/user)
	if(istype(A, /obj/item/ntusp_conversion_kit))
		to_chat(user, span_notice("[A] makes a whirring sound as it modifies \the [src]'s lens to fabricate less lethal rounds."))
		new /obj/item/ammo_box/magazine/recharge/ntusp/empty(get_turf(src))
		qdel(src)
	else
		return ..()
