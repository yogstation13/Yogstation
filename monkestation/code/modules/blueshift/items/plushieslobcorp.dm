// //Lobotomy Corportion 13 Plushies
/obj/item/toy/plush/lobotomy
	icon = 'monkestation/code/modules/blueshift/icons/plusheslobcorp.dmi'
	inhand_icon_state = null

// The good guys
/obj/item/toy/plush/lobotomy/ayin
	name = "ayin plushie"
	desc = "A plushie depicting a researcher that did <b>nothing wrong</b>."
	icon_state = "ayin"
	gender = MALE

/obj/item/toy/plush/lobotomy/benjamin
	name = "benjamin plushie"
	desc = "A plushie depicting a researcher that resembles Hokma a bit too much."
	icon_state = "benjamin"
	gender = MALE

/obj/item/toy/plush/lobotomy/carmen
	name = "carmen plushie"
	desc = "A plushie depicting an ambitious and altruistic researcher."
	icon_state = "carmen"
	gender = FEMALE

// Sephirots
/obj/item/toy/plush/lobotomy/malkuth
	name = "malkuth plushie"
	desc = "A plushie depicting a diligent worker."
	icon_state = "malkuth"
	gender = FEMALE

/obj/item/toy/plush/lobotomy/yesod
	name = "yesod plushie"
	desc = "A plushie depicting a researcher in a turtleneck."
	icon_state = "yesod"
	gender = MALE

/obj/item/toy/plush/lobotomy/netzach
	name = "netzach plushie"
	desc = "A plushie depicting a person that likes alcohol a bit too much."
	icon_state = "netzach"
	gender = MALE

/obj/item/toy/plush/lobotomy/hod
	name = "hod plushie"
	desc = "A plushie depicting a person who hopes to make everything right."
	icon_state = "hod"
	gender = FEMALE

/obj/item/toy/plush/lobotomy/lisa
	name = "tiphereth-A plushie"
	desc = "A plushie depicting a person with high expectations."
	icon_state = "lisa"
	gender = FEMALE

/obj/item/toy/plush/lobotomy/enoch
	name = "tiphereth-B plushie"
	desc = "A plushie depicting an optimistic person with kind heart."
	icon_state = "enoch"
	gender = MALE

/obj/item/toy/plush/lobotomy/chesed
	name = "chesed plushie"
	desc = "A plushie depicting a sleepy person with a mug of coffee in their hand."
	icon_state = "chesed"
	gender = MALE

/obj/item/toy/plush/lobotomy/gebura
	name = "gebura plushie"
	desc = "A plushie depicting avery strong and brave person."
	icon_state = "gebura"
	gender = FEMALE

/obj/item/toy/plush/lobotomy/hokma
	name = "hokma plushie"
	desc = "A plushie depicting a wise person with a fancy monocle. He knows the secrets behind his company."
	icon_state = "hokma"
	gender = MALE

/obj/item/toy/plush/lobotomy/binah
	name = "binah plushie"
	desc = "A plushie depicting a sadistic person who lacks any emotions."
	icon_state = "binah"
	gender = FEMALE

/obj/item/toy/plush/lobotomy/angela
	name = "angela plushie"
	desc = "A plushie depicting a highly advanced AI with ulterior motives."
	icon_state = "angela"
	gender = FEMALE

	//Limbus Sinners
/obj/item/toy/plush/lobotomy/yisang
	name = "yi sang plushie"
	desc = "A plushie depicting a ruminating Sinner."
	icon_state = "yisang"
	attack_verb_continuous = list("shanks", "stabs")
	attack_verb_simple = list("shank", "stab")
	gender = MALE

/obj/item/toy/plush/lobotomy/faust
	name = "faust plushie"
	desc = "A plushie depicting an insufferable Sinner."
	icon_state = "faust"
	attack_verb_continuous = list("slices", "cleaves")
	attack_verb_simple = list("slice", "cleave")
	gender = FEMALE

