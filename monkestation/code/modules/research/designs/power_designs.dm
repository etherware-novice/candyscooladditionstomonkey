/datum/design/light_replacer_bluespace
	name = "Bluespace Light Replacer"
	desc = "A device to automatically replace lights at a distance. Refill with working light bulbs."
	id = "light_replacer_bluespace"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 700, /datum/material/glass = 70, /datum/material/copper = 100, /datum/material/bluespace = 100)
	build_path = /obj/item/lightreplacer/bluespace
	category = list("Power Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE | DEPARTMENTAL_FLAG_ENGINEERING
