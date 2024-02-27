/obj/structure/closet/crate/mystery_box
	name = "mystery box"
	desc = "A mysterious box that seems to contain limitless guns, for a price."
	icon_state = "trashcart"
	color = "#755716"
	max_integrity = INFINITY
	var/guncost = 950
	var/list/gunlist = list()
	var/list/blacklist = list(/obj/item/gun/energy/laser/instakill, /obj/item/gun/energy/laser/instakill/red, /obj/item/gun/energy/laser/instakill/blue)//guns that should never spawn
	var/opening = FALSE

/obj/structure/closet/crate/mystery_box/Initialize(mapload)
	. = ..()
	gunlist |= subtypesof(/obj/item/gun) //huge fucking list, don't spawn too many of these @hisa
	gunlist -= blacklist

/obj/structure/closet/crate/mystery_box/examine(mob/user)
	. = ..()
	. += span_notice("It costs [guncost ? "[guncost] credits" : "nothing"] to open.")

/obj/structure/closet/crate/mystery_box/open(mob/living/user)
	welded = FALSE 
	if(opened || !can_open(user) || !ishuman(user) || opening)
		return

	if(guncost)
		var/mob/living/carbon/human/H = user
		var/obj/item/card/id/id_card = H.get_idcard()
		if(!id_card)
			H.balloon_alert(H, "Need an id card")
			return
		if(!id_card.registered_account)
			H.balloon_alert(H, "Need a bank account")
			return
		if(id_card.registered_account.account_balance < guncost)
			H.balloon_alert(H, "Not enough money")
			return
		id_card.registered_account.account_balance -= guncost

	add_filter("glowing filter", 2, list("type" = "outline", "color" = "#ffffff", "alpha" = 0, "size" = 2))
	var/filter = get_filter("glowing filter")
	animate(filter, alpha = 150, time = 0.5 SECONDS, loop = -1)
	animate(alpha = 0, time = 0.5 SECONDS)
	opening = TRUE
	playsound(src, 'yogstation/sound/effects/mysterybox.ogg', 60, FALSE)
	sleep(5 SECONDS)

	animate(filter)
	remove_filter("glowing filter")
	opening = FALSE

	var/gunpath = pick(gunlist)
	if(prob(2)) //bypass regular % and just get a raygun, so it's not near impossible to get with how many guns there are
		gunpath = /obj/item/gun/energy/kinetic_accelerator/raygun
	var/obj/item/gun/thing = new gunpath(src)
	
	thing.no_pin_required = TRUE

	playsound(loc, open_sound, 15, 1, -3)
	opened = TRUE
	dump_contents()
	animate_door(FALSE)
	update_appearance(UPDATE_ICON)
	update_airtightness()

	addtimer(CALLBACK(src, PROC_REF(userless_close)), 5 SECONDS, TIMER_UNIQUE)
	
//can't close
/obj/structure/closet/crate/mystery_box/close(mob/living/user)
	return FALSE

/obj/structure/closet/crate/mystery_box/proc/userless_close()
	playsound(loc, close_sound, 15, 1, -3)
	opened = FALSE
	density = TRUE
	animate_door(TRUE)
	update_appearance(UPDATE_ICON)
	update_airtightness()

//cod zombies raygun i guess
/obj/item/gun/energy/kinetic_accelerator/raygun
	name = "Raygun"
	desc = "A self recharging raygun."
	icon = 'yogstation/icons/obj/guns/raygun.dmi'
	lefthand_file = 'yogstation/icons/mob/inhands/weapons/raygun_lefthand.dmi'
	righthand_file = 'yogstation/icons/mob/inhands/weapons/raygun_righthand.dmi'
	icon_state = "raygun"
	item_state = "raygun"
	ammo_type = list(/obj/item/ammo_casing/energy/raygun)
	dry_fire_sound = 'sound/weapons/revolverdry.ogg'
	fire_sound_volume = 130 //the ammo sound effect is very quiet
	can_flashlight = FALSE
	can_bayonet = FALSE
	overheat_time = 10
	max_mod_capacity = 0
	holds_charge = TRUE

