/datum/holiday
	var/name = "Bugsgiving"

	var/begin_day = 1
	var/begin_month = 0
	var/end_day = 0 // Default of 0 means the holiday lasts a single day
	var/end_month = 0
	var/begin_week = FALSE //If set to a number, then this holiday will begin on certain week
	var/begin_weekday = FALSE //If set to a weekday, then this will trigger the holiday on the above week
	var/always_celebrate = FALSE // for christmas neverending, or testing.
	var/current_year = 0
	var/year_offset = 0
	var/obj/item/drone_hat //If this is defined, drones without a default hat will spawn with this one during the holiday; check drones_as_items.dm to see this used

// This proc gets run before the game starts when the holiday is activated. Do festive shit here.
/datum/holiday/proc/celebrate()
	return

// When the round starts, this proc is ran to get a text message to display to everyone to wish them a happy holiday
/datum/holiday/proc/greet()
	return "Have a happy [name]!"

// Returns special prefixes for the station name on certain days. You wind up with names like "Christmas Object Epsilon". See new_station_name()
/datum/holiday/proc/getStationPrefix()
	//get the first word of the Holiday and use that
	var/i = findtext(name, " ")
	return copytext(name, 1, i)

// Return 1 if this holidy should be celebrated today
/datum/holiday/proc/shouldCelebrate(dd, mm, yy, ww, ddd)
	if(always_celebrate)
		return TRUE

	if(!end_day)
		end_day = begin_day
	if(!end_month)
		end_month = begin_month
	if(begin_week && begin_weekday)
		if(begin_week == ww && begin_weekday == ddd && begin_month == mm)
			return TRUE
	if(end_month > begin_month) //holiday spans multiple months in one year
		if(mm == end_month) //in final month
			if(dd <= end_day)
				return TRUE

		else if(mm == begin_month)//in first month
			if(dd >= begin_day)
				return TRUE

		else if(mm in begin_month to end_month) //holiday spans 3+ months and we're in the middle, day doesn't matter at all
			return TRUE

	else if(end_month == begin_month) // starts and stops in same month, simplest case
		if(mm == begin_month && (dd in begin_day to end_day))
			return TRUE

	else // starts in one year, ends in the next
		if(mm >= begin_month && dd >= begin_day) // Holiday ends next year
			return TRUE
		if(mm <= end_month && dd <= end_day) // Holiday started last year
			return TRUE

	return FALSE

// The actual holidays

/datum/holiday/new_year
	name = NEW_YEAR
	begin_day = 30
	begin_month = DECEMBER
	end_day = 2
	end_month = JANUARY
	drone_hat = /obj/item/clothing/head/festive

/datum/holiday/new_year/getStationPrefix()
	return pick("Party","New","Hangover","Resolution","Auld")

/datum/holiday/new_year/greet()
	return "Happy New Years!"

/datum/holiday/groundhog
	name = "Groundhog Day"
	begin_day = 2
	begin_month = FEBRUARY
	drone_hat = /obj/item/clothing/head/helmet/space/chronos

/datum/holiday/groundhog/getStationPrefix()
	return pick("Groundhog")

/datum/holiday/groundhog/greet()
	return "Happy Groundhog day!"

/datum/holiday/valentines
	name = VALENTINES
	begin_day = 13
	end_day = 15
	begin_month = FEBRUARY
	lobby_music = list(
		"https://www.youtube.com/watch?v=cEwZpejd4rM", // Charlie Wilson - Forever Valentine
		"https://www.youtube.com/watch?v=4j-cPYewjn4", // David Bowie - Valentine's Day
		"https://www.youtube.com/watch?v=yvUPEW8bdHA" // On The Street Where You Live
		)

/datum/holiday/valentines/getStationPrefix()
	return pick("Love","Amore","Single","Smootch","Hug")

/datum/holiday/birthday
	name = "Birthday of Space Station 13"
	begin_day = 16
	begin_month = FEBRUARY
	drone_hat = /obj/item/clothing/head/festive

