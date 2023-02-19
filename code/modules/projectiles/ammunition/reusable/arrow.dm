/obj/item/ammo_casing/reusable/arrow
	name = "arrow"
	desc = "An arrow, typically fired from a bow."
	projectile_type = /obj/item/projectile/bullet/reusable/arrow
	caliber = "arrow"
	icon_state = "arrow"
	item_state = "arrow"
	base_rotation = 45
	force = 5
	throwforce = 5 //If, if you want to throw the arrow since you don't have a bow?
	throw_speed = 3
	sharpness = SHARP_POINTY
	embedding = list("embed_chance" = 25, "embedded_fall_chance" = 0)

	/// List of all attached parts to move to the projectile when fired
	var/list/attached_parts
	/// Attached explosive
	var/obj/item/grenade/explosive
	/// Attached bola
	var/obj/item/restraints/legcuffs/bola/bola
	/// Attached syringe
	var/obj/item/reagent_containers/syringe/syringe
	/// If the arrow is on fire
	var/flaming = FALSE

/obj/item/ammo_casing/reusable/arrow/Initialize()
	RegisterSignal(src, COMSIG_ITEM_EMBEDDED, PROC_REF(on_embed))
	RegisterSignal(src, COMSIG_ITEM_EMBED_TICK, PROC_REF(embed_tick))
	var/list/new_parts
	if(ispath(explosive))
		LAZYADD(new_parts, new explosive())
	if(ispath(bola))
		LAZYADD(new_parts, new bola())
	if(ispath(syringe))
		LAZYADD(new_parts, new syringe())
	..()
	if(LAZYLEN(new_parts))
		CheckParts(new_parts)

/obj/item/ammo_casing/reusable/arrow/update_icon(force_update)
	..()
	cut_overlays()
	if(istype(explosive))
		add_overlay(mutable_appearance(icon, "arrow_explosive[explosive.active ? "_active" : ""]"), TRUE)
	if(istype(bola))
		add_overlay(mutable_appearance(icon, "arrow_bola"), TRUE)
	if(istype(syringe))
		add_overlay(mutable_appearance(icon, "arrow_syringe"), TRUE)
	if(flaming)
		add_overlay(mutable_appearance(icon, "arrow_fire"), TRUE)

/obj/item/ammo_casing/reusable/arrow/examine(mob/user)
	. = ..()
	if(explosive)
		. += "It has [explosive.active ? "an armed " : ""][explosive] attached."
	if(bola)
		. += "It has [bola] attached."
	if(syringe)
		. += "It has [syringe] attached."
	if(LAZYLEN(attached_parts))
		. += "The added parts can be removed with a wirecutter."
	if(flaming)
		. += "It is on fire."

/obj/item/ammo_casing/reusable/arrow/attack_self(mob/user)
	if(istype(explosive))
		explosive.attack_self(user)
		add_fingerprint(user)
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			C.throw_mode_off()
		update_icon()
	return ..()

/obj/item/ammo_casing/reusable/arrow/wirecutter_act(mob/living/user, obj/item/I)
	var/obj/item/projectile/bullet/reusable/arrow/arrow = BB
	if(!istype(arrow))
		return
	if(!LAZYLEN(attached_parts))
		to_chat(user, span_warning("There is nothing to remove!"))
		return
	if(explosive)
		explosive = null
	if(bola)
		bola = null
	for(var/obj/item/part in attached_parts)
		if(!part.forceMove(part.drop_location()))
			qdel(part)
	attached_parts = null
	to_chat(user, span_notice("You remove the attached parts."))

			
/obj/item/ammo_casing/reusable/arrow/CheckParts(list/parts_list)
	var/obj/item/ammo_casing/reusable/arrow/A = locate(/obj/item/ammo_casing/reusable/arrow) in parts_list
	if(A)
		LAZYREMOVE(parts_list, A)
		if(flaming)
			add_flame()
		A.CheckParts(parts_list)
		qdel(src)
	for(var/obj/item/grenade/G in parts_list)
		if(G)
			if(istype(explosive))
				G.forceMove(G.drop_location())
			else
				add_explosive(G)
	for(var/obj/item/restraints/legcuffs/bola/B in parts_list)
		if(B)
			if(istype(bola))
				B.forceMove(B.drop_location())
			else
				add_bola(B)
	for(var/obj/item/reagent_containers/syringe/S in parts_list)
		if(S)
			if(istype(syringe))
				S.forceMove(S.drop_location())
			else
				add_syringe(S)
	for(var/obj/item/restraints/handcuffs/cable/C in parts_list)
		LAZYADD(attached_parts, C)
	..()

