// Hey! Listen! Update \config\lavaruinblacklist.txt with your new ruins!

/datum/map_template/ruin/lavaland
	prefix = "_maps/RandomRuins/LavaRuins/"

/datum/map_template/ruin/lavaland/biodome
	cost = 5
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/biodome/beach
	name = "Biodome Beach"
	id = "biodome-beach"
	description = "Seemingly plucked from a tropical destination, this beach is calm and cool, with the salty waves roaring softly in the background. \
	Comes with a rustic wooden bar and suicidal bartender."
	suffix = "lavaland_biodome_beach.dmm"

/datum/map_template/ruin/lavaland/biodome/fishing
	name = "Biodome Fishing Pier"
	id = "biodome-fishing"
	description = "A freshwater fishing pier, contained in a biodome? In MY lavaland? \
	Comes with a rustic wooden pier, kitchen, a gift shop, and two fishermen."
	suffix = "lavaland_biodome_fishing.dmm"

/datum/map_template/ruin/lavaland/biodome/winter
	name = "Biodome Winter"
	id = "biodome-winter"
	description = "For those getaways where you want to get back to nature, but you don't want to leave the fortified military compound where you spend your days. \
	Includes a unique(*) laser pistol display case, and the recently introduced I.C.E(tm)."
	suffix = "lavaland_surface_biodome_winter.dmm"

/datum/map_template/ruin/lavaland/biodome/winter/inn
	name = "Biodome Inn"
	id = "biodome-inn"
	description = "After spending years in a desolate ice planet, the legendary innkeeper managed to get enough cash to put his inn into a biodome and get out of there. \
	Unfortunately, instead of going to Earth, the dome misfired and landed on another desolate wasteland instead."
	suffix = "lavaland_surface_biodome_winter_inn"

/datum/map_template/ruin/lavaland/biodome/clown
	name = "Biodome Clown Planet"
	id = "biodome-clown"
	description = "WELCOME TO CLOWN PLANET! HONK HONK HONK etc.!"
	suffix = "lavaland_biodome_clown_planet.dmm"

/datum/map_template/ruin/lavaland/cube
	name = "The Wishgranter Cube"
	id = "wishgranter-cube"
	description = "Nothing good can come from this. Learn from their mistakes and turn around."
	suffix = "lavaland_surface_cube.dmm"
	cost = 10
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/seed_vault
	name = "Seed Vault"
	id = "seed-vault"
	description = "The creators of these vaults were a highly advanced and benevolent race, and launched many into the stars, hoping to aid fledgling civilizations. \
	However, all the inhabitants seem to do is grow drugs and guns."
	suffix = "lavaland_surface_seed_vault.dmm"
	cost = 10
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/ash_walker
	name = "Ash Walker Nest"
	id = "ash-walker"
	description = "A race of unbreathing lizards live here, that run faster than a human can, worship a broken dead city, and are capable of reproducing by something involving tentacles? \
	Probably best to stay clear."
	suffix = "lavaland_surface_ash_walker1.dmm"
	cost = 20
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/syndicate_base
	name = "Syndicate Lava Base"
	id = "lava-base"
	description = "A secret base researching illegal bioweapons, it is closely guarded by an elite team of syndicate agents."
	suffix = "lavaland_surface_syndicate_base1.dmm"
	cost = 20
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/free_golem
	name = "Free Golem Ship"
	id = "golem-ship"
	description = "Lumbering humanoids, made out of precious metals, move inside this ship. They frequently leave to mine more minerals, which they somehow turn into more of them. \
	Seem very intent on research and individual liberty, and also geology based naming?"
	cost = 20
	suffix = "lavaland_surface_golem_ship.dmm"
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/animal_hospital
	name = "Animal Hospital"
	id = "animal-hospital"
	description = "Rats with cancer do not live very long. And the ones that wake up from cryostasis seem to commit suicide out of boredom."
	cost = 5
	suffix = "lavaland_surface_animal_hospital.dmm"
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/sin
	cost = 10
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/sin/envy
	name = "Ruin of Envy"
	id = "envy"
	description = "When you get what they have, then you'll finally be happy."
	suffix = "lavaland_surface_envy.dmm"

/datum/map_template/ruin/lavaland/sin/gluttony
	name = "Ruin of Gluttony"
	id = "gluttony"
	description = "If you eat enough, then eating will be all that you do."
	suffix = "lavaland_surface_gluttony.dmm"

/datum/map_template/ruin/lavaland/sin/greed
	name = "Ruin of Greed"
	id = "greed"
	description = "Sure you don't need magical powers, but you WANT them, and \
		that's what's important."
	suffix = "lavaland_surface_greed.dmm"