/datum/holiday/birthday/greet()
	var/game_age = text2num(time2text(world.timeofday, "YY")) - 3
	var/Fact
	switch(game_age)
		if(16)
			Fact = " SS13 is now old enough to drive!"
		if(18)
			Fact = " SS13 is now legal!"
		if(21)
			Fact = " SS13 can now drink!"
		if(26)
			Fact = " SS13 can now rent a car!"
		if(30)
			Fact = " SS13 can now go home and be a family man!"
		if(35)
			Fact = " SS13 can now run for President of the United States!"
		if(40)
			Fact = " SS13 can now suffer a midlife crisis!"
		if(50)
			Fact = " Happy golden anniversary!"
		if(65)
			Fact = " SS13 can now start thinking about retirement!"
		if(96)
			Fact = " Please send a time machine back to pick me up, I need to update the time formatting for this feature!" //See you later suckers
	if(!Fact)
		Fact = " SS13 is now [game_age] years old!"

	return "Say 'Happy Birthday' to Space Station 13, first publicly playable on February 16th, 2003![Fact]"

/datum/holiday/random_kindness
	name = "Random Acts of Kindness Day"
	begin_day = 17
	begin_month = FEBRUARY

/datum/holiday/random_kindness/greet()
	return "Go do some random acts of kindness for a stranger!" //haha yeah right

/datum/holiday/leap
	name = "Leap Day"
	begin_day = 29
	begin_month = FEBRUARY

/datum/holiday/leap/greet()
	return "Today is Leap Day!"

/datum/holiday/pi
	name = "Pi Day"
	begin_day = 14
	begin_month = MARCH
	lobby_music = list(
		"https://www.youtube.com/watch?v=9WGO7dAxjD8", // Circle Song
		"https://www.youtube.com/watch?v=3HRkKznJoZA", // Pi Song
		"https://www.youtube.com/watch?v=Ay8vzCHkgEk" // Pi Black Midi
		)

/datum/holiday/pi/getStationPrefix()
	return pick("Sine","Cosine","Tangent","Secant","Cosecant","Cotangent","Radian","Pi","Arc")

/datum/holiday/no_this_is_patrick
	name = "St. Patrick's Day"
	begin_day = 17
	begin_month = MARCH
	drone_hat = /obj/item/clothing/head/soft/green

/datum/holiday/no_this_is_patrick/getStationPrefix()
	return pick("Blarney","Green","Leprechaun","Booze","Pub","IRA")

/datum/holiday/no_this_is_patrick/greet()
	return "Happy St. Patrick's Day!"

/datum/holiday/april_fools
	name = APRIL_FOOLS
	begin_day = 1
	end_day = 5
	begin_month = APRIL
	lobby_music = list(
		"https://www.youtube.com/watch?v=5QtxOr4iSBY", // Gay Activity - Clive Richardson
		"https://www.youtube.com/watch?v=ytWz0qVvBZ0", // Diggy Diggy Hole - Sparkles*
		"https://www.youtube.com/watch?v=ko_A6YW6Krk", // Blockbuster - Jack Waldenmaier
		"https://www.youtube.com/watch?v=qOVLUiha1B8", // Welcome To YogLabs - Mattokamus
		"https://www.youtube.com/watch?v=9whQIbNmu9s"  // Clown.wmv - Admiral Hippie
	)

/datum/holiday/april_fools/celebrate()
	SSjob.set_overflow_role("Clown")

/datum/holiday/april_fools/greet()
	return "NOTICE: Yogstation will be down from April 2nd to April 5th as we transfer to the Source engine. Please join our discord for more info."

/datum/holiday/spess
	name = "Cosmonautics Day"
	begin_day = 12
	begin_month = APRIL
	drone_hat = /obj/item/clothing/head/syndicatefake

/datum/holiday/spess/greet()
	return "On this day over 600 years ago, Comrade Yuri Gagarin first ventured into space!"

