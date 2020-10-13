// Starthistle
/obj/item/seeds/starthistle
	name = "pack of starthistle seeds"
	desc = "A robust species of weed that often springs up in-between the cracks of spaceship parking lots."
	icon_state = "seed-starthistle"
	species = "starthistle"
	plantname = "Starthistle"
	lifespan = 70
	endurance = 50 // damm pesky weeds
	maturation = 5
	production = 1
	yield = 2
	potency = 10
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	genes = list(/datum/plant_gene/trait/plant_type/weed_hardy)
	mutatelist = list(/obj/item/seeds/starthistle/corpse_flower)

/obj/item/seeds/starthistle/harvest(mob/user)
	var/obj/machinery/hydroponics/parent = loc
	var/seed_count = yield
	if(prob(getYield() * 20))
		seed_count++
		var/output_loc = parent.Adjacent(user) ? user.loc : parent.loc
		for(var/i in 1 to seed_count)
			var/obj/item/seeds/starthistle/harvestseeds = Copy()
			harvestseeds.forceMove(output_loc)

	parent.update_tray()

// Corpse flower
/obj/item/seeds/starthistle/corpse_flower
	name = "pack of corpse flower seeds"
	desc = "A species of plant that emits a horrible odor. The odor stops being produced in difficult atmospheric conditions."
	icon_state = "seed-corpse-flower"
	species = "corpse-flower"
	plantname = "Corpse flower"
	production = 2
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	genes = list()
	mutatelist = list()

/obj/item/seeds/starthistle/corpse_flower/pre_attack(obj/machinery/hydroponics/I)
	if(istype(I, /obj/machinery/hydroponics))
		if(!I.myseed)
			START_PROCESSING(SSobj, src)
	return ..()

/obj/item/seeds/starthistle/corpse_flower/process()
	var/obj/machinery/hydroponics/parent = loc
	if(parent.age < maturation) // Start a little before it blooms
		return

	var/turf/open/T = get_turf(parent)
	if(abs(ONE_ATMOSPHERE - T.return_air().return_pressure()) > (potency/10 + 10)) // clouds can begin showing at around 50-60 potency in standard atmos
		return

	var/datum/gas_mixture/stank = new
	stank.set_moles(/datum/gas/miasma, (yield + 6)*7*MIASMA_CORPSE_MOLES) // this process is only being called about 2/7 as much as corpses so this is 12-32 times a corpses
	stank.set_temperature(T20C) // without this the room would eventually freeze and miasma mining would be easier
	T.assume_air(stank)
	T.air_update_turf()

// Cabbage
/obj/item/seeds/cabbage
	name = "pack of cabbage seeds"
	desc = "These seeds grow into cabbages."
	icon_state = "seed-cabbage"
	species = "cabbage"
	plantname = "Cabbages"
	product = /obj/item/reagent_containers/food/snacks/grown/cabbage
	lifespan = 50
	endurance = 25
	maturation = 3
	production = 5
	yield = 4
	growthstages = 1
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/replicapod)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1)

/obj/item/reagent_containers/food/snacks/grown/cabbage
	seed = /obj/item/seeds/cabbage
	name = "cabbage"
	desc = "Ewwwwwwwwww. Cabbage."
	icon_state = "cabbage"
	filling_color = "#90EE90"
	bitesize_mod = 2
	foodtype = VEGETABLES
	wine_power = 20

// Sugarcane
/obj/item/seeds/sugarcane
	name = "pack of sugarcane seeds"
	desc = "These seeds grow into sugarcane."
	icon_state = "seed-sugarcane"
	species = "sugarcane"
	plantname = "Sugarcane"
	product = /obj/item/reagent_containers/food/snacks/grown/sugarcane
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	lifespan = 60
	endurance = 50
	maturation = 3
	yield = 4
	growthstages = 2
	reagents_add = list(/datum/reagent/consumable/sugar = 0.25)
	mutatelist = list(/obj/item/seeds/bamboo)

