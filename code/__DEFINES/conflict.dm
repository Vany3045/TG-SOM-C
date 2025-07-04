//click cooldowns, in tenths of a second, used for various combat actions
#define CLICK_CD_FASTEST 1
#define CLICK_CD_RAPID 2
#define CLICK_CD_RANGE 4
#define CLICK_CD_CLICK_ABILITY 6
#define CLICK_CD_MELEE 8
#define CLICK_CD_HANDCUFFED 10
#define CLICK_CD_GRABBING 10
#define CLICK_CD_RESIST 10
#define CLICK_CD_LONG 20
#define CLICK_CD_RESIST_PSYCHIC_GRAB 30
#define CLICK_CD_BREAKOUT 100

//Grab levels
#define GRAB_PASSIVE 0
#define GRAB_AGGRESSIVE 1
#define GRAB_NECK 2
#define GRAB_KILL 3

//TK Grab levels
#define TKGRAB_NONLETHAL 3	//Values should be different as they are identifiers.
#define TKGRAB_LETHAL 4	//Also serves as a measure of how many attempts to resist it.

//intent defines
#define INTENT_HELP "help"
#define INTENT_GRAB "grab"
#define INTENT_DISARM "disarm"
#define INTENT_HARM "harm"
//NOTE: INTENT_HOTKEY_* defines are not actual intents!
//they are here to support hotkeys
#define INTENT_HOTKEY_LEFT "left"
#define INTENT_HOTKEY_RIGHT "right"
//intent magic numbers associations.
#define INTENT_NUMBER_HELP 0
#define INTENT_NUMBER_DISARM 1
#define INTENT_NUMBER_GRAB 2
#define INTENT_NUMBER_HARM 3

//Ammo defines for gun/projectile related things.
//ammo_behavior_flags

///Ammo will impact a targeted open turf instead of continuing past it
#define AMMO_TARGET_TURF (1<<0)
///Xeno type projectile
#define AMMO_XENO (1<<1)
///poor accuracy against humans
#define AMMO_UNWIELDY (1<<2)
///Ammo will pass through windows and has damage reduced by smokes with SMOKE_NERF_BEAM
#define AMMO_ENERGY (1<<3)
///Ammo is more likely to continue past cover such as cades
#define AMMO_SNIPER (1<<4)
///Ammo will attempt to add firestacks and ignite a hit mob if it deals any damage
#define AMMO_INCENDIARY (1<<5)
///Ammo type entirely ignores xenos
#define AMMO_SKIPS_ALIENS (1<<6)
///Generates blood splatters on mob hit
#define AMMO_BALLISTIC (1<<7)
///Ammo processes while traveling
#define AMMO_SPECIAL_PROCESS (1<<8)
///Used to identify flamethrower projectiles and similar projectiles
#define AMMO_FLAME (1<<9)
///Used to identify ammo that have intrinsec IFF properties
#define AMMO_IFF (1<<10)
///If the projectile from this ammo is hitscan
#define AMMO_HITSCAN (1<<11)
///If the projectile does something with on_leave_turf()
#define AMMO_LEAVE_TURF (1<<12)
///If the projectile passes through walls causing damage to them
#define AMMO_PASS_THROUGH_TURF (1<<13)
///If the projectile passes through mobs and objects causing damage to them
#define AMMO_PASS_THROUGH_MOVABLE (1<<14)
///If the projectile passes through mobs only causing damage to them
#define AMMO_PASS_THROUGH_MOB (1<<15)
///If the projectile ricochet and miss sound is pitched up
#define AMMO_SOUND_PITCH (1<<16)
///Used to identify ammo from sentry guns and other other automated sources
#define AMMO_SENTRY (1<<17)

//Gun defines for gun related thing. More in the projectile folder.
//gun_features_flags
#define GUN_CAN_POINTBLANK (1<<0)
#define GUN_UNUSUAL_DESIGN (1<<1)
#define GUN_AMMO_COUNTER (1<<2)
#define GUN_WIELDED_FIRING_ONLY (1<<3)
#define GUN_ALLOW_SYNTHETIC (1<<4)
#define GUN_WIELDED_STABLE_FIRING_ONLY (1<<5)
#define GUN_IFF (1<<6)
#define GUN_DEPLOYED_FIRE_ONLY (1<<7)
#define GUN_IS_ATTACHMENT (1<<8)
#define GUN_ATTACHMENT_FIRE_ONLY (1<<9)
#define GUN_ENERGY (1<<10)
#define GUN_AMMO_COUNT_BY_PERCENTAGE (1<<11)
#define GUN_AMMO_COUNT_BY_SHOTS_REMAINING (1<<12)
#define GUN_NO_PITCH_SHIFT_NEAR_EMPTY (1<<13)
#define GUN_SHOWS_AMMO_REMAINING (1<<14) //Whether the mob sprite reflects the ammo level
#define GUN_SHOWS_LOADED (1<<15) //Whether the mob sprite as loaded or unloaded, a binary version of the above
#define GUN_SMOKE_PARTICLES (1<<16) //Whether the gun has smoke particles

