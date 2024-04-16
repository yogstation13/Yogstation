/obj/item/kinetic_javelin_core 
	name = "generic kinetic javelin core"
	desc = "A shiny synthetic gem with wires poking out of it."
	icon = 'yogstation/icons/obj/kinetic_javelin.dmi'
	var/charged_glow_color
	var/javelin_icon_state
	var/javelin_item_state

/obj/item/kinetic_javelin_core/proc/on_insert(obj/item/kinetic_javelin/javelin)
	return

/obj/item/kinetic_javelin_core/proc/on_remove(obj/item/kinetic_javelin/javelin)
	return

/obj/item/kinetic_javelin_core/proc/on_charged(obj/item/kinetic_javelin/javelin) 
	return

/obj/item/kinetic_javelin_core/proc/charged_effect(mob/living/simple_animal/hostile/victim, obj/item/kinetic_javelin/javelin,mob/user)
	return 
 
/obj/item/kinetic_javelin_core/proc/get_effect_description()
	return ""

/obj/item/kinetic_javelin
	name = "kinetic javelin"
	desc = "Powerful thrown weapon best suited to exotic environments. It has a small piece of bluespace lodged inside of it's shaft, hitting a living being while in an exotic environment teleports it straight back to you."
	icon = 'yogstation/icons/obj/kinetic_javelin.dmi'
	lefthand_file = 'yogstation/icons/mob/inhands/lefthand.dmi'
	righthand_file = 'yogstation/icons/mob/inhands/righthand.dmi'
	icon_state = "base"
	item_state = "kinetic_javelin"
	force = 10
	throw_range = 7
	throw_speed = 1
	w_class = WEIGHT_CLASS_NORMAL
	var/unmodified_throwforce = 15
	var/exotic_damage_multiplier = 3 // yes you heard me, it deals 8 times more damage in exotic environments.
	var/obj/item/kinetic_javelin_core/core 	
	var/charges = 0
	var/max_charges = 3
	var/charged = FALSE
	var/always_recall = FALSE

/obj/item/kinetic_javelin/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 60, 110)
	if(core)
		core = new core(src)
		icon_state = core.javelin_icon_state
		item_state = core.javelin_item_state
		core.on_insert(src)

/obj/item/kinetic_javelin/crowbar_act(mob/living/user, obj/item/I)
	if(core)
		to_chat(user,span_notice("You remove the kinetic javelin core."))
		remove_charge()
		core.on_remove(src)
		core.forceMove(get_turf(user))
		core = null
		icon_state = "base"
		item_state = core.javelin_item_state
	else 
		to_chat(user,span_notice("There's no core to remove from the socket."))	

/obj/item/kinetic_javelin/attackby(obj/item/I, mob/living/user, params)
	if(istype(I,/obj/item/kinetic_javelin_core))
		if(core)
			to_chat(user, span_notice("There's already a core installed. Remove it with a crowbar first."))
			return
		if(!user.transferItemToLoc(I,src))
			return 
		to_chat(user, span_notice("Kinetic javelin core installed successfully."))
		core = I
		icon_state = core.javelin_icon_state
		item_state = core.javelin_item_state
		core.on_insert(src)
		return 
	return ..()

/obj/item/kinetic_javelin/examine(mob/user)
	. = ..()
	. += "Successfully striking an enemy with a thrown kinetic javelin increases it's charge. Missing resets charges to 0."
	. += "Cores provide unique effects once the javelin is charged."
	. += "It has currently [charges] charges out of [max_charges] charges."
	if(core)
		. += "You can remove the core using a crowbar."
		. += "Currently installed core : [core.name]."
		. += "Core effect:"
		. += core.get_effect_description()
	else 
		. += "You can insert a core by using it on the javelin."

/obj/item/kinetic_javelin/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!core)
		throwforce = 0 //without a core it is blunt
		return ..()

	var/mob/living/carbon/user = throwingdatum.thrower
	if(ismineralturf(hit_atom))
		var/turf/closed/mineral/M = hit_atom
		M.attempt_drill(user, 0, 1)
		remove_charge()
		return ..()
	
	if(istype(hit_atom,/turf/open/floor/plating/dirt/jungleland))
		var/turf/open/floor/plating/dirt/jungleland/JG = hit_atom
		JG.spawn_rock()
		remove_charge()	
		if(always_recall && user)
			user.put_in_active_hand(src)
		return ..()

	if(istype(hit_atom,/obj/structure/flora))
		qdel(hit_atom)
		remove_charge()
		if(always_recall && user)
			user.put_in_active_hand(src)
		return ..()

	if(lavaland_equipment_pressure_check(get_turf(hit_atom)) && user)
		throwforce = unmodified_throwforce * exotic_damage_multiplier
		if(isliving(hit_atom))
			if(!always_recall)
				user.put_in_active_hand(src)
			charge_up()
			if(charged)
				core.charged_effect(hit_atom,src,user)
		else 
			remove_charge()
	else
		remove_charge() 
		throwforce = unmodified_throwforce

	if(always_recall && user)
		user.put_in_active_hand(src)
		
	return ..()

