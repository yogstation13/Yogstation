/obj/item/gun/ballistic/automatic/ar2
	name = "\improper OSIPR"
	desc = "A pulse rifle often dubbed the 'AR2'. Boasts superior armor piercing capabilities, accuracy, and firepower. Biolocked to only be usable by authorised individuals."
	icon = 'icons/obj/guns/halflife/projectile.dmi'
	icon_state = "ar2"
	item_state = "arg"
	fire_sound = "sound/weapons/halflife/ar2fire.ogg"
	mag_type = /obj/item/ammo_box/magazine/ar2
	spread = 3
	fire_delay = 2
	burst_size = 2
	mag_display = TRUE
	pin = /obj/item/firing_pin/implant/mindshield


//old rifles that are exclusively loot. Similar to the AR2, but slightly less accurate, and no armor piercing by default.
/obj/item/gun/ballistic/automatic/m4a1
	name = "\improper M4A1 Rifle"
	desc = "A old M4A1 pattern rifle. Not as good as the combine's rifles, but still powerful."
	icon = 'icons/obj/guns/halflife/projectile.dmi'
	icon_state = "m4a1"
	item_state = "lwt650"
	fire_sound = "sound/weapons/dmrshot.ogg"
	vary_fire_sound = FALSE 
	load_sound = "sound/weapons/rifleload.ogg"
	load_empty_sound = "sound/weapons/rifleload.ogg"
	rack_sound = "sound/weapons/riflerack.ogg"
	eject_sound = "sound/weapons/rifleunload.ogg"
	eject_empty_sound = "sound/weapons/rifleunload.ogg"
	mag_type = /obj/item/ammo_box/magazine/m4a1
	fire_delay = 2
	burst_size = 2
	spread = 4 
	can_suppress = FALSE
	can_bayonet = TRUE
	knife_x_offset = 27
	knife_y_offset = 12
	mag_display = TRUE
	weapon_weight = WEAPON_MEDIUM
	w_class = WEIGHT_CLASS_BULKY


//the crossbow

/obj/item/gun/ballistic/bow/crossbow/rebar
	name = "Heated Rebar Crossbow"
	desc = "A handcrafted crossbow that fires heated rods of rebar."
	icon = 'icons/obj/guns/halflife/projectile.dmi'
	icon_state = "rebarxbow"
	item_state = "rebarxbow"
	//fire_sound = 'sound/items/xbow_lock.ogg'
	force = 12
	spread = 0
	draw_time = 3 SECONDS
	mag_type = /obj/item/ammo_box/magazine/internal/bow/rebar
