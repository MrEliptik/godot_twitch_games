extends Node

##
## handles viewers for all games
##
## !join will add viewers to the list[br]
## !leave or leaving the chat will remove viewers from the list

# TODO: refactor duplication of lists merge and event emit

## viewer is active
signal viewer_active(name)

## viewer is waiting
signal viewer_waiting(name)

## viewer is dead
signal viewer_dead(name)

## viewer joined the game
signal viewer_added(name)

## viewer left the game
signal viewer_removed(name)

## all viewers reset
signal viewers_reset

## only one active viewer left
signal last_viewer_active(name)


## all active viewers
var viewers_active: Array = []

## all waiting viewers
var viewers_waiting: Array = []

## all dead viewers
var viewers_dead: Array = []

## is current game is locked
var locked: bool = false

## when closed no interaction is possible
var closed: bool = true

## turn on / off debug messages and test at statup
var debug: bool = true


func _ready():
	GiftSingleton.viewer_joined.connect(_on_viewer_joined)
	GiftSingleton.viewer_left.connect(_on_viewer_left)
	GiftSingleton.user_left_chat.connect(_on_viewer_left_chat)
	GiftSingleton.viewers_reset.connect(_on_reset_viewers)

	if debug: _test()


##
## public
##


## open all list so that viwers can join
func open() -> void:
	closed = false

	if debug: prints("Viewers.open()")


## close all lists
func close() -> void:
	closed = true

	if debug: prints("Viewers.close()")


## viewers who join when locked will be addd to the waiting list
func lock_active() -> void:
	locked = true

	if debug: prints("Viewers.lock_active()")


## all waiting and dead viewers move to the active list
func unlock_active() -> void:
	locked = false

	var tmp_waiting = viewers_waiting.duplicate()
	viewers_active.append_array(viewers_waiting)
	viewers_waiting.clear()

	var tmp_dead = viewers_dead.duplicate()
	viewers_active.append_array(viewers_dead)
	viewers_dead.clear()

	if debug: _print_viewers("unlock_active()")

	for viewer in tmp_waiting:
		viewer_active.emit(viewer)

	for viewer in tmp_dead:
		viewer_active.emit(viewer)


## return the last active viewer or null then there are more
func get_last_active_viewer() -> Variant:
	if viewers_active.size() == 1:
		if debug: prints("Viewers.get_last_active_viewer():", viewers_active[0])
		return viewers_active[0]
	else:
		if debug: prints("Viewers.get_last_active_viewer(): null")
		return null


## count all viewers in any state
func count() -> int:
	return viewers_active.size() + viewers_waiting.size() + viewers_dead.size()


## count of all active players
func count_active() -> int:
	return viewers_active.size()


## count of all viewers in the waiting list
func count_waiting() -> int:
	return viewers_waiting.size()


## count of all viewers in the dead list
func count_dead() -> int:
	return viewers_dead.size()


## resets all state
func reset() -> void:
	var tmp_active = viewers_active.duplicate()
	var tmp_waiting = viewers_waiting.duplicate()
	var tmp_dead = viewers_dead.duplicate()

	viewers_active.clear()
	viewers_waiting.clear()
	viewers_dead.clear()

	if debug: _print_viewers("reset()")

	for viewer in tmp_active:
		viewer_removed.emit(viewer)

	for viewer in tmp_waiting:
		viewer_removed.emit(viewer)

	for viewer in tmp_dead:
		viewer_removed.emit(viewer)

	viewers_reset.emit()


## add viewer to the active list
func add(viewer_name: String) -> void:
	if closed:
		return

	if is_joined(viewer_name):
		return

	viewer_added.emit(viewer_name)

	if locked:
		viewers_waiting.append(viewer_name)
		if debug: _print_viewers("add(%s)" % viewer_name)
		viewer_waiting.emit(viewer_name)
	else:
		viewers_active.append(viewer_name)
		if debug: _print_viewers("add(%s)" % viewer_name)
		viewer_active.emit(viewer_name)


## move viewer to the dead list if its active
func dead(viewer_name: String) -> void:
	if closed:
		return

	if not is_joined(viewer_name) or not is_active(viewer_name):
		return

	viewers_active.erase(viewer_name)
	viewers_dead.append(viewer_name)

	if debug: _print_viewers("dead(%s)" % viewer_name)

	viewer_dead.emit(viewer_name)
	check_last_active_viewer()


## remove viewer from all lists
func remove(viewer_name: String) -> void:
	viewers_active.erase(viewer_name)
	viewers_waiting.erase(viewer_name)
	viewers_dead.erase(viewer_name)

	check_last_active_viewer()

	if debug: _print_viewers("remove(%s)" % viewer_name)

	viewer_removed.emit(viewer_name)


