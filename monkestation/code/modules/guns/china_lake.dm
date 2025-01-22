/obj/item/gun/ballistic/shotgun/china_lake
	name = "\improper China Lake 40mm"
	desc = "Oh, they're goin' ta have to glue you back together...IN HELL!"
	desc_controls = "ALT-Click to set range. Can be reloaded by CLICK-DRAGGING grenades onto the launcher."

	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/china_lake

	var/target_range = 10
	var/minimum_target_range = 5
	var/maximum_target_range = 30

	icon = 'monkestation/icons/obj/guns/china_lake_obj.dmi'
	icon_state = "china_lake"

	lefthand_file = 'monkestation/icons/mob/inhands/china_lake_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/china_lake_righthand.dmi'
	inhand_icon_state = "china_lake"
	inhand_x_dimension = 32
	inhand_y_dimension = 32

	fire_sound = 'monkestation/sound/misc/china_lake_sfx/china_lake_fire.ogg'
	fire_sound_volume = 100
	rack_sound = 'monkestation/sound/misc/china_lake_sfx/china_lake_rack.ogg'
	rack_delay = 1.5 SECONDS

	drop_sound = 'monkestation/sound/misc/china_lake_sfx/china_lake_drop.ogg'
	pickup_sound = 'monkestation/sound/misc/china_lake_sfx/china_lake_pickup.ogg'

/obj/item/gun/ballistic/shotgun/china_lake/Initialize()
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE, force_unwielded = 10, force_wielded = 10)

/obj/item/gun/ballistic/shotgun/china_lake/examine(mob/user)
	. = ..()
	. += span_notice("The leaf sight is set for: <b>[target_range] tiles</b>.")

/obj/item/gun/ballistic/shotgun/china_lake/AltClick(mob/living/user)
	if(!user.can_perform_action(src, NEED_DEXTERITY))
		return ..()
	var/new_range = tgui_input_number(user, "Please set the range", "Leaf Sight Level", 10, maximum_target_range, minimum_target_range)
	if(!new_range || QDELETED(user) || QDELETED(src) || !usr.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	if(new_range != target_range)
		playsound(src, 'sound/machines/click.ogg', 30, TRUE)
	target_range = new_range
	to_chat(user, "Leaf sight set for [target_range] tiles.")

/obj/item/gun/ballistic/shotgun/china_lake/MouseDrop_T(obj/item/target, mob/living/user, params)
	. = ..()
	if(!istype(target, /obj/item/ammo_casing/a40mm))
		return
	if(!(user.mobility_flags & MOBILITY_USE) || user.stat != CONSCIOUS || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user, target))
		return
	src.attackby(target, user)

/obj/item/ammo_box/magazine/internal/china_lake
	name = "china lake internal magazine"
	ammo_type = /obj/item/ammo_casing/a40mm
	caliber = CALIBER_40MM
	max_ammo = 3
	multiload = FALSE
