  /*
  Religious Sects are a way to convert the fun of having an active 'god' (admin) to code-mechanics so you aren't having to press adminwho.

  Sects are not meant to overwrite the fun of choosing a custom god/religion, but meant to enhance it.
  The idea is that Space Jesus (or whoever you worship) can be an evil bloodgod who takes the lifeforce out of people, a nature lover, or all things righteous and good. You decide!
  */
/datum/religion_sect
	var/name = "Religious Sect Base Type" // Name of the religious sect
	var/desc = "Oh My! What Do We Have Here?!!?!?!?" // Description of the religious sect, Presents itself in the selection menu (AKA be brief)
	var/convert_opener // Opening message when someone gets converted
	var/alignment = ALIGNMENT_GOOD // holder for alignments.
	var/starter = TRUE // Does this require something before being available as an option?
	var/favor = 0 // The Sect's 'Mana'
	var/max_favor = 1000 // The max amount of favor the sect can have
	var/default_item_favor = 5 // The default value for an item that can be sacrificed
	var/list/desired_items // Turns into 'desired_items_typecache', lists the types that can be sacrificed barring optional features in can_sacrifice()
	var/list/desired_items_typecache // Autopopulated by `desired_items`
	var/list/rites_list // Lists of rites by type. Converts itself into a list of rites with "name - desc (favor_cost)" = type
	var/altar_icon // Changes the Altar of Gods icon
	var/altar_icon_state // Changes the Altar of Gods icon_state
	var/list/active_rites // Currently Active (non-deleted) rites

/datum/religion_sect/New()
	. = ..()
	if(desired_items)
		desired_items_typecache = typecacheof(desired_items)
	if(rites_list)
		var/listylist = generate_rites_list()
		rites_list = listylist
	on_select()

///Generates a list of rites with 'name' = 'type'
/datum/religion_sect/proc/generate_rites_list()
	. = list()
	for(var/i in rites_list)
		if(!ispath(i))
			continue
		var/datum/religion_rites/RI = i
		var/name_entry = "[initial(RI.name)]"
		if(initial(RI.desc))
			name_entry += " - [initial(RI.desc)]"
		if(initial(RI.favor_cost))
			name_entry += " ([initial(RI.favor_cost)] favor)"

		. += list("[name_entry]" = i)

/// Activates once selected
/datum/religion_sect/proc/on_select()

/// Activates once selected and on newjoins, oriented around people who become holy.
/datum/religion_sect/proc/on_conversion(mob/living/L)
	if(convert_opener)
		to_chat(L, "<span class='notice'>[convert_opener]</span")

/// Returns TRUE if the item can be sacrificed. Can be modified to fit item being tested as well as person offering. Returning TRUE will stop the attackby sequence and proceed to on_sacrifice.
/datum/religion_sect/proc/can_sacrifice(obj/item/I, mob/living/L)
	. = TRUE
	if(!is_type_in_typecache(I,desired_items_typecache))
		return FALSE

/// Activates when the sect sacrifices an item. This proc has NO bearing on the attackby sequence of other objects when used in conjunction with the religious_tool component.
/datum/religion_sect/proc/on_sacrifice(obj/item/I, mob/living/L)
	return adjust_favor(default_item_favor,L)

/// Adjust Favor by a certain amount. Can provide optional features based on a user. Returns actual amount added/removed
/datum/religion_sect/proc/adjust_favor(amount = 0, mob/living/L)
	var/old_favor = favor //store the current favor
	favor = clamp(favor+amount, 0, max_favor) //ensure we arent going overboard
	return favor - old_favor //return the difference

/// Sets favor to a specific amount. Can provide optional features based on a user.
/datum/religion_sect/proc/set_favor(amount = 0, mob/living/L)
	favor = clamp(amount, 0, max_favor)
	return favor

/// Activates when an individual uses a rite. Can provide different/additional benefits depending on the user.
/datum/religion_sect/proc/on_riteuse(mob/living/user, atom/religious_tool)

