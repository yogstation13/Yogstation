// WINTER COATS

/obj/item/clothing/suit/hooded/wintercoat
	mob_overlay_icon = 'icons/mob/clothing/suit/wintercoat.dmi'
	icon = 'icons/obj/clothing/suits/wintercoat.dmi'
	name = "winter coat"
	desc = "A heavy jacket made from 'synthetic' animal furs."
	icon_state = "coatwinter"
	item_state = "coatwinter"
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 10, RAD = 0, FIRE = 0, ACID = 0)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/tank/internals/ipc_coolant, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter)

/obj/item/clothing/head/hooded/winterhood
	mob_overlay_icon = 'icons/mob/clothing/head/winterhood.dmi'
	icon = 'icons/obj/clothing/hats/winterhood.dmi'
	name = "winter hood"
	desc = "A hood attached to a heavy winter jacket."
	icon_state = "hood_winter"
	body_parts_covered = HEAD
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEHAIR|HIDEEARS

/obj/item/clothing/suit/hooded/wintercoat/centcom
	name = "centcom winter coat"
	desc = "A luxurious winter coat woven in the bright green and gold colours of Central Command. It has a small pin in the shape of the Nanotrasen logo for a zipper."
	icon_state = "coatcentcom"
	item_state = "coatcentcom"
	armor = list(MELEE = 35, BULLET = 40, LASER = 40, ENERGY = 50, BOMB = 35, BIO = 10, RAD = 10, FIRE = 10, ACID = 60)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/centcom

/obj/item/clothing/suit/hooded/wintercoat/centcom/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_wintercoat_allowed

/obj/item/clothing/head/hooded/winterhood/centcom
	icon_state = "hood_centcom"
	armor = list(MELEE = 35, BULLET = 40, LASER = 40, ENERGY = 50, BOMB = 35, BIO = 10, RAD = 10, FIRE = 10, ACID = 60)

// COMMAND

/obj/item/clothing/suit/hooded/wintercoat/captain
	name = "captain's winter coat"
	desc = "A luxurious winter coat, stuffed with the down of the endangered Uka bird and trimmed with genuine sable. The fabric is an indulgently soft micro-fiber,\
			and the deep ultramarine colour is only one that could be achieved with minute amounts of crystalline bluespace dust woven into the thread between the plectrums.\
			Extremely lavish, and extremely durable."
	icon_state = "coatcaptain"
	item_state = "coatcaptain"
	armor = list(MELEE = 25, BULLET = 30, LASER = 30, ENERGY = 10, BOMB = 25, BIO = 0, RAD = 0, FIRE = 0, ACID = 50)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/captain

/obj/item/clothing/suit/hooded/wintercoat/captain/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_wintercoat_allowed

/obj/item/clothing/head/hooded/winterhood/captain
	desc = "A blue winter coat hood."
	icon_state = "hood_captain"

/obj/item/clothing/suit/hooded/wintercoat/hop
	name = "head of personnel's winter coat"
	desc = "A cozy winter coat, covered in thick fur. The breast features a proud yellow chevron, reminding everyone that you're the second banana."
	icon_state = "coathop"
	item_state = "coathop"
	armor = list(MELEE = 10, BULLET = 15, LASER = 15, ENERGY = 25, BOMB = 10, BIO = 0, RAD = 0, FIRE = 0, ACID = 35)
	allowed = list(
		/obj/item/melee/classic_baton,
		/obj/item/stamp
	)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/hop

/obj/item/clothing/head/hooded/winterhood/hop
	desc = "A blue winter coat hood."
	icon_state = "hood_hop"

// SERVICE

/obj/item/clothing/suit/hooded/wintercoat/hydro
	name = "hydroponics winter coat"
	desc = "A green and blue winter coat. The zipper tab looks like the flower from a member of Rosa Hesperrhodos, a pretty pink-and-white rose. The colours absolutely clash."
	icon_state = "coathydro"
	item_state = "coathydro"
	allowed = list(/obj/item/reagent_containers/spray/plantbgone, /obj/item/plant_analyzer, /obj/item/seeds, /obj/item/reagent_containers/glass/bottle, /obj/item/cultivator, /obj/item/reagent_containers/spray/pestspray, /obj/item/hatchet, /obj/item/storage/bag/plants, /obj/item/toy, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/tank/internals/ipc_coolant, /obj/item/storage/fancy/cigarettes, /obj/item/lighter)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/hydro

