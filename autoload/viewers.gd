extends Node

##
## handles viewers for all games
##

##
## Usage:
## 	Viewers.viewer_joined.connect(on_viewer_joined)
##	Viewers.viewer_left.connect(on_viewer_left)
##
## The signal will be send for every change in the viewers list. Thats makes it easy to
## spawn and remove players in your game

## an event is fired for each viewer that joins the viewer list (not the waiting list)
signal viewer_joined(name)

## an event is fired whenever a user leaves this list
signal viewer_left(name)

## all "active" viewers held in this list
## when a viewer will join and the list is locked
## the viewer will be added to the viewers_waiting list
var viewers: Array = []

## all players that have joind while list is locked will be added here
var viewers_waiting: Array = []

var locked: bool = false

var debug: bool = true


func _ready():
	GiftSingleton.viewer_joined.connect(on_viewer_joined)
	GiftSingleton.viewer_left.connect(on_viewer_left)
	GiftSingleton.user_left_chat.connect(on_viewer_left_chat)


##
## public
##


func get_winner() -> String:
	if count_active() != 1:
		return "Viewers: WHOPS %s viewers are active" % count_active()

	return viewers[0]


## viewers who join when locked will be addd to the waiting list
func lock() -> void:
	locked = true


## all waiting viewers now move to the viewers list (active)
func unlock() -> Array:
	var waiting_list = viewers_waiting
	viewers.append_array(viewers_waiting)
	viewers_waiting.clear()
	locked = false

	for viewer_name in waiting_list:
		viewer_joined.emit(viewer_name)

	return waiting_list


func count() -> int:
	return viewers.size() + viewers_waiting.size()


func count_active() -> int:
	return viewers.size()


func count_waiting() -> int:
	return viewers_waiting.size()


func reset() -> void:
	for viewer_name in viewers:
		viewer_left.emit(viewer_name)

	viewers.clear()

	if debug:
		prints("Viewers.reset(): active",  Viewers.viewers, "waiting", Viewers.viewers_waiting)


func add(viewer_name: String) -> void:
	if locked:
		viewers_waiting.append(viewer_name)
	else:
		viewers.append(viewer_name)
		viewer_joined.emit(viewer_name)

	if debug:
		prints("Viewers.add(): active",  Viewers.viewers, "waiting", Viewers.viewers_waiting)


func remove(viewer_name: String) -> void:
	if is_active(viewer_name):
		viewer_left.emit(viewer_name)

	viewers.erase(viewer_name)
	viewers_waiting.erase(viewer_name)

	if debug:
		prints("Viewers.remove(): active",  Viewers.viewers, "waiting", Viewers.viewers_waiting)


func is_joined(viewer_name: String) -> bool:
	return is_active(viewer_name) or is_waiting(viewer_name)


func is_waiting(viewer_name: String) -> bool:
	return viewer_name in viewers_waiting


func is_active(viewer_name: String) -> bool:
	return viewer_name in viewers


##
## private
##


func on_viewer_left(viewer_name: String) -> void:
	if debug:
		prints('Viewers.on_viewer_left():', viewer_name)

	remove(viewer_name)


func on_viewer_left_chat(sender_data: SenderData) -> void:
	if debug:
		prints('Viewers.on_viewer_left_chat():', sender_data.user)

	remove(sender_data.user)


func on_viewer_joined(viewer_name: String) -> void:
	if is_joined(viewer_name):
		return

	if debug:
		prints('Viewers.on_viewer_joined():', viewer_name)

	add(viewer_name)

