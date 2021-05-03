/*
Crystalized extracts:
	Creates a crystal structure that
	grants the room it's in	unique properties
	when activated in-hand.
*/

/obj/item/slimecross/crystalized
	name = "crystalized extract"
	desc = "It's crystalline,"
	effect = "crystalline"
	icon_state = "crystalline"
	var/obj/structure/slime_crystal/crystal_type


/obj/item/slimecross/crystalized/attack_self(mob/user)
	. = ..()
	var/obj/structure/slime_crystal/C = locate() in range(6,get_turf(user))
	if(C)
		to_chat(user,"<span class='notice'>You can't build crystals that close to each other!</span>")
		return
	var/user_turf = get_turf(user)
	if(!do_after(user,15 SECONDS,FALSE,user_turf))
		return
	new crystal_type(user_turf)
	qdel(src)

/obj/item/slimecross/crystalized/grey
	crystal_type = /obj/structure/slime_crystal/grey
	colour = "grey"
	effect_desc = "Slowly feeds all slimes in the area. Effect is blocked by walls."

/obj/item/slimecross/crystalized/orange
	crystal_type = /obj/structure/slime_crystal/orange
	colour = "orange"
	effect_desc = "Ignites anyone in range of the crystal and heats the surrounding air. Effect is blocked by walls."

/obj/item/slimecross/crystalized/purple
	crystal_type = /obj/structure/slime_crystal/purple
	colour = "purple"
	effect_desc = "Slowly heals organic humans and creatures in range of all types of damage."

/obj/item/slimecross/crystalized/blue
	crystal_type = /obj/structure/slime_crystal/blue
	colour = "blue"
	effect_desc = "Stabilizes air around crystal to the standard O2/N2 mixture, and stabilizes it room temperature. Effect is blocked by walls. "

/obj/item/slimecross/crystalized/metal
	crystal_type = /obj/structure/slime_crystal/metal
	colour = "metal"
	effect_desc = "Slowly heals cyborgs in range."

/obj/item/slimecross/crystalized/yellow
	crystal_type = /obj/structure/slime_crystal/yellow
	colour = "yellow"
	effect_desc = "When struck by a cell, the cell will be instantly charged. Fully charged cells will explode when striking it."

/obj/item/slimecross/crystalized/darkpurple
	crystal_type = /obj/structure/slime_crystal/darkpurple
	colour = "dark purple"
	effect_desc = "Consumes plasma in the air, converting it into plasma sheets. Crystal releases and ignites a small amount of plasma when destroyed."

/obj/item/slimecross/crystalized/darkblue
	crystal_type = /obj/structure/slime_crystal/darkblue
	colour = "dark blue"
	effect_desc = "Cleans and dries tiles in the area."

/obj/item/slimecross/crystalized/silver
	crystal_type = /obj/structure/slime_crystal/silver
	colour = "silver"
	effect_desc = "Plants grow slightly faster in the area and prevents weeds and pests from growing at all."

/obj/item/slimecross/crystalized/bluespace
	crystal_type = /obj/structure/slime_crystal/bluespace
	colour = "bluespace"
	effect_desc = "Acts as a beacon to other crystals of this type. Click with an empty hand to teleport between them."

/obj/item/slimecross/crystalized/sepia
	crystal_type = /obj/structure/slime_crystal/sepia
	colour = "sepia"
	effect_desc = "Everything in the area is put in stasis as if on a stasis bed. Does not stun you like a stasis bed."

/obj/item/slimecross/crystalized/cerulean
	crystal_type = /obj/structure/slime_crystal/cerulean
	colour = "cerulean"
	effect_desc = "Adjacent tiles will gradually grow slime crystals. These slime crystals, when harvested, may be combined with any material sheet to increase its stack size by 5."

/obj/item/slimecross/crystalized/pyrite
	crystal_type = /obj/structure/slime_crystal/pyrite
	colour = "pyrite"
	effect_desc = "Causes floor tiles to be randomly colored within the area. Perfect for parties!"

/obj/item/slimecross/crystalized/red
	crystal_type = /obj/structure/slime_crystal/red
	colour = "red"
	effect_desc = "Crystal cleans blood from the ground in a wide area and may store up to 300u of gathered blood. Touching the crystal will consume some blood and create a piece of meat or a random basic, functional organ. Containers may also be used on the crystal to transfer blood directly out of it."

/obj/item/slimecross/crystalized/green
	crystal_type = /obj/structure/slime_crystal/green
	colour = "green"
	effect_desc = "Crystal stores one random mutation from the last player who interacted with it (starts with none). People standing within the effect radius are gradually cured of mutations but will be forcefully given the mutation stored in the crystal."

/obj/item/slimecross/crystalized/pink
	crystal_type = /obj/structure/slime_crystal/pink
	colour = "pink"
	effect_desc = "Everyone within the area is pacified. Violence is not the answer."

/obj/item/slimecross/crystalized/gold
	crystal_type = /obj/structure/slime_crystal/gold
	colour = "gold"
	effect_desc = "Touch the crystal to be transformed into a random pet. Effects are undone when leaving the area."

/obj/item/slimecross/crystalized/oil
	crystal_type = /obj/structure/slime_crystal/oil
	colour = "oil"
	effect_desc = "Covers nearby tiles with very slippery lube."

/obj/item/slimecross/crystalized/black
	crystal_type = /obj/structure/slime_crystal/black
	colour = "black"
	effect_desc = "People standing near the crystal will begin slowly transforming into a random slimeperson. Has no effect on slimepeople."

/obj/item/slimecross/crystalized/lightpink
	crystal_type = /obj/structure/slime_crystal/lightpink
	colour = "light pink"
	effect_desc = "Crystal converts lost souls into harmless, healing lightgheists that disappear when too far away from the crystal."

/obj/item/slimecross/crystalized/adamantine
	crystal_type = /obj/structure/slime_crystal/adamantine
	colour = "adamantine"
	effect_desc = "Makes everyone slightly more resistant in an area around it."

/obj/item/slimecross/crystalized/rainbow
	crystal_type = /obj/structure/slime_crystal/rainbow
	colour = "rainbow"
	effect_desc = "Does nothing on its own but will accept crystalized extracts to begin emitting the same effect as the consumed extract, allowing for multiple different effects in the same space."
