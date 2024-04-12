/obj/item/gun/ballistic/shotgun
	name = "shotgun"
	desc = "A traditional shotgun with wood furniture and a four-shell capacity underneath."
	icon_state = "shotgun"
	item_state = "shotgun"
	fire_sound = "sound/weapons/shotgunshot.ogg"
	vary_fire_sound = FALSE
	fire_sound_volume = 90
	rack_sound = "sound/weapons/shotgunpump.ogg"
	load_sound = "sound/weapons/shotguninsert.ogg"
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	flags_1 =  CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	mag_type = /obj/item/ammo_box/magazine/internal/shot
	weapon_weight = WEAPON_MEDIUM
	semi_auto = FALSE
	internal_magazine = TRUE
	casing_ejector = FALSE
	bolt_wording = "pump"
	cartridge_wording = "shell"
	tac_reloads = FALSE

/obj/item/gun/ballistic/shotgun/automatic
	name = "semi-auto shotgun"
	desc = "A shotgun that automatically chambers a new round after firing."
	rack_sound = "sound/weapons/gun_slide_lock_5.ogg"
	rack_sound_vary = FALSE
	bolt_type = BOLT_TYPE_LOCKING
	semi_auto = TRUE
	casing_ejector = TRUE
	bolt_wording = "charging handle"

/obj/item/gun/ballistic/shotgun/blow_up(mob/user)
	. = 0
	if(chambered && chambered.BB)
		process_fire(user, user, FALSE)
		. = 1

/obj/item/gun/ballistic/shotgun/lethal
	mag_type = /obj/item/ammo_box/magazine/internal/shot/lethal

// RIOT SHOTGUN //

/obj/item/gun/ballistic/shotgun/riot //for spawn in the armory
	name = "riot shotgun"
	desc = "A sturdy shotgun with a longer magazine and a fixed tactical stock designed for non-lethal riot control."
	icon_state = "riotshotgun"
	fire_delay = 7
	mag_type = /obj/item/ammo_box/magazine/internal/shot/riot
	sawn_desc = "Come with me if you want to live."
	can_be_sawn_off  = TRUE

// Breaching Shotgun //

/obj/item/gun/ballistic/shotgun/automatic/breaching
	name = "tactical breaching shotgun"
	desc = "A compact semi-auto shotgun designed to fire breaching slugs and create rapid entry points. Only accepts breaching slugs."
	icon_state = "breachingshotgun"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/breaching
	w_class = WEIGHT_CLASS_NORMAL //compact so it fits in backpacks
	can_be_sawn_off  = FALSE


// Automatic Shotguns//

/obj/item/gun/ballistic/shotgun/automatic/combat
	name = "combat shotgun"
	desc = "A semi-automatic shotgun with tactical furniture and a six-shell capacity underneath."
	fire_delay = 5
	icon_state = "cshotgun"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/com
	w_class = WEIGHT_CLASS_HUGE

/obj/item/gun/ballistic/shotgun/automatic/combat/compact
	name = "compact combat shotgun"
	desc = "A compact version of the semi-automatic combat shotgun. For close encounters."
	icon_state = "cshotgunc"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/com/compact
	w_class = WEIGHT_CLASS_BULKY

//Dual Feed Shotgun

