GLOBAL_VAR_INIT(clones, 0)
//Cloning revival method.
//The pod handles the actual cloning while the computer manages the clone profiles

//Potential replacement for genetics revives or something I dunno (?)

#define CLONE_INITIAL_DAMAGE     150    //Clones in clonepods start with 150 cloneloss damage and 150 brainloss damage, thats just logical
#define MINIMUM_HEAL_LEVEL 40

#define SPEAK(message) radio.talk_into(src, message, radio_channel)

/obj/machinery/clonepod
	name = "cloning pod"
	desc = "An electronically-lockable pod for growing organic tissue."
	density = TRUE
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "pod_0"
	req_access = list(ACCESS_CLONING) //FOR PREMATURE UNLOCKING.
	verb_say = "states"
	circuit = /obj/item/circuitboard/machine/clonepod

	var/heal_level //The clone is released once its health reaches this level.
	var/obj/machinery/computer/cloning/connected //So we remember the connected clone machine.
	var/mess = FALSE //Need to clean out it if it's full of exploded clone.
	var/attempting = FALSE //One clone attempt at a time thanks
	var/speed_coeff
	var/efficiency
	// the three variables that handle meatcloning
	var/biomass = 0 //Start with no biomass inserted.
	var/maxbiomass = 100
	///List of special meat that gives extra/less biomass
	var/list/accepted_biomass = list(
		/obj/item/reagent_containers/food/snacks/meat/slab/monkey = 25, 
		/obj/item/reagent_containers/food/snacks/meat/slab/synthmeat = 34,
		/obj/item/reagent_containers/food/snacks/meat/slab/human = 50,
		/obj/item/stack/sheet/animalhide/human = 50
		)
	///How much biomass does regular meat that isn't in the above list give
	var/biomass_per_slab = 20

	var/datum/mind/clonemind
	var/grab_ghost_when = CLONER_MATURE_CLONE

	var/internal_radio = TRUE
	var/obj/item/radio/radio
	var/radio_key = /obj/item/encryptionkey/headset_med
	var/radio_channel = RADIO_CHANNEL_MEDICAL

	var/obj/effect/countdown/clonepod/countdown

	var/list/unattached_flesh
	var/flesh_number = 0
	var/datum/bank_account/current_insurance
	fair_market_price = 5 // He nodded, because he knew I was right. Then he swiped his credit card to pay me for arresting him.
	payment_department = ACCOUNT_MED

/obj/machinery/clonepod/Initialize(mapload)
	. = ..()

	countdown = new(src)

	if(internal_radio)
		radio = new(src)
		radio.keyslot = new radio_key
		radio.subspace_transmission = TRUE
		radio.canhear_range = 0
		radio.recalculateChannels()

/obj/machinery/clonepod/Destroy()
	go_out()
	QDEL_NULL(radio)
	QDEL_NULL(countdown)
	if(connected)
		connected.DetachCloner(src)
	QDEL_LIST(unattached_flesh)
	. = ..()

/obj/machinery/clonepod/RefreshParts()
	speed_coeff = 0
	efficiency = 0
	maxbiomass = 0
	for(var/obj/item/stock_parts/scanning_module/S in component_parts)
		efficiency += S.rating
	for(var/obj/item/stock_parts/manipulator/P in component_parts)
		speed_coeff += P.rating
	for(var/obj/item/reagent_containers/glass/beaker/B in component_parts)
		maxbiomass += B.reagents.maximum_volume
	heal_level = (efficiency * 15) + 10
	if(heal_level < MINIMUM_HEAL_LEVEL)
		heal_level = MINIMUM_HEAL_LEVEL
	if(heal_level > 100)
		heal_level = 100

/obj/machinery/clonepod/examine(mob/user)
	. = ..()
	. += span_notice("The <i>linking</i> device can be <i>scanned<i> with a multitool.")
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads: Cloning speed at <b>[speed_coeff*50]%</b>.<br>Predicted amount of cellular damage: <b>[100-heal_level]%</b>.<span>"
		. += "<span class='notice'>The status display reads: Biomass levels at <b>[round((biomass/maxbiomass)*100)]%</b><span>" // read out the amount of biomass if you examine
		if(efficiency > 5)
			. += "<span class='notice'>Pod has been upgraded to support autoprocessing and apply beneficial mutations.<span>"