/obj/item/ammo_casing/reusable/arrow/proc/add_explosive(obj/item/grenade/new_explosive)
	if(istype(new_explosive))
		explosive = new_explosive
		LAZYADD(attached_parts, new_explosive)
	update_icon()

/obj/item/ammo_casing/reusable/arrow/proc/add_bola(obj/item/restraints/legcuffs/bola/new_bola)
	if(istype(new_bola))
		bola = new_bola
		LAZYADD(attached_parts, new_bola)
	update_icon()

/obj/item/ammo_casing/reusable/arrow/proc/add_syringe(obj/item/reagent_containers/syringe/new_syringe)
	if(istype(new_syringe))
		syringe = new_syringe
		LAZYADD(attached_parts, new_syringe)
	update_icon()

/obj/item/ammo_casing/reusable/arrow/proc/add_flame()
	flaming = TRUE
	update_icon()
	
/obj/item/ammo_casing/reusable/arrow/proc/on_embed(target, mob/living/carbon/embedde)
	if(syringe)
		syringe.embed_inject(target, embedde)
	
/obj/item/ammo_casing/reusable/arrow/proc/embed_tick(target, mob/living/carbon/embedde)
	if(syringe)
		syringe.embed_inject(target, embedde)


// Arrow Subtypes //

/obj/item/ammo_casing/reusable/arrow/wood
	name = "wooden arrow"
	desc = "A wooden arrow, quickly made."
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/wood

/obj/item/ammo_casing/reusable/arrow/ash
	name = "ashen arrow"
	desc = "A wooden arrow tempered by fire. It's tougher, but less likely to embed."
	icon_state = "ashenarrow"
	item_state = "ashenarrow"
	force = 7
	throwforce = 7
	embedding = list("embed_chance" = 15, "embedded_fall_chance" = 0)
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/ash

/obj/item/ammo_casing/reusable/arrow/bone_tipped
	name = "bone-tipped arrow"
	desc = "An arrow made from bone, wood, and sinew. Sturdy and sharp."
	icon_state = "bonetippedarrow"
	item_state = "bonetippedarrow"
	force = 9
	throwforce = 9
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/bone_tipped

/obj/item/ammo_casing/reusable/arrow/bone
	name = "bone arrow"
	desc = "An arrow made from bone and sinew. Better at hunting fauna."
	icon_state = "bonearrow"
	item_state = "bonearrow"
	force = 4
	throwforce = 4
	embedding = list("embed_chance" = 20, "embedded_fall_chance" = 0)
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/bone

/obj/item/ammo_casing/reusable/arrow/chitin
	name = "chitin-tipped arrow"
	desc = "An arrow made from chitin, bone, and sinew. Incredibly potent at puncturing armor and hunting fauna."
	icon_state = "chitinarrow"
	item_state = "chitinarrow"
	armour_penetration = 25 //Ah yes the 25 AP on a 5 force hit
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/chitin

/obj/item/ammo_casing/reusable/arrow/bamboo
	name = "bamboo arrow"
	desc = "An arrow made from bamboo. Incredibly fragile and weak, but prone to shattering in unarmored targets."
	icon_state = "bambooarrow"
	item_state = "bambooarrow"
	force = 3
	throwforce = 3
	armour_penetration = -10
	embedding = list("embed_chance" = 35, "embedded_fall_chance" = 0)
	variance = 10
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/bamboo

/obj/item/ammo_casing/reusable/arrow/bronze
	name = "bronze arrow"
	desc = "An arrow tipped with bronze. Better against armor than iron."
	icon_state = "bronzearrow"
	item_state = "bronzearrow"
	armour_penetration = 10 
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/bronze

/obj/item/ammo_casing/reusable/arrow/glass
	name = "glass arrow"
	desc = "A shoddy arrow with a broken glass shard as its tip. Can break upon impact."
	icon_state = "glassarrow"
	item_state = "glassarrow"
	force = 4
	throwforce = 4
	embedding = list("embed_chance" = 15, "embedded_fall_chance" = 0)
	variance = 5
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/glass

