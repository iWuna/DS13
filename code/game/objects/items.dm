/obj/item
	name = "item"
	icon = 'icons/obj/items.dmi'
	var/break_message = "SELF breaks apart!"
	w_class = ITEM_SIZE_NORMAL
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER

	var/image/blood_overlay = null //this saves our blood splatter overlay, which will be processed not to go over the edges of the sprite
	var/randpixel = 6
	var/r_speed = 1.0

	var/structure_damage_factor = 1	//Damage dealt to doors, walls, floors, structures and other hard targets is multiplied by this
	var/embed_mult = 1	//Multiplier on chance to  embed

	max_health = null //Autocalculated from size

	var/burn_point = null
	var/burning = null
	var/hitsound = null
	var/blocksound = 'sound/weapons/Genhit.ogg'

	var/biomaterial = FALSE	//If true, this item does not cause pain or damage when it is embedded or implanted in a human body

	var/slot_flags = 0		//This is used to determine on which slots an item can fit.
	var/equip_slot = slot_none	//What slot this item was last equipped into

	var/no_attack_log = 0			//If it's an item we don't want to log attack_logs with, set this to 1
	pass_flags = PASS_FLAG_TABLE
//	causeerrorheresoifixthis
	var/obj/item/master = null
	var/list/origin_tech = null	//Used by R&D to determine what research bonuses it grants.
	var/list/attack_verb = list("hit") //Used in attackby() to say how something was attacked "[x] has been [z.attack_verb] by [y] with [z]"
	var/list/attack_noun = list("hit")
	var/lock_picking_level = 0 //used to determine whether something can pick a lock, and how well.
	var/force = 0
	var/attack_cooldown = DEFAULT_WEAPON_COOLDOWN
	var/melee_accuracy_bonus = 0

	var/heat_protection = 0 //flags which determine which body parts are protected from heat. Use the HEAD, UPPER_TORSO, LOWER_TORSO, etc. flags. See setup.dm
	var/cold_protection = 0 //flags which determine which body parts are protected from cold. Use the HEAD, UPPER_TORSO, LOWER_TORSO, etc. flags. See setup.dm
	var/max_heat_protection_temperature //Set this variable to determine up to which temperature (IN KELVIN) the item protects against heat damage. Keep at null to disable protection. Only protects areas set by heat_protection flags
	var/min_cold_protection_temperature //Set this variable to determine down to which temperature (IN KELVIN) the item protects against cold damage. 0 is NOT an acceptable number due to if(varname) tests!! Keep at null to disable protection. Only protects areas set by cold_protection flags

	var/datum/action/item_action/action = null
	var/action_button_name //It is also the text which gets displayed on the action button. If not set it defaults to 'Use [name]'. If it's not set, there'll be no button.
	var/default_action_type = /datum/action/item_action // Specify the default type and behavior of the action button for this atom.

	//This flag is used to determine when items in someone's inventory cover others. IE helmets making it so you can't see glasses, etc.
	//It should be used purely for appearance. For gameplay effects caused by items covering body parts, use body_parts_covered.
	var/flags_inv = 0
	var/body_parts_covered = 0 //see setup.dm for appropriate bit flags

	var/item_flags = 0 //Miscellaneous flags pertaining to equippable objects.

	//var/heat_transfer_coefficient = 1 //0 prevents all transfers, 1 is invisible
	var/gas_transfer_coefficient = 1 // for leaking gas from turf to mask and vice-versa (for masks right now, but at some point, i'd like to include space helmets)
	var/permeability_coefficient = 1 // for chemicals/diseases
	var/siemens_coefficient = 1 // for electrical admittance/conductance (electrocution checks and shit)
	var/slowdown_general = 0 // How much clothing is slowing you down. Negative values speeds you up. This is a genera##l slowdown, no matter equipment slot.
	var/slowdown_per_slot[slot_last] // How much clothing is slowing you down. This is an associative list: item slot - slowdown
	var/slowdown_accessory // How much an accessory will slow you down when attached to a worn article of clothing.
	var/canremove = 1 //Mostly for Ninja code at this point but basically will not allow the item to be removed if set to 0. /N
	var/list/armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	var/list/allowed = null //suit storage stuff.
	var/obj/item/device/uplink/hidden_uplink = null // All items can have an uplink hidden inside, just remember to add the triggers.
	var/zoomdevicename = null //name used for message when binoculars/scope is used
	var/zoom = 0 //1 if item is actively being used to zoom. For scoped guns and binoculars.

	var/base_parry_chance = 0	// Will allow weapon to parry melee attacks if non-zero
	var/icon_override = null  //Used to override hardcoded clothing dmis in human clothing proc.

	var/use_alt_layer = FALSE // Use the slot's alternative layer when rendering on a mob

	//** These specify item/icon overrides for _slots_

	var/list/item_state_slots = list(slot_wear_id_str = "id") //overrides the default item_state for particular slots.

	// Used to specify the icon file to be used when the item is worn. If not set the default icon for that slot will be used.
	// If icon_override or sprite_sheets are set they will take precendence over this, assuming they apply to the slot in question.
	// Only slot_l_hand/slot_r_hand are implemented at the moment. Others to be implemented as needed.
	var/list/item_icons

	//** These specify item/icon overrides for _species_

	/* Species-specific sprites, concept stolen from Paradise//vg/.
	ex:
	sprite_sheets = list(
		SPECIES_TAJARA = 'icons/cat/are/bad'
		)
	If index term exists and icon_override is not set, this sprite sheet will be used.
	*/
	var/list/sprite_sheets = list()

	// Species-specific sprite sheets for inventory sprites
	// Works similarly to worn sprite_sheets, except the alternate sprites are used when the clothing/refit_for_species() proc is called.
	var/list/sprite_sheets_obj = list()

	//Items are not dense typically
	can_block_movement = FALSE

