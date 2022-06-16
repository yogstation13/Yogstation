/obj/structure/hog_structure/fountain
	name = "Fountain"
	desc = "A fountain, containing some magical reagents in it."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "lance"
	icon_originalname = "lance"
	max_integrity = 50
	cost = 175
	time_builded = 10 SECONDS
    var/max_reagents = 30
    var/reagents_amount = 0
    var/production_amount = 5
    var/production_cooldown = 35 SECONDS
    var/last_time_produced
    var/datum/reagent/reagent_type 

/obj/structure/hog_structure/fountain/Initialize()
	. = ..()
    reagents_amount = max_reagents/2
    last_time_produced = world.time
	START_PROCESSING(SSfastprocess, src)

/obj/structure/hog_structure/fountain/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
    . = ..()

/obj/structure/hog_structure/fountain/process()
    if(last_time_produced + production_cooldown < world.time && reagents_amount < max_reagents)
        reagents_amount += production_amount
        last_time_produced = world.time
        if(reagents_amount < 0)
            reagents_amount = 0
        if(reagents_amount > max_reagents)
            reagents_amount = max_reagents
        
        

/obj/structure/hog_structure/fountain/special_interaction(mob/user)
    var/mob/living/carbon/C = user
    if(!user)
        return
    if(C.reagents)
        C.reagents.add_reagent(/datum/reagent/reagent_type, 5)
        user.visible_message(span_warning("[C] drinks from [src]!"),span_notice("You drink from [src]."))



/*
	Godblood - it, well... heals servants, deconverts cultists from other cults(including bloodcult and cockcult) and damages all other dudes.
*/

/datum/reagent/fuel/godblood	
	name = "Godblood"
	description = "Something that shouldn't exist on this plane of existence."
	taste_description = "sublimity"
    var/cultcolor = "black"
    var/datum/reagent/deconverter = /datum/reagent/deconverter


/datum/reagent/fuel/godblood/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		M.reagents.add_reagent(type,reac_volume/4)
		return
	return ..()

/datum/reagent/fuel/godblood/on_mob_life(mob/living/carbon/M)
    var/datum/antagonist/hog/hoggers = IS_HOG_CULTIST(M)
	if(hoggers)
        if(hoggers.cult.cult_color = src.cultcolor)
            M.drowsyness = max(M.drowsyness-5, 0)
            M.AdjustAllImmobility(-40, FALSE)
            M.adjustStaminaLoss(-10, 0)
            M.adjustToxLoss(-2, 0)
            M.adjustOxyLoss(-2, 0)
            M.adjustBruteLoss(-2, 0)
            M.adjustFireLoss(-2, 0)
            holder.remove_reagent(/datum/reagent/deconverter, rand(2,3)) ///Some rng, E
            holder.remove_reagent(/datum/reagent/water/holywater, rand(2,3))
            if(ishuman(M) && M.blood_volume < BLOOD_VOLUME_NORMAL(M))
                M.blood_volume += 3
        else
            M.adjustStaminaLoss(10, 0)
            M.adjustOxyLoss(2, 0)
            M.add_reagent(deconverter, 2)
	else  // Will deal about 90 damage when 50 units are thrown
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3, 150)
		M.adjustToxLoss(2, 0)
		M.adjustFireLoss(2, 0)
		M.adjustOxyLoss(2, 0)
		M.adjustBruteLoss(2, 0)
	holder.remove_reagent(type, 1)
	return TRUE

/*
	It is just a strange deconverter liquid.
*/

/datum/reagent/deconverter
	name = "Religion smasher"
	description = "A liquid, that magicaly makes religious zealots feel not very cool."
	color = "#E0E8EF"
	glass_icon_state  = "glass_clear"
	self_consuming = TRUE 

/datum/reagent/deconverter/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(is_servant_of_ratvar(M))
		to_chat(M, span_userdanger("A darkness begins to spread its unholy tendrils through your mind, purging the Justiciar's influence!"))
	..()

/datum/reagent/deconverter/on_mob_life(mob/living/carbon/M)
	if(!data)
		data = list("misc" = 1)
	data["misc"]++
	M.jitteriness = min(M.jitteriness+4,10)
	if(iscultist(M))
        var/list/delete_candidates = list() 
		for(var/datum/action/innate/cult/blood_magic/BM in M.actions)
			to_chat(M, span_cultlarge("Your blood rites falter as holy water scours your body!"))
			for(var/datum/action/innate/cult/blood_spell/BS in BM.spells)
				delete_candidates += BS
        qdel(pick(delete_candidates))
	if(data["misc"] >= 25)		// 10 units, 45 seconds @ metabolism 0.4 units & tick rate 1.8 sec
		if(!M.stuttering)
			M.stuttering = 1
		M.stuttering = min(M.stuttering+4, 10)
		M.Dizzy(5)
		if(iscultist(M) && prob(20))
			M.say(pick("Av'te Nar'Sie","Pa'lid Mors","INO INO ORA ANA","SAT ANA!","Daim'niodeis Arc'iai Le'eones","R'ge Na'sie","Diabo us Vo'iscum","Eld' Mon Nobis"), forced = "holy water")
			if(prob(10))
				M.visible_message(span_danger("[M] starts having a seizure!"), span_userdanger("You have a seizure!"))
				M.Unconscious(120)
				to_chat(M, "<span class='cultlarge'>[pick("Your blood is your bond - you are nothing without it", "Do not forget your place", \
				"All that power, and you still fail?", "If you cannot scour this poison, I shall scour your meager life!")].</span>")
		else if(is_servant_of_ratvar(M) && prob(8))
			switch(pick("speech", "message", "emote"))
				if("speech")
					clockwork_say(M, "...[text2ratvar(pick("Engine... your light grows dark...", "Where are you, master?", "He lies rusting in Error...", "Purge all untruths and... and... something..."))]")
				if("message")
					to_chat(M, "<span class='boldwarning'>[pick("Ratvar's illumination of your mind has begun to flicker", "He lies rusting in Reebe, derelict and forgotten. And there he shall stay", \
					"You can't save him. Nothing can save him now", "It seems that Nar-Sie will triumph after all")].</span>")
				if("emote")
					M.visible_message(span_warning("[M] [pick("whimpers quietly", "shivers as though cold", "glances around in paranoia")]."))
        else if(IS_HOG_CULTIST(M) && prob(8))
				M.visible_message(span_warning("[M] [pick("whimpers quietly", "shivers as though cold", "glances around in paranoia")].")) ///Im not very creative with this
	if(data["misc"] >= 60)	// 30 units, 135 seconds
		if(iscultist(M) || is_servant_of_ratvar(M))
			if(iscultist(M))
				SSticker.mode.remove_cultist(M.mind, FALSE, TRUE)
			else if(is_servant_of_ratvar(M))
				remove_servant_of_ratvar(M)
            else if(IS_HOG_CULTIST(M))
                M.mind.remove_antag_datum(/datum/antagonist/hog)
			M.jitteriness = 0
			M.stuttering = 0
			holder.remove_reagent(type, volume)	
			return
	holder.remove_reagent(type, 0.6)	

