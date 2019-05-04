/* ************************
	Sorry for the weird ASCII art headers, my mind was breaking trying to navigate the file.
   ************************/ 

/* ************************
	DEFINES
   ************************/ 

#define NO_GEMS 0
#define SPACE_GEM (1<<0)
#define TIME_GEM (1<<1)
#define MIND_GEM (1<<2)
#define SOUL_GEM (1<<3)
#define POWER_GEM (1<<4)
#define REALITY_GEM (1<<5)
#define ALL_GEMS (SPACE_GEM | TIME_GEM | MIND_GEM | SOUL_GEM | POWER_GEM | REALITY_GEM)

#define isinfinitygauntlet(A) (istype(A,/obj/item/storage/infinity_gauntlet))

/* ************************
	GAUNTLET
   ************************/ 

/datum/component/storage/concrete/infinity_gauntlet //TODO: probably put into another file
	rustle_sound = FALSE
	max_items = 6
	can_hold = typecacheof(list(
		obj/item/infinity_gem
	))

/datum/component/storage/concrete/infinity_gauntlet/handle_item_insertion(obj/item/I, prevent_warning = FALSE, mob/living/user)
	var/obj/item/infinity_gem/gem = I
	gem.add_gem(user)
	. = ..()

//don't need to do remove_from_storage because storage already calls dropped in there

/obj/item/storage/infinity_gauntlet
	name = "Infinity Gauntlet"
	desc = "A gauntlet which holds the infinity gems."
	siemens_coefficient = 0
	strip_delay = 100
	equip_delay_self = 20
	permeability_coefficient = 0
	body_parts_covered = HAND_LEFT
	slot_flags = ITEM_SLOT_GLOVES
	component_type = /datum/component/storage/concrete/infinity_gauntlet

/obj/item/storage/infinity_gauntlet/update_icon() //copy/pasted from belts mostly
	cut_overlays()
	if(content_overlays)
		for(var/I in contents)
			var/obj/item/infinity_gem/gem = I //can't hold anything else, so this is fine
			var/mutable_appearance/M = gem.get_gauntlet_overlay()
			add_overlay(M)
	..()

/obj/item/storage/infinity_gauntlet/equipped(mob/user,slot)
	if(slot == SLOT_GLOVES)
		add_gems_to_owner(user)
	else
		remove_gems_from_owner(user)

/obj/item/storage/infinity_gauntlet/dropped(mob/user)
	. = ..()
	remove_gems_from_owner(user)

/obj/item/storage/infinity_gauntlet/proc/remove_gems_from_owner(mob/user)
	for(var/I in contents)
		var/obj/item/infinity_gem/gem = I
		gem.remove_gem(user)

/obj/item/storage/infinity_gauntlet/proc/add_gems_to_owner(mob/user)
	for(var/I in contents)
		var/obj/item/infinity_gem/gem = I
		gem.add_gem(user)

/* ************************
	BASE GEM CLASS
   ************************/ 

/obj/item/infinity_gem
	name = "Infinity Gem"
	desc = "You shouldn't see this!"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/turf/lastlocation //if the wizard can't track 'em, it's too hard!

/obj/item/infinity_gem/equipped(mob/user,slot)
	. = ..()
	if(slot == SLOT_HANDS)
		gem_add(user)
	else
		gem_remove(user)

/obj/item/infinity_gem/dropped(mob/user)
	. = ..()
	gem_remove(user)

/obj/item/infinity_gem/proc/add_gem()
	return //nothing here, defined in each gem

/obj/item/infinity_gem/proc/remove_gem()
	return

/obj/item/infinity_gem/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/stationloving, true) //obviously could make admins not informed but i don't see the point


/* ************************
	SPACE GEM
   ************************/ 

/obj/effect/proc_holder/spell/targeted/area_teleport/space_gem
	name = "Space Gem Teleport"
	desc = "Use the gem to teleport you to an area of your selection."
	charge_max = 200
	sound1 = 'sound/magic/teleport_diss.ogg'
	sound2 = 'sound/magic/teleport_app.ogg'

/obj/effect/proc_holder/spell/targeted/area_teleport/space_gem/self
	name = "Space Gem Teleport (self)"
	range = -1
	include_user = TRUE

/obj/effect/proc_holder/spell/targeted/area_teleport/space_gem/other
	name = "Space Gem Teleport (other)"
	desc = "Use the space gem to teleport someone else to an area of your selection."
	range = 10
	include_user = FALSE

obj/item/infinity_gem/space_gem
	name = "Space Gem"
	desc = "A gem that allows the holder to be anywhere at any time."
	var/gauntlet_flag = SPACE_GEM
	var/obj/effect/proc_holder/spell/targeted/area_teleport/space_gem/self/teleport_self
	var/obj/effect/proc_holder/spell/targeted/area_teleport/space_gem/other/teleport_other
	var/obj/effect/proc_holder/spell/targeted/turf_teleport/space_gem/mass_blink

obj/item/infinity_gem/space_gem/Initialize()
	. = ..()
	teleport_self = new obj/effect/proc_holder/spell/targeted/area_teleport/space_gem/self
	teleport_other = new obj/effect/proc_holder/spell/targeted/area_teleport/space_gem/other
	mass_blink = new obj/effect/proc_holder/spell/targeted/turf_teleport/space_gem/mass_blink
	
obj/item/infinity_gem/space_gem/equipped(mob/user,slot)


obj/item/infinity_gem/space_gem/gem_add(mob/user)
	. = ..()
	if(user.mind)
		user.mind.AddSpell(teleport_self)
		user.mind.AddSpell(teleport_other)
		user.mind.AddSpell(mass_blink)
	else
		user.AddSpell(teleport_self)
		user.AddSpell(teleport_other)
		user.AddSpell(mass_blink)

obj/item/infinity_gem/space_gem/gem_remove(mob/user)
	if(user.mind)
		user.mind.RemoveSpell(teleport_self)
		user.mind.RemoveSpell(teleport_other)
		user.mind.RemoveSpell(mass_blink)
	else
		user.RemoveSpell(teleport_self)
		user.RemoveSpell(teleport_other)
		user.RemoveSpell(mass_blink)

/* ************************
	TIME GEM
   ************************/ 

//this is incomplete, finish later, it's 5 am christ
