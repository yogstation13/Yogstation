/datum/religion_rites
	var/name = "religious rite" // name of the religious rite
	var/desc = "immm gonna rooon" // Description of the religious rite
	var/ritual_length = (10 SECONDS) // length it takes to complete the ritual
	var/list/ritual_invocations // list of invocations said (strings) throughout the rite
	var/invoke_msg // message when you invoke
	var/favor_cost = 0

/datum/religion_rites/New()
	. = ..()
	if(!GLOB?.religious_sect)
		return
	LAZYADD(GLOB.religious_sect.active_rites, src)

/datum/religion_rites/Destroy()
	if(!GLOB?.religious_sect)
		return
	LAZYREMOVE(GLOB.religious_sect.active_rites, src)
	return ..()


///Called to perform the invocation of the rite, with args being the performer and the altar where it's being performed. Maybe you want it to check for something else?
/datum/religion_rites/proc/perform_rite(mob/living/user, atom/religious_tool)
	if(GLOB.religious_sect?.favor < favor_cost)
		to_chat(user, span_warning("This rite requires more favor!"))
		return FALSE
	to_chat(user, span_notice("You begin to perform the rite of [name]..."))
	if(!ritual_invocations)
		if(do_after(user, ritual_length, user))
			if(invoke_msg)
				user.say(invoke_msg, forced = "ritual")
			return TRUE
		return FALSE
	var/first_invoke = TRUE
	for(var/i in ritual_invocations)
		if(first_invoke) //instant invoke
			user.say(i)
			first_invoke = FALSE
			continue
		if(!ritual_invocations.len) //we divide so we gotta protect
			return FALSE
		if(!do_after(user, ritual_length/ritual_invocations.len, user))
			return FALSE
		user.say(i, forced = "ritual")
	if(!do_after(user, ritual_length/ritual_invocations.len, user)) //because we start at 0 and not the first fraction in invocations, we still have another fraction of ritual_length to complete
		return FALSE
	if(invoke_msg)
		user.say(invoke_msg, forced = "ritual")
	return TRUE


///Does the thing if the rite was successfully performed. return value denotes that the effect successfully (IE a harm rite does harm)
/datum/religion_rites/proc/invoke_effect(mob/living/user, atom/religious_tool)
	GLOB.religious_sect.on_riteuse(user,religious_tool)
	return TRUE


/*********Technophiles**********/

/datum/religion_rites/synthconversion
	name = "Synthetic Conversion"
	desc = "Convert a human-esque individual into a (superior) Android."
	ritual_length = 30 SECONDS
	ritual_invocations = list(
	"By the inner workings of our god...",
	"... We call upon you, in the face of adversity...",
	"... to complete us, removing that which is undesirable..."
	)
	invoke_msg = "... Arise, our champion! Become that which your soul craves, live in the world as your true form!!"
	favor_cost = 350

/datum/religion_rites/synthconversion/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(!LAZYLEN(movable_reltool.buckled_mobs))
		. = FALSE
		if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
			to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
			return
		to_chat(user, span_warning("This rite requires an individual to be buckled to [movable_reltool]."))
		return
	return ..()

/datum/religion_rites/synthconversion/invoke_effect(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool?.buckled_mobs?.len)
		return FALSE
	var/mob/living/carbon/human/human2borg
	for(var/i in movable_reltool.buckled_mobs)
		if(istype(i,/mob/living/carbon/human))
			human2borg = i
			break
	if(!human2borg)
		return FALSE
	human2borg.set_species(/datum/species/android)
	human2borg.visible_message(span_notice("[human2borg] has been converted by the rite of [name]!"))
	return TRUE

/datum/religion_rites/machine_blessing
	name = "Receive Blessing"
	desc = "Receive a blessing from the machine god to further your ascension."
	ritual_length = 5 SECONDS
	ritual_invocations =list( "Let your will power our forges.",
							"...Help us in our great conquest!")
	invoke_msg = "The end of flesh is near!"
	favor_cost = 200

/datum/religion_rites/machine_blessing/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/altar_turf = get_turf(religious_tool)
	var/blessing = pick(
					/obj/item/organ/cyberimp/arm/toolset/surgery,
					/obj/item/organ/cyberimp/eyes/hud/diagnostic,
					/obj/item/organ/cyberimp/eyes/hud/medical,
					/obj/item/organ/cyberimp/mouth/breathing_tube,
					/obj/item/organ/cyberimp/chest/thrusters,
					/obj/item/organ/eyes/robotic/glow)
	new blessing(altar_turf)
	return TRUE

