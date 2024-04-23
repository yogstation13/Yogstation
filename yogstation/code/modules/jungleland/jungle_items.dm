/obj/item/dummy_toxic_buildup
	name = "test dummy"
	desc = "what"
	icon = 'yogstation/icons/obj/jungle.dmi'
	icon_state = "damage_orb"

/obj/item/dummy_toxic_buildup/attack_self(mob/user)
	if(!isliving(user))
		return
	var/mob/living/living_user = user
	living_user.reagents.add_reagent(/datum/reagent/toxic_metabolities,15)
/obj/item/dummy_malaria
	name = "test dummy"
	desc = "what"
	icon = 'yogstation/icons/obj/jungle.dmi'
	icon_state = "damage_orb"

/obj/item/dummy_malaria/attack_self(mob/user)
	if(!iscarbon(user))
		return
	var/mob/living/carbon/carbon_user = user
	var/datum/disease/malaria/infection = new() 
	carbon_user.ForceContractDisease(infection,FALSE,TRUE)

/obj/item/tar_crystal
	name = "Broken Crystal"
	desc = "A broken crystal, it has an ominous dark glow around it. It looks like it was once part of something larger, and could be repaired..."
	icon = 'yogstation/icons/obj/jungle.dmi'
	icon_state = "tar_crystal_part0"
	max_integrity = 400
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/tar_crystal/Initialize()
	. = ..()
	AddComponent(/datum/component/gps, "Reckoning Signal")
	icon_state = "tar_crystal_part[pick(0,1,2)]"

/obj/item/full_tar_crystal
	name = "Ominous Crystal"
	desc = "a crystal that has been repaired from 3 parts, it emantes dark energy."
	icon = 'yogstation/icons/obj/jungle.dmi'
	icon_state = "tar_crystal"
	max_integrity = 400
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/explosive_shroom
	name = "Explosive Shroom"
	desc = "Mushroom picked from a foreign world, it will explode when handled too harshly"
	icon = 'yogstation/icons/obj/jungle.dmi'
	icon_state = "explosive_shroom"

/obj/item/explosive_shroom/attack_self(mob/user)
	. = ..()
	animate(src,time=2.49 SECONDS, color = "#e05a5a")
	addtimer(CALLBACK(src,PROC_REF(explode)),2.5 SECONDS)

/obj/item/explosive_shroom/proc/explode()
	dyn_explosion(get_turf(src),4)
	if(src && !QDELETED(src))
		qdel(src)

/obj/item/reagent_containers/food/snacks/grown/jungle
	icon = 'yogstation/icons/obj/jungle.dmi'


/obj/item/seeds/jungleland
	name = "jungleland seeds"
	desc = "You should never see this."
	lifespan = 50
	endurance = 25
	maturation = 7
	production = 4
	yield = 4
	potency = 50
	growthstages = 3
	rarity = 20
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.1)
	resistance_flags = ACID_PROOF

/obj/item/reagent_containers/food/snacks/grown/jungle/kuku
	name = "Kuku berry"
	desc = "What a pretty berry!"
	icon_state = "kuku_fruit"
	seed = /obj/item/seeds/jungleland/kuku

/obj/item/seeds/jungleland/kuku
	name = "pack of kuku bush seeds"
	desc = "These seeds will grow into a beautiful twisting fruiting bush"
	icon_state = "seed-kuku"
	species = "kuku"
	plantname = "Kuku Berry"
	product = /obj/item/reagent_containers/food/snacks/grown/jungle/kuku
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	growthstages = 4
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.1, /datum/reagent/jungle/retrosacharide = 0.2)

/obj/item/reagent_containers/food/snacks/grown/jungle/bonji
	name = "Bonji berry"
	desc = "What a pretty berry!"
	icon_state = "bonji_fruit"
	seed = /obj/item/seeds/jungleland/bonji

/obj/item/seeds/jungleland/bonji
	name = "pack of bonji bush seeds"
	desc = "These seeds will grow into a beautiful twisting fruiting bush"
	icon_state = "seed-bonji"
	species = "bonji"
	plantname = "Bonji Berry"
	product = /obj/item/reagent_containers/food/snacks/grown/jungle/bonji
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	genes = list(/datum/plant_gene/trait/squash)
	growthstages = 4
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.15, /datum/reagent/jungle/jungle_scent = 0.1)

