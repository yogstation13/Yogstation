/obj/item/melee/transforming/energy
	hitsound_on = 'sound/weapons/blade1.ogg'
	icon = 'icons/obj/weapons/energy.dmi'
	heat = 3500
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 30)
	resistance_flags = FIRE_PROOF
	light_system = MOVABLE_LIGHT
	light_range = 3
	light_power = 1
	light_on = FALSE
	var/saber_color = null

/obj/item/melee/transforming/energy/Initialize(mapload)
	. = ..()
	if(active)
		START_PROCESSING(SSobj, src)

/obj/item/melee/transforming/energy/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/melee/transforming/energy/suicide_act(mob/user)
	if(!active)
		transform_weapon(user, TRUE)
	user.visible_message(span_suicide("[user] is [pick("slitting [user.p_their()] stomach open with", "falling on")] [src]! It looks like [user.p_theyre()] trying to commit seppuku!"))
	return (BRUTELOSS|FIRELOSS)

/obj/item/melee/transforming/energy/add_blood_DNA(list/blood_dna)
	return FALSE

/obj/item/melee/transforming/energy/is_sharp()
	return active * sharpness

/obj/item/melee/transforming/energy/process()
	open_flame()

/obj/item/melee/transforming/energy/transform_weapon(mob/living/user, supress_message_text)
	. = ..()
	if(.)
		if(active)
			if(saber_color)
				icon_state = "sword[saber_color]"
			START_PROCESSING(SSobj, src)
		else
			STOP_PROCESSING(SSobj, src)
		set_light_on(active)

/obj/item/melee/transforming/energy/is_hot()
	return active * heat

/obj/item/melee/transforming/energy/ignition_effect(atom/A, mob/user)
	if(!active)
		return ""

	var/in_mouth = ""
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.wear_mask)
			in_mouth = ", barely missing [C.p_their()] nose"
	. = span_warning("[user] swings [user.p_their()] [name][in_mouth]. [user.p_they(TRUE)] light[user.p_s()] [user.p_their()] [A.name] in the process.")
	playsound(loc, hitsound, get_clamped_volume(), 1, -1)
	add_fingerprint(user)

/obj/item/melee/transforming/energy/axe
	name = "energy axe"
	desc = "An energized battle axe."
	icon = 'icons/obj/weapons/axe.dmi'
	icon_state = "axe0"
	lefthand_file = 'icons/mob/inhands/weapons/axes_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/axes_righthand.dmi'
	force = 40
	force_on = 150
	throwforce = 25
	throwforce_on = 30
	hitsound = 'sound/weapons/bladeslice.ogg'
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	w_class_on = WEIGHT_CLASS_HUGE
	flags_1 = CONDUCT_1
	armour_penetration = 100
	attack_verb_off = list("attacked", "chopped", "cleaved", "torn", "cut")
	attack_verb_on = list()
	light_color = "#40ceff"

/obj/item/melee/transforming/energy/axe/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] swings [src] towards [user.p_their()] head! It looks like [user.p_theyre()] trying to commit suicide!"))
	return (BRUTELOSS|FIRELOSS)

/obj/item/melee/transforming/energy/sword
	name = "energy sword"
	desc = "A powerful energy-based hardlight sword that is easily stored when not in use. 'May the force be within you' is carved on the side of the handle."
	icon_state = "sword0"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 3
	throwforce = 5
	hitsound = "swing_hit" //it starts deactivated
	attack_verb_off = list("tapped", "poked")
	throw_speed = 3
	throw_range = 5
	sharpness = SHARP_EDGED
	embedding = list("embed_chance" = 75, "embedded_impact_pain_multiplier" = 10)
	armour_penetration = 35
	saber_color = "green"
	var/block_force = 15

/obj/item/melee/transforming/energy/sword/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cleave_attack) // very cool
	AddComponent(/datum/component/blocking, block_force = src.block_force, block_flags = WEAPON_BLOCK_FLAGS|PROJECTILE_ATTACK|REFLECTIVE_BLOCK)
	RegisterSignal(src, COMSIG_ITEM_PRE_BLOCK, PROC_REF(block_check))

/obj/item/melee/transforming/energy/sword/proc/block_check(datum/source, mob/defender)
	if(!active)
		return COMPONENT_CANCEL_BLOCK
	var/datum/component/blocking/block_component = GetComponent(/datum/component/blocking)
	if(!block_component)
		CRASH("[type] was missing its blocking component!")
	if(locate(/obj/structure/table) in get_turf(src))
		block_component.block_force = 50
		defender.say(pick("IT'S OVER!!", "I HAVE THE HIGH GROUND!!"))
	else
		block_component.block_force = block_force
	return NONE

/obj/item/melee/transforming/energy/sword/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/melee/transforming/energy/sword))
		if(HAS_TRAIT(I, TRAIT_NODROP) || HAS_TRAIT(src, TRAIT_NODROP))
			to_chat(user, span_warning("\the [HAS_TRAIT(src, TRAIT_NODROP) ? src : I] is stuck to your hand, you can't attach it to \the [HAS_TRAIT(src, TRAIT_NODROP) ? I : src]!"))
			return
		else
			var/obj/item/melee/dualsaber/makeshift/newSaber = new /obj/item/melee/dualsaber/makeshift(user.loc)
			to_chat(user, span_notice("You crudely attach both [src]s together in order to make a [newSaber]."))
			qdel(I)
			qdel(src)
			return
	return ..()

/obj/item/melee/transforming/energy/sword/transform_weapon(mob/living/user, supress_message_text)
	. = ..()
	if(. && active && saber_color)
		icon_state = "sword[saber_color]"

/obj/item/melee/transforming/energy/sword/cyborg
	saber_color = "red"
	var/hitcost = 50

