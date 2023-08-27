//Bureaucracy machine!
//Simply set this up in the hopline and you can serve people based on ticket numbers

/obj/machinery/ticket_machine
	name = "ticket machine"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "ticketmachine"
	desc = "A marvel of bureaucratic engineering encased in an efficient plastic shell. Click to take a number!"
	circuit = /obj/item/circuitboard/machine/ticketmachine
	density = TRUE
	var/screenNum = 0 //this is the the number of the person who is up
	var/currentNum = 0 //this is the the number someone who takes a ticket gets
	var/ticketNumMax = 999 //No more!
	var/cooldown = 10
	var/ready = TRUE
	var/linked = FALSE
	var/list/obj/item/ticket_machine_ticket/tickets = list()

/obj/machinery/ticket_machine/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_ICON)

/obj/machinery/ticket_machine/update_overlays()
	. = ..()
	var/Temp = screenNum //This whole thing breaks down a 3 digit number into 3 seperate digits, aka "69" becomes "0","6" and "9"
	var/Digit1 = round(Temp%10)//The remainder of any number/10 is always that number's rightmost digit
	var/Digit2 = round(((Temp-Digit1)*0.1)%10) //Same idea, but divided by ten, to find the middle digit
	var/Digit3 = round(((Temp-Digit1-Digit2*10)*0.01)%10)//Same as above. Despite the weird notation these will only ever output integers, don't worry.
	. += image('icons/obj/bureaucracy_overlays.dmi',icon_state = "machine_first_[Digit1]")
	. += image('icons/obj/bureaucracy_overlays.dmi',icon_state = "machine_second_[Digit2]")
	. += image('icons/obj/bureaucracy_overlays.dmi',icon_state = "machine_third_[Digit3]")

/obj/machinery/ticket_machine/update_icon_state()
	. = ..()
	switch(currentNum) //Gives you an idea of how many tickets are left
		if(0 to 200)
			icon_state = "ticketmachine_100"
		if(201 to 800)
			icon_state = "ticketmachine_50"
		if(801 to 999)
			icon_state = "ticketmachine_0"

/obj/machinery/ticket_machine/proc/increment()
	playsound(src, 'sound/misc/announce_dig.ogg', 50, 0)
	say("Next customer, please!")
	screenNum ++ //Increment the one we're serving.
	if(currentNum > ticketNumMax)
		currentNum = 0
		say("Error: Stack Overflow!")
	if(screenNum > ticketNumMax)
		screenNum = 0
		say("Error: Stack Overflow!")
	if(currentNum < screenNum - 1)
		screenNum -- //this should only happen if the queue is all caught up and more numbers get called than tickets exist
		currentNum = screenNum - 1 //so the number wont go onto infinity. Numbers that haven't been taken yet won't show up on the screen yet either.
	update_appearance(UPDATE_ICON) //Update our icon here
	if(tickets.len<screenNum)
		tickets.len = screenNum //this helps prevents runtimes that happen due to mapping stuff. Just an extra safety

	if(!(obj_flags & EMAGGED) && tickets[screenNum]) //if the ticket actually, you know, exists and all
		tickets[screenNum].audible_message(span_rose("\the [tickets[screenNum]] dings!"),hearing_distance=1)
		playsound(tickets[screenNum], 'sound/machines/twobeep_high.ogg', 10, 0 ,1-world.view) //The sound travels world.view+extraRange tiles. This last value is the extra range, which means the total range will be 1.

/obj/machinery/ticket_machine/emag_act(mob/user, obj/item/card/emag/emag_card) //Emag the ticket machine to dispense burning tickets, as well as randomize its customer number to destroy the HOP's mind.
	if(obj_flags & EMAGGED)
		return FALSE
	to_chat(user, span_warning("You overload [src]'s bureaucratic logic circuitry to its MAXIMUM setting."))
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(12, 1, src)
	s.start()
	screenNum = rand(0,ticketNumMax)
	update_appearance(UPDATE_ICON)
	obj_flags |= EMAGGED
	return TRUE

/obj/machinery/ticket_machine/attack_hand(mob/living/carbon/user)
	. = ..()
	if(!ready)
		return
	ready = FALSE
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 100, 0)
	addtimer(VARSET_CALLBACK(src, ready, TRUE), cooldown) //Small cooldown to prevent the clown from ripping out every ticket
	currentNum ++
	to_chat(user, span_notice("You take a ticket from [src], looks like you're customer #[currentNum]..."))
	var/obj/item/ticket_machine_ticket/theirticket = new /obj/item/ticket_machine_ticket(get_turf(src))
	theirticket.name = "Ticket #[currentNum]"
	theirticket.source = src
	theirticket.ticket_number = currentNum
	theirticket.update_appearance(UPDATE_ICON)
	user.put_in_hands(theirticket)
	if(tickets.len<currentNum)
		tickets.len = currentNum //this grows the size of the list as needed.
	tickets[currentNum] = theirticket
	if(obj_flags & EMAGGED) //Emag the machine to destroy the HOP's life.
		theirticket.fire_act()
		user.dropItemToGround(theirticket)
		user.adjust_fire_stacks(1)
		user.ignite_mob()
		return