/obj/item/gun/ballistic/shotgun/automatic/dual_tube
	name = "cycler shotgun"
	desc = "An advanced shotgun with two separate magazine tubes, allowing you to quickly toggle between ammo types."
	icon_state = "cycler"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/tube
	w_class = WEIGHT_CLASS_HUGE
	var/toggled = FALSE
	var/obj/item/ammo_box/magazine/internal/shot/alternate_magazine

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click to pump it.")

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/Initialize(mapload)
	. = ..()
	if (!alternate_magazine)
		alternate_magazine = new mag_type(src)

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/attack_self(mob/living/user)
	if(!chambered && magazine.contents.len)
		rack()
	else
		toggle_tube(user)

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/proc/toggle_tube(mob/living/user)
	var/current_mag = magazine
	var/alt_mag = alternate_magazine
	magazine = alt_mag
	alternate_magazine = current_mag
	toggled = !toggled
	if(toggled)
		to_chat(user, "You switch to tube B.")
	else
		to_chat(user, "You switch to tube A.")

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/AltClick(mob/living/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	rack()

/obj/item/gun/ballistic/shotgun/lever
	name = "\improper Winton Mk. VI Repeating Rifle"
	desc = "A lever-action rifle chambered in .308 with pristine wooden furniture. Favored by Frontier sharpshooters."
	icon_state = "wintonrifle"
	item_state = "wintonrifle"
	fire_sound = "sound/weapons/leverfire.ogg"
	fire_sound_volume = 50
	rack_sound = "sound/weapons/leverrack.ogg"
	load_sound = "sound/weapons/leverload.ogg"
	fire_delay = 9
	mag_type = /obj/item/ammo_box/magazine/internal/shot/lever
	bolt_wording = "lever"
	cartridge_wording = "bullet"

// Bulldog shotgun //

/obj/item/gun/ballistic/shotgun/bulldog
	name = "\improper Bulldog Shotgun"
	desc = "A semi-auto, mag-fed shotgun for combat in narrow corridors, nicknamed 'Bulldog' by boarding parties. Compatible only with specialized 8-round drum magazines."
	icon_state = "bulldog"
	item_state = "bulldog"
	w_class = WEIGHT_CLASS_NORMAL
	weapon_weight = WEAPON_MEDIUM
	mag_type = /obj/item/ammo_box/magazine/m12g
	can_suppress = FALSE
	burst_size = 1
	fire_delay = 0
	pin = /obj/item/firing_pin/implant/pindicate
	actions_types = list()
	mag_display = TRUE
	mag_display_ammo = TRUE
	empty_indicator = TRUE
	semi_auto = TRUE
	internal_magazine = FALSE
	tac_reloads = TRUE


/obj/item/gun/ballistic/shotgun/bulldog/unrestricted
	pin = /obj/item/firing_pin
/////////////////////////////
// DOUBLE BARRELED SHOTGUN //
/////////////////////////////

/obj/item/gun/ballistic/shotgun/doublebarrel
	name = "double-barreled shotgun"
	desc = "A true classic."
	icon_state = "dshotgun"
	item_state = "shotgun"
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_MEDIUM
	force = 10
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	mag_type = /obj/item/ammo_box/magazine/internal/shot/dual
	sawn_desc = "Omar's coming!"
	obj_flags = UNIQUE_RENAME
	rack_sound_volume = 0
	unique_reskin = list("Default" = "dshotgun",
						"Dark Red Finish" = "dshotgun_d",
						"Ash" = "dshotgun_f",
						"Faded Grey" = "dshotgun_g",
						"Maple" = "dshotgun_l",
						"Rosewood" = "dshotgun_p"
						)
	semi_auto = TRUE
	bolt_type = BOLT_TYPE_NO_BOLT
	can_be_sawn_off  = TRUE

/obj/item/gun/ballistic/shotgun/doublebarrel/lethal
	mag_type = /obj/item/ammo_box/magazine/internal/shot/lethal

/obj/item/gun/ballistic/shotgun/doublebarrel/AltClick(mob/user)
	. = ..()
	if(unique_reskin && !current_skin && user.canUseTopic(src, BE_CLOSE, NO_DEXTERY))
		reskin_obj(user)

// IMPROVISED SHOTGUN //

/obj/item/gun/ballistic/shotgun/doublebarrel/improvised
	name = "improvised shotgun"
	desc = "Essentially a tube that aims shotgun shells."
	icon_state = "ishotgun"
	item_state = "shotgun"
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	slot_flags = null
	mag_type = /obj/item/ammo_box/magazine/internal/shot/improvised
	sawn_desc = "I'm just here for the gasoline."
	unique_reskin = null
	can_bayonet = TRUE //STOP WATCHING THIS FILTH MY FELLOW CARGONIAN,WE MUST DEFEND OURSELVES
	var/slung = FALSE
	var/usage = 0 //how many times it's been used since last maintenance

/obj/item/gun/ballistic/shotgun/doublebarrel/improvised/afterattack()
	if(prob(usage * 10))//10% chance for each shot to not fire
		if(prob(max((usage - 5), 0) * 10))//10% chance for each shot to explode, after 6 shots
			explosion(src, 0, 0, 1, 1)
			playsound(src, 'sound/effects/break_stone.ogg', 30, TRUE)
			to_chat(usr, span_warning("The round explodes in the chamber!"))
			qdel(src)
			return
		playsound(src, dry_fire_sound, 30, TRUE)
		return
	else
		. = ..()
		usage++

/obj/item/gun/ballistic/shotgun/doublebarrel/improvised/attackby(obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/stack/cable_coil) && !sawn_off)
		var/obj/item/stack/cable_coil/C = A
		if(slung)
			to_chat(user, span_notice("The shotgun already has a sling."))
			return
		if(C.use(10))
			slot_flags = ITEM_SLOT_BACK
			to_chat(user, span_notice("You tie the lengths of cable to the shotgun, making a sling."))
			slung = TRUE
			update_appearance(UPDATE_ICON)
		else
			to_chat(user, span_warning("You need at least ten lengths of cable if you want to make a sling!"))

/obj/item/gun/ballistic/shotgun/doublebarrel/improvised/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(usage == initial(usage))
		to_chat(user, span_notice("[src] has no need for maintenance yet."))
		return

	to_chat(user, span_notice("You start to perform some maintenance on [src]."))
	if(I.use_tool(src, user, 4 SECONDS))
		to_chat(user, span_notice("You fix up [src] a bit."))
		usage = max(usage - 2, initial(usage))

/obj/item/gun/ballistic/shotgun/doublebarrel/improvised/examine(mob/user)
	. = ..()
	switch(usage)
		if(0 to 1)
			. += "It looks about as good as it possibly could."
		if(2 to 6)
			. += "It's starting to show some wear."
		if(7 to INFINITY)
			. += "It's not long before this thing falls apart."

/obj/item/gun/ballistic/shotgun/doublebarrel/improvised/update_icon_state()
	. = ..()
	if(slung)
		icon_state = "ishotgunsling"
	

/obj/item/gun/ballistic/shotgun/doublebarrel/improvised/sawoff(mob/user)
	. = ..()
	if(. && slung) //sawing off the gun removes the sling
		new /obj/item/stack/cable_coil(get_turf(src), 10)
		slung = 0
		update_appearance(UPDATE_ICON)

/obj/item/gun/ballistic/shotgun/doublebarrel/improvised/sawn
	name = "sawn-off improvised shotgun"
	desc = "A single-shot shotgun. Better not miss."
	icon_state = "ishotgun"
	item_state = "gun"
	w_class = WEIGHT_CLASS_NORMAL
	sawn_off = TRUE
	slot_flags = ITEM_SLOT_BELT
	can_bayonet = FALSE
	usage = 1 //always slightly worse