/datum/map_template/ruin/lavaland/sin/pride
	name = "Ruin of Pride"
	id = "pride"
	description = "Wormhole lifebelts are for LOSERS, whom you are better than."
	suffix = "lavaland_surface_pride.dmm"

/datum/map_template/ruin/lavaland/sin/sloth
	name = "Ruin of Sloth"
	id = "sloth"
	description = "..."
	suffix = "lavaland_surface_sloth.dmm"
	// Generates nothing but atmos runtimes and salt
	cost = 0

/datum/map_template/ruin/lavaland/ratvar
	name = "Dead God"
	id = "ratvar"
	description = "Ratvar's final resting place."
	suffix = "lavaland_surface_dead_ratvar.dmm"
	cost = 0
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/hierophant
	name = "Hierophant's Arena"
	id = "hierophant"
	description = "A strange, square chunk of metal of massive size. Inside awaits only death and many, many squares."
	suffix = "lavaland_surface_hierophant.dmm"
	always_place = TRUE
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/blood_drunk_miner
	name = "Blood-Drunk Miner"
	id = "blooddrunk"
	description = "A strange arrangement of stone tiles and an insane, beastly miner contemplating them."
	suffix = "lavaland_surface_blooddrunk1.dmm"
	cost = 0
	allow_duplicates = FALSE //will only spawn one variant of the ruin

/datum/map_template/ruin/lavaland/blood_drunk_miner/guidance
	name = "Blood-Drunk Miner (Guidance)"
	suffix = "lavaland_surface_blooddrunk2.dmm"

/datum/map_template/ruin/lavaland/blood_drunk_miner/hunter
	name = "Blood-Drunk Miner (Hunter)"
	suffix = "lavaland_surface_blooddrunk3.dmm"

/datum/map_template/ruin/lavaland/ufo_crash
	name = "UFO Crash"
	id = "ufo-crash"
	description = "Turns out that keeping your abductees unconscious is really important. Who knew?"
	suffix = "lavaland_surface_ufo_crash.dmm"
	cost = 5

/datum/map_template/ruin/lavaland/xeno_nest
	name = "Xenomorph Nest"
	id = "xeno-nest"
	description = "These xenomorphs got bored of horrifically slaughtering people on space stations, and have settled down on a nice lava filled hellscape to focus on what's really important in life. \
	Quality memes."
	suffix = "lavaland_surface_xeno_nest.dmm"
	cost = 20

/datum/map_template/ruin/lavaland/fountain
	name = "Fountain Hall"
	id = "fountain"
	description = "The fountain has a warning on the side. DANGER: May have undeclared side effects that only become obvious when implemented."
	suffix = "lavaland_surface_fountain_hall.dmm"
	cost = 5

/datum/map_template/ruin/lavaland/survivalcapsule
	name = "Survival Capsule Ruins"
	id = "survivalcapsule"
	description = "What was once sanctuary to the common miner, is now their tomb."
	suffix = "lavaland_surface_survivalpod.dmm"
	cost = 5

/datum/map_template/ruin/lavaland/pizza
	name = "Ruined Pizza Party"
	id = "pizza"
	description = "Little Timmy's birthday pizza bash took a turn for the worse when a bluespace anomaly passed by."
	suffix = "lavaland_surface_pizzaparty.dmm"
	allow_duplicates = FALSE
	cost = 5

/datum/map_template/ruin/lavaland/cultaltar
	name = "Summoning Ritual"
	id = "cultaltar"
	description = "A place of vile worship, the scrawling of blood in the middle glowing eerily. A demonic laugh echoes throughout the caverns."
	suffix = "lavaland_surface_cultaltar.dmm"
	allow_duplicates = FALSE
	cost = 10

/datum/map_template/ruin/lavaland/hermit
	name = "Makeshift Shelter"
	id = "hermitcave"
	description = "A place of shelter for a lone hermit, scraping by to live another day."
	suffix = "lavaland_surface_hermit.dmm"
	allow_duplicates = FALSE
	cost = 10

/datum/map_template/ruin/lavaland/swarmer_boss
	name = "Crashed Shuttle"
	id = "swarmerboss"
	description = "A Syndicate shuttle had an unfortunate stowaway..."
	suffix = "lavaland_surface_swarmer_crash.dmm"
	allow_duplicates = FALSE
	cost = 20

/datum/map_template/ruin/lavaland/miningripley
	name = "Ripley"
	id = "ripley"
	description = "A heavily-damaged mining ripley, property of a very unfortunate miner. You might have to do a bit of work to fix this thing up."
	suffix = "lavaland_surface_random_ripley.dmm"
	allow_duplicates = FALSE
	cost = 5

/datum/map_template/ruin/lavaland/puzzle
	name = "Ancient Puzzle"
	id = "puzzle"
	description = "Mystery to be solved."
	suffix = "lavaland_surface_puzzle.dmm"
	cost = 5

