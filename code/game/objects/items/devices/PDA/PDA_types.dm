//Clown PDA is slippery.
/obj/item/pda/clown
	name = "\improper antique clown PDA"
	default_cartridge = /obj/item/cartridge/virus/clown
	insert_type = /obj/item/toy/crayon/rainbow
	icon_state = "pda-clown"
	desc = "An outdated, portable microcomputer developed by Thinktronic Systems, LTD. The surface is coated with polytetrafluoroethylene and banana drippings."
	ttone = "honk"

/obj/item/pda/clown/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery, 120, NO_SLIP_WHEN_WALKING, CALLBACK(src, PROC_REF(AfterSlip)))

/obj/item/pda/clown/proc/AfterSlip(mob/living/carbon/human/M)
	if (istype(M) && (M.real_name != owner))
		var/obj/item/cartridge/virus/clown/cart = cartridge
		if(istype(cart) && cart.charges < 5)
			cart.charges++

// Special AI/pAI PDAs that cannot explode.
/obj/item/pda/ai
	icon = null
	ttone = "data"

/obj/item/pda/ai/attack_self(mob/user)
	if ((honkamt > 0) && (prob(60)))//For clown virus.
		honkamt--
		playsound(loc, 'sound/items/bikehorn.ogg', 30, 1)
	return

/obj/item/pda/ai/pai
	ttone = "assist"

/obj/item/pda/ai/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_TABLET_CHECK_DETONATE, PROC_REF(pda_no_detonate))

/obj/item/pda/medical
	name = "\improper antique medical PDA"
	default_cartridge = /obj/item/cartridge/medical
	icon_state = "pda-medical"

/obj/item/pda/viro
	name = "\improper antique virology PDA"
	default_cartridge = /obj/item/cartridge/medical
	icon_state = "pda-virology"

/obj/item/pda/engineering
	name = "\improper antique engineering PDA"
	default_cartridge = /obj/item/cartridge/engineering
	icon_state = "pda-engineer"

/obj/item/pda/security
	name = "\improper antique security PDA"
	default_cartridge = /obj/item/cartridge/security
	icon_state = "pda-security"

/obj/item/pda/detective
	name = "\improper antique detective PDA"
	default_cartridge = /obj/item/cartridge/detective
	icon_state = "pda-detective"

/obj/item/pda/warden
	name = "\improper antique warden PDA"
	default_cartridge = /obj/item/cartridge/security
	icon_state = "pda-warden"

/obj/item/pda/janitor
	name = "\improper antique janitor PDA"
	default_cartridge = /obj/item/cartridge/janitor
	icon_state = "pda-janitor"
	ttone = "slip"

/obj/item/pda/toxins
	name = "\improper antique scientist PDA"
	default_cartridge = /obj/item/cartridge/signal/toxins
	icon_state = "pda-science"
	ttone = "boom"

/obj/item/pda/mime
	name = "\improper antique mime PDA"
	default_cartridge = /obj/item/cartridge/virus/mime
	insert_type = /obj/item/toy/crayon/mime
	icon_state = "pda-mime"
	silent = TRUE
	ttone = "silence"

/obj/item/pda/heads
	default_cartridge = /obj/item/cartridge/head
	icon_state = "pda-hop"

/obj/item/pda/heads/hop
	name = "\improper antique head of personnel PDA"
	default_cartridge = /obj/item/cartridge/hop
	icon_state = "pda-hop"

/obj/item/pda/heads/hos
	name = "\improper antique head of security PDA"
	default_cartridge = /obj/item/cartridge/hos
	icon_state = "pda-hos"

/obj/item/pda/heads/ce
	name = "\improper antique chief engineer PDA"
	default_cartridge = /obj/item/cartridge/ce
	icon_state = "pda-ce"

/obj/item/pda/heads/cmo
	name = "\improper antique chief medical officer PDA"
	default_cartridge = /obj/item/cartridge/cmo
	icon_state = "pda-cmo"

