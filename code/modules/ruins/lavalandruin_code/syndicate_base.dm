//lavaland_surface_syndicate_base1.dmm

/obj/machinery/vending/syndichem
	name = "\improper SyndiChem"
	desc = "A vending machine full of grenades and grenade accessories. Sponsored by DonkCo(tm)."
	req_access = list(ACCESS_SYNDICATE)
	products = list(/obj/item/stack/cable_coil/random = 5,
					/obj/item/assembly/igniter = 20,
					/obj/item/assembly/prox_sensor = 5,
					/obj/item/assembly/signaler = 5,
					/obj/item/assembly/timer = 5,
					/obj/item/assembly/voice = 5,
					/obj/item/assembly/health = 5,
					/obj/item/assembly/infra = 5,
					/obj/item/grenade/chem_grenade = 5,
	                /obj/item/grenade/chem_grenade/large = 5,
	                /obj/item/grenade/chem_grenade/pyro = 5,
	                /obj/item/grenade/chem_grenade/cryo = 5,
	                /obj/item/grenade/chem_grenade/adv_release = 5,
					/obj/item/reagent_containers/food/drinks/bottle/holywater = 1)
	product_slogans = "It's not pyromania if you're getting paid!;You smell that? Plasma, son. Nothing else in the world smells like that.;I love the smell of Plasma in the morning.;Plasma and plasma accessories!"
	resistance_flags = FIRE_PROOF

/obj/item/paper/fluff/ruins/syndicate_lavaland/research_restrictions
	name = "very stern note"
	info = "DO NOT attempt to test any explosive devices inside the outpost. A good amount of the walls have been equipped with explosive charges used as part of the self-destruction system. Explosives detonating near these walls will invariably obliterate the base."

/obj/item/paper/fluff/ruins/syndicate_lavaland/warning
	name = "warning"
	info = "Do not abandon the base without cause. I know you all are itching to attack Nanotrasen, but PLEASE, DO NOT GO OUT AND FIGHT. YOUR GUNS ARE FOR SELF-DEFENCE."

/obj/item/phone/real/syndicate_ruin //i know it's probably better in the weaponry.dm file the actual phone is in, but i dont want to do that for my own sanity.
	name = "syndicate red phone"
	desc = "A red phone used as a hotline directly to Syndicate Command. A little note on it reads 'Unauthorised use may result in termination of your life expectancy.'"

/obj/item/phone/real/syndicate_ruin/attack_self(mob/user)
	var/input = stripped_input(usr, "Please type your message. Be extremely careful with what you say, as Command has no obligation to respond and may terminate your contract.", "Message Syndicate Command", "")
	if(!input || !(usr in view(1,src)))
		return
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
	message_redphone_syndicateruin(input, usr)
	to_chat(usr, span_danger("Message sent."))
	usr.log_talk(input, LOG_SAY, tag="Syndicate announcement")
	deadchat_broadcast(" has messaged Syndicate Command using the syndicate red phone, \"[input]\" at [span_name("[get_area_name(usr, TRUE)]")].", span_name("[usr.real_name]"), usr)
