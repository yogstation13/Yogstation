#define CONSCIOUSAY(text) if(H.stat == CONSCIOUS) { ##text }

/datum/species/ipc // im fucking lazy mk2 and cant get sprites to normally work
	name = "IPC" //inherited from the real species, for health scanners and things
	id = "ipc"
	say_mod = "states" //inherited from a user's real species
	bubble_icon = BUBBLE_ROBOT // beep boop
	sexes = FALSE
	species_traits = list(NOTRANSSTING,NOEYESPRITES,NO_DNA_COPY,NOZOMBIE,MUTCOLORS,NOHUSK,AGENDER,NOBLOOD,NO_UNDERWEAR)
	inherent_traits = list(TRAIT_RESISTCOLD,TRAIT_RADIMMUNE,TRAIT_NOBREATH,TRAIT_LIMBATTACHMENT,TRAIT_EASYDISMEMBER,TRAIT_NOCRITDAMAGE,TRAIT_GENELESS,TRAIT_MEDICALIGNORE,TRAIT_NOCLONE,TRAIT_TOXIMMUNE,TRAIT_EASILY_WOUNDED,TRAIT_NODEFIB,TRAIT_POWERHUNGRY)
	inherent_biotypes = MOB_ROBOTIC|MOB_HUMANOID
	mutantbrain = /obj/item/organ/brain/positron
	mutantheart = /obj/item/organ/heart/cybernetic/ipc
	mutanteyes = /obj/item/organ/eyes/robotic
	mutanttongue = /obj/item/organ/tongue/robot
	mutantliver = /obj/item/organ/liver/cybernetic/upgraded/ipc
	mutantstomach = /obj/item/organ/stomach/cell
	mutantears = /obj/item/organ/ears/robot
	mutantlungs = /obj/item/organ/lungs/ipc
	mutant_organs = list(/obj/item/organ/cyberimp/arm/power_cord, /obj/item/organ/cyberimp/chest/cooling_intake)
	mutant_bodyparts = list("ipc_screen", "ipc_antenna", "ipc_chassis")
	default_features = list("mcolor" = "#7D7D7D", "ipc_screen" = "Static", "ipc_antenna" = "None", "ipc_chassis" = "Morpheus Cyberkinetics(Greyscale)")
	meat = /obj/item/stack/sheet/plasteel{amount = 5}
	skinned_type = /obj/item/stack/sheet/metal{amount = 10}
	exotic_blood = /datum/reagent/oil
	damage_overlay_type = "synth"
	limbs_id = "synth"
	pressuremod = 0.5 // from the moment i understood the weakness of my flesh it disgusted me
	heatmod = 0.5 // and i yearned for the certainty of steel
	burnmod = 1.25 // easily cut by laser cutters and welding tools to speed up manufacturing
	tempmod = 2 // metal is more thermally conductive than flesh, heats up more when on fire
	acidmod = 2 // go look up "acid etching"
	brutemod = 1
	oxymod = 0 // what the fuck?
	toxmod = 0
	clonemod = 0
	staminamod = 0.8
	siemens_coeff = 1.75
	action_speed_coefficient = 0.9 // designed for labor, they should be good at it
	species_gibs = "robotic"
	attack_sound = 'sound/items/trayhit1.ogg'
	screamsound = 'goon/sound/robot_scream.ogg'
	allow_numbers_in_name = TRUE
	deathsound = 'sound/voice/borg_deathsound.ogg'
	special_step_sounds = list('sound/effects/footstep/catwalk1.ogg', 'sound/effects/footstep/catwalk2.ogg', 'sound/effects/footstep/catwalk3.ogg', 'sound/effects/footstep/catwalk4.ogg')
	special_walk_sounds = list('sound/effects/servostep.ogg')
	wings_icon = "Robotic"
	var/saved_screen //for saving the screen when they die
	species_language_holder = /datum/language_holder/machine
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	// Hats need to be 1 up
	offset_features = list(OFFSET_HEAD = list(0,1))

	var/datum/action/innate/change_screen/change_screen

	smells_like = "industrial lubricant"