//The return of data disks?? Just for transferring between genetics machine/cloning machine.
//TO-DO: Make the genetics machine accept them.
/obj/item/disk/data
	name = "cloning data disk"
	icon_state = "datadisk0" //Gosh I hope syndies don't mistake them for the nuke disk.
	var/list/fields = list()
	var/list/genetic_makeup_buffer = list()
	var/list/mutations = list()
	var/max_mutations = 6
	var/read_only = FALSE //Well,it's still a floppy disk

//Disk stuff.
/obj/item/disk/data/Initialize(mapload)
	. = ..()
	icon_state = "datadisk[rand(0,6)]"
	add_overlay("datadisk_gene")

/obj/item/disk/data/attack_self(mob/user)
	read_only = !read_only
	to_chat(user, span_notice("You flip the write-protect tab to [read_only ? "protected" : "unprotected"]."))

/obj/item/disk/data/examine(mob/user)
	. = ..()
	. += "The write-protect tab is set to [read_only ? "protected" : "unprotected"]."

// Biomass

/obj/machinery/clonepod/proc/handle_biomass(W, tempbiomass, user) // updates the value
	if(biomass >= maxbiomass)
		to_chat(user, "<span class = 'notice'>[src]'s biomass containers are full!.</span>")
		return // if biomass is already 100 then yell at those stupid idiots
	else
		to_chat(user, "<span class = 'notice'>You insert [W] into [src].</span>") // feel free to fill it.
		biomass = tempbiomass
		qdel(W)
		biomass = clamp(biomass, 0, maxbiomass)
	return

/obj/machinery/clonepod/attackby(obj/item/W, mob/user, params)
	var/tempbiomass = biomass
	if(W.type in accepted_biomass)
		if(istype(W, /obj/item/stack/sheet))
			var/obj/item/stack/S = W
			tempbiomass += S.amount * accepted_biomass[W.type] //we need special code because stacks are cringe
			handle_biomass(W, tempbiomass, user)

		else
			tempbiomass += accepted_biomass[W.type] // changes biomass to whatever slab it picked
			handle_biomass(W, tempbiomass, user)

	else if(istype(W, /obj/item/reagent_containers/food/snacks/meat/slab)) // If no special slab was picked it reverts to var/biomass_per_slab
		tempbiomass += biomass_per_slab
		handle_biomass(W, tempbiomass, user)

	else
		return ..()

//Clonepod

/obj/machinery/clonepod/examine(mob/user)
	. = ..()
	var/mob/living/mob_occupant = occupant
	if(mess)
		. += "It's filled with blood and viscera. You swear you can see it moving..."
	if(is_operational() && istype(mob_occupant))
		if(mob_occupant.stat != DEAD)
			. += "Current clone cycle is [round(get_completion())]% complete."

/obj/machinery/clonepod/return_air()
	// We want to simulate the clone not being in contact with
	// the atmosphere, so we'll put them in a constant pressure
	// nitrogen. They don't need to breathe while cloning anyway.
	var/static/datum/gas_mixture/immutable/cloner/GM //global so that there's only one instance made for all cloning pods
	if(!GM)
		GM = new
	return GM

/obj/machinery/clonepod/proc/get_completion()
	. = FALSE
	var/mob/living/mob_occupant = occupant
	if(mob_occupant)
		. = (100 * ((mob_occupant.health + 100) / (heal_level + 100)))

/obj/machinery/clonepod/attack_ai(mob/user)
	return examine(user)

