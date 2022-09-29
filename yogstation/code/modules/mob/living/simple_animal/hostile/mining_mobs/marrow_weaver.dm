/mob/living/simple_animal/hostile/asteroid/marrowweaver
	name = "marrow weaver"
	desc = "A big, angry, venomous spider. It likes to snack on bone marrow. Its preferred food source is you."
	icon = 'yogstation/icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "weaver"
	icon_living = "weaver"
	icon_aggro = "weaver"
	icon_dead = "weaver_dead"
	throw_message = "bounces harmlessly off the"
	butcher_results = list(/obj/item/stack/ore/uranium = 2, /obj/item/stack/sheet/bone = 3, /obj/item/stack/sheet/sinew = 2, /obj/item/stack/sheet/animalhide/weaver_chitin = 4, /obj/item/reagent_containers/food/snacks/meat/slab/spider = 2)
	loot = list()
	attacktext = "bites"
	gold_core_spawnable = HOSTILE_SPAWN
	health = 220
	maxHealth = 220
	vision_range = 8
	move_to_delay = 16
	speed = 3
	melee_damage_lower = 13
	melee_damage_upper = 16
	stat_attack = 1
	robust_searching = 1
	see_in_dark = 7
	ventcrawler = 2
	pass_flags = PASSTABLE
	attack_sound = 'sound/weapons/bite.ogg'
	deathmessage = "rolls over, frothing at the mouth before stilling."
	var/poison_type = /datum/reagent/toxin/spore
	var/poison_per_bite = 5
	var/buttmad = 0
	var/melee_damage_lower_angery0 = 13
	var/melee_damage_upper_angery0 = 16
	var/melee_damage_lower_angery1 = 15
	var/melee_damage_upper_angery1 = 20

/mob/living/simple_animal/hostile/asteroid/marrowweaver/adjustHealth(amount)
	if(buttmad == 0)
		if(health < maxHealth/3)
			buttmad = 1
			visible_message(span_danger("[src] chitters in rage, baring its fangs!"))
			melee_damage_lower = melee_damage_lower_angery1
			melee_damage_upper = melee_damage_upper_angery1
			move_to_delay = 8
			speed = 3
			poison_type = /datum/reagent/toxin/venom
			poison_per_bite = 6
	else if(buttmad == 1)
		if(health > maxHealth/2)
			buttmad = 0
			visible_message(span_notice("[src] seems to have calmed down, but not by much."))
			melee_damage_lower = melee_damage_lower_angery0
			melee_damage_upper = melee_damage_upper_angery0
			poison_type = initial(poison_type)
			poison_per_bite = initial(poison_per_bite)
	..()

/mob/living/simple_animal/hostile/asteroid/marrowweaver/AttackingTarget()
	..()
	if(isliving(target))
		var/mob/living/L = target
		if(target.reagents)
			L.reagents.add_reagent(poison_type, poison_per_bite)
		if((L.stat == DEAD) && (health < maxHealth) && ishuman(L))
			var/mob/living/carbon/human/H = L
			var/foundorgans = 0
			for(var/obj/item/organ/O in H.internal_organs)
				if(O.zone == "chest")
					foundorgans++
					qdel(O)
			if(foundorgans)
				src.visible_message(
					span_danger("[src] drools some toxic goo into [L]'s innards..."),
					span_danger("Before sucking out the slurry of bone marrow and flesh, healing itself!"),
					"<span class-'userdanger>You liquefy [L]'s innards with your venom and suck out the resulting slurry, revitalizing yourself.</span>")
				adjustBruteLoss(round(-H.maxHealth/2))
				for(var/obj/item/bodypart/B in H.bodyparts)
					if(B.body_zone == "chest")
						B.dismember()
			else
				to_chat(src, span_warning("There are no organs left in this corpse."))

/mob/living/simple_animal/hostile/asteroid/marrowweaver/CanAttack(atom/A)
	if(..())
		return TRUE
	if((health < maxHealth) && ishuman(A) && !faction_check_mob(A))
		var/mob/living/carbon/human/H = A
		for(var/obj/item/organ/O in H.internal_organs)
			if(O.zone == "chest")
				return TRUE
	return FALSE

/mob/living/simple_animal/hostile/asteroid/marrowweaver/clown
	name = "Clown Spider"
	desc = "A big, angry, venomous clown spider. It likes to snack on noses. Its preferred food source is you."
	icon = 'goon/icons/mob/clownspider.dmi'
	icon_state = "clownspider_queen"
	icon_living = "clownspider_queen"
	icon_aggro = "clownspider_queen"
	icon_gib = "clown_gib"
	throw_message = "bounces harmlessly off the"
	loot = list(/obj/item/clothing/mask/gas/clown_hat)
	attacktext = "bites"
	del_on_death = TRUE
	gold_core_spawnable = HOSTILE_SPAWN
	health = 250
	maxHealth = 250
	poison_type = /datum/reagent/consumable/ethanol/bananahonk

/mob/living/simple_animal/hostile/asteroid/marrowweaver/cluwne
	name = "Cluwne Spider"
	desc = "A big, angry, venomous... something It likes to snack on souls. Its preferred food source is you probably."
	icon = 'goon/icons/mob/cluwnespider.dmi'
	icon_state = "cluwnespider_queen"
	icon_living = "cluwnespider_queen"
	icon_aggro = "cluwnespider_queen"
	icon_gib = "clown_gib"
	throw_message = "bounces harmlessly off the"
	loot = list(/obj/item/clothing/mask/yogs/cluwne/happy_cluwne)
	attacktext = "bites"
	del_on_death = TRUE
	gold_core_spawnable = NO_SPAWN
	health = 450
	maxHealth = 450
	poison_type = /datum/reagent/cluwnification
	
/mob/living/simple_animal/hostile/asteroid/marrowweaver/ice
	name = "Frostbite Spider"
	desc = "A big, angry, venomous ice spider. It likes to snack on bone marrow. Its preferred food source is you."
	icon_state = "weaver_ice"
	icon_living = "weaver_ice"
	icon_aggro = "weaver_ice"
	icon_dead = "weaver_ice_dead"
	melee_damage_lower = 10 //stronger venom, but weaker attack.
	melee_damage_upper = 13
	poison_type = /datum/reagent/consumable/frostoil
	poison_per_bite = 5
