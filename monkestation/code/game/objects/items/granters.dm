/obj/item/book/granter/martial/psychotic_brawl
	martial = /datum/martial_art/psychotic_brawling
	name = "damp roll of paper"
	martialname = "psychotic brawling"
	desc = "An ancient roll of toilet paper passed down from debtor to debtor full of insane rants and conspiracies."
	greet = "<span class='sciradio'>They're puttin' chemicals into the water that turn the frickin' frogmen into Nanotrasen slaves! Your mind shatters from this knowledge, but you know how to fight them now.</span>"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	remarks = list("In 2384, meridian time personnel met in Washington to change Space Time...",
					"Where IS the ceiling?",
					"Am I constantly laying down from this perspective?",
					"Only Cubic Harmonics can save the galaxy. Cubic Harmonics will pacify all cultists...",
					"Why DOES that moth just appear and disappear...",
					"Who even is Mr.Nanotrasen Himself?",
					"How do we keep coming back to the same stations, even after they get entirely destroyed?",
					"The AI is just a brain in a box...",
					"This is all a simulation...",
					"Why did Nanotrasen hire that confirmed infiltrator for another shift...",
					"The year 25XX has arrived. A horde of ashwalkers. Are rushing from lavaland. Tiding rates skyrocketed! Space Station 13 is ruined! Therefore, Central Command called Mr. Nanotrasen's relative \"John\". For the massacre of the ashwalkers, John is a killer machine. Wipe out all 17 of the ashwalkers! However, in lavaland, there was a secret project in progress! A project to transform the deceased captain into an ultimate weapon!",
					"Floor Pills unlock the secrets of the universe...")

/obj/item/book/granter/martial/psychotic_brawl/onlearned(mob/living/carbon/user)
	..()
	if(oneuse == TRUE)
		desc = "It's completely blank."
		name = "empty scroll"
		icon_state = "blankscroll"
