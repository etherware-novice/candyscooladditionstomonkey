/datum/emote/living/thumbs_up
	key = "thumbsup"
	key_third_person = "thumbsup"
	message = "flashes a thumbs up"
	message_robot = "makes a crude thumbs up with their 'hands'"
	message_AI = "flashes a quick hologram of a thumbs up"
	message_ipc = "flashes a thumbs up icon"
	message_simple = "attempts a thumbs up"
	message_param = "flashes a thumbs up at %t"

/datum/emote/living/thumbs_down
	key = "thumbsdown"
	key_third_person = "thumbsdown"
	message = "flashes a thumbs down"
	message_robot = "makes a crude thumbs down with their 'hands'"
	message_AI = "flashes a quick hologram of a thumbs down"
	message_ipc = "flashes a thumbs down icon"
	message_simple = "attempts a thumbs down"
	message_param = "flashes a thumbs down at %t"

/datum/emote/living/whistle
	key="whistle"
	key_third_person="whistle"
	message = "whistles a few notes"
	message_robot = "whistles a few synthesized notes"
	message_AI = "whistles a synthesized song"
	message_ipc = "whistles a few synthesized notes"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/whistle/get_sound(mob/living/user)
	return pick('sound/instruments/harmonica/Ab2.mid', 'sound/instruments/harmonica/Ab3.mid', 'sound/instruments/harmonica/Ab4.mid', 'sound/instruments/harmonica/Ab5.mid', 'sound/instruments/harmonica/Ab6.mid')