/obj/item/clothing/head/hooded/winterhood/hydro
	desc = "A green winter coat hood."
	icon_state = "hood_hydro"

/obj/item/clothing/suit/hooded/wintercoat/janitor
	name = "janitors winter coat"
	desc = "A purple-and-beige winter coat that smells of space cleaner."
	icon_state = "coatjanitor"
	item_state = "coatjanitor"
	allowed = list(/obj/item/toy, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/storage/fancy/cigarettes, /obj/item/lighter,/obj/item/grenade/chem_grenade,/obj/item/lightreplacer,/obj/item/flashlight,/obj/item/reagent_containers/glass/beaker,/obj/item/reagent_containers/glass/bottle,/obj/item/reagent_containers/spray,/obj/item/soap,/obj/item/holosign_creator,/obj/item/key/janitor,/obj/item/melee/flyswatter,/obj/item/paint/paint_remover,/obj/item/storage/bag/trash,/obj/item/reagent_containers/glass/bucket)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/janitor

/obj/item/clothing/head/hooded/winterhood/janitor
	desc = "A purple hood that smells of space cleaner."
	icon_state = "hood_janitor"

// SECURITY

/obj/item/clothing/suit/hooded/wintercoat/security
	name = "security winter coat"
	desc = "A red, armour-padded winter coat. It glitters with a mild ablative coating and a robust air of authority.  The zipper tab is a pair of jingly little handcuffs that get annoying after the first ten seconds."
	icon_state = "coatsecurity"
	item_state = "coatsecurity"
	armor = list(MELEE = 25, BULLET = 15, LASER = 30, ENERGY = 10, BOMB = 25, BIO = 0, RAD = 0, FIRE = 0, ACID = 45)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/security

/obj/item/clothing/suit/hooded/wintercoat/security/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_wintercoat_allowed

/obj/item/clothing/head/hooded/winterhood/security
	desc = "A red, armour-padded winter hood. Definitely not bulletproof, especially not the part where your face goes."
	icon_state = "hood_security"

/obj/item/clothing/suit/hooded/wintercoat/security/hos
	name = "head of security's winter coat"
	desc = "A red, armour-padded winter coat, lovingly woven with a Kevlar interweave and reinforced with semi-ablative polymers and a silver azide fill material. The zipper tab looks like a tiny replica of Beepsky."
	icon_state = "coathos"
	item_state = "coathos"
	armor = list(MELEE = 35, BULLET = 25, LASER = 40, ENERGY = 20, BOMB = 35, BIO = 0, RAD = 0, FIRE = 0, ACID = 55)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/security/hos

/obj/item/clothing/head/hooded/winterhood/security/hos
	desc = "A red, armour-padded winter hood, lovingly woven with a Kevlar interweave. Definitely not bulletproof, especially not the part where your face goes."
	icon_state = "hood_hos"
	armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 5, BIO = 0, RAD = 0, FIRE = 0, ACID = 55)

// MEDICAL

/obj/item/clothing/suit/hooded/wintercoat/medical
	name = "medical winter coat"
	desc = "An arctic white winter coat with a small blue caduceus instead of a plastic zipper tab. Snazzy."
	icon_state = "coatmedical"
	item_state = "coatmedical"
	allowed = list(/obj/item/analyzer, /obj/item/stack/medical, /obj/item/dnainjector, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/autoinjector, /obj/item/healthanalyzer, /obj/item/flashlight/pen, /obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/reagent_containers/pill, /obj/item/storage/pill_bottle, /obj/item/paper, /obj/item/melee/classic_baton/telescopic, /obj/item/soap, /obj/item/sensor_device, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/tank/internals/ipc_coolant, /obj/item/hypospray)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 50, RAD = 0, FIRE = 0, ACID = 45)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical

/obj/item/clothing/head/hooded/winterhood/medical
	desc = "A white winter coat hood."
	icon_state = "hood_medical"

/obj/item/clothing/suit/hooded/wintercoat/medical/cmo
	name = "chief medical officer's winter coat"
	desc = "A winter coat in a vibrant shade of blue with a small silver caduceus instead of a plastic zipper tab. The normal liner is replaced with an exceptionally thick, soft layer of fur."
	icon_state = "coatcmo"
	item_state = "coatcmo"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 50, RAD = 0, FIRE = 20, ACID = 30)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical/cmo