/obj/item/melee/transforming/energy/sword/cyborg/attack(mob/M, mob/living/silicon/robot/R)
	if(R.cell)
		var/obj/item/stock_parts/cell/C = R.cell
		if(active && !(C.use(hitcost)))
			attack_self(R)
			to_chat(R, span_notice("It's out of charge!"))
			return
		return ..()

/obj/item/melee/transforming/energy/sword/cyborg/saw //Used by medical Syndicate cyborgs
	name = "energy saw"
	desc = "For heavy duty cutting. It has a carbon-fiber blade in addition to a toggleable hard-light edge to dramatically increase sharpness."
	force_on = 30
	force = 18 //About as much as a spear
	hitsound = 'sound/weapons/circsawhit.ogg'
	icon = 'icons/obj/surgery.dmi'
	icon_state = "esaw_0"
	icon_state_on = "esaw_1"
	saber_color = null //stops icon from breaking when turned on.
	hitcost = 75 //Costs more than a standard cyborg esword
	block_force = 10 // not really for blocking
	w_class = WEIGHT_CLASS_NORMAL
	sharpness = SHARP_EDGED
	tool_behaviour = TOOL_SAW
	light_color = "#40ceff"

/obj/item/melee/transforming/energy/sword/cyborg/saw/cyborg_unequip(mob/user)
	if(!active)
		return
	transform_weapon(user, TRUE)

/obj/item/melee/transforming/energy/sword/saber
	var/list/possible_colors = list("red" = LIGHT_COLOR_RED, "blue" = LIGHT_COLOR_LIGHT_CYAN, "green" = LIGHT_COLOR_GREEN, "purple" = LIGHT_COLOR_LAVENDER)
	var/hacked = FALSE

/obj/item/melee/transforming/energy/sword/saber/Initialize(mapload)
	. = ..()
	if(LAZYLEN(possible_colors))
		var/set_color = pick(possible_colors)
		saber_color = set_color
		light_color = possible_colors[set_color]

/obj/item/melee/transforming/energy/sword/saber/process()
	. = ..()
	if(hacked)
		var/set_color = pick(possible_colors)
		light_color = possible_colors[set_color]

/obj/item/melee/transforming/energy/sword/saber/red
	possible_colors = list("red" = LIGHT_COLOR_RED)

/obj/item/melee/transforming/energy/sword/saber/blue
	possible_colors = list("blue" = LIGHT_COLOR_LIGHT_CYAN)

/obj/item/melee/transforming/energy/sword/saber/green
	possible_colors = list("green" = LIGHT_COLOR_GREEN)

/obj/item/melee/transforming/energy/sword/saber/purple
	possible_colors = list("purple" = LIGHT_COLOR_LAVENDER)

/obj/item/melee/transforming/energy/sword/saber/attackby(obj/item/W, mob/living/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(!hacked)
			hacked = TRUE
			saber_color = "rainbow"
			to_chat(user, span_warning("RNBW_ENGAGE"))

			if(active)
				icon_state = "swordrainbow"
				user.update_inv_hands()
		else
			to_chat(user, span_warning("It's already fabulous!"))
	else
		return ..()

/obj/item/melee/transforming/energy/sword/bikehorn
	name = "bike horn"
	desc = "A horn off of a bicycle."
	icon_state = "swordhonk"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	icon_state_on = "swordpink"
	saber_color = null
	light_color = "#ff3399"
	force = 0
	throwforce = 0
	attack_verb = list("HONKED")
	hitsound = null

/obj/item/melee/transforming/energy/sword/bikehorn/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/items/bikehorn.ogg'=1), 50)
	qdel(GetComponent(/datum/component/cleave_attack))

/obj/item/melee/transforming/energy/sword/bikehorn/attack(mob/living/carbon/M, mob/living/carbon/user)
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "honk", /datum/mood_event/honk)
	return ..()

/obj/item/melee/transforming/energy/sword/bikehorn/transform_weapon(mob/living/user, supress_message_text)
	. = ..()
	if(active)
		name += " energy sword"
		desc += " It has a powerful hardlight sword attached to it."
		AddComponent(/datum/component/cleave_attack)
	else
		name = initial(name)
		desc = initial(desc)
		qdel(GetComponent(/datum/component/cleave_attack))

/obj/item/melee/transforming/energy/sword/pirate
	name = "energy cutlass"
	desc = "Arrrr matey."
	icon_state = "cutlass0"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	icon_state_on = "cutlass1"
	saber_color = null
	light_color = "#ff0000"

/obj/item/melee/transforming/energy/blade
	name = "energy blade"
	desc = "A concentrated beam of energy in the shape of a blade. Very stylish... and lethal."
	icon_state = "blade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 30 //Normal attacks deal esword damage
	hitsound = 'sound/weapons/blade1.ogg'
	active = 1
	throwforce = 1 //Throwing or dropping the item deletes it.
	throw_speed = 3
	throw_range = 1
	w_class = WEIGHT_CLASS_BULKY//So you can't hide it in your pocket or some such.
	var/datum/effect_system/spark_spread/spark_system
	sharpness = SHARP_EDGED

//Most of the other special functions are handled in their own files. aka special snowflake code so kewl
/obj/item/melee/transforming/energy/blade/Initialize(mapload)
	. = ..()
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/melee/transforming/energy/blade/Destroy()
	QDEL_NULL(spark_system)
	return ..()

/obj/item/melee/transforming/energy/blade/transform_weapon(mob/living/user, supress_message_text)
	return

/obj/item/melee/transforming/energy/blade/hardlight
	name = "hardlight blade"
	desc = "An extremely sharp blade made out of hard light. Packs quite a punch."
	icon_state = "lightblade"
	item_state = "lightblade"