/obj/item/New()
	if (!max_health)
		if (w_class != ITEM_SIZE_NO_CONTAINER)	//This is infinity, would cause errors
			max_health = 30 * w_class	//Bigger items are harder to break
		else
			max_health = 250
	health = max_health


	..()
	if(randpixel && (!pixel_x && !pixel_y) && isturf(loc)) //hopefully this will prevent us from messing with mapper-set pixel_x/y
		pixel_x = rand(-randpixel, randpixel)
		pixel_y = rand(-randpixel, randpixel)

	//Normal or larger objects have some parry chance if none is set
	//Explicitly setting a null parry chance prevents the item from being used to parry
	if (w_class >= ITEM_SIZE_NORMAL && !base_parry_chance && !isnull(base_parry_chance))
		base_parry_chance = 15

/obj/item/meddle()
	tumble()
	.=..()

/obj/item/Destroy()
	qdel(hidden_uplink)
	hidden_uplink = null
	if(ismob(loc))
		var/mob/m = loc
		m.drop_from_inventory(src)
		m.update_inv_r_hand()
		m.update_inv_l_hand()
		src.loc = null
	return ..()

/obj/item/device
	icon = 'icons/obj/device.dmi'

//Checks if the item is being held by a mob, and if so, updates the held icons
/obj/item/proc/update_twohanding()
	update_held_icon()

/obj/item/proc/update_held_icon()
	if(ismob(src.loc))
		var/mob/M = src.loc
		if(M.l_hand == src)
			M.update_inv_l_hand()
		else if(M.r_hand == src)
			M.update_inv_r_hand()

/obj/item/proc/is_held_twohanded(mob/living/M)
	var/check_hand
	if(M.l_hand == src && !M.r_hand)
		check_hand = BP_R_HAND //item in left hand, check right hand
	else if(M.r_hand == src && !M.l_hand)
		check_hand = BP_L_HAND //item in right hand, check left hand
	else
		return FALSE

	//would check is_broken() and is_malfunctioning() here too but is_malfunctioning()
	//is probabilistic so we can't do that and it would be unfair to just check one.
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/hand = H.organs_by_name[check_hand]
		if(istype(hand) && hand.is_usable())
			return TRUE
	return FALSE

/obj/item/ex_act(severity)
	switch(severity)
		if(1.0)
			take_damage(500)
		if(2.0)
			take_damage(rand(125, 200))
		if(3.0)
			take_damage(rand(75, 125))

/obj/item/verb/move_to_top()
	set name = "Move To Top"
	set category = "Object"
	set src in oview(1)

	if(!istype(src.loc, /turf) || usr.stat || usr.restrained() )
		return

	var/turf/T = src.loc

	src.loc = null

	src.loc = T

/obj/item/examine(mob/user, var/distance = -1)
	var/size
	switch(src.w_class)
		if(ITEM_SIZE_TINY)
			size = "tiny"
		if(ITEM_SIZE_SMALL)
			size = "small"
		if(ITEM_SIZE_NORMAL)
			size = "normal-sized"
		if(ITEM_SIZE_LARGE)
			size = "large"
		if(ITEM_SIZE_HUGE)
			size = "bulky"
		if(ITEM_SIZE_HUGE + 1 to INFINITY)
			size = "huge"
	var/desc_comp = "" //For "description composite"
	desc_comp += "It is a [size] item."

	if(hasHUD(user, HUD_SCIENCE)) //Mob has a research scanner active.
		desc_comp += "<BR>*--------* <BR>"

		if(origin_tech)
			desc_comp += "<span class='notice'>Testing potentials:</span><BR>"
			//var/list/techlvls = params2list(origin_tech)
			for(var/T in origin_tech)
				desc_comp += "Tech: Level [origin_tech[T]] [CallTechName(T)] <BR>"
		else
			desc_comp += "No tech origins detected.<BR>"

		if(LAZYLEN(matter))
			desc_comp += "<span class='notice'>Extractable materials:</span><BR>"
			for(var/mat in matter)
				desc_comp += "[get_material_by_name(mat)]<BR>"
		else
			desc_comp += "<span class='danger'>No extractable materials detected.</span><BR>"
		desc_comp += "*--------*"

	return ..(user, distance, "", desc_comp)