/obj/item/clothing/suit/hooded/wintercoat/medical/cmo/Initialize(mapload)
	. = ..()
	allowed += list(
		/obj/item/melee/classic_baton,
	)

/obj/item/clothing/head/hooded/winterhood/medical/cmo
	desc = "A blue winter coat hood."
	icon_state = "hood_cmo"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 50, RAD = 0, FIRE = 20, ACID = 30)

/obj/item/clothing/suit/hooded/wintercoat/medical/chemistry
	name = "chemistry winter coat"
	desc = "A lab-grade winter coat made with acid resistant polymers. For the enterprising chemist who was exiled to a frozen wasteland on the go."
	icon_state = "coatchemistry"
	item_state = "coatchemistry"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical/chemistry

/obj/item/clothing/head/hooded/winterhood/medical/chemistry
	desc = "A white winter coat hood."
	icon_state = "hood_chemistry"

/obj/item/clothing/suit/hooded/wintercoat/medical/viro
	name = "virology winter coat"
	desc = "A white winter coat with green markings. Warm, but wont fight off the common cold or any other disease. Might make people stand far away from you in the hallway. The zipper tab looks like an oversized bacteriophage."
	icon_state = "coatviro"
	item_state = "coatviro"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical/viro

/obj/item/clothing/head/hooded/winterhood/medical/viro
	desc = "A white winter coat hood with green markings."
	icon_state = "hood_viro"

/obj/item/clothing/suit/hooded/wintercoat/medical/paramedic
	name = "paramedic winter coat"
	desc = "A winter coat with blue markings. Warm, but probably won't protect from biological agents. For the cozy doctor on the go."
	icon_state = "coatparamed"
	item_state = "coatparamed"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical/paramedic

/obj/item/clothing/head/hooded/winterhood/medical/paramedic
	desc = "A white winter coat hood with blue markings."
	icon_state = "hood_paramed"

// SCIENCE

/obj/item/clothing/suit/hooded/wintercoat/science
	name = "science winter coat"
	desc = "A white winter coat with an outdated atomic model instead of a plastic zipper tab."
	icon_state = "coatscience"
	item_state = "coatscience"
	allowed = list(/obj/item/analyzer, /obj/item/multitool/tricorder, /obj/item/stack/medical, /obj/item/dnainjector, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/autoinjector, /obj/item/healthanalyzer, /obj/item/flashlight/pen, /obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/reagent_containers/pill, /obj/item/storage/pill_bottle, /obj/item/paper, /obj/item/melee/classic_baton/telescopic, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/tank/internals/ipc_coolant)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 10, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/science

/obj/item/clothing/head/hooded/winterhood/science
	desc = "A white winter coat hood. This one will keep your brain warm. About as much as the others, really."
	icon_state = "hood_science"

/obj/item/clothing/suit/hooded/wintercoat/science/rd
	name = "research director's advanced thermal insulator"
	desc = "A thick arctic winter coat with an outdated atomic model instead of a plastic zipper tab. Most in the know are heavily aware that Bohr's model of the atom was outdated by the time of the 1930s when the Heisenbergian and Schrodinger models were generally accepted for true. Nevertheless, we still see its use in anachronism, roleplaying, and, in this case, as a zipper tab. At least it should keep you warm on your ivory pillar."
	icon_state = "coatrd"
	item_state = "coatrd"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 20, BIO = 0, RAD = 0, FIRE = 30, ACID = 0)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/science/rd

/obj/item/clothing/suit/hooded/wintercoat/science/rd/Initialize(mapload)
	. = ..()
	allowed += list(
		/obj/item/melee/classic_baton,
	)

/obj/item/clothing/head/hooded/winterhood/science/rd
	desc = "A white winter coat hood. It smells faintly of hair gel."
	icon_state = "hood_rd"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 20, BIO = 0, RAD = 0, FIRE = 30, ACID = 0)

/obj/item/clothing/suit/hooded/wintercoat/science/robotics
	name = "robotics winter coat"
	desc = "A black winter coat with a badass flaming robotic skull for the zipper tab. This one has bright red designs and a few useless buttons."
	icon_state = "coatrobotics"
	item_state = "coatrobotics"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/science/robotics

/obj/item/clothing/head/hooded/winterhood/science/robotics
	desc = "A black winter coat hood. You can pull it down over your eyes and pretend that you're an outdated, late 1980s interpretation of a futuristic mechanized police force. They'll fix you. They fix everything."
	icon_state = "hood_robotics"