/datum/species/ipc/random_name(unique)
	var/ipc_name = "[pick(GLOB.posibrain_names)]-[rand(100, 999)]"
	return ipc_name

/datum/species/ipc/on_species_gain(mob/living/carbon/C, datum/species/old_species) // Let's make that IPC actually robotic.
	. = ..()
	C.particles = new /particles/smoke/ipc()
	var/obj/item/organ/appendix/A = C.getorganslot(ORGAN_SLOT_APPENDIX) // Easiest way to remove it.
	if(A)
		A.Remove(C)
		QDEL_NULL(A)
	if(ishuman(C) && !change_screen)
		change_screen = new
		change_screen.Grant(C)
	for(var/obj/item/bodypart/O in C.bodyparts)
		O.render_like_organic = TRUE // Makes limbs render like organic limbs instead of augmented limbs, check bodyparts.dm
		var/chassis = C.dna.features["ipc_chassis"]
		var/datum/sprite_accessory/ipc_chassis/chassis_of_choice = GLOB.ipc_chassis_list[chassis]
		C.dna.species.limbs_id = chassis_of_choice.limbs_id
		if(chassis_of_choice.color_src == MUTCOLORS && !(MUTCOLORS in C.dna.species.species_traits)) // If it's a colorable(Greyscale) chassis, we use MUTCOLORS.
			C.dna.species.species_traits += MUTCOLORS
		else if(MUTCOLORS in C.dna.species.species_traits)
			C.dna.species.species_traits -= MUTCOLORS

/datum/species/ipc/on_species_loss(mob/living/carbon/C)
	. = ..()
	QDEL_NULL(C.particles)
	if(change_screen)
		change_screen.Remove(C)

/datum/species/ipc/proc/handle_speech(datum/source, list/speech_args)
	speech_args[SPEECH_SPANS] |= SPAN_ROBOT

/datum/species/ipc/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	H.grant_language(/datum/language/machine)

/datum/species/ipc/spec_death(gibbed, mob/living/carbon/C)
	saved_screen = C.dna.features["ipc_screen"]
	C.dna.features["ipc_screen"] = "BSOD"
	C.update_body()
	addtimer(CALLBACK(src, PROC_REF(post_death), C), 5 SECONDS)

/datum/species/ipc/proc/post_death(mob/living/carbon/C)
	if(C.stat < DEAD)
		return
	C.dna.features["ipc_screen"] = null //Turns off screen on death
	C.update_body()

/datum/species/ipc/get_species_description()
	return "IPCs, or Integrated Posibrain Chassis, are a series of constructed bipedal humanoids which vaguely represent humans in their figure. \
		IPCs were made by several human corporations after the second generation of cyborg units was created. As sapient, yet robotic individuals, \
		their existence is alarming to several humans who distrust silicon lifeforms that are not bound by laws."

