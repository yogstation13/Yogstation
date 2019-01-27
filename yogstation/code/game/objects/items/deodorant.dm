/obj/item/deodorant
	name = "deodorant"
	desc = "AX brand deodorant. The smell brings you back to school years."
	icon = 'yogstation/icons/obj/items.dmi'
	icon_state = "deodorant"
	item_flags = NOBLUDGEON
	var/uses = 15

/obj/item/deodorant/attack_self(mob/living/carbon/human/user)
	if(!istype(user))
		to_chat(user, "<span class='danger'>You aren't quite sure how to use this.</span>")
		return
	if(uses <= 0)
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return
	to_chat(user, "<span class='notice'>You spray yourself down. The previous smell is mostly gone, but you're not sure if it's for the better.</span>")
	user.adjust_hygiene(HYGIENE_LEVEL_CLEAN * 0.5) //Almost as good as a shower!
	playsound(user, 'sound/effects/spray.ogg', 50)
	uses--

/obj/item/deodorant/afterattack(atom/target, mob/living/carbon/human/user, proximity)
	if(!proximity || !istype(user))
		return
	if(uses <= 0)
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return
	var/obj/item/lighter/L = user.get_inactive_held_item()
	if(L && istype(L) && L.lit)
		if(istype(target, /obj/structure/spider/spiderling))
			playsound(user, 'yogstation/sound/effects/burning.wav', 50)
			user.visible_message("<span class='danger'>[user] incinerates [target].</span>", "<span class='danger'>You incinerate [target].</span>")
			qdel(target)
			uses--
		else if(istype(target, /mob/living/simple_animal/hostile/poison/giant_spider))
			playsound(user, 'yogstation/sound/effects/burning.wav', 50)
			user.visible_message("<span class='danger'>[user] sprays [target] with fire!</span>", "<span class='danger'><b>BURN BABY BURN!!</b></span>")
			var/mob/living/simple_animal/hostile/poison/giant_spider/GCS = target
			GCS.adjustHealth(30)
			uses--
		else if(iscarbon(target))
			playsound(user, 'yogstation/sound/effects/burning.wav', 50)
			var/mob/living/carbon/C = target
			user.visible_message("<span class='danger'>[user] sprays [C] with fire!</span>", "<span class='danger'><b>BURN BABY BURN!!</b></span>")
			to_chat(target, "<span class='userdanger'>[user] sprays you with fire!</span>")
			C.adjust_fire_stacks(0.2)
			C.IgniteMob()
			uses--
		return

	if(ishuman(target))
		if(target == user)
			attack_self(user)
			return
		playsound(user, 'sound/effects/spray.ogg', 50)
		var/mob/living/carbon/human/H = target
		H.adjust_hygiene(HYGIENE_LEVEL_CLEAN * 0.5)
		user.visible_message("<span class='notice'>[user] sprays [H] with [src].</span>", "<span class='notice'>You spray [H] with [src]. Sheesh, how hard is it to take a shower?</span>")
		uses--

/obj/item/deodorant/suicide_act(mob/user)
	switch(rand(1,3))
		if(1)
			user.visible_message("<span class='danger'>[user] smells [src] in [user.p_their()] hand.</span>", "<span class='userdanger'>You smell the cap. It reminds you of the locker room after gym class.</span>")
			sleep(30)
			return OXYLOSS
		if(2)
			user.visible_message("<span class='danger'>[user] is huffing [src], it looks like [user.p_theyre()] trying to commit suicide!")
			return OXYLOSS
		if(3)
			user.visible_message("<span class='danger'>[user] is rapidly shaking [src], it looks like [user.p_theyre()] trying to commit suicide!")
			sleep(15)
			playsound(user, 'sound/effects/explosion3.ogg', 50)
			qdel(src)
			return BRUTELOSS