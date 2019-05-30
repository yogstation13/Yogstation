/obj/item/card
	icon = 'yogstation/icons/obj/card.dmi'
	var/has_fluff

/obj/item/card/id/update_label(newname, newjob)
	..()
	ID_fluff()

/obj/item/card/id/proc/ID_fluff()
	var/job = assignment
	var/list/idfluff = list(
	"Assistant" = list("civillian","green"),
	"Captain" = list("captain","gold"),
	"Head of Personnel" = list("civillian","silver"),
	"Head of Security" = list("security","silver"),
	"Chief Engineer" = list("engineering","silver"),
	"Research Director" = list("science","silver"),
	"Chief Medical Officer" = list("medical","silver"),
	"Station Engineer" = list("engineering","yellow"),
	"Atmospheric Technician" = list("engineering","white"),
	"Signal Technician" = list("engineering","green"),
	"Medical Doctor" = list("medical","blue"),
	"Geneticist" = list("medical","purple"),
	"Virologist" = list("medical","green"),
	"Chemist" = list("medical","orange"),
	"Paramedic" = list("medical","white"),
	"Psychiatrist" = list("medical","brown"),
	"Scientist" = list("science","purple"),
	"Roboticist" = list("science","black"),
	"Quartermaster" = list("cargo","silver"),
	"Cargo Technician" = list("cargo","brown"),
	"Shaft Miner" = list("cargo","black"),
	"Mining Medic" = list("cargo","blue"),
	"Bartender" = list("civillian","black"),
	"Botanist" = list("civillian","blue"),
	"Cook" = list("civillian","white"),
	"Janitor" = list("civillian","purple"),
	"Curator" = list("civillian","purple"),
	"Chaplain" = list("civillian","black"),
	"Clown" = list("clown","rainbow"),
	"Mime" = list("mime","white"),
	"Clerk" = list("civillian","blue"),
	"Tourist" = list("civillian","yellow"),
	"Warden" = list("security","black"),
	"Security Officer" = list("security","red"),
	"Detective" = list("security","brown"),
	"Lawyer" = list("security","purple")
	)
	if(job in idfluff)
		has_fluff = TRUE
	else
		if(has_fluff)
			return
		else
			job = "Assistant" //Loads up the basic green ID
	overlays.Cut()
	overlays += idfluff[job][1]
	overlays += idfluff[job][2]

/obj/item/card/id/silver
	icon_state = "id_silver"

/obj/item/card/id/gold
	icon_state = "id_gold"

/obj/item/card/id/captains_spare
	icon_state = "id_gold"

/obj/item/card/emag/emag_act(mob/user)
	var/otherEmag = user.get_active_held_item()
	if(!otherEmag)
		return
	to_chat(user, "<span class='notice'>The cyptographic sequencers attempt to override each other before destroying themselves.</span>")
	playsound(src.loc, "sparks", 50, 1)
	qdel(otherEmag)
	qdel(src)

/obj/item/card/id/gasclerk
	name = "Clerk"
	desc = "A employee ID used to access areas around the gastation."
	access = list(ACCESS_MANUFACTURING)

/obj/item/card/id/gasclerk/New()
	..()
	registered_account = new("Clerk", FALSE)