/datum/map_template/ruin/lavaland/worldanvil //Plasma magmite upgrading area... always place.
	name = "World Anvil"
	id = "worldanvil"
	description = "An ancient anvil, standing untainted for millennia. Wonders were once forged here."
	suffix = "lavaland_surface_worldanvil.dmm"
	always_place = TRUE
	unpickable = TRUE
	cost = 0

/datum/map_template/ruin/lavaland/miningbase //THIS IS THE MINING BASE. DO NOT FUCK WITH THIS UNLESS YOU ARE 100% CERTAIN YOU KNOW WHAT YOU'RE DOING, OR THE MINING BASE WILL DISAPPEAR
	name = "Mining Base"
	id = "miningbase"
	description = "The mining base that Nanotrasen uses for their mining operations."
	suffix = "miningbase.dmm"
	always_place = TRUE
	unpickable = TRUE
	cost = 0



/datum/map_template/ruin/lavaland/toyshop
	name = "Toy Shop"
	id = "toyshop"
	description = "A shop that has the entire collection of Nanotrasen brand action figures!"
	suffix = "lavaland_surface_cursedtoyshop.dmm"
	cost = 10
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/clownfacility
	name = "Clown Facility"
	id = "clownfacility"
	description = "They went searching for madness, instead it found them."
	suffix = "lavaland_surface_clownfacility.dmm"
	cost = 10
	allow_duplicates = FALSE

/*/datum/map_template/ruin/lavaland/mimingdrill
	name = "Miming Drill"
	id = "mimingdrill"
	description = "A silent mining operation, its workers died as they lived."
	suffix = "lavaland_surface_mimingdrill.dmm"
	cost = 5
	allow_duplicates = FALSE*/

/datum/map_template/ruin/lavaland/cugganscove
	name = "Cuggans Cove"
	id = "cugganscove"
	description = "BEHOLD THE TERRIFYING LAIR OF THE INFAMOUS CAPTAIN CUGGAN!"
	suffix = "lavaland_surface_cugganscove.dmm"
	cost = 10
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/russianbunker
	name = "Russian Bunker"
	id = "russianbunker"
	description = "A russian bunker containing high technology, its abandoned but its security systems are still functional"
	suffix = "lavaland_surface_russianbunker.dmm"
	cost = 5
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/wizardden
	name = "Wizard Den"
	id = "wizardden"
	description = "Only Malarky The Mad would be mad enough to live in a wooden shack on this planet"
	suffix = "lavaland_surface_wizardden.dmm"
	cost = 15
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/watcherspiral
	name = "Watcher Spiral"
	id = "watcherspiral"
	description = "These watchers were left here to guard some ancient artifact"
	suffix = "lavaland_surface_watcherspiral.dmm"
	cost = 5
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/weavernest
	name = "Weaver Nest"
	id = "weavernest"
	description = "An eerie cavern full of deadly Marrow Weavers and the corpses of their victims"
	suffix = "lavaland_surface_weavernest.dmm"
	cost = 5
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/goliathmound
	name = "Goliath Mound"
	id = "goliathmound"
	description = "More tentacles than one of my japanese animes"
	suffix = "lavaland_surface_goliathmound.dmm"
	cost = 5
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/I
	name = "Necromancer Tower"
	id = "I"
	description = "It contains the secrets of life and death"
	suffix = "lavaland_surface_I.dmm"
	cost = 5
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/legionbarracks
	name = "Legion Barracks"
	id = "legionbarracks"
	description = "Once a structure containing stalwart soldiers, it now contains their lost souls"
	suffix = "lavaland_surface_legionbarracks.dmm"
	cost = 5
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/cultritual
	name = "Cult Ritual"
	id = "cultritual"
	description = "A group of mortal cultist nerds sacrifice their souls to become one with the realm of medieval fantasy and fiction causing a tear in the fabric of reality."
	suffix = "lavaland_surface_cultritual.dmm"
	cost = 10
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/ntsurveyor
	name = "Nanotrasen Surveyor"
	id = "ntsurveyo"
	description = "The most tragic part about it all is the ship didnt even have any donuts"
	suffix = "lavaland_surface_ntsurveyor.dmm"
	cost = 5
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/researchoutpost
	name = "Research Outpost"
	id = "researchoutpost"
	description = "While mystery enshrouds as to why this place is here, the real question is should you wear the carp hardsuit..or the engineering one?"
	suffix = "lavaland_surface_researchoutpost.dmm"
	cost = 5
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/syndicatepod
	name = "Syndicate Pod"
	id = "syndicatepod"
	description = "The Syndicate would pay handsomely for its contents"
	suffix = "lavaland_surface_syndicatepod.dmm"
	cost = 5
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/prisoners
	name = "Prisoner Crash"
	id = "prisoner-crash"
	description = "This incredibly high security shuttle clearly didn't have \
		'avoiding lavafilled hellscapes' as a design priority. As such, it \
		has crashed, waking the prisoners from their cryostasis, and setting \
		them loose on the wastes. If they live long enough, that is."
	suffix = "lavaland_surface_prisoner_crash.dmm"
	cost = 15
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/cosmicashwalkerpod
	name = "Cosmic Ashwalker Pod"
	id = "cosmicashwalkerpod"
	description = "A escape pod that branched off from a crashing abductor terror ship. The fate of the main vessel is unknown but most of the crew should of escaped. Although maybe containing your experiments in escape pod capsules was a bad idea in hindsight..."
	suffix = "lavaland_surface_cosmicashwalkerpod.dmm"
	allow_duplicates = FALSE
	cost = 15
	unpickable = TRUE //council-vote