/datum/holiday/fourtwenty
	name = "Four-Twenty"
	begin_day = 20
	begin_month = APRIL

/datum/holiday/fourtwenty/getStationPrefix()
	return pick("Snoop","Blunt","Toke","Dank","Cheech","Chong")

/datum/holiday/fourtwenty/greet()
	return "Smoke weed every day!"

/datum/holiday/tea
	name = "National Tea Day"
	begin_day = 21
	begin_month = APRIL

/datum/holiday/tea/getStationPrefix()
	return pick("Crumpet","Assam","Oolong","Pu-erh","Sweet Tea","Green","Black")

/datum/holiday/earth
	name = "Earth Day"
	begin_day = 22
	begin_month = APRIL

/datum/holiday/labor
	name = "Labor Day"
	begin_day = 1
	begin_month = MAY
	drone_hat = /obj/item/clothing/head/hardhat

/datum/holiday/labor/getStationPrefix()
	return pick("Union","Labor","Worker","Trade")

/datum/holiday/firefighter
	name = "Firefighter's Day"
	begin_day = 4
	begin_month = MAY
	drone_hat = /obj/item/clothing/head/hardhat/red

/datum/holiday/firefighter/getStationPrefix()
	return pick("Burning","Blazing","Plasma","Fire")

/datum/holiday/bee
	name = "Bee Day"
	begin_day = 20
	begin_month = MAY
	drone_hat = /obj/item/clothing/mask/rat/bee

/datum/holiday/bee/getStationPrefix()
	return pick("Bee","Honey","Hive","Africanized","Mead","Buzz")

/datum/holiday/summersolstice
	name = "Summer Solstice"
	begin_day = 21
	begin_month = JUNE

/datum/holiday/summersolstice/greet()
	return "Happy Summer Solstice!"

/datum/holiday/doctor
	name = "Doctor's Day"
	begin_day = 1
	begin_month = JULY
	drone_hat = /obj/item/clothing/head/nursehat

/datum/holiday/UFO
	name = "UFO Day"
	begin_day = 2
	begin_month = JULY
	drone_hat = /obj/item/clothing/mask/facehugger/dead
	lobby_music = list(
		"https://www.youtube.com/watch?v=X8cmbmwFAl8",	// Clutch - X-Ray Visions
		"https://www.youtube.com/watch?v=sYkvpNR8BGU",	// Blue Oyster Cult: E.T.I. (Extra Terraestrial Intelligence)
		"https://www.youtube.com/watch?v=Pyu89NHSniU",	// Blood And Rockets: Movement I, Saga Of Jack Parsons - Movement II, Too The Moon
		"https://www.youtube.com/watch?v=BYDd0TTx4nE",	// Nyctophilliac - Blunted Session
		"https://www.youtube.com/watch?v=n8cCDoDYgc0",	// Ballad of a Spaceman - Julia Ecklar
		"https://www.youtube.com/watch?v=I1VLuZ9Smf0",	// Elektronik Supersonik - ZLAD
		"https://www.youtube.com/watch?v=KvQ0zWHtnN4",	// The Mechanisms - Once Upon a Time - 06 Pump Shanty
		"https://www.youtube.com/watch?v=4hutvW-eSFY"	// Bryan Scary and the Shedding Tears - Venus Ambassador
	)

/datum/holiday/UFO/getStationPrefix() //Is such a thing even possible?
	return pick("Ayy","Truth","Tsoukalos","Mulder","Scully","Greys") //Yes it is!

/datum/holiday/USA
	name = "Independence Day"
	begin_day = 4
	begin_month = JULY
	lobby_music = list(
		"https://www.youtube.com/watch?v=5uPoDNEn3I0", // america
		"https://www.youtube.com/watch?v=ec0XKhAHR5I", // fortunate (how did i forget a slash)
		"https://www.youtube.com/watch?v=9Cyokaj3BJU", // alabama
		"https://www.youtube.com/watch?v=1vrEljMfXYo", // country roads
		"https://www.youtube.com/watch?v=FqxJ_iuBPCs", // Star Spangled Banner
		"https://www.youtube.com/watch?v=H0bhSGfKTs4", // Surfin' USA
		"https://www.youtube.com/watch?v=FAVQsnr4uYg",  // Lone Star - Tony Marcus
		"https://www.youtube.com/watch?v=kQzdJUiALBk"	// wyoming - In the Shadow of the Valley - Don Burnham
	)
