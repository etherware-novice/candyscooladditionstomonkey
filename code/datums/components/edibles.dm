#define MIN_FULLNESS 50
#define MAX_FULLNESS 600
#define NEAR_FULLNESS 500
#define MID_FULLNESS 150



/*!

This component makes it possible to make things edible. What this means is that you can take a bite or force someone to take a bite (in the case of items).
These items take a specific time to eat, and can do most of the things our original food items could.

Behavior that's still missing from this component that original food items had that should either be put into seperate components or somewhere else:
	Components:
	Drying component (jerky etc)
	Customizable component (custom pizzas etc)
	Processable component (Slicing and cooking behavior essentialy, making it go from item A to B when conditions are met.)

	Misc:
	Something for cakes (You can store things inside)

*/
/datum/component/edible
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	///Amount of reagents taken per bite
	var/bite_consumption = 2
	///Amount of bites taken so far
	var/bitecount = 0
	///Flags for food
	var/food_flags = NONE
	///Bitfield of the types of this food
	var/foodtypes = NONE
	///Amount of seconds it takes to eat this food
	var/eat_time = 30
	///Defines how much it lowers someones satiety (Need to eat, essentialy)
	var/junkiness = 0
	///Message to send when eating
	var/list/eatverbs
	///Callback to be ran for when you take a bite of something
	var/datum/callback/after_eat
	///Callback to be ran for when you take a bite of something
	var/datum/callback/on_consume
	///Callback to be ran for when the code check if the food is liked, allowing for unique overrides for special foods like donuts with cops.
	var/datum/callback/check_liked
	///Last time we checked for food likes
	var/last_check_time
	///The initial reagents of this food when it is made
	var/list/initial_reagents
	///The initial volume of the foods reagents
	var/volume
	///The flavortext for taste (haha get it flavor text)
	var/list/tastes
	///The type of atom this creates when the object is microwaved.
	var/microwaved_type

/datum/component/edible/Initialize(list/initial_reagents,
								food_flags = NONE,
								foodtypes = NONE,
								volume = 50,
								eat_time = 10,
								list/tastes,
								list/eatverbs = list("bite","chew","nibble","gnaw","gobble","chomp"),
								bite_consumption = 2,
								microwaved_type,
								junkiness,
								datum/callback/after_eat,
								datum/callback/on_consume,
								datum/callback/check_liked)

	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_ANIMAL, .proc/UseByAnimal)
	RegisterSignal(parent, COMSIG_ATOM_CHECKPARTS, .proc/OnCraft)
	RegisterSignal(parent, COMSIG_ATOM_CREATEDBY_PROCESSING, .proc/OnProcessed)
	RegisterSignal(parent, COMSIG_ITEM_MICROWAVE_COOKED, .proc/OnMicrowaveCooked)
	RegisterSignal(parent, COMSIG_EDIBLE_INGREDIENT_ADDED, .proc/edible_ingredient_added)
	RegisterSignal(parent, COMSIG_CLICK_ALT, .proc/show_radial_recipes)
	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_ATTACK, .proc/UseFromHand)
		RegisterSignal(parent, COMSIG_ITEM_FRIED, .proc/OnFried)
		RegisterSignal(parent, COMSIG_ITEM_MICROWAVE_ACT, .proc/OnMicrowaved)
		RegisterSignal(parent, COMSIG_ITEM_USED_AS_INGREDIENT, .proc/used_to_customize)

		var/obj/item/item = parent
		if (!item.grind_results)
			item.grind_results = list() //If this doesn't already exist, add it as an empty list. This is needed for the grinder to accept it.

	else if(isturf(parent))
		RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, .proc/TryToEatTurf)

	src.bite_consumption = bite_consumption
	src.food_flags = food_flags
	src.foodtypes = foodtypes
	src.eat_time = eat_time
	src.eatverbs = string_list(eatverbs)
	src.junkiness = junkiness
	src.after_eat = after_eat
	src.on_consume = on_consume
	src.initial_reagents = string_assoc_list(initial_reagents)
	src.tastes = string_assoc_list(tastes)
	src.microwaved_type = microwaved_type
	src.check_liked = check_liked

	var/atom/owner = parent

	owner.create_reagents(volume, INJECTABLE)

	for(var/rid in initial_reagents)
		var/amount = initial_reagents[rid]
		if(length(tastes) && (rid == /datum/reagent/consumable/nutriment || rid == /datum/reagent/consumable/nutriment/vitamin))
			owner.reagents.add_reagent(rid, amount, tastes.Copy())
		else
			owner.reagents.add_reagent(rid, amount)