/obj/machinery/ticket_machine/attackby(obj/item/O, mob/user, params)
	if(user.a_intent == INTENT_HARM) //so we can hit the machine
		return ..()

	if(default_deconstruction_screwdriver(user, "ticketmachine_panel", "ticketmachine", O))
		updateUsrDialog()
		update_appearance(UPDATE_ICON)
		return TRUE

	if(default_deconstruction_crowbar(O) || stat)
		return TRUE

	if(istype(O, /obj/item/ticket_machine_remote))
		if (!linked)
			var/obj/item/ticket_machine_remote/Z = O //typecasting!!
			if (!Z.connection)
				Z.connection=src
				to_chat(user,span_info("You link the remote to the machine."))
				linked = TRUE
				return TRUE
			to_chat(user,span_warning("The remote is already linked to a ticket machine!"))

		else
			to_chat(user,span_warning("The ticket machine is already linked to a remote!"))

	if(istype(O, /obj/item/ticket_machine_ticket))
		to_chat(user, span_warning("You put [O] into the ticket machine's recycling bin."))
		qdel(O) //KMC put a delay here. I'm not so forgiving. You accidently shred your ticket, you cry. (Also the delay felt really clunky)
		return TRUE

/obj/machinery/ticket_machine/Destroy()
	var/obj/item/ticket_machine_ticket/T
	for (T in tickets)
		T.audible_message("The ticket vibrates for a moment, then dissolves into paper scraps!")
		qdel(T)
	tickets = list()
	return ..()

//Tickets dispensed from the machine
/obj/item/ticket_machine_ticket
	name = "Ticket"
	desc = "A ticket which shows your place in the queue."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "ticket"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	max_integrity = 50
	var/obj/machinery/ticket_machine/source
	var/ticket_number

/obj/item/ticket_machine_ticket/update_overlays()
	. = ..()
	var/Temp = ticket_number //this stuff is a repeat from the other update_icon, but with new image files and the like
	var/Digit1 = round(Temp%10)
	var/Digit2 = round(((Temp-Digit1)*0.1)%10)
	var/Digit3 = round(((Temp-Digit1-Digit2*10)*0.01)%10)
	. += image('icons/obj/bureaucracy_overlays.dmi',icon_state = "ticket_first_[Digit1]")
	. += image('icons/obj/bureaucracy_overlays.dmi',icon_state = "ticket_second_[Digit2]")
	. += image('icons/obj/bureaucracy_overlays.dmi',icon_state = "ticket_third_[Digit3]")
	if(resistance_flags & ON_FIRE)
		icon_state = "ticket_onfire"

/obj/item/ticket_machine_ticket/attackby(obj/item/P, mob/living/carbon/human/user, params)
	..()
	if(P.is_hot())
		if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(10))
			user.visible_message(span_warning("[user] accidentally ignites [user.p_them()]self!"), span_userdanger("You miss the ticket and accidentally light yourself on fire!"))
			user.dropItemToGround(P)
			user.adjust_fire_stacks(1)
			user.ignite_mob()
			return

		if(!(in_range(user, src))) //to prevent issues as a result of telepathically lighting a paper
			return

		user.dropItemToGround(src)
		user.visible_message(span_danger("[user] lights [src] ablaze with [P]!"), span_danger("You light [src] on fire!"))
		src.fire_act()

/obj/item/ticket_machine_ticket/extinguish()
	..()
	update_appearance(UPDATE_ICON)

//Remote that operates it
/obj/item/ticket_machine_remote
	name = "Ticket Machine Remote"
	desc = "A remote used to operate a ticket machine."
	icon = 'icons/obj/assemblies/electronic_setups.dmi'
	icon_state = "setup_small_simple"
	w_class = WEIGHT_CLASS_TINY
	max_integrity = 100
	var/obj/machinery/ticket_machine/connection = null
	var/cooldown = 20
	var/ready = TRUE

/obj/item/ticket_machine_remote/attack_self(mob/user)
	if(!ready)
		return
	if(!connection)
		to_chat(user,span_warning("The remote isn't linked to a ticket machine!"))
		return
	ready = FALSE
	addtimer(VARSET_CALLBACK(src, ready, TRUE), cooldown)
	connection.increment()

/obj/item/ticket_machine_remote/AltClick(mob/living/user)
	..()
	if(connection)
		connection.linked = FALSE
		connection = null
		to_chat(user,span_info("You unlink the remote from all connections."))

/obj/item/ticket_machine_remote/examine(mob/user)
	.=..()
	if(connection)
		.+= span_info("The remote is currently connected to a ticket machine.\nAlt click the remote to sever this connection.")
	else
		.+= span_info("Click on a ticket machine with this remote to link them.")