/datum/holiday/USA/getStationPrefix()
	return pick("Independent","American","Burger","Bald Eagle","Star-Spangled", "Fireworks")

/datum/holiday/writer
	name = "Writer's Day"
	begin_day = 8
	begin_month = JULY

/datum/holiday/france
	name = "Bastille Day"
	begin_day = 14
	begin_month = JULY
	drone_hat = /obj/item/clothing/head/beret
	lobby_music = list(
		"https://www.youtube.com/watch?v=4K1q9Ntcr5g", // French Anthem La Marseillaise
		"https://www.youtube.com/watch?v=c5OdCqUWRyo", // Le Chant du Depart
		"https://www.youtube.com/watch?v=wS10laW0rFo", // Chant du 9 Thermidor
		"https://www.youtube.com/watch?v=o3wivTC1gOw", // Bonjour mon vieux Paris
		)

/datum/holiday/france/getStationPrefix()
	return pick("Francais","Fromage", "Zut", "Merde")

/datum/holiday/france/greet()
	return "Do you hear the people sing?"

/datum/holiday/friendship
	name = "Friendship Day"
	begin_day = 30
	begin_month = JULY

/datum/holiday/friendship/greet()
	return "Have a magical [name]!"

/datum/holiday/beer
	name = "Beer Day"

/datum/holiday/beer/shouldCelebrate(dd, mm, yy, ww, ddd)
	return (mm == 8 && ddd == FRIDAY && ww == 1) //First Friday in August

/datum/holiday/beer/getStationPrefix()
	return pick("Stout","Porter","Lager","Ale","Malt","Bock","Doppelbock","Hefeweizen","Pilsner","IPA","Lite") //I'm sorry for the last one

/datum/holiday/pirate
	name = "Talk-Like-a-Pirate Day"
	begin_day = 19
	begin_month = SEPTEMBER
	drone_hat = /obj/item/clothing/head/pirate

/datum/holiday/pirate/greet()
	return "Ye be talkin' like a pirate today or else ye'r walkin' tha plank, matey!"

/datum/holiday/pirate/getStationPrefix()
	return pick("Yarr","Scurvy","Yo-ho-ho")

/datum/holiday/programmers
	name = "Programmers' Day"

/datum/holiday/programmers/shouldCelebrate(dd, mm, yy, ww, ddd) //Programmer's day falls on the 2^8th day of the year
	return (mm==9 && ((yy/4 == round(yy/4) && dd==12) || dd==13))

/datum/holiday/programmers/getStationPrefix()
	return pick("span>","DEBUG: ","null","/list","EVENT PREFIX NOT FOUND") //Portability

/datum/holiday/questions
	name = "Stupid-Questions Day"
	begin_day = 28
	begin_month = SEPTEMBER

/datum/holiday/questions/greet()
	return "Are you having a happy [name]?"

/datum/holiday/animal
	name = "Animal's Day"
	begin_day = 4
	begin_month = OCTOBER

/datum/holiday/animal/getStationPrefix()
	return pick("Parrot","Corgi","Cat","Pug","Goat","Fox")

/datum/holiday/smile
	name = "Smiling Day"
	begin_day = 7
	begin_month = OCTOBER
	drone_hat = /obj/item/clothing/head/papersack/smiley

/datum/holiday/boss
	name = "Boss' Day"
	begin_day = 16
	begin_month = OCTOBER
	drone_hat = /obj/item/clothing/head/that