/obj/item/reagent_containers/food/snacks/grown/jungle/bianco
	name = "Bianco berry"
	desc = "What a pretty berry!"
	icon_state = "bianco_fruit"
	seed = /obj/item/seeds/jungleland/bianco

/obj/item/seeds/jungleland/bianco
	name = "pack of bianco bush seeds"
	desc = "These seeds will grow into a beautiful twisting fruiting bush"
	icon_state = "seed-bianco"
	species = "bianco"
	plantname = "Bianco Berry"
	product = /obj/item/reagent_containers/food/snacks/grown/jungle/bianco
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	genes = list(/datum/plant_gene/trait/glow/white)
	growthstages = 4
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.25,/datum/reagent/consumable/nutriment/vitamin = 0.05)

/obj/item/reagent_containers/food/snacks/grown/jungle/liberal_hat
	name = "Liberal Hat"
	desc = "Hats off madlad, take me and free your mind..."
	icon_state = "liberal_hat"
	seed = /obj/item/seeds/jungleland/liberal_hats

/obj/item/seeds/jungleland/liberal_hats
	name = "pack of liberal hat mycelium"
	desc = "These spores should grow into liberal hats"
	icon_state = "mycelium-liberal-hat"
	species = "liberal_hat"
	plantname = "Liberal Hat"
	product = /obj/item/reagent_containers/food/snacks/grown/jungle/liberal_hat
	growing_icon = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	genes = list(/datum/plant_gene/trait/plant_type/fungal_metabolism)
	growthstages = 3
	reagents_add = list(/datum/reagent/consumable/nutriment = 0.02, /datum/reagent/jungle/polybycin = 0.1)

/obj/item/reagent_containers/food/snacks/grown/jungle/cinchona_bark
	name = "Cinchona Bark"
	desc = "Powerful healing herb that can help with curing many exotic diseases"
	icon_state = "cinchona_bark"
	seed = /obj/item/seeds/jungleland/cinchona
	distill_reagent = /datum/reagent/space_cleaner/sterilizine/primal

/obj/item/seeds/jungleland/cinchona
	name = "pack of cinchona seeds"
	desc = "These seeds should grow into cinchona shrubs"
	icon_state = "seed-cinchona"
	species = "cinchona"
	plantname = "Cinchona"
	product = /obj/item/reagent_containers/food/snacks/grown/jungle/cinchona_bark
	growing_icon = 'icons/obj/hydroponics/growing.dmi'
	growthstages = 3
	reagents_add = list(/datum/reagent/quinine = 0.1, /datum/reagent/medicine/atropine = 0.05, /datum/reagent/medicine/omnizine = 0.1)

/obj/item/seeds/jungleland/magnus_purpura
	name = "pack of magnus purpura seeds"
	desc = "These seeds should grow into cinchona shrubs"
	icon_state = "seed-magnus_purpura"
	species = "magnus_purpura"
	plantname = "Magnus Purpura"
	product = /obj/item/reagent_containers/food/snacks/grown/jungle/magnus_purpura
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	growthstages = 3
	reagents_add = list(/datum/reagent/magnus_purpura_enzyme = 0.25)

/obj/item/reagent_containers/food/snacks/grown/jungle/magnus_purpura
	name = "Magnus Purpura flower"
	desc = "A head of a massive flower, it contains potent anti-acidic enzymes that allow someone to temporarily be immune to highly corrosive waters on jungleland. It can be processed futher to increase it's efficiency."
	icon_state = "magnus_purpura_flower"
	seed = /obj/item/seeds/jungleland/magnus_purpura
	distill_reagent = /datum/reagent/magnus_purpura_enzyme/condensed

/obj/item/organ/regenerative_core/dryad
	name = "Dryad heart"
	desc = "Heart of a dryad. It can be used to heal completely, but it will rapidly decay into uselessness."
	icon = 'yogstation/icons/obj/jungle.dmi'
	icon_state = "dryad_heart"
	status_effect = /datum/status_effect/regenerative_core/dryad

