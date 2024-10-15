/obj/item/effect_granter/donator
	name = "Donator Transformation"
	icon = 'monkestation/code/modules/donator/icons/mob/pets.dmi'
	icon_state = "void_mothroach"
	var/mob/living/basic/animal_transformation = null
	var/basic_inhands_y_offset = -6

/obj/item/effect_granter/donator/grant_effect(mob/living/carbon/granter)
	var/mob/living/basic/animal = src.animal_transformation
	animal = new animal(granter.loc)
	animal.mind_initialize()
	var/datum/mind/granters_mind = granter.mind
	granters_mind.transfer_to(animal)
	animal.AddElement(/datum/element/dextrous)
	animal.AddComponent(/datum/component/basic_inhands, y_offset = basic_inhands_y_offset)
	qdel(granter)
	. = ..()

//Senri08
/obj/item/effect_granter/donator/slime
	name = "Slime transformation"
	icon_state = "slime"
	animal_transformation = /mob/living/basic/pet/slime/talkative

//Random
/obj/item/effect_granter/donator/spider
	name = "Spider transformation"
	icon_state = "spider"
	animal_transformation = /mob/living/basic/pet/spider/dancing

//mjolnir
/obj/item/effect_granter/donator/germanshepherd
	name = "German Shepherd transformation"
	icon_state = "germanshepherd"
	animal_transformation = /mob/living/basic/pet/dog/germanshepherd

//bidlink2
/obj/item/effect_granter/donator/cirno
	name = "Cirno transformation"
	icon = 'monkestation/icons/obj/plushes.dmi'
	icon_state = "cirno-happy"
	animal_transformation = /mob/living/basic/pet/cirno

//Random
/obj/item/effect_granter/donator/void_mothroach
	name = "Mothroach transformation"
	icon_state = "void_mothroach"
	animal_transformation = /mob/living/basic/mothroach/void


//ruby
/obj/item/effect_granter/donator/blahaj
	name = "Blahaj transformation"
	icon_state = "blahaj"
	animal_transformation = /mob/living/basic/pet/blahaj

//ttnt
/obj/item/effect_granter/donator/spycrab
	name = "Spycrab transformation"
	icon_state = "crab_red"
	animal_transformation = /mob/living/basic/crab/spycrab

//tonymcp

/obj/item/effect_granter/donator/void_butterfly
	name = "void butterfly transformation"
	icon_state = "void_butterfly"
	animal_transformation = /mob/living/basic/butterfly/void/spacial

//rickdude
/obj/item/effect_granter/donator/plant_crab
	name = "plantcrab transformation"
	icon_state = "crab_plant"
	animal_transformation = /mob/living/basic/crab/plant

//ellie
/obj/item/effect_granter/donator/gumball_goblin
	name = "gumball goblin transformation"
	icon_state = "gumball_goblin"
	animal_transformation = /mob/living/basic/pet/gumball_goblin


//Raziaar
/obj/item/effect_granter/donator/orangutan
	name = "orangutan transformation"
	icon_state = "orangutan"
	animal_transformation = /mob/living/basic/pet/orangutan


//Bluedragon66
/obj/item/effect_granter/donator/fluffykobold
	name = "fluffy kobold transformation"
	icon_state = "Bluedragon66"
	animal_transformation = /mob/living/basic/pet/fluffykobold

/obj/item/effect_granter/donator/darkscug
	name = "night slugcat transformation"
	icon = 'icons/mob/simple/slugcats.dmi'
	icon_state = "scug_nightcat"
	animal_transformation = /mob/living/basic/pet/darkscug

//Ophaq
/obj/item/effect_granter/donator/hypnotoad
	name = "hypnotoad transformation"
	icon_state = "hypnotoad"
	animal_transformation = /mob/living/basic/frog/hypnotoad

//ThePooba
/obj/item/effect_granter/donator/ghastly_evil_demon
	name = "ghastly evil demon transformation"
	icon = 'monkestation/code/modules/donator/icons/mob/pets_32x48.dmi'
	icon_state = "ghastly_evil_demon"
	animal_transformation = /mob/living/basic/pet/ghastly_evil_demon
	basic_inhands_y_offset = 0

//Eacles13
/obj/item/effect_granter/donator/albino_ghost_ian
	name = "ghost ian transformation"
	icon = 'monkestation/code/modules/donator/icons/mob/pets_32x48.dmi'
	icon_state = "ghastly_evil_demon"
	animal_transformation = /mob/living/basic/pet/albino_ghost_ian
