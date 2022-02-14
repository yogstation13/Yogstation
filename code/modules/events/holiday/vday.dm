// Valentine's Day events //
// why are you playing spessmens on valentine's day you wizard //

#define VALENTINE_FILE "valentines.json"

// valentine / candy heart distribution //

/datum/round_event_control/valentines
	name = "Valentines!"
	holidayID = VALENTINES
	typepath = /datum/round_event/valentines
	weight = -1							//forces it to be called, regardless of weight
	max_occurrences = 1
	earliest_start = 0 MINUTES

/datum/round_event/valentines/start()
	..()
	var/list/mob/living/carbon/human/removed = list()
	for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
		H.put_in_hands(new /obj/item/valentine)
		var/obj/item/storage/backpack/b = locate() in H.contents
		new /obj/item/reagent_containers/food/snacks/candyheart(b)
		new /obj/item/storage/box/fancy/heart_box(b)

	var/list/valentines = list()
	for(var/mob/living/M in GLOB.player_list)
		if(!M.stat && M.client && M.mind)
			if(M.client.prefs.valentines == FALSE)
				removed.Add(M)
				continue
			valentines |= M

	while(valentines.len)
		var/mob/living/L = pick_n_take(valentines)
		if(valentines.len)
			var/mob/living/date = pick_n_take(valentines)


			forge_valentines_objective(L, date)
			forge_valentines_objective(date, L)

			if(valentines.len && prob(4))
				var/mob/living/notgoodenough = pick_n_take(valentines)
				forge_valentines_objective(notgoodenough, date)
	
	spawn(1)
		priority_announce("Opting out [removed.len] employees from the Nanotrasen valentines program. Opt out laser charging...", "Opt out")
		sound_to_playing_players('sound/magic/lightning_chargeup.ogg')
		sleep(10 SECONDS)
		sound_to_playing_players('sound/magic/lightningbolt.ogg')

		for(var/mob/living/grinch in removed)
			spawn(0)
				for(var/i = 1 to 6)
					var/obj/effect/temp_visual/solarbeam_killsat/K = new (get_turf(grinch))
					var/matrix/final = matrix()
					final.Scale(1,32)
					final.Translate(0,512)
					K.transform = final
					grinch.notransform = TRUE
					grinch.adjustBruteLoss(10, TRUE, TRUE)
					grinch.adjustFireLoss(10, TRUE, TRUE)
					grinch.adjustOxyLoss(10, TRUE, TRUE)
					grinch.adjustToxLoss(10, TRUE, TRUE)
					grinch.adjust_drugginess(10)
					grinch.adjust_blurriness(10)
					grinch.adjust_disgust(10)
					grinch.adjust_fire_stacks(10)
					grinch.IgniteMob()
					grinch.AdjustParalyzed(10, TRUE, TRUE)
					grinch.regenerate_icons()
					sleep(1 SECONDS)
				grinch.gib(TRUE, FALSE, FALSE)
				sleep(3 SECONDS)
				qdel(grinch)

/proc/forge_valentines_objective(mob/living/lover,mob/living/date)
	lover.mind.special_role = "valentine"
	var/datum/antagonist/valentine/V = new
	V.date = date.mind
	lover.mind.add_antag_datum(V) //These really should be teams but i can't be assed to incorporate third wheels right now

/datum/round_event/valentines/announce(fake)
	priority_announce("It's Valentine's Day! Give a valentine to that special someone!")

/obj/item/valentine
	name = "valentine"
	desc = "A Valentine's card! Wonder what it says..."
	icon = 'icons/obj/toy.dmi'
	icon_state = "sc_Ace of Hearts_syndicate" // shut up
	var/message = "A generic message of love or whatever."
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_TINY

/obj/item/valentine/Initialize()
	. = ..()
	message = pick(strings(VALENTINE_FILE, "valentines"))

/obj/item/valentine/attackby(obj/item/W, mob/user, params)
	..()
	if(istype(W, /obj/item/pen) || istype(W, /obj/item/toy/crayon))
		if(!user.is_literate())
			to_chat(user, span_notice("You scribble illegibly on [src]!"))
			return
		var/recipient = stripped_input(user, "Who is receiving this valentine?", "To:", null , 20)
		var/sender = stripped_input(user, "Who is sending this valentine?", "From:", null , 20)
		if(!user.canUseTopic(src, BE_CLOSE))
			return
		if(recipient && sender)
			name = "valentine - To: [recipient] From: [sender]"

/obj/item/valentine/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		if( !(ishuman(user) || isobserver(user) || issilicon(user)) )
			user << browse("<HTML><HEAD><meta charset='UTF-8'><TITLE>[name]</TITLE></HEAD><BODY>[stars(message)]</BODY></HTML>", "window=[name]")
			onclose(user, "[name]")
		else
			user << browse("<HTML><HEAD><meta charset='UTF-8'><TITLE>[name]</TITLE></HEAD><BODY>[message]</BODY></HTML>", "window=[name]")
			onclose(user, "[name]")
	else
		. += span_notice("It is too far away.")

/obj/item/valentine/attack_self(mob/user)
	user.examinate(src)

/obj/item/reagent_containers/food/snacks/candyheart
	name = "candy heart"
	icon = 'icons/obj/holiday_misc.dmi'
	icon_state = "candyheart"
	desc = "A heart-shaped candy that reads: "
	list_reagents = list(/datum/reagent/consumable/sugar = 2)
	junkiness = 5

/obj/item/reagent_containers/food/snacks/candyheart/Initialize()
	. = ..()
	desc = pick(strings(VALENTINE_FILE, "candyhearts"))
	icon_state = pick("candyheart", "candyheart2", "candyheart3", "candyheart4")