/obj/item/organ/regenerative_core/dryad/Initialize()
	. = ..()
	update_appearance(UPDATE_ICON)

/obj/item/organ/regenerative_core/dryad/update_icon_state()
	. = ..()
	icon_state = inert ? "dryad_heart_decay" : initial(icon_state)
	for(var/X in actions)
		var/datum/action/A = X
		A.build_all_button_icons()

/obj/item/organ/regenerative_core/dryad/preserved(implanted)
	. = ..()
	name = "preserved [initial(name)]"
	desc = "Heart of a dryad. It can be used to heal completely, unlike others, this one won't decay"

/obj/item/organ/regenerative_core/dryad/go_inert()
	..()
	desc = "[src] has become inert. It has decayed, and is completely useless."

/obj/item/organ/regenerative_core/dryad/preserved(implanted = 0)
	..()
	desc = "[src] has been stabilized. It is preserved, allowing you to use it to heal completely without danger of decay."

/obj/item/organ/regenerative_core/dryad/corrupted
	name = "Corrupted dryad heart"
	desc = "Heart of a corrupted dryad, for now it still lives, and i may use some of it's strength to help me live aswell."
	icon_state = "corrupted_heart"
	status_effect = /datum/status_effect/corrupted_dryad

/obj/item/clothing/neck/yogs/skin_twister
	name = "skin-twister cloak"
	desc = "Cloak made out of skin of the elusive skin-twister, when worn over head it makes you invisible to the smaller fauna of the jungle."
	icon_state = "skin_twister_cloak_0"
	item_state = "skin_twister_cloak_0"

	var/active = FALSE
	var/list/cached_faction_list

/obj/item/clothing/neck/yogs/skin_twister/equipped(mob/user, slot)
	. = ..()
	active = FALSE
	if(slot != ITEM_SLOT_NECK)
		return
	active = TRUE
	cached_faction_list = user.faction.Copy() // we dont keep the reference to it 
	user.faction += "skintwister_cloak"

/obj/item/clothing/neck/yogs/skin_twister/dropped(mob/user)
	if(active)
		active = FALSE 
		user.faction = cached_faction_list	
	return ..()

/obj/item/stack/sheet/skin_twister
	name = "skin twister hide"
	desc = "Hide of a skin twister"
	singular_name = "skintwister hide piece"
	icon_state = "sheet-skintwister_hide"

/obj/item/stack/sheet/slime
	name = "slime granule"
	desc = "densely compacted granulate of organic slime"
	singular_name = "slime granulate"
	icon_state = "sheet-slime"

/obj/item/stack/sheet/meduracha 
	name = "meduracha tentacles"
	desc = "sharp and wiry limbs of a meduracha"
	singular_name = "meduracha tentacle"
	icon_state = "sheet-meduracha"
	grind_results = list(/datum/reagent/toxin/meduracha = 5)

/obj/item/stinger 
	name = "giant insect stinger"
	desc = "a stinger of a giant exotic insect, quite sharp"
	icon = 'yogstation/icons/obj/jungle.dmi'
	icon_state = "stinger"

/obj/item/melee/stinger_sword
	name = "stinger sword"
	desc = "a sword made out of giant insect stinger crudely glued to a metal rod"
	force = 15
	armour_penetration = 75
	icon = 'yogstation/icons/obj/jungle.dmi'
	lefthand_file = 'yogstation/icons/mob/inhands/lefthand.dmi'
	righthand_file = 'yogstation/icons/mob/inhands/righthand.dmi'
	icon_state = "stinger_sword"
	item_state = "stinger_sword"

/obj/item/melee/stinger_sword/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!iscarbon(target))
		return 
	var/mob/living/carbon/C = target 
	C.blood_volume -= force

/obj/item/stinger_trident	//an awesome trident made of fauna parts and metal. Is slightly superior to bonespear, though doesn't have slowdown/reach, since thats pretty bad vs jungle fauna.
	name = "stinger trident"
	desc = "a well-crafted trident made of metal and insect stingers tied together with still prickly meduracha tentacles."
	force = 11
	icon = 'yogstation/icons/obj/jungle.dmi'
	icon_state = "sting_trident0"
	lefthand_file = 'yogstation/icons/mob/inhands/lefthand.dmi'
	righthand_file = 'yogstation/icons/mob/inhands/righthand.dmi'
	max_integrity = 100
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	throwforce = 24
	throw_speed = 4
	embedding = list("embedded_impact_pain_multiplier" = 3)
	armour_penetration = 25				//Enhanced armor piercing
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "poked", "jabbed", "torn", "gored", "stung")
	sharpness = SHARP_EDGED

