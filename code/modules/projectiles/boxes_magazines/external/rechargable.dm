//Laser Rifle

/obj/item/ammo_box/magazine/recharge
	name = "power pack"
	desc = "A rechargeable, detachable battery that serves as a magazine for laser rifles."
	icon_state = "powerpack"
	ammo_type = /obj/item/ammo_casing/caseless/laser
	caliber = LASER
	max_ammo = 20

/obj/item/ammo_box/magazine/recharge/update_icon()
	..()
	desc = "[initial(desc)] It has [stored_ammo.len] shot\s left."
	cut_overlays()
	var/cur_ammo = ammo_count()
	if(cur_ammo)
		if(cur_ammo >= max_ammo)
			add_overlay("[icon_state]_o_full")
		else
			add_overlay("[icon_state]_o_mid")
		

/obj/item/ammo_box/magazine/recharge/attack_self() //No popping out the "bullets"
	return

/obj/item/gun/ballistic/automatic/pistol/ntusp
	name = "NT-USP pistol"
	desc = "A small pistol that uses hardlight technology to synthesize bullets. Due to its low power, it doesn't have much use besides tiring out criminals."
	icon_state = "ntusp"
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/recharge/ntusp
	can_suppress = FALSE
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

//NT-USP Clip
/obj/item/ammo_box/magazine/recharge/ntusp
	name = "small power pack"
	desc = "A small rechargable power pack that synthesizes .22HL bullets, used in the NT-USP."
	icon_state = "powerpack_small"
	ammo_type = /obj/item/ammo_casing/caseless/c22hl
	max_ammo = 9

/obj/item/ammo_box/magazine/recharge/ntusp/emp_act(severity) //shooting physical bullets wont stop you dying to an EMP
	. = ..()
	if(!(. & EMP_PROTECT_CONTENTS)) 
		var/bullet_count = ammo_count()
		var/bullets_to_remove = round(bullet_count / severity)
		for(var/i = 0; i < bullets_to_remove, i++)
			qdel(get_round())
		update_icon()

/obj/item/ammo_casing/caseless/c22hl
	caliber = ENERGY
	projectile_type = /obj/item/projectile/bullet/c22hl

/obj/item/projectile/bullet/c22hl //.22 HL
	name = "NT-USP beam"
	icon_state = "disabler_bullet"
	flag = ENERGY
	damage = 2 //ouch ouch my skin ouchie
	damage_type = BURN
	stamina = 25

