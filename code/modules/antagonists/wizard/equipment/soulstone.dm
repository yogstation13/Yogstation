/obj/item/soulstone
	name = "soulstone shard"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "soulstone"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	layer = HIGH_OBJ_LAYER
	desc = "A fragment of the legendary treasure known simply as the 'Soul Stone'. The shard still flickers with a fraction of the full artefact's power."
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_BELT
	var/usability = FALSE

	var/old_shard = FALSE
	var/spent = FALSE
	var/purified = FALSE

/obj/item/soulstone/proc/was_used()
	if(old_shard)
		spent = TRUE
		name = "dull [name]"
		desc = "A fragment of the legendary treasure known simply as \
			the 'Soul Stone'. The shard lies still, dull and lifeless; \
			whatever spark it once held long extinguished."

/obj/item/soulstone/anybody
	usability = TRUE

/obj/item/soulstone/anybody/purified
	icon = 'icons/obj/wizard.dmi'
	icon_state = "purified_soulstone"
	purified = TRUE


/obj/item/soulstone/anybody/chaplain
	name = "mysterious old shard"
	old_shard = TRUE

/obj/item/soulstone/pickup(mob/living/user)
	..()
	if(!iscultist(user) && !IS_WIZARD(user) && !usability)
		to_chat(user, span_danger("An overwhelming feeling of dread comes over you as you pick up the soulstone. It would be wise to be rid of this quickly."))

/obj/item/soulstone/examine(mob/user)
	. = ..()
	if(usability || iscultist(user) || IS_WIZARD(user) || isobserver(user))
		if (old_shard)
			. += span_cult("A soulstone, used to capture a soul, either from dead humans or from freed shades.")
		else
			. += span_cult("A soulstone, used to capture souls, either from unconscious or sleeping humans or from freed shades.")
		. += span_cult("The captured soul can be placed into a construct shell to produce a construct, or released from the stone as a shade.")
		if(spent)
			. += span_cult("This shard is spent; it is now just a creepy rock.")

/obj/item/soulstone/Destroy() //Stops the shade from being qdel'd immediately and their ghost being sent back to the arrival shuttle.
	for(var/mob/living/simple_animal/shade/A in src)
		A.death()
	return ..()

//////////////////////////////Capturing////////////////////////////////////////////////////////

/obj/item/soulstone/attack(mob/living/carbon/human/M, mob/living/user)
	if(!iscultist(user) && !IS_WIZARD(user) && !usability)
		user.Unconscious(10 SECONDS)
		to_chat(user, span_userdanger("Your body is wracked with debilitating pain!"))
		return
	if(spent)
		to_chat(user, span_warning("There is no power left in the shard."))
		return
	if(!ishuman(M))//If target is not a human.
		return ..()
	if(iscultist(M) && iscultist(user))
		to_chat(user, span_cultlarge("\"Come now, do not capture your bretheren's soul.\""))
		return
	if(purified && iscultist(user))
		to_chat(user, span_warning("Holy magic resides within the stone, you cannot use it."))
		return
	/*if(theme == THEME_HOLY && IS_CULTIST(user))
		hot_potato(user)
		return*/
	if(HAS_TRAIT(M, TRAIT_NO_SOUL))
		to_chat(user, span_warning("This body does not possess a soul to capture."))
		return
	log_combat(user, M, "captured [M.name]'s soul", src)
	transfer_soul("VICTIM", M, user)

///////////////////Options for using captured souls///////////////////////////////////////

/obj/item/soulstone/attack_self(mob/living/user)
	if(!in_range(src, user))
		return
	if(!iscultist(user) && !IS_WIZARD(user) && !usability)
		user.Unconscious(100)
		to_chat(user, span_userdanger("Your body is wracked with debilitating pain!"))
		return
	if(purified && iscultist(user))
		to_chat(user, span_warning("Holy magic resides within the stone, you cannot use it."))
		return
	release_shades(user)