/obj/item/pda/heads/rd
	name = "\improper antique research director PDA"
	default_cartridge = /obj/item/cartridge/rd
	insert_type = /obj/item/pen/fountain
	icon_state = "pda-rd"

/obj/item/pda/captain
	name = "\improper antique captain PDA"
	default_cartridge = /obj/item/cartridge/captain
	insert_type = /obj/item/pen/fountain/captain
	icon_state = "pda-captain"

/obj/item/pda/captain/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_TABLET_CHECK_DETONATE, PROC_REF(pda_no_detonate))

/obj/item/pda/cargo
	name = "\improper antique cargo technician PDA"
	default_cartridge = /obj/item/cartridge/quartermaster
	icon_state = "pda-cargo"

/obj/item/pda/quartermaster
	name = "\improper antique quartermaster PDA"
	default_cartridge = /obj/item/cartridge/quartermaster
	insert_type = /obj/item/pen/fountain
	icon_state = "pda-qm"

/obj/item/pda/shaftminer
	name = "\improper antique shaft miner PDA"
	icon_state = "pda-miner"

/obj/item/pda/syndicate
	default_cartridge = /obj/item/cartridge/virus/syndicate
	icon_state = "pda-syndi"
	name = "\improper antique military PDA"
	owner = "John Doe"
	hidden = 1

/obj/item/pda/chaplain
	name = "\improper antique chaplain PDA"
	icon_state = "pda-chaplain"
	ttone = "holy"

/obj/item/pda/lawyer
	name = "\improper antique lawyer PDA"
	default_cartridge = /obj/item/cartridge/lawyer
	insert_type = /obj/item/pen/fountain
	icon_state = "pda-lawyer"
	ttone = "objection"

/obj/item/pda/botanist
	name = "\improper antique botanist PDA"
	//default_cartridge = /obj/item/cartridge/botanist
	icon_state = "pda-hydro"

/obj/item/pda/roboticist
	name = "\improper antique roboticist PDA"
	icon_state = "pda-roboticist"
	default_cartridge = /obj/item/cartridge/roboticist

/obj/item/pda/curator
	name = "\improper antique curator PDA"
	icon_state = "pda-library"
	icon_alert = "pda-r-library"
	default_cartridge = /obj/item/cartridge/curator
	insert_type = /obj/item/pen/fountain
	desc = "An outdated, portable microcomputer developed by Thinktronic Systems, LTD. This model is a WGW-11 series e-reader."
	note = "Congratulations, your station has chosen the Thinktronic 5290 WGW-11 Series E-reader and Personal Data Assistant!"
	silent = TRUE //Quiet in the library!
	overlays_x_offset = -3

/obj/item/pda/clear
	name = "\improper antique clear PDA"
	icon_state = "pda-clear"
	desc = "An outdated, portable microcomputer developed by Thinktronic Systems, LTD. This model is a special edition with a transparent case."
	note = "Congratulations, you have chosen the Thinktronic 5230 Personal Data Assistant Deluxe Special Max Turbo Limited Edition!"

/obj/item/pda/artist
	name = "\improper antique aesthetic PDA"
	icon_state = "pda-artist"

/obj/item/pda/cook
	name = "\improper antique cook PDA"
	icon_state = "pda-cook"

/obj/item/pda/bar
	name = "\improper antique bartender PDA"
	icon_state = "pda-bartender"
	insert_type = /obj/item/pen/fountain

/obj/item/pda/atmos
	name = "\improper antique atmospherics PDA"
	default_cartridge = /obj/item/cartridge/atmos
	icon_state = "pda-atmos"

/obj/item/pda/chemist
	name = "\improper antique chemist PDA"
	default_cartridge = /obj/item/cartridge/chemistry
	icon_state = "pda-chemistry"

/obj/item/pda/geneticist
	name = "\improper antique geneticist PDA"
	default_cartridge = /obj/item/cartridge/medical
	icon_state = "pda-genetics"