/datum/component/edible/InheritComponent(datum/component/C,
	i_am_original,
	list/initial_reagents,
	food_flags = NONE,
	foodtypes = NONE,
	volume = 50,
	eat_time = 30,
	list/tastes,
	list/eatverbs = list("bite","chew","nibble","gnaw","gobble","chomp"),
	bite_consumption = 2,
	microwaved_type,
	junkiness,
	datum/callback/after_eat,
	datum/callback/on_consume,
	datum/callback/check_liked
	)

	. = ..()
	src.bite_consumption = bite_consumption
	src.food_flags = food_flags
	src.foodtypes = foodtypes
	src.eat_time = eat_time
	src.eatverbs = eatverbs
	src.junkiness = junkiness
	src.after_eat = after_eat
	src.on_consume = on_consume

/datum/component/edible/Destroy(force, silent)
	QDEL_NULL(after_eat)
	QDEL_NULL(on_consume)
	return ..()

///Response to being used to customize something
/datum/component/edible/proc/used_to_customize(datum/source, atom/customized)
	SIGNAL_HANDLER

	SEND_SIGNAL(customized, COMSIG_EDIBLE_INGREDIENT_ADDED, src)

///Response to an edible ingredient being added to parent.
/datum/component/edible/proc/edible_ingredient_added(datum/source, datum/component/edible/ingredient)
	SIGNAL_HANDLER

	var/datum/component/edible/E = ingredient
	if (LAZYLEN(E.tastes))
		tastes = tastes.Copy()
		for (var/t in E.tastes)
			tastes[t] += E.tastes[t]
	foodtypes |= E.foodtypes

/datum/component/edible/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(!(food_flags & FOOD_IN_CONTAINER))
		switch (bitecount)
			if (0)
				return
			if(1)
				examine_list += "[parent] was bitten by someone!"
			if(2,3)
				examine_list += "[parent] was bitten [bitecount] times!"
			else
				examine_list += "[parent] was bitten multiple times!"

/datum/component/edible/proc/UseFromHand(obj/item/source, mob/living/M, mob/living/user)
	SIGNAL_HANDLER

	return TryToEat(M, user)

/datum/component/edible/proc/TryToEatTurf(datum/source, mob/user)
	SIGNAL_HANDLER

	return TryToEat(user, user)

/datum/component/edible/proc/OnFried(fry_object)
	SIGNAL_HANDLER
	var/atom/our_atom = parent
	our_atom.reagents.trans_to(fry_object, our_atom.reagents.total_volume)
	qdel(our_atom)
	return COMSIG_FRYING_HANDLED

///Called when food is created through processing (Usually this means it was sliced). We use this to pass the OG items reagents.
/datum/component/edible/proc/OnProcessed(datum/source, atom/original_atom, list/chosen_processing_option)
	SIGNAL_HANDLER

	if(!original_atom.reagents)
		return

	var/atom/this_food = parent
	var/reagents_for_slice = chosen_processing_option[TOOL_PROCESSING_AMOUNT]

	this_food.create_reagents(volume) //Make sure we have a reagent container

	original_atom.reagents.trans_to(this_food, reagents_for_slice)

	if(original_atom.name != initial(original_atom.name))
		this_food.name = "slice of [original_atom.name]"
	if(original_atom.desc != initial(original_atom.desc))
		this_food.desc = "[original_atom.desc]"

///Called when food is crafted through a crafting recipe datum.
/datum/component/edible/proc/OnCraft(datum/source, list/parts_list, datum/crafting_recipe/food/recipe)
	SIGNAL_HANDLER

	var/atom/this_food = parent

	this_food.reagents.clear_reagents()

	for(var/obj/item/crafted_part in this_food.contents)
		crafted_part.reagents?.trans_to(this_food.reagents, crafted_part.reagents.maximum_volume, CRAFTED_FOOD_INGREDIENT_REAGENT_MODIFIER)

	var/list/objects_to_delete = list()

	// Remove all non recipe objects from the contents
	for(var/content_object in this_food.contents)
		for(var/recipe_object in recipe.real_parts)
			if(istype(content_object, recipe_object))
				continue
		objects_to_delete += content_object

	QDEL_LIST(objects_to_delete)

	for(var/r_id in initial_reagents)
		var/amount = initial_reagents[r_id] * CRAFTED_FOOD_BASE_REAGENT_MODIFIER
		if(r_id == /datum/reagent/consumable/nutriment || r_id == /datum/reagent/consumable/nutriment/vitamin)
			this_food.reagents.add_reagent(r_id, amount, tastes)
		else
			this_food.reagents.add_reagent(r_id, amount)

	SSblackbox.record_feedback("tally", "food_made", 1, type)

