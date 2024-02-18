/obj/item/poster/random_abductor
	name = "random abductor poster"
	poster_type = /obj/structure/sign/poster/abductor/random
	icon = 'icons/obj/contraband.dmi'
	icon_state = "rolled_abductor"

/obj/structure/sign/poster/abductor
	icon = 'icons/obj/abductor_posters.dmi'
	poster_item_name = "abductor poster"
	poster_item_desc = "A large piece of space-resistant printed paper."
	poster_item_icon_state = "rolled_abductor"

/obj/structure/sign/poster/abductor/attack_hand(mob/user)
	if(!isabductor(user))
		to_chat(user, span_notice("It won't budge!"))
		return
	return ..()

/obj/structure/sign/poster/abductor/random
	name = "random abductor poster"
	icon_state = "random_abductor"
	never_random = TRUE
	random_basetype = /obj/structure/sign/poster/abductor

/obj/structure/sign/poster/abductor/random
	name = "random abductor poster"
	icon_state = "random_abductor"
	never_random = TRUE
	random_basetype = /obj/structure/sign/poster/abductor

/obj/structure/sign/poster/abductor/ayylian
	name = "Ayylian"
	desc = "Man, Ian sure is looking strange these days."
	icon_state = "ayylian"

/obj/structure/sign/poster/abductor/ayy
	name = "Abductor"
	desc = "Hey, that's not a lizard!"
	icon_state = "ayy"

/obj/structure/sign/poster/abductor/ayy_over_tizira
	name = "Abductors Over Tizira"
	desc = "A poster for an experimental adaptation of a movie about the Human-Lizard war. Production was greatly hindered by the leading pair's refusal to speak any lines."
	icon_state = "ayy_over_tizira"

/obj/structure/sign/poster/abductor/ayy_recruitment
	name = "Abductor Recruitment"
	desc = "Enlist in the Mothership Probing Division today!"
	icon_state = "ayy_recruitment"

/obj/structure/sign/poster/abductor/ayy_cops
	name = "Abductor Cops"
	desc = "A poster advertising the polarizing 'Abductor Cops' series. Some critics claimed that it stunned them, while others said it put them to sleep."
	icon_state = "ayyce_cops"

/obj/structure/sign/poster/abductor/ayy_no
	name = "Uayy No"
	desc = "This thing is all in Japanese, AND they got rid of the anime girl on the poster. Outrageous."
	icon_state = "ayy_no"

/obj/structure/sign/poster/abductor/ayy_piping
	name = "Safety Abductor - Piping"
	desc = "Safety Abductor has nothing to say. Not because it cannot speak, but because Abductors don't have to deal with atmos stuff."
	icon_state = "ayy_piping"

/obj/structure/sign/poster/abductor/ayy_fancy
	name = "Abductor Fancy"
	desc = "Abductors are the best at doing everything. That includes looking good!"
	icon_state = "ayy_fancy"