/obj/item/stinger_trident/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, \
		force_unwielded = 11, \
		force_wielded = 19, \
		icon_wielded = "sting_trident1", \
		wielded_stats = list(SWING_SPEED = 1, ENCUMBRANCE = 0.4, ENCUMBRANCE_TIME = 5, REACH = 2, DAMAGE_LOW = 0, DAMAGE_HIGH = 0), \
	)
/obj/item/stinger_trident/update_icon_state()  //Currently only here to fuck with the on-mob icons.
	. = ..()
	icon_state = "sting_trident[HAS_TRAIT(src, TRAIT_WIELDED)]"
	return

/obj/item/slime_sling 
	name = "slime sling"
	desc = "a sling made out of organic slime... why are you aiming at me?"
	icon = 'yogstation/icons/obj/jungle.dmi'
	icon_state = "slime_sling_0"

	var/state = 0

/obj/item/slime_sling/attack_self(mob/user)
	. = ..()
	RegisterSignal(user,COMSIG_MOB_CLICKON, PROC_REF(sling))
	for(var/i in 1 to 3)
		if(do_after(user,2.5 SECONDS, user))
			state++
			icon_state = "slime_sling_[state]" 
		else 
			cancel(user)
			return
	RegisterSignal(user,COMSIG_MOVABLE_MOVED, PROC_REF(cancel))

/obj/item/slime_sling/proc/cancel(mob/user)
	UnregisterSignal(user,COMSIG_MOB_CLICKON)
	UnregisterSignal(user,COMSIG_MOVABLE_MOVED)
	state = 0
	icon_state = "slime_sling_0"


/obj/item/slime_sling/proc/sling(mob/user,atom/A, params)
	UnregisterSignal(user,COMSIG_MOB_CLICKON)
	UnregisterSignal(user,COMSIG_MOVABLE_MOVED)	
	if(!state)
		return
	var/turf/T = get_turf(A)

	var/dir = Get_Angle(user.loc,T)
	
	//i actually fucking hate this utility function, for whatever reason Get_Angle returns the angle assuming that [0;-1] is 0 degrees rather than [1;0] like any sane being.
	var/tx = clamp(0,round(T.x + sin(dir) * state * 5),255)
	var/ty = clamp(0,round(T.y + cos(dir) * state * 5),255)
	user.throw_at(locate(tx,ty,T.z),state * 5,state * 5)
	state = 0
	icon_state = "slime_sling_0"

/obj/item/clothing/head/yogs/tar_king_crown
	name = "Crown of the Tar King"
	desc = "And old and withered crown made out of bone of unknown origin, there is a vibrant pinkish crystal embedded in it, it is warm to the touch..."
	icon = 'yogstation/icons/obj/jungle.dmi'
	icon_state = "tar_king_crown"
	armor = list(MELEE = 80, BULLET = 40, LASER = 60, ENERGY = 50, BOMB = 80, BIO = 70, RAD = 60, FIRE = 100, ACID = 100)
	actions_types = list(/datum/action/cooldown/tar_crown_spawn_altar,/datum/action/cooldown/tar_crown_teleport)
	var/max_tar_shrines = 3
	var/list/current_tar_shrines = list()
	var/next_spawn = 0
	var/next_teleport = 0
	
/obj/item/clothing/head/yogs/tar_king_crown/Destroy()
	QDEL_LIST_ASSOC_VAL(current_tar_shrines)
	return ..()

/obj/item/clothing/head/yogs/tar_king_crown/item_action_slot_check(slot, mob/user)
	if(slot == ITEM_SLOT_HEAD)
		return TRUE
	return FALSE