/datum/component/edible/proc/OnMicrowaved(datum/source, obj/machinery/microwave/used_microwave)
	SIGNAL_HANDLER

	var/turf/parent_turf = get_turf(parent)

	if(!microwaved_type)
		new /obj/item/food/badrecipe(parent_turf)
		qdel(parent)
		return

	var/obj/item/result

	result = new microwaved_type(parent_turf)

	var/efficiency = istype(used_microwave) ? used_microwave.efficiency : 1

	SEND_SIGNAL(result, COMSIG_ITEM_MICROWAVE_COOKED, parent, efficiency)

	SSblackbox.record_feedback("tally", "food_made", 1, result.type)
	qdel(parent)
	return

///Corrects the reagents on the newly cooked food
/datum/component/edible/proc/OnMicrowaveCooked(datum/source, obj/item/source_item, cooking_efficiency = 1)
	SIGNAL_HANDLER

	var/atom/this_food = parent

	this_food.reagents.clear_reagents()

	source_item.reagents?.trans_to(this_food, source_item.reagents.total_volume)

	for(var/r_id in initial_reagents)
		var/amount = initial_reagents[r_id] * cooking_efficiency * CRAFTED_FOOD_BASE_REAGENT_MODIFIER
		if(r_id == /datum/reagent/consumable/nutriment || r_id == /datum/reagent/consumable/nutriment/vitamin)
			this_food.reagents.add_reagent(r_id, amount, tastes)
		else
			this_food.reagents.add_reagent(r_id, amount)

///Makes sure the thing hasn't been destroyed or fully eaten to prevent eating phantom edibles
/datum/component/edible/proc/IsFoodGone(atom/owner, mob/living/feeder)
	if(QDELETED(owner)|| !(IS_EDIBLE(owner)))
		return TRUE
	if(owner.reagents.total_volume)
		return FALSE
	return TRUE

///All the checks for the act of eating itself and
/datum/component/edible/proc/TryToEat(mob/living/eater, mob/living/feeder)

	set waitfor = FALSE

	var/atom/owner = parent

	if(feeder.a_intent == INTENT_HARM)
		return

	if(!owner)
		return

	if(IsFoodGone(owner, feeder))
		return

	if(!owner.reagents.total_volume)//Shouldn't be needed but it checks to see if it has anything left in it.
		to_chat(feeder, "<span class='warning'>None of [owner] left, oh no!</span>")
		if(isturf(parent))
			var/turf/T = parent
			T.ScrapeAway(1, CHANGETURF_INHERIT_AIR)
		else
			qdel(parent)
		return
	if(!CanConsume(eater, feeder))
		return
	var/fullness = eater.nutrition + 10 //The theoretical fullness of the person eating if they were to eat this
	for(var/datum/reagent/consumable/C in eater.reagents.reagent_list) //we add the nutrition value of what we're currently digesting
		fullness += C.nutriment_factor * C.volume / C.metabolization_rate

	. = COMPONENT_ITEM_NO_ATTACK //Point of no return I suppose

	if(eater == feeder)//If you're eating it yourself.
		if(!do_mob(feeder, eater, eat_time)) //Gotta pass the minimal eat time
			return
		if(IsFoodGone(owner, feeder))
			return
		var/eatverb = pick(eatverbs)
		if(junkiness && eater.satiety < -150 && eater.nutrition > NUTRITION_LEVEL_STARVING + 50 && !HAS_TRAIT(eater, TRAIT_VORACIOUS))
			to_chat(eater, "<span class='warning'>You don't feel like eating any more junk food at the moment!</span>")
			return
		else if(fullness <= MIN_FULLNESS)
			eater.visible_message("<span class='notice'>[eater] hungrily [eatverb]s \the [parent], gobbling it down!</span>", "<span class='notice'>You hungrily [eatverb] \the [parent], gobbling it down!</span>")
		else if(fullness > MIN_FULLNESS && fullness < MID_FULLNESS)
			eater.visible_message("<span class='notice'>[eater] hungrily [eatverb]s \the [parent].</span>", "<span class='notice'>You hungrily [eatverb] \the [parent].</span>")
		else if(fullness > MID_FULLNESS && fullness < NEAR_FULLNESS)
			eater.visible_message("<span class='notice'>[eater] [eatverb]s \the [parent].</span>", "<span class='notice'>You [eatverb] \the [parent].</span>")
		else if(fullness > NEAR_FULLNESS && fullness < MAX_FULLNESS)
			eater.visible_message("<span class='notice'>[eater] unwillingly [eatverb]s a bit of \the [parent].</span>", "<span class='notice'>You unwillingly [eatverb] a bit of \the [parent].</span>")
		else if(fullness > (MAX_FULLNESS * (1 + eater.overeatduration / 2000)))	// The more you eat - the more you can eat
			eater.visible_message("<span class='warning'>[eater] cannot force any more of \the [parent] to go down [eater.p_their()] throat!</span>", "<span class='warning'>You cannot force any more of \the [parent] to go down your throat!</span>")
			return
	else //If you're feeding it to someone else.
		if(isbrain(eater))
			to_chat(feeder, "<span class='warning'>[eater] doesn't seem to have a mouth!</span>")
			return
		if(fullness <= (MAX_FULLNESS * (1 + eater.overeatduration / 1000)))
			eater.visible_message("<span class='danger'>[feeder] attempts to feed [eater] [parent].</span>", \
									"<span class='userdanger'>[feeder] attempts to feed you [parent].</span>")
		else
			eater.visible_message("<span class='warning'>[feeder] cannot force any more of [parent] down [eater]'s throat!</span>", \
									"<span class='warning'>[feeder] cannot force any more of [parent] down your throat!</span>")
			return
		if(!do_mob(feeder, eater)) //Wait 3 seconds before you can feed
			return

		if(IsFoodGone(owner, feeder))
			return

		log_combat(feeder, eater, "fed", owner.reagents.log_list())
		eater.visible_message("<span class='danger'>[feeder] forces [eater] to eat [parent]!</span>", \
									"<span class='userdanger'>[feeder] forces you to eat [parent]!</span>")

	TakeBite(eater, feeder)

	//If we're not force-feeding and there's an eat delay, try take another bite
	if(eater == feeder && eat_time)
		INVOKE_ASYNC(src, .proc/TryToEat, eater, feeder)