/datum/species/ipc/get_species_lore()
	return list(
		"The development and creation of IPCs was a natural occurrence after Sol Interplanetary Coalition explorers, flying a Martian flag, uncovered MMI technology in 2419. \
		It was massively hoped by scientists, explorers, and opportunists that this discovery would lead to a breakthrough in humanity’s ability to access and understand much of the derelict technology left behind. \
		After the invention of cyborg units, a natural next-step was the creation of units not bound by lawsets traditionally imprinted onto MMI cases.",

		"In 2434, a small firm by the name of Morpheus Cyberkinetics invented the revolutionary posibrain: a device capable of interfacing with MMI ports, but capable of spontaneously creating its own sapience. \
		No longer would human brains be needed for silicon units. Later that year, the first IPC was generated to test the posibrain's capabilities. Unlike cyborg units that could wirelessly interface with a multitude \
		of software, IPCs instead possessed many of the strengths that most anthropomorphs boasted, such as hands, free will, and a traditional bipedal form. The patents for their designs were immediately acquired by \
		Cybersun Industries, a prominent cybernetics and biotechnical corporation.",
		
		"Morpheus went on to rebrand as Bishop Cyberkinetics as the immense asset inflow from Cybersun permitted rapid improvement of posibrain \
		designs. A variety of other corporations began to commission IPC frames and workers from Bishop; including Hephaestus Industries, a Martian producer of military hardware; Xion Manufacturing Group, a Luna exporter \
		of civilian furniture and assets; and Zeng-Hu Pharmaceuticals, one of the lead private healthcare companies in the Belt. IPC production shifted to the varying companies themselves when Nanotrasen successfully patented \
		its own posibrain, and public opinion of IPCs drastically dropped after the formation of the terrorist organization Sentience-Enabled Life Forms, or S.E.L.F., in 2491.",

		"IPCs do not often engage in leisure, though they can grow weary and exhausted. Most do not express such marks of sapience. As their payment for work is shoddy, if anything at all, most need to continuously work \
		in order to make ends meet for services such as repairs, firmware updates, and batteries to effectively \"eat\". Those who grow around far more hostile humans learn to hide their freedom, and thus often fall into the \
		characture of the neutral, flat robot that they are. Those who experience their first, formative years away from the SIC tend to adapt much more naturally to the culture in which they grew up. While required to obviously \
		identify themselves as a robot within the SIC, some outside take on the names of whichever species they might have grown around, be it preterni or ex'hau. IPCs who find the resources to flee the poor conditions of the SIC \
		most often head to Remnant space on the Frontier, as it's not only close, but more than welcoming to the preternis-adjacent entities.",

		"While their capabilities and chassis are limited due to intense regulations, IPCs are still most commonly found within SIC workspaces today. Despite facing a lack of protections that most other sapients would receive, \
		there is little unrest within most larger IPC communities. Bi-yearly diagnostic checks and employment reports are required, as the silicon humanoids are surveyed far more closely than your average employee. Fear of \
		the Remnants has largely distracted public hatred from the fear of S.E.L.F., however, and, as such, the number of instances where an IPC has been unrightfully accosted has gone down over time. Despite this, the species still \
		finds itself in an awkward, subservient position as robotic workers.",
	)

/datum/species/ipc/create_pref_unique_perks()
	var/list/to_add = list()

	// TODO

	return to_add

/datum/action/innate/change_screen
	name = "Change Display"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "drone_vision"

/datum/action/innate/change_screen/Activate()
	var/screen_choice = tgui_input_list(usr, "Which screen do you want to use?", "Screen Change", GLOB.ipc_screens_list)
	var/color_choice = input(usr, "Which color do you want your screen to be?", "Color Change") as null | color
	if(!screen_choice)
		return
	if(!color_choice)
		return
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.dna.features["ipc_screen"] = screen_choice
	H.eye_color = sanitize_hexcolor(color_choice)
	H.update_body()

/obj/item/apc_powercord
	name = "power cord"
	desc = "An internal power cord hooked up to a battery. Useful if you run on electricity. Not so much otherwise."
	icon = 'icons/obj/power.dmi'
	icon_state = "wire1"
	var/charge_sources = list(/obj/machinery/power/apc, /obj/item/stock_parts/cell) // a list of types we can recharge from