/obj/item/soulstone/proc/release_shades(mob/user)
	for(var/mob/living/simple_animal/shade/A in src)
		A.status_flags &= ~GODMODE
		A.mobility_flags = MOBILITY_FLAGS_DEFAULT
		A.forceMove(get_turf(user))
		A.cancel_camera()
		if(purified)
			icon_state = "purified_soulstone"
		else
			icon_state = "soulstone"
		name = initial(name)
		if(IS_WIZARD(user) || usability)
			to_chat(A, "<b>You have been released from your prison, but you are still bound to [user.real_name]'s will. Help [user.p_them()] succeed in [user.p_their()] goals at all costs.</b>")
		else if(iscultist(user))
			to_chat(A, "<b>You have been released from your prison, but you are still bound to the cult's will. Help them succeed in their goals at all costs.</b>")
		was_used()

///////////////////////////Transferring to constructs/////////////////////////////////////////////////////
/obj/structure/constructshell
	name = "empty shell"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct-cult"
	desc = "A wicked machine used by those skilled in magical arts. It is inactive."

/obj/structure/constructshell/examine(mob/user)
	. = ..()
	if(iscultist(user) || IS_WIZARD(user) || user.stat == DEAD)
		. += {"<span class='cult'>A construct shell, used to house bound souls from a soulstone.\n
		Placing a soulstone with a soul into this shell allows you to produce your choice of the following:\n
		An <b>Artificer</b>, which can produce <b>more shells and soulstones</b>, as well as fortifications.\n
		A <b>Wraith</b>, which does high damage and can jaunt through walls, though it is quite fragile.\n
		A <b>Juggernaut</b>, which is very hard to kill and can produce temporary walls, but is slow.</span>"}

/obj/structure/constructshell/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/soulstone))
		var/obj/item/soulstone/SS = O
		if(!iscultist(user) && !IS_WIZARD(user) && !SS.purified)
			to_chat(user, span_danger("An overwhelming feeling of dread comes over you as you attempt to place the soulstone into the shell. It would be wise to be rid of this quickly."))
			if(isliving(user))
				var/mob/living/living_user = user
				living_user.set_dizzy_if_lower(1 MINUTES)
		if(SS.purified && iscultist(user))
			to_chat(user, span_warning("Holy magic resides within the stone, you cannot use it."))
			return
		SS.transfer_soul("CONSTRUCT",src,user)
		SS.was_used()
	else
		return ..()

////////////////////////////Proc for moving soul in and out off stone//////////////////////////////////////