/datum/holiday/halloween
	name = HALLOWEEN
	begin_day = 26
	begin_month = OCTOBER
	end_day = 2
	end_month = NOVEMBER
	lobby_music = list(
		"https://www.youtube.com/watch?v=AfjqL0vaBYU", // Haunted Fortress 2
		"https://www.youtube.com/watch?v=9QpmfOLaUcw", // Misfortune Teller
		"https://www.youtube.com/watch?v=m9We2XsVZfc", // Ghostbusters Theme
		"https://www.youtube.com/watch?v=xIx_HbmRnQY", // Thriller
		"https://www.youtube.com/watch?v=7-D83f33pAE", // Spooky Scary Skeletons
		"https://www.youtube.com/watch?v=bebUeWgNkAM", // Halloween Theme Michael Myers
		"https://www.youtube.com/watch?v=qaQ6oJL1qQA", // Lucifer My Love - Twin Temple
		"https://www.youtube.com/watch?v=vCYLUZyWeDs&t", // "Unforgiving Cold"- Godzilla NES Creepypasta OST
		"https://www.youtube.com/watch?v=OPDDFdyKOgU", // Red Signal - The Bifrost Incident - The Mechanisms
		"https://www.youtube.com/watch?v=d1itZiNY5pY" // Todd Rollins - The Boogie Man
		)

/datum/holiday/halloween/greet()
	return "Have a spooky Halloween!"

/datum/holiday/halloween/getStationPrefix()
	return pick("Bone-Rattling","Mr. Bones' Own","2SPOOKY","Spooky","Scary","Skeletons","The Haunted","Abominable","Gibbering","Squamous","Ghoul","Zombie","Forbidden","Bloody","Horrific","Infernal","Star Spawned","Hellish","Forgotten","Eldritch","Sleeping","Eternal","Abhorrence","Plague","Dread","Apprehension","Crawling Chaos","Blot","Cold Sweat","Unholy","Jitters","Unknown","Darkness","Festering","Fetid","Vile","Lurker","Scorn","Apocalypse","The Last","Lasting","Corruption","Blasphemous","The Corruption on","The Blasphemous")

/datum/holiday/vegan
	name = "Vegan Day"
	begin_day = 1
	begin_month = NOVEMBER

/datum/holiday/vegan/getStationPrefix()
	return pick("Tofu", "Tempeh", "Seitan", "Tofurkey")

/datum/holiday/october_revolution
	name = "October Revolution"
	begin_day = 6
	begin_month = NOVEMBER
	end_day = 7

/datum/holiday/october_revolution/getStationPrefix()
	return pick("Communist", "Soviet", "Bolshevik", "Socialist", "Red", "Workers'")

/datum/holiday/remembrance
    name = "Remembrance Day"
    begin_day = 11
    begin_month = NOVEMBER

/datum/holiday/remembrance/celebrate()
    SSticker.OnRoundstart(CALLBACK(src, .proc/roundstart_celebrate))

/datum/holiday/remembrance/proc/roundstart_celebrate()
    for(var/mob/living/carbon/human/H in GLOB.player_list)
        H.put_in_hands(new /obj/item/clothing/accessory/poppypin)

/datum/holiday/kindness
	name = "Kindness Day"
	begin_day = 13
	begin_month = NOVEMBER

/datum/holiday/flowers
	name = "Flowers Day"
	begin_day = 19
	begin_month = NOVEMBER
	drone_hat = /obj/item/reagent_containers/food/snacks/grown/moonflower

/datum/holiday/hello
	name = "Saying-'Hello' Day"
	begin_day = 21
	begin_month = NOVEMBER

/datum/holiday/hello/greet()
	return "[pick(list("Aloha", "Bonjour", "Hello", "Hi", "Greetings", "Salutations", "Bienvenidos", "Hola", "Howdy", "Ni hao", "Guten Tag", "Konnichiwa", "G'day cunt"))]! " + ..()

/datum/holiday/human_rights
	name = "Human-Rights Day"
	begin_day = 10
	begin_month = DECEMBER