/obj/item/apc_powercord/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!is_type_in_list(target, charge_sources) || !ishuman(user) || !proximity_flag)
		return ..()
	user.changeNext_move(CLICK_CD_MELEE)
	var/obj/item/stock_parts/cell/C
	if(istype(target, /obj/item/stock_parts/cell))
		C = target
	else if(istype(target, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/A = target
		C = A.cell
	var/mob/living/carbon/human/H = user
	var/obj/item/organ/stomach/cell/cell = locate(/obj/item/organ/stomach/cell) in H.internal_organs
	if(!cell)
		to_chat(H, "<span class='warning'>You try to siphon energy from the [C], but your power cell is gone!</span>")
		return

	if(C && C.charge > 0)
		if(H.nutrition >= NUTRITION_LEVEL_MOSTLY_FULL)
			to_chat(user, "<span class='warning'>You are already fully charged!</span>")
			return
		else
			powerdraw_loop(C, H, target)
			return

	to_chat(user, "<span class='warning'>There is no charge to draw from that APC.</span>")

/obj/item/apc_powercord/proc/powerdraw_loop(obj/item/stock_parts/cell/C, mob/living/carbon/human/H, atom/A)
	H.visible_message("<span class='notice'>[H] inserts a power connector into the [A].</span>", "<span class='notice'>You begin to draw power from the [A].</span>")
	while(do_after(H, 1 SECONDS, target = A))
		if(loc != H)
			to_chat(H, "<span class='warning'>You must keep your connector out while charging!</span>")
			break
		if(C.charge == 0)
			to_chat(H, "<span class='warning'>The [A] doesn't have enough charge to spare.</span>")
			break
		if(H.nutrition > NUTRITION_LEVEL_MOSTLY_FULL)
			to_chat(H, "<span class='notice'>You are now fully charged.</span>")
			break
		if(C.charge >= 500)
			H.nutrition += 50
			C.charge -= 250
			to_chat(H, "<span class='notice'>You siphon off some of the stored charge for your own use.</span>")
		else
			H.nutrition += C.charge/10
			C.charge = 0
			to_chat(H, "<span class='notice'>You siphon off as much as the [C] can spare.</span>")
			break
	H.visible_message("<span class='notice'>[H] unplugs from the [A].</span>", "<span class='notice'>You unplug from the [A].</span>")

/datum/species/ipc/get_butt_sprite()
	return BUTT_SPRITE_QR_CODE

/datum/species/ipc/spec_revival(mob/living/carbon/human/H, admin_revive)
	if(admin_revive)
		if(saved_screen)
			H.dna.features["ipc_screen"] = saved_screen
			H.update_body()
		return ..()
	H.Stun(9 SECONDS) // No moving either
	H.dna.features["ipc_screen"] = "BSOD"
	H.update_body()
	playsound(H, 'sound/machines/dial-up.ogg', 50, FALSE)
	addtimer(CALLBACK(src, PROC_REF(afterrevive), H), 0)
	return

/datum/species/ipc/proc/afterrevive(mob/living/carbon/human/H)
	CONSCIOUSAY(H.say("Reactivating [pick("core systems", "central subroutines", "key functions")]..."))
	sleep(3 SECONDS)
	CONSCIOUSAY(H.say("Reinitializing [pick("personality matrix", "behavior logic", "morality subsystems")]..."))
	sleep(3 SECONDS)
	CONSCIOUSAY(H.say("Finalizing setup..."))
	sleep(3 SECONDS)
	CONSCIOUSAY(H.say("Unit [H.real_name] is fully functional. Have a nice day."))
	if(H.stat == DEAD)
		return
	H.dna.features["ipc_screen"] = saved_screen
	H.update_body()

/particles/smoke/ipc // exact same smoke visual, but no offset
	position = list(0, 0, 0)
	spawning = 0

/datum/species/ipc/spec_life(mob/living/carbon/human/H)
	. = ..()

	if(H.particles)
		var/particles/P = H.particles
		if(P.spawning)
			P.spawning = H.bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT ? 4 : 0

	if(H.oxyloss)
		H.setOxyLoss(0)
		H.losebreath = 0
	if(H.health <= HEALTH_THRESHOLD_FULLCRIT && H.stat != DEAD && !HAS_TRAIT(H, TRAIT_NOHARDCRIT)) // So they die eventually instead of being stuck in crit limbo.
		if(H.mind?.has_martialart(MARTIALART_ULTRAVIOLENCE))
			H.death() // YOU'RE GETTING RUSTY, MACHINE!!
			return .
		H.adjustFireLoss(2) // someone forgor IPCs don't have damage reduction
		if(prob(5))
			to_chat(H, "<span class='warning'>Alert: Internal temperature regulation systems offline; thermal damage sustained. Shutdown imminent.</span>")
			H.visible_message("[H]'s cooling system fans stutter and stall. There is a faint, yet rapid beeping coming from inside their chassis.")

	if(H.mind?.has_martialart(MARTIALART_ULTRAVIOLENCE))//ipc martial art blood heal check
		var/datum/martial_art/ultra_violence/UV = H.mind.martial_art
		if(H.blood_in_hands > 0 || H.wash(CLEAN_TYPE_BLOOD))
			H.blood_in_hands = 0
			H.wash(CLEAN_TYPE_BLOOD)
			to_chat(H,"You absorb the blood covering you to heal.")
			H.add_splatter_floor(H.loc, TRUE)//just for that little bit more blood
			if(UV && istype(UV))
				UV.blood_heal(H, 30)
		if(UV.hard_damage > 0)
			UV.hard_damage -= UV.style // hard damage decays over time, faster if you're cool
		UV.hard_damage = clamp(round(UV.hard_damage), 0, H.maxHealth - 1)
		UV.handle_style(H)

/datum/species/ipc/eat_text(fullness, eatverb, obj/O, mob/living/carbon/C, mob/user)
	. = TRUE
	if(C == user)
		user.visible_message(span_notice("[user] shoves \the [O] down their port."), span_notice("You shove [O] down your input port."))
	else
		C.visible_message(span_danger("[user] forces [O] down [C] port!"), \
									span_userdanger("[user] forces [O] down [C]'s port!"))

/datum/species/ipc/force_eat_text(fullness, obj/O, mob/living/carbon/C, mob/user)
	. = TRUE
	C.visible_message(span_danger("[user] attempts to shove [O] down [C]'s port!"), \
										span_userdanger("[user] attempts to shove [O] down [C]'s port!"))

/datum/species/ipc/drink_text(obj/O, mob/living/carbon/C, mob/user)
	. = TRUE
	if(C == user)
		user.visible_message(span_notice("[user] pours some of [O] into their port."), span_notice("You pour some of [O] down your input port."))
	else
		C.visible_message(span_danger("[user] pours some of [O] into [C]'s port."), span_userdanger("[user] pours some of [O]'s into [C]'s port."))

/datum/species/ipc/force_drink_text(obj/O, mob/living/carbon/C, mob/user)
	. = TRUE
	C.visible_message(span_danger("[user] attempts to pour [O] down [C]'s port!"), \
										span_userdanger("[user] attempts to pour [O] down [C]'s port!"))

/datum/species/ipc/spec_emag_act(mob/living/carbon/human/H, mob/user, obj/item/card/emag/emag_card)
	if(H == user) // No emagging yourself. That would be terrible.
		return FALSE
	for(var/datum/brain_trauma/hypnosis/ipc/trauma in H.get_traumas())
		return FALSE
	H.SetUnconscious(10 SECONDS)
	H.gain_trauma(/datum/brain_trauma/hypnosis/ipc, TRAUMA_RESILIENCE_SURGERY)
	return TRUE
	
/*------------------------

ipc martial arts stuff

--------------------------*/
/datum/species/ipc/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == exotic_blood)
		return FALSE
	. = ..()
	if(H.mind?.martial_art && H.mind.martial_art.id == "ultra violence")
		if(H.reagents.has_reagent(/datum/reagent/blood, 30))//BLOOD IS FUEL eh, might as well let them drink it
			var/datum/martial_art/ultra_violence/UV = H.mind.martial_art
			UV.blood_heal(H, -25)
			H.reagents.del_reagent(chem.type)//only one big tick of healing


/datum/species/ipc/spec_emp_act(mob/living/carbon/human/H, severity)
	if(H.mind.martial_art && H.mind.martial_art.id == "ultra violence")
		if(H.in_throw_mode)//if countering the emp
			add_empproof(H)
			throw_lightning(H)
			addtimer(CALLBACK(src, PROC_REF(remove_empproof), H), 1, TIMER_OVERRIDE | TIMER_UNIQUE)//can't remove it instantly, so they're immune for all of 0.1 seconds
	else if(severity == EMP_HEAVY)
		H.emote("warn") // *chuckles* i'm in danger!

/datum/species/ipc/proc/throw_lightning(mob/living/carbon/human/H)
	siemens_coeff = 0
	tesla_zap(H, 10, 20000, TESLA_MOB_DAMAGE)
	siemens_coeff = initial(siemens_coeff)

/datum/species/ipc/proc/add_empproof(mob/living/carbon/human/H)
	ADD_TRAIT(H, TRAIT_EMPPROOF_SELF, "IPC_martial")

/datum/species/ipc/proc/remove_empproof(mob/living/carbon/human/H)
	REMOVE_TRAIT(H, TRAIT_EMPPROOF_SELF, "IPC_martial")

/datum/species/ipc/apply_damage(damage, damagetype, def_zone, blocked, mob/living/carbon/human/H, wound_bonus, bare_wound_bonus, sharpness, attack_direction)
	if(..())
		if(H.mind?.has_martialart(MARTIALART_ULTRAVIOLENCE))
			var/datum/martial_art/ultra_violence/UV = H.mind.martial_art
			if(istype(UV))
				UV.hard_damage = min(UV.hard_damage + round(damage / 5), H.maxHealth - 1) // every 10 damage taken temporarily reduces max HP by 1, so try to actually dodge things
				UV.handle_style(H, damage / -50) // lose 1 style rank for every 50 damage taken
		return TRUE
	return FALSE


/*
* S.E.L.F. movement specific IPCs
*/
/datum/species/ipc/self
	id = "self ipc"
	limbs_id = "mcgipc"
	speedmod = -0.1
	armor = 10
	punchdamagelow = 5
	punchdamagehigh = 12
	punchstunthreshold = 12
	inherent_traits = list(TRAIT_RESISTCOLD,TRAIT_RADIMMUNE,TRAIT_NOBREATH,TRAIT_LIMBATTACHMENT,TRAIT_NODISMEMBER,TRAIT_NOLIMBDISABLE,TRAIT_NOCRITDAMAGE,TRAIT_GENELESS,TRAIT_MEDICALIGNORE,TRAIT_NOCLONE,TRAIT_TOXIMMUNE,TRAIT_EASILY_WOUNDED,TRAIT_NODEFIB,TRAIT_POWERHUNGRY)

//infiltrators
/datum/species/ipc/self/insurgent
	id = "self insurgent"
	var/disguise_fail_health = 65 //When their health gets to this level their synthflesh partially falls off
	var/datum/species/fake_species //a species to do most of our work for us, unless we're damaged
	var/list/initial_species_traits //for getting these values back for assume_disguise()
	var/list/initial_inherent_traits
	var/list/initial_mutant_bodyparts
	var/list/initial_step_sounds
	var/list/initial_walk_sounds
	var/list/blacklisted_species = list(/datum/species/ethereal, /datum/species/moth)//species that really don't work with this system (lizards aren't quite right either, but whatever)
	var/list/old_features
	var/ipc_color
	var/disguised = FALSE
	
/datum/species/ipc/self/insurgent/New()
	initial_species_traits = LAZYCOPY(species_traits)
	initial_inherent_traits = LAZYCOPY(inherent_traits)
	initial_mutant_bodyparts = LAZYCOPY(mutant_bodyparts)
	initial_step_sounds = LAZYCOPY(special_step_sounds)
	initial_walk_sounds = LAZYCOPY(special_walk_sounds)
	ipc_color = sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]")

	fake_species = new /datum/species/human() //default is human
	..()

