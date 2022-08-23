//These mutations change your overall "form" somehow, like size

//Epilepsy gives a very small chance to have a seizure every life tick, knocking you unconscious.
/datum/mutation/human/epilepsy
	name = "Epilepsy"
	desc = "A genetic defect that sporadically causes seizures."
	quality = NEGATIVE
	text_gain_indication = span_danger("You get a headache.")
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/human/epilepsy/on_life()
	if(prob(1 * GET_MUTATION_SYNCHRONIZER(src)) && owner.stat == CONSCIOUS)
		owner.visible_message(span_danger("[owner] starts having a seizure!"), span_userdanger("You have a seizure!"))
		owner.Unconscious(200 * GET_MUTATION_POWER(src))
		owner.Jitter(1000 * GET_MUTATION_POWER(src))
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "epilepsy", /datum/mood_event/epilepsy)
		addtimer(CALLBACK(src, .proc/jitter_less), 90)

/datum/mutation/human/epilepsy/proc/jitter_less()
	if(owner)
		owner.jitteriness = 10


//Unstable DNA induces random mutations!
/datum/mutation/human/bad_dna
	name = "Unstable DNA"
	desc = "Strange mutation that causes the holder to randomly mutate."
	quality = NEGATIVE
	text_gain_indication = span_danger("You feel strange.")
	locked = TRUE

/datum/mutation/human/bad_dna/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	to_chat(owner, text_gain_indication)
	var/mob/new_mob
	if(prob(95))
		if(prob(50))
			new_mob = owner.easy_randmut(NEGATIVE + MINOR_NEGATIVE)
		else
			new_mob = owner.randmuti()
	else
		new_mob = owner.easy_randmut(POSITIVE)
	if(new_mob && ismob(new_mob))
		owner = new_mob
	. = owner
	on_losing(owner)


//Cough gives you a chronic cough that causes you to drop items.
/datum/mutation/human/cough
	name = "Cough"
	desc = "A chronic cough."
	quality = MINOR_NEGATIVE
	text_gain_indication = span_danger("You start coughing.")
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/human/cough/on_life()
	if(prob(5 * GET_MUTATION_SYNCHRONIZER(src)) && owner.stat == CONSCIOUS)
		owner.drop_all_held_items()
		owner.emote("cough")
		if(GET_MUTATION_POWER(src) > 1)
			var/cough_range = GET_MUTATION_POWER(src) * 4
			var/turf/target = get_ranged_target_turf(owner, turn(owner.dir, 180), cough_range)
			owner.throw_at(target, cough_range, GET_MUTATION_POWER(src))

/datum/mutation/human/paranoia
	name = "Paranoia"
	desc = "Subject is easily terrified, and may suffer from hallucinations."
	quality = NEGATIVE
	text_gain_indication = span_danger("You feel screams echo through your mind...")
	text_lose_indication = "<span class'notice'>The screaming in your mind fades.</span>"

/datum/mutation/human/paranoia/on_life()
	if(prob(5) && owner.stat == CONSCIOUS)
		owner.emote("scream")
		if(prob(25))
			owner.hallucination += 20

//Dwarfism shrinks your body and lets you pass tables.
/datum/mutation/human/dwarfism
	name = "Dwarfism"
	desc = "A mutation believed to be the cause of dwarfism."
	quality = POSITIVE
	difficulty = 16
	instability = 5
	conflicts = list(GIGANTISM)
	locked = TRUE    // Default intert species for now, so locked from regular pool.

/datum/mutation/human/dwarfism/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	var/matrix/new_transform = matrix()
	new_transform.Scale(1, 0.8)
	owner.transform = new_transform.Multiply(owner.transform)
	passtable_on(owner, GENETIC_MUTATION)
	owner.visible_message(span_danger("[owner] suddenly shrinks and grows a beard!"), span_notice("Everything around you seems to grow.."))
	grow_beard(owner)

/datum/mutation/human/dwarfism/proc/grow_beard(mob/living/carbon/human/owner)
	var/mob/living/carbon/human/H = owner
	to_chat(H, span_warning("Your chin itches."))
	H.facial_hair_style = "Beard (Dwarf)"
	H.update_hair()

/datum/mutation/human/dwarfism/on_life()
	if(owner.facial_hair_style != "Beard (Dwarf)")
		grow_beard(owner)

/datum/mutation/human/dwarfism/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	var/matrix/new_transform = matrix()
	new_transform.Scale(1, 1.25)
	owner.transform = new_transform.Multiply(owner.transform)
	passtable_off(owner, GENETIC_MUTATION)
	owner.visible_message(span_danger("[owner] suddenly grows!"), span_notice("Everything around you seems to shrink.."))


