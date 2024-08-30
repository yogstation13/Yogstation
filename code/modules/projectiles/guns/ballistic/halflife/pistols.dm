/obj/item/gun/ballistic/automatic/pistol/usp
	name = "USP Match"
	desc = "A small and light 9mm pistol which is often used as a metropolice standard carry."
	icon_state = "pistol"
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/usp9mm
	can_suppress = TRUE
	burst_size = 1
	fire_delay = 0
	actions_types = list()
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

/obj/item/gun/ballistic/automatic/pistol/usp/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/pistol/usp/suppressed/Initialize(mapload)
	. = ..()
	var/obj/item/suppressor/S = new(src)
	install_suppressor(S)