/datum/holiday/monkey
	name = "Monkey Day"
	begin_day = 14
	begin_month = DECEMBER
	drone_hat = /obj/item/clothing/mask/gas/monkeymask

/datum/holiday/thanksgiving
	name = "Thanksgiving in the United States"
	begin_week = 4
	begin_month = NOVEMBER
	begin_weekday = THURSDAY
	drone_hat = /obj/item/clothing/head/that //This is the closest we can get to a pilgrim's hat

/datum/holiday/thanksgiving/canada
	name = "Thanksgiving in Canada"
	begin_week = 2
	begin_month = OCTOBER
	begin_weekday = MONDAY

/datum/holiday/columbus
	name = "Columbus Day"
	begin_week = 2
	begin_month = OCTOBER
	begin_weekday = MONDAY

/datum/holiday/mother
	name = "Mother's Day"
	begin_week = 2
	begin_month = MAY
	begin_weekday = SUNDAY

/datum/holiday/mother/greet()
	return "Happy Mother's Day in most of the Americas, Asia, and Oceania!"

/datum/holiday/father
	name = "Father's Day"
	begin_week = 3
	begin_month = JUNE
	begin_weekday = SUNDAY

/datum/holiday/moth
	name = "Moth Week"

/datum/holiday/moth/shouldCelebrate(dd, mm, yy, ww, ddd) //National Moth Week falls on the last full week of July
	return mm == JULY && (ww == 4 || (ww == 5 && ddd == SUNDAY))

/datum/holiday/moth/getStationPrefix()
	return pick("Mothball","Lepidopteran","Lightbulb","Moth","Giant Atlas","Twin-spotted Sphynx","Madagascan Sunset","Luna","'s Head","Emperor Gum","Polyphenus","Oleander Hawk","Io","Rosy Maple","Cecropia","Noctuidae","Giant Leopard","Dysphania Militaris","Garden Tiger")

/datum/holiday/ramadan
	name = "Start of Ramadan"

/*

For anyone who stumbles on this some time in the future: this was calibrated to 2017
Calculated based on the start and end of Ramadan in 2000 (First year of the Gregorian Calendar supported by BYOND)
This is going to be accurate for at least a decade, likely a lot longer
Since the date fluctuates, it may be inaccurate one year and then accurate for several after
Inaccuracies will never be by more than one day for at least a hundred years
Finds the number of days since the day in 2000 and gets the modulo of that and the average length of a Muslim year since the first one (622 AD, Gregorian)
Since Ramadan is an entire month that lasts 29.5 days on average, the start and end are holidays and are calculated from the two dates in 2000

*/

/datum/holiday/ramadan/shouldCelebrate(dd, mm, yy, ww, ddd)
	return (round(((world.realtime - 285984000) / 864000) % 354.373435326843) == 0)

/datum/holiday/ramadan/getStationPrefix()
	return pick("Harm","Halaal","Jihad","Muslim")

/datum/holiday/ramadan/end
	name = "End of Ramadan"

/datum/holiday/ramadan/end/shouldCelebrate(dd, mm, yy, ww, ddd)
	return (round(((world.realtime - 312768000) / 864000) % 354.373435326843) == 0)

/datum/holiday/lifeday
	name = "Life Day"
	begin_day = 17
	begin_month = NOVEMBER

/datum/holiday/lifeday/getStationPrefix()
	return pick("Itchy", "Lumpy", "Malla", "Kazook") //he really pronounced it "Kazook", I wish I was making shit up

/datum/holiday/doomsday
	name = "Mayan Doomsday Anniversary"
	begin_day = 21
	begin_month = DECEMBER
	drone_hat = /obj/item/clothing/mask/rat/tribal