/datum/religion_rites/botcreation
	name = "Lesser Robotic Manufacturing"
	desc = "Manufacture a robotic companion."
	ritual_length = 45 SECONDS
	ritual_invocations = list(
	"I call upon the machine spirits, aid me in creation...",
	"... The energy shall take the form of its shell...")
	invoke_msg = "...AND LET IT BE BORN!!"
	favor_cost = 50 // two bluespace cells, 80MJ. needs sci and mining to be competent.

/datum/religion_rites/botcreation/invoke_effect(atom/religious_tool, mob/user)
	var/altar_turf = get_turf(religious_tool)
	var/chosenbot = pick(/mob/living/simple_animal/bot/medbot, /mob/living/simple_animal/bot/cleanbot, /mob/living/simple_animal/bot/firebot, /obj/item/drone_shell) // nothing too bad.
	new chosenbot(altar_turf)
	return TRUE

/*********Capitalists**********/

/*
* this rites makes you into a non converting capitalist golem for 10000 favor
*/
/datum/religion_rites/toppercent
	name = "Reaching the Top Percent"
	desc = "Help a moneybag to get even richer."
	ritual_length = 30 SECONDS
	ritual_invocations = list("%Money, money, money...",
						"%... Must be funny...",
						"%... In the rich man's world...")
	invoke_msg = "... Wait, it worked?"
	favor_cost = 10000

/*
* this rites gives you some snazzy looking clothes for 100 favor
*/
/datum/religion_rites/looks
	name = "Gonna look like it"
	desc = "From rags to riches? Better get rid of the rags then!"
	ritual_length = 0.5 MINUTES
	invoke_msg = "Please, all i want are some nice clothes..."
	favor_cost = 100

/datum/religion_rites/looks/invoke_effect(atom/religious_tool, mob/user)
	var/location = get_turf(user)
	new /obj/item/clothing/head/that(location)
	new /obj/item/clothing/glasses/monocle(location)
	new /obj/item/clothing/under/yogs/victorianvest(location)
	return TRUE

/datum/religion_rites/toppercent/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(!LAZYLEN(movable_reltool.buckled_mobs))
		. = FALSE
		if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
			to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
			return
		to_chat(user, span_warning("This rite requires an individual to be buckled to [movable_reltool]."))
		return
	return ..()

/datum/religion_rites/toppercent/invoke_effect(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool?.buckled_mobs?.len)
		return FALSE
	var/mob/living/carbon/human/mantomoney
	for(var/i in movable_reltool.buckled_mobs)
		if(istype(i,/mob/living/carbon/human))
			mantomoney = i
			break
	if(!mantomoney)
		return FALSE
	mantomoney.set_species(/datum/species/golem/church_capitalist)
	mantomoney.visible_message(span_notice("[mantomoney] has ascended to the top of society!"))
	return TRUE

/*********Ever-Burning Candle**********/

///apply a bunch of fire immunity effect to clothing
/datum/religion_rites/fireproof/proc/apply_fireproof(obj/item/clothing/fireproofed)
	fireproofed.name = "unmelting [fireproofed.name]"
	fireproofed.max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	fireproofed.heat_protection = chosen_clothing.body_parts_covered
	fireproofed.resistance_flags |= FIRE_PROOF

/datum/religion_rites/fireproof
	name = "Unmelting Wax"
	desc = "Grants fire immunity to any piece of clothing."
	ritual_length = 15 SECONDS
	ritual_invocations = list("And so to support the holder of the Ever-Burning candle...",
	"... allow this unworthy apparel to serve you ...",
	"... make it strong enough to burn a thousand time and more ...")
	invoke_msg = "... Come forth in your new form, and join the unmelting wax of the one true flame!"
	favor_cost = 1000
///the piece of clothing that will be fireproofed, only one per rite
	var/obj/item/clothing/chosen_clothing

/datum/religion_rites/fireproof/perform_rite(mob/living/user, atom/religious_tool)
	for(var/obj/item/clothing/apparel in get_turf(religious_tool))
		if(apparel.max_heat_protection_temperature >= FIRE_IMMUNITY_MAX_TEMP_PROTECT)
			continue //we ignore anything that is already fireproof
		chosen_clothing = apparel //the apparel has been chosen by our lord and savior
		return ..()
	return FALSE

