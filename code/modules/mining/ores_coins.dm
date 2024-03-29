
#define GIBTONITE_QUALITY_HIGH 3
#define GIBTONITE_QUALITY_MEDIUM 2
#define GIBTONITE_QUALITY_LOW 1

#define ORESTACK_OVERLAYS_MAX 10

#define COINSTACK_MAX 8

/**********************Mineral ores**************************/

/obj/item/stack/ore
	name = "rock"
	icon = 'icons/obj/mining.dmi'
	icon_state = "ore"
	item_state = "ore"
	full_w_class = WEIGHT_CLASS_BULKY
	singular_name = "ore chunk"
	var/points = 0 //How many points this ore gets you from the ore redemption machine
	var/refined_type = null //What this ore defaults to being refined into
	novariants = TRUE // Ore stacks handle their icon updates themselves to keep the illusion that there's more going
	var/list/stack_overlays
	var/eaten_text

/obj/item/stack/ore/update_overlays()
	. = ..()
	var/difference = min(ORESTACK_OVERLAYS_MAX, amount) - (LAZYLEN(stack_overlays)+1)
	if(difference == 0)
		return
	else if(difference < 0 && LAZYLEN(stack_overlays))			//amount < stack_overlays, remove excess.
		if (LAZYLEN(stack_overlays)-difference <= 0)
			stack_overlays = null;
		else
			stack_overlays.len += difference
	else if(difference > 0)			//amount > stack_overlays, add some.
		for(var/i in 1 to difference)
			var/mutable_appearance/newore = mutable_appearance(icon, icon_state)
			newore.pixel_x = rand(-8,8)
			newore.pixel_y = rand(-8,8)
			LAZYADD(stack_overlays, newore)
	if (stack_overlays)
		. += stack_overlays

/obj/item/stack/ore/welder_act(mob/living/user, obj/item/I)
	if(!refined_type)
		return TRUE

	if(I.use_tool(src, user, 0, volume=50, amount=15))
		new refined_type(drop_location())
		use(1)

	return TRUE

/obj/item/stack/ore/fire_act(exposed_temperature, exposed_volume)
	. = ..()
	if(isnull(refined_type))
		return
	else
		var/probability = (rand(0,100))/100
		var/burn_value = probability*amount
		var/amountrefined = round(burn_value, 1)
		if(amountrefined < 1)
			qdel(src)
		else
			new refined_type(drop_location(),amountrefined)
			qdel(src)

/obj/item/stack/ore/attack(mob/living/M, mob/living/user)
	if(user.a_intent == INTENT_HARM || M != user || !ishuman(user))
		return ..()

	var/mob/living/carbon/human/H = user
	var/obj/item/organ/stomach/S = H.getorganslot(ORGAN_SLOT_STOMACH)

	if(!istype(S, /obj/item/organ/stomach/cell/preternis))//need a fancy stomach for it
		return ..()

	if(!get_location_accessible(H, BODY_ZONE_PRECISE_MOUTH))
		to_chat(H, span_notice("You can't eat with your mouth covered!"))
		return

	if(!eaten(H))
		to_chat(H, span_notice("You don't feel like eating this ore."))
		return

	use(1)//only eat one at a time

	if(eaten_text)
		H.visible_message(span_notice("[H] takes a bite of [src], crunching happily."), span_notice(eaten_text))
	playsound(H, 'sound/items/eatfood.ogg', 50, 1)

	if(HAS_TRAIT(H, TRAIT_VORACIOUS))//I'M VERY HONGRY
		H.changeNext_move(CLICK_CD_MELEE * 0.5)

/obj/item/stack/ore/proc/eaten(mob/living/carbon/human/H)//override to give certain ores effects when eaten, return true for it to consume stacks
	return FALSE

