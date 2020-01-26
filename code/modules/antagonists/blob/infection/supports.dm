/datum/support_callin
	var/name = "test"
	var/desc = "test"
	var/cost = 0
	var/item = /obj/item
	var/id = "test"

/datum/support_callin/proc/Purchase(crew2, user)
	if(!istype(crew2, /datum/infection_crew))
		return FALSE
	var/datum/infection_crew/crew = crew2
	if(crew.orbital_points >= cost)
		crew.orbital_points -= cost
		var/obj/item/ourItem = new item()
		var/obj/structure/closet/supplypod/bluespacepod/pod = new()
		pod.explosionSize = list(0,0,0,0)
		ourItem.forceMove(pod)
		new /obj/effect/DPtarget(get_turf(user), pod)
		return TRUE
	else
		return FALSE

/datum/support_callin/ammo
	name = "Additional Ammo"
	desc = "Sends down 10 extra magazines of regular ammunition"
	cost = 1
	item = /obj/item/storage/backpack/duffelbag/infection/ammo/big
	id = "ammo_1"

/obj/item/storage/backpack/duffelbag/infection/ammo/big
	name = "ammo duffel bag"
	desc = "A large duffel bag for holding ammo."

/obj/item/storage/backpack/duffelbag/infection/ammo/big/PopulateContents()
	new /obj/item/ammo_box/magazine/m556/infection(src)
	new /obj/item/ammo_box/magazine/m556/infection(src)
	new /obj/item/ammo_box/magazine/m556/infection(src)
	new /obj/item/ammo_box/magazine/m556/infection(src)
	new /obj/item/ammo_box/magazine/m556/infection(src)
	new /obj/item/ammo_box/magazine/m556/infection(src)
	new /obj/item/ammo_box/magazine/m556/infection(src)
	new /obj/item/ammo_box/magazine/m556/infection(src)
	new /obj/item/ammo_box/magazine/m556/infection(src)
	new /obj/item/ammo_box/magazine/m556/infection(src)

/datum/support_callin/firstaid
	name = "First Aid"
	desc = "Sends down 5 first aid kits"
	cost = 1
	item = /obj/item/storage/backpack/duffelbag/infection/firstaid
	id = "firstaid_1"


/obj/item/storage/backpack/duffelbag/infection/firstaid
	name = "first aid duffel bag"
	desc = "A large duffel bag for first aid kits"

/obj/item/storage/backpack/duffelbag/infection/firstaid/PopulateContents()
	new /obj/item/storage/firstaid/regular(src)
	new /obj/item/storage/firstaid/regular(src)
	new /obj/item/storage/firstaid/regular(src)
	new /obj/item/storage/firstaid/regular(src)
	new /obj/item/storage/firstaid/regular(src)

/datum/support_callin/bulldog
	name = "Bulldog Shotgun"
	desc = "Sends down 3 bulldog shotguns"
	cost = 2
	item = /obj/item/storage/backpack/duffelbag/infection/bulldog
	id = "bulldog"


/obj/item/storage/backpack/duffelbag/infection/bulldog
	name = "buldog duffel bag"
	desc = "A large duffel bag for shotguns"

/obj/item/storage/backpack/duffelbag/infection/bulldog/PopulateContents()
	new /obj/item/gun/ballistic/shotgun/bulldog/unrestricted(src)
	new /obj/item/gun/ballistic/shotgun/bulldog/unrestricted(src)
	new /obj/item/gun/ballistic/shotgun/bulldog/unrestricted(src)

/datum/support_callin/bulldog
	name = "Bulldog Shotgun"
	desc = "Sends down 3 bulldog shotguns"
	cost = 2
	item = /obj/item/storage/backpack/duffelbag/infection/bulldog
	id = "bulldog"

/datum/support_callin/medbeam
	name = "Medbeam"
	desc = "Sends down 1 MedBeam"
	cost = 2
	item = /obj/item/gun/medbeam
	id = "medbeam"


/datum/support_callin/durand
	name = "Durand"
	desc = "Sends down 1 Durand exosuit"
	cost = 4
	item = /obj/mecha/combat/durand
	id = "durand"


/datum/support_callin/durand_gun
	name = "Durand LMG"
	desc = "Sends down 1 LMG for a Durand"
	cost = 2
	item = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg
	id = "durand_lmg"


/datum/support_callin/durand_gun_ammo
	name = "Durand LMG Ammo"
	desc = "Sends down 1 box of LMG ammo for a Durand"
	cost = 2
	item = /obj/item/mecha_ammo/lmg
	id = "durand_lmg_ammo"

/datum/support_callin/metal
	name = "50x metal"
	desc = "Sends down 50 metal sheets"
	cost = 1
	item = /obj/item/stack/sheet/metal/fifty
	id = "metal"

/datum/support_callin/plasteel
	name = "50x Plasteel"
	desc = "Sends down 50 plasteel sheets"
	cost = 2
	item = /obj/item/stack/sheet/plasteel/fifty
	id = "plas"