//Clumsiness has a very large amount of small drawbacks depending on item.
/datum/mutation/human/clumsy
	name = "Clumsiness"
	desc = "A genome that inhibits certain brain functions, causing the holder to appear clumsy. Honk!"
	quality = MINOR_NEGATIVE
	text_gain_indication = span_danger("You feel lightheaded.")

/datum/mutation/human/clumsy/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_CLUMSY, GENETIC_MUTATION)

/datum/mutation/human/clumsy/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_CLUMSY, GENETIC_MUTATION)


//Tourettes causes you to randomly stand in place and shout.
/datum/mutation/human/tourettes
	name = "Tourette's Syndrome"
	desc = "A chronic twitch that forces the user to scream bad words." //definitely needs rewriting
	quality = NEGATIVE
	text_gain_indication = span_danger("You twitch.")
	synchronizer_coeff = 1

/datum/mutation/human/tourettes/on_life()
	if(prob(10 * GET_MUTATION_SYNCHRONIZER(src)) && owner.stat == CONSCIOUS && !owner.IsStun())
		owner.Stun(200)
		switch(rand(1, 3))
			if(1)
				owner.emote("twitch")
			if(2 to 3)
				owner.say("[prob(50) ? ";" : ""][pick("SHIT", "PISS", "FUCK", "CUNT", "COCKSUCKER", "MOTHERFUCKER", "TITS")]", forced="tourette's syndrome")
		var/x_offset_old = owner.pixel_x
		var/y_offset_old = owner.pixel_y
		var/x_offset = owner.pixel_x + rand(-2,2)
		var/y_offset = owner.pixel_y + rand(-1,1)
		animate(owner, pixel_x = x_offset, pixel_y = y_offset, time = 0.1 SECONDS)
		animate(owner, pixel_x = x_offset_old, pixel_y = y_offset_old, time = 0.1 SECONDS)


//Deafness makes you deaf.
/datum/mutation/human/deaf
	name = "Deafness"
	desc = "The holder of this genome is completely deaf."
	quality = NEGATIVE
	text_gain_indication = span_danger("You can't seem to hear anything.")

/datum/mutation/human/deaf/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_DEAF, GENETIC_MUTATION)

/datum/mutation/human/deaf/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_DEAF, GENETIC_MUTATION)


//Monified turns you into a monkey.
/datum/mutation/human/race
	name = "Monkified"
	desc = "A strange genome, believing to be what differentiates monkeys from humans."
	quality = NEGATIVE
	time_coeff = 2
	locked = TRUE //Species specific, keep out of actual gene pool

/datum/mutation/human/race/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	. = owner.monkeyize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPORGANS | TR_KEEPDAMAGE | TR_KEEPVIRUS | TR_KEEPSTUNS | TR_KEEPREAGENTS | TR_KEEPSE)

/datum/mutation/human/race/on_losing(mob/living/carbon/monkey/owner)
	if(owner && istype(owner) && owner.stat != DEAD && (owner.dna.mutations.Remove(src)))
		. = owner.humanize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPORGANS | TR_KEEPDAMAGE | TR_KEEPVIRUS | TR_KEEPSTUNS | TR_KEEPREAGENTS | TR_KEEPSE)

/datum/mutation/human/glow
	name = "Glowy"
	desc = "You permanently emit a light with a random color and intensity."
	quality = POSITIVE
	text_gain_indication = span_notice("Your skin begins to glow softly.")
	instability = 5
	var/obj/effect/dummy/luminescent_glow/glowth //shamelessly copied from luminescents
	var/glow = 3.5
	var/range = 2.5
	var/color
	power_coeff = 1
	conflicts = list(/datum/mutation/human/glow/anti)

/datum/mutation/human/glow/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	glowth = new(owner)
	modify()

/datum/mutation/human/glow/modify()
	if(!glowth)
		return
	var/power = GET_MUTATION_POWER(src)
	if(owner.dna.features["mcolor"][1] != "#")
		//if it doesn't start with a pound, it needs that for the color
		color += "#"
	if(length(owner.dna.features["mcolor"]) < 6)
		//this atrocity converts shorthand hex rgb back into full hex that's required for light to be given a functional value
		color += owner.dna.features["mcolor"][1] + owner.dna.features["mcolor"][1] + owner.dna.features["mcolor"][2] + owner.dna.features["mcolor"][2] + owner.dna.features["mcolor"][3] + owner.dna.features["mcolor"][3]
	else
		color += owner.dna.features["mcolor"]
	glowth.set_light(range * power, glow * power, color)