//Start growing a human clone in the pod!
/obj/machinery/clonepod/proc/growclone(clonename, ui, mutation_index, makeup, mindref, last_death, datum/species/mrace, list/features, factions, list/quirks, datum/bank_account/insurance, list/traumas, empty, mood)
	if(panel_open)
		return NONE
	if(mess || attempting)
		return NONE

	if(!empty) //Doesn't matter if we're just making a copy
		clonemind = locate(mindref) in SSticker.minds
		if(!istype(clonemind))	//not a mind
			return NONE
		if(clonemind.last_death != last_death) //The soul has advanced, the record has not.
			return NONE
		if(!QDELETED(clonemind.current))
			if(clonemind.current.stat != DEAD)	//mind is associated with a non-dead body
				return NONE
			if(clonemind.current.suiciding) // Mind is associated with a body that is suiciding.
				return NONE
		if(!clonemind.active)
			// get_ghost() will fail if they're unable to reenter their body
			var/mob/dead/observer/G = clonemind.get_ghost()
			if(!G)
				return NONE
			if(G.suiciding) // The ghost came from a body that is suiciding.
				return NONE
		if(clonemind.damnation_type) //Can't clone the damned.
			INVOKE_ASYNC(src, PROC_REF(horrifyingsound))
			mess = TRUE
			icon_state = "pod_g"
			update_appearance(UPDATE_ICON)
			return NONE
		if(clonemind.zombified) //Can't clone the damned x2
			INVOKE_ASYNC(src, PROC_REF(horrifyingsound))
			mess = TRUE
			icon_state = "pod_g"
			update_appearance(UPDATE_ICON)
			return NONE
		current_insurance = insurance
	attempting = TRUE //One at a time!!
	biomass -= 100
	countdown.start()

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(src)

	H.hardset_dna(ui, mutation_index, makeup, H.real_name, null, mrace, features)

	if(!HAS_TRAIT(H, TRAIT_RADIMMUNE))//dont apply mutations if the species is Mutation proof.
		if(efficiency > 2)
			var/list/unclean_mutations = (GLOB.not_good_mutations|GLOB.bad_mutations)
			H.dna.remove_mutation_group(unclean_mutations)
		if(efficiency > 5 && prob(20))
			H.easy_random_mutate(POSITIVE)
		if(efficiency < 3 && prob(50))
			var/mob/M = H.easy_random_mutate(NEGATIVE+MINOR_NEGATIVE)
			if(ismob(M))
				H = M
	
	var/list/possible_genders = H.dna.species.possible_genders
	if(!possible_genders || possible_genders.len < 1)
		stack_trace("[H.dna.species.type] has no possible genders!")
		H.gender = PLURAL // uh oh
	else if(possible_genders.len == 1)
		H.gender = possible_genders[1] // some species only have one gender

	if(!H.GetComponent(/datum/component/mood) && mood)
		H.AddComponent(/datum/component/mood)

	H.silent = 20 //Prevents an extreme edge case where clones could speak if they said something at exactly the right moment.
	occupant = H

	if(!clonename)	//to prevent null names
		clonename = "clone ([rand(1,999)])"
	H.real_name = clonename

	icon_state = "pod_1"
	//Get the clone body ready
	maim_clone(H)
	ADD_TRAIT(H, TRAIT_STABLEHEART, CLONING_POD_TRAIT)
	ADD_TRAIT(H, TRAIT_STABLELIVER, CLONING_POD_TRAIT)
	ADD_TRAIT(H, TRAIT_EMOTEMUTE, CLONING_POD_TRAIT)
	ADD_TRAIT(H, TRAIT_MUTE, CLONING_POD_TRAIT)
	ADD_TRAIT(H, TRAIT_NOBREATH, CLONING_POD_TRAIT)
	ADD_TRAIT(H, TRAIT_NOCRITDAMAGE, CLONING_POD_TRAIT)
	H.Unconscious(80)

	if(!empty)
		clonemind.transfer_to(H)

		if(grab_ghost_when == CLONER_FRESH_CLONE)
			H.grab_ghost()
			to_chat(H, span_notice("<b>Consciousness slowly creeps over you as your body regenerates.</b><br><i>So this is what cloning feels like?</i>"))

		if(grab_ghost_when == CLONER_MATURE_CLONE)
			H.ghostize(TRUE)	//Only does anything if they were still in their old body and not already a ghost
			to_chat(H.get_ghost(TRUE), span_notice("Your body is beginning to regenerate in a cloning pod. You will become conscious when it is complete."))

	if(H)
		H.faction |= factions

		for(var/V in quirks)
			var/datum/quirk/Q = new V(H)
			Q.on_clone(quirks[V])

		for(var/t in traumas)
			var/datum/brain_trauma/BT = t
			var/datum/brain_trauma/cloned_trauma = BT.on_clone()
			if(cloned_trauma)
				H.gain_trauma(cloned_trauma, BT.resilience)

		H.set_cloned_appearance()

		H.set_suicide(FALSE)
	attempting = FALSE
	return CLONING_SUCCESS