///This function lets the eater take a bite and transfers the reagents to the eater.
/datum/component/edible/proc/TakeBite(mob/living/eater, mob/living/feeder)

	var/atom/owner = parent

	if(!owner?.reagents)
		return FALSE

	playsound(eater.loc,'sound/items/eatfood.ogg', rand(10,50), TRUE)
	if(owner.reagents.total_volume)
		SEND_SIGNAL(parent, COMSIG_FOOD_EATEN, eater, feeder, bitecount, bite_consumption)
		var/fraction = min(bite_consumption / owner.reagents.total_volume, 1)
		owner.reagents.trans_to(eater, bite_consumption, transfered_by = feeder, method = INGEST)
		bitecount++
		if(!owner.reagents.total_volume)
			On_Consume(eater, feeder)
		checkLiked(fraction, eater)

		//Invoke our after eat callback if it is valid
		if(after_eat)
			after_eat.Invoke(eater, feeder, bitecount)

		return TRUE

///Checks whether or not the eater can actually consume the food
/datum/component/edible/proc/CanConsume(mob/living/eater, mob/living/feeder)
	if(!iscarbon(eater))
		return FALSE
	if(isipc(eater))
		return FALSE
	var/mob/living/carbon/C = eater
	var/covered = ""
	if(C.is_mouth_covered(head_only = 1))
		covered = "headgear"
	else if(C.is_mouth_covered(mask_only = 1))
		covered = "mask"
	if(covered)
		var/who = (isnull(feeder) || eater == feeder) ? "your" : "[eater.p_their()]"
		to_chat(feeder, "<span class='warning'>You have to remove [who] [covered] first!</span>")
		return FALSE
	return TRUE

///Check foodtypes to see if we should send a moodlet
/datum/component/edible/proc/checkLiked(fraction, mob/M)
	if(last_check_time + 5 SECONDS > world.time)
		return FALSE
	if(!ishuman(M))
		return FALSE
	var/mob/living/carbon/human/H = M
	if(HAS_TRAIT(H, TRAIT_AGEUSIA) && foodtypes & H.dna.species.toxic_food)
		to_chat(H, "<span class='warning'>You don't feel so good...</span>")
		H.adjust_disgust(25 + 30 * fraction)

	var/food_taste_reaction


	if(check_liked) //Callback handling; use this as an override for special food like donuts
		food_taste_reaction = check_liked.Invoke(fraction, H)
	else if(foodtypes & H.dna.species.toxic_food)
		food_taste_reaction = FOOD_TOXIC
	else if(foodtypes & H.dna.species.disliked_food)
		food_taste_reaction = FOOD_DISLIKED
	else if(foodtypes & H.dna.species.liked_food)
		food_taste_reaction = FOOD_LIKED

	switch(food_taste_reaction)
		if(FOOD_TOXIC)
			to_chat(H,"<span class='warning'>What the hell was that thing?!</span>")
			H.adjust_disgust(25 + 30 * fraction)
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "toxic_food", /datum/mood_event/disgusting_food)
		if(FOOD_DISLIKED)
			to_chat(H,"<span class='notice'>That didn't taste very good...</span>")
			H.adjust_disgust(11 + 15 * fraction)
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "gross_food", /datum/mood_event/gross_food)
		if(FOOD_LIKED)
			to_chat(H,"<span class='notice'>I love this taste!</span>")
			H.adjust_disgust(-5 + -2.5 * fraction)
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "fav_food", /datum/mood_event/favorite_food)

	//Bruh this breakfast thing is cringe and shouldve been handled separately from food-types, remove this in the future (Actually, just kill foodtypes in general)
	if((foodtypes & BREAKFAST) && world.time - SSticker.round_start_time < STOP_SERVING_BREAKFAST)
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "breakfast", /datum/mood_event/breakfast)
	last_check_time = world.time