/obj/item/ammo_casing/reusable/arrow/glass/plasma
	name = "plasmaglass arrow"
	desc = "An arrow with a plasmaglass shard affixed to its head. Incredibly capable of puncturing armor."
	icon_state = "plasmaglassarrow"
	item_state = "plasmaglassarrow"
	armour_penetration = 40 //Ah yes the 40 AP on a 4 force hit
	embedding = list("embed_chance" = 25, "embedded_fall_chance" = 0)
	variance = 5
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/glass/plasma

/obj/item/ammo_casing/reusable/arrow/magic
	name = "magic arrow"
	desc = "An arrow made of magic that can track targets, though it can't track those under the effects of anti-magic. Can make a good throwing weapon in a pinch!"
	icon_state = "arrow_magic"
	item_state = "arrow_magic"
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/magic
	force = 12
	throwforce = 20
	embedding = list("embed_chance" = 50, "embedded_fall_chance" = 0)
	/// Causes the arrow to become weaker, as I was told to prevent it from being used against wizards
	var/dulled = FALSE

/obj/item/ammo_casing/reusable/arrow/magic/examine(mob/user)
	. = ..()
	if(dulled)
		. += "It appears to be dulled, and the tracking magic has left it."

/obj/item/ammo_casing/reusable/arrow/magic/ready_proj(atom/target, mob/living/user, quiet, zone_override = "", atom/fired_from)
	. = ..()
	if(!.)
		return

	if(dulled)
		BB.damage = 20
		BB.armour_penetration = -25
		var/obj/item/projectile/bullet/reusable/arrow/arrow = BB
		if(!istype(arrow))
			arrow.embed_chance = 0
	else
		BB.set_homing_target(target)
		var/mob/M = target
		if(istype(M) && M.anti_magic_check(chargecost = 0))
			BB.homing_away = TRUE // And there it goes!

/obj/item/ammo_casing/reusable/arrow/magic/on_land(var/obj/item/projectile/old_projectile)
	dulled = TRUE
	force = 3
	throwforce = 0
	sharpness = SHARP_NONE // It IS dull after all
	. = ..()


// Toy //

/obj/item/ammo_casing/reusable/arrow/toy
	name = "toy arrow"
	desc = "A plastic arrow with a blunt tip covered in velcro to allow it to stick to whoever it hits."
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/toy
	force = 0
	throwforce = 0
	sharpness = SHARP_NONE
	embedding = list(100, 0, 0, 0, 0, 0, 0, 0.5, TRUE)
	taped = TRUE

/obj/item/ammo_casing/reusable/arrow/toy/energy
	name = "toy energy bolt"
	desc = "A deceiving arrow that looks to be lethal, but is a velcro-tipped toy. For use with toy bows."
	icon_state = "arrow_energy"
	item_state = "arrow_toy_energy"
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/toy/energy

/obj/item/ammo_casing/reusable/arrow/toy/disabler
	name = "toy disabler bolt"
	desc = "A toy arrow that looks like a disabler bolt fabricated from a hardlight bow. Tipped with velcro to allow it to stick to targets."
	icon_state = "arrow_disable"
	item_state = "arrow_toy_disable"
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/toy/disabler

/obj/item/ammo_casing/reusable/arrow/toy/pulse
	name = "toy pulse bolt"
	desc = "A plastic, fake arrow that looks like a pulse bolt. A velcro head lets it stick to targets."
	icon_state = "arrow_pulse"
	item_state = "arrow_toy_pulse"
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/toy/pulse

/obj/item/ammo_casing/reusable/arrow/toy/xray
	name = "toy X-ray bolt"
	desc = "A plastic arrow with a blunt tip covered in velcro to allow it to stick to whoever it hits. This one is made to resemble a X-ray bolt from a hardlight bow."
	icon_state = "arrow_xray"
	item_state = "arrow_toy_xray"
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/toy/xray

/obj/item/ammo_casing/reusable/arrow/toy/shock
	name = "toy shock bolt"
	desc = "A plastic arrow with a blunt tip covered in velcro to allow it to stick to whoever it hits. This one is made to resemble a shock bolt from a hardlight bow."
	icon_state = "arrow_shock"
	item_state = "arrow_toy_shock"
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/toy/shock


// Utility //

/obj/item/ammo_casing/reusable/arrow/bola
	bola = /obj/item/restraints/legcuffs/bola

