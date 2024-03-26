/*
 * Double-Bladed Energy Swords - Cheridan
 */
/obj/item/melee/dualsaber
	icon = 'icons/obj/weapons/energy.dmi'
	icon_state = "dualsaber0"
	base_icon_state = "dualsaber"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	name = "double-bladed energy sword"
	desc = "A more powerful version on the energy sword, it is more capable of blocking energy projectiles than its single bladed counterpart. 'At last we will have revenge' is carved on the side of the handle."
	force = 3
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	hitsound = "swing_hit"
	armour_penetration = 35
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	block_chance = 75
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 70)
	resistance_flags = FIRE_PROOF
	light_system = MOVABLE_LIGHT
	light_range = 6 //TWICE AS BRIGHT AS A REGULAR ESWORD
	light_color = "#00ff00" //green
	light_on = FALSE
	wound_bonus = -10
	bare_wound_bonus = 20
	var/force_wielded = 31
	var/w_class_on = WEIGHT_CLASS_BULKY
	var/saber_color = "green"
	var/hacked = FALSE
	var/list/possible_colors = list("red", "blue", "green", "purple")

/obj/item/melee/dualsaber/Initialize(mapload)
	. = ..()
	if(LAZYLEN(possible_colors))
		saber_color = pick(possible_colors)
		var/new_color
		switch(saber_color)
			if("red")
				new_color = LIGHT_COLOR_RED
			if("green")
				new_color = LIGHT_COLOR_GREEN
			if("blue")
				new_color = LIGHT_COLOR_LIGHT_CYAN
			if("purple")
				new_color = LIGHT_COLOR_LAVENDER
		set_light_color(new_color)

	AddComponent(/datum/component/two_handed, \
		force_wielded = force_wielded, \
		icon_wielded = "[base_icon_state][saber_color]1", \
		wieldsound = 'sound/weapons/saberon.ogg', \
		unwieldsound = 'sound/weapons/saberoff.ogg', \
		wield_callback = CALLBACK(src, PROC_REF(on_wield)), \
		unwield_callback = CALLBACK(src, PROC_REF(on_unwield)), \
	)
	AddComponent(/datum/component/cleave_attack, arc_size=360, swing_speed_mod=1.5, requires_wielded=TRUE) // lol, lmao even

/obj/item/melee/dualsaber/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/melee/dualsaber/suicide_act(mob/living/carbon/user)
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		user.visible_message(span_suicide("[user] begins spinning way too fast! It looks like [user.p_theyre()] trying to commit suicide!"))

		var/obj/item/bodypart/head/myhead = user.get_bodypart(BODY_ZONE_HEAD)//stole from chainsaw code
		var/obj/item/organ/brain/B = user.getorganslot(ORGAN_SLOT_BRAIN)
		B.organ_flags &= ~ORGAN_VITAL	//this cant possibly be a good idea
		var/randdir
		for(var/i in 1 to 24)//like a headless chicken!
			if(user.is_holding(src))
				randdir = pick(GLOB.alldirs)
				user.Move(get_step(user, randdir),randdir)
				user.emote("spin")
				if (i == 3 && myhead)
					myhead.drop_limb()
				sleep(0.3 SECONDS)
			else
				user.visible_message(span_suicide("[user] panics and starts choking to death!"))
				return OXYLOSS

	else
		user.visible_message(span_suicide("[user] begins beating [user.p_them()]self to death with \the [src]'s handle! It probably would've been cooler if [user.p_they()] turned it on first!"))
	return BRUTELOSS

/obj/item/melee/dualsaber/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]0"
	SEND_SIGNAL(src, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_TYPE_BLOOD)

/obj/item/melee/dualsaber/attack(mob/target, mob/living/carbon/human/user)
	if(user.has_dna())
		if(user.dna.check_mutation(HULK))
			to_chat(user, span_warning("You grip the blade too hard and accidentally close it!"))
			if(HAS_TRAIT(src, TRAIT_WIELDED))
				user.dropItemToGround(src, force=TRUE)
				return
	..()
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && (HAS_TRAIT(src, TRAIT_WIELDED)) && prob(40))
		impale(user)
		return
	if(HAS_TRAIT(src, TRAIT_WIELDED) && prob(50))
		INVOKE_ASYNC(src, PROC_REF(jedi_spin), user)