//Grow clones to maturity then kick them out.  FREELOADERS
/obj/machinery/clonepod/process()
	var/mob/living/mob_occupant = occupant

	if(!is_operational()) //Autoeject if power is lost
		if(mob_occupant)
			log_cloning("[key_name(mob_occupant)] ejected from [src] at [AREACOORD(src)] due to power loss.")
			go_out()
			connected_message("Clone Ejected: Loss of power.")

	else if(mob_occupant && (mob_occupant.loc == src))
		if(SSeconomy.full_ancap)
			if(!current_insurance)
				log_cloning("[key_name(mob_occupant)] ejected from [src] at [AREACOORD(src)] due to invalid bank account.")
				go_out()
				connected_message("Clone Ejected: No bank account.")
				if(internal_radio)
					SPEAK("The cloning of [mob_occupant.real_name] has been terminated due to no bank account to draw payment from.")
			else if(!current_insurance.adjust_money(-fair_market_price))
				log_cloning("[key_name(mob_occupant)] ejected from [src] at [AREACOORD(src)] due to insufficient funds.")
				go_out()
				connected_message("Clone Ejected: Out of Money.")
				if(internal_radio)
					SPEAK("The cloning of [mob_occupant.real_name] has been ended prematurely due to being unable to pay.")
			else
				var/datum/bank_account/D = SSeconomy.get_dep_account(payment_department)
				if(D)
					D.adjust_money(fair_market_price)
		if(mob_occupant && (mob_occupant.stat == DEAD) || (mob_occupant.suiciding) || mob_occupant.hellbound)  //Autoeject corpses and suiciding dudes.
			connected_message("Clone Rejected: Deceased.")
			if(internal_radio)
				SPEAK("The cloning of [mob_occupant.real_name] has been \
					aborted due to unrecoverable tissue failure.")
			log_cloning("[key_name(mob_occupant)] ejected from [src] at [AREACOORD(src)] after suiciding.")
			go_out()

		else if(mob_occupant && mob_occupant.cloneloss > (100 - heal_level))
			mob_occupant.Unconscious(80)
			var/dmg_mult = CONFIG_GET(number/damage_multiplier)
			 //Slowly get that clone healed and finished.
			var/telomere_boost = HAS_TRAIT(mob_occupant,TRAIT_LONG_TELOMERES) ? 1.2 : 1.0 //clone 20% faster with long telomere quirk
			mob_occupant.adjustCloneLoss(-((speed_coeff / 2) * dmg_mult * telomere_boost))
			var/progress = CLONE_INITIAL_DAMAGE - mob_occupant.getCloneLoss()
			// To avoid the default cloner making incomplete clones
			progress += (100 - MINIMUM_HEAL_LEVEL)
			var/milestone = CLONE_INITIAL_DAMAGE / flesh_number
			var/installed = flesh_number - unattached_flesh.len

			if((progress / milestone) >= installed)
				// attach some flesh
				var/obj/item/I = pick_n_take(unattached_flesh)
				if(isorgan(I))
					var/obj/item/organ/O = I
					O.organ_flags &= ~ORGAN_FROZEN
					O.Insert(mob_occupant)
				else if(isbodypart(I))
					var/obj/item/bodypart/BP = I
					BP.attach_limb(mob_occupant)

			use_power(7500) //This might need tweaking.

		else if(mob_occupant && (mob_occupant.cloneloss <= (100 - heal_level)))
			connected_message("Cloning Process Complete.")
			log_cloning("[key_name(mob_occupant)] completed cloning cycle in [src] at [AREACOORD(src)].")
			if(internal_radio)
				SPEAK("The cloning cycle of [mob_occupant.real_name] is complete.")

			// If the cloner is upgraded to debugging high levels, sometimes
			// organs and limbs can be missing.
			for(var/i in unattached_flesh)
				if(isorgan(i))
					var/obj/item/organ/O = i
					O.organ_flags &= ~ORGAN_FROZEN
					O.Insert(mob_occupant)
				else if(isbodypart(i))
					var/obj/item/bodypart/BP = i
					BP.attach_limb(mob_occupant)

			go_out()

	else if (!mob_occupant || mob_occupant.loc != src)
		occupant = null
		if (!mess && !panel_open)
			icon_state = "pod_0"
		use_power(200)