/datum/religion_rites/fireproof/invoke_effect(mob/living/user, atom/religious_tool)
	if(!QDELETED(chosen_clothing) && get_turf(religious_tool) == chosen_clothing.loc) //check if the same clothing is still there
		if(istype(chosen_clothing,/obj/item/clothing/suit/hooded) || istype(chosen_clothing,/obj/item/clothing/suit/space/hardsuit ))
			for(var/obj/item/clothing/head/integrated_helmet in chosen_clothing.contents) //check if the clothing has a hood/helmet integrated and fireproof it if there is one.
				apply_fireproof(integrated_helmet)
		apply_fireproof(chosen_clothing)
		playsound(get_turf(religious_tool), 'sound/magic/fireball.ogg', 50, TRUE)
		chosen_clothing = null //our lord and savior no longer cares about this apparel
		return TRUE
	chosen_clothing = null
	to_chat(user, span_warning("The clothing that was chosen for the rite is no longer on the altar!"))
	return FALSE


/datum/religion_rites/burning_sacrifice
	name = "Candle Fuel"
	desc = "Sacrifice a buckled burning corpse for favor; the more burn damage the corpse has, the more favor you will receive."
	ritual_length = 20 SECONDS
	ritual_invocations = list("To feed the fire of the one true flame ...",
	"... to make it burn brighter ...",
	"... so that it may consume all in its path ...",
	"... I offer you this pitiful being ...")
	invoke_msg = "... may it join you in the amalgamation of wax and fire, and become one in the black and white scene. "
///the burning corpse chosen for the sacrifice of the rite
	var/mob/living/carbon/chosen_sacrifice

/datum/religion_rites/burning_sacrifice/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(!LAZYLEN(movable_reltool.buckled_mobs))
		to_chat(user, span_warning("Nothing is buckled to the altar!"))
		return FALSE
	for(var/corpse in movable_reltool.buckled_mobs)
		if(!iscarbon(corpse))// only works with carbon corpse since most normal mobs can't be set on fire.
			to_chat(user, span_warning("Only carbon lifeforms can be properly burned for the sacrifice!"))
			return FALSE
		chosen_sacrifice = corpse
		if(chosen_sacrifice.stat != DEAD)
			to_chat(user, span_warning("You can only sacrifice dead bodies, this one is still alive!"))
			return FALSE
		if(!chosen_sacrifice.on_fire)
			to_chat(user, span_warning("This corpse needs to be on fire to be sacrificed!"))
			return FALSE
		return ..()

/datum/religion_rites/burning_sacrifice/invoke_effect(mob/living/user, atom/movable/religious_tool)
	if(!(chosen_sacrifice in religious_tool.buckled_mobs)) //checks one last time if the right corpse is still buckled
		to_chat(user, span_warning("The right sacrifice is no longer on the altar!"))
		chosen_sacrifice = null
		return FALSE
	if(!chosen_sacrifice.on_fire)
		to_chat(user, span_warning("The sacrifice is no longer on fire, it needs to burn until the end of the rite!"))
		chosen_sacrifice = null
		return FALSE
	if(chosen_sacrifice.stat != DEAD)
		to_chat(user, span_warning("The sacrifice has to stay dead for the rite to work!"))
		chosen_sacrifice = null
		return FALSE
	var/favor_gained = 100 + round(chosen_sacrifice.getFireLoss())
	GLOB.religious_sect?.adjust_favor(favor_gained, user)
	to_chat(user, span_notice("[GLOB.deity] absorb the burning corpse and any trace of fire with it. [GLOB.deity] rewards you with [favor_gained] favor."))
	chosen_sacrifice.dust(force = TRUE)
	playsound(get_turf(religious_tool), 'sound/effects/supermatter.ogg', 50, TRUE)
	chosen_sacrifice = null
	return TRUE



/datum/religion_rites/infinite_candle
	name = "Immortal Candles"
	desc = "Creates 5 candles that never run out of wax."
	ritual_length = 10 SECONDS
	invoke_msg = "please lend us five of your candles so we may bask in your burning glory."
	favor_cost = 200