/obj/item/book/manual/ivymen
	name = "Tome of Herbal Knowledge"
	icon_state = "book1"
	author = "Manchineel the Shaman"
	title = "Tome of Herbal Knowledge"
	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>
				<h1>Ancient Ivymen Recipes</h1>
				I pass down my knowledge to my kin, all that I know shall forever be preserved in this book.
				Inside, I shall teach you various important healing recipes and crafting techniques.
				<h2>Poultice:</h2>
				To prepare, first gather wood, a mortar and pestle, cinchona bark, ashes from a burnt item, a barrel, and a heat source such as a welder/lit candle.
				Next, place the cinchona bark inside the barrel for it to ferment.
				While the cinchona ferments, grind 2 planks of wood in the mortar and burn an item such as wood in fire for ashes.
				Afterwards, scoop up ashes with the mortar and distill the fermented cinchona. If the ashes are warm enough, it may mix without extra heat needed.
				If it has yet to mix, heat up the bowl by using the welder on it until it has done so.
				Apply product to wounded parts to heal them. May cause loss of breath.
				<h2>Sterilizine:</h2>
				To prepare, acquire a wooden barrel and cinchona bark.
				Place the cinchona in the barrel to ferment.
				Once done, the product can be used for making poultice or using in surgery.
				<h2>Flora:</h2>
				Every plant we are blessed with can be used in some way. 
				Liberal hats can be used to free the mind for a pleasant time.
				Cinchona bark can heal wounds when consumed, or fermented for sterilizine and poultice.
				Magnus Purpura can be used to temporarily make you immune to sulphuric pits
				<h2>Leather:</h2>
				Leather does not need to be interacted with much as a shaman,
				especially if you are prioritizing medicine.
				However, it can still be useful to know how to make it,
				Especially since you can use it, or cloth, to create a medicinal pouch useful for holding plants and medicines.
				To create it, acquire some hide, the most available of which will be goliath hide.
				Next, skin it well with a sharp tool.
				Afterwards, wash with water thoroughly, and then dry by placing it over a grill atop a lit bonfire.
				<h2>Meduracha Toxin:</h2>
				The toxins off of meduracha tentacles can be harvested.
				Grind their tentacles in a mortar and pestle to obtain it.
				It is deadly and causes confusion in targets, and is useful in blowguns against humans.
				</body>
				</html>
			"}

/obj/item/gps/internal/tar_king_crystal
	icon_state = null
	gpstag = "Reckoning Signal"
	desc = "It's time to repay due debts..."
	invisibility = 100

/obj/item/charged_tar_crystal
	name = "Glowing Ominous Crystal"
	desc = "It is glowing with pure power."

/obj/item/crusher_trophy/jungleland 
	icon = 'yogstation/icons/obj/jungle.dmi'

/obj/item/crusher_trophy/jungleland/aspect_of_tar
	name = "Aspect of tar"
	desc = "It pulsates with a corroding, everpresent energy"
	icon_state = "aspect_of_tar"
	denied_type = /obj/item/crusher_trophy/jungleland/aspect_of_tar
	var/last_applied
	var/cooldown = 6 SECONDS

/obj/item/crusher_trophy/jungleland/aspect_of_tar/effect_desc()
	return "Slows down enemies to crawling speed and gives a shield that blocks a single enemy attack (lasts 5 seconds)."

/obj/item/crusher_trophy/jungleland/aspect_of_tar/on_mark_detonation(mob/living/target, mob/living/user)
	. = ..()
	if(!last_applied || world.time >= last_applied + cooldown)
		user.apply_status_effect(/datum/status_effect/tar_shield)
		last_applied = world.time

/obj/item/crusher_trophy/jungleland/aspect_of_tar/on_mark_application(mob/living/target, datum/status_effect/crusher_mark/mark, had_mark)
	. = ..()
	if(!isanimal(target))	
		return 
	var/mob/living/simple_animal/S = target 
	S.turns_per_move *= 4
	addtimer(CALLBACK(S,/mob/living/simple_animal/proc/return_standard_turns_per_move),5 SECONDS) 

/obj/item/crusher_trophy/jungleland/meduracha_tentacles
	name = "Alpha Meduracha tentacles"
	desc = "It stings, it burns, it twists, it turns."
	icon_state = "meduracha_tentacles"
	denied_type = /obj/item/crusher_trophy/jungleland/meduracha_tentacles