//Let's unlock this early I guess.  Might be too early, needs tweaking.
/obj/machinery/clonepod/attackby(obj/item/W, mob/user, params)
	if(!(occupant || mess))
		if(default_deconstruction_screwdriver(user, "[icon_state]_maintenance", "[initial(icon_state)]",W))
			return

	if(default_deconstruction_crowbar(W))
		return

	if(W.tool_behaviour == TOOL_MULTITOOL)
		if(!multitool_check_buffer(user, W))
			return
		var/atom/buffer_atom = multitool_get_buffer(user, W)
		if(istype(buffer_atom, /obj/machinery/computer/cloning))
			if(get_area(buffer_atom) != get_area(src))
				to_chat(user, "<font color = #666633>-% Cannot link machines across power zones. Buffer cleared %-</font color>")
				multitool_set_buffer(user, W, null)
				return
			to_chat(user, "<font color = #666633>-% Successfully linked [buffer_atom] with [src] %-</font color>")
			var/obj/machinery/computer/cloning/comp = buffer_atom
			if(connected)
				connected.DetachCloner(src)
			comp.AttachCloner(src)
		else
			multitool_set_buffer(user, W, src)
			to_chat(user, "<font color = #666633>-% Successfully stored [REF(buffer_atom)] [buffer_atom.name] in buffer %-</font color>")
		return

	var/mob/living/mob_occupant = occupant
	if(W.GetID())
		if(!check_access(W))
			to_chat(user, span_danger("Access Denied."))
			return
		if(!(mob_occupant || mess))
			to_chat(user, span_danger("Error: Pod has no occupant."))
			return
		else
			add_fingerprint(user)
			log_cloning("[key_name(user)] manually ejected [key_name(mob_occupant)] from [src] at [AREACOORD(src)].")
			log_combat(user, mob_occupant, "ejected", W, "from [src]")
			connected_message("Emergency Ejection")
			SPEAK("An emergency ejection of [clonemind.name] has occurred. Survival not guaranteed.")
			to_chat(user, span_notice("You force an emergency ejection. "))
			go_out()
	else
		return ..()

/obj/machinery/clonepod/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(!occupant)
		return FALSE
	to_chat(user, span_warning("You corrupt the genetic compiler."))
	malfunction()
	add_fingerprint(user)
	log_cloning("[key_name(user)] emagged [src] at [AREACOORD(src)], causing it to malfunction.")
	log_combat(user, src, "emagged", null, occupant ? "[occupant] inside, killing them via malfunction." : null)
	return TRUE

//Put messages in the connected computer's temp var for display.
/obj/machinery/clonepod/proc/connected_message(message)
	if ((isnull(connected)) || (!istype(connected, /obj/machinery/computer/cloning)))
		return FALSE
	if (!message)
		return FALSE

	connected.temp = message
	connected.updateUsrDialog()
	return TRUE

