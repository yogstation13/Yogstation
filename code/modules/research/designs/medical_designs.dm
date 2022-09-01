/////////////////////////////////////////
////////////Medical Tools////////////////
/////////////////////////////////////////

/datum/design/mmi
	name = "Man-Machine Interface"
	desc = "The warrior's bland acronym, MMI, obscures the true horror of this monstrosity."
	id = "mmi"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500)
	construction_time = 75
	build_path = /obj/item/mmi
	category = list("Control Interfaces", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/posibrain
	name = "Positronic Brain"
	desc = "The latest in Artificial Intelligence."
	id = "mmi_posi"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 1700, /datum/material/glass = 1350, /datum/material/gold = 500) //Gold, because SWAG.
	construction_time = 75
	build_path = /obj/item/mmi/posibrain
	category = list("Control Interfaces", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/bluespacebeaker
	name = "Bluespace Beaker"
	desc = "A bluespace beaker, powered by experimental bluespace technology and Element Cuban combined with the Compound Pete. Can hold up to 300 units."
	id = "bluespacebeaker"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 5000, /datum/material/plasma = 3000, /datum/material/diamond = 1000, /datum/material/bluespace = 1000)
	build_path = /obj/item/reagent_containers/glass/beaker/bluespace
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/bluespacevial
	name = "Bluespace Vial"
	desc = "A small vial powered by experimental bluespace technology capable of holding 60 units."
	id = "bluespacevial"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 2500, /datum/material/plasma = 1500, /datum/material/diamond = 500, /datum/material/bluespace = 500)
	build_path = /obj/item/reagent_containers/glass/bottle/vial/bluespace
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/noreactbeaker
	name = "Cryostasis Beaker"
	desc = "A cryostasis beaker that allows for chemical storage without reactions. Can hold up to 50 units."
	id = "splitbeaker"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000)
	build_path = /obj/item/reagent_containers/glass/beaker/noreact
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/xlarge_beaker
	name = "X-large Beaker"
	id = "xlarge_beaker"
	build_type = PROTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
	materials = list(/datum/material/glass = 2500, /datum/material/plastic = 3000)
	build_path = /obj/item/reagent_containers/glass/beaker/plastic
	category = list("Medical Designs")

/datum/design/meta_beaker
	name = "Metamaterial Beaker"
	id = "meta_beaker"
	build_type = PROTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
	materials = list(/datum/material/glass = 2500, /datum/material/plastic = 3000, /datum/material/gold = 1000, /datum/material/titanium = 1000)
	build_path = /obj/item/reagent_containers/glass/beaker/meta
	category = list("Medical Designs")