/obj/item/crusher_trophy/jungleland/meduracha_tentacles/effect_desc()
	return "Infects the mob with toxins that cause half of backstabs damage after 5 seconds"

/obj/item/crusher_trophy/jungleland/meduracha_tentacles/on_mark_detonation(mob/living/target, mob/living/user)
	. = ..()
	addtimer(CALLBACK(src,PROC_REF(delayed_damage),target),5 SECONDS)

/obj/item/crusher_trophy/jungleland/meduracha_tentacles/proc/delayed_damage(mob/living/target)
	if(!target || QDELETED(target) || target.health <= 0)
		return
	var/def_check = target.getarmor(type = TOX)
	target.apply_damage(40, TOX, blocked = def_check)
	
/obj/item/crusher_trophy/jungleland/blob_brain
	name = "Gelatinous Brain"
	desc = "Slimy mass of organic tissue, it still pulsates when pressed."
	icon_state = "slime_brain"
	denied_type = /obj/item/crusher_trophy/jungleland/blob_brain

/obj/item/crusher_trophy/jungleland/blob_brain/effect_desc()
	return "Spreads the mark to mobs close together, activating a mark on adjacent mobs activates all the marks at once."

/obj/item/crusher_trophy/jungleland/blob_brain/on_mark_detonation(mob/living/target, mob/living/user,obj/item/kinetic_crusher/hammer_synced)
	for(var/mob/living/L in range(1,target))
		if(L == user || L == target)
			continue 
		var/datum/status_effect/crusher_mark/CM = L.has_status_effect(STATUS_EFFECT_CRUSHERMARK)
		if(!CM || CM.hammer_synced != hammer_synced || !L.remove_status_effect(STATUS_EFFECT_CRUSHERMARK))
			continue
		var/datum/status_effect/crusher_damage/C = L.has_status_effect(STATUS_EFFECT_CRUSHERDAMAGETRACKING)
		if(!C)
			C = L.apply_status_effect(STATUS_EFFECT_CRUSHERDAMAGETRACKING)
		var/target_health = L.health
		for(var/t in hammer_synced.trophies)
			var/obj/item/crusher_trophy/T = t
			INVOKE_ASYNC(T,/obj/item/crusher_trophy/proc/on_mark_detonation,L,user,hammer_synced)
		if(!QDELETED(L))
			if(!QDELETED(C))
				C.total_damage += target_health - L.health //we did some damage, but let's not assume how much we did
			new /obj/effect/temp_visual/kinetic_blast(get_turf(L))
			var/def_check = L.getarmor(type = BOMB)
			if(!QDELETED(C))
				C.total_damage += hammer_synced.detonation_damage
			L.apply_damage(hammer_synced.detonation_damage, BRUTE, blocked = def_check)
			playsound(user, 'sound/weapons/kenetic_accel.ogg', 100, 1) //Seriously who spelled it wrong

/obj/item/crusher_trophy/jungleland/blob_brain/on_mark_application(mob/living/target, datum/status_effect/crusher_mark/mark, had_mark,obj/item/kinetic_crusher/hammer_synced)
	. = ..()
	if(had_mark)
		return
	for(var/mob/living/L in range(1,target))
		var/had_effect = (L.has_status_effect(STATUS_EFFECT_CRUSHERMARK)) //used as a boolean
		if(had_effect)
			continue
		var/datum/status_effect/crusher_mark/CM = L.apply_status_effect(STATUS_EFFECT_CRUSHERMARK, hammer_synced)
		if(hammer_synced)
			for(var/t in hammer_synced.trophies)
				var/obj/item/crusher_trophy/T = t
				T.on_mark_application(target, CM, had_effect, hammer_synced)

/obj/item/crusher_trophy/jungleland/dryad_branch
	name = "Dryad Branch"
	desc = "Branch of a living tree, it still holds some of it's power."
	icon_state = "dryad_branch"
	denied_type = /obj/item/crusher_trophy/jungleland/dryad_branch

