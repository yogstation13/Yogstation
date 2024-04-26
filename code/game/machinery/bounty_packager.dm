GLOBAL_DATUM(bounty_packager, /obj/machinery/bounty_packager)

/obj/machinery/bounty_packager
	name = "\improper NanoTrasen Bounty Encapsulation Device"
	desc = "A large metallic machine with an entrance and an exit. A sign on \
		the side reads, 'bounty go in, cube come out'."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "grinder-b1"
	layer = ABOVE_ALL_MOB_LAYER // Overhead
	density = TRUE
	var/datum/bounty/selected_bounty
	var/obj/machinery/computer/bounty/linked_console

/obj/machinery/bounty_packager/Initialize(mapload)
	. = ..()
	if(mapload && !GLOB.bounty_packager)
		GLOB.bounty_packager = src

/obj/machinery/bounty_packager/update_icon()
	..()
	if(stat & (BROKEN|NOPOWER))
		icon_state = "grinder-b0"
	else
		icon_state = initial(icon_state)

/obj/machinery/bounty_packager/Bumped(atom/movable/AM)
	if(!selected_bounty)
		return
	if(selected_bounty.applies_to(AM))
		AM.forceMove(drop_location())
		selected_bounty.ship(AM)
		if(istype(AM, /obj/mecha))
			for(var/mob/thing as anything in AM.client_mobs_in_contents) // Get pilot out of mech
				thing.forceMove(drop_location())
		qdel(AM)
		if(!selected_bounty.can_claim())
			return
		var/obj/item/bounty_cube/cube = new(drop_location())
		cube.set_up(selected_bounty)
		selected_bounty.claim()
		selected_bounty = null

/obj/machinery/bounty_packager/multitool_act(mob/living/user, obj/item/I)
	var/obj/item/multitool/multitool = I
	if(!istype(multitool)) return FALSE
	if(!istype(multitool.buffer, /obj/machinery/computer/bounty))
		multitool.buffer = src
		to_chat(user, span_notice("[src] stored in [I]"))
		return TRUE

	linked_console = multitool.buffer
	linked_console.linked_packager = src
	to_chat(user, span_notice("[src] has been linked to [linked_console]"))
	return TRUE


/obj/item/bounty_cube
	name = "bounty cube"
	desc = "A neatly packaged bounty for transport back to central command. Place this on the cargo shuttle to get your reward!"
	icon = 'icons/obj/economy.dmi'
	icon_state = "bounty_cube"

	///Value of the bounty that this bounty cube sells for.
	var/bounty_value = 0
	///Multiplier for the bounty payout received by the Supply budget if the cube is sent without having to nag.
	var/speed_bonus = 0.2
	///Multiplier for the bounty payout received by the person who completed the bounty.
	var/holder_cut = 0.3
	///Multiplier for the bounty payout received by the person who claims the handling tip.
	var/handler_tip = 0.1
	///Time between nags.
	var/nag_cooldown = 5 MINUTES
	///How much the time between nags extends each nag.
	var/nag_cooldown_multiplier = 1.25
	///Next world tick to nag Supply listeners.
	var/next_nag_time
	///Who completed the bounty.
	var/bounty_holder
	///What job the bounty holder had.
	var/datum/job/bounty_holder_job
	///What the bounty was for.
	var/bounty_name
	///Bank account of the person who completed the bounty.
	var/datum/bank_account/bounty_holder_account
	///Bank account of the person who receives the handling tip.
	var/datum/bank_account/bounty_handler_account
	///Our internal radio.
	var/obj/item/radio/radio
	///The key our internal radio uses.
	var/radio_key = /obj/item/encryptionkey/headset_cargo

/obj/item/bounty_cube/Initialize()
	. = ..()
	radio = new(src)
	radio.keyslot = new radio_key
	radio.listening = FALSE
	radio.recalculateChannels()
	RegisterSignal(radio, COMSIG_ITEM_PRE_EXPORT, .proc/on_export)

