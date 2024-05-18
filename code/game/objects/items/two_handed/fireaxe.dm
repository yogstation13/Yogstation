/obj/item/fireaxe
	icon = 'icons/obj/tools.dmi'
	icon_state = "fireaxe0"
	base_icon_state = "fireaxe"
	lefthand_file = 'icons/mob/inhands/weapons/axes_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/axes_righthand.dmi'
	name = "fire axe"
	desc = "Truly, the weapon of a madman. Who would think to fight fire with an axe?"
	force = 5
	throwforce = 15
	demolition_mod = 3 // specifically designed for breaking things
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut", "axed")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP_EDGED
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 30)
	resistance_flags = FIRE_PROOF
	wound_bonus = -15
	bare_wound_bonus = 20

	/// Bonus damage from wielding
	var/force_wielded = 19

/obj/item/fireaxe/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, \
		force_wielded = force_wielded, \
		icon_wielded = "[base_icon_state]1", \
	)
	AddComponent(/datum/component/cleave_attack, arc_size=180, requires_wielded=TRUE) // YEAHHHHH
	AddComponent(/datum/component/butchering, 100, 80, 0 , hitsound) //axes are not known for being precision butchering tools

/obj/item/fireaxe/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]0"

/obj/item/fireaxe/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] axes [user.p_them()]self from head to toe! It looks like [user.p_theyre()] trying to commit suicide!"))
	return (BRUTELOSS)

/obj/item/fireaxe/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(QDELETED(A))
		return
	if(HAS_TRAIT(src, TRAIT_WIELDED) && !HAS_TRAIT(src, TRAIT_CLEAVING)) //destroys shit faster, generally in 1-2 hits.
		if(istype(A, /obj/structure/window))
			var/obj/structure/window/W = A
			W.take_damage(W.max_integrity*2, BRUTE, MELEE, FALSE, null, armour_penetration)
		else if(istype(A, /obj/structure/grille))
			var/obj/structure/grille/G = A
			G.take_damage(G.max_integrity*2, BRUTE, MELEE, FALSE, null, armour_penetration)

/*
 * Metal Hydrogen Axe
 */
/obj/item/fireaxe/metal_h2_axe  // Blatant imitation of the fireaxe, but made out of metallic hydrogen
	icon_state = "metalh2_axe0"
	base_icon_state = "metalh2_axe"
	name = "metallic hydrogen axe"
	desc = "A large, menacing axe made of an unknown substance that the most elder atmosians call Metallic Hydrogen. Truly an otherworldly weapon."
	force_wielded = 18

/*
 * Bone Axe
 */
/obj/item/fireaxe/boneaxe
	icon_state = "bone_axe0"
	base_icon_state = "bone_axe"
	name = "bone axe"
	desc = "A large, vicious axe crafted out of several sharpened bone plates and crudely tied together. Made of monsters, by killing monsters, for killing monsters."
	force_wielded = 18

/*
 * Energy Fire Axe
 */
/obj/item/fireaxe/energy
	name = "energy fire axe"
	desc = "A massive, two handed, energy-based hardlight axe capable of cutting through solid metal. 'Glory to atmosia' is carved on the side of the handle."
	icon = 'icons/obj/weapons/energy.dmi'
	icon_state = "energy-fireaxe0"
	base_icon_state = "energy-fireaxe"
	demolition_mod = 4 // DESTROY
	armour_penetration = 50 // Probably doesn't care much for armor given how it can destroy solid metal structures
	block_chance = 50 // Big handle and large flat energy blade, good for blocking things
	heat = 1800 // It's a FIRE axe
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = "swing_hit"
	light_system = MOVABLE_LIGHT
	light_range = 6 //This is NOT a stealthy weapon
	light_color = "#ff4800" //red-orange
	light_on = FALSE
	sharpness = SHARP_NONE
	resistance_flags = FIRE_PROOF | ACID_PROOF

	force_wielded = 25

	var/w_class_on = WEIGHT_CLASS_BULKY

/obj/item/fireaxe/energy/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, \
		force_wielded = force_wielded, \
		icon_wielded = "[base_icon_state]1", \
		wieldsound = 'sound/weapons/saberon.ogg', \
		unwieldsound = 'sound/weapons/saberoff.ogg', \
		wield_callback = CALLBACK(src, PROC_REF(on_wield)), \
		unwield_callback = CALLBACK(src, PROC_REF(on_unwield)), \
	)

/obj/item/fireaxe/energy/proc/on_wield(obj/item/source, mob/living/carbon/user)
	w_class = w_class_on
	sharpness = SHARP_EDGED
	hitsound = 'sound/weapons/blade1.ogg'
	START_PROCESSING(SSobj, src)
	set_light_on(TRUE)

/obj/item/fireaxe/energy/proc/on_unwield(obj/item/source, mob/living/carbon/user)
	w_class = initial(w_class)
	sharpness = initial(sharpness)
	hitsound = "swing_hit"
	STOP_PROCESSING(SSobj, src)
	set_light_on(FALSE)

/obj/item/fireaxe/energy/attack(mob/living/M, mob/living/user)
	..()
	M.ignite_mob() // Ignites you if you're flammable

/obj/item/fireaxe/energy/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage, attack_type)
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		return 0 // large energy blade can only block stuff if it's actually on
	return ..()

/obj/item/fireaxe/energy/ignition_effect(atom/A, mob/user)
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		return "[user] tries to light [A] with [src] while it's off. Nothing happens."
	playsound(loc, hitsound, get_clamped_volume(), 1, -1)
	return "[user] casually raises [src] up to [user.p_their()] face and lights [A]. Hot damn."

/obj/item/fireaxe/energy/is_hot()
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		return FALSE // Shouldn't be able to ignite stuff if it's off
	return ..()

/obj/item/fireaxe/energy/process()
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		STOP_PROCESSING(SSobj, src)
		return PROCESS_KILL
	open_flame(heat)