/datum/holiday/xmas
	name = CHRISTMAS
	begin_day = 19
	begin_month = DECEMBER
	end_day = 27
	drone_hat = /obj/item/clothing/head/santa
	lobby_music = list(
		"https://www.youtube.com/watch?v=v7s2VjwQSMw", // Jingle Bells
		"https://www.youtube.com/watch?v=oIKt5p3UmXg", // Michael Bublé - Winter Wonderland
		"https://www.youtube.com/watch?v=nytpYtLtHpE", // Youre a Mean One, Mr. Grinch
		"https://www.youtube.com/watch?v=jCjrcjFGQCA", // Frosty The Snowman
		"https://www.youtube.com/watch?v=oyEyMjdD2uk", // Twelve Days of Christmas
		"https://www.youtube.com/watch?v=Dkq3LD-4pmM",  // Michael Bublé - Holly Jolly Christmas
		"https://www.youtube.com/watch?v=WgEVI8DEkF8",	// Nat King Cole - Deck the Halls
		"https://www.youtube.com/watch?v=noMhM1CjM78",	// Christopher Lee - Silent Night
		"https://www.youtube.com/watch?v=KmddeUJJEuU",	// Perry Como - It's Beginning to Look a Lot Like Christmas
		"https://www.youtube.com/watch?v=kfZtNVEqsBs",  // Christopher Lee - Jingle Hell
		"https://soundcloud.com/garym03062/beacons-in-the-darkness",	// Gary McGath - Beacons in the Darkness
		"https://www.youtube.com/watch?v=KGEfBop0nkI",	// Julia Ecklar - "Christmastime in Sector 5" - "Little Drummer Boy"
		"https://www.youtube.com/watch?v=1twga61Kd14",	// Julia Ecklar - #1 - Christmas Time
		"https://www.youtube.com/watch?v=imjMjnczqkU"	// Pete Gold - Ive Been a Bad Boy
		)

/datum/holiday/xmas/greet()
	return "Have a merry Christmas!"

/datum/holiday/xmas/celebrate()
	SSticker.OnRoundstart(CALLBACK(src, .proc/roundstart_celebrate))
	GLOB.maintenance_loot += list(
		/obj/item/toy/xmas_cracker = 3,
		/obj/item/clothing/head/santa = 1,
		/obj/item/a_gift/anything = 1
	)

/datum/holiday/xmas/proc/roundstart_celebrate()
	for(var/obj/machinery/computer/security/telescreen/entertainment/Monitor in GLOB.machines)
		Monitor.icon_state_on = "entertainment_xmas"

	for(var/mob/living/simple_animal/pet/dog/corgi/Ian/Ian in GLOB.mob_living_list)
		Ian.place_on_head(new /obj/item/clothing/head/helmet/space/santahat(Ian))


/datum/holiday/festive_season
	name = FESTIVE_SEASON
	begin_day = 1
	begin_month = DECEMBER
	end_day = 31
	drone_hat = /obj/item/clothing/head/santa

/datum/holiday/festive_season/greet()
	return "Have a nice festive season!"

/datum/holiday/boxing
	name = "Boxing Day"
	begin_day = 26
	begin_month = DECEMBER

/datum/holiday/friday_thirteenth
	name = "Friday the 13th"

/datum/holiday/friday_thirteenth/shouldCelebrate(dd, mm, yy, ww, ddd)
	return (dd == 13 && ddd == FRIDAY)

/datum/holiday/friday_thirteenth/getStationPrefix()
	return pick("Mike","Friday","Evil","Myers","Murder","ly","Stabby","Voorhees","Jason","Mother","Krueger","Telephone","Slasher","Flick","Hockey","Chevron")

/datum/holiday/easter
	name = EASTER
	drone_hat = /obj/item/clothing/head/rabbitears
	var/const/days_early = 1 //to make editing the holiday easier
	var/const/days_extra = 1