/obj/item/attack_hand(mob/user as mob)
	if (!user) return
	if (anchored)
		return ..()
	if (hasorgans(user))
		var/mob/living/carbon/human/H
		if (istype(user, /mob/living/carbon/human))
			H = user
		else
			//There is currently no support for non humans picking up items.
			//If there is ever a need to add that functionality, then this logic should be moved to procs on the mob,
			//the last thing we need is a pile of if/else mob checks here
			return

		//Cant pick things up with no hands, arms, or tentacles
		if(!(LAZYLEN(H.species.grasping_limbs)))
			return

		//If this person can't normally pick things up, lets see if we are an exception
		if (H && !H.species.can_pickup)
			if (!is_type_in_list(src, GLOB.pickup_whitelist))
				to_chat(user, "<span class='warning'>You lack the manual dexterity to pick up objects!</span>")
				return
		var/organ_name = H.species.grasping_limbs[1]

		if (user.hand)
			organ_name = H.species.grasping_limbs[2]

		var/obj/item/organ/external/temp = H.get_organ(organ_name)


		if(temp && !temp.is_usable())
			to_chat(user, "<span class='notice'>You try to move your [temp.name], but cannot!</span>")
			return
		if(!temp)
			if (H && H.should_have_organ(organ_name))
				to_chat(user, "<span class='notice'>You try to use your hand, but realize it is no longer attached!</span>")
			else
				to_chat(user, "<span class='notice'>You have no hands to pickup objects with!</span>")
			return



	var/old_loc = src.loc

	src.pickup(user)
	if (istype(src.loc, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = src.loc
		S.remove_from_storage(src)

	src.throwing = 0


	var/inside = null

	//If we're clicking an item which is already in us, it means we're trying to move it from one equip slot to another
	if (src.loc == user)
		//When doing this, we pass ourselves as the target, so that the item will never leave our body in this process
		if(!user.unEquip(src, user))
			return
		else
			//The item is now briefly lost inside our body. Don't worry, we'll get it out before this proc is finished
			inside = user
	else
		if(isliving(src.loc))
			return


	//If it goes into our hand, all is well
	if(user.put_in_active_hand(src))
		if (isturf(old_loc))
			var/obj/effect/temporary/item_pickup_ghost/ghost = new(old_loc, src)
			ghost.animate_towards(user)
		if(randpixel)
			pixel_x = rand(-randpixel, randpixel)
			pixel_y = rand(-randpixel/2, randpixel/2)
			pixel_z = 0
		else if(randpixel == 0)
			pixel_x = 0
			pixel_y = 0

	//The item failed to enter our hand, lets see what happens now
	else
		//If the item is floating inside our body, we gotta drop it. This will trigger dropped() in the next step
		if (inside)
			forceMove(get_turf(src))

		//If we started on a mob and are no longer on that mob, we call dropped
		if(ismob(old_loc) && loc != old_loc)
			dropped()

/obj/item/attack_ai(mob/user as mob)
	if (istype(src.loc, /obj/item/weapon/robot_module))
		//If the item is part of a cyborg module, equip it
		if(!isrobot(user))
			return
		var/mob/living/silicon/robot/R = user
		R.activate_module(src)
		R.hud_used.update_robot_modules_display()

/obj/item/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = W
		if(S.use_to_pickup)
			if(S.collection_mode) //Mode is set to collect all items
				if(isturf(src.loc))
					S.gather_all(src.loc, user)
			else if(S.can_be_inserted(src, user))
				S.handle_item_insertion(src)

/obj/item/proc/talk_into(mob/M as mob, text)
	return

/obj/item/proc/moved(mob/user as mob, old_loc as turf)
	return

//Dropped is called just after an item leaves a mob's direct contents
//This does not include containers on the mob
//It will already be in its new location when dropped is called
/obj/item/proc/dropped(mob/user as mob)
	if(randpixel)
		pixel_z = randpixel //an idea borrowed from some of the older pixel_y randomizations. Intended to make items appear to drop at a character

	update_twohanding()
	if(user)
		if(user.l_hand)
			user.l_hand.update_twohanding()
		if(user.r_hand)
			user.r_hand.update_twohanding()

// called just as an item is picked up (loc is not yet changed)
/obj/item/proc/pickup(mob/user)
	return

// called when this item is removed from a storage item, which is passed on as S. The loc variable is already set to the new destination before this is called.
/obj/item/proc/on_exit_storage(obj/item/weapon/storage/S as obj)
	return

// called when this item is added into a storage item, which is passed on as S. The loc variable is already set to the storage item.
/obj/item/proc/on_enter_storage(obj/item/weapon/storage/S as obj)
	return

// called when "found" in pockets and storage items. Returns 1 if the search should end.
/obj/item/proc/on_found(mob/finder as mob)
	return

// called after an item is placed in an equipment slot
// user is mob that equipped it
// slot uses the slot_X defines found in setup.dm
// for items that can be placed in multiple slots
// note this isn't called during the initial dressing of a player
/obj/item/proc/equipped(var/mob/user, var/slot)
	hud_layerise()
	equip_slot = slot
	if(user.client)	user.client.screen |= src
	if(user.pulling == src) user.stop_pulling()

	//Update two-handing status
	var/mob/M = loc
	if(!istype(M))
		return
	if(M.l_hand)
		M.l_hand.update_twohanding()
	if(M.r_hand)
		M.r_hand.update_twohanding()

//Defines which slots correspond to which slot flags
var/list/global/slot_flags_enumeration = list(
	"[slot_wear_mask]" = SLOT_MASK,
	"[slot_back]" = SLOT_BACK,
	"[slot_wear_suit]" = SLOT_OCLOTHING,
	"[slot_gloves]" = SLOT_GLOVES,
	"[slot_shoes]" = SLOT_FEET,
	"[slot_belt]" = SLOT_BELT,
	"[slot_glasses]" = SLOT_EYES,
	"[slot_head]" = SLOT_HEAD,
	"[slot_l_ear]" = SLOT_EARS|SLOT_TWOEARS,
	"[slot_r_ear]" = SLOT_EARS|SLOT_TWOEARS,
	"[slot_w_uniform]" = SLOT_ICLOTHING,
	"[slot_wear_id]" = SLOT_ID,
	"[slot_tie]" = SLOT_TIE,
	)

//the mob M is attempting to equip this item into the slot passed through as 'slot'. Return 1 if it can do this and 0 if it can't.
//If you are making custom procs but would like to retain partial or complete functionality of this one, include a 'return ..()' to where you want this to happen.
//Set disable_warning to 1 if you wish it to not give you outputs.
//Should probably move the bulk of this into mob code some time, as most of it is related to the definition of slots and not item-specific
//set force to ignore blocking overwear and occupied slots
/obj/item/proc/mob_can_equip(var/mob/M, var/slot, var/disable_warning = 0, var/force = 0)
	if(!slot) return 0
	if(!M) return 0

	if(!ishuman(M)) return 0


	var/mob/living/carbon/human/H = M
	var/list/mob_equip = list()
	if(H.species.hud && H.species.hud.equip_slots)
		mob_equip = H.species.hud.equip_slots


	if(H.species && !(slot in mob_equip))
		return 0

	if (!H.has_organ_for_slot(slot))
		return FALSE


	//First check if the item can be equipped to the desired slot.
	if("[slot]" in slot_flags_enumeration)
		var/req_flags = slot_flags_enumeration["[slot]"]
		if(!(req_flags & slot_flags))
			return 0

	if(!force)
		//Next check that the slot is free
		if(H.get_equipped_item(slot))
			return 0

		//Next check if the slot is accessible.
		var/mob/_user = disable_warning? null : H
		if(!H.slot_is_accessible(slot, src, _user))
			return 0



	//Lastly, check special rules for the desired slot.
	switch(slot)
		if(slot_l_ear, slot_r_ear)
			var/slot_other_ear = (slot == slot_l_ear)? slot_r_ear : slot_l_ear
			if( (w_class > ITEM_SIZE_TINY) && !(slot_flags & SLOT_EARS) )
				return 0
			if( (slot_flags & SLOT_TWOEARS) && H.get_equipped_item(slot_other_ear) )
				return 0
		if(slot_belt, slot_wear_id)
			if(slot == slot_belt && (item_flags & ITEM_FLAG_IS_BELT))
				return 1
			else if(!H.w_uniform && (slot_w_uniform in mob_equip))
				if(!disable_warning)
					to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
				return 0
		if(slot_l_store, slot_r_store)
			if(!H.w_uniform && (slot_w_uniform in mob_equip))
				if(!disable_warning)
					to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
				return 0
			if(slot_flags & SLOT_DENYPOCKET)
				return 0
			if( w_class > ITEM_SIZE_SMALL && !(slot_flags & SLOT_POCKET) )
				return 0
			if(get_storage_cost() == ITEM_SIZE_NO_CONTAINER)
				return 0 //pockets act like storage and should respect ITEM_SIZE_NO_CONTAINER. Suit storage might be fine as is
		if(slot_s_store)
			if(!H.wear_suit && (slot_wear_suit in mob_equip))
				if(!disable_warning)
					to_chat(H, "<span class='warning'>You need a suit before you can attach this [name].</span>")
				return 0
			if(!H.wear_suit.allowed)
				if(!disable_warning)
					to_chat(usr, "<span class='warning'>You somehow have a suit with no defined allowed items for suit storage, stop that.</span>")
				return 0
			if( !(istype(src, /obj/item/modular_computer/pda) || istype(src, /obj/item/weapon/pen) || is_type_in_list(src, H.wear_suit.allowed)) )
				return 0
		if(slot_handcuffed)
			if(!istype(src, /obj/item/weapon/handcuffs))
				return 0
		if(slot_legcuffed)
			return !H.legcuffed && istype(src, /obj/item/weapon/legcuffs)
		if(slot_in_backpack) //used entirely for equipping spawned mobs or at round start
			var/allow = 0
			if(H.back)
				if(istype(H.back, /obj/item/weapon/storage/backpack))
					var/obj/item/weapon/storage/backpack/B = H.back
					if(B.can_be_inserted(src,M,1))
						allow = 1

				else if(istype(H.back, /obj/item/weapon/rig))
					var/obj/item/weapon/rig/rig = H.back
					if (rig.storage && rig.storage.container.can_be_inserted(src,M,1))
						allow = 1
			if(!allow)
				return 0
		if(slot_tie)
			if((!H.w_uniform && (slot_w_uniform in mob_equip)) && (!H.wear_suit && (slot_wear_suit in mob_equip)))
				if(!disable_warning)
					to_chat(H, "<span class='warning'>You need something you can attach \the [src] to.</span>")
				return 0
			if(H.w_uniform && (slot_w_uniform in mob_equip))
				var/obj/item/clothing/under/uniform = H.w_uniform
				if(uniform && !uniform.can_attach_accessory(src))
					if (!disable_warning)
						to_chat(H, "<span class='warning'>You cannot equip \the [src] to \the [uniform].</span>")
					return 0
				else return 1
			if(H.wear_suit && (slot_wear_suit in mob_equip))
				var/obj/item/clothing/suit/suit = H.wear_suit
				if(suit && !suit.can_attach_accessory(src))
					if (!disable_warning)
						to_chat(H, "<span class='warning'>You cannot equip \the [src] to \the [suit].</span>")
					return 0


	return 1

/obj/item/proc/mob_can_unequip(mob/M, slot, disable_warning = 0)
	if(!slot) return 0
	if(!M) return 0

	if(!canremove)
		return 0
	if(!M.slot_is_accessible(slot, src, disable_warning? null : M))
		return 0
	return 1

/obj/item/verb/verb_pickup()
	set src in oview(1)
	set category = "Object"
	set name = "Pick up"

	if(!(usr)) //BS12 EDIT
		return
	if(!CanPhysicallyInteract(usr))
		return
	if((!istype(usr, /mob/living/carbon)) || (istype(usr, /mob/living/carbon/brain)))//Is humanoid, and is not a brain
		to_chat(usr, "<span class='warning'>You can't pick things up!</span>")
		return
	if( usr.stat || usr.restrained() )//Is not asleep/dead and is not restrained
		to_chat(usr, "<span class='warning'>You can't pick things up!</span>")
		return
	if(src.anchored) //Object isn't anchored
		to_chat(usr, "<span class='warning'>You can't pick that up!</span>")
		return
	if(!usr.hand && usr.r_hand) //Right hand is not full
		to_chat(usr, "<span class='warning'>Your right hand is full.</span>")
		return
	if(usr.hand && usr.l_hand) //Left hand is not full
		to_chat(usr, "<span class='warning'>Your left hand is full.</span>")
		return
	if(!istype(src.loc, /turf)) //Object is on a turf
		to_chat(usr, "<span class='warning'>You can't pick that up!</span>")
		return
	//All checks are done, time to pick it up!
	usr.UnarmedAttack(src)
	return


//This proc is executed when someone clicks the on-screen UI button. To make the UI button show, set the 'icon_action_button' to the icon_state of the image of the button in screen1_action.dmi
//The default action is attack_self().
//Checks before we get to here are: mob is alive, mob is not restrained, paralyzed, asleep, resting, laying, item is on the mob.
/obj/item/proc/ui_action_click()
	attack_self(usr)




/obj/item/proc/eyestab(mob/living/carbon/M as mob, mob/living/carbon/user as mob)

	var/mob/living/carbon/human/H = M
	if(istype(H))
		for(var/obj/item/protection in list(H.head, H.wear_mask, H.glasses))
			if(protection && (protection.body_parts_covered & EYES))
				// you can't stab someone in the eyes wearing a mask!
				to_chat(user, "<span class='warning'>You're going to need to remove the eye covering first.</span>")
				return

	if(!M.has_eyes())
		to_chat(user, "<span class='warning'>You cannot locate any eyes on [M]!</span>")
		return

	admin_attack_log(user, M, "Attacked using \a [src]", "Was attacked with \a [src]", "used \a [src] to attack")

	user.set_click_cooldown(DEFAULT_ATTACK_COOLDOWN)
	user.do_attack_animation(M)

	src.add_fingerprint(user)
	//if((CLUMSY in user.mutations) && prob(50))
	//	M = user
		/*
		to_chat(M, "<span class='warning'>You stab yourself in the eye.</span>")
		M.sdisabilities |= BLIND
		M.weakened += 4
		M.adjustBruteLoss(10)
		*/

	if(istype(H))

		var/obj/item/organ/internal/eyes/eyes = H.internal_organs_by_name[BP_EYES]

		if(H != user)
			for(var/mob/O in (viewers(M) - user - M))
				O.show_message("<span class='danger'>[M] has been stabbed in the eye with [src] by [user].</span>", 1)
			to_chat(M, "<span class='danger'>[user] stabs you in the eye with [src]!</span>")
			to_chat(user, "<span class='danger'>You stab [M] in the eye with [src]!</span>")
		else
			user.visible_message( \
				"<span class='danger'>[user] has stabbed themself with [src]!</span>", \
				"<span class='danger'>You stab yourself in the eyes with [src]!</span>" \
			)

		eyes.damage += rand(3,4)
		if(eyes.damage >= eyes.min_bruised_damage)
			if(M.stat != 2)
				if(!BP_IS_ROBOTIC(eyes)) //robot eyes bleeding might be a bit silly
					to_chat(M, "<span class='danger'>Your eyes start to bleed profusely!</span>")
			if(prob(50))
				if(M.stat != 2)
					to_chat(M, "<span class='warning'>You drop what you're holding and clutch at your eyes!</span>")
					M.unequip_item()
				M.eye_blurry += 10
				M.Paralyse(1)
				M.Weaken(4)
			if (eyes.damage >= eyes.min_broken_damage)
				if(M.stat != 2)
					to_chat(M, "<span class='warning'>You go blind!</span>")

		var/obj/item/organ/external/affecting = H.get_organ(eyes.parent_organ)
		affecting.take_external_damage(7)
	else
		M.take_organ_damage(7)
	M.eye_blurry += rand(3,4)
	return

/obj/item/clean_blood()
	. = ..()
	if(blood_overlay)
		overlays.Remove(blood_overlay)
	if(istype(src, /obj/item/clothing/gloves))
		var/obj/item/clothing/gloves/G = src
		G.transfer_blood = 0

/obj/item/reveal_blood()
	if(was_bloodied && !fluorescent)
		fluorescent = 1
		blood_color = COLOR_LUMINOL
		blood_overlay.color = COLOR_LUMINOL
		update_icon()

/obj/item/add_blood(mob/living/carbon/human/M as mob)
	if (!..())
		return 0

	if(istype(src, /obj/item/weapon/melee/energy))
		return

	//if we haven't made our blood_overlay already
	if( !blood_overlay )
		generate_blood_overlay()

	//apply the blood-splatter overlay if it isn't already in there
	if(!blood_DNA.len)
		blood_overlay.color = blood_color
		overlays += blood_overlay

	//if this blood isn't already in the list, add it
	if(istype(M))
		if(blood_DNA[M.dna.unique_enzymes])
			return 0 //already bloodied with this blood. Cannot add more.
		blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
	return 1 //we applied blood to the item

/obj/item/proc/generate_blood_overlay()
	if(blood_overlay)
		return

	var/icon/I = new /icon(icon, icon_state)
	I.Blend(new /icon('icons/effects/blood.dmi', rgb(255,255,255)),ICON_ADD) //fills the icon_state with white (except where it's transparent)
	I.Blend(new /icon('icons/effects/blood.dmi', "itemblood"),ICON_MULTIPLY) //adds blood and the remaining white areas become transparant

	//not sure if this is worth it. It attaches the blood_overlay to every item of the same type if they don't have one already made.
	for(var/obj/item/A in world)
		if(A.type == type && !A.blood_overlay)
			A.blood_overlay = image(I)

/obj/item/proc/showoff(mob/user)
	for (var/mob/M in view(user))
		M.show_message("[user] holds up [src]. <a HREF=?src=\ref[M];lookitem=\ref[src]>Take a closer look.</a>",1)

/mob/living/carbon/verb/showoff()
	set name = "Show Held Item"
	set category = "Object"

	var/obj/item/I = get_active_hand()
	if(I && I.simulated)
		I.showoff(src)

/*
THIS SCOPE CODE IS DEPRECATED, USE AIM MODES INSTEAD.
*/
//Looking through a scope or binoculars should /not/ improve your periphereal vision. Still, increase viewsize a tiny bit so that sniping isn't as restricted to NSEW
/obj/item/proc/zoom(mob/user, var/tileoffset = 14,var/viewsize = 9) //tileoffset is client view offset in the direction the user is facing. viewsize is how far out this thing zooms. 7 is normal view
	/*
	if(!user.client)
		return
	if(zoom)
		return

	var/devicename = zoomdevicename || name

	var/mob/living/carbon/human/H = user
	if(user.incapacitated(INCAPACITATION_DISABLED))
		to_chat(user, "<span class='warning'>You are unable to focus through the [devicename].</span>")
		return
	else if(!zoom && istype(H) && H.equipment_tint_total >= TINT_MODERATE)
		to_chat(user, "<span class='warning'>Your visor gets in the way of looking through the [devicename].</span>")
		return
	else if(!zoom && user.get_active_hand() != src)
		to_chat(user, "<span class='warning'>You are too distracted to look through the [devicename], perhaps if it was in your active hand this might work better.</span>")
		return

	if(user.hud_used.hud_shown)
		user.toggle_zoom_hud()	// If the user has already limited their HUD this avoids them having a HUD when they zoom in
	//user.client.view = viewsize
	zoom = 1

	var/viewoffset = WORLD_ICON_SIZE * tileoffset
	switch(user.dir)
		if (NORTH)
			user.client.pixel_x = 0
			user.client.pixel_y = viewoffset
		if (SOUTH)
			user.client.pixel_x = 0
			user.client.pixel_y = -viewoffset
		if (EAST)
			user.client.pixel_x = viewoffset
			user.client.pixel_y = 0
		if (WEST)
			user.client.pixel_x = -viewoffset
			user.client.pixel_y = 0

	user.visible_message("\The [user] peers through [zoomdevicename ? "the [zoomdevicename] of [src]" : "[src]"].")

	GLOB.destroyed_event.register(src, src, /obj/item/proc/unzoom)
	GLOB.moved_event.register(src, src, /obj/item/proc/unzoom)
	GLOB.dir_set_event.register(src, src, /obj/item/proc/unzoom)
	GLOB.item_unequipped_event.register(src, src, /obj/item/proc/zoom_drop)
	GLOB.stat_set_event.register(user, src, /obj/item/proc/unzoom)
	*/

/obj/item/proc/zoom_drop(var/obj/item/I, var/mob/user)
	unzoom(user)

/obj/item/proc/unzoom(var/mob/user)
	if(!zoom)
		return
	zoom = 0

	GLOB.destroyed_event.unregister(src, src, /obj/item/proc/unzoom)
	GLOB.moved_event.unregister(src, src, /obj/item/proc/unzoom)
	GLOB.dir_set_event.unregister(src, src, /obj/item/proc/unzoom)
	GLOB.item_unequipped_event.unregister(src, src, /obj/item/proc/zoom_drop)

	user = user == src ? loc : (user || loc)
	if(!istype(user))
		return

	GLOB.stat_set_event.unregister(user, src, /obj/item/proc/unzoom)

	if(!user.client)
		return

	//user.client.view = world.view
	if(!user.hud_used.hud_shown)
		user.toggle_zoom_hud()

	user.client.pixel_x = 0
	user.client.pixel_y = 0
	user.visible_message("[zoomdevicename ? "\The [user] looks up from [src]" : "\The [user] lowers [src]"].")

/obj/item/proc/pwr_drain()
	return 0 // Process Kill

/obj/item/proc/use_spritesheet(var/bodytype, var/slot, var/icon_state)
	if(!sprite_sheets || !sprite_sheets[bodytype])
		return 0
	if(slot == slot_r_hand_str || slot == slot_l_hand_str)
		return 0

	if(icon_state in icon_states(sprite_sheets[bodytype]))
		return 1

	return (slot != slot_wear_suit_str && slot != slot_head_str)

/obj/item/proc/get_icon_state(mob/user_mob, slot)
	var/mob_state
	if(item_state_slots && item_state_slots[slot])
		mob_state = item_state_slots[slot]
	else if (item_state)
		mob_state = item_state
	else
		mob_state = icon_state

	var/mob/living/carbon/human/user_human
	if(ishuman(user_mob))
		user_human = user_mob
		if (user_human.lying && user_human.species.icon_lying)
			mob_state = "[mob_state][user_human.species.icon_lying]"
	return mob_state


/obj/item/proc/get_mob_overlay(mob/user_mob, slot)
	var/bodytype = "Default"
	var/mob/living/carbon/human/user_human
	if(ishuman(user_mob))
		user_human = user_mob
		bodytype = user_human.species.get_bodytype(user_human)

	var/mob_state = get_icon_state(user_mob, slot)

	var/mob_icon
	var/spritesheet = FALSE
	if(icon_override)
		mob_icon = icon_override
		if(slot == 	slot_l_hand_str || slot == slot_l_ear_str)
			mob_state = "[mob_state]_l"
		if(slot == 	slot_r_hand_str || slot == slot_r_ear_str)
			mob_state = "[mob_state]_r"
	else if(use_spritesheet(bodytype, slot, mob_state))
		if(slot == slot_l_ear)
			mob_state = "[mob_state]_l"
		if(slot == slot_r_ear)
			mob_state = "[mob_state]_r"
		spritesheet = TRUE
		mob_icon = sprite_sheets[bodytype]
	else if(item_icons && item_icons[slot])
		mob_icon = item_icons[slot]
	else
		mob_icon = default_onmob_icons[slot]

	if(user_human)
		return user_human.species.get_offset_overlay_image(spritesheet, mob_icon, mob_state, color, slot)
	return overlay_image(mob_icon, mob_state, color, RESET_COLOR)

/obj/item/proc/get_examine_line()
	if(blood_DNA)
		. = "<span class='warning'>\icon[src] [gender==PLURAL?"some":"a"] [(blood_color != SYNTH_BLOOD_COLOUR) ? "blood" : "oil"]-stained [src]</span>"
	else
		. = "\icon[src] \a [src]"
	var/ID = GetIdCard()
	if(ID)
		. += "  <a href='?src=\ref[ID];look_at_id=1'>\[Look at ID\]</a>"

/obj/item/is_burnable()
	return simulated

/obj/item/lava_act()
	. = (!throwing) ? ..() : FALSE

/obj/item/proc/is_equipped()
	if (ismob(loc))
		return (equip_slot != slot_none)


/obj/item/proc/is_worn()
	//If equip_slot is zero then it has never been equipped
	if (equip_slot == slot_none)
		return FALSE

	if (ismob(loc))
		return !(equip_slot in unworn_slots)


/obj/item/proc/is_held()
	//If equip_slot is zero then it has never been equipped
	if (equip_slot == slot_none)
		return FALSE

	if (ismob(loc))
		return equip_slot in list(slot_l_hand, slot_r_hand,slot_robot_equip_1,slot_robot_equip_2,slot_robot_equip_3)


/obj/item/proc/get_equip_slot()
	if (ismob(loc))
		return equip_slot
	else
		return slot_none


/obj/item/proc/update_wear_icon()
	if (ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.update_slot(equip_slot)



//Called when a structure takes damage
/obj/item/proc/take_damage(var/amount, var/damtype = BRUTE, var/user, var/used_weapon, var/bypass_resist = FALSE)
	if ((atom_flags & ATOM_FLAG_INDESTRUCTIBLE))
		return
	if (!bypass_resist)
		amount -= resistance

	if (amount <= 0)
		return FALSE
	health -= amount

	updatehealth()


//Sets an object's health to a percenrage of its max health. Calls all the usual updating functions
/obj/item/proc/set_healthpercent(var/percentage)
	health = max_health * percentage
	updatehealth()


/obj/item/proc/updatehealth()
	if (health <= 0)
		health = 0
		return zero_health()//Some zero health overrides do things with a return value
	else
		update_icon()
		return TRUE

//Called when health drops to zero. Parameters are the params of the final hit that broke us, if this was called from take_damage
/obj/item/proc/zero_health(var/amount, var/damtype = BRUTE, var/user, var/used_weapon, var/bypass_resist)

	//To cut down on spam, we'll only display a message for items broken while attached to a mob, So that we don't get a million messages from an explosion
	if (ismob(loc))
		var/mob/M = loc
		M.visible_message(SPAN_WARNING(replacetext(break_message, "SELF", src.name)))
	qdel(src)
	return TRUE



/*
	Defensive handling
*/
/obj/item/proc/handle_block(var/datum/strike/strike)
	var/blocked_damage = max(w_class*3, min(health+resistance, strike.damage))
	strike.blocked_damage += blocked_damage
	strike.blocker = src
	spawn()
		take_damage(blocked_damage, strike.damage_type, strike.user, strike.used_weapon, bypass_resist = FALSE)


/obj/item/proc/can_block(var/datum/strike/strike)

	//An object can't block itself
	if (strike && strike.used_weapon == src)
		return FALSE

	//Items must be a certain minimum size to be used for blocking
	if (w_class < ITEM_SIZE_NORMAL)
		return FALSE

	if (base_parry_chance > 0)
		return TRUE
	return FALSE

//Items which aren't especially designed for melee combat have a pretty low block chance.
/obj/item/proc/get_block_chance(var/datum/strike/strike)
	return base_parry_chance

//When swinging this weapon, this cooldown
/obj/item/proc/get_delay(var/mob/living/user)
	var/delay = attack_cooldown + w_class
	if (user)
		delay /= user.attack_speed_factor

	return delay


/obj/item/proc/store_item(var/obj/item/input, var/mob/user)
	return FALSE



/obj/item/repair(var/repair_power, var/datum/repair_source, var/mob/user)
	health = clamp(health+repair_power, 0, max_health)
	updatehealth()
	update_icon()


/obj/item/repair_needed()
	return max_health - health