/obj/item/card/erp_pass
	name = "\improper ERP pass"
	desc = "A card that allows its user to ERP. The small print says \"uwu\"."
	icon_state = "id"
	item_state = "card-id"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/card/erp_pass/attack_self(mob/user)
	if(Adjacent(user))
		user.say("Rawr X3")
		user.visible_message("<span class='notice'>[user] nuzzles.</span>", "<span class='notice'>You nuzzle.</span>")
		user.say("How are you?")
		user.visible_message("<span class='notice'>[user] pounces on you.</span>", "<span class='notice'>You pounce.</span>")
		user.say("You're so warm o3o")
		user.visible_message("<span class='notice'>[user] notices you have a bulge.</span>", "<span class='notice'>You notice a bulge.</span>")
		user.say("Someone's happy!")
		user.visible_message("<span class='notice'>[user] nuzzles your necky wecky.</span>", "<span class='notice'>You nuzzle a necky wecky.</span>")
		user.say("~murr~ hehe ;)")
		user.visible_message("<span class='notice'>[user] rubbies your bulgy wolgy.</span>", "<span class='notice>You rubbie a bulgy wolgy.</span>")
		user.say("It doesn't stop growing .///.")
		user.visible_message("<span class='notice'>[user] kisses you and licks your neck.</span>", "<span class='notice'>You kiss and lick a neck.</span>")
		user.say("Daddy likes ;)")
		user.visible_message("<span class='notice'>[user] nuzzle wuzzles.</span>", "<span class='notice'>You nuzzle wuzzle.</span>")
		user.say("I hope daddy likes")
		user.visible_message("<span class='notice'>[user] wiggles their butt and squirms.</span>", "<span class='notice'>You wiggle your butt and squirm.</span>")
		user.say("I wanna see your big daddy meat!")
		user.visible_message("<span class='notice'>[user] wiggles their butt.</span>", "<span class='notice'>You wiggle your butt.</span>")
		user.say("I have a little itch o3o")
		user.visible_message("<span class='notice'>[user] wags their tails.</span>", "<span class='notice'>You wag your tails.</span>")
		user.say("Can you please get my itch?")
		user.visible_message("<span class='notice'>[user] puts their paws on your chest.</span>", "<span class='notice'>You put your paws on a chest.</span>")
		user.say("Nyea~ it's a seven inch itch")
		user.visible_message("<span class='notice'>[user] rubs your chest.</span>", "<span class='notice'>You rub a chest.</span>")
		user.say("Can you pwease?")
		user.visible_message("<span class='notice'>[user] squirms.</span>", "<span class='notice'>You squirm.</span>")
		user.say("Pwetty pwease? :( I need to be punished")
		user.visible_message("<span class='notice'>[user] runs their paws down your chest and bites their lip.</span>", "<span class='notice'>You run your paws down a chest and bite your lip.</span>")
		user.say("Like, I need to be punished really good")
		user.visible_message("<span class='notice'>[user] puts their paws on your bulge as their lick their lips.</span>", "<span class='notice'>You put your paws on a bulge as you lick your lips.</span")
		user.say("I'm getting thirsty.")
		user.say("I could go for some milk.")
		user.visible_message("<span class='notice'>[user] unbuttons your pants as their eyes glow.</span>", "<span class='notice'>You unbutton some pants as your eyes glow.</span>")
		user.say("You smell so musky ;)")
		user.visible_message("<span class='notice'>[user] licks your shaft.</span>", "<span class='notice'>You lick a shaft.</span>")
		user.say("mmmmmmmmmmmmmmmmmmm so musky ;)")
		user.visible_message("<span class='notice'>[user] drools all over your cawk.</span>", "<span class='notice'>You drool all over a cawk.</span>")
		user.say("Your daddy meat")
		user.say("I like")
		user.say("Mister fuzzy balls")
		user.visible_message("<span class='notice'>[user] puts their snout on your balls and inhales deeply.</span>", "<span class='notice'>You put your snout on some balls and inhale deeply.</span>")
		user.say("Oh my gawd")
		user.say("I'm so hard")
		user.visible_message("<span class='notice'>[user] rubbies your bulgy wolgy.</span>", "<span class='notice'>You rubbie a bulgy wolgy.</span>")
		user.visible_message("<span class='notice'>[user] licks your balls.</span>", "<span class='notice'>You lick some balls.</span>")
		user.say("Punish me daddy")
		user.say("Nyea~")
		user.visible_message("<span class='notice'>[user] squirms more and wiggles their butt.</span>", "<span class='notice'>You squirm and wiggle your butt.</span>")
		user.say("I love your musky goodness")
		user.visible_message("<span class='notice'>[user] bites their lip.</span>", "<span class='notice'>You bite your lip.</span>")
		user.say("Please punish me")
		user.visible_message("<span class='notice'>[user] licks their lips.</span>", "<span class='notice'>You lick your lips.</span>")
		user.say("Nyea~")
		user.visible_message("<span class='notice'>[user] suckles on your tip.</span>", "<span class='notice'>You suckle on a tip.</span>")
		user.say("So good")
		user.visible_message("<span class='notice'>[user] licks pre off your cock.</span>", "<span class='notice'>You lick pre off a cock.</span>")
		user.say("Salty goodness~")
		user.visible_message("<span class='notice'>[user]'s eyes roll back and they go balls deep.</span>", "<span class='notice'>Your eyes roll back and you go balls deep.</span>")
	add_fingerprint(user)