/obj/item/ammo_casing/reusable/arrow/explosive
	explosive = /obj/item/grenade/iedcasing

/obj/item/ammo_casing/reusable/arrow/syringe
	syringe = /obj/item/reagent_containers/syringe/lethal/choral

/obj/item/ammo_casing/reusable/arrow/flaming/Initialize()
	..()
	add_flame()


// Joke? //

/obj/item/ammo_casing/reusable/arrow/supermatter
	name = "supermatter-tipped arrow"
	desc = "An arrow made of a hypernoblium-tipped rod, a shard of supermatter, and poor decision making."
	icon_state = "supermatterarrow"
	item_state = "supermatterarrow"
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/supermatter

/obj/item/ammo_casing/reusable/arrow/supermatter/proc/disintigrate(atom/dusting)
	if(ismob(dusting))
		var/mob/ded = dusting
		if(ded.status_flags & GODMODE)
			return FALSE
		dusting.visible_message(span_danger("As [ded] is impacted by [src], [ded.p_their()] body starts to glow and bursts into flames before flashing into dust!"),\
				span_userdanger("You are hit by [src], and start to glow. Uh oh."),\
				span_italics("Everything suddenly goes silent."))
		radiation_pulse(src, 500, 2)
		ded.dust()
		playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, 1)
		return TRUE

	else if(isobj(dusting))
		dusting.visible_message(span_danger("As [dusting] is impacted by [src], [dusting.p_they()] burned into your eyes before disapearing into nothing!"))
		radiation_pulse(src, 100, 2)
		qdel(dusting)
		playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, 1)
		return TRUE

	else if(isturf(dusting))
		var/turf/T = dusting
		var/oldtype = T.type
		var/oldname = T.name
		var/turf/newT = T.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
		if(newT.type == oldtype)
			return FALSE
		dusting.visible_message(span_danger("As [oldname] is impacted by [src], its image is burned into your eyes before disapearing into nothing!"))
		radiation_pulse(src, 50, 2)
		playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, 1)
		return TRUE

/obj/item/ammo_casing/reusable/arrow/supermatter/sliver
	name = "supermatter sliver arrow"
	desc = "An arrow made of a hypernoblium tipped rod, a sliver of supermatter, and poor decision making. It looks like it will only survive one hit."

/obj/item/ammo_casing/reusable/arrow/supermatter/sliver/disintigrate(atom/dusting)
	. = ..()
	if(.)
		qdel(src)

/obj/item/ammo_casing/reusable/arrow/singulo
	name = "singularity shard arrow"
	desc = "An arrow with a shard of a singularity at the end. It radiates a small amout of radiation and slightly pulls you towards it."
	icon_state = "singuloarrow"
	item_state = "singuloarrow"
	force = 4
	throwforce = 4
	embedding = list("embed_chance" = 15, "embedded_fall_chance" = 0)
	variance = 5
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/singulo
	/// The shard currently in the arrow
	var/obj/item/singularity_shard/shard

/obj/item/ammo_casing/reusable/arrow/singulo/Initialize()
	..()
	if(ispath(shard))
		CheckParts(list(new shard()))

/obj/item/ammo_casing/reusable/arrow/singulo/CheckParts(list/parts_list)
	var/obj/item/singularity_shard/new_shard = locate(/obj/item/singularity_shard) in parts_list
	if(!new_shard)
		if(!shard) // No shard, no point in having the arrow
			qdel(src)
		return ..()

	if(istype(shard))
		new_shard.forceMove(new_shard.drop_location())
	else
		new_shard.forceMove(src)
		shard = new_shard
		update_icon()
	..()

/obj/item/ammo_casing/reusable/arrow/singulo/update_icon(force_update)
	..()
	if(istype(shard))
		add_overlay(mutable_appearance(icon, "[icon_state]_[shard.icon_state]"), TRUE)