/datum/holiday/easter/shouldCelebrate(dd, mm, yy, ww, ddd)
	if(!begin_month)
		current_year = text2num(time2text(world.timeofday, "YYYY"))
		var/list/easterResults = EasterDate(current_year+year_offset)

		begin_day = easterResults["day"]
		begin_month = easterResults["month"]

		end_day = begin_day + days_extra
		end_month = begin_month
		if(end_day >= 32 && end_month == MARCH) //begins in march, ends in april
			end_day -= 31
			end_month++
		if(end_day >= 31 && end_month == APRIL) //begins in april, ends in june
			end_day -= 30
			end_month++

		begin_day -= days_early
		if(begin_day <= 0)
			if(begin_month == APRIL)
				begin_day += 31
				begin_month-- //begins in march, ends in april

	return ..()

/datum/holiday/easter/celebrate()
	GLOB.maintenance_loot += list(
		/obj/item/reagent_containers/food/snacks/egg/loaded = 15,
		/obj/item/storage/bag/easterbasket = 15)

/datum/holiday/easter/greet()
	return "Greetings! Have a Happy Easter and keep an eye out for Easter Bunnies!"

/datum/holiday/easter/getStationPrefix()
	return pick("Fluffy","Bunny","Easter","Egg")

/datum/holiday/lovecraft
	name = "H.P. Lovecraft's Birthday"
	begin_day = 20
	begin_month = AUGUST
	lobby_music = list(
		"https://www.youtube.com/watch?v=XYpGVnpujOQ", // I burn - Toadies
		"https://www.youtube.com/watch?v=hLRo06NCOAo", // When He Died - Lemon Demon
		"https://www.youtube.com/watch?v=MfQ1zGsZOiI", // Enter the Temple - Nyctophilliac
		"https://www.youtube.com/watch?v=w-N1tjMfk4Y", // The Darkest of Hillside Thickets - No Way
		"https://www.youtube.com/watch?v=27gmVUixXfs", // Ragnarok I: Runaway - The Mechanisms
		"https://www.youtube.com/watch?v=Q5tYxsjjpsU", // Ragnarok II - The Calling - The Mechanisms
		"https://www.youtube.com/watch?v=56pccCkgsdk", // Merlin - Kathy Mar
		"https://www.youtube.com/watch?v=XRnjPSkVdt8", // Blood Ceremony - Goodbye Gemini
		"https://www.youtube.com/watch?v=hX05LywQlPw", // The Darkest of Hillside Thickets - Cultists Onboard
		"https://www.youtube.com/watch?v=Nl95A7on4iI", // The Astral Seer - Hallas
		"https://www.youtube.com/watch?v=xHAeJSwUbaw", // Demon Sultan Azathoth - The H.P. Lovecraft Historical Society
		"https://www.youtube.com/watch?v=KSvsy11PHxM", // I saw mommy kissing Yog-Sothoth - The H.P. Lovecraft Historical Society
		"https://www.youtube.com/watch?v=61MR40PG8K4", // What Do You Do with an Innsmouth Sailor? - H. P. Lovecraft Historical Society - A Shoggoth on the Roof
		"https://www.youtube.com/watch?v=P2csnVNai-o", // Tentacles! - H. P. Lovecraft Historical Society - A Shoggoth on the Roof
		"https://www.youtube.com/watch?v=Jr5DG6QheEc",  // Look! Professor Angell Brings - H. P. Lovecraft Historical Society - An Even Scarier Solstice
		"https://www.youtube.com/watch?v=LA4TMacjYMw",  // Slay Ride - H. P. Lovecraft Historical Society - An Even Scarier Solstice
		"https://www.youtube.com/watch?v=tM08p2sxDVE"	// Embrace the Darkness - Andrew Hulshult - DUSK
		)

/datum/holiday/twofoursixohfive
	name = "24605 Anniversary"
	begin_day = 2
	begin_month = AUGUST
	drone_hat = /obj/item/clothing/head/beret/atmos
	lobby_music = list("https://www.youtube.com/watch?v=QfCOJLRk2D4") // Johnny Cash - Ring Of Fire

/datum/holiday/twofoursixohfive/getStationPrefix()
	return pick("Class-O","Class-B","Class-A","Class-F","Class-G","Class-K","Class-M","Dwarf","Main Sequence","Giant","Atmospheric")