/obj/item/gun/energy/kinetic_accelerator/raygun/reload()
	cell.give(cell.maxcharge)
	recharge_newshot(TRUE)
	update_appearance(UPDATE_ICON)
	overheat = FALSE

/obj/item/ammo_casing/energy/raygun
	projectile_type = /obj/projectile/raygun
	select_name = "kinetic"
	e_cost = 500
	fire_sound = 'yogstation/sound/effects/raygun.ogg'
	firing_effect_type = null

/obj/projectile/raygun
	name = "kinetic force"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "kinetic_blast"
	damage = 20
	damage_type = BURN
	armor_flag = RAD
	range = 6
	log_override = TRUE
	color = "#00ff00"

/obj/projectile/raygun/on_range()
	strike_thing()
	..()

/obj/projectile/raygun/on_hit(atom/target)
	strike_thing(target)
	
/obj/projectile/raygun/proc/strike_thing(atom/target)
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		target_turf = get_turf(src)

	for(var/mob/living/L in range(1, target_turf) - firer - target)
		var/armor = L.run_armor_check(def_zone, armor_flag, "", "", armour_penetration)
		L.apply_damage(damage, damage_type, def_zone, armor)
		to_chat(L, span_userdanger("You're struck by a [name]!"))

	//yogs end
	var/obj/effect/temp_visual/kinetic_blast/K = new /obj/effect/temp_visual/kinetic_blast(target_turf)
	K.transform = matrix()*2
	K.color = color

//The zombie in question (probably don't let this get merged if the box is going to be)
#define REGENERATION_DELAY 6 SECONDS  // After taking damage, how long it takes for automatic regeneration to begin
/datum/species/preternis/zombie
	name = "Low-Functioning Preternis"
	id = "preterniszombie"
	limbs_id = "preternis"
	inherent_traits = list(TRAIT_NOBREATH, TRAIT_NOHUNGER, TRAIT_RADIMMUNE, TRAIT_MEDICALIGNORE, TRAIT_NO_BLOOD_REGEN, TRAIT_STABLELIVER, TRAIT_STABLEHEART, TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE, TRAIT_FAKEDEATH, TRAIT_STUNIMMUNE, TRAIT_NODEATH)
	mutanthands = /obj/item/zombie_hand
	var/static/list/spooks = list('sound/hallucinations/growl1.ogg','sound/hallucinations/growl2.ogg','sound/hallucinations/growl3.ogg','sound/hallucinations/veryfar_noise.ogg','sound/hallucinations/wail.ogg')
	armor = 20
	speedmod = 1.6
	changesource_flags = MIRROR_BADMIN //deliberate admin spawn only
	var/heal_rate = 1
	var/regen_cooldown = 0

/datum/species/preternis/zombie/check_roundstart_eligible()
	return FALSE

/datum/species/preternis/zombie/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/human/H, wound_bonus = 0, bare_wound_bonus = 0, sharpness = SHARP_NONE, attack_direction = null)
	. = ..()
	if(.)
		regen_cooldown = world.time + REGENERATION_DELAY

/datum/species/preternis/zombie/spec_life(mob/living/carbon/C)
	. = ..()
	C.a_intent = INTENT_HARM // THE SUFFERING MUST FLOW

	//Zombies never actually die, they just fall down until they regenerate enough to rise back up.
	//They must be restrained, beheaded or gibbed to stop being a threat.
	if(regen_cooldown < world.time)
		var/heal_amt = heal_rate
		if(C.InCritical())
			heal_amt *= 2
		C.heal_overall_damage(heal_amt,heal_amt, 0, BODYPART_ANY)
		C.adjustToxLoss(-heal_amt)
		for(var/i in C.all_wounds)
			var/datum/wound/iter_wound = i
			if(prob(4-iter_wound.severity))
				iter_wound.remove_wound()
	if(!C.InCritical() && prob(5))
		playsound(C, pick(spooks), 50, TRUE, 10)

#undef REGENERATION_DELAY