/// Replaces the bible's bless mechanic. Return TRUE if you want to not do the brain hit.
/datum/religion_sect/proc/sect_bless(mob/living/L, mob/living/user)
	if(!ishuman(L))
		return FALSE
	var/mob/living/carbon/human/H = L
	for(var/X in H.bodyparts)
		var/obj/item/bodypart/BP = X
		if(BP.status == BODYPART_ROBOTIC)
			to_chat(user, span_warning("[GLOB.deity] refuses to heal this metallic taint!"))
			return TRUE

	var/heal_amt = 10
	var/list/hurt_limbs = H.get_damaged_bodyparts(1, 1, null, BODYPART_ORGANIC)

	if(hurt_limbs.len)
		for(var/X in hurt_limbs)
			var/obj/item/bodypart/affecting = X
			if(affecting.heal_damage(heal_amt, heal_amt, null, BODYPART_ORGANIC))
				H.update_damage_overlays()
		H.visible_message(span_notice("[user] heals [H] with the power of [GLOB.deity]!"))
		to_chat(H, span_boldnotice("May the power of [GLOB.deity] compel you to be healed!"))
		playsound(user, "punch", 25, TRUE, -1)
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
	return FALSE

/datum/religion_sect/puritanism
	name = "Puritanism (Default)"
	desc = "Nothing special."
	convert_opener = "Your run-of-the-mill sect, there are no benefits or boons associated. Praise normalcy!"

/datum/religion_sect/technophile
	name = "Technophile"
	desc = "A sect oriented around technology."
	convert_opener = "May you find peace in a metal shell, acolyte.<br>Bibles now recharge cyborgs and heal robotic limbs if targeted, but they do not heal organic limbs. You can now sacrifice cells, with favor depending on their charge."
	alignment = ALIGNMENT_NEUT
	desired_items = list(/obj/item/stock_parts/cell)
	rites_list = list(/datum/religion_rites/synthconversion, /datum/religion_rites/botcreation, /datum/religion_rites/machine_blessing)
	altar_icon_state = "convertaltar-blue"