/obj/item/reagent_containers/food/snacks/grown/sugarcane
	seed = /obj/item/seeds/sugarcane
	name = "sugarcane"
	desc = "Sickly sweet."
	icon_state = "sugarcane"
	filling_color = "#FFD700"
	bitesize_mod = 2
	foodtype = VEGETABLES | SUGAR
	distill_reagent = /datum/reagent/consumable/ethanol/rum

// Gatfruit
/obj/item/seeds/gatfruit
	name = "pack of gatfruit seeds"
	desc = "These seeds grow into .357 revolvers. A prized commodity among the criminal shadow-collective."
	icon_state = "seed-gatfruit"
	species = "gatfruit"
	plantname = "Gatfruit Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/shell/gatfruit
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	lifespan = 20
	endurance = 20
	maturation = 40
	production = 10
	yield = 2
	potency = 60
	growthstages = 2
	rarity = 60 // Obtainable only with xenobio+superluck.
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	reagents_add = list(/datum/reagent/sulfur = 0.1, /datum/reagent/carbon = 0.1, /datum/reagent/nitrogen = 0.07, /datum/reagent/potassium = 0.05)

/obj/item/reagent_containers/food/snacks/grown/shell/gatfruit
	seed = /obj/item/seeds/gatfruit
	name = "gatfruit"
	desc = "It smells like burning."
	icon_state = "gatfruit"
	trash = /obj/item/gun/ballistic/revolver
	bitesize_mod = 2
	foodtype = FRUIT
	tastes = list("gunpowder" = 1)
	wine_power = 90 //It burns going down, too.

//Cherry Bombs
/obj/item/seeds/cherry/bomb
	name = "pack of cherry bomb pits"
	desc = "They give you vibes of dread and frustration."
	icon_state = "seed-cherry_bomb"
	species = "cherry_bomb"
	plantname = "Cherry Bomb Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/cherry_bomb
	mutatelist = list()
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.1, /datum/reagent/consumable/sugar = 0.1, /datum/reagent/blackpowder = 0.7)
	rarity = 60 //See above

/obj/item/reagent_containers/food/snacks/grown/cherry_bomb
	name = "cherry bombs"
	desc = "You think you can hear the hissing of a tiny fuse."
	icon_state = "cherry_bomb"
	filling_color = rgb(20, 20, 20)
	seed = /obj/item/seeds/cherry/bomb
	bitesize_mod = 2
	volume = 125 //Gives enough room for the black powder at max potency
	max_integrity = 40
	wine_power = 80

/obj/item/reagent_containers/food/snacks/grown/cherry_bomb/attack_self(mob/living/user)
	user.visible_message("<span class='warning'>[user] plucks the stem from [src]!</span>", "<span class='userdanger'>You pluck the stem from [src], which begins to hiss loudly!</span>")
	log_bomber(user, "primed a", src, "for detonation")
	prime()

/obj/item/reagent_containers/food/snacks/grown/cherry_bomb/deconstruct(disassembled = TRUE)
	if(!disassembled)
		prime()
	if(!QDELETED(src))
		qdel(src)

/obj/item/reagent_containers/food/snacks/grown/cherry_bomb/ex_act(severity)
	qdel(src) //Ensuring that it's deleted by its own explosion. Also prevents mass chain reaction with piles of cherry bombs

/obj/item/reagent_containers/food/snacks/grown/cherry_bomb/proc/prime()
	icon_state = "cherry_bomb_lit"
	playsound(src, 'sound/effects/fuse.ogg', seed.potency, 0)
	reagents.chem_temp = 1000 //Sets off the black powder
	reagents.handle_reactions()