/obj/item/soulstone/proc/transfer_soul(choice as text, target, mob/user)
	switch(choice)
		if("FORCE")
			if(!iscarbon(target))		//TODO: Add sacrifice stoning for non-organics, just because you have no body doesnt mean you dont have a soul
				return FALSE
			if(contents.len)
				return FALSE
			var/mob/living/carbon/T = target
			if(T.client != null && T.key != null)
				for(var/obj/item/W in T)
					T.dropItemToGround(W)
				init_shade(T, user)
				return TRUE
			else
				to_chat(user, "[span_userdanger("Capture failed!")]: The soul has already fled its mortal frame. You attempt to bring it back...")
				return getCultGhost(T,user)

		if("VICTIM")
			var/mob/living/carbon/human/T = target
			var/datum/antagonist/cult/C = user.mind.has_antag_datum(/datum/antagonist/cult,TRUE)
			if(C && C.cult_team.is_sacrifice_target(T.mind))
				if(iscultist(user))
					to_chat(user, "<span class='cult'><b>\"This soul is mine.</b></span> [span_cultlarge("SACRIFICE THEM!\"")]")
				else
					to_chat(user, span_danger("The soulstone seems to reject this soul."))
				return FALSE
			if(contents.len)
				to_chat(user, "[span_userdanger("Capture failed!")]: The soulstone is full! Free an existing soul to make room.")
			else
				if((!old_shard && T.stat != CONSCIOUS) || (old_shard && T.stat == DEAD))
					if(T.client == null)
						to_chat(user, "[span_userdanger("Capture failed!")]: The soul has already fled its mortal frame. You attempt to bring it back...")
						getCultGhost(T,user)
					else
						for(var/obj/item/W in T)
							T.dropItemToGround(W)
						init_shade(T, user, vic = 1)
						qdel(T)
				else
					to_chat(user, "[span_userdanger("Capture failed!")]: Kill or maim the victim first!")

		if("SHADE")
			var/mob/living/simple_animal/shade/T = target
			if(contents.len)
				to_chat(user, "[span_userdanger("Capture failed!")]: The soulstone is full! Free an existing soul to make room.")
			else
				T.forceMove(src) //put shade in stone
				T.status_flags |= GODMODE
				T.mobility_flags = NONE
				T.health = T.maxHealth
				if(purified)
					icon_state = "purified_soulstone2"
				else
					icon_state = "soulstone2"
				name = "soulstone: Shade of [T.real_name]"
				to_chat(T, span_notice("Your soul has been captured by the soulstone. Its arcane energies are reknitting your ethereal form."))
				if(user != T)
					to_chat(user, "<span class='info'><b>Capture successful!</b>:</span> [T.real_name]'s soul has been captured and stored within the soulstone.")

		if("CONSTRUCT")
			var/obj/structure/constructshell/T = target
			var/mob/living/simple_animal/shade/A = locate() in src
			if(A)
				var/construct_class = alert(user, "Please choose which type of construct you wish to create.",,"Juggernaut","Wraith","Artificer")
				if(!T || !T.loc)
					return
				switch(construct_class)
					if("Juggernaut")
						if(iscultist(user) || IS_WIZARD(user))
							makeNewConstruct(/mob/living/simple_animal/hostile/construct/armored, A, user, 0, T.loc)
						else
							if(purified)
								makeNewConstruct(/mob/living/simple_animal/hostile/construct/armored/angelic, A, user, 0, T.loc)
							else
								makeNewConstruct(/mob/living/simple_animal/hostile/construct/armored/noncult, A, user, 0, T.loc)
					if("Wraith")
						if(iscultist(user) || IS_WIZARD(user))
							makeNewConstruct(/mob/living/simple_animal/hostile/construct/wraith, A, user, 0, T.loc)
						else
							if(purified)
								makeNewConstruct(/mob/living/simple_animal/hostile/construct/wraith/angelic, A, user, 0, T.loc)
							else
								makeNewConstruct(/mob/living/simple_animal/hostile/construct/wraith/noncult, A, user, 0, T.loc)
					if("Artificer")
						if(iscultist(user) || IS_WIZARD(user))
							makeNewConstruct(/mob/living/simple_animal/hostile/construct/builder, A, user, 0, T.loc)
						else
							if(purified)
								makeNewConstruct(/mob/living/simple_animal/hostile/construct/builder/angelic, A, user, 0, T.loc)
							else
								makeNewConstruct(/mob/living/simple_animal/hostile/construct/builder/noncult, A, user, 0, T.loc)
				for(var/datum/mind/B in SSgamemode.cult)
					if(B == A.mind)
						SSgamemode.cult -= A.mind
				qdel(T)
				qdel(src)
			else
				to_chat(user, "[span_userdanger("Creation failed!")]: The soul stone is empty! Go kill someone!")