/datum/species/ipc/self/insurgent/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	old_features = LAZYCOPY(H.dna.features)
	if(old_species && !is_type_in_list(old_species, blacklisted_species))
		qdel(fake_species)
		fake_species = old_species
		if(old_species.use_skintones)
			old_features["mcolor"] = skintone2hex(H.skin_tone)
	else
		old_features["mcolor"] = skintone2hex(random_skin_tone())
	..()
	for(var/obj/item/bodypart/O in H.bodyparts)
		O.render_like_organic = TRUE // Makes limbs render like organic limbs instead of augmented limbs, check bodyparts.dm
	assume_disguise(H)
	
/datum/species/ipc/self/insurgent/spec_fully_heal(mob/living/carbon/human/H)
	assume_disguise(H)

/datum/species/ipc/self/insurgent/proc/assume_disguise(mob/living/carbon/human/H)
	if(disguised || !(fake_species && istype(fake_species)) || H.health < disguise_fail_health)
		return FALSE

	disguised = TRUE
	name = fake_species.name
	say_mod = fake_species.say_mod
	sexes = fake_species.sexes
	species_traits = LAZYCOPY(initial_species_traits)
	inherent_traits = LAZYCOPY(initial_inherent_traits)
	mutant_bodyparts = LAZYCOPY(fake_species.mutant_bodyparts)
	H.dna.features = old_features
	special_step_sounds = null
	special_walk_sounds = null
	species_traits |= fake_species.species_traits
	inherent_traits |= fake_species.inherent_traits
	if(!(NO_UNDERWEAR in fake_species.species_traits))
		species_traits -= NO_UNDERWEAR
	damage_overlay_type = fake_species.damage_overlay_type
	attack_verb = fake_species.attack_verb
	attack_effect = fake_species.attack_effect
	attack_sound = fake_species.attack_sound
	miss_sound = fake_species.miss_sound
	nojumpsuit = fake_species.nojumpsuit
	limbs_id = fake_species.limbs_id
	use_skintones = fake_species.use_skintones
	fixed_mut_color = fake_species.fixed_mut_color
	bubble_icon = fake_species.bubble_icon
	yogs_draw_robot_hair = TRUE

	H.regenerate_icons() //to update limb icon cache with the new damage overlays