/obj/item/stack/ore/uranium
	name = "uranium ore"
	icon_state = "Uranium ore"
	item_state = "Uranium ore"
	singular_name = "uranium ore chunk"
	points = 30
	materials = list(/datum/material/uranium=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/uranium
	eaten_text = "The uranium ore tingles a bit as it goes down."

/obj/item/stack/ore/uranium/eaten(mob/living/carbon/human/H)
	radiation_pulse(H, 100)
	return TRUE

/obj/item/stack/ore/iron
	name = "iron ore"
	icon_state = "Iron ore"
	item_state = "Iron ore"
	singular_name = "iron ore chunk"
	points = 1
	materials = list(/datum/material/iron=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/metal
	eaten_text = "You take a bite of iron ore, minerals do a body good."

/obj/item/stack/ore/iron/eaten(mob/living/carbon/human/H)
	H.heal_overall_damage(2, 0, 0, BODYPART_ROBOTIC)
	return TRUE

/obj/item/stack/ore/glass
	name = "sand pile"
	icon_state = "Glass ore"
	item_state = "Glass ore"
	singular_name = "sand pile"
	points = 1
	materials = list(/datum/material/glass=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/glass
	w_class = WEIGHT_CLASS_TINY
	eaten_text = "The glass bits in the sand scratch your throat as you eat them."

GLOBAL_LIST_INIT(sand_recipes, list(\
		new /datum/stack_recipe("sandstone", /obj/item/stack/sheet/mineral/sandstone, 1, 1, 50)\
		))

/obj/item/stack/ore/glass/eaten(mob/living/carbon/human/H)
	H.apply_damage(2, BRUTE, BODY_ZONE_HEAD)
	H.heal_overall_damage(0, 1, 0, BODYPART_ROBOTIC)
	return TRUE

/obj/item/stack/ore/glass/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.sand_recipes
	. = ..()

/obj/item/stack/ore/glass/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(..() || !ishuman(hit_atom))
		return
	var/mob/living/carbon/human/C = hit_atom
	if(C.is_eyes_covered())
		C.visible_message(span_danger("[C]'s eye protection blocks the sand!"), span_warning("Your eye protection blocks the sand!"))
		return
	C.adjust_eye_blur(6)
	C.adjustStaminaLoss(15)//the pain from your eyes burning does stamina damage
	C.adjust_confusion(5 SECONDS)
	to_chat(C, span_userdanger("\The [src] gets into your eyes! The pain, it burns!"))
	qdel(src)

/obj/item/stack/ore/glass/ex_act(severity, target)
	if (severity == EXPLODE_NONE)
		return
	qdel(src)

/obj/item/stack/ore/glass/basalt
	name = "volcanic ash"
	icon_state = "volcanic_sand"
	icon_state = "volcanic_sand"
	singular_name = "volcanic ash pile"

/obj/item/stack/ore/plasma
	name = "plasma ore"
	icon_state = "Plasma ore"
	item_state = "Plasma ore"
	singular_name = "plasma ore chunk"
	points = 15
	materials = list(/datum/material/plasma=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/plasma
	eaten_text = "You take a bite of plasma ore, you feel energized."

/obj/item/stack/ore/plasma/eaten(mob/living/carbon/human/H)
	H.heal_overall_damage(0, 2, 0, BODYPART_ROBOTIC)
	return TRUE

/obj/item/stack/ore/plasma/welder_act(mob/living/user, obj/item/I)
	to_chat(user, span_warning("You can't hit a high enough temperature to smelt [src] properly!"))
	return TRUE

/obj/item/stack/ore/silver
	name = "silver ore"
	icon_state = "Silver ore"
	item_state = "Silver ore"
	singular_name = "silver ore chunk"
	points = 16
	materials = list(/datum/material/silver=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/silver
	eaten_text = "You eat some silver ore, you're pretty sure this is healthy or something."

/obj/item/stack/ore/silver/eaten(mob/living/carbon/human/H)
	if(prob(1))//can cure viruses if you either get really lucky or eat a lot
		for(var/thing in H.diseases)
			var/datum/disease/D = thing
			D.cure()
	else
		H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2)//eating too much silver can cause brain problems
	return TRUE

/obj/item/stack/ore/gold
	name = "gold ore"
	icon_state = "Gold ore"
	icon_state = "Gold ore"
	singular_name = "gold ore chunk"
	points = 18
	materials = list(/datum/material/gold=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/gold
	eaten_text = "As you eat the gold ore, you think it almost looks like butter."

/obj/item/stack/ore/gold/eaten(mob/living/carbon/human/H)
	return TRUE //what do you expect? it's an inert metal

/obj/item/stack/ore/diamond
	name = "diamond ore"
	icon_state = "Diamond ore"
	item_state = "Diamond ore"
	singular_name = "diamond ore chunk"
	points = 50
	materials = list(/datum/material/diamond=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/diamond
	eaten_text = "The diamonds, while \"tasty\" leaves a weird sensation throughout your body."
					
/obj/item/stack/ore/diamond/eaten(mob/living/carbon/human/H)
	H.apply_status_effect(STATUS_EFFECT_DIAMONDSKIN)	
	return TRUE

/obj/item/stack/ore/bananium
	name = "bananium ore"
	icon_state = "Bananium ore"
	item_state = "Bananium ore"
	singular_name = "bananium ore chunk"
	points = 60
	materials = list(/datum/material/bananium=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/bananium

/obj/item/stack/ore/bananium/eaten(mob/living/carbon/human/H)//why are you eating bananium ore?
	H.visible_message(span_notice("[H] takes a bite of [src], crunching happily."), span_userdanger("The [src] rapidly starts permeating you until there's nothing left!"))
	H.emote("scream")
	playsound(H, 'sound/effects/supermatter.ogg', 100)
	var/petrified = H.petrify(5 MINUTES, TRUE)
	if(petrified)
		var/obj/structure/statue/petrified/statue = petrified
		statue.name = "bananium plated [statue.name]"
		statue.desc = "An incredibly lifelike bananium carving."
		statue.add_atom_colour("#ffd700", FIXED_COLOUR_PRIORITY)
		statue.modify_max_integrity(9999, can_break=FALSE)
	return TRUE

/obj/item/stack/ore/titanium
	name = "titanium ore"
	icon_state = "Titanium ore"
	item_state = "Titanium ore"
	singular_name = "titanium ore chunk"
	points = 50
	materials = list(/datum/material/titanium=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/titanium

/obj/item/stack/ore/slag
	name = "slag"
	desc = "Completely useless."
	icon_state = "slag"
	item_state = "slag"
	singular_name = "slag chunk"
	eaten_text = "This slag is the most utterly vile thing you've ever eaten."
	
/obj/item/stack/ore/slag/eaten(mob/living/carbon/human/H)
	H.adjust_disgust(30)
	return TRUE

/obj/item/melee/gibtonite
	name = "gibtonite ore"
	desc = "Extremely explosive if struck with mining equipment, Gibtonite is often used by miners to speed up their work by using it as a mining charge. This material is illegal to possess by unauthorized personnel under space law."
	icon = 'icons/obj/mining.dmi'
	icon_state = "Gibtonite ore"
	item_state = "Gibtonite ore"
	w_class = WEIGHT_CLASS_HUGE
	throw_range = 0
	var/primed = FALSE
	var/det_time = 100
	var/quality = GIBTONITE_QUALITY_LOW //How pure this gibtonite is, determines the explosion produced by it and is derived from the det_time of the rock wall it was taken from, higher value = better
	var/attacher = "UNKNOWN"
	var/det_timer

/obj/item/melee/gibtonite/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)

/obj/item/melee/gibtonite/Destroy()
	qdel(wires)
	wires = null
	return ..()

/obj/item/melee/gibtonite/attackby(obj/item/I, mob/user, params)
	if(!wires && istype(I, /obj/item/assembly/igniter))
		user.visible_message("[user] attaches [I] to [src].", span_notice("You attach [I] to [src]."))
		wires = new /datum/wires/explosive/gibtonite(src)
		attacher = key_name(user)
		qdel(I)
		add_overlay("Gibtonite_igniter")
		return

	if(wires && !primed)
		if(is_wire_tool(I))
			wires.interact(user)
			return

	if(I.tool_behaviour == TOOL_MINING || istype(I, /obj/item/resonator) || I.force >= 10)
		GibtoniteReaction(user)
		return
	if(primed)
		if(istype(I, /obj/item/t_scanner/adv_mining_scanner/goat_scanner))
			primed = FALSE
			if(det_timer)
				deltimer(det_timer)
			user.visible_message("The chain reaction was stopped... the ore's quality seems to have improved!", span_notice("You stopped the chain reaction... the ore's quality seems to have improved!"))
			icon_state = "Gibtonite ore 3"
			quality = GIBTONITE_QUALITY_HIGH
			return
		if(istype(I, /obj/item/mining_scanner) || istype(I, /obj/item/t_scanner/adv_mining_scanner) || I.tool_behaviour == TOOL_MULTITOOL)
			primed = FALSE
			if(det_timer)
				deltimer(det_timer)
			user.visible_message("The chain reaction was stopped! ...The ore's quality looks diminished.", span_notice("You stopped the chain reaction... the ore's quality looks diminished."))
			icon_state = "Gibtonite ore"
			quality = GIBTONITE_QUALITY_LOW
			return
	..()

/obj/item/melee/gibtonite/attack_self(user)
	if(wires)
		wires.interact(user)
	else
		..()

/obj/item/melee/gibtonite/bullet_act(obj/projectile/P)
	GibtoniteReaction(P.firer)
	. = ..()

/obj/item/melee/gibtonite/ex_act()
	GibtoniteReaction(null, 1)

/obj/item/melee/gibtonite/proc/GibtoniteReaction(mob/user, triggered_by = 0)
	if(!primed)
		primed = TRUE
		playsound(src,'sound/effects/hit_on_shattered_glass.ogg',50,1)
		icon_state = "Gibtonite active"
		var/notify_admins = FALSE
		if(z != 5)//Only annoy the admins ingame if we're triggered off the mining zlevel
			notify_admins = TRUE

		if(triggered_by == 1)
			log_bomber(null, "An explosion has primed a", src, "for detonation", notify_admins)
		else if(triggered_by == 2)
			var/turf/bombturf = get_turf(src)
			if(notify_admins)
				message_admins("A signal has triggered a [name] to detonate at [ADMIN_VERBOSEJMP(bombturf)]. Igniter attacher: [ADMIN_LOOKUPFLW(attacher)]")
			var/bomb_message = "A signal has primed a [name] for detonation at [AREACOORD(bombturf)]. Igniter attacher: [key_name(attacher)]."
			log_game(bomb_message)
			GLOB.bombers += bomb_message
		else
			user.visible_message(span_warning("[user] strikes \the [src], causing a chain reaction!"), span_danger("You strike \the [src], causing a chain reaction."))
			log_bomber(user, "has primed a", src, "for detonation", notify_admins)
		det_timer = addtimer(CALLBACK(src, PROC_REF(detonate), notify_admins), det_time, TIMER_STOPPABLE)

/obj/item/melee/gibtonite/proc/detonate(notify_admins)
	if(primed)
		switch(quality)
			if(GIBTONITE_QUALITY_HIGH)
				explosion(src,2,4,9,adminlog = notify_admins)
			if(GIBTONITE_QUALITY_MEDIUM)
				explosion(src,1,2,5,adminlog = notify_admins)
			if(GIBTONITE_QUALITY_LOW)
				explosion(src,0,1,3,adminlog = notify_admins)
		qdel(src)

/obj/item/stack/ore/Initialize(mapload)
	. = ..()
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8

/obj/item/stack/ore/ex_act(severity, target)
	if (!severity || severity >= 2)
		return
	qdel(src)

/*****************************Coin********************************/

// The coin's value is a value of it's materials.
// Yes, the gold standard makes a come-back!
// This is the only way to make coins that are possible to produce on station actually worth anything.
/obj/item/coin
	icon = 'icons/obj/economy.dmi'
	name = "coin"
	icon_state = "coin__heads"
	flags_1 = CONDUCT_1
	force = 1
	throwforce = 2
	w_class = WEIGHT_CLASS_TINY
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	var/string_attached
	var/list/sideslist = list("heads","tails")
	var/cmineral = null
	var/cooldown = 0
	var/value = 1
	var/coinflip
	var/coin_stack_icon_state = "coin_stack"

/obj/item/coin/get_item_credit_value()
	return value

/obj/item/coin/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] contemplates suicide with \the [src]!"))
	if (!attack_self(user))
		user.visible_message(span_suicide("[user] couldn't flip \the [src]!"))
		return SHAME
	addtimer(CALLBACK(src, PROC_REF(manual_suicide), user), 10)//10 = time takes for flip animation
	return MANUAL_SUICIDE_NONLETHAL

/obj/item/coin/proc/manual_suicide(mob/living/user)
	var/index = sideslist.Find(coinflip)
	if (index==2)//tails
		user.visible_message(span_suicide("\the [src] lands on [coinflip]! [user] promptly falls over, dead!"))
		user.adjustOxyLoss(200)
		user.death(0)
		user.set_suicide(TRUE)
		user.suicide_log()
	else
		user.visible_message(span_suicide("\the [src] lands on [coinflip]! [user] keeps on living!"))

/obj/item/coin/Initialize(mapload)
	. = ..()
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8

/obj/item/coin/examine(mob/user)
	. = ..()
	if(value)
		. += span_info("It's worth [value] credit\s.")

/obj/item/coin/attackby(obj/item/I, mob/living/user, params)
	if(istype(I,/obj/item/coin))
		var/obj/item/coinstack/cs = new/obj/item/coinstack(null)
		if(user.is_holding(src))
			var/currentHandIndex = user.get_held_index_of_item(src)
			user.transferItemToLoc(src, null)
			cs.add_to_stack(src, user, message = FALSE)
			cs.add_to_stack(I, user, message = FALSE)
			user.put_in_hand(cs, currentHandIndex)
		else
			var/oldLoc = src.loc
			cs.pixel_x = pixel_x
			cs.pixel_y = pixel_y
			cs.add_to_stack(src, user, message = FALSE)
			cs.add_to_stack(I, user, message = FALSE)
			cs.forceMove(oldLoc)
		to_chat(user,span_notice("You stack [I] on [src]."))

/obj/item/coin/gold
	name = "gold coin"
	cmineral = "gold"
	icon_state = "coin_gold_heads"
	coin_stack_icon_state = "coin_gold_stack"
	value = 25
	materials = list(/datum/material/gold = MINERAL_MATERIAL_AMOUNT*0.2)
	grind_results = list(/datum/reagent/gold = 4)

/obj/item/coin/silver
	name = "silver coin"
	cmineral = "silver"
	icon_state = "coin_silver_heads"
	coin_stack_icon_state = "coin_silver_stack"
	value = 10
	materials = list(/datum/material/silver = MINERAL_MATERIAL_AMOUNT*0.2)
	grind_results = list(/datum/reagent/silver = 4)

/obj/item/coin/diamond
	name = "diamond coin"
	cmineral = "diamond"
	icon_state = "coin_diamond_heads"
	coin_stack_icon_state = "coin_diamond_stack"
	value = 100
	materials = list(/datum/material/diamond = MINERAL_MATERIAL_AMOUNT*0.2)
	grind_results = list(/datum/reagent/carbon = 4)

/obj/item/coin/iron
	name = "iron coin"
	cmineral = "iron"
	icon_state = "coin_iron_heads"
	coin_stack_icon_state = "coin_iron_stack"
	value = 1
	materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT*0.2)
	grind_results = list(/datum/reagent/iron = 4)

/obj/item/coin/plasma
	name = "plasma coin"
	cmineral = "plasma"
	icon_state = "coin_plasma_heads"
	coin_stack_icon_state = "coin_plasma_stack"
	value = 40
	materials = list(/datum/material/plasma = MINERAL_MATERIAL_AMOUNT*0.2)
	grind_results = list(/datum/reagent/toxin/plasma = 4)

/obj/item/coin/uranium
	name = "uranium coin"
	cmineral = "uranium"
	icon_state = "coin_uranium_heads"
	coin_stack_icon_state = "coin_uranium_stack"
	value = 25
	materials = list(/datum/material/uranium = MINERAL_MATERIAL_AMOUNT*0.2)
	grind_results = list(/datum/reagent/uranium = 4)

/obj/item/coin/bananium
	name = "bananium coin"
	cmineral = "bananium"
	icon_state = "coin_bananium_heads"
	coin_stack_icon_state = "coin_bananium_stack"
	value = 200 //makes the clown cry
	materials = list(/datum/material/bananium = MINERAL_MATERIAL_AMOUNT*0.2)
	grind_results = list(/datum/reagent/consumable/banana = 4)

/obj/item/coin/adamantine
	name = "adamantine coin"
	cmineral = "adamantine"
	icon_state = "coin_adamantine_heads"
	coin_stack_icon_state = "coin_adamantine_stack"
	value = 100

/obj/item/coin/mythril
	name = "mythril coin"
	cmineral = "mythril"
	icon_state = "coin_mythril_heads"
	coin_stack_icon_state = "coin_mythril_stack"
	value = 300

/obj/item/coin/twoheaded
	cmineral = "iron"
	icon_state = "coin_iron_heads"
	desc = "Hey, this coin's the same on both sides!"
	coin_stack_icon_state = "coin_iron_stack"
	sideslist = list("heads")
	materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT*0.2)
	value = 1
	grind_results = list(/datum/reagent/iron = 4)

/obj/item/coin/antagtoken
	name = "antag token"
	icon_state = "coin_valid_valid"
	coin_stack_icon_state = "coin_valid_stack"
	cmineral = "valid"
	desc = "A novelty coin that helps the heart know what hard evidence cannot prove."
	sideslist = list("valid", "salad")
	value = 0
	grind_results = list(/datum/reagent/consumable/sodiumchloride = 4)

/obj/item/coin/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/CC = W
		if(string_attached)
			to_chat(user, span_warning("There already is a string attached to this coin!"))
			return

		if (CC.use(1))
			add_overlay("coin_string_overlay")
			string_attached = 1
			to_chat(user, span_notice("You attach a string to the coin."))
		else
			to_chat(user, span_warning("You need one length of cable to attach a string to the coin!"))
			return
	else
		..()

/obj/item/coin/wirecutter_act(mob/living/user, obj/item/I)
	if(!string_attached)
		return TRUE

	new /obj/item/stack/cable_coil(drop_location(), 1)
	overlays = list()
	string_attached = null
	to_chat(user, span_notice("You detach the string from the coin."))
	return TRUE

/obj/item/coin/proc/flip(mob/user, flash = FALSE)
	if(cooldown < world.time)
		if(string_attached) //does the coin have a wire attached
			if(user)
				to_chat(user, span_warning("The coin won't flip very well with something attached!"))
			return FALSE//do not flip the coin
		coinflip = pick(sideslist)
		cooldown = world.time + 15

		flick("coin_[cmineral]_flip", src)
		icon_state = "coin_[cmineral]_[coinflip]"
		if(flash)
			SSvis_overlays.add_vis_overlay(src, icon, "flash", ABOVE_LIGHTING_PLANE, unique = TRUE)
		playsound(loc, 'sound/items/coinflip.ogg', 50, TRUE)
		var/oldloc = loc
		sleep(1.5 SECONDS)
		SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
		if(loc == oldloc && user && !user.incapacitated())
			user.visible_message("[user] has flipped [src]. It lands on [coinflip].", \
 							 span_notice("You flip [src]. It lands on [coinflip]."), \
							 span_italics("You hear the clattering of loose change."))
		else
			visible_message(span_notice("[src] lands on [coinflip]."), blind_message = span_italics("You hear the clattering of loose change."))
	return TRUE//did the coin flip? useful for suicide_act

/obj/item/coin/attack_self(mob/user)
	flip(user)

/obj/item/coin/after_throw(datum/callback/callback) //get rid of the throw rotation
	. = ..()
	transform = initial(transform)

/obj/item/coin/bullet_act(obj/projectile/P)
	if(P.armor_flag != LASER && P.armor_flag != ENERGY && !P.can_ricoshot) //only energy projectiles get deflected (also revolvers because damn thats cool)
		return ..()

	if(cooldown >= world.time || P.can_ricoshot == ALWAYS_RICOSHOT)//we ricochet the projectile
		var/list/targets = list()
		for(var/mob/living/T in viewers(5, src))
			if(istype(T) && T != P.firer && T.stat != DEAD) //don't fire at someone if they're dead or if we already hit them
				targets |= T
		P.damage *= 1.5
		P.speed *= 0.5
		P.ricochets++
		if(P.hitscan)
			P.store_hitscan_collision(P.trajectory.copy_to()) // ULTRA-RICOSHOT
		P.on_ricochet(src)
		P.impacted = list(src)
		P.pixel_x = pixel_x
		P.pixel_y = pixel_y
		if(!targets.len)
			var/spr = rand(0, 360) //randomize the direction
			P.preparePixelProjectile(src, src, spread = spr)
			P.fire(rand(0, 360))
		else
			var/mob/living/target = get_closest_atom(/mob/living, targets, src)
			P.preparePixelProjectile(target, src)
			P.fire(get_angle(P, target))
			targets -= target
			if(targets.len)
				P = duplicate_object(P, sameloc=1) //split into another projectile
				P.datum_flags = initial(P.datum_flags)	//we want to reset the projectile process that was duplicated
				P.last_process = initial(P.last_process)
				P.last_projectile_move = initial(P.last_projectile_move)
				target = get_closest_atom(/mob/living, targets, src)
				P.preparePixelProjectile(target, src)
				P.fire(get_angle(P, target))
		visible_message(span_danger("[P] ricochets off of [src]!"))
		playsound(loc, 'sound/weapons/ricochet.ogg', 50, 1)
		if(cooldown < world.time)
			INVOKE_ASYNC(src, PROC_REF(flip), null, TRUE) //flip the coin if it isn't already doing that
		return BULLET_ACT_FORCE_PIERCE

	//we instead flip the coin
	INVOKE_ASYNC(src, PROC_REF(flip), null, TRUE) //we don't want to wait for flipping to finish in order to do the impact
	return BULLET_ACT_TURF

/obj/item/coin/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, force, quickstart)
	if(cooldown < world.time) // Flip the coin when thrown
		spin = 0 // looks weird if it spins and flips at the same time
		INVOKE_ASYNC(src, PROC_REF(flip), null, TRUE)
	..()

/obj/item/coinstack
	name = "stack of coins"
	w_class = WEIGHT_CLASS_NORMAL
	var/list/obj/item/coin/coins //a stack of coins

/obj/item/coinstack/Initialize(mapload)
	. = ..()
	coins = list()
	var/turf/T = get_turf(src)
	if(T)
		for(var/obj/item/coin/C in T.contents)
			add_to_stack(C, null, FALSE)
	update_appearance(UPDATE_ICON)

/obj/item/coinstack/examine(mob/user)
	. = ..()
	var/value = 0
	var/antag = 0
	for(var/obj/item/coin/C in coins)
		value += C.value
		if(istype(C,/obj/item/coin/antagtoken))
			antag++
	. += span_info("The stack is worth [value] credit\s.")
	if(antag > 1)
		. += span_info("But they told me I could only have one at a time...")

/obj/item/coinstack/update_overlays()
	. = ..()
	for(var/i in 1 to length(coins))
		var/obj/item/coin/C = coins[i]
		. += image(icon = C.icon,icon_state = C.coin_stack_icon_state, pixel_y = (i-1)*2)

/obj/item/coinstack/attack_hand(mob/user) ///take a coin off the top of the stack
	remove_from_stack(user)
	return

/obj/item/coinstack/attackby(obj/item/I, mob/living/user, params)
	if(istype(I,/obj/item/coin))
		var/success = add_to_stack(I,user)
		if(success)
			to_chat(user,span_notice("You add [I] to the top of the stack of coins."))
		else
			to_chat(user,span_warning("The coin stack is already full!"))
		return
	..()

/obj/item/coinstack/proc/add_to_stack(obj/item/coin/C, mob/living/user, message = TRUE) //returns TRUE if it was successfully added to the stack.
	if(length(coins) >= COINSTACK_MAX)
		return FALSE
	coins += C
	C.forceMove(src)
	C.pixel_x = 0
	C.pixel_y = 0
	if(user)
		src.add_fingerprint(user)
		to_chat(user,span_notice("You add [C] to the stack of coins."))
	update_appearance(UPDATE_ICON)
	return TRUE

/obj/item/coinstack/proc/remove_from_stack(mob/living/user) //you can only remove the topmost coin from the stack
	var/obj/item/coin/top_coin = coins[length(coins)]
	if(top_coin)
		coins -= top_coin
		user.put_in_active_hand(top_coin)
	update_appearance(UPDATE_ICON)
	if(length(coins) <= 1) //one coin left, we're done here
		var/obj/item/coin/lastCoin = coins[1]
		coins -= coins[1]
		if(user.is_holding(src))
			var/currentHandIndex = user.get_held_index_of_item(src)
			user.transferItemToLoc(src, null)
			user.put_in_hand(lastCoin, currentHandIndex)
		else
			lastCoin.pixel_x = pixel_x
			lastCoin.pixel_y = pixel_y
			lastCoin.forceMove(loc)
		qdel(src)


/obj/item/coinstack/MouseDrop(atom/over_object)
	. = ..()
	var/mob/living/M = usr
	if(!istype(M) || !(M.mobility_flags & MOBILITY_PICKUP))
		return
	if(Adjacent(usr))
		if(over_object == M && loc != M)
			M.put_in_hands(src)
			pixel_x = 0
			pixel_y = 0
			to_chat(usr, span_notice("You pick up the coin stack."))
		else if(istype(over_object, /atom/movable/screen/inventory/hand))
			var/atom/movable/screen/inventory/hand/H = over_object
			if(M.putItemFromInventoryInHandIfPossible(src, H.held_index))
				pixel_x = 0
				pixel_y = 0
				to_chat(usr, span_notice("You pick up the deck."))
	else
		to_chat(usr, span_warning("You can't reach it from here!"))

#undef ORESTACK_OVERLAYS_MAX
#undef COINSTACK_MAX