/datum/religion_rites/infinite_candle/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/altar_turf = get_turf(religious_tool)
	for(var/i in 1 to 5)
		new /obj/item/candle/infinite(altar_turf)
	playsound(altar_turf, 'sound/magic/fireball.ogg', 50, TRUE)
	return TRUE

/datum/religion_rites/candletransformation //in case you'd rather look like your lord than be flameproof
	name = "Wax Conversion"
	desc = "Convert a human-esque individual into a being of wax."
	ritual_length = 30 SECONDS
	ritual_invocations = list(
	"Let us offer this unworthy being...",
	"... Offered in hope to become something much more...",
	"... And in hope to better suit your great image..."
	)
	invoke_msg = "... Rise, rise! Rise in your new form!!"
	favor_cost = 2000

/datum/religion_rites/candletransformation/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(!LAZYLEN(movable_reltool.buckled_mobs))
		. = FALSE
		if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
			to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
			return
		to_chat(user, span_warning("This rite requires an individual to be buckled to [movable_reltool]."))
		return
	return ..()

/datum/religion_rites/candletransformation/invoke_effect(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool?.buckled_mobs?.len)
		return FALSE
	var/mob/living/carbon/human/human2wax
	for(var/i in movable_reltool.buckled_mobs)
		if(istype(i,/mob/living/carbon/human))
			human2wax = i
			break
	if(!human2wax)
		return FALSE
	human2wax.set_species(/datum/species/golem/wax)
	human2wax.visible_message(span_notice("[human2wax] has been converted by the rite of [name]!"))


/*********Plant people**********/

/datum/religion_rites/plantconversion
	name = "Ent Conversion"
	desc = "Convert a human-esque individual into a treelike golem."
	ritual_length = 30 SECONDS
	ritual_invocations = list(
	"Let us call upon the vines that protect...",
	"... Allow them to strip away that which is undesirable...",
	"... Allow them to protect our souls with a new shell..."
	)
	invoke_msg = "... Arise, one from the earth! Become one with the true vines, and spread its holy roots!!"
	favor_cost = 400 //on average, 20-40 crops

/datum/religion_rites/plantconversion/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(!LAZYLEN(movable_reltool.buckled_mobs))
		. = FALSE
		if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
			to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
			return
		to_chat(user, span_warning("This rite requires an individual to be buckled to [movable_reltool]."))
		return
	return ..()

/datum/religion_rites/plantconversion/invoke_effect(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool?.buckled_mobs?.len)
		return FALSE
	var/mob/living/carbon/human/human2plant
	for(var/i in movable_reltool.buckled_mobs)
		if(istype(i,/mob/living/carbon/human))
			human2plant = i
			break
	if(!human2plant)
		return FALSE
	human2plant.set_species(/datum/species/golem/wood/holy)
	human2plant.visible_message(span_notice("[human2plant] has been converted by the rite of [name]!"))
	return TRUE

/datum/religion_rites/photogeist
	name = "Summon Photogeist"
	desc = "Summons forth a holy photogeist that can heal fellow plant-like creatures. Note, it will be dormant till a ghost inhabits it, and it only understands Sylvan."
	ritual_length = 15 SECONDS
	invoke_msg = "please, great kudzu, give us an angel to watch over us."
	favor_cost = 150

/datum/religion_rites/photogeist/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/altar_turf = get_turf(religious_tool)
	new /obj/effect/mob_spawn/photogeist(altar_turf)
	return TRUE

/*********Old Ones**********/

/datum/religion_rites/ruinousknife
	name = "Ruinous Knife"
	desc = "Creates a knife that is mostly cosmetic, but is also a weapon. It is extra effective as a butchering tool, and can be upgraded with crafting alongside a piece of ruinous metal."
	ritual_length = 5 SECONDS
	invoke_msg = "please, old ones, lend us a tool of holy creation."
	favor_cost = 50

/datum/religion_rites/ruinousknife/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/altar_turf = get_turf(religious_tool)
	new /obj/item/kitchen/knife/ritual/holy(altar_turf)
	playsound(altar_turf, 'sound/magic/enter_blood.ogg', 50, TRUE)
	return TRUE

/datum/religion_rites/meatbless
	name = "Meat Blessing"
	desc = "Bless a piece of meat. Preps it for sacrifice"
	ritual_length = 2 SECONDS
	//no invoke message, this does a custom one down below in invoke_effect
	///the piece of meat that will be blessed, only one per rite
	var/obj/item/reagent_containers/food/snacks/meat/slab/chosen_meat

