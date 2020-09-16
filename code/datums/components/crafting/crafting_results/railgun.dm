/obj/item/gun/ballistic/automatic/railgun
	name = "railgun"
	desc = "A weapon that uses the Lorentz force to propel an armature carrying a projectile to incredible velocities."
	icon = 'icons/obj/vg_items.dmi'
	icon_state = "railgun"
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	item_state = "arg"
	force = 10
	fire_sound = 'sound/weapons/rodgun_fire.ogg'
	can_suppress = FALSE
	burst_size = 1
	actions_types = null
	fire_delay = 15
	spread = 0
	recoil = 0.5
	weapon_weight = WEAPON_MEDIUM
	w_class = WEIGHT_CLASS_BULKY
	spawnwithmagazine = FALSE
	casing_ejector = FALSE
	var/obj/item/stock_parts/cell/cell
	var/obj/item/stock_parts/cell/cell_type = /obj/item/stock_parts/cell
	var/insert_sound = 'sound/weapons/bulletinsert.ogg'

/obj/item/gun/ballistic/automatic/railgun/update_icon()
	icon_state = "railgun"

/obj/item/gun/ballistic/automatic/railgun/Initialize()
	. = ..()
	if(cell_type)
		cell = new cell_type(src)
	else
		cell = new(src)

/obj/item/gun/ballistic/automatic/railgun/attackby(obj/item/A, mob/living/user, params)
	if (!chambered)
		if (istype(A, /obj/item/stack/rods))
			var/obj/item/stack/rods/R = A
			if (R.use(1))
				chambered = new /obj/item/ammo_casing/rod
				var/obj/item/projectile/rod/PR = chambered.BB

				if (PR)
					PR.range = PR.range * (cell.charge/1000 * 3)
					PR.damage = PR.damage * (cell.charge/1000 * 3)
					PR.charge = (cell.charge/1000 * 3)

				playsound(user, insert_sound, 50, 1)

				user.visible_message("<span class='notice'>[user] carefully places the [chambered.BB] into the [src].</span>", \
                                    "<span class='notice'>You carefully place the [chambered.BB] into the [src].</span>")
	else
		to_chat(user, "<span class='warning'>There's already a [chambered.BB] loaded!<span>")

	update_icon()
	return

/obj/item/gun/ballistic/automatic/railgun/attack_self(mob/living/user)
	user.visible_message("<span class='notice'>[user] removes the [chambered.BB] from the [src].</span>", \
						"<span class='notice'>You remove the [chambered.BB] from the [src].</span>")
	user.put_in_hands(new /obj/item/stack/rods)
	chambered = null
	playsound(user, insert_sound, 50, 1)
	update_icon()
	return

/obj/item/gun/ballistic/automatic/railgun/examine(mob/user)
	. = ..()
	if(cell)
		. += "<span class='notice'>[src]'s cell is [round(cell.charge / cell.maxcharge, 0.1) * 100]% full.</span>"
	else
		. += "<span class='notice'>[src] doesn't seem to have a cell!</span>"

/obj/item/gun/ballistic/automatic/railgun/can_shoot()
	. = ..()
	if(QDELETED(cell))
		return 0

	var/obj/item/ammo_casing/rod/shot = chambered
	if(!shot)
		return 0
	if(cell.charge < 200)
		return 0

/obj/item/gun/ballistic/automatic/railgun/shoot_live_shot()
	. = ..()
	cell.use(200)

/obj/item/gun/ballistic/automatic/railgun/emp_act(severity)
	. = ..()
	if(!(. & EMP_PROTECT_CONTENTS))
		cell.use(round(cell.charge / severity))

/obj/item/gun/ballistic/automatic/railgun/get_cell()
	return cell