/datum/religion_sect/technophile/sect_bless(mob/living/L, mob/living/user)
	if(iscyborg(L))
		var/mob/living/silicon/robot/R = L
		var/charge_amt = 50
		if(L.mind?.holy_role == HOLY_ROLE_HIGHPRIEST)
			charge_amt *= 2
		R.cell?.charge += charge_amt
		R.visible_message(span_notice("[user] charges [R] with the power of [GLOB.deity]!"))
		to_chat(R, span_boldnotice("You are charged by the power of [GLOB.deity]!"))
		SEND_SIGNAL(R, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
		playsound(user, 'sound/effects/bang.ogg', 25, TRUE, -1)
		return TRUE
	if(!ishuman(L))
		return
	var/mob/living/carbon/human/H = L

	//first we determine if we can charge them
	var/did_we_charge = FALSE
	var/obj/item/organ/stomach/ethereal/eth_stomach = H.getorganslot(ORGAN_SLOT_STOMACH)
	if(istype(eth_stomach))
		eth_stomach.adjust_charge(3)
		did_we_charge = TRUE
	if(ispreternis(H))
		var/datum/species/preternis/preternis = H.dna.species
		preternis.charge = clamp(preternis.charge + 3, PRETERNIS_LEVEL_NONE, PRETERNIS_LEVEL_FULL)
		did_we_charge = TRUE

	//if we're not targetting a robot part we stop early
	var/obj/item/bodypart/BP = H.get_bodypart(user.zone_selected)
	if(BP.status != BODYPART_ROBOTIC)
		if(!did_we_charge)
			to_chat(user, span_warning("[GLOB.deity] scoffs at the idea of healing such fleshy matter!"))
		else
			H.visible_message(span_notice("[user] charges [H] with the power of [GLOB.deity]!"))
			to_chat(H, span_boldnotice("You feel charged by the power of [GLOB.deity]!"))
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
			playsound(user, 'sound/machines/synth_yes.ogg', 25, TRUE, -1)
		return TRUE

	//charge(?) and go
	if(BP.heal_damage(5,5,null,BODYPART_ROBOTIC))
		H.update_damage_overlays()

	H.visible_message(span_notice("[user] [did_we_charge ? "repairs" : "repairs and charges"] [H] with the power of [GLOB.deity]!"))
	to_chat(H, span_boldnotice("The inner machinations of [GLOB.deity] [did_we_charge ? "repairs" : "repairs and charges"] you!"))
	playsound(user, 'sound/effects/bang.ogg', 25, TRUE, -1)
	SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
	return TRUE

/datum/religion_sect/technophile/on_sacrifice(obj/item/I, mob/living/L)
	var/obj/item/stock_parts/cell/the_cell = I
	if(!istype(the_cell)) //how...
		return
	if(the_cell.charge < 3000)
		to_chat(L,span_notice("[GLOB.deity] does not accept pity amounts of power."))
		return
	adjust_favor(round(the_cell.charge/1500), L)
	to_chat(L, span_notice("You offer [the_cell]'s power to [GLOB.deity], pleasing them."))
	qdel(I)
	return TRUE
/*
 * A religious sect based around giving money for favor which can be used to get a cool suit and become a golem.
 */
/datum/religion_sect/capitalists
	name = "The Cult of St. Credit"
	desc = "A cult oriented around money."
	convert_opener = "If you always donate your money and dont violate the NAP, you too might one day achieve the top 0.0000001%!<br>(Only Holochips accepted, for more questions reach out to our legal team!)"
	alignment = ALIGNMENT_EVIL
	desired_items = list(/obj/item/holochip)
	max_favor = 100000
	var/last_dono = 0 // world.time
	rites_list = list(/datum/religion_rites/toppercent,
					  /datum/religion_rites/looks)

/datum/religion_sect/capitalists/sect_bless(mob/living/L, mob/living/user)
	if(!ishuman(L))
		return
	if(world.time < last_dono) // immersion broken
		user.visible_message(span_notice("You are getting too greedy! You can recieve another donation in [(last_dono - world.time)/10] seconds!"))
		return
	var/mob/living/carbon/human/H = L
	var/obj/item/card/id/id_card = H.get_idcard()
	var/obj/item/card/id/id_cardu = user.get_idcard()
	var/money_to_donate = round(id_card.registered_account.account_balance * 0.1) // takes 10% of their money and rounds it down

	if(money_to_donate <= 0)
		user.visible_message(span_notice("[H] is too poor to recieve [GLOB.deity]'s blessing!"))
	else
		last_dono = world.time + 15 SECONDS // healing CD is 15 seconds but your healing strength is 3x stronger
		var/heal_amt = 30
		var/list/hurt_limbs = H.get_damaged_bodyparts(TRUE, TRUE, null, BODYPART_ORGANIC)

		if(hurt_limbs.len)
			for(var/X in hurt_limbs)
				var/obj/item/bodypart/affecting = X
				if(affecting.heal_damage(heal_amt, heal_amt, null, BODYPART_ORGANIC))
					H.update_damage_overlays()
		id_card.registered_account.adjust_money(-money_to_donate)
		id_cardu.registered_account.adjust_money(money_to_donate)
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
		playsound(user, 'sound/misc/capitialism-short.ogg', 25, TRUE, -1)
		H.visible_message(span_notice("[user] blesses [H] with the power of capitalism!"))
		to_chat(H, span_boldnotice("You feel spiritually enriched, and donate to the cause of [GLOB.deity]!"))
		H.visible_message(span_notice("[H] donated [money_to_donate] credits!"))
	return TRUE

/datum/religion_sect/capitalists/on_sacrifice(obj/item/I, mob/living/L)
	var/obj/item/holochip/money = I
	if(!istype(money))
		return
	adjust_favor(round(money.credits), L)
	to_chat(L, span_notice("As you insert the chip into the small slit in the altar, you feel [GLOB.deity] looking at you with gratitude. Seems being a God isnt that easy on your wallet."))
	qdel(I)
	return TRUE

/**** Ever-Burning Candle sect ****/

/datum/religion_sect/candle_sect
	name = "Ever-Burning Candle"
	desc = "A sect dedicated to candles."
	convert_opener = "May you be the wax to keep the Ever-Burning Candle burning, acolyte.<br>Sacrificing burning corpses with a lot of burn damage and candles grants you favor."
	alignment = ALIGNMENT_NEUT
	max_favor = 10000
	desired_items = list(/obj/item/candle)
	rites_list = list(/datum/religion_rites/fireproof, /datum/religion_rites/burning_sacrifice, /datum/religion_rites/infinite_candle, /datum/religion_rites/candletransformation)
	altar_icon_state = "convertaltar-red"

//candle sect bibles only heal burn damage and only work on people who are on fire
/datum/religion_sect/candle_sect/sect_bless(mob/living/L, mob/living/user)
	if(!ishuman(L))
		return
	var/mob/living/carbon/human/H = L
	if(!H.on_fire)
		to_chat(user, span_warning("[GLOB.deity] refuses to heal this non-burning heathen!"))
		return
	for(var/X in H.bodyparts)
		var/obj/item/bodypart/BP = X
		if(BP.status == BODYPART_ROBOTIC)
			to_chat(user, span_warning("[GLOB.deity] refuses to heal this metallic taint!"))
			return 0

	var/heal_amt = 10
	var/list/hurt_limbs = H.get_damaged_bodyparts(1, 1, null, BODYPART_ORGANIC)

	if(hurt_limbs.len)
		for(var/X in hurt_limbs)
			var/obj/item/bodypart/affecting = X
			if(affecting.heal_damage(0, heal_amt, null, BODYPART_ORGANIC))
				H.update_damage_overlays()

	H.visible_message(span_notice("[user] heals [H] with the power of [GLOB.deity]!"))
	to_chat(H, span_boldnotice("The radiance of [GLOB.deity] heals you!"))
	playsound(user, "punch", 25, TRUE, -1)
	SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
	return TRUE

/datum/religion_sect/candle_sect/on_sacrifice(obj/item/candle/offering, mob/living/user)
	if(!istype(offering))
		return
	if(!offering.lit)
		to_chat(user, span_notice("The candle needs to be lit to be offered!"))
		return
	to_chat(user, span_notice("Another candle for [GLOB.deity]'s collection"))
	if(istype(offering, /obj/item/candle/resin))
		adjust_favor(100, user) //resin candles are thicker and more rare
	else
		adjust_favor(20, user) //it's not a lot but hey there's a pacifist favor option at least
	qdel(offering)
	return TRUE

/**** Children of the Kudzu sect, will allow you to sacrifice plants to become a special wood golem. ****/

/datum/religion_sect/plant
	name = "Children of the Kudzu"
	desc = "A sect dedicated to plants."
	convert_opener = "The kudzu welcomes you with open arms, acolyte.<br>Sacrificing plants will give you favor based on their potency and allow you to ascend."
	alignment = ALIGNMENT_NEUT
	max_favor = 10000
	desired_items = list(/obj/item/reagent_containers/food/snacks/grown)
	rites_list = list(/datum/religion_rites/plantconversion, /datum/religion_rites/photogeist)
	altar_icon_state = "convertaltar-green"

//plant sect bibles will only heal plant-like things
/datum/religion_sect/plant/sect_bless(mob/living/L, mob/living/user)
	if(!ishuman(L))
		return
	var/mob/living/carbon/human/H = L
	if(!("vines" in H.faction) || !("plants" in H.faction))
		to_chat(user, span_warning("[GLOB.deity] refuses to heal this fleshy creature!"))
		return
	for(var/X in H.bodyparts)
		var/obj/item/bodypart/BP = X
		if(BP.status == BODYPART_ROBOTIC)
			to_chat(user, span_warning("[GLOB.deity] refuses to heal this metallic taint!"))
			return 0

	var/heal_amt = 10
	var/list/hurt_limbs = H.get_damaged_bodyparts(1, 1, null, BODYPART_ORGANIC)

	if(hurt_limbs.len)
		for(var/obj/item/bodypart/affecting in hurt_limbs)
			if(affecting.heal_damage(0, heal_amt, null, BODYPART_ORGANIC))
				H.update_damage_overlays()

	H.visible_message(span_notice("[user] heals [H] with the power of [GLOB.deity]!"))
	to_chat(H, span_boldnotice("The light of [GLOB.deity] heals you!"))
	playsound(user, "punch", 25, TRUE, -1)
	SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
	return TRUE

/datum/religion_sect/plant/on_sacrifice(obj/item/I, mob/living/L)
	var/obj/item/reagent_containers/food/snacks/grown/offering = I
	var/favortogive = 1
	if(!istype(offering))
		return
	favortogive += I.reagents.get_reagent_amount(/datum/reagent/consumable/nutriment) * 2
	adjust_favor(round(favortogive), L) //amount of favor depends on how much nutriment the plant carries
	to_chat(L, span_notice("[GLOB.deity] happily accepts your offering, and brings the crop to a new home."))
	qdel(I)
	return TRUE

/**** Gathering of the Old Ones sect, bless flesh and sacrifice it to gain favor for fancy runes. ****/
// Blessed meat slabs are the currency of this sect, they use it in order to make fancy structures and runes.

/datum/religion_sect/oldgods
	name = "Gathering of the Old Ones"
	desc = "A sect dedicated to the Old Gods."
	convert_opener = "The great gods of old welcome you to their gathering, acolyte.<br>Bless slabs of meat on your altar and then sacrifice it in the name of the Old Gods."
	alignment = ALIGNMENT_EVIL //kind of evil?
	max_favor = 3000
	desired_items = list(/obj/item/reagent_containers/food/snacks/meat/slab/blessed)
	rites_list = list(/datum/religion_rites/meatbless, /datum/religion_rites/ruinousknife, /datum/religion_rites/ruinousmetal, /datum/religion_rites/bodybless)
	altar_icon_state = "convertaltar-black"

//old ones sect bibles don't heal or do anything special apart from the standard holy water blessings
/datum/religion_sect/oldgods/sect_bless(mob/living/blessed, mob/living/user)
	return TRUE

/datum/religion_sect/oldgods/on_sacrifice(obj/item/reagent_containers/food/snacks/meat/slab/blessed/offering, mob/living/user)
	if(!istype(offering))
		return
	to_chat(user, span_notice(" An image of [GLOB.deity] flashes in your mind. They look pleased."))
	if(istype(offering, /obj/item/reagent_containers/food/snacks/meat/slab/blessed/weak))
		adjust_favor(10, user)
	else
		adjust_favor(75, user)
	qdel(offering)
	return 
	
/// The Honkmother sect, sacrifice bananas to feed your prank power. 

/datum/religion_sect/honkmother
	name = "The Honkmother"
	desc = "A sect dedicated to the Honkmother"
	convert_opener = "The Honkmother welcomes you to her to the party, prankster.<br>Sacrifice bananas to power our pranks and grant you favor."
	alignment = ALIGNMENT_NEUT
	max_favor = 10000
	desired_items = list(/obj/item/reagent_containers/food/snacks/grown/banana)
	rites_list = list(/datum/religion_rites/holypie, /datum/religion_rites/honkabot, /datum/religion_rites/bananablessing)
	altar_icon_state = "convertaltar-red"

//honkmother bible is supposed to only cure clowns, honk, and be slippery. I don't know how I'll do that
/datum/religion_sect/honkmother/sect_bless/sect_bless(mob/living/blessed, mob/living/user)
	if(!ishuman(blessed))
		return
	var/mob/living/carbon/human/H = blessed
	var/datum/mind/M = H.mind
	if(M.assigned_role == "Clown")
		return
	var/heal_amt = 10
	var/list/hurt_limbs = H.get_damaged_bodyparts(TRUE, TRUE, null, BODYPART_ORGANIC)

	if(hurt_limbs.len)
		for(var/X in hurt_limbs)
			var/obj/item/bodypart/affecting = X
			if(affecting.heal_damage(heal_amt, heal_amt, null, BODYPART_ORGANIC))
				H.update_damage_overlays()
	H.visible_message(span_notice("[user] heals [H] with the power of [GLOB.deity]!"))
	to_chat(H, span_boldnotice("The radiance of [GLOB.deity] heals you!"))
	playsound(user, "sound/miscitems/bikehorn.ogg", 25, TRUE, -1)
	SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/honk)
	return TRUE

/obj/item/storage/book/bible/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/slippery, 40)


/datum/religion_sect/honkmother/on_sacrifice(obj/item/reagent_containers/food/snacks/grown/banana/offering, mob/living/user)
	if(!istype(offering))
		return
	adjust_favor(10, user)			
	to_chat(user, span_notice("HONK"))
	qdel(offering)
	return