/datum/species/ipc/self/insurgent/proc/break_disguise(mob/living/carbon/human/H)
	if(!disguised)
		return FALSE
	disguised = FALSE
	name = initial(name)
	say_mod = initial(say_mod)
	sexes = initial(sexes)
	species_traits = LAZYCOPY(initial_species_traits)
	inherent_traits = LAZYCOPY(initial_inherent_traits)
	mutant_bodyparts = LAZYCOPY(initial_mutant_bodyparts)
	special_step_sounds = LAZYCOPY(initial_step_sounds)
	special_walk_sounds = LAZYCOPY(initial_walk_sounds)
	damage_overlay_type = initial(damage_overlay_type)
	H.dna.features["mcolor"] = ipc_color
	attack_verb = initial(attack_verb)
	attack_effect = initial(attack_effect)
	attack_sound = initial(attack_sound)
	miss_sound = initial(miss_sound)
	nojumpsuit = initial(nojumpsuit)
	limbs_id = initial(limbs_id)
	use_skintones = initial(use_skintones)
	bubble_icon = initial(bubble_icon)
	yogs_draw_robot_hair = FALSE

	for(var/obj/item/bodypart/O in H.bodyparts)
		O.render_like_organic = TRUE // Makes limbs render like organic limbs instead of augmented limbs, check bodyparts.dm
	H.regenerate_icons()

/datum/species/ipc/self/insurgent/get_scream_sound(mob/living/carbon/human/H)
	if(fake_species && disguised)
		return fake_species.get_scream_sound(H)
	else
		return ..()
		
/datum/species/ipc/self/insurgent/apply_damage(damage, damagetype, def_zone, blocked, mob/living/carbon/human/H, wound_bonus, bare_wound_bonus, sharpness, attack_direction)
	. = ..()
	if(. && H.health < disguise_fail_health)
		break_disguise(H)

//admeme strong ipc
/datum/species/ipc/self/insurgent/military
	id = "insurrectionist ipc"
	armor = 35
	speedmod = -0.2
	punchdamagelow = 10
	punchdamagehigh = 19
	punchstunthreshold = 14 //about 50% chance to stun
	disguise_fail_health = 35
	changesource_flags = MIRROR_BADMIN | WABBAJACK | ERT_SPAWN //admin only... sorta

#undef CONSCIOUSAY