/datum/mutation/human/glow/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	QDEL_NULL(glowth)

/datum/mutation/human/glow/anti
	name = "Anti-Glow"
	desc = "Your skin seems to attract and absorb nearby light creating 'darkness' around you."
	text_gain_indication = span_notice("Your light around you seems to disappear.")
	glow = -3.5
	conflicts = list(/datum/mutation/human/glow)
	locked = TRUE

/datum/mutation/human/thickskin
	name = "Thick skin"
	desc = "The user's skin acquires a leathery texture, and becomes more resilient to harm."
	quality = POSITIVE
	text_gain_indication = span_notice("Your skin feels dry and heavy.")
	text_lose_indication = span_notice("Your skin feels soft again...")
	difficulty = 18
	instability = 30

/datum/mutation/human/thickskin/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(owner.physiology)
		owner.physiology.brute_mod *= 0.8
		owner.physiology.burn_mod *= 0.9

/datum/mutation/human/thickskin/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(owner.physiology)
		owner.physiology.brute_mod /= 0.8
		owner.physiology.burn_mod /= 0.9

//Makes strong actually useful. Somewhat.
/datum/mutation/human/strong
	name = "Strength"
	desc = "The user's muscles slightly expand, allowing them to move faster while carrying people."
	quality = POSITIVE
	text_gain_indication = span_notice("You feel strong!")
	text_lose_indication = span_notice("You feel fairly weak.")
	difficulty = 12
	instability = 10
	power_coeff = 1		//Yogs start - Strength makes you punch harder

/datum/mutation/human/strong/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	var/strength_punchpower = GET_MUTATION_POWER(src) * 2 - 1 //Normally +1, strength chromosome increases it to +2
	owner.physiology.punchdamagehigh_bonus += strength_punchpower
	owner.physiology.punchdamagelow_bonus += strength_punchpower
	owner.physiology.punchstunthreshold_bonus += strength_punchpower //So we dont change the stun chance
	ADD_TRAIT(owner, TRAIT_QUICKER_CARRY, src)

/datum/mutation/human/strong/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	var/strength_punchpower = GET_MUTATION_POWER(src) * 2 - 1
	owner.physiology.punchdamagehigh_bonus -= strength_punchpower
	owner.physiology.punchdamagelow_bonus -= strength_punchpower
	owner.physiology.punchstunthreshold_bonus -= strength_punchpower
	REMOVE_TRAIT(owner, TRAIT_QUICKER_CARRY, src)

//Yogs end

/datum/mutation/human/insulated
	name = "Insulated"
	desc = "The affected person does not conduct electricity."
	quality = POSITIVE
	text_gain_indication = span_notice("Your fingertips go numb.")
	text_lose_indication = span_notice("Your fingertips regain feeling.")
	difficulty = 16
	instability = 25
	conflicts = list(/datum/mutation/human/shock, /datum/mutation/human/shock/far)

/datum/mutation/human/insulated/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_SHOCKIMMUNE, "genetics")

/datum/mutation/human/insulated/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_SHOCKIMMUNE, "genetics")

/datum/mutation/human/fire
	name = "Fiery Sweat"
	desc = "The user's skin will randomly combust, but is generally a lot more resilient to burning."
	quality = NEGATIVE
	text_gain_indication = span_warning("You feel hot.")
	text_lose_indication = "<span class'notice'>You feel a lot cooler.</span>"
	difficulty = 14
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/human/fire/on_life()
	if(prob((1+(100-dna.stability)/10)) * GET_MUTATION_SYNCHRONIZER(src))
		owner.adjust_fire_stacks(2 * GET_MUTATION_POWER(src))
		owner.IgniteMob()

/datum/mutation/human/fire/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.physiology.burn_mod *= 0.5

/datum/mutation/human/fire/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.physiology.burn_mod *= 2

/datum/mutation/human/badblink
	name = "Spatial Instability"
	desc = "The victim of the mutation has a very weak link to spatial reality, and may be displaced. Often causes extreme nausea."
	quality = NEGATIVE
	text_gain_indication = span_warning("The space around you twists sickeningly.")
	text_lose_indication = "<span class'notice'>The space around you settles back to normal.</span>"
	difficulty = 18//high so it's hard to unlock and abuse
	instability = 10
	synchronizer_coeff = 1
	energy_coeff = 1
	power_coeff = 1
	var/warpchance = 0