/obj/item/melee/dualsaber/proc/jedi_spin(mob/living/user)
	for(var/i in list(NORTH,SOUTH,EAST,WEST,EAST,SOUTH,NORTH,SOUTH,EAST,WEST,EAST,SOUTH))
		user.setDir(i)
		if(i == WEST)
			user.emote("flip")
		sleep(0.1 SECONDS)

/obj/item/melee/dualsaber/proc/impale(mob/living/user)
	to_chat(user, span_warning("You twirl around a bit before losing your balance and impaling yourself on [src]."))
	if (force_wielded)
		user.take_bodypart_damage(20,25,check_armor = TRUE)
	else
		user.adjustStaminaLoss(25)

/obj/item/melee/dualsaber/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		return ..()
	return 0

/obj/item/melee/dualsaber/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)  //In case thats just so happens that it is still activated on the groud, prevents hulk from picking it up
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		to_chat(user, span_warning("You can't pick up such dangerous item with your meaty hands without losing fingers, better not to!"))
		return 1

/obj/item/melee/dualsaber/process()
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		if(hacked)
			light_color = pick(LIGHT_COLOR_RED, LIGHT_COLOR_GREEN, LIGHT_COLOR_LIGHT_CYAN, LIGHT_COLOR_LAVENDER)
		open_flame()
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/melee/dualsaber/IsReflect()
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		return TRUE

/obj/item/melee/dualsaber/ignition_effect(atom/A, mob/user)
	// same as /obj/item/melee/transforming/energy, mostly
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		return ""
	var/in_mouth = ""
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.wear_mask)
			in_mouth = ", barely missing [user.p_their()] nose"
	. = span_warning("[user] swings [user.p_their()] [name][in_mouth]. [user.p_they(TRUE)] light[user.p_s()] [user.p_their()] [A.name] in the process.")
	playsound(loc, hitsound, get_clamped_volume(), 1, -1)
	add_fingerprint(user)
	// Light your candles while spinning around the room
	INVOKE_ASYNC(src, PROC_REF(jedi_spin), user)

/obj/item/melee/dualsaber/green
	possible_colors = list("green")

/obj/item/melee/dualsaber/red
	possible_colors = list("red")

/obj/item/melee/dualsaber/blue
	possible_colors = list("blue")

/obj/item/melee/dualsaber/purple
	possible_colors = list("purple")

/obj/item/melee/dualsaber/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(!hacked)
			hacked = TRUE
			to_chat(user, span_warning("2XRNBW_ENGAGE"))
			saber_color = "rainbow"
			update_appearance(UPDATE_ICON)
		else
			to_chat(user, span_warning("It's starting to look like a triple rainbow - no, nevermind."))
		return
	return ..()

/obj/item/melee/dualsaber/proc/on_wield(atom/source, mob/living/carbon/M)
	if(!M.has_dna())
		return
	if(M.dna.check_mutation(HULK))
		to_chat(M, span_warning("You lack the grace to wield this!"))
		return
	sharpness = SHARP_EDGED
	w_class = w_class_on
	hitsound = 'sound/weapons/blade1.ogg'
	START_PROCESSING(SSobj, src)
	set_light_on(TRUE)

/obj/item/melee/dualsaber/proc/on_unwield(atom/source, mob/living/user)
	sharpness = initial(sharpness)
	w_class = initial(w_class)
	hitsound = initial(hitsound)
	STOP_PROCESSING(SSobj, src)
	set_light_on(FALSE)

/obj/item/melee/dualsaber/makeshift
	name = "makeshift double-bladed energy sword"
	desc = "Two energy swords taped crudely together. 'at last we finally get some revenge' is scribbled on the side with crayon."

	force_wielded = 27 //total of 30 to be equal to an esword, it's literally just two duct taped together

/obj/item/melee/dualsaber/makeshift/IsReflect()//only 50% chance to reflect, so it still has the cool effect, but not 100% chance
	if(prob(50))
		return ..()
	return FALSE