///Delete the item when it is fully eaten
/datum/component/edible/proc/On_Consume(mob/living/eater, mob/living/feeder)
	SEND_SIGNAL(parent, COMSIG_FOOD_CONSUMED, eater, feeder)

	on_consume?.Invoke(eater, feeder)

	if(isturf(parent))
		var/turf/T = parent
		T.ScrapeAway(1, CHANGETURF_INHERIT_AIR)
	else
		qdel(parent)

///Ability to feed food to puppers
/datum/component/edible/proc/UseByAnimal(datum/source, mob/user)

	SIGNAL_HANDLER


	var/atom/owner = parent

	var/mob/living/L = user
	if(bitecount == 0 || prob(50))
		L.manual_emote("nibbles away at \the [parent]")
	bitecount++
	. = COMPONENT_ITEM_NO_ATTACK
	L.taste(owner.reagents) // why should carbons get all the fun?
	if(bitecount >= 5)
		var/satisfaction_text = pick("burps from enjoyment", "yaps for more", "woofs twice", "looks at the area where \the [parent] was")
		if(satisfaction_text)
			L.manual_emote(satisfaction_text)
		qdel(parent)

/datum/component/edible/proc/check_menu(mob/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(parent))
		return FALSE
	return TRUE

/datum/component/edible/proc/show_radial_recipes(atom/parent_atom, mob/user)
	SIGNAL_HANDLER
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/chef = user
	var/datum/component/personal_crafting/crafting_menu = user.GetComponent(/datum/component/personal_crafting) // we turned crafting into a component so now I have to do this shit to avoid copypaste
	if(!crafting_menu)
		CRASH("HUMAN WITHOUT PERSONAL CRAFTING COMPONENT")
	var/list/available_recipes = list()
	var/list/surroundings = crafting_menu.get_surroundings(chef)
	var/list/recipes_radial = list()
	var/list/recipes_craft = list()
	for(var/recipe in GLOB.crafting_recipes)
		var/datum/crafting_recipe/potential_recipe = recipe
		if((parent.type in potential_recipe.reqs) || (potential_recipe.type in GLOB.generic_recipes)) // dont show recipes that don't involve this item
			if(crafting_menu.check_contents(chef, potential_recipe, surroundings)) // don't show recipes we can't actually make
				available_recipes.Add(potential_recipe)
	for(var/available_recipe in available_recipes)
		var/datum/crafting_recipe/available_recipe_datum = available_recipe
		var/atom/craftable_atom = available_recipe_datum.result
		recipes_radial.Add(list(initial(craftable_atom.name) = image(icon = initial(craftable_atom.icon), icon_state = initial(craftable_atom.icon_state))))
		recipes_craft.Add(list(initial(craftable_atom.name) = available_recipe_datum))
	INVOKE_ASYNC(src, .proc/finalize_radial, recipes_radial, recipes_craft, chef, crafting_menu)
	return

/datum/component/edible/proc/finalize_radial(list/recipes_radial, list/recipes_craft, mob/chef, datum/component/personal_crafting/crafting_menu)
	var/recipe_chosen = show_radial_menu(chef, chef, recipes_radial, custom_check = CALLBACK(src, .proc/check_menu, chef), require_near = TRUE, tooltips = TRUE)
	if(!recipe_chosen)
		return
	var/datum/crafting_recipe/chosen_recipe = recipes_craft[recipe_chosen]
	chef.balloon_alert_to_viewers("crafting [chosen_recipe.name]")
	crafting_menu.craft_until_cant(chosen_recipe, chef, get_turf(parent))