/datum/map_template/ruin/lavaland/medical
	name = "Orion Medical Outpost"
	id = "medical"
	description = "One of the Orion Medical Outposts was teleported after a bluespace anomaly"
	suffix = "lavaland_surface_medical.dmm"
	allow_duplicates = FALSE
	cost = 15

/datum/map_template/ruin/lavaland/travellingbard
	name = "Travelling Bard"
	id = "travellingbard"
	description = "A travelling space bard who only wishes to tell tales of adventure and play catchy songs"
	suffix = "lavaland_surface_travellingbard.dmm"
	allow_duplicates = FALSE
	cost = 5

/datum/map_template/ruin/lavaland/chemistry
	name= "Abandoned Chemistry Lab"
	id = "chemistry"
	description = "A seemingly innocent-looking lab, with an assault pod outside..."
	suffix = "lavaland_surface_chemistry.dmm"
	allow_duplicates = FALSE
	cost = 10

/datum/map_template/ruin/lavaland/scp_facility
	name = "Anomalous Object Site"
	id = "scp_facility"
	description = "An abandoned storage site for dangerous and paranormal objects and creatures."
	suffix = "lavaland_surface_scp_facility.dmm"
	allow_duplicates = FALSE
	cost = 20

/datum/map_template/ruin/lavaland/cafe_of_broken_dreams
	name = "Cafe of Broken Dreams"
	id = "cafe-of-broken-dreams"
	description = "Nothing's better the sweet taste of coffee in such an apocalyptic world. The only catch is that there isn't any coffee. But there's lots of fauna. "
	suffix = "lavaland_surface_cafe_of_broken_dreams.dmm"
	allow_duplicates = FALSE
	cost = 10

/datum/map_template/ruin/lavaland/gas_station
	name = "Gas Station"
	id = "gas-station"
	description = "An old gas station that's somehow managed to survive in the deteriorating hellscape of lavaland. If you've managed to find it than you've lucked out assuming the mad man running it is willing to sell his goods of course."
	suffix = "lavaland_surface_gas_station.dmm"
	allow_duplicates = FALSE
	cost = 10

/datum/map_template/ruin/lavaland/king_goat_boss
	name = "King Goat Boss Ruin"
	id = "kinggoatboss"
	description = "Abandon All Hope Ye Who Enter Here."
	suffix = "lavaland_surface_kinggoatboss.dmm"
	always_place = TRUE // This is just the lavaland part, king_goat_arena in /code/datums/ruins/space.dm needs to have this set to true aswell for goat king to actually appear
	allow_duplicates = FALSE

/datum/map_template/ruin/lavaland/elite_tumor
	name = "Pulsating Tumor"
	id = "tumor"
	description = "A strange tumor which houses a powerful beast..."
	suffix = "lavaland_surface_elite_tumor.dmm"
	cost = 5
	always_place = TRUE
	allow_duplicates = TRUE

/datum/map_template/ruin/lavaland/doorstuck
	name = "Door Stuck"
	id = "doorstuck"
	description = "A sad tale of inability to move on."
	suffix = "lavaland_surface_doorstuck.dmm"
	allow_duplicates = FALSE
	cost = 5

/datum/map_template/ruin/lavaland/shinobigraveyard
	name = "Shinobi Graveyard"
	id = "shinobigraveyard"
	description = "The space ninjas left a grave of someone powerful."
	suffix = "lavaland_surface_shinobigraveyard.dmm"
	allow_duplicates = FALSE
	cost = 5

/datum/map_template/ruin/lavaland/lavaland_surface_meteorite
	name = "Ash Walker Meteorite"
	id = "meteorite"
	description = "A village bestowed with immense misfortune."
	suffix = "lavaland_surface_meteorite.dmm"
	allow_duplicates = FALSE
	cost = 20
