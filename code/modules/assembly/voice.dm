/obj/item/assembly/voice
	name = "voice analyzer"
	desc = "A small electronic device able to record a voice sample, and send a signal when that sample is repeated."
	icon_state = "voice"
	origin_tech = list(TECH_MAGNET = 1)
	matter = list(MATERIAL_STEEL = 500, MATERIAL_GLASS = 50)
	var/listening = 0
	var/recorded	//the activation message

/obj/item/assembly/voice/New()
	..()
	GLOB.listening_objects += src

/obj/item/assembly/voice/Destroy()
	GLOB.listening_objects -= src
	return ..()

/obj/item/assembly/voice/hear_talk(mob/living/M as mob, msg)
	if(listening)
		recorded = msg
		listening = 0
		var/turf/T = get_turf(src)	//otherwise it won't work in hand
		var/list/mobs = list()
		get_mobs_and_objs_in_view_fast(T, world.view, mobs, list())
		T.visible_message("[icon2html(src, mobs)] beeps, \"Activation message is '[recorded]'.\"")
	else
		if(findtext(msg, recorded))
			pulse(0)

/obj/item/assembly/voice/activate()
	if(secured)
		if(!holder)
			listening = !listening
			var/turf/T = get_turf(src)
			var/list/mobs = list()
			get_mobs_and_objs_in_view_fast(T, world.view, mobs, list())
			T.visible_message("[icon2html(src, mobs)] beeps, \"[listening ? "Now" : "No longer"] recording input.\"")


/obj/item/assembly/voice/attack_self(mob/user)
	if(!user)	return 0
	activate()
	return 1


/obj/item/assembly/voice/toggle_secure()
	. = ..()
	listening = 0
