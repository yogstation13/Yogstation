// Shotgun

/obj/item/ammo_casing/shotgun
	name = "shotgun slug"
	desc = "A 12 gauge lead slug."
	icon_state = "blshell"
	caliber = "shotgun"
	projectile_type = /obj/item/projectile/bullet/shotgun_slug
	materials = list(/datum/material/iron=4000)

/obj/item/ammo_casing/shotgun/syndie
	name = "syndicate shotgun slug"
	desc = "An illegal type of ammunition used by the syndicate for their bulldog shotguns. Hopefully you're not the one on the receiving end."
	projectile_type = /obj/item/projectile/bullet/shotgun_slug/syndie

/obj/item/ammo_casing/shotgun/beanbag
	name = "beanbag slug"
	desc = "A weak beanbag slug for riot control."
	icon_state = "bshell"
	projectile_type = /obj/item/projectile/bullet/shotgun_beanbag
	materials = list(/datum/material/iron=250)

/obj/item/ammo_casing/shotgun/incendiary
	name = "incendiary slug"
	desc = "An incendiary-coated shotgun slug."
	icon_state = "ishell"
	projectile_type = /obj/item/projectile/bullet/incendiary/shotgun

/obj/item/ammo_casing/shotgun/dragonsbreath
	name = "dragonsbreath shell"
	desc = "A shotgun shell which fires a spread of incendiary pellets."
	icon_state = "ishell2"
	projectile_type = /obj/item/projectile/bullet/incendiary/shotgun/dragonsbreath
	pellets = 4
	variance = 35

/obj/item/ammo_casing/shotgun/stunslug
	name = "taser slug"
	desc = "A stunning taser slug."
	icon_state = "stunshell"
	projectile_type = /obj/item/projectile/bullet/shotgun_stunslug
	materials = list(/datum/material/iron=250)

/obj/item/ammo_casing/shotgun/meteorslug
	name = "meteorslug shell"
	desc = "A shotgun shell rigged with CMC technology, which launches a massive slug when fired."
	icon_state = "mshell"
	projectile_type = /obj/item/projectile/bullet/shotgun_meteorslug

/obj/item/ammo_casing/shotgun/pulseslug
	name = "pulse slug"
	desc = "A delicate device which can be loaded into a shotgun. The primer acts as a button which triggers the gain medium and fires a powerful \
	energy blast. While the heat and power drain limit it to one use, it can still allow an operator to engage targets that ballistic ammunition \
	would have difficulty with."
	icon_state = "pshell"
	projectile_type = /obj/item/projectile/beam/pulse/shotgun

/obj/item/ammo_casing/shotgun/frag12
	name = "FRAG-12 slug"
	desc = "A high explosive breaching round for a 12 gauge shotgun."
	icon_state = "heshell"
	projectile_type = /obj/item/projectile/bullet/shotgun_frag12

/obj/item/ammo_casing/shotgun/buckshot
	name = "buckshot shell"
	desc = "A 12 gauge buckshot shell."
	icon_state = "gshell"
	projectile_type = /obj/item/projectile/bullet/pellet/shotgun_buckshot
	pellets = 6
	variance = 25

/obj/item/ammo_casing/shotgun/hpbuck
	name = "hollow-point buckshot shell"
	desc = "A 12 gauge hollow-point buckshot shell."
	icon_state = "hpbshell"
	projectile_type = /obj/item/projectile/bullet/pellet/shotgun_hpbuckshot
	pellets = 6
	variance = 25

/obj/item/ammo_casing/shotgun/flechette
	name = "flechette shell"
	desc = "A 12 gauge flechette shell."
	icon_state = "flshell"
	projectile_type = /obj/item/projectile/bullet/pellet/shotgun_flechette
	pellets = 6
	variance = 15

/obj/item/ammo_casing/shotgun/clownshot
	name = "buckshot shell..?"
	desc = "This feels a little light for a buckshot shell."
	icon_state = "gshell"
	projectile_type = /obj/item/projectile/bullet/pellet/shotgun_clownshot
	pellets = 20
	variance = 40

/obj/item/ammo_casing/shotgun/rubbershot
	name = "rubber shot"
	desc = "A shotgun casing filled with densely-packed rubber balls, used to incapacitate crowds from a distance."
	icon_state = "bshell"
	projectile_type = /obj/item/projectile/bullet/pellet/shotgun_rubbershot
	pellets = 6
	variance = 25
	materials = list(/datum/material/iron=4000)

/obj/item/ammo_casing/shotgun/improvised
	name = "improvised shell"
	desc = "An extremely weak shotgun shell with multiple small pellets made out of metal shards."
	icon_state = "improvshell"
	projectile_type = /obj/item/projectile/bullet/pellet/shotgun_improvised
	materials = list(/datum/material/iron=250)
	pellets = 10
	variance = 25

/obj/item/ammo_casing/shotgun/ion
	name = "ion shell"
	desc = "An advanced shotgun shell which uses a subspace ansible crystal to produce an effect similar to a standard ion rifle. \
	The unique properties of the crystal split the pulse into a spread of individually weaker bolts."
	icon_state = "ionshell"
	projectile_type = /obj/item/projectile/ion/weak
	pellets = 4
	variance = 35

/obj/item/ammo_casing/shotgun/laserbuckshot
	name = "laser buckshot"
	desc = "An advanced shotgun shell that uses  micro lasers to replicate the effects of a laser weapon in a ballistic package."
	icon_state = "lshell"
	projectile_type = /obj/item/projectile/beam/laser/buckshot
	pellets = 5
	variance = 35

/obj/item/ammo_casing/shotgun/uraniumpenetrator
	name = "depleted uranium slug"
	desc = "A relatively low-tech shell, utilizing the unique properties of Uranium, and possessing \
	very impressive armor penetration capabilities."
	icon_state = "dushell" 
	projectile_type = /obj/item/projectile/bullet/shotgun_uraniumslug

/obj/item/ammo_casing/shotgun/cryoshot
	name = "cryoshot shell"
	desc = "A state-of-the-art shell which uses the cooling power of Rhigoxane to snap freeze a target, without causing \
	them much harm."
	icon_state = "fshell" 
	projectile_type = /obj/item/projectile/bullet/pellet/shotgun_cryoshot
	pellets = 4
	variance = 35

/obj/item/ammo_casing/shotgun/techshell
	name = "unloaded technological shell"
	desc = "A high-tech shotgun shell which can be loaded with materials to produce unique effects."
	icon_state = "cshell"
	projectile_type = null
	
/obj/item/ammo_casing/shotgun/dart
	name = "shotgun dart"
	desc = "A dart for use in shotguns. Can be injected with up to 30 units of any chemical."
	icon_state = "cshell"
	projectile_type = /obj/item/projectile/bullet/reusable/dart
	var/reagent_amount = 30
	var/no_react = FALSE

/obj/item/ammo_casing/shotgun/dart/Initialize()
	. = ..()
	create_reagents(reagent_amount, OPENCONTAINER)
	if(no_react)
		ENABLE_BITFIELD(reagents.flags, NO_REACT)

/obj/item/ammo_casing/shotgun/dart/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	if(!BB)
		return
	if(reagents.total_volume < 0)
		return
	var/obj/item/projectile/bullet/reusable/dart/D = BB
	var/obj/item/reagent_containers/syringe/dart/temp/new_dart = new(D)

	new_dart.volume = reagents.total_volume
	if(no_react)
		new_dart.reagent_flags |= NO_REACT
	reagents.trans_to(new_dart, reagents.total_volume, transfered_by = user)
	D.add_dart(new_dart)
	..()

/obj/item/ammo_casing/shotgun/dart/attackby()
	return

/obj/item/ammo_casing/shotgun/dart/noreact
	name = "cryostasis shotgun dart"
	desc = "A dart for use in shotguns, using similar technology as cryostatis beakers to keep internal reagents from reacting. Can be injected with up to 10 units of any chemical."
	icon_state = "cnrshell"
	reagent_amount = 10
	no_react = TRUE

/obj/item/ammo_casing/shotgun/dart/bioterror
	desc = "A shotgun dart filled with deadly toxins."

/obj/item/ammo_casing/shotgun/dart/bioterror/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/consumable/ethanol/neurotoxin, 6)
	reagents.add_reagent(/datum/reagent/toxin/spore, 6)
	reagents.add_reagent(/datum/reagent/toxin/mutetoxin, 6) //;HELP OPS IN MAINT
	reagents.add_reagent(/datum/reagent/toxin/coniine, 6)
	reagents.add_reagent(/datum/reagent/toxin/sodium_thiopental, 6)

/obj/item/ammo_casing/shotgun/breacher
	name = "breaching slug"
	desc = "A 12 gauge anti-material slug. Great for breaching airlocks and windows with minimal shots. Only fits in tactical breaching shotguns."
	icon_state = "breacher"
	projectile_type = /obj/item/projectile/bullet/shotgun_breaching
	materials = list(/datum/material/iron=4000)
	caliber = "breaching"


/obj/item/ammo_casing/shotgun/thundershot
	name = "thunder slug"
	desc = "An advanced shotgun shell that uses stored electrical energy to discharge a massive shock on impact, arcing to nearby targets."
	icon_state = "Thshell"
	pellets = 3
	variance = 30
	projectile_type = /obj/item/projectile/bullet/pellet/shotgun_thundershot