## send all players to waiting list(dead / active)
func wait_all() -> void:
	var tmp_active = viewers_active.duplicate()
	viewers_waiting.append_array(viewers_active)
	viewers_active.clear()

	var tmp_dead = viewers_dead.duplicate()
	viewers_waiting.append_array(viewers_dead)
	viewers_dead.clear()

	if debug: _print_viewers("wait_all()")

	for viewer in tmp_active:
		viewer_waiting.emit(viewer)

	for viewer in tmp_dead:
		viewer_waiting.emit(viewer)


## is viewer in any list
func is_joined(viewer_name: String) -> bool:
	return is_active(viewer_name) or is_waiting(viewer_name) or is_dead(viewer_name)


## is viewer in the waiting list
func is_waiting(viewer_name: String) -> bool:
	return viewer_name in viewers_waiting


## is viewer in the active list
func is_active(viewer_name: String) -> bool:
	return viewer_name in viewers_active


## is viewer in the dead list
func is_dead(viewer_name: String) -> bool:
	return viewer_name in viewers_dead


## get the list where viewer is in
func get_viewer_list(viewer_name: String) -> Variant:
	var list = null

	if is_active(viewer_name):
		list = "active"
	elif is_waiting(viewer_name):
		list = "waiting"
	elif is_dead(viewer_name):
		list = "dead"

	return list


##
## private
##


func check_last_active_viewer() -> void:
	if count_active() != 1: return
	last_viewer_active.emit(get_last_active_viewer())


##  viewer left the game - remove from all lists
func _on_viewer_left(viewer_name: String) -> void:
	remove(viewer_name)


## viewer left the chat - remove from all lists
func _on_viewer_left_chat(sender_data: SenderData) -> void:
	remove(sender_data.user)


## viewer joined the game - add to the active/waiting list
func _on_viewer_joined(viewer_name: String) -> void:
	if is_joined(viewer_name):
		return

	add(viewer_name)


## reset all viewers
func _on_reset_viewers() -> void:
	reset()


##
## test
##


## debug output
func _print_viewers(msg: String) -> void:
	prints("Viewers."+msg+": active:",  Viewers.viewers_active, "waiting:", Viewers.viewers_waiting, "dead:", Viewers.viewers_dead)


func _print_debug(msg: String, type: String = "DEBUG") -> void:
	prints("Viewers.%s(" % type , msg,") <-----")


## some quick tests to see if the lists are working
func _test() -> void:
	prints("")
	prints("---> TEST: Viewers autoload <---")

	viewer_added.connect(_print_debug.bind("EVENT:viewer_added"))
	viewer_removed.connect(_print_debug.bind("EVENT:viewer_removed"))

	viewer_active.connect(_print_debug.bind("EVENT:viewer_active"))
	viewer_waiting.connect(_print_debug.bind("EVENT:viewer_waiting"))
	viewer_dead.connect(_print_debug.bind("EVENT:viewer_dead"))

	last_viewer_active.connect(_print_debug.bind("EVENT:last_viewer_active"))

	open()
	test_viewer_lists(0, 0, 0)

	add("viewer1")
	test_viewer_lists(1, 0, 0)

	add("viewer2")
	add("viewer3")
	test_viewer_lists(3, 0, 0)

	remove("viewer1")
	test_viewer_lists(2, 0, 0)

	lock_active()
	add("viewer4")
	test_viewer_lists(2, 1, 0)

	unlock_active()
	test_viewer_lists(3, 0, 0)

	lock_active()
	dead("viewer2")
	test_viewer_lists(2, 0, 1)

	dead("viewer3")
	test_viewer_lists(1, 0, 2)

	unlock_active()
	test_viewer_lists(3, 0, 0)

	reset()
	test_viewer_lists(0, 0, 0)

	add("viewer1")
	dead("viewer1")
	test_viewer_lists(0, 0, 1)

	add("viewer6")
	add("viewer7")
	dead("viewer7")
	assert(get_last_active_viewer() == "viewer6")

	reset()
	close()
	test_viewer_lists(0, 0, 0)

	#viewer_added.disconnect(_print_debug)
	#viewer_removed.disconnect(_print_debug)

	#viewer_active.disconnect(_print_debug)
	#viewer_waiting.disconnect(_print_debug)
	#viewer_dead.disconnect(_print_debug)

	prints("---> TESTL OK <---")
	prints("")


## test the viewer lists count
func test_viewer_lists(active_count: int, waiting_count: int, dead_count: int) -> void:
	assert(viewers_active.size() == active_count)
	assert(viewers_waiting.size() == waiting_count)
	assert(viewers_dead.size() == dead_count)