/obj/item/clothing/suit/hooded/wintercoat/science/genetics
	name = "genetics winter coat"
	desc = "A white winter coat with a DNA helix for the zipper tab."
	icon_state = "coatgenetics"
	item_state = "coatgenetics"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/science/genetics

/obj/item/clothing/head/hooded/winterhood/science/genetics
	desc = "A white winter coat hood. It's warm."
	icon_state = "hood_genetics"

// ENGINEERING

/obj/item/clothing/suit/hooded/wintercoat/engineering
	name = "engineering winter coat"
	desc = "A surprisingly heavy yellow winter coat with reflective orange stripes. It has a small wrench for its zipper tab, and the inside layer is covered with a radiation-resistant silver-nylon blend. Because you're worth it."
	icon_state = "coatengineer"
	item_state = "coatengineer"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 20, FIRE = 30, ACID = 45, ELECTRIC = 20)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/tank/internals/ipc_coolant, /obj/item/t_scanner, /obj/item/construction/rcd, /obj/item/pipe_dispenser, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/extinguisher/mini)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering

/obj/item/clothing/head/hooded/winterhood/engineering
	desc = "A yellow winter coat hood. Definitely not a replacement for a hard hat."
	icon_state = "hood_engineer"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 10, FIRE = 20, ACID = 10, ELECTRIC = 20)

/obj/item/clothing/suit/hooded/wintercoat/engineering/ce
	name = "chief engineer's winter coat"
	desc = "A white winter coat with reflective green and yellow stripes. Stuffed with asbestos, treated with fire retardant PBDE, lined with a micro thin sheet of lead foil and snugly fitted to your body's measurements. This baby's ready to save you from anything except the thyroid cancer and systemic fibrosis you'll get from wearing it. The zipper tab is a tiny golden wrench."
	icon_state = "coatce"
	item_state = "coatce"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 30, FIRE = 40, ACID = 10, ELECTRIC = 40)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering/ce

/obj/item/clothing/suit/hooded/wintercoat/engineering/ce/Initialize(mapload)
	. = ..()
	allowed += list(
		/obj/item/melee/classic_baton,
	)

/obj/item/clothing/head/hooded/winterhood/engineering/ce
	desc = "A white winter coat hood. Feels surprisingly heavy. The tag says that it's not child safe."
	icon_state = "hood_ce"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 15, FIRE = 30, ACID = 10, ELECTRIC = 40)

/obj/item/clothing/suit/hooded/wintercoat/engineering/atmos
	name = "atmospherics winter coat"
	desc = "A surprisingly heavy yellow winter coat with reflective blue stripes. It has a small wrench for its zipper tab, and the inside layer is covered with a radiation-resistant silver-nylon blend. Because you're worth it."
	icon_state = "coatatmos"
	item_state = "coatatmos"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering/atmos

/obj/item/clothing/head/hooded/winterhood/engineering/atmos
	desc = "A yellow and blue winter coat hood."
	icon_state = "hood_atmos"

// SUPPLY

/obj/item/clothing/suit/hooded/wintercoat/cargo
	name = "cargo winter coat"
	desc = "A tan-and-grey winter coat. The zipper tab is a small pin resembling a MULE. It fills you with the warmth of a fierce independence."
	icon_state = "coatcargo"
	item_state = "coatcargo"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/cargo
	allowed = list(/obj/item/stamp)

/obj/item/clothing/head/hooded/winterhood/cargo
	desc = "A grey hood for a winter coat."
	icon_state = "hood_cargo"

/obj/item/clothing/suit/hooded/wintercoat/qm
	name = "quartermaster's winter coat"
	desc = "A dark brown winter coat that has a golden crate pin for its zipper pully."
	icon_state = "coatqm"
	item_state = "coatqm"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/qm

/obj/item/clothing/head/hooded/winterhood/qm
	desc = "A dark brown winter hood"
	icon_state = "hood_qm"

/obj/item/clothing/suit/hooded/wintercoat/miner
	name = "mining winter coat"
	desc = "A dusty button up winter coat. The zipper tab looks like a tiny pickaxe."
	icon_state = "coatminer"
	item_state = "coatminer"
	allowed = list(/obj/item/pickaxe, /obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/tank/internals/ipc_coolant, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter)
	armor = list(MELEE = 10, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/miner

/obj/item/clothing/head/hooded/winterhood/miner
	desc = "A dusty winter coat hood."
	icon_state = "hood_miner"