/proc/makeNewConstruct(mob/living/simple_animal/hostile/construct/ctype, mob/target, mob/stoner = null, cultoverride = 0, loc_override = null)
	if(QDELETED(target))
		return
	var/mob/living/simple_animal/hostile/construct/newstruct = new ctype((loc_override) ? (loc_override) : (get_turf(target)))
	if(stoner)
		newstruct.faction |= "[REF(stoner)]"
		newstruct.master = stoner
		var/datum/action/innate/seek_master/SM = new()
		SM.Grant(newstruct)
	if(isliving(target))
		target.mind.transfer_to(newstruct)
	else
		newstruct.key = target.key
	var/atom/movable/screen/alert/bloodsense/BS
	if(newstruct.mind && ((stoner && iscultist(stoner)) || cultoverride))
		newstruct.add_cultist()
	if(iscultist(stoner) || cultoverride)
		to_chat(newstruct, "<b>You are still bound to serve the cult[stoner ? " and [stoner]":""], follow [stoner ? stoner.p_their() : "their"] orders and help [stoner ? stoner.p_them() : "them"] complete [stoner ? stoner.p_their() : "their"] goals at all costs.</b>")
	else if(stoner)
		to_chat(newstruct, "<b>You are still bound to serve your creator, [stoner], follow [stoner.p_their()] orders and help [stoner.p_them()] complete [stoner.p_their()] goals at all costs.</b>")
	newstruct.clear_alert("bloodsense")
	BS = newstruct.throw_alert("bloodsense", /atom/movable/screen/alert/bloodsense)
	if(BS)
		BS.Cviewer = newstruct
	newstruct.cancel_camera()


/obj/item/soulstone/proc/init_shade(mob/living/carbon/human/T, mob/U, vic = 0)
	new /obj/effect/decal/remains/human(T.loc) //Spawns a skeleton
	T.stop_sound_channel(CHANNEL_HEARTBEAT)
	T.invisibility = INVISIBILITY_ABSTRACT
	T.dust_animation()
	var/mob/living/simple_animal/shade/S = new /mob/living/simple_animal/shade(src)
	S.status_flags |= GODMODE //So they won't die inside the stone somehow
	S.mobility_flags = NONE //Can't move out of the soul stone
	S.name = "Shade of [T.real_name]"
	S.real_name = "Shade of [T.real_name]"
	T.mind.transfer_to(S)
	S.copy_languages(T, LANGUAGE_MIND)//Copies the old mobs languages into the new mob holder.
	S.copy_languages(U, LANGUAGE_MASTER)
	S.update_atom_languages()
	grant_all_languages(FALSE, FALSE, TRUE)	//Grants omnitongue
	if(U)
		S.faction |= "[REF(U)]" //Add the master as a faction, allowing inter-mob cooperation
	if(U && iscultist(U))
		S.add_cultist()
	S.cancel_camera()
	name = "soulstone: Shade of [T.real_name]"
	if(purified)
		icon_state = "purified_soulstone2"
	else
		icon_state = "soulstone2"
	if(U && (IS_WIZARD(U) || usability))
		to_chat(S, "Your soul has been captured! You are now bound to [U.real_name]'s will. Help [U.p_them()] succeed in [U.p_their()] goals at all costs.")
	else if(U && iscultist(U))
		to_chat(S, "Your soul has been captured! You are now bound to the cult's will. Help them succeed in their goals at all costs.")
	if(vic && U)
		to_chat(U, "<span class='info'><b>Capture successful!</b>:</span> [T.real_name]'s soul has been ripped from [T.p_their()] body and stored within the soul stone.")


/obj/item/soulstone/proc/getCultGhost(mob/living/carbon/human/T, mob/U)
	var/mob/dead/observer/chosen_ghost

	for(var/mob/dead/observer/ghost in GLOB.player_list) //We put them back in their body
		if(ghost.mind && ghost.mind.current == T && ghost.client)
			chosen_ghost = ghost
			break

	if(!chosen_ghost)	//Failing that, we grab a ghost
		var/list/consenting_candidates = pollGhostCandidates("Would you like to play as a Shade?", "Cultist", null, ROLE_CULTIST, 150, POLL_IGNORE_SHADE)
		if(consenting_candidates.len)
			chosen_ghost = pick(consenting_candidates)
	if(!T)
		return FALSE
	if(!chosen_ghost)
		to_chat(U, span_danger("There were no spirits willing to become a shade."))
		return FALSE
	if(contents.len) //If they used the soulstone on someone else in the meantime
		return FALSE
	T.ghostize() // yogs - if they disconnected, they ghost now.
	T.ckey = chosen_ghost.ckey
	for(var/obj/item/W in T)
		T.dropItemToGround(W)
	init_shade(T, U)
	qdel(T)
	return TRUE
