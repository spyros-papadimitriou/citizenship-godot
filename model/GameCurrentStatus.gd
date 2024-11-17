class_name GameCurrentStatus
extends Object

var mission: Mission;
var facilities: Array = [];
var candidate_locations: Array = [];

var current_location: Location;
var current_facility: Facility;
var last: bool;
var lost: bool;
