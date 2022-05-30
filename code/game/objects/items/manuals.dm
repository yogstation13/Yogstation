/*********************MANUALS (BOOKS)***********************/

//Oh god what the fuck I am not good at computer
/obj/item/book/manual
	icon = 'icons/obj/library.dmi'
	w_class = WEIGHT_CLASS_SMALL
	due_date = 0 // Game time in 1/10th seconds
	unique = TRUE   // FALSE - Normal book, TRUE - Should not be treated as normal book, unable to be copied, unable to be modified

/obj/item/book/manual/ripley_build_and_repair
	name = "APLU \"Ripley\" Construction and Operation Manual"
	icon_state ="book"
	author = "Weyland-Yutani Corp"
	title = "APLU \"Ripley\" Construction and Operation Manual"
	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>
				<center>
				<b style='font-size: 12px;'>Weyland-Yutani - Building Better Worlds</b>
				<h1>Autonomous Power Loader Unit \"Ripley\"</h1>
				</center>
				<h2>Specifications:</h2>
				<ul>
				<li><b>Class:</b> Autonomous Power Loader</li>
				<li><b>Scope:</b> Logistics and Construction</li>
				<li><b>Weight:</b> 820kg (without operator and with empty cargo compartment)</li>
				<li><b>Height:</b> 2.5m</li>
				<li><b>Width:</b> 1.8m</li>
				<li><b>Top speed:</b> 5km/hour</li>
				<li><b>Operation in vacuum/hostile environment:</b> Possible</b>
				<li><b>Airtank Volume:</b> 500liters</li>
				<li><b>Devices:</b>
					<ul>
					<li>Hydraulic Clamp</li>
					<li>High-speed Drill</li>
					</ul>
				</li>
				<li><b>Propulsion Device:</b> Powercell-powered electro-hydraulic system.</li>
				<li><b>Powercell capacity:</b> Varies.</li>
				</ul>

				<h2>Construction:</h2>
				<ol>
				<li>Connect all exosuit parts to the chassis frame</li>
				<li>Connect all hydraulic fittings and tighten them up with a wrench</li>
				<li>Adjust the servohydraulics with a screwdriver</li>
				<li>Wire the chassis. (Cable is not included.)</li>
				<li>Use the wirecutters to remove the excess cable if needed.</li>
				<li>Install the central control module (Not included. Use supplied datadisk to create one).</li>
				<li>Secure the mainboard with a screwdriver.</li>
				<li>Install the peripherals control module (Not included. Use supplied datadisk to create one).</li>
				<li>Secure the peripherals control module with a screwdriver</li>
				<li>Install the internal armor plating (Not included due to Nanotrasen regulations. Can be made using 5 metal sheets.)</li>
				<li>Secure the internal armor plating with a wrench</li>
				<li>Weld the internal armor plating to the chassis</li>
				<li>Install the external reinforced armor plating (Not included due to Nanotrasen regulations. Can be made using 5 reinforced metal sheets.)</li>
				<li>Secure the external reinforced armor plating with a wrench</li>
				<li>Weld the external reinforced armor plating to the chassis</li>
				<li></li>
				<li>Additional Information:</li>
				<li>The firefighting variation is made in a similar fashion.</li>
				<li>A firesuit must be connected to the Firefighter chassis for heat shielding.</li>
				<li>Internal armor is plasteel for additional strength.</li>
				<li>External armor must be installed in 2 parts, totaling 10 sheets.</li>
				<li>Completed mech is more resiliant against fire, and is a bit more durable overall</li>
				<li>Nanotrasen is determined to the safety of its <s>investments</s> employees.</li>
				</ol>
				</body>
				</html>

				<h2>Operation</h2>
				Please consult the Nanotrasen compendium "Robotics for Dummies".
			"}