// Coconut
/obj/item/seeds/coconut
	name = "pack of coconut seeds"
	desc = "They're seeds that grow into coconut palm trees."
	icon_state = "seed-coconut"
	species = "coconut"
	plantname = "Coconut Palm Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/coconut
	lifespan = 50
	endurance = 30
	potency = 35
	growing_icon = 'icons/obj/hydroponics/growing.dmi'
	icon_dead = "coconut-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	forbiddengenes = list(/datum/plant_gene/trait/squash, /datum/plant_gene/trait/stinging)
	reagents_add = list("coconutmilk" = 0.3)

/obj/item/reagent_containers/food/snacks/grown/coconut
	seed = /obj/item/seeds/coconut
	name = "coconut"
	desc = "Hard shell of a nut containing delicious milk inside. Perhaps try using something sharp?"
	icon_state = "coconut"
	item_state = "coconut"
	possible_transfer_amounts = list(5, 10, 15, 20, 25, 30, 50)
	spillable = FALSE
	resistance_flags = ACID_PROOF
	volume = 150 //so it won't cut reagents despite having the capacity for them
	w_class = WEIGHT_CLASS_SMALL
	force = 5
	throwforce = 5
	hitsound = 'sound/weapons/klonk.ogg'
	attack_verb = list("klonked", "donked", "bonked")
	var/opened = FALSE
	var/carved = FALSE
	var/chopped = FALSE
	var/straw = FALSE
	var/fused = FALSE
	var/fusedactive = FALSE
	var/defused = FALSE

/obj/item/reagent_containers/food/snacks/grown/coconut/Initialize(mapload, obj/item/seeds/new_seed)
	. = ..()
	var/newvolume = 50 + round(seed.potency,10)
	if (seed.get_gene(/datum/plant_gene/trait/maxchem))
		newvolume = newvolume + 50
	volume = newvolume
	reagents.maximum_volume = newvolume
	reagents.update_total()

	transform *= TRANSFORM_USING_VARIABLE(40, 100) + 0.5 //temporary fix for size?

/obj/item/reagent_containers/food/snacks/grown/coconut/attack_self(mob/user)
	if (!opened)
		return

	if(!possible_transfer_amounts.len)
		return
	var/i=0
	for(var/A in possible_transfer_amounts)
		i++
		if(A != amount_per_transfer_from_this)
			continue
		if(i<possible_transfer_amounts.len)
			amount_per_transfer_from_this = possible_transfer_amounts[i+1]
		else
			amount_per_transfer_from_this = possible_transfer_amounts[1]
		to_chat(user, "<span class='notice'>[src]'s transfer amount is now [amount_per_transfer_from_this] units.</span>")
		return