/obj/item/kinetic_javelin/proc/charge_up()
	if(!core)
		return
	charges += 1 
	if(charges == 3)
		if(!charged)
			add_filter("charge_glow", 2, list("type" = "outline", "color" = core.charged_glow_color, "size" = 2))
		core.on_charged(src)
		charged = TRUE 
		charges = 0

/obj/item/kinetic_javelin/proc/remove_charge()
	charges = 0
	if(charged)
		remove_filter("charge_glow")
	charged = FALSE

/obj/item/kinetic_javelin_core/blue 
	name = "Electrified Kinetic Javelin Core"
	icon_state = "blue_core"
	charged_glow_color = "#00c8ff"
	javelin_icon_state = "blue"
	javelin_item_state = "kinetic_javelin_blue"

/obj/item/kinetic_javelin_core/blue/get_effect_description()
	return "When charged, the next successful hit against an enemy unleashes a surge of electricity that targets all nearby exotic lifeforms." 

/obj/item/kinetic_javelin_core/blue/charged_effect(mob/living/simple_animal/hostile/victim, obj/item/kinetic_javelin/javelin,mob/user)
	for(var/mob/living/simple_animal/hostile/H in range(4,victim) - victim)
		victim.Beam(H,"lightning[rand(1,12)]",time = 15)
		H.adjustFireLoss(15)

/obj/item/kinetic_javelin_core/red 
	name = "Enraged Kinetic Javelin Core"
	icon_state = "red_core"
	charged_glow_color = "#ff7700"
	javelin_icon_state = "red"
	javelin_item_state = "kinetic_javelin_red"

/obj/item/kinetic_javelin_core/red/get_effect_description()
	return "Upon charging it increases the damage of kinetic spear by 25%" 

/obj/item/kinetic_javelin_core/red/charged_effect(mob/living/simple_animal/hostile/victim, obj/item/kinetic_javelin/javelin,mob/user)
	javelin.throwforce += javelin.throwforce * 0.25	

/obj/item/kinetic_javelin_core/green
	name = "Merciful Kinetic Javelin Core"
	icon_state = "green_core"
	charged_glow_color = "#00b61b"
	javelin_icon_state = "green"
	javelin_item_state = "kinetic_javelin_green"

/obj/item/kinetic_javelin_core/green/get_effect_description()
	return "Striking an enemy while charged heals 5 of each damage type." 

/obj/item/kinetic_javelin_core/green/charged_effect(mob/living/simple_animal/hostile/victim, obj/item/kinetic_javelin/javelin,mob/living/user)
	user.adjustFireLoss(-5,FALSE)
	user.adjustBruteLoss(-5,FALSE)
	user.adjustToxLoss(-5,FALSE)
	user.adjustOxyLoss(-5)

/obj/item/kinetic_javelin_core/yellow
	name = "Radiant Kinetic Javelin Core"
	icon_state = "yellow_core"
	charged_glow_color = "#fff700"
	javelin_icon_state = "yellow"
	javelin_item_state = "kinetic_javelin_yellow"

/obj/item/kinetic_javelin_core/yellow/get_effect_description()
	return "Striking an enemy while charged slows that enemy to near standstill for 3 seconds." 

/obj/item/kinetic_javelin_core/yellow/charged_effect(mob/living/simple_animal/hostile/victim, obj/item/kinetic_javelin/javelin,mob/user)
	walk(victim,0)
	victim.move_to_delay = 600
	addtimer(CALLBACK(src,PROC_REF(remove_debuff),victim),3 SECONDS)

/obj/item/kinetic_javelin_core/yellow/proc/remove_debuff(mob/living/simple_animal/hostile/victim)
	if(victim)
		victim.move_to_delay = initial(victim.move_to_delay)

/obj/item/kinetic_javelin_core/purple
	name = "Loyal Kinetic Javelin Core"
	icon_state = "purple_core"
	charged_glow_color = "#900081ff"
	javelin_icon_state = "purple"
	javelin_item_state = "kinetic_javelin_purple"

/obj/item/kinetic_javelin_core/purple/get_effect_description()
	return "Kinetic spear will always be able to be recalled, even when you miss an enemy, but drastically reduces it's flying speed and damage." 

/obj/item/kinetic_javelin_core/purple/on_insert(obj/item/kinetic_javelin/javelin)
	javelin.always_recall = TRUE
	javelin.throw_speed = 0.5
	javelin.exotic_damage_multiplier = 2

/obj/item/kinetic_javelin_core/purple/on_remove(obj/item/kinetic_javelin/javelin)
	javelin.always_recall = FALSE
	javelin.throw_speed = 1
	javelin.exotic_damage_multiplier = 3

/obj/item/kinetic_javelin/blue 
	core = /obj/item/kinetic_javelin_core/blue

/obj/item/kinetic_javelin/green
	core = /obj/item/kinetic_javelin_core/green

/obj/item/kinetic_javelin/red
	core = /obj/item/kinetic_javelin_core/red

/obj/item/kinetic_javelin/yellow
	core = /obj/item/kinetic_javelin_core/yellow

/obj/item/kinetic_javelin/purple
	core = /obj/item/kinetic_javelin_core/purple