/obj/machinery/clonepod/proc/go_out()
	countdown.stop()
	var/mob/living/mob_occupant = occupant
	var/turf/T = get_turf(src)

	if(mess) //Clean that mess and dump those gibs!
		for(var/obj/fl in unattached_flesh)
			fl.forceMove(T)
			if(istype(fl, /obj/item/organ))
				var/obj/item/organ/O = fl
				O.organ_flags &= ~ORGAN_FROZEN
		unattached_flesh.Cut()
		mess = FALSE
		new /obj/effect/gibspawner/generic(get_turf(src), mob_occupant)
		audible_message(span_italics("You hear a splat."))
		icon_state = "pod_0"
		return

	if(!mob_occupant)
		return
	current_insurance = null
	REMOVE_TRAIT(mob_occupant, TRAIT_STABLEHEART, CLONING_POD_TRAIT)
	REMOVE_TRAIT(mob_occupant, TRAIT_STABLELIVER, CLONING_POD_TRAIT)
	REMOVE_TRAIT(mob_occupant, TRAIT_EMOTEMUTE, CLONING_POD_TRAIT)
	REMOVE_TRAIT(mob_occupant, TRAIT_MUTE, CLONING_POD_TRAIT)
	REMOVE_TRAIT(mob_occupant, TRAIT_NOCRITDAMAGE, CLONING_POD_TRAIT)
	REMOVE_TRAIT(mob_occupant, TRAIT_NOBREATH, CLONING_POD_TRAIT)

	if(grab_ghost_when == CLONER_MATURE_CLONE)
		mob_occupant.grab_ghost()
		to_chat(occupant, span_notice("<b>There is a bright flash!</b><br><i>You feel like a new being.</i>"))
		to_chat(occupant, span_userdanger("You do not remember your death, how you died, or who killed you. <a href='https://forums.yogstation.net/help/rules/#rule-1_6'>See rule 1.6</a>.")) //yogs
		occupant.log_message("was cloned with memory loss", LOG_ATTACK, color="green")
		mob_occupant.flash_act()
		GLOB.clones++

	occupant.forceMove(T)
	icon_state = "pod_0"
	mob_occupant.domutcheck(1) //Waiting until they're out before possible monkeyizing. The 1 argument forces powers to manifest.
	for(var/fl in unattached_flesh)
		qdel(fl)
	unattached_flesh.Cut()

	occupant = null
	clonemind = null

/obj/machinery/clonepod/proc/malfunction()
	var/mob/living/mob_occupant = occupant
	if(mob_occupant)
		connected_message("Critical Error!")
		SPEAK("Critical error! Please contact a Thinktronic Systems \
			technician, as your warranty may be affected.")
		mess = TRUE
		maim_clone(mob_occupant)	//Remove every bit that's grown back so far to drop later, also destroys bits that haven't grown yet
		icon_state = "pod_g"
		if(clonemind && mob_occupant.mind != clonemind)
			clonemind.transfer_to(mob_occupant)
		mob_occupant.grab_ghost() // We really just want to make you suffer.
		flash_color(mob_occupant, flash_color="#960000", flash_time=100)
		to_chat(mob_occupant, span_warning("<b>Agony blazes across your consciousness as your body is torn apart.</b><br><i>Is this what dying is like? Yes it is.</i>"))
		playsound(src, 'sound/machines/warning-buzzer.ogg', 50)
		SEND_SOUND(mob_occupant, sound('sound/hallucinations/veryfar_noise.ogg',0,1,50))
		log_cloning("[key_name(mob_occupant)] destroyed within [src] at [AREACOORD(src)] due to malfunction.")
		QDEL_IN(mob_occupant, 40)

/obj/machinery/clonepod/relaymove(mob/user)
	container_resist(user)

/obj/machinery/clonepod/container_resist(mob/living/user)
	if(user.stat == CONSCIOUS)
		go_out()

/obj/machinery/clonepod/emp_act(severity)
	. = ..()
	if (!(. & EMP_PROTECT_SELF))
		var/mob/living/mob_occupant = occupant
		if(mob_occupant && prob(10 * severity / efficiency))
			log_cloning("[key_name(mob_occupant)] ejected from [src] at [AREACOORD(src)] due to EMP pulse.")
			connected_message(Gibberish("EMP-caused Accidental Ejection", 0))
			SPEAK(Gibberish("Exposure to electromagnetic fields has caused the ejection of [mob_occupant.real_name] prematurely." ,0))
			go_out()

/obj/machinery/clonepod/ex_act(severity, target)
	..()
	if(!QDELETED(src))
		go_out()

/obj/machinery/clonepod/handle_atom_del(atom/A)
	if(A == occupant)
		occupant = null
		countdown.stop()