//reciever_flags. Used to determin how the gun cycles, what kind of ammo it uses, etc.
#define AMMO_RECIEVER_REQUIRES_UNIQUE_ACTION (1<<0)
	#define AMMO_RECIEVER_UNIQUE_ACTION_LOCKS (1<<1)
#define AMMO_RECIEVER_MAGAZINES (1<<2)
	#define AMMO_RECIEVER_AUTO_EJECT (1<<3)
#define AMMO_RECIEVER_HANDFULS (1<<4)
#define AMMO_RECIEVER_TOGGLES_OPEN (1<<5)
	#define AMMO_RECIEVER_TOGGLES_OPEN_EJECTS (1<<6)
#define AMMO_RECIEVER_CLOSED (1<<7)
#define AMMO_RECIEVER_ROTATES_CHAMBER (1<<8)
#define AMMO_RECIEVER_DO_NOT_EJECT_HANDFULS (1<<9)
#define AMMO_RECIEVER_DO_NOT_EMPTY_ROUNDS_AFTER_FIRE (1<<10)
#define AMMO_RECIEVER_CYCLE_ONLY_BEFORE_FIRE (1<<11) //The ammo stay in the magazine until the last moment
#define AMMO_RECIEVER_AUTO_EJECT_LOCKED (1<<12) //Not allowed to turn automatic unloading off

#define FLAMER_IS_LIT (1<<0)
#define FLAMER_NO_LIT_OVERLAY (1<<1)
#define FLAMER_USES_GUN_FLAMES (1<<2)

#define FLAMER_STREAM_STRAIGHT "straight"
#define FLAMER_STREAM_CONE "cone"
#define FLAMER_STREAM_RANGED "ranged"

#define GUN_FIREMODE_SEMIAUTO "semi-auto fire mode"
#define GUN_FIREMODE_BURSTFIRE "burst-fire mode"
#define GUN_FIREMODE_AUTOMATIC "automatic fire mode"
#define GUN_FIREMODE_AUTOBURST "auto-burst-fire mode"

//autofire component fire callback callback return flags
#define AUTOFIRE_CONTINUE (1<<0)
#define AUTOFIRE_SUCCESS (1<<1)

//Ammo magazine defines, for magazine_flags
#define MAGAZINE_REFILLABLE (1<<0)
#define MAGAZINE_HANDFUL (1<<1)
#define MAGAZINE_WORN (1<<2)
#define MAGAZINE_REFUND_IN_CHAMBER (1<<3)
#define MAGAZINE_NOT_FABRICABLE (1<<4)
///ammo count shown on mag sprite
#define MAGAZINE_SHOW_AMMO (1<<5)

//Slowdown from various armors.
#define SHOES_SLOWDOWN -1.0			// How much shoes slow you down by default. Negative values speed you up

#define SLOWDOWN_ARMOR_VERY_LIGHT 0.25
#define SLOWDOWN_ARMOR_LIGHT 0.3
#define SLOWDOWN_ARMOR_MEDIUM 0.5
#define SLOWDOWN_ARMOR_HEAVY 0.75
#define SLOWDOWN_ARMOR_VERY_HEAVY 1

//Marine armor defines
#define MARINE_ARMOR_LIGHT list(MELEE = 35, BULLET = 50, LASER = 50, ENERGY = 30, BOMB = 10, BIO = 30, FIRE = 5, ACID = 35)
#define MARINE_ARMOR_MEDIUM list(MELEE = 45, BULLET = 60, LASER = 60, ENERGY = 40, BOMB = 20, BIO = 40, FIRE = 10, ACID = 45)
#define MARINE_ARMOR_HEAVY list(MELEE = 55, BULLET = 70, LASER = 70, ENERGY = 50, BOMB = 30, BIO = 50, FIRE = 15, ACID = 55)
#define MARINE_HAT_ARMOR list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 10, BIO = 5, FIRE = 5, ACID = 5)

//=================================================

//Define detpack
#define DETPACK_TIMER_MIN 5
#define DETPACK_TIMER_MAX 300

//Define sniper laser multipliers

#define SNIPER_LASER_DAMAGE_MULTIPLIER 1.5 //+50% damage vs the aimed target

//Define lasrifle
#define ENERGY_STANDARD_AMMO_COST 20
#define ENERGY_OVERCHARGE_AMMO_COST 80
#define ENERGY_OVERCHARGE_FIRE_DELAY 10

//Define stagger damage multipliers
#define STAGGER_DAMAGE_MULTIPLIER 0.5 //-50% damage dealt by the staggered target after all other mods.