/obj/item/toy/plush/lobotomy/don
	name = "don quixote plushie"
	desc = "A plushie depicting a heroic Sinner."
	icon_state = "don"
	attack_verb_continuous = list("impales", "jousts")
	attack_verb_simple = list("impale", "joust")
	gender = FEMALE

/obj/item/toy/plush/lobotomy/don/attack(mob/living/target, mob/living/user, params)
	. = ..()
	flick("don_yahoo", src)

/obj/item/toy/plush/lobotomy/ryoshu
	name = "ryoshu plushie"
	desc = "A plushie depicting a artistic Sinner."
	icon_state = "ryoshu"
	attack_verb_continuous = list("slices", "cleaves")
	attack_verb_simple = list("slice", "cleave")
	gender = FEMALE

/obj/item/toy/plush/lobotomy/meursault
	name = "meursault plushie"
	desc = "A plushie depicting a neutral Sinner."
	icon_state = "meursault"
	attack_verb_continuous = list("bashes", "slams", "bludgeons")
	attack_verb_simple = list("bash", "slam", "bludgeon")
	gender = MALE

/obj/item/toy/plush/lobotomy/honglu
	name = "hong lu plushie"
	desc = "A plushie depicting a sheltered Sinner."
	icon_state = "honglu"
	attack_verb_continuous = list("slices", "cleaves")
	attack_verb_simple = list("slice", "cleave")
	gender = MALE

/obj/item/toy/plush/lobotomy/heathcliff
	name = "heathcliff plushie"
	desc = "A plushie depicting a brash Sinner."
	icon_state = "heathcliff"
	attack_verb_continuous = list("bashes", "slams", "bludgeons")
	attack_verb_simple = list("bash", "slam", "bludgeon")
	gender = MALE

/obj/item/toy/plush/lobotomy/ishmael
	name = "ishmael plushie"
	desc = "A plushie depicting a reliable Sinner."
	icon_state = "ishmael"
	attack_verb_continuous = list("bashes", "slams", "bludgeons")
	attack_verb_simple = list("bash", "slam", "bludgeon")
	gender = FEMALE

/obj/item/toy/plush/lobotomy/rodion
	name = "rodion plushie"
	desc = "A plushie depicting a Sinner born in the Backstreets."
	icon_state = "rodion"
	attack_verb_continuous = list("slices", "cleaves")
	attack_verb_simple = list("slice", "cleave")
	gender = FEMALE

/obj/item/toy/plush/lobotomy/sinclair
	name = "sinclair plushie"
	desc = "A plushie depicting a insecure Sinner."
	icon_state = "sinclair"
	attack_verb_continuous = list("slices", "cleaves")
	attack_verb_simple = list("slice", "cleave")
	gender = MALE

/obj/item/toy/plush/lobotomy/dante
	name = "dante plushie"
	desc = "A plushie depicting a clock-headed manager struggling to wrangle the Sinners."
	icon_state = "dante"
	gender = MALE

/obj/item/toy/plush/lobotomy/outis
	name = "outis plushie"
	desc = "A plushie depicting a strategic Sinner."
	icon_state = "outis"
	attack_verb_continuous = list("shanks", "stabs")
	attack_verb_simple = list("shank", "stab")
	gender = FEMALE

/obj/item/toy/plush/lobotomy/gregor
	name = "gregot plushie"
	desc = "A plushie depicting a genetically altered Sinner that resembles a bug."
	icon_state = "gregor"
	attack_verb_continuous = list("shanks", "stabs")
	attack_verb_simple = list("shank", "stab")
	gender = MALE

// Misc LC13 stuff
/obj/item/toy/plush/lobotomy/pierre
	name = "pierre plushie"
	desc = "A plushie depicting a friendly cook looking for simulating flavors."
	icon_state = "pierre"
	gender = FEMALE

/obj/item/toy/plush/lobotomy/myo
	name = "myo plushie"
	desc = "A plushie that's here to chew grass and kick ass. And she's all out of grass."
	icon_state = "myo"
	gender = FEMALE
	pet_message = "You pet the myo plushie, yem."