/obj/machinery/clonepod/proc/horrifyingsound()
	for(var/i in 1 to 5)
		playsound(src,pick('sound/hallucinations/growl1.ogg','sound/hallucinations/growl2.ogg','sound/hallucinations/growl3.ogg'), 100, rand(0.95,1.05))
		sleep(0.1 SECONDS)
	sleep(1 SECONDS)
	playsound(src,'sound/hallucinations/wail.ogg', 100, TRUE)

/obj/machinery/clonepod/deconstruct(disassembled = TRUE)
	if(occupant)
		go_out()
	..()

/obj/machinery/clonepod/proc/maim_clone(mob/living/carbon/human/H)
	if(!unattached_flesh)
		unattached_flesh = list()
	else
		for(var/fl in unattached_flesh)
			qdel(fl)
		unattached_flesh.Cut()

	H.setCloneLoss(CLONE_INITIAL_DAMAGE)     //Yeah, clones start with very low health, not with random, because why would they start with random health
	// In addition to being cellularly damaged, they also have no limbs or internal organs.
	// Applying brainloss is done when the clone leaves the pod, so application of traumas can happen
	// based on the level of damage sustained.

	if(!HAS_TRAIT(H, TRAIT_NODISMEMBER))
		var/static/list/zones = list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
		for(var/zone in zones)
			var/obj/item/bodypart/BP = H.get_bodypart(zone)
			if(BP)
				BP.drop_limb()
				BP.forceMove(src)
				unattached_flesh += BP

	for(var/o in H.internal_organs)
		var/obj/item/organ/organ = o
		if(!istype(organ) || (organ.organ_flags & ORGAN_VITAL))
			continue
		organ.organ_flags |= ORGAN_FROZEN
		organ.Remove(H, special=TRUE)
		organ.forceMove(src)
		unattached_flesh += organ

	flesh_number = unattached_flesh.len

/*
 *	Manual -- A big ol' manual.
 */

/obj/item/paper/guides/jobs/medical/cloning
	name = "paper - 'H-87 Cloning Apparatus Manual"
	info = {"<h4>Getting Started</h4>
	Congratulations, your station has purchased the H-87 industrial cloning device!<br>
	Using the H-87 is almost as simple as brain surgery! Simply insert the target humanoid into the scanning chamber and select the scan option to create a new profile!<br>
	<b>That's all there is to it!</b><br>
	<i>Notice, cloning system cannot scan inorganic life or small primates.  Scan may fail if subject has suffered extreme brain damage.</i><br>
	<p>Clone profiles may be viewed through the profiles menu. Scanning implants a complementary HEALTH MONITOR IMPLANT into the subject, which may be viewed from each profile.
	Profile Deletion has been restricted to \[Station Head\] level access.</p>
	<h4>Cloning from a profile</h4>
	Cloning is as simple as pressing the CLONE option at the bottom of the desired profile.<br>
	Per your company's EMPLOYEE PRIVACY RIGHTS agreement, the H-87 has been blocked from cloning crewmembers while they are still alive.<br>
	<br>
	<p>The provided CLONEPOD SYSTEM will produce the desired clone.  Standard clone maturation times (With SPEEDCLONE technology) are roughly 90 seconds.
	The cloning pod may be unlocked early with any \[Medical Researcher\] ID after initial maturation is complete.</p><br>
	<i>Please note that resulting clones may have a small DEVELOPMENTAL DEFECT as a result of genetic drift.</i><br>
	<h4>Profile Management</h4>
	<p>The H-87 (as well as your station's standard genetics machine) can accept STANDARD DATA DISKETTES.
	These diskettes are used to transfer genetic information between machines and profiles.
	A load/save dialog will become available in each profile if a disk is inserted.</p><br>
	<i>A good diskette is a great way to counter aforementioned genetic drift!</i><br>
	<br>
	<font size=1>This technology produced under license from Thinktronic Systems, LTD.</font>"}

#undef CLONE_INITIAL_DAMAGE
#undef SPEAK
#undef MINIMUM_HEAL_LEVEL