/datum/mutation/human/badblink/on_life()
	if(prob(warpchance) && isturf(owner.loc))	//checks if the owner is inside something so they can't teleport out of the cloner
		var/warpmessage = pick(
		span_warning("With a sickening 720-degree twist of [owner.p_their()] back, [owner] vanishes into thin air."),
		span_warning("[owner] does some sort of strange backflip into another dimension. It looks pretty painful."),
		span_warning("[owner] does a jump to the left, a step to the right, and warps out of reality."),
		span_warning("[owner]'s torso starts folding inside out until it vanishes from reality, taking [owner] with it."),
		span_warning("One moment, you see [owner]. The next, [owner] is gone."))
		owner.visible_message(warpmessage, span_userdanger("You feel a wave of nausea as you fall through reality!"))
		var/warpdistance = rand(10,15) * GET_MUTATION_POWER(src)
		do_teleport(owner, get_turf(owner), warpdistance, channel = TELEPORT_CHANNEL_FREE)
		owner.adjust_disgust(GET_MUTATION_SYNCHRONIZER(src) * (warpchance * warpdistance) * 0.2)
		warpchance = 0
		owner.visible_message(span_danger("[owner] appears out of nowhere!"))
	else
		warpchance += 0.25 * GET_MUTATION_ENERGY(src)

/datum/mutation/human/acidflesh
	name = "Acidic Flesh"
	desc = "Subject has acidic chemicals building up underneath the skin. This is often lethal."
	quality = NEGATIVE
	text_gain_indication = span_userdanger("A horrible burning sensation envelops you as your flesh turns to acid!")
	text_lose_indication = "<span class'notice'>A feeling of relief fills you as your flesh goes back to normal.</span>"
	difficulty = 18//high so it's hard to unlock and use on others
	var/msgcooldown = 0

/datum/mutation/human/acidflesh/on_life()
	if(prob(25))
		if(world.time > msgcooldown)
			to_chat(owner, span_danger("Your acid flesh bubbles..."))
			msgcooldown = world.time + 200
		if(prob(15))
			owner.acid_act(rand(30,50), 10)
			owner.visible_message(span_warning("[owner]'s skin bubbles and pops."), span_userdanger("Your bubbling flesh pops! It burns!"))
			playsound(owner,'sound/weapons/sear.ogg', 50, 1)

/datum/mutation/human/gigantism
	name = "Gigantism"//negative version of dwarfism
	desc = "The cells within the subject spread out to cover more area, making the subject appear larger."
	quality = MINOR_NEGATIVE
	difficulty = 12
	conflicts = list(DWARFISM)

/datum/mutation/human/gigantism/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.resize = 1.25
	owner.update_transform()
	owner.visible_message(span_danger("[owner] suddenly grows!"), span_notice("Everything around you seems to shrink.."))

/datum/mutation/human/gigantism/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.resize = 0.8
	owner.update_transform()
	owner.visible_message(span_danger("[owner] suddenly shrinks!"), span_notice("Everything around you seems to grow.."))

/datum/mutation/human/spastic
	name = "Spastic"
	desc = "Subject suffers from muscle spasms."
	quality = NEGATIVE
	text_gain_indication = span_warning("You flinch.")
	text_lose_indication = "<span class'notice'>Your flinching subsides.</span>"
	difficulty = 16

/datum/mutation/human/spastic/on_acquiring()
	if(..())
		return
	owner.apply_status_effect(STATUS_EFFECT_SPASMS)

/datum/mutation/human/spastic/on_losing()
	if(..())
		return
	owner.remove_status_effect(STATUS_EFFECT_SPASMS)

/datum/mutation/human/extrastun
	name = "Two Left Feet"
	desc = "A mutation that replaces the right foot with another left foot. It makes standing up after getting knocked down very difficult."
	quality = NEGATIVE
	text_gain_indication = span_warning("Your right foot feels... left.")
	text_lose_indication = "<span class'notice'>Your right foot feels alright.</span>"
	difficulty = 16
	var/stun_cooldown = 0

/datum/mutation/human/extrastun/on_life()
	if(world.time > stun_cooldown)
		if(owner.AmountKnockdown() || owner.AmountStun())
			owner.SetKnockdown(owner.AmountKnockdown()*2)
			owner.SetStun(owner.AmountStun()*2)
			owner.visible_message(span_danger("[owner] tries to stand up, but trips!"), span_userdanger("You trip over your own feet!"))
			stun_cooldown = world.time + 300