/datum/religion_rites/meatbless/perform_rite(mob/living/user, atom/religious_tool)
	for(var/obj/item/reagent_containers/food/snacks/meat/slab/offering in get_turf(religious_tool))
		if(istype(offering, /obj/item/reagent_containers/food/snacks/meat/slab/blessed))
			continue //we ignore anything that is already blessed
		chosen_meat = offering //the meat has been chosen by our lord and savior
		return ..()
	return FALSE

/datum/religion_rites/meatbless/invoke_effect(mob/living/user, atom/religious_tool)
	if(!QDELETED(chosen_meat) && get_turf(religious_tool) == chosen_meat.loc) //check if the same meat is still there
		var/altar_turf = get_turf(religious_tool)
		playsound(get_turf(religious_tool), 'sound/magic/enter_blood.ogg', 50, TRUE)
		if(istype(chosen_meat, /obj/item/reagent_containers/food/snacks/meat/slab/synthmeat))
			new /obj/item/reagent_containers/food/snacks/meat/slab/blessed/weak(altar_turf)
		else
			new /obj/item/reagent_containers/food/snacks/meat/slab/blessed(altar_turf)
		qdel(chosen_meat)
		chosen_meat = null //our lord and savior no longer cares about this meat
		var/mb_message = pick("old ones, I bless this meat for you!", "old ones, I bless this flesh in your name", "old ones, I empower this flesh in your name.")
		user.say(mb_message, forced = "ritual") //chooses one of three invoke messages to say in order to avoid auto mute and add variety.
		return TRUE
	chosen_meat = null
	to_chat(user, span_warning("The meat that was chosen for the rite is no longer on the altar!"))
	return FALSE

/datum/religion_rites/ruinousmetal
	name = "Ruinous Metal"
	desc = "Creates a piece of metal that can create various holy structures."
	ritual_length = 5 SECONDS
	invoke_msg = "please, old ones, lend us some of your holy material."
	favor_cost = 150

/datum/religion_rites/ruinousmetal/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/altar_turf = get_turf(religious_tool)
	new /obj/item/stack/sheet/ruinous_metal(altar_turf)
	playsound(altar_turf, 'sound/magic/enter_blood.ogg', 50, TRUE)
	return TRUE

/datum/religion_rites/bodybless
	name = "Body Blessing"
	desc = "Convert a human-esque individual into a being of ruinous metal."
	ritual_length = 30 SECONDS
	ritual_invocations = list(
	"Let us call upon the blessings of the old gods...",
	"... Show them one that is worthy of greatness...",
	"... And allow them to bless this one with a great power..."
	)
	invoke_msg = "... Become one with the blessings of our gods, arise great one!!"
	favor_cost = 2000 // 27 slabs of blessed meat/200 blessed synthetic meat, more expensive than working with xenobio.

/datum/religion_rites/bodybless/perform_rite(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
		return FALSE
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool)
		return FALSE
	if(!LAZYLEN(movable_reltool.buckled_mobs))
		. = FALSE
		if(!movable_reltool.can_buckle) //yes, if you have somehow managed to have someone buckled to something that now cannot buckle, we will still let you perform the rite!
			to_chat(user, span_warning("This rite requires a religious device that individuals can be buckled to."))
			return
		to_chat(user, span_warning("This rite requires an individual to be buckled to [movable_reltool]."))
		return
	return ..()

/datum/religion_rites/bodybless/invoke_effect(mob/living/user, atom/religious_tool)
	if(!ismovable(religious_tool))
		CRASH("[name]'s perform_rite had a movable atom that has somehow turned into a non-movable!")
	var/atom/movable/movable_reltool = religious_tool
	if(!movable_reltool?.buckled_mobs?.len)
		return FALSE
	var/mob/living/carbon/human/human2ruinous
	for(var/i in movable_reltool.buckled_mobs)
		if(istype(i,/mob/living/carbon/human))
			human2ruinous = i
			break
	if(!human2ruinous)
		return FALSE
	human2ruinous.set_species(/datum/species/golem/ruinous)
	human2ruinous.visible_message(span_notice("[human2ruinous] has been converted by the rite of [name]!"))