//Define smoke effects
#define SMOKE_COUGH (1<<0)
#define SMOKE_GASP (1<<1)
#define SMOKE_OXYLOSS (1<<2)
#define SMOKE_FOUL (1<<3)
#define SMOKE_NERF_BEAM (1<<4)
#define SMOKE_CAMO (1<<5)
#define SMOKE_SLEEP (1<<6)
#define SMOKE_BLISTERING (1<<7)
#define SMOKE_PLASMALOSS (1<<8)
#define SMOKE_XENO (1<<9)
#define SMOKE_XENO_ACID (1<<10)
#define SMOKE_XENO_NEURO (1<<11)
#define SMOKE_XENO_HEMODILE (1<<12)
#define SMOKE_XENO_TRANSVITOX (1<<13)
#define SMOKE_CHEM (1<<14)
/// Extinguishes fires and mobs that are on fire
#define SMOKE_EXTINGUISH (1<<15)
/// Effectively a sub-flag of Neuro; precludes higher impact effects
#define SMOKE_NEURO_LIGHT (1<<16)
/// Smoke that pacifies huggers in its area; mainly used for vision blocking smoke
#define SMOKE_HUGGER_PACIFY (1<<17)
/// Toxic crimson smoke created by the Defiler's Defile ability.
#define SMOKE_XENO_SANGUINAL (1<<18)
/// Smoke that purges chemicals and does minor capped toxin damage for Defiler.
#define SMOKE_XENO_OZELOMELYN (1<<19)
/// Nerve agent that purges painkillers and causes increasing pain
#define SMOKE_SATRAPINE (1<<20)
/// Deals damage to anyone inside it and inflicts the intoxicated debuff, dealing damage over time
#define SMOKE_XENO_TOXIC (1<<21)
/// This smoke removes any smoke has this in its effects_cycle, that removes certain types of smokes.
#define SMOKE_PURGER (1<<22)
/// Smoke that acts like SMOKE_BLISTERING for non-xenos and applies pyrogen's melting fire status effect when entering.
#define SMOKE_XENO_PYROGEN (1<<23)

//Incapacitated
#define INCAPACITATED_IGNORE_RESTRAINED (1<<0)
#define INCAPACITATED_IGNORE_GRAB (1<<1)


//Restraints
#define RESTRAINED_XENO_NEST (1<<0)
#define RESTRAINED_NECKGRAB (1<<1)
#define RESTRAINED_STRAIGHTJACKET (1<<2)
#define RESTRAINED_RAZORWIRE (1<<3)
#define RESTRAINED_PSYCHICGRAB (1<<4)

#define SINGLE_CASING (1 << 0)
#define SPEEDLOADER (1 << 1)
#define MAGAZINE (1 << 2)
#define CELL (1 << 3)
#define POWERPACK (1 << 4)

#define EGG_BURST 0
#define EGG_BURSTING 1
#define EGG_GROWING 2
#define EGG_GROWN 3
#define EGG_DESTROYED 4

#define EGG_MIN_GROWTH_TIME 10 SECONDS //time it takes for the egg to mature once planted
#define EGG_MAX_GROWTH_TIME 15 SECONDS

#define EGG_GAS_DEFAULT_SPREAD 3
#define EGG_GAS_KILL_SPREAD 4


//We will round to this value in damage calculations.
#define DAMAGE_PRECISION 0.1

#define MAX_PARALYSE_AMOUNT_FOR_PARALYSE_RESISTANT 2 SECONDS

// No neighbors
#define NEIGHBORS_NONE  0
// Cardinal neighborhood
#define NEIGHBORS_CARDINAL 1
// Ordinal neighborhood
#define NEIGHBORS_ORDINAL  2
// Note that NEIGHBORS_CARDINAL | NEIGHBORS_ORDINALS gives you all 8 surrounding neighbors

/// how much it takes to gib a mob
#define EXPLOSION_THRESHOLD_GIB 200 // maybe should change it to 300?
/// prone mobs receive less damage from explosions
#define EXPLOSION_PRONE_MULTIPLIER 0.5

//Explosion damage multipliers for different objects
#define EXPLOSION_DAMAGE_MULTIPLIER_DOOR 5
#define EXPLOSION_DAMAGE_MULTIPLIER_DOOR_OPEN 0.5
#define EXPLOSION_DAMAGE_MULTIPLIER_WALL 7.5
#define EXPLOSION_DAMAGE_MULTIPLIER_WINDOW 5

//Explosion damage multipliers for different objects
#define RESIN_EXPLOSIVE_MULTIPLIER 0.85

// What kind of function to use for Explosions falling off.
#define EXPLOSION_FALLOFF_SHAPE_LINEAR 1
#define EXPLOSION_FALLOFF_SHAPE_EXPONENTIAL 2
#define EXPLOSION_FALLOFF_SHAPE_EXPONENTIAL_HALF 3

#define EXPLOSION_MAX_POWER 5000

//Damage modificator
#define PRED_MELEE_DAMAGE_MOD 0.5

//Cave comms defines
/// No impact on comms
#define CAVE_NO_INTERFERENCE 0
/// Scrambles outgoing messages, no impact on incoming.
#define CAVE_MINOR_INTERFERENCE 1
/// Prevents incoming and outgoing messages.
#define CAVE_FULL_INTERFERENCE 2

/// Time needed to initially configure an antenna module after equipping
#define ANTENNA_SYNCING_TIME 30 SECONDS

#define CADE_TYPE_BOMB "concussive armor"
#define CADE_TYPE_MELEE "ballistic armor"
#define CADE_TYPE_ACID "caustic armor"
