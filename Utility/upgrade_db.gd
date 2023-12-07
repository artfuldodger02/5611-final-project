extends Node


const ICON_PATH = "res://Sprites/Upgrades/"
const WEAPON_PATH = "res://Sprites/Weapons/"

const UPGRADES = {
	"icespear1": {
		"icon": WEAPON_PATH + "sprite_1.png",
		"displayname": "Ice Spear",
		"details": "Hurls a spear of ice at a random enemy",
		"level": "Level: 1",
		"prereq": [],
		"type": "weapon"
		},
	"icespear2": {
		"icon": WEAPON_PATH + "sprite_1.png",
		"displayname": "Ice Spear",
		"details": "Summon an additional spear",
		"level": "Level: 2",
		"prereq": ["icespear1"],
		"type": "weapon"
		},
		
	"icespear3": {
		"icon": WEAPON_PATH + "sprite_1.png",
		"displayname": "Ice Spear",
		"details": "Ice Spears now pass through another enemy and do additional damage",
		"level": "Level: 3",
		"prereq": ["icespear2"],
		"type": "weapon"
	},
	"icespear4": {
		"icon": WEAPON_PATH + "sprite_1.png",
		"displayname": "Ice Spear",
		"details": "An additional 2 Ice Spears are thrown",
		"level": "Level: 4",
		"prereq": ["icespear3"],
		"type": "weapon"
		},
		
	"dragonlance1": {
		"icon": WEAPON_PATH + "sprite_5.png",
		"displayname": "Dragon Lance",
		"details": "A draconic lance will follow you and attack random enemies",
		"level": "Level: 1",
		"prereq": [],
		"type": "weapon"
	},
	"dragonlance2": {
		"icon": WEAPON_PATH + "sprite_5.png",
		"displayname": "Dragon Lance",
		"details": "The lance will now attack an additional enemy",
		"level": "Level: 2",
		"prereq": ["dragonlance1"],
		"type": "weapon"
	},
	"dragonlance3": {
		"icon": WEAPON_PATH + "sprite_5.png",
		"displayname": "Dragon Lance",
		"details": "The lance will now attack another additional enemy",
		"level": "Level: 3",
		"prereq": ["dragonlance2"],
		"type": "weapon"
	},
	"dragonlance4": {
		"icon": WEAPON_PATH + "sprite_5.png",
		"displayname": "Dragon Lance",
		"details": "The lance now does more damage and knockback",
		"level": "Level: 4",
		"prereq": ["dragonlance3"],
		"type": "weapon"
	},
	
	"whirlwind1": {
		"icon": WEAPON_PATH + "sprite_3.png",
		"displayname": "Fan of Gusts",
		"details": "Summon a whirlwind in the direction you are facing",
		"level": "Level: 1",
		"prereq": [],
		"type": "weapon"
	},
	"whirlwind2": {
		"icon": WEAPON_PATH + "sprite_3.png",
		"displayname": "Fan of Gusts",
		"details": "Summon an additional whirlwind",
		"level": "Level: 2",
		"prereq": ["whirlwind1"],
		"type": "weapon"
	},
	"whirlwind3": {
		"icon": WEAPON_PATH + "sprite_3.png",
		"displayname": "Fan of Gusts",
		"details": "Reduces the cooldown between whirlwinds",
		"level": "Level: 3",
		"prereq": ["whirlwind2"],
		"type": "weapon"
	},
	"whirlwind4": {
		"icon": WEAPON_PATH + "sprite_3.png",
		"displayname": "Fan of Gusts",
		"details": "Summon another additional whirlwind and increase knockback",
		"level": "Level: 4",
		"prereq": ["whirlwind3"],
		"type": "weapon"
	},
	
	"armor1": {
		"icon": ICON_PATH + "helmet4_visor.png",
		"displayname": "Armor",
		"details": "Reduces Damage By 1 point",
		"level": "Level: 1",
		"prereq": [],
		"type": "upgrade"
	},
	"armor2": {
		"icon": ICON_PATH + "helmet4_visor.png",
		"displayname": "Armor",
		"details": "Reduces Damage By an additional 1 point",
		"level": "Level: 2",
		"prereq": ["armor1"],
		"type": "upgrade"
	},
	"armor3": {
		"icon": ICON_PATH + "helmet4_visor.png",
		"displayname": "Armor",
		"details": "Reduces Damage By an additional 1 point",
		"level": "Level: 3",
		"prereq": ["armor2"],
		"type": "upgrade"
	},
	"armor4": {
		"icon": ICON_PATH + "helmet4_visor.png",
		"displayname": "Armor",
		"details": "Reduces Damage By an additional 1 point",
		"level": "Level: 4",
		"prereq": ["armor3"],
		"type": "upgrade"
	},
	
	"speed1": {
		"icon": ICON_PATH + "boots4_green.png",
		"displayname": "Speed",
		"details": "Movement Speed Increased by 50% of base speed",
		"level": "Level: 1",
		"prereq": [],
		"type": "upgrade"
	},
	"speed2": {
		"icon": ICON_PATH + "boots4_green.png",
		"displayname": "Speed",
		"details": "Movement Speed Increased by an additional 50% of base speed",
		"level": "Level: 2",
		"prereq": ["speed1"],
		"type": "upgrade"
	},
	"speed3": {
		"icon": ICON_PATH + "boots4_green.png",
		"displayname": "Speed",
		"details": "Movement Speed Increased by an additional 50% of base speed",
		"level": "Level: 3",
		"prereq": ["speed2"],
		"type": "upgrade"
	},
	"speed4": {
		"icon": ICON_PATH + "boots_4_green.png",
		"displayname": "Speed",
		"details": "Movement Speed Increased an additional 50% of base speed",
		"level": "Level: 4",
		"prereq": ["speed3"],
		"type": "upgrade"
	},
	
	"tome1": {
		"icon": ICON_PATH + "purple.png",
		"displayname": "Tome",
		"details": "Increases the size of spells an additional 10% of their base size",
		"level": "Level: 1",
		"prereq": [],
		"type": "upgrade"
	},
	"tome2": {
		"icon": ICON_PATH + "purple.png",
		"displayname": "Tome",
		"details": "Increases the size of spells an additional 10% of their base size",
		"level": "Level: 2",
		"prereq": ["tome1"],
		"type": "upgrade"
	},
	"tome3": {
		"icon": ICON_PATH + "purple.png",
		"displayname": "Tome",
		"details": "Increases the size of spells an additional 10% of their base size",
		"level": "Level: 3",
		"prereq": ["tome2"],
		"type": "upgrade"
	},
	"tome4": {
		"icon": ICON_PATH + "purple.png",
		"displayname": "Tome",
		"details": "Increases the size of spells an additional 10% of their base size",
		"level": "Level: 4",
		"prereq": ["tome3"],
		"type": "upgrade"
	},
	
	"scroll1": {
		"icon": ICON_PATH + "scroll.png",
		"displayname": "Scroll",
		"details": "Decreases of the cooldown of spells by an additional 5% of their base time",
		"level": "Level: 1",
		"prereq": [],
		"type": "upgrade"
	},
	"scroll2": {
		"icon": ICON_PATH + "scroll.png",
		"displayname": "Scroll",
		"details": "Decreases of the cooldown of spells by an additional 5% of their base time",
		"level": "Level: 2",
		"prereq": ["scroll1"],
		"type": "upgrade"
	},
	"scroll3": {
		"icon": ICON_PATH + "scroll.png",
		"displayname": "Scroll",
		"details": "Decreases of the cooldown of spells by an additional 5% of their base time",
		"level": "Level: 3",
		"prereq": ["scroll2"],
		"type": "upgrade"
	},
	"scroll4": {
		"icon": ICON_PATH + "scroll.png",
		"displayname": "Scroll",
		"details": "Decreases of the cooldown of spells by an additional 5% of their base time",
		"level": "Level: 4",
		"prereq": ["scroll3"],
		"type": "upgrade"
	},
	
	"ring1": {
		"icon": ICON_PATH + "clay.png",
		"displayname": "Ring",
		"details": "Your spells now spawn 1 more additional attack",
		"level": "Level: 1",
		"prereq": [],
		"type": "upgrade"
	},
	"ring2": {
		"icon": ICON_PATH + "clay.png",
		"displayname": "Ring",
		"details": "Your spells now spawn an additional attack",
		"level": "Level: 2",
		"prereq": ["ring1"],
		"type": "upgrade"
	},
		
	"food": {
		"icon": ICON_PATH + "meat_ration.png",
		"displayname": "Food",
		"details": "Instantly heals you for 20 hp",
		"level": "N/A",
		"prereq": [],
		"type": "item"
		}
}		

