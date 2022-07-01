
/datum/guardianname
	var/prefixname = "Default" //the prefix the guardian uses for its name
	var/suffixcolor = "Name" //the suffix the guardian uses for its name
	var/parasiteicon = "techbase" //the icon of the guardian
	var/bubbleicon = "holo" //the speechbubble icon of the guardian
	var/theme = "tech" //what the actual theme of the guardian is
	var/color = "#C3C3C3" //what color the guardian's name is in chat and what color is used for effects from the guardian
	var/stainself = 0 //whether to use the color var to literally dye ourself our chosen color, for lazy spriting

/datum/guardianname/carp
	bubbleicon = "guardian"
	theme = "carp"
	parasiteicon = "holocarp"
	stainself = 1

/datum/guardianname/carp/New()
	prefixname = pick(GLOB.carp_names)

/datum/guardianname/carp/sand
	suffixcolor = "Sand"
	color = "#C2B280"

/datum/guardianname/carp/seashell
	suffixcolor = "Seashell"
	color = "#FFF5EE"

/datum/guardianname/carp/coral
	suffixcolor = "Coral"
	color = "#FF7F50"

/datum/guardianname/carp/salmon
	suffixcolor = "Salmon"
	color = "#FA8072"

/datum/guardianname/carp/sunset
	suffixcolor = "Sunset"
	color = "#FAD6A5"

/datum/guardianname/carp/riptide
	suffixcolor = "Riptide"
	color = "#89D9C8"

/datum/guardianname/carp/seagreen
	suffixcolor = "Sea Green"
	color = "#2E8B57"

/datum/guardianname/carp/ultramarine
	suffixcolor = "Ultramarine"
	color = "#3F00FF"

/datum/guardianname/carp/cerulean
	suffixcolor = "Cerulean"
	color = "#007BA7"

/datum/guardianname/carp/aqua
	suffixcolor = "Aqua"
	color = "#00FFFF"

/datum/guardianname/carp/paleaqua
	suffixcolor = "Pale Aqua"
	color = "#BCD4E6"

/datum/guardianname/carp/hookergreen
	suffixcolor = "Hooker Green"
	color = "#49796B"

/datum/guardianname/magic
	bubbleicon = "guardian"
	theme = "magic"

/datum/guardianname/magic/New()
	prefixname = pick("Aries", "Leo", "Sagittarius", "Taurus", "Virgo", "Capricorn", "Gemini", "Libra", "Aquarius", "Cancer", "Scorpio", "Pisces", "Ophiuchus")

/datum/guardianname/magic/red
	suffixcolor = "Red"
	parasiteicon = "magicRed"
	color = "#E32114"

/datum/guardianname/magic/pink
	suffixcolor = "Pink"
	parasiteicon = "magicPink"
	color = "#FB5F9B"

/datum/guardianname/magic/orange
	suffixcolor = "Orange"
	parasiteicon = "magicOrange"
	color = "#F3CF24"

/datum/guardianname/magic/green
	suffixcolor = "Green"
	parasiteicon = "magicGreen"
	color = "#A4E836"

/datum/guardianname/magic/blue
	suffixcolor = "Blue"
	parasiteicon = "magicBlue"
	color = "#78C4DB"

/datum/guardianname/tech/New()
	prefixname = pick("Gallium", "Indium", "Thallium", "Bismuth", "Aluminium", "Mercury", "Iron", "Silver", "Zinc", "Titanium", "Chromium", "Nickel", "Platinum", "Tellurium", "Palladium", "Rhodium", "Cobalt", "Osmium", "Tungsten", "Iridium")

/datum/guardianname/tech/rose
	suffixcolor = "Rose"
	parasiteicon = "techRose"
	color = "#F62C6B"

/datum/guardianname/tech/peony
	suffixcolor = "Peony"
	parasiteicon = "techPeony"
	color = "#E54750"

/datum/guardianname/tech/lily
	suffixcolor = "Lily"
	parasiteicon = "techLily"
	color = "#F6562C"

/datum/guardianname/tech/daisy
	suffixcolor = "Daisy"
	parasiteicon = "techDaisy"
	color = "#ECCD39"

/datum/guardianname/tech/zinnia
	suffixcolor = "Zinnia"
	parasiteicon = "techZinnia"
	color = "#89F62C"

/datum/guardianname/tech/ivy
	suffixcolor = "Ivy"
	parasiteicon = "techIvy"
	color = "#5DF62C"

/datum/guardianname/tech/iris
	suffixcolor = "Iris"
	parasiteicon = "techIris"
	color = "#2CF6B8"

/datum/guardianname/tech/petunia
	suffixcolor = "Petunia"
	parasiteicon = "techPetunia"
	color = "#51A9D4"

/datum/guardianname/tech/violet
	suffixcolor = "Violet"
	parasiteicon = "techViolet"
	color = "#8A347C"

/datum/guardianname/tech/lotus
	suffixcolor = "Lotus"
	parasiteicon = "techLotus"
	color = "#463546"

/datum/guardianname/tech/lilac
	suffixcolor = "Lilac"
	parasiteicon = "techLilac"
	color = "#C7A0F6"

/datum/guardianname/tech/orchid
	suffixcolor = "Orchid"
	parasiteicon = "techOrchid"
	color = "#F62CF5"