/obj/item/book/manual/chef_recipes
	name = "Chef Recipes"
	icon_state = "cooked_book"
	author = "Lord Frenrir Cageth"
	title = "Chef Recipes"
	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>

				<h1>Food for Dummies</h1>
				Here is a guide on basic food recipes and also how to not poison your customers accidentally.


				<h2>Basic ingredients preparation:</h2>

				<b>Dough:</b> 10u water + 15u flour for simple dough.<br>
				15u egg yolk + 15u flour + 5u sugar for cake batter.<br>
				Doughs can be transformed by using a knife and rolling pin.<br>
				All doughs can be microwaved.<br>
				<b>Bowl:</b> Add water to it for soup preparation.<br>
				<b>Meat:</b> Microwave it, process it, slice it into microwavable cutlets with your knife, or use it raw.<br>
				<b>Cheese:</b> Add 5u universal enzyme (catalyst) to milk and soy milk to prepare cheese (sliceable) and tofu.<br>
				<b>Rice:</b> Mix 10u rice with 10u water in a bowl then microwave it.

				<h2>Custom food:</h2>
				Add ingredients to a base item to prepare a custom meal.<br>
				The bases are:<br>
				- bun (burger)<br>
				- breadslices(sandwich)<br>
				- plain bread<br>
				- plain pie<br>
				- vanilla cake<br>
				- empty bowl (salad)<br>
				- bowl with 10u water (soup)<br>
				- boiled spaghetti<br>
				- pizza bread<br>
				- metal rod (kebab)

				<h2>Table Craft:</h2>
				Put ingredients on table, then click and drag the table onto yourself to see what recipes you can prepare.

				<h2>Microwave:</h2>
				Use it to cook or boil food ingredients (meats, doughs, egg, spaghetti, donkpocket, etc...).
				It can cook multiple items at once.

				<h2>Processor:</h2>
				Use it to process certain ingredients (meat into meatball, doughslice into spaghetti, potato into fries,etc...)

				<h2>Gibber:</h2>
				Stuff an animal in it to grind it into meat.

				<h2>Meat spike:</h2>
				Stick an animal on it then begin collecting its meat.


				<h2>Example recipes:</h2>
				<b>Vanilla Cake</b>: Microwave cake batter.<br>
				<b>Burger:</b> 1 bun + 1 meat steak<br>
				<b>Bread:</b> Microwave dough.<br>
				<b>Waffles:</b> 2 pastry base<br>
				<b>Popcorn:</b> Microwave corn.<br>
				<b>Meat Steak:</b> Microwave meat.<br>
				<b>Meat Pie:</b> 1 plain pie + 1u black pepper + 1u salt + 2 meat cutlets<br>
				<b>Boiled Spagetti:</b> Microwave spaghetti.<br>
				<b>Donuts:</b> 1u sugar + 1 pastry base<br>
				<b>Fries:</b> Process potato.

				<h2>Sharing your food:</h2>
				You can put your meals on your kitchen counter or load them in the snack vending machines.
				</body>
				</html>
			"}