/obj/item/reagent_containers/food/snacks/grown/coconut/attackby(obj/item/W, mob/user, params)
	//DEFUSING NADE LOGIC
	if (W.tool_behaviour == TOOL_WIRECUTTER && fused)
		user.show_message("<span class='notice'>You cut the fuse!</span>", MSG_VISUAL)
		playsound(user, W.hitsound, 50, 1, -1)
		icon_state = "coconut_carved"
		desc = "A coconut. This one's got a hole in it."
		name = "coconut"
		defused = TRUE
		fused = FALSE
		fusedactive = FALSE
		if(!seed.get_gene(/datum/plant_gene/trait/glow))
			set_light(0, 0.0)
		return
	//IGNITING NADE LOGIC
	if(!fusedactive && fused)
		var/lighting_text = W.ignition_effect(src, user)
		if(lighting_text)
			user.visible_message("<span class='warning'>[user] ignites [src]'s fuse!</span>", "<span class='userdanger'>You ignite the [src]'s fuse!</span>")
			fusedactive = TRUE
			defused = FALSE
			playsound(src, 'sound/effects/fuse.ogg', 100, 0)
			message_admins("[ADMIN_LOOKUPFLW(user)] ignited a coconut bomb for detonation at [ADMIN_VERBOSEJMP(user)] [pretty_string_from_reagent_list(reagents.reagent_list)]")
			log_game("[key_name(user)] primed a coconut grenade for detonation at [AREACOORD(user)].")
			addtimer(CALLBACK(src, .proc/prime), 5 SECONDS)
			icon_state = "coconut_grenade_active"
			desc = "RUN!"
			if(!seed.get_gene(/datum/plant_gene/trait/glow))
				light_color = "#FFCC66" //for the fuse
				set_light(3, 0.8)
			return

	//ADDING A FUSE, NADE LOGIC
	if (istype(W,/obj/item/stack/sheet/cloth) || istype(W,/obj/item/stack/sheet/durathread))
		if (carved && !straw && !fused)
			user.show_message("<span class='notice'>You add a fuse to the coconut!</span>", 1)
			W.use(1)
			fused = TRUE
			icon_state = "coconut_grenade"
			desc = "A makeshift bomb made out of a coconut. You estimate the fuse is long enough for 5 seconds."
			name = "coconut bomb"
			return
	//ADDING STRAW LOGIC
	if (istype(W,/obj/item/stack/sheet/mineral/bamboo) && opened && !straw && fused)
		user.show_message("<span class='notice'>You add a bamboo straw to the coconut!</span>", 1)
		straw = TRUE
		W.use(1)
		icon_state += "_straw"
		desc = "You can already feel like you're on a tropical vacation."
		return
	//OPENING THE NUT LOGIC
	if (!carved && !chopped)
		var/screwdrivered = W.tool_behaviour == TOOL_SCREWDRIVER
		if(screwdrivered || W.sharpness)
			user.show_message("<span class='notice'>You [screwdrivered ? "make a hole in the coconut" : "slice the coconut open"]!</span>", 1)
			carved = TRUE
			opened = TRUE
			spillable = !screwdrivered
			reagent_flags = OPENCONTAINER
			ENABLE_BITFIELD(reagents.reagents_holder_flags, OPENCONTAINER)
			icon_state = screwdrivered ? "coconut_carved" : "coconut_chopped"
			desc = "A coconut. [screwdrivered ? "This one's got a hole in it" : "This one's sliced open, with all its delicious contents for your eyes to savour"]."
			playsound(user, W.hitsound, 50, 1, -1)
			return
	return ..()

/obj/item/reagent_containers/food/snacks/grown/coconut/attack(mob/living/M, mob/user, obj/target)
	if(M && user.a_intent == INTENT_HARM && !spillable)
		var/obj/item/bodypart/affecting = user.zone_selected //Find what the player is aiming at
		if (affecting == BODY_ZONE_HEAD && prob(15))
			//smash the nut open
			var/armor_block = min(90, M.run_armor_check(affecting, "melee", null, null,armour_penetration)) // For normal attack damage
			M.apply_damage(force, BRUTE, affecting, armor_block)

			//Sound
			playsound(user, hitsound, 100, 1, -1)

			//Attack logs
			log_combat(user, M, "attacked", src)

			//Display an attack message.
			if(M != user)
				M.visible_message("<span class='danger'>[user] has cracked open a [name] on [M]'s head!</span>", \
						"<span class='userdanger'>[user] has cracked open a [name] on [M]'s head!</span>")
			else
				user.visible_message("<span class='danger'>[M] cracks open a [name] on their [M.p_them()] head!</span>", \
						"<span class='userdanger'>[M] cracks open a [name] on [M.p_their()] head!</span>")

			//The coconut breaks open so splash its reagents
			spillable = TRUE
			SplashReagents(M)

			//Lastly we remove the nut
			qdel(src)
		else
			. = ..()
		return

	if(fusedactive)
		return

	if(!opened)
		return

	if(!canconsume(M, user))
		return

	if(!reagents || !reagents.total_volume)
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return

	if(user.a_intent == INTENT_HARM && spillable)
		var/R
		M.visible_message("<span class='danger'>[user] splashes the contents of [src] onto [M]!</span>", \
						"<span class='userdanger'>[user] splashes the contents of [src] onto [M]!</span>")
		if(reagents)
			for(var/datum/reagent/A in reagents.reagent_list)
				R += A.id + " ("
				R += num2text(A.volume) + "),"
		if(isturf(target) && reagents.reagent_list.len && thrownby)
			log_combat(thrownby, target, "splashed (thrown) [english_list(reagents.reagent_list)]")
			message_admins("[ADMIN_LOOKUPFLW(thrownby)] splashed (thrown) [english_list(reagents.reagent_list)] on [target] at [ADMIN_VERBOSEJMP(target)].")
		reagents.reaction(M, TOUCH)
		log_combat(user, M, "splashed", R)
		reagents.clear_reagents()
	else
		if(M != user)
			M.visible_message("<span class='danger'>[user] attempts to feed something to [M].</span>", \
						"<span class='userdanger'>[user] attempts to feed something to you.</span>")
			if(!do_mob(user, M))
				return
			if(!reagents || !reagents.total_volume)
				return // The drink might be empty after the delay, such as by spam-feeding
			M.visible_message("<span class='danger'>[user] feeds something to [M].</span>", "<span class='userdanger'>[user] feeds something to you.</span>")
			log_combat(user, M, "fed", reagents.log_list())
		else
			to_chat(user, "<span class='notice'>You swallow a gulp of [src].</span>")
		var/fraction = min(5/reagents.total_volume, 1)
		reagents.reaction(M, INGEST, fraction)
		addtimer(CALLBACK(reagents, /datum/reagents.proc/trans_to, M, 5), 5)
		playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)

