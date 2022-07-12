/datum/chemical_reaction/baja_blast
	name = "Baja Blast"
	id = /datum/reagent/consumable/baja_blast
	results = list(/datum/reagent/consumable/baja_blast = 3)
	required_reagents = list(/datum/reagent/consumable/limejuice = 1, /datum/reagent/oil = 1, /datum/reagent/consumable/sugar = 1)

/datum/chemical_reaction/drink/bureau
	name = "Bureaucratic Perfection"
	id = /datum/reagent/consumable/ethanol/bureau
	results = list(/datum/reagent/consumable/ethanol/bureau = 3)
	required_reagents = list(/datum/reagent/consumable/ethanol/gin = 1, /datum/reagent/consumable/ethanol/wine = 1, /datum/reagent/consumable/cream = 1)
	reaction_tags = REACTION_TAG_DRINK | REACTION_TAG_EASY | REACTION_TAG_OTHER
