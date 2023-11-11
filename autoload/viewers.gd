extends Node

##
## handles viewers for all games
##

signal viewer_active(name)
signal viewer_waiting(name)
signal viewer_dead(name)

signal viewer_added(name)
signal viewer_removed(name)

signal winner(name)

var viewers_active: Array = []
var viewers_waiting: Array = []
var viewers_dead: Array = []

var locked: bool = false
var debug: bool = true


func _ready():
	GiftSingleton.viewer_joined.connect(on_viewer_joined)
	GiftSingleton.viewer_left.connect(on_viewer_left)
	GiftSingleton.user_left_chat.connect(on_viewer_left_chat)
	
	if debug: test()


##
## public
##


## viewers who join when locked will be addd to the waiting list
func lock() -> void:
	locked = true

	if debug: prints("Viewers.lock()")


## all waiting viewers now move to the viewers list (active)
func unlock() -> void:
	var tmp_waiting = viewers_waiting
	viewers_active.append_array(viewers_waiting)
	viewers_waiting.clear()

	for viewer in tmp_waiting:
		viewer_active.emit(viewer)

	var tmp_dead = viewers_dead
	viewers_active.append_array(viewers_dead)
	viewers_dead.clear()

	for viewer in tmp_dead:
		viewer_active.emit(viewer)

	locked = false

	if debug: print_viewers("unlock()")


func get_winner() -> Variant:
	if viewers_active.size() == 1:
		if debug: prints("Viewers.get_winner():", viewers_active[0])
		return viewers_active[0]
	else:
		if debug: prints("Viewers.get_winner(): null")
		return null


func count() -> int:
	return viewers_active.size() + viewers_waiting.size() + viewers_dead.size()


func count_active() -> int:
	return viewers_active.size()


func count_waiting() -> int:
	return viewers_waiting.size()


func count_dead() -> int:
	return viewers_dead.size()
	
	
## resets all state
func reset() -> void:
	var tmp_active = viewers_active
	var tmp_waiting = viewers_waiting
	var tmp_dead = viewers_dead

	viewers_active.clear()
	viewers_waiting.clear()
	viewers_dead.clear()

	if debug: print_viewers("reset()")

	for viewer in tmp_active:
		viewer_removed.emit(viewer)

	for viewer in tmp_waiting:
		viewer_removed.emit(viewer)

	for viewer in tmp_dead:
		viewer_removed.emit(viewer)
	

func add(viewer_name: String) -> void:
	if not is_joined(viewer_name):
		viewer_added.emit(viewer_name)

	if locked:
		viewers_waiting.append(viewer_name)
		if debug: print_viewers("add(%s)" % viewer_name)
		viewer_waiting.emit(viewer_name)
	else:
		viewers_active.append(viewer_name)
		if debug: print_viewers("add(%s)" % viewer_name)
		viewer_active.emit(viewer_name)



func dead(viewer_name: String) -> void:
	viewers_active.erase(viewer_name)
	viewers_waiting.erase(viewer_name)

	viewers_dead.append(viewer_name)

	if debug: print_viewers("dead(%s)" % viewer_name)


func remove(viewer_name: String) -> void:
	viewers_active.erase(viewer_name)
	viewers_waiting.erase(viewer_name)
	viewers_dead.erase(viewer_name)
	
	if debug: print_viewers("remove(%s)" % viewer_name)

	viewer_removed.emit(viewer_name)


func is_joined(viewer_name: String) -> bool:
	return is_active(viewer_name) or is_waiting(viewer_name) or is_dead(viewer_name)


func is_waiting(viewer_name: String) -> bool:
	return viewer_name in viewers_waiting


func is_active(viewer_name: String) -> bool:
	return viewer_name in viewers_active


func is_dead(viewer_name: String) -> bool:
	return viewer_name in viewers_dead


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


func on_viewer_left(viewer_name: String) -> void:
	if debug: prints('Viewers.on_viewer_left():', viewer_name)

	remove(viewer_name)


func on_viewer_left_chat(sender_data: SenderData) -> void:
	if debug: prints('Viewers.on_viewer_left_chat():', sender_data.user)

	remove(sender_data.user)


func on_viewer_joined(viewer_name: String) -> void:
	if is_joined(viewer_name):
		return

	if debug: prints('Viewers.on_viewer_joined():', viewer_name)

	add(viewer_name)

##
## test
##

func print_viewers(msg: String) -> void:
	prints("Viewers."+msg+": -> active",  Viewers.viewers_active, "-> waiting", Viewers.viewers_waiting, "-> dead", Viewers.viewers_dead)


func test() -> void:
	prints("---> test Viewers autoload")

	viewer_added.connect(func(n: String): prints("EVENT: viewer_added:", n))
	viewer_removed.connect(func(n: String): prints("EVENT: viewer_removed:", n))

	test_viewer_lists(0, 0, 0)
	
	add("viewer1")
	test_viewer_lists(1, 0, 0)

	add("viewer2")
	add("viewer3")
	test_viewer_lists(3, 0, 0)

	remove("viewer1")
	test_viewer_lists(2, 0, 0)

	lock()
	add("viewer4")
	test_viewer_lists(2, 1, 0)

	unlock()
	test_viewer_lists(3, 0, 0)

	lock()
	dead("viewer2")
	test_viewer_lists(2, 0, 1)

	dead("viewer3")
	test_viewer_lists(1, 0, 2)

	unlock()
	test_viewer_lists(3, 0, 0)

	reset()
	test_viewer_lists(0, 0, 0)

	add("viewer1")
	dead("viewer1")
	test_viewer_lists(0, 0, 1)

	add("viewer6")
	add("viewer7")
	dead("viewer7")
	assert(get_winner() == "viewer6")
	

	prints("---> test OK")


func test_viewer_lists(active_count: int, waiting_count: int, dead_count: int) -> void:	
	assert(viewers_active.size() == active_count)
	assert(viewers_waiting.size() == waiting_count)
	assert(viewers_dead.size() == dead_count)