/obj/item/reagent_containers/food/snacks/grown/coconut/afterattack(obj/target, mob/user, proximity)
	. = ..()
	if(fusedactive)
		return

	if((!proximity) || !check_allowed_items(target,target_self=1))
		return

	if(target.is_refillable()) //Something like a glass. Player probably wants to transfer TO it.
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>[src] is empty!</span>")
			return

		if(target.reagents.holder_full())
			to_chat(user, "<span class='warning'>[target] is full.</span>")
			return

		var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You transfer [trans] unit\s of the solution to [target].</span>")

	else if(target.is_drainable()) //A dispenser. Transfer FROM it TO us.
		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] is empty and can't be refilled!</span>")
			return

		if(reagents.holder_full())
			to_chat(user, "<span class='warning'>[src] is full.</span>")
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You fill [src] with [trans] unit\s of the contents of [target].</span>")

	else if(reagents.total_volume)
		if(user.a_intent == INTENT_HARM && spillable == TRUE)
			user.visible_message("<span class='danger'>[user] splashes the contents of [src] onto [target]!</span>", \
								"<span class='notice'>You splash the contents of [src] onto [target].</span>")
			reagents.reaction(target, TOUCH)
			reagents.clear_reagents()

/obj/item/reagent_containers/food/snacks/grown/coconut/dropped(mob/user)
	. = ..()
	transform *= TRANSFORM_USING_VARIABLE(40, 100) + 0.5 //temporary fix for size?

/obj/item/reagent_containers/food/snacks/grown/coconut/proc/prime()
	if (defused)
		return
	var/turf/T = get_turf(src)
	reagents.chem_temp = 1000
	//Disable seperated contents when the grenade primes
	if (seed.get_gene(/datum/plant_gene/trait/noreact))
		DISABLE_BITFIELD(reagents.reagents_holder_flags, NO_REACT)
	reagents.handle_reactions()
	log_game("Coconut bomb detonation at [AREACOORD(T)], location [loc]")
	qdel(src)

/obj/item/reagent_containers/food/snacks/grown/coconut/ex_act(severity)
	qdel(src)

/obj/item/reagent_containers/food/snacks/grown/coconut/deconstruct(disassembled = TRUE)
	if(!disassembled && fused)
		prime()
	if(!QDELETED(src))
		qdel(src)
