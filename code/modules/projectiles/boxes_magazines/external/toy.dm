/obj/item/ammo_box/magazine/toy
	name = "foam force META magazine"
	ammo_type = /obj/item/ammo_casing/reusable/foam_dart
	caliber = CALIBER_FOAM
	var/hugbox = FALSE

/obj/item/ammo_box/magazine/toy/Initialize(mapload)
	. = ..()
	if(hugbox) //noob
		name = "safety-first [name]"

/obj/item/ammo_box/magazine/toy/attempt_load(obj/item/A, mob/user, silent, replace_spent)
	if(istype(A, /obj/item/ammo_casing/reusable/foam_dart/riot) && hugbox)
		to_chat(user, span_danger("The dart seems to be blocked from entering by a bright orange piece of plastic! How annoying."))
		return
	..()

/obj/item/ammo_box/magazine/toy/smg
	name = "foam force SMG magazine"
	icon_state = "smg9mm-42"
	ammo_type = /obj/item/ammo_casing/reusable/foam_dart
	max_ammo = 20

/obj/item/ammo_box/magazine/toy/smg/update_icon_state()
	. = ..()
	if(ammo_count())
		icon_state = "smg9mm-42"
	else
		icon_state = "smg9mm-0"

/obj/item/ammo_box/magazine/toy/smg/riot
	ammo_type = /obj/item/ammo_casing/reusable/foam_dart/riot

/obj/item/ammo_box/magazine/toy/pistol
	name = "foam force pistol magazine"
	icon_state = "9x19p"
	max_ammo = 10
	multiple_sprites = AMMO_BOX_FULL_EMPTY

/obj/item/ammo_box/magazine/toy/pistol/riot
	ammo_type = /obj/item/ammo_casing/reusable/foam_dart/riot

/obj/item/ammo_box/magazine/toy/smgm45
	name = "donksoft SMG magazine"
	icon_state = "c20r45-toy"
	caliber = CALIBER_FOAM
	ammo_type = /obj/item/ammo_casing/reusable/foam_dart
	max_ammo = 20

/obj/item/ammo_box/magazine/toy/smgm45/update_icon_state()
	. = ..()
	icon_state = "c20r45-[round(ammo_count(),2)]"

/obj/item/ammo_box/magazine/toy/smgm45/riot
	icon_state = "c20r45-riot"
	ammo_type = /obj/item/ammo_casing/reusable/foam_dart/riot

/obj/item/ammo_box/magazine/toy/m762
	name = "donksoft box magazine"
	icon_state = "a762-toy"
	ammo_type = /obj/item/ammo_casing/reusable/foam_dart
	max_ammo = 50

/obj/item/ammo_box/magazine/toy/m762/update_icon_state()
	. = ..()
	icon_state = "a762-[round(ammo_count(),10)]"

/obj/item/ammo_box/magazine/toy/m762/riot
	icon_state = "a762-riot"
	ammo_type = /obj/item/ammo_casing/reusable/foam_dart/riot

//Hugboxed mags for roundstart vendors.
/obj/item/ammo_box/magazine/toy/smg/hugbox
	hugbox = TRUE

/obj/item/ammo_box/magazine/toy/pistol/hugbox
	hugbox = TRUE

/obj/item/ammo_box/magazine/toy/m762/hugbox
	hugbox = TRUE

/obj/item/ammo_box/magazine/toy/smgm45/hugbox
	hugbox = TRUE

//paintballs
/obj/item/ammo_box/magazine/toy/paintball
	name = "paintball ammo cartridge (red)"
	ammo_type = /obj/item/ammo_casing/paintball
	icon_state = "paintballmag"
	max_ammo = 20

/obj/item/ammo_box/magazine/toy/paintball/blue
	name = "paintball ammo cartridge (blue)"
	ammo_type = /obj/item/ammo_casing/paintball/blue

/obj/item/ammo_box/magazine/toy/paintball/pink
	name = "paintball ammo cartridge (pink)"
	ammo_type = /obj/item/ammo_casing/paintball/pink

/obj/item/ammo_box/magazine/toy/paintball/purple
	name = "paintball ammo cartridge (purple)"
	ammo_type = /obj/item/ammo_casing/paintball/purple

/obj/item/ammo_box/magazine/toy/paintball/orange
	name = "paintball ammo cartridge (orange)"
	ammo_type = /obj/item/ammo_casing/paintball/orange

/obj/item/ammo_casing/paintball
	name = "paintball"
	icon_state = "paintball"
	desc = "A red coloured plastic ball filled with paint."
	color = "#C73232"
	projectile_type = /obj/projectile/bullet/paintball

/obj/item/ammo_casing/paintball/blue
	desc = "A blue coloured plastic ball filled with paint."
	color = "#5998FF"
	projectile_type = /obj/projectile/bullet/paintball/blue

/obj/item/ammo_casing/paintball/pink
	desc = "A pink coloured plastic ball filled with paint."
	color = "#FF69DA"
	projectile_type = /obj/projectile/bullet/paintball/pink

/obj/item/ammo_casing/paintball/purple
	desc = "A purple coloured plastic ball filled with paint."
	color = "#910AFF"
	projectile_type = /obj/projectile/bullet/paintball/purple

/obj/item/ammo_casing/paintball/orange
	desc = "An orange coloured plastic ball filled with paint."
	color = "#FF9326"
	projectile_type = /obj/projectile/bullet/paintball/orange

/obj/projectile/bullet/paintball
	damage = 0
	icon = 'icons/obj/ammo.dmi'
	icon_state = "paintball-live"
	color = "#C73232"

/obj/projectile/bullet/paintball/blue
	color = "#5998FF"

/obj/projectile/bullet/paintball/pink
	color = "#FF69DA"

/obj/projectile/bullet/paintball/purple
	color = "#910AFF"

/obj/projectile/bullet/paintball/orange
	color = "#FF9326"

/obj/projectile/bullet/paintball/on_hit(atom/target, blocked = FALSE)
	if(iscarbon(target))
		var/mob/living/carbon/human/H = target
		var/image/paintoverlay = image('icons/effects/paintball.dmi')
		paintoverlay.color = color
		paintoverlay.icon_state = pick("1","2","3","4","5","6","7")
		H.overlays += paintoverlay
		to_chat(H, span_warning("You feel a sharp sting."))
		H.adjustStaminaLoss(5)
	else if(isturf(target))
		target.color = color //paints walls that it hits with paint