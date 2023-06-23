/mob/living/simple_animal/hostile/devil
	name = "True Devil"
	desc = "A pile of infernal energy, taking a vaguely humanoid form."
	icon = 'icons/mob/32x64.dmi'
	icon_state = "true_devil"
	gender = NEUTER

	del_on_death = TRUE
	dextrous = TRUE
	spacewalk = TRUE
	density = TRUE
	pass_flags = NONE
	health = 350
	maxHealth = 350
	ventcrawler = VENTCRAWLER_NONE
	sight = (SEE_TURFS | SEE_OBJS)
	status_flags = CANPUSH
	mob_size = MOB_SIZE_LARGE
	held_items = list(null, null)

/mob/living/simple_animal/hostile/devil/Initialize(mapload)
	grant_all_languages(TRUE, FALSE, TRUE)
	return ..()

/mob/living/simple_animal/hostile/devil/examine(mob/user)
	. = list("<span class='info'>This is [icon2html(src, user)] <b>[src]</b>!")

	//Left hand items
	for(var/obj/item/I in held_items)
		if(!(I.item_flags & ABSTRACT))
			. += "It is holding [I.get_examine_string(user)] in its [get_held_index_name(get_held_index_of_item(I))]."

	//Braindead
	if(!client && stat != DEAD)
		. += "The devil seems to be in deep contemplation."

	//Damaged
	if(stat == DEAD)
		. += span_deadsay("The hellfire seems to have been extinguished, for now at least.")
	else if(health < (maxHealth/10))
		. += span_warning("You can see hellfire inside its gaping wounds.")
	else if(health < (maxHealth/2))
		. += span_warning("You can see hellfire inside its wounds.")
	. += "</span>"

/mob/living/simple_animal/hostile/devil/resist_buckle()
	if(buckled)
		buckled.user_unbuckle_mob(src,src)
		visible_message(
			span_warning("[src] easily breaks out of [p_their()] handcuffs!"),
			span_notice("With just a thought your handcuffs fall off."),
		)

/mob/living/simple_animal/hostile/devil/assess_threat(judgement_criteria, lasercolor = "", datum/callback/weaponcheck=null)
	return 666

/mob/living/simple_animal/hostile/devil/get_ear_protection()
	return 2

/mob/living/simple_animal/hostile/devil/can_be_revived()
	return 1

/mob/living/simple_animal/hostile/devil/is_literate()
	return TRUE

/mob/living/simple_animal/hostile/devil/ex_act(severity, ex_target)
	var/b_loss
	switch(severity)
		if (EXPLODE_DEVASTATE)
			b_loss = 500
		if (EXPLODE_HEAVY)
			b_loss = 150
		if (EXPLODE_LIGHT)
			b_loss = 30
	adjustBruteLoss(b_loss)
	return ..()