/obj/item/crusher_trophy/jungleland/dryad_branch/effect_desc()
	return "Gives a stacking (up to 5 times) regeneration effect for every detonated mark. Lasts 5 seconds, extending on successful mark detonation. Missing resets the stacks."

/obj/item/crusher_trophy/jungleland/dryad_branch/add_to(obj/item/kinetic_crusher/H, mob/living/user)
	. = ..()
	RegisterSignal(H,COMSIG_KINETIC_CRUSHER_PROJECTILE_ON_RANGE,PROC_REF(clear_status_effects))
	RegisterSignal(H,COMSIG_KINETIC_CRUSHER_PROJECTILE_FAILED_TO_MARK,PROC_REF(clear_status_effects))

/obj/item/crusher_trophy/jungleland/dryad_branch/remove_from(obj/item/kinetic_crusher/H, mob/living/user)
	. = ..()
	UnregisterSignal(H,COMSIG_KINETIC_CRUSHER_PROJECTILE_FAILED_TO_MARK)
	UnregisterSignal(H,COMSIG_KINETIC_CRUSHER_PROJECTILE_ON_RANGE)

/obj/item/crusher_trophy/jungleland/dryad_branch/on_mark_detonation(mob/living/target, mob/living/user, obj/item/kinetic_crusher/hammer_synced)
	. = ..()
	user.apply_status_effect(/datum/status_effect/bounty_of_the_forest)

/obj/item/crusher_trophy/jungleland/dryad_branch/proc/clear_status_effects(datum/source,mob/living/user,obj/item/kinetic_crusher/hammer_synced)
	if(user.has_status_effect(/datum/status_effect/bounty_of_the_forest))
		user.remove_status_effect(/datum/status_effect/bounty_of_the_forest)

/obj/item/crusher_trophy/jungleland/corrupted_dryad_branch 
	name = "Corrupted branch"
	desc = "A tendril of corruption that took over a forest spirit. Maybe it can be of use for me?"
	icon_state = "corrupted_dryad_branch"
	denied_type = /obj/item/crusher_trophy/jungleland/corrupted_dryad_branch
	var/damage_bonus = 0
	var/cooldown_bonus = 0
	var/current_state = 0
	COOLDOWN_DECLARE(bonus_timer)
	var/bonus_cooldown = 5 SECONDS

/obj/item/crusher_trophy/jungleland/corrupted_dryad_branch/effect_desc()
	return "Gives a stacking (up to 5 times) decreases your shot delay and increases detonation damage when you detonate a mark. Lasts 5 seconds, extending on successful mark detonation. Missing resets the stacks."

/obj/item/crusher_trophy/jungleland/corrupted_dryad_branch/add_to(obj/item/kinetic_crusher/H, mob/living/user)
	. = ..()
	RegisterSignal(H,COMSIG_KINETIC_CRUSHER_PROJECTILE_ON_RANGE,PROC_REF(remove_bonuses))
	RegisterSignal(H,COMSIG_KINETIC_CRUSHER_PROJECTILE_FAILED_TO_MARK,PROC_REF(remove_bonuses))
	START_PROCESSING(SSprocessing,src)

/obj/item/crusher_trophy/jungleland/corrupted_dryad_branch/remove_from(obj/item/kinetic_crusher/H, mob/living/user)
	. = ..()
	UnregisterSignal(H,COMSIG_KINETIC_CRUSHER_PROJECTILE_FAILED_TO_MARK)
	UnregisterSignal(H,COMSIG_KINETIC_CRUSHER_PROJECTILE_ON_RANGE)
	remove_bonuses()
	STOP_PROCESSING(SSprocessing,src)

/obj/item/crusher_trophy/jungleland/corrupted_dryad_branch/on_mark_detonation(mob/living/target, mob/living/user, obj/item/kinetic_crusher/hammer_synced)
	COOLDOWN_START(src, bonus_timer, bonus_cooldown)
	var/previous_state = current_state
	current_state = min(current_state + 1, 5)
	cooldown_bonus = 2 * current_state
	damage_bonus = 5 * current_state
	if(previous_state != current_state)
		hammer_synced.detonation_damage += 5
		hammer_synced.charge_time -= 2
	user.throw_alert("glory_of_victory",/atom/movable/screen/alert/status_effect/glory_of_victory,current_state)