/datum/design/bluespacesyringe
	name = "Bluespace Syringe"
	desc = "An advanced syringe that can hold 60 units of chemicals."
	id = "bluespacesyringe"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 2000, /datum/material/plasma = 1000, /datum/material/diamond = 1000, /datum/material/bluespace = 500)
	build_path = /obj/item/reagent_containers/syringe/bluespace
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/cloning_disk
	name = "Cloning Data Disk"
	desc = "Produce additional disks for storing genetic data."
	id = "cloning_disk"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 300, /datum/material/glass = 100, /datum/material/silver = 50)
	build_path = /obj/item/disk/data
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/noreactsyringe
	name = "Cryo Syringe"
	desc = "An advanced syringe that stops reagents inside from reacting. It can hold up to 20 units."
	id = "noreactsyringe"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 2000, /datum/material/gold = 1000)
	build_path = /obj/item/reagent_containers/syringe/noreact
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/piercesyringe
	name = "Piercing Syringe"
	desc = "A diamond-tipped syringe that pierces armor when launched at high velocity. It can hold up to 10 units."
	id = "piercesyringe"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 2000, /datum/material/diamond = 1000)
	build_path = /obj/item/reagent_containers/syringe/piercing
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/dartsyringe
	name = "Reagent Dart"
	desc = "A specialized syringe that quickly inject reagent. It can hold up to 15 units."
	id = "dartsyringe"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 2500)
	build_path = /obj/item/reagent_containers/syringe/dart
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/bluespacebodybag
	name = "Bluespace Body Bag"
	desc = "A bluespace body bag, powered by experimental bluespace technology. It can hold loads of bodies and the largest of creatures."
	id = "bluespacebodybag"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000, /datum/material/plasma = 2000, /datum/material/diamond = 500, /datum/material/bluespace = 500)
	build_path = /obj/item/bodybag/bluespace
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/plasmarefiller
	name = "Plasma-Man Jumpsuit Refill"
	desc = "A refill pack for the auto-extinguisher on Plasma-man suits."
	id = "plasmarefiller" //Why did this have no plasmatech
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/plasma = 1000)
	build_path = /obj/item/extinguisher_refill
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/pinpointer_crew
	name = "Crew Pinpointer"
	desc = "Allows tracking of someone's location if their suit sensors are turned to tracking beacon."
	id = "pinpointer_crew"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 1500, /datum/material/gold = 200)
	build_path = /obj/item/pinpointer/crew
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/defibrillator
	name = "Defibrillator"
	desc = "A portable defibrillator, used for resuscitating recently deceased crew."
	id = "defibrillator"
	build_type = PROTOLATHE
	build_path = /obj/item/defibrillator
	materials = list(/datum/material/iron = 8000, /datum/material/glass = 4000, /datum/material/silver = 3000, /datum/material/gold = 1500)
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/defibrillator_mount
	name = "Defibrillator Wall Mount"
	desc = "An all-in-one mounted frame for holding defibrillators, complete with ID-locked clamps and recharging cables."
	id = "defibmount"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000)
	build_path = /obj/item/wallframe/defib_mount
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/defibrillator_compact
	name = "Compact Defibrillator"
	desc = "A compact defibrillator that can be worn on a belt."
	id = "defibrillator_compact"
	build_type = PROTOLATHE
	build_path = /obj/item/defibrillator/compact
	materials = list(/datum/material/iron = 8000, /datum/material/glass = 8000, /datum/material/silver = 6000, /datum/material/gold = 3000, /datum/material/plastic = 8000)
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/genescanner
	name = "Genetic Sequence Analyzer"
	desc = "A handy hand-held analyzer for quickly determining mutations and collecting the full sequence."
	id = "genescanner"
	build_path = /obj/item/sequence_scanner
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500, /datum/material/plastic = 250)
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/healthanalyzer_advanced
	name = "Advanced Health Analyzer"
	desc = "A hand-held body scanner, able to distinguish vital signs of the subject with high accuracy."
	id = "healthanalyzer_advanced"
	build_path = /obj/item/healthanalyzer/advanced
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 2500, /datum/material/silver = 2000, /datum/material/gold = 1500, /datum/material/plastic = 1000)
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/medspray
	name = "Medical Spray"
	desc = "A medical spray bottle, designed for precision application, with an unscrewable cap."
	id = "medspray"
	build_path = /obj/item/reagent_containers/medspray
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2500, /datum/material/glass = 500)
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/surgical_mat
	name = "Surgical Mat"
	id = "surgical_mat"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 2000)
	build_path = /obj/item/surgical_mat
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/rollerbed
	name = "Roller Bed"
	desc = "A foldable rolling bed that can be carried around."
	id = "rollerbed"
	build_path = /obj/item/roller
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 8000)
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/laserscalpel
	name = "Laser Scalpel"
	desc = "A laser scalpel used for precise cutting."
	id = "laserscalpel"
	build_path = /obj/item/scalpel/advanced
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 6000, /datum/material/glass = 1500, /datum/material/silver = 2000, /datum/material/gold = 1500, /datum/material/diamond = 200, /datum/material/titanium = 4000)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/mechanicalpinches
	name = "Mechanical Pinches"
	desc = "These pinches can be used as a retractor or hemostat."
	id = "mechanicalpinches"
	build_path = /obj/item/retractor/advanced
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 12000, /datum/material/glass = 4000, /datum/material/silver = 4000, /datum/material/titanium = 5000)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/searingtool
	name = "Searing Tool"
	desc = "Used to mend tissue together."
	id = "searingtool"
	build_path = /obj/item/cautery/advanced
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 2000, /datum/material/plasma = 2000, /datum/material/uranium = 3000, /datum/material/titanium = 3000)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/hypospray
	name = "Hypospray"
	desc = "A sterile, air-needle autoinjector for rapid administration of drugs to patients."
	id = "hypospray"
	build_path = /obj/item/hypospray
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 2000, /datum/material/plastic = 1500, /datum/material/silver = 3000, /datum/material/titanium = 3000)
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL


/////////////////////////////////////////
////////////Regular Implants/////////////
/////////////////////////////////////////

/datum/design/implanter
	name = "Implanter"
	desc = "A sterile automatic implant injector."
	id = "implanter"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 600, /datum/material/glass = 200)
	build_path = /obj/item/implanter
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/implantcase
	name = "Implant Case"
	desc = "A glass case for containing an implant."
	id = "implantcase"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 500)
	build_path = /obj/item/implantcase
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/implant_sadtrombone
	name = "Sad Trombone Implant Case"
	desc = "Makes death amusing."
	id = "implant_trombone"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 500, /datum/material/bananium = 500)
	build_path = /obj/item/implantcase/sad_trombone
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ALL		//if you get bananium you get the sad trombones.

/datum/design/implant_chem
	name = "Chemical Implant Case"
	desc = "A glass case containing an implant."
	id = "implant_chem"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 700)
	build_path = /obj/item/implantcase/chem
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/implant_tracking
	name = "Tracking Implant Case"
	desc = "A glass case containing an implant."
	id = "implant_tracking"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/implantcase/tracking
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

//Cybernetic organs

/datum/design/cybernetic_liver
	name = "Cybernetic Liver"
	desc = "A cybernetic liver."
	id = "cybernetic_liver"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/organ/liver/cybernetic
	category = list("Cybernetics", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cybernetic_heart
	name = "Cybernetic Heart"
	desc = "A cybernetic heart."
	id = "cybernetic_heart"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/organ/heart/cybernetic
	category = list("Cybernetics", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cybernetic_lungs
	name = "Cybernetic Lungs"
	desc = "A pair of cybernetic lungs."
	id = "cybernetic_lungs"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/organ/lungs/cybernetic
	category = list("Cybernetics", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cybernetic_ears
	name = "Cybernetic Ears"
	desc = "A pair of cybernetic ears"
	id = "cybernetic_ears"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/organ/ears/cybernetic
	category = list("Cybernetics", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cybernetic_stomach
	name = "Cybernetic stomach"
	desc = "A cybernetic stomach"
	id = "cybernetic_stomach"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/organ/stomach/cybernetic
	category = list("Cybernetics", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cybernetic_appendix
	name = "Cybernetic Appendix"
	desc = "A replacement for those who lost a part of themselfs."
	id = "cybernetic_appendix"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(/datum/material/iron = 200, /datum/material/glass = 200)
	build_path = /obj/item/organ/appendix/cybernetic
	category = list("Cybernetics", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/synthetic_plasmavessel
	name = "Synthetic Plasma Vessel"
	desc = "A complex synthetic construct meant to replicate the effects of a plasma vessel"
	id = "synthetic_plasmavessel"
	build_type = PROTOLATHE
	construction_time = 50
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500, /datum/material/gold = 1250, /datum/material/plasma = 10000, /datum/material/diamond = 1000, /datum/material/bluespace = 2000)
	build_path = /obj/item/organ/alien/plasmavessel/synthetic
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/////////////////////
///Surgery Designs///
/////////////////////
/datum/design/surgery
	name = "Surgery Design"
	desc = "what"
	id = "surgery_parent"
	research_icon = 'icons/misc/surgery_icons.dmi'
	research_icon_state = "surgery_any"
	var/list/surgery

/datum/design/surgery/experimental_dissection
	name = "Advanced Dissection"
	desc = "A surgical procedure which analyzes the biology of a corpse, and automatically adds new findings to the research database."
	id = "surgery_adv_dissection"
	surgery = list(/datum/surgery/experimental_dissection/adv)
	research_icon = 'icons/mob/actions.dmi'
	research_icon_state = "scan_mode"

/datum/design/surgery/experimental_dissection/exp
	name = "Experimental Dissection"
	id = "surgery_exp_dissection"
	surgery = list(/datum/surgery/experimental_dissection/adv/exp)

/datum/design/surgery/experimental_dissection/alien
	name = "Extraterrestrial Dissection"
	id = "surgery_ext_dissection"
	surgery = list(/datum/surgery/experimental_dissection/adv/alien)

/datum/design/surgery/lobotomy
	name = "Lobotomy"
	desc = "An invasive surgical procedure which guarantees removal of almost all brain traumas, but might cause another permanent trauma in return."
	id = "surgery_lobotomy"
	surgery = list(/datum/surgery/advanced/lobotomy, /datum/surgery/advanced/lobotomy/mechanic)
	research_icon_state = "lobotomy"

/datum/design/surgery/pacify
	name = "Pacification"
	desc = "A surgical procedure which permanently inhibits the aggression center of the brain, making the patient unwilling to cause direct harm."
	id = "surgery_pacify"
	surgery = list(/datum/surgery/advanced/pacify, /datum/surgery/advanced/pacify/mechanic)
	research_icon_state = "pacify"

/datum/design/surgery/viral_bonding
	name = "Viral Bonding"
	desc = "A surgical procedure that forces a symbiotic relationship between a virus and its host. The patient must be dosed with spaceacillin, virus food, and formaldehyde."
	id = "surgery_viral_bond"
	surgery = list(/datum/surgery/advanced/viral_bonding)
	research_icon_state = "surgery_chest"

/datum/design/surgery/healing
	name = "Tend Wounds"
	desc = "An upgraded version of the original surgery."
	id = "surgery_healing_base" //holder because travis cries otherwise. Not used in techweb unlocks.
	research_icon_state = "surgery_chest"

/datum/design/surgery/healing/brute_upgrade
	name = "Tend Wounds (Brute) Upgrade"
	surgery = list(/datum/surgery/healing/brute/upgraded)
	id = "surgery_heal_brute_upgrade"

/datum/design/surgery/healing/brute_upgrade_2
	name = "Tend Wounds (Brute) Upgrade"
	surgery = list(/datum/surgery/healing/brute/upgraded/femto)
	id = "surgery_heal_brute_upgrade_femto"

/datum/design/surgery/healing/burn_upgrade
	name = "Tend Wounds (Burn) Upgrade"
	surgery = list(/datum/surgery/healing/burn/upgraded)
	id = "surgery_heal_burn_upgrade"

/datum/design/surgery/healing/burn_upgrade_2
	name = "Tend Wounds (Burn) Upgrade"
	surgery = list(/datum/surgery/healing/burn/upgraded/femto)
	id = "surgery_heal_burn_upgrade_femto"

/datum/design/surgery/healing/combo
	name = "Tend Wounds (Physical)"
	desc = "A surgical procedure that repairs both bruises and burns. Repair efficiency is not as high as the individual surgeries but it is faster."
	surgery = list(/datum/surgery/healing/combo)
	id = "surgery_heal_combo"

/datum/design/surgery/healing/combo_upgrade
	name = "Tend Wounds (Physical) Upgrade"
	surgery = list(/datum/surgery/healing/combo/upgraded)
	id = "surgery_heal_combo_upgrade"

/datum/design/surgery/healing/combo_upgrade_2
	name = "Tend Wounds (Physical) Upgrade"
	desc = "A surgical procedure that repairs both bruises and burns faster than their individual counterparts. It is more effective than both the individual surgeries."
	surgery = list(/datum/surgery/healing/combo/upgraded/femto)
	id = "surgery_heal_combo_upgrade_femto"

/datum/design/surgery/revival
	name = "Revival"
	desc = "An experimental surgical procedure which involves reconstruction and reactivation of the patient's brain even long after death. The body must still be able to sustain life."
	id = "surgery_revival"
	surgery = list(/datum/surgery/advanced/revival, /datum/surgery/advanced/revival/mechanic)
	research_icon_state = "revival"

/datum/design/surgery/dna_recovery
	name = "DNA Recovery"
	desc = "A surgical procedure which involves using rezadone to salvage a single strand of DNA from the patient, allowing them to be cloned."
	id = "surgery_dna_recovery"
	surgery = list(/datum/surgery/advanced/dna_recovery, /datum/surgery/advanced/dna_recovery/alien)
	research_icon_state = "surgery_head"

/datum/design/surgery/brainwashing
	name = "Brainwashing"
	desc = "A surgical procedure which directly implants a directive into the patient's brain, making it their absolute priority. It can be cleared using a mindshield implant."
	id = "surgery_brainwashing"
	surgery = list(/datum/surgery/advanced/brainwashing, /datum/surgery/advanced/brainwashing/mechanic)
	research_icon_state = "surgery_head"

/datum/design/surgery/nerve_splicing
	name = "Nerve Splicing"
	desc = "A surgical procedure which splices the patient's nerves, making them more resistant to stuns."
	id = "surgery_nerve_splice"
	surgery = list(/datum/surgery/advanced/bioware/nerve_splicing)
	research_icon_state = "surgery_chest"

/datum/design/surgery/nerve_grounding
	name = "Nerve Grounding"
	desc = "A surgical procedure which makes the patient's nerves act as grounding rods, protecting them from electrical shocks."
	id = "surgery_nerve_ground"
	surgery = list(/datum/surgery/advanced/bioware/nerve_grounding)
	research_icon_state = "surgery_chest"

/datum/design/surgery/vein_threading
	name = "Vein Threading"
	desc = "A surgical procedure which severely reduces the amount of blood lost in case of injury."
	id = "surgery_vein_thread"
	surgery = list(/datum/surgery/advanced/bioware/vein_threading)
	research_icon_state = "surgery_chest"

/datum/design/surgery/muscled_veins
	name = "Vein Muscle Membrane"
	desc = "A surgical procedure which adds a muscled membrane to blood vessels, allowing them to pump blood without a heart."
	id = "surgery_muscled_veins"
	surgery = list(/datum/surgery/advanced/bioware/muscled_veins)
	research_icon_state = "surgery_chest"

/datum/design/surgery/ligament_hook
	name = "Ligament Hook"
	desc = "A surgical procedure which reshapes the connections between torso and limbs, making it so limbs can be attached manually if severed. \
	However this weakens the connection, making them easier to detach as well."
	id = "surgery_ligament_hook"
	surgery = list(/datum/surgery/advanced/bioware/ligament_hook)
	research_icon_state = "surgery_chest"

/datum/design/surgery/ligament_reinforcement
	name = "Ligament Reinforcement"
	desc = "A surgical procedure which adds a protective tissue and bone cage around the connections between the torso and limbs, preventing dismemberment. \
	However, the nerve connections as a result are more easily interrupted, making it easier to disable limbs with damage."
	id = "surgery_ligament_reinforcement"
	surgery = list(/datum/surgery/advanced/bioware/ligament_reinforcement)
	research_icon_state = "surgery_chest"

/datum/design/surgery/necrotic_revival
	name = "Necrotic Revival"
	desc = "An experimental surgical procedure that stimulates the growth of a Romerol tumor inside the patient's brain. Requires zombie powder or rezadone."
	id = "surgery_zombie"
	surgery = list(/datum/surgery/advanced/necrotic_revival)
	research_icon_state = "surgery_head"