/obj/item/book/manual/ashwalker
	name = "Tome of Herbal Knowledge"
	icon_state = "book1"
	author = "Ma'sha Alazee the Shaman"
	title = "Tome of Herbal Knowledge"
	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>

				<h1>Ancient Ashwalker Recipes</h1>
				I pass down my knowledge to my kin, all that I know shall forever be preserved in this book.
				Inside, I shall teach you various important healing recipes and crafting techniques.


				<h2>Poultice:</h2>

				To prepare, first gather mushroom stems, cacti or porcini leaves, ashes from a burnt item, and a heat source such as a welder/lit candle.
				Next, mash together 4 mushroom stems and 3 cacti fruit.
				Porcini can be used instead of cacti fruit, but due to having less concentration it may be harder to fit enough leaves required to make the product.
				Afterwards, scoop up ashes with the mortar. If the ashes are warm enough, it may mix without extra heat needed.
				If it has yet to mix, heat up the bowl by using the welder on it until it has done so.
				Apply product to wounded parts to heal them. May cause loss of breath.

				<h2>Bone Gel:</h2>

				To prepare, first mash up either 3 of any plant or 1 polypore mushroom shaving.
				Next, milk a gutlunch, one of which should be near the tendril.
				Afterwards, once enough honey is gathered, mix the two together and heat.
				Once heated enough it will solidify into a usable product.
				Apply product to broken bones in order to mend them.

				<h2>Capmix:</h2>

				To prepare, first gather a mushroom cap, ashes from a burnt item, and a heat source such as a welder/lit candle.
				Next, mash together one mushroom cap.
				Afterwards, scoop up ashes with the mortar. If the ashes are warm enough, it may mix without extra heat needed.
				If it has yet to mix, heat up the bowl by using the welder on it until it has done so.
				Consume in moderation in order to detox the body. Note, this may induce vomiting.

				<h2>Resin:</h2>

				All the plants here contain a small amount of resin, likely to deter consumption of them, or perhaps to retain water.
				Either way, it is known to cause belly aches and toxicity within our bodies when consumed in large amounts.
				However there is several methods for avoiding this:
				Consuming plants in small quantities, or not consuming them at all.
				Mashing the plants up and adding water to the bowl to solidify and remove most of the resin.
				Ingesting capmix in order to expel the resin.

				Resin is also useful for ensuring things stick together, and is a stronger binder than watcher sinew.
				To use it for this purpose you'll have to solidify it by adding water.

				<h2>Mushroom Paste:</h2>

				To prepare, first gather mushroom stems, cacti or porcini leaves, and a bowl of gutlunch honey/milk.
				Next, mash together a stem and a cacti fruit/porcini leaf within a mortar with the help of a pestle.
				Afterwards, the mix should congeal into a odorous paste.
				This paste can then be applied to crops in order to fertilize them to nurtur and stabilize them.

				<h2>Bug Cheese:</h2>

				A recipe passed down from generation to generation, far before we even discovered the healing properties of mushrooms and such.
				Although I am not an avid chef, I found it important to ensure the knowledge of making this is never lost either.
				Creating this delicious food is rather easy.
				All you must do is use a mortar and pestle to crush a cacti fruit or porcini leaf and then mix it with gutlunch honey.
				The resulting creation is a ball of healthy bug cheese, ready to eat.

				<h2>Flora:</h2>

				Every plant we are blessed with can be used in some way. 
				All are not dangerous when consumed in moderation, save for mushroom caps.
				All may be fermented and brewed into substances that induce a woozy and feel-good high.
				Cacti fruit is rich in juices that will nurtur and heal your body.
				Polypore shavings are tough and can be used for crafts such as bowls and wood substitute, and contain a higher than average resin content.
				Porcini leaves contain a similar content to cacti fruit along with a substance that increases brain focus.
				Inocybe caps contain deadly toxins in their raw state, but with ash and heat can be neutralized to instead detox the body.
				Embershroom stems contain a bioluminescient substance that manages to even light up the body when consumed.

				<h2>Leather:</h2>

				Leather does not need to be interacted with much as a shaman,
				especially if you are prioritizing medicine.
				However, it can still be useful to know how to make it,
				Especially since you can use it, or cloth, to create a medicinal pouch useful for holding plants and medicines.
				To create it, acquire some hide, the most available of which will be goliath hide.
				Next, skin it well with a sharp tool.
				Afterwards, wash with water thoroughly, and then dry by placing it over a grill atop a lit bonfire.
				</body>
				</html>
			"}