/obj/item/crusher_trophy/jungleland/corrupted_dryad_branch/proc/remove_bonuses(datum/source,mob/living/user,obj/item/kinetic_crusher/hammer_synced)
	if(!hammer_synced)
		hammer_synced = loc
		user = hammer_synced.loc
	hammer_synced.detonation_damage -= damage_bonus
	hammer_synced.charge_time += cooldown_bonus
	current_state = 0
	cooldown_bonus = 0
	damage_bonus = 0
	user.clear_alert("glory_of_victory")

/obj/item/crusher_trophy/jungleland/corrupted_dryad_branch/process(delta_time)
	if(COOLDOWN_FINISHED(src, bonus_timer))
		remove_bonuses()

/obj/item/crusher_trophy/jungleland/mosquito_sack
	name = "Mosquito's bloodsack"
	desc = "It used to be filled with blood, now it is empty."
	icon_state = "mosquito_sack"
	denied_type = /obj/item/crusher_trophy/jungleland/mosquito_sack

/obj/item/crusher_trophy/jungleland/mosquito_sack/effect_desc()
	return "Detonating a mark heals you for 10% of the damage applied."

/obj/item/crusher_trophy/jungleland/mosquito_sack/after_mark_detonation(mob/living/target, mob/living/user, obj/item/kinetic_crusher/hammer_synced,damage_dealt)
	user.adjustBruteLoss(-0.1 * damage_dealt)
	user.adjustFireLoss(-0.1 * damage_dealt)
	user.adjustToxLoss(-0.1 * damage_dealt) 
	
/obj/item/crusher_trophy/jungleland/wasp_head
	name = "Matriarch wasp's head"
	desc = "It's eyes still stare at you."
	icon_state = "wasp_head"
	denied_type = /obj/item/crusher_trophy/jungleland/wasp_head

	var/damage_per_dist = 4
	var/first_loc

/obj/item/crusher_trophy/jungleland/wasp_head/effect_desc()
	return "Increases the damage of mark detonation proprotionally to distance travelled."

/obj/item/crusher_trophy/jungleland/wasp_head/on_projectile_fire(obj/projectile/destabilizer/marker, mob/living/user)
	first_loc = get_turf(user)

/obj/item/crusher_trophy/jungleland/wasp_head/after_mark_detonation(mob/living/target, mob/living/user, obj/item/kinetic_crusher/hammer_synced, damage_dealt)
	var/dist = get_dist(get_turf(target),first_loc)
	var/damage = dist * damage_per_dist 
	target.apply_damage(damage, BRUTE, blocked = target.getarmor(type = BOMB))

/obj/item/stack/sheet/ivory_crumbles
	name = "ivory crumbles"
	desc = "pale and beautiful crumbles of past long gone."
	singular_name = "ivory crumble"
	icon_state = "sheet-ivory"
	grind_results = list(/datum/reagent/potassium = 10) //ivory is a bone

/obj/item/gem/tarstone
	name = "primal tarstone"
	desc = "An incredibly dense and tough chunk of ancient tar. Millions of microscopic runes subtly line the surface, and probably make this artifact worth thousands."
	icon = 'yogstation/icons/obj/jungle.dmi'
	icon_state = "targem"
	point_value = 3000
	light_range = 3
	light_power = 4
	light_color = "#2d066d"

/obj/item/demon_core
	name = "demon core"
	desc = "It glows with a faint light, you can feel the energy buzzing off of it"
	icon = 'yogstation/icons/obj/jungle.dmi'
	icon_state = "demon_core"

/obj/item/demon_core/examine(mob/user)
	. = ..()
	. += "You can insert it into any hardsuit to give it a rechargeable shield."
	. += "You can insert it into the super-matter engine, to double it's rad production."

/obj/item/demon_core/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return ..()
	if(istype(target,/obj/item/clothing/suit/space/hardsuit))
		target.AddComponent(/datum/component/shielded,'yogstation/icons/effects/effects.dmi',"tar_shield", 1, 30 SECONDS, ITEM_SLOT_OCLOTHING)
		visible_message("[user] inserts [src] into [target]")
		qdel(src)
		return
	return ..()
	