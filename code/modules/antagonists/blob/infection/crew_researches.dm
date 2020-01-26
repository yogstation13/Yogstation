/datum/crew_researches
	var/name = "TEST"
	var/desc = "TEST"
	var/cost = 1
	var/id = "test"
	var/researched = FALSE
	var/tier = 1

/datum/crew_researches/proc/onPurchase(fCrew)
	var/datum/infection_crew/crew = fCrew
	if(crew.points >= cost)
		if(crew.tier >= tier)
			crew.points -= cost
			researched = TRUE
			return TRUE
	return FALSE

/datum/crew_researches/blob_cultivation
	name = "Blob Cultivation"
	desc = "Unlocks the blob cultivation machine"
	cost = 25
	id = "blob_cultivation"
	tier = 1

/datum/crew_researches/healing_gel
	name = "Healing Gel"
	desc = "Makes a specialised healing patch available in the fabricator"
	cost = 25
	id = "healing_gel"
	tier = 1

/datum/crew_researches/advanced_purifier
	name = "Advanced Purifier"
	desc = "Makes experimental welding tools available at the fabricator"
	cost = 30
	id = "advanced_purifier"
	tier = 1

/datum/crew_researches/neural_hijacker
	name = "Neural Hijacker"
	desc = "Unlocks the Neural Hijacker"
	cost = 50
	id = "neural_hijacker"
	tier = 2

/datum/crew_researches/lazarus
	name = "Lazarus Rounds"
	desc = "Unlocks specialised anti-blob ammunition in the fabricator"
	cost = 40
	id = "lazarus_rounds"
	tier = 2

/datum/crew_researches/bio_armor
	name = "Bio Integrated Armor"
	desc = "Unlocks specialised armor, that reduces damage taken from the Infection"
	cost = 40
	id = "bio_armor"
	tier = 2

/datum/crew_researches/mech_armor
	name = "Bio-assisted Mechanized Armor"
	desc = "Unlocks high tier specialised armor, that reduces damage taken from the Infection"
	cost = 60
	id = "mech_armor"
	tier = 3

/datum/crew_researches/purifier
	name = "Purifier Rounds"
	desc = "Unlocks the ultimate anti-infection ammo in the fabricator"
	cost = 60
	id = "purifier"
	tier = 3

/datum/crew_researches/grasscutter
	name = "'Grasscutter' Pistol"
	desc = "Unlocks a small pistol for emergency defence, self charging"
	cost = 50
	id = "grasscutter"
	tier = 3

/datum/crew_researches/big_bertha
	name = "'Big Bertha'"
	desc = "Unlocks the construction of 2 'Big Bertha' miniguns specialised at fighting the Infection"
	cost = 150
	id = "big_bertha"
	tier = 3

/datum/crew_researches/juggernaut
	name = "'Juggernaut' Personal Armor"
	desc = "Unlocks the construction of 2 'Juggernaut' armor sets, the ultimate in protection."
	cost = 125
	id = "juggernaut"
	tier = 3