/obj/item/book/manual/nuclear
	name = "Fission Mailed: Nuclear Sabotage 101"
	icon_state ="bookNuclear"
	author = "Syndicate"
	title = "Fission Mailed: Nuclear Sabotage 101"
	dat = {"<html>
			Nuclear Explosives 101:<br>
			Hello and thank you for choosing the Syndicate for your nuclear information needs.<br>
			Today's crash course will deal with the operation of a Fusion Class Nanotrasen made Nuclear Device.<br>
			First and foremost, DO NOT TOUCH ANYTHING UNTIL THE BOMB IS IN PLACE.<br>
			Pressing any button on the compacted bomb will cause it to extend and bolt itself into place.<br>
			If this is done to unbolt it one must completely log in which at this time may not be possible.<br>
			To make the nuclear device functional:<br>
			<li>Place the nuclear device in the designated detonation zone.</li>
			<li>Extend and anchor the nuclear device from its interface.</li>
			<li>Insert the nuclear authorisation disk into slot.</li>
			<li>Type numeric authorisation code into the keypad. This should have been provided. Note: If you make a mistake press R to reset the device.
			<li>Press the E button to log onto the device.</li>
			You now have activated the device. To deactivate the buttons at anytime for example when you've already prepped the bomb for detonation	remove the auth disk OR press the R on the keypad.<br>
			Now the bomb CAN ONLY be detonated using the timer. Manual detonation is not an option.<br>
			Note: Nanotrasen is a pain in the neck.<br>
			Toggle off the SAFETY.<br>
			Note: You wouldn't believe how many Syndicate Operatives with doctorates have forgotten this step.<br>
			So use the - - and + + to set a det time between 5 seconds and 10 minutes.<br>
			Then press the timer toggle button to start the countdown.<br>
			Now remove the auth. disk so that the buttons deactivate.<br>
			Note: THE BOMB IS STILL SET AND WILL DETONATE<br>
			Now before you remove the disk if you need to move the bomb you can:<br>
			Toggle off the anchor, move it, and re-anchor.<br><br>
			Good luck. Remember the order:<br>
			<b>Disk, Code, Safety, Timer, Disk, RUN!</b><br>
			Intelligence Analysts believe that normal Nanotrasen procedure is for the Captain to secure the nuclear authorisation disk.<br>
			Good luck!
			</html>"}

// Wiki books that are linked to the configured wiki link.

/obj/item/book/manual/wiki
	var/page_link = ""
	window_size = "970x710"

/obj/item/book/manual/wiki/attack_self()
	if(!dat)
		initialize_wikibook()
	return ..()

/obj/item/book/manual/wiki/proc/initialize_wikibook()
	var/wikiurl = CONFIG_GET(string/wikiurl)
	if(wikiurl)
		dat = {"
			<iframe
				id='ext_frame'
				src='[wikiurl]/frame.html'
				style='border: none; width: 100vw; height: 100vh;'>
			</iframe>
			<style>
			html, body {
				height: 100vh;
				width: 100vw;
				margin: 0;
				overflow: hidden;
			}
			body > :not(iframe) {
				display: none;
				}
			</style>
			<script>
				window.onmessage = function() {
					document.getElementById('ext_frame').contentWindow.postMessage('[page_link]', '*')
				}
			</script>
			"}

/obj/item/book/manual/wiki/chemistry
	name = "Chemistry Textbook"
	icon_state ="chemistrybook"
	author = "Nanotrasen"
	title = "Chemistry Textbook"
	page_link = "Guide_to_Chemistry"

/obj/item/book/manual/wiki/engineering_construction
	name = "Station Repairs and Construction"
	icon_state ="bookEngineering"
	author = "Engineering Encyclopedia"
	title = "Station Repairs and Construction"
	page_link = "Guide_to_Construction"

/obj/item/book/manual/wiki/engineering_guide
	name = "Engineering Textbook"
	icon_state ="bookEngineering2"
	author = "Engineering Encyclopedia"
	title = "Engineering Textbook"
	page_link = "Guide_to_Engineering"

/obj/item/book/manual/wiki/engineering_singulo_tesla
	name = "Singularity and Tesla for Dummies"
	icon_state ="bookEngineeringSingularitySafety"
	author = "Engineering Encyclopedia"
	title = "Singularity and Tesla for Dummies"
	page_link = "Singularity_and_Tesla_engines"

/obj/item/book/manual/wiki/security_space_law
	name = "Space Law"
	desc = "A set of Nanotrasen guidelines for keeping law and order on their space stations."
	icon_state = "bookSpaceLaw"
	author = "Nanotrasen"
	title = "Space Law"
	page_link = "Space_Law"

/obj/item/book/manual/wiki/security_space_law/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] pretends to read \the [src] intently... then promptly dies of laughter!"))
	return OXYLOSS

/obj/item/book/manual/wiki/infections
	name = "Infections - Making your own pandemic!"
	icon_state = "bookInfections"
	author = "Infections Encyclopedia"
	title = "Infections - Making your own pandemic!"
	page_link = "Infections"

/obj/item/book/manual/wiki/telescience
	name = "Teleportation Science - Bluespace for dummies!"
	icon_state = "book7"
	author = "University of Bluespace"
	title = "Teleportation Science - Bluespace for dummies!"
	page_link = "Guide_to_telescience"

/obj/item/book/manual/wiki/engineering_hacking
	name = "Hacking"
	icon_state ="bookHacking"
	author = "Engineering Encyclopedia"
	title = "Hacking"
	page_link = "Hacking"

/obj/item/book/manual/wiki/detective
	name = "The Film Noir: Proper Procedures for Investigations"
	icon_state ="bookDetective"
	author = "Nanotrasen"
	title = "The Film Noir: Proper Procedures for Investigations"
	page_link = "Detective"

/obj/item/book/manual/wiki/barman_recipes
	name = "Barman Recipes: Mixing Drinks and Changing Lives"
	icon_state = "barbook"
	author = "Sir John Rose"
	title = "Barman Recipes: Mixing Drinks and Changing Lives"
	page_link = "Guide_to_Drinks"

/obj/item/book/manual/wiki/hydroponicsguide
	name = "Botany: An Introduction"
	icon_state = "hydrobucket"
	author = "Farmer John"
	title = "Botany: An Introduction"
	page_link = "Guide_to_hydroponics"

/obj/item/book/manual/wiki/hydroponicsplants
	name = "Plants of the Galaxy"
	icon_state = "hydroplant"
	author = "Gose Jarcia"
	title = "Plants of the Galaxy"
	page_link = "Guide_to_plants"

/obj/item/book/manual/wiki/robotics_cyborgs
	name = "Robotics for Dummies"
	icon_state = "borgbook"
	author = "XISC"
	title = "Robotics for Dummies"
	page_link = "Guide_to_robotics"

/obj/item/book/manual/wiki/research_and_development
	name = "Research and Development 101"
	icon_state = "rdbook"
	author = "Dr. L. Ight"
	title = "Research and Development 101"
	page_link = "Guide_to_Research_and_Development"

/obj/item/book/manual/wiki/experimentor
	name = "Mentoring your Experiments"
	icon_state = "rdbook"
	author = "Dr. H.P. Kritz"
	title = "Mentoring your Experiments"
	page_link = "E.X.P.E.R.I-MENTOR"

/obj/item/book/manual/wiki/medical_cloning
	name = "Cloning techniques of the 26th century"
	icon_state ="bookCloning"
	author = "Medical Journal, volume 3"
	title = "Cloning techniques of the 26th century"
	page_link = "Guide_to_Genetics"

/obj/item/book/manual/wiki/medical_genetics
	name = "Genetics of the 26th century"
	icon_state ="bookCloning"
	author = "Dr. Likes-The-Powers "
	title = "Genetics of the 26th century"
	page_link = "Guide_to_Genetics"

/obj/item/book/manual/wiki/cooking_to_serve_man
	name = "To Serve Man"
	desc = "It's a cookbook!"
	icon_state ="cooked_book"
	author = "the Kanamitan Empire"
	title = "To Serve Man"
	page_link = "Guide_to_food"

/obj/item/book/manual/wiki/tcomms
	name = "Subspace Telecommunications And You"
	icon_state = "book3"
	author = "Engineering Encyclopedia"
	title = "Subspace Telecommunications And You"
	page_link = "Guide_to_Telecommunications"

/obj/item/book/manual/wiki/atmospherics
	name = "Lexica Atmosia"
	icon_state = "book5"
	author = "the City-state of Atmosia"
	title = "Lexica Atmosia"
	page_link = "Guide_to_Atmospherics"

/obj/item/book/manual/wiki/medicine
	name = "Medical Space Compendium, Volume 638"
	icon_state = "book8"
	author = "Medical Journal"
	title = "Medical Space Compendium, Volume 638"
	page_link = "Guide_to_medicine"

/obj/item/book/manual/wiki/surgery
	name = "Brain Surgery for Dummies"
	icon_state = "book4"
	author = "Dr. F. Fran"
	title = "Brain Surgery for Dummies"
	page_link = "Surgery"

/obj/item/book/manual/wiki/grenades
	name = "DIY Chemical Grenades"
	icon_state = "book2"
	author = "W. Powell"
	title = "DIY Chemical Grenades"
	page_link = "Grenade"

/obj/item/book/manual/wiki/toxins
	name = "Toxins or: How I Learned to Stop Worrying and Love the Maxcap"
	icon_state = "book6"
	author = "Cuban Pete"
	title = "Toxins or: How I Learned to Stop Worrying and Love the Maxcap"
	page_link = "Guide_to_toxins"

/obj/item/book/manual/wiki/toxins/suicide_act(mob/user)
	var/mob/living/carbon/human/H = user
	user.visible_message(span_suicide("[user] starts dancing to the Rhumba Beat! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(loc, 'sound/effects/spray.ogg', 10, 1, -3)
	if (!QDELETED(H))
		H.emote("spin")
		sleep(2 SECONDS)
		for(var/obj/item/W in H)
			H.dropItemToGround(W)
			if(prob(50))
				step(W, pick(GLOB.alldirs))
		ADD_TRAIT(H, TRAIT_DISFIGURED, TRAIT_GENERIC)
		for(var/i in H.bodyparts)
			var/obj/item/bodypart/BP = i
			BP.generic_bleedstacks += 5
		H.gib_animation()
		sleep(0.3 SECONDS)
		H.adjustBruteLoss(1000) //to make the body super-bloody
		H.spawn_gibs()
		H.spill_organs()
		H.spread_bodyparts()
	return (BRUTELOSS)

//YOGS start
/obj/item/book/manual/wiki/supermatter
	name = "Supermatter for Dummies"
	icon = 'yogstation/icons/obj/library.dmi'
	icon_state = "sm_book"
	author = "Engineering Encyclopedia"
	title = "Easy Guide to Setting up the Supermatter Engine"
	page_link = "Supermatter"
//YOGS end