/obj/item/bounty_cube/Destroy()
	UnregisterSignal(radio, COMSIG_ITEM_PRE_EXPORT)
	QDEL_NULL(radio)
	return ..()

/obj/item/bounty_cube/proc/on_export()
	SIGNAL_HANDLER

	QDEL_NULL(radio)
	return COMPONENT_STOP_EXPORT

/obj/item/bounty_cube/examine()
	. = ..()
	if(speed_bonus)
		. += span_notice("<b>[time2text(next_nag_time - world.time,"mm:ss")]</b> remains until <b>[bounty_value * speed_bonus]</b> credit speedy delivery bonus lost.")
	if(handler_tip && !bounty_handler_account)
		. += span_notice("Scan this in the cargo shuttle with an export scanner to register your bank account for the <b>[bounty_value * handler_tip]</b> credit handling tip.")

/obj/item/bounty_cube/process(delta_time)
	//if our nag cooldown has finished and we aren't on Centcom or in transit, then nag
	if(COOLDOWN_FINISHED(src, next_nag_time) && !is_centcom_level(z) && !is_reserved_level(z))
		//set up our nag message
		var/nag_message = "[src] is unsent in [get_area(src)]."

		//nag on Supply channel and reduce the speed bonus multiplier to nothing
		var/speed_bonus_lost = "[speed_bonus ? " Speedy delivery bonus of [bounty_value * speed_bonus] credit\s lost." : ""]"
		radio.talk_into(src, "[nag_message][speed_bonus_lost]", RADIO_CHANNEL_SUPPLY)
		speed_bonus = 0

		//alert the holder
		bounty_holder_account.bank_card_talk("[nag_message]") 

		//if someone has registered for the handling tip, nag them
		bounty_handler_account?.bank_card_talk(nag_message)

		//increase our cooldown length and start it again
		nag_cooldown = nag_cooldown * nag_cooldown_multiplier
		COOLDOWN_START(src, next_nag_time, nag_cooldown)

/obj/item/bounty_cube/proc/set_up(datum/bounty/my_bounty)
	bounty_value = my_bounty.reward
	bounty_name = my_bounty.name
	bounty_holder = my_bounty.account.account_holder
	bounty_holder_job = my_bounty.account.account_job
	bounty_holder_account = my_bounty.account
	name = "\improper [bounty_value] cr [name]"
	desc += " The sales tag indicates it contains <i>[bounty_holder] ([bounty_holder_job.title])</i>'s <i>[bounty_name]</i> bounty."
	AddComponent(/datum/component/pricetag, bounty_holder_account, holder_cut)
	START_PROCESSING(SSobj, src)
	COOLDOWN_START(src, next_nag_time, nag_cooldown)
	radio.talk_into(src,"Created in [get_area(src)] by [bounty_holder] ([bounty_holder_job.title]). Speedy delivery bonus lost in [time2text(next_nag_time - world.time,"mm:ss")].", RADIO_CHANNEL_SUPPLY)

/obj/item/bounty_cube/debug_cube
	name = "debug bounty cube"
	desc = "Use in-hand to set it up with a random bounty. Requires an ID it can detect with a bank account attached. \
	This will alert Supply over the radio with your name and location, and cargo techs will be dispatched with kill on sight clearance."
	var/set_up = FALSE

/obj/item/bounty_cube/debug_cube/attack_self(mob/user)
	if(!isliving(user))
		to_chat(user, span_warning("You aren't eligible to use this!"))
		return ..()

	if(!set_up)
		var/mob/living/squeezer = user
		var/obj/item/card/id/id = squeezer.get_idcard()
		if(id?.registered_account)
			set_up(random_bounty(CIV_JOB_RANDOM, id.registered_account), id)
			set_up = TRUE
			return ..()
		to_chat(user, span_notice("It can't detect your bank account."))

	return ..()