/obj/item/ammo_casing/reusable/arrow/singulo/proc/shard_effect()
	if(!shard)
		qdel(src)
		return
	var/break_chance = 0
	var/rads_released = 0
	switch(shard.type)
		if(/obj/item/singularity_shard/stage1)
			break_chance = 0.1
			rads_released = 100
		if(/obj/item/singularity_shard/stage2)
			break_chance = 0.5
			rads_released = 200
			empulse(src, 0, 1)
		if(/obj/item/singularity_shard/stage3)
			break_chance = 1.5
			rads_released = 500
			empulse(src, 0, 3)
		if(/obj/item/singularity_shard/stage4)
			break_chance = 5
			rads_released = 1000
			empulse(src, 1, 5)
		if(/obj/item/singularity_shard/stage5)
			break_chance = 10
			rads_released = 2000
			empulse(src, 2, 7)
		if(/obj/item/singularity_shard/stage6)
			break_chance = 100
			rads_released = 3000
			empulse(src, 5, 15) // Its going to break open into a singulo anyways, may as well add some fireworks

	if(rads_released)
		radiation_pulse(src, rads_released, RAD_DISTANCE_COEFFICIENT * 0.5)
	if(prob(break_chance))
		playsound(src, "shatter", 70, 1)
		if(shard.all_powerful)
			new /obj/singularity(get_turf(src), 100)
			visible_message(span_danger("\The [shard] shatters on impact, releasing a singularity!"))
		else
			visible_message(span_danger("\The [shard] shatters on impact!"))

/obj/item/ammo_casing/reusable/arrow/singulo/shard6
	shard = /obj/item/singularity_shard/stage6

// Hardlight //

/obj/item/ammo_casing/reusable/arrow/energy
	name = "energy bolt"
	desc = "An arrow made from hardlight."
	icon_state = "arrow_energy"
	item_flags = DROPDEL
	embedding = list("embedded_pain_chance" = 0, "embedded_pain_multiplier" = 0, "embedded_unsafe_removal_pain_multiplier" = 0, "embedded_pain_chance" = 0, "embedded_fall_chance" = 0)
	projectile_type = /obj/item/projectile/energy/arrow

	var/ticks = 0
	var/tick_max = 10
	var/tick_damage = 1
	var/tick_damage_type = FIRE
	var/tick_sound = 'sound/effects/sparks4.ogg'

/obj/item/ammo_casing/reusable/arrow/energy/Initialize()
	RegisterSignal(src, COMSIG_ITEM_EMBED_REMOVAL, PROC_REF(on_embed_removal))
	..()

/obj/item/ammo_casing/reusable/arrow/energy/proc/on_embed_removal(mob/living/carbon/human/embedde)
	return COMSIG_ITEM_QDEL_EMBED_REMOVAL

/obj/item/ammo_casing/reusable/arrow/energy/on_embed(mob/living/carbon/embedde)
	return

/obj/item/ammo_casing/reusable/arrow/energy/embed_tick(target, mob/living/carbon/human/embedde, obj/item/bodypart/part)
	if(ticks >= tick_max)
		embedde.remove_embedded_object(src, , TRUE, TRUE)
		return
	ticks++
	playsound(embedde, tick_sound , 10, 0)
	embedde.apply_damage(tick_damage, BB.damage_type, part.body_zone)

/obj/item/ammo_casing/reusable/arrow/energy/disabler
	name = "disabler bolt"
	desc = "An arrow made from hardlight. This one stuns the victim in a non-lethal way."
	icon_state = "arrow_disable"
	projectile_type = /obj/item/projectile/energy/arrow/disabler
	harmful = FALSE
	tick_damage_type = STAMINA
	
/obj/item/ammo_casing/reusable/arrow/energy/pulse
	name = "pulse bolt"
	desc = "An arrow made from hardlight. This one eliminates any obstructions it hits."
	icon_state = "arrow_pulse"
	projectile_type = /obj/item/projectile/energy/arrow/pulse
	tick_damage = 5

/obj/item/ammo_casing/reusable/arrow/energy/xray
	name = "X-ray bolt"
	desc = "An arrow made from hardlight. This one can pass through obstructions."
	icon_state = "arrow_xray"
	projectile_type = /obj/item/projectile/energy/arrow/xray
	tick_damage_type = TOX

/obj/item/ammo_casing/reusable/arrow/energy/shock
	name = "shock bolt"
	desc = "An arrow made from hardlight. This one shocks the victim with harmless energy capable of stunning them."
	icon_state = "arrow_shock"
	projectile_type = /obj/item/projectile/energy/arrow/shock
	harmful = FALSE
	tick_damage_type = STAMINA

/obj/item/ammo_casing/reusable/arrow/energy/clockbolt
	name = "redlight bolt"
	desc = "An arrow made from a strange energy."
	projectile_type = /obj/item/projectile/energy/arrow/clockbolt