/obj/item/toy/plush/lobotomy/rabbit
	name = "rabbit plushie"
	desc = "A plushie depicting a mercenary that grazes the grass."
	icon_state = "rabbit"

/obj/item/toy/plush/lobotomy/yuri
	name = "yuri plushie"
	desc = "A plushie depicting an employee who had the potential to walk alongside the Sinners."
	icon_state = "yuri"
	gender = FEMALE

/obj/item/toy/plush/lobotomy/yuri/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(istype(I, /obj/item/food/grown/apple/gold))
		if(do_after(user, 2 SECONDS, target = user))
			user.visible_message(span_danger("[src] is violently absorbed by \the [I]!"))
			qdel(src)
			return
		to_chat(user, span_notice("You feel as if you prevented something terrible from happening again."))

/obj/item/toy/plush/lobotomy/samjo
	name = "samjo plushie"
	desc = "A plushie depicting a secretary with unparalleled devotion."
	icon_state = "samjo"
	gender = MALE

// Abnormalities
/obj/item/toy/plush/lobotomy/qoh
	name = "queen of hatred plushie"
	desc = "A plushie depicting a magical girl whose goal is fighting all evil in the universe!"
	icon_state = "qoh"
	gender = FEMALE

/obj/item/toy/plush/lobotomy/kog
	name = "king of greed plushie"
	desc = "A plushie depicting a magical girl whose desires got the best of her."
	icon_state = "kog"
	gender = FEMALE
	pet_message = "While petting the king of greed plushie, you feel a slight nibbling on your finger."

/obj/item/toy/plush/lobotomy/kod
	name = "knight of despair plushie"
	desc = "A plushie depicting a magical girl who abandoned those who needed her most."
	icon_state = "kod"
	gender = FEMALE

/obj/item/toy/plush/lobotomy/sow
	name = "servant of wrath plushie"
	desc = "A plushie depicting a magical girl who was betrayed by someone they trusted dearly."
	icon_state = "sow"
	gender = FEMALE

/obj/item/toy/plush/lobotomy/nihil
	name = "jester of nihil plushie"
	desc = "A plushie depicting a black and white jester who embodies nilihism."
	icon_state = "nihil"

/obj/item/toy/plush/lobotomy/bigbird
	name = "big bird plushie"
	desc = "A plushie depicting a big bird with a lantern that burns forever. How does it even work?"
	icon_state = "bigbird"

/obj/item/toy/plush/lobotomy/mosb
	name = "mountain of smiling bodies plushie"
	desc = "A plushie depicting a mountain of corpses merged into one. Yuck!"
	icon_state = "mosb"

/obj/item/toy/plush/lobotomy/big_bad_wolf
	name = "big and will be bad wolf plushie"
	desc = "A plushie depicting quite a not so bad and very much so marketable wolf plush."
	icon_state = "big_bad_wolf"

/obj/item/toy/plush/lobotomy/melt
	name = "melting love plushie"
	desc = "A plushie depicting a slime girl, you think."
	icon_state = "melt"
	attack_verb_continuous = list("blorbles", "slimes", "absorbs")
	attack_verb_simple = list("blorble", "slime", "absorb")
	pet_message = "As you pet the melting love plushie, you swear it stares and smiles at you."

/obj/item/toy/plush/lobotomy/scorched
	name = "scorched girl plushie"
	desc = "A plushie depicting a burned girl with an eternally lit match."
	icon_state = "scorched"
	gender = FEMALE

/obj/item/toy/plush/lobotomy/pinocchio
	name = "pinocchio plushie"
	desc = "A plushie depicting a puppet that wanted to be a human."
	icon_state = "pinocchio"

// Others
/obj/item/toy/plush/lobotomy/bongbong
	name = "bongbong plushie"
	desc = "A plushie depicting the essence of Lobotomy Corporation."
	icon_state = "bongbong"
	pet_message = "Bong bong."

// Special
/obj/item/toy/plush/lobotomy/bongy
	name = "bongy plushie"
	desc = "It looks like a raw chicken. A cute raw chicken!"
	icon_state = "bongy"