/datum/mutation/human/hypermarrow
	name = "Hyperactive Bone Marrow"
	desc = "A mutation that stimulates the subject's bone marrow causes it to work three times faster than usual."
	quality = POSITIVE
	text_gain_indication = span_notice("You feel your bones ache for a moment.")
	text_lose_indication = span_notice("You feel something in your bones calm down.")
	difficulty = 12
	instability = 20
	power_coeff = 1

/datum/mutation/human/hypermarrow/on_life()
	if(owner.blood_volume < BLOOD_VOLUME_NORMAL(owner))
		owner.blood_volume += GET_MUTATION_POWER(src) * 2 - 1
		owner.adjust_nutrition((GET_MUTATION_POWER(src) * 2 - 0.8) * HUNGER_FACTOR)

/datum/mutation/human/densebones
	name = "Bone Densification"
	desc = "A mutation that gives the subject a rare form of increased bone density, making their entire body slightly more resilient to low kinetic blows."
	quality = POSITIVE
	text_gain_indication = span_notice("You feel your bones get denser.")
	text_lose_indication = span_notice("You feel your bones get lighter.")
	difficulty = 16
	instability = 25
	power_coeff = 1

/datum/mutation/human/densebones/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.physiology.armor.melee += 5
	owner.physiology.armor.wound += 10
	if(GET_MUTATION_POWER(src) > 1)
		ADD_TRAIT(owner, TRAIT_HARDLY_WOUNDED, "genetics")

/datum/mutation/human/densebones/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.physiology.armor.melee -= 5
	owner.physiology.armor.wound -= 10
	if(GET_MUTATION_POWER(src) > 1)
		REMOVE_TRAIT(owner, TRAIT_HARDLY_WOUNDED, "genetics")

/datum/mutation/human/cerebral
	name = "Cerebral Neuroplasticity"
	desc = "A mutation that reorganizes the subject's brain, giving them more stamina while allowing for a slightly quicker recovery speed if exhausted."
	quality = POSITIVE
	locked = TRUE
	text_gain_indication = span_notice("You feel your brain get sturdier.")
	text_lose_indication = span_notice("You feel your brain getting weaker. ")
	instability = 70

/datum/mutation/human/cerebral/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.physiology.stamina_mod *= 0.7
	owner.physiology.stun_mod *= 0.85

/datum/mutation/human/cerebral/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.physiology.stamina_mod /= 0.7
	owner.physiology.stun_mod /= 0.85
	
/datum/mutation/overload
	name = "Overload"
	desc = "Allows an Ethereal to overload their skin to cause a bright flash."
	quality = POSITIVE
	locked = TRUE
	text_gain_indication = "<span class='notice'>Your skin feels more crackly.</span>"
	instability = 30
	power = /obj/effect/proc_holder/spell/self/overload
	species_allowed = list(SPECIES_ETHEREAL)

/obj/effect/proc_holder/spell/self/overload
	name = "Overload"
	desc = "Concentrate to make your skin energize."
	clothes_req = FALSE
	human_req = FALSE
	charge_max = 400
	action_icon_state = "blind"
	var/max_distance = 4

/obj/effect/proc_holder/spell/self/overload/cast(mob/user = usr)
	if(!isethereal(user))
		return

	var/list/mob/targets = oviewers(max_distance, get_turf(user))
	visible_message("<span class='disarm'>[user] emits a blinding light!</span>")
	for(var/mob/living/carbon/C in targets)
		if(C.flash_act(1))
			C.Paralyze(10 + (5*max_distance))

/datum/mutation/overload/modify()
	if(power)
		var/obj/effect/proc_holder/spell/self/overload/S = power
		S.max_distance = 4 * GET_MUTATION_POWER(src)
	

/datum/mutation/human/catclaws
	name = "Cat Claws"
	desc = "Subject's hands grow sharpened claws."
	quality = POSITIVE
	difficulty = 12
	instability = 25
	species_allowed = list(SPECIES_FELINID)
	var/added_damage = 6

/datum/mutation/human/catclaws/on_acquiring()
	if(..())
		return
	added_damage = min(17, 6 * GET_MUTATION_POWER(src) + owner.dna.species.punchdamage)
	owner.dna.species.punchdamage += added_damage
	to_chat(owner, "<span class='notice'>Claws extend from your fingertips.</span>")
	owner.dna.species.attack_verb = "slash"

/datum/mutation/human/catclaws/on_losing()
	if(..())
		return
	owner.dna.species.punchdamage -= added_damage
	to_chat(owner, "<span class='warning'> Your claws retract into your hand.</span>")
	owner.dna.species.attack_verb = initial(owner.dna.species.attack_verb)
