extends Node3D

# Loads the imported human PackedScene and selects the male variant if present.
# If no explicit male node is found, selects the first Skeleton3D or MeshInstance3D found.

@export var imported_scene_path: String = "res://.godot/imported/human.blend-738fbf7b85a13f54d00c9db65cf59296.scn"
@export var prefer_name_patterns: Array = ["male", "man"]

var instanced_root: Node = null

func _ready():
	if not ResourceLoader.exists(imported_scene_path):
		push_error("Imported human scene not found: %s" % imported_scene_path)
		return

	var ps := load(imported_scene_path) as PackedScene
	if not ps:
		push_error("Failed to load PackedScene: %s" % imported_scene_path)
		return

	instanced_root = ps.instantiate()
	add_child(instanced_root)

	# Search recursively for a node whose name matches preferred patterns
	var male_node: Node = null
	for n in _collect_all_nodes(instanced_root):
		if typeof(n.name) == TYPE_STRING:
			for pat in prefer_name_patterns:
				if n.name.to_lower().find(pat) != -1:
					male_node = n
					break
			if male_node:
				break

	# If found, hide siblings and keep only male_node visible
	if male_node:
		_print_debug("Male node found: %s" % male_node.name)
		_hide_all_except(male_node)
		return

	# Fallback: find first Skeleton3D or MeshInstance3D
	for n in _collect_all_nodes(instanced_root):
		if n is Skeleton3D or n is MeshInstance3D:
			_print_debug("Fallback node selected: %s (%s)" % [n.name, n.get_class()])
			_hide_all_except(n)
			return

	_print_debug("No suitable node found; keeping entire imported scene visible")

func _hide_all_except(keep_node: Node) -> void:
	# Hide all MeshInstance3D children except those under keep_node
	for m in _collect_all_nodes(instanced_root):
		if m is MeshInstance3D:
			if not (m.is_inside_tree() and (m == keep_node or _is_parent_of(m, keep_node))):
				m.visible = false

func _collect_all_nodes(root: Node) -> Array:
	var out: Array = []
	if not root:
		return out
	var stack: Array = [root]
	while stack.size() > 0:
		var cur: Node = stack.pop_back()
		out.append(cur)
		for child in cur.get_children():
			if child is Node:
				stack.append(child)
	return out

func _is_parent_of(parent: Node, child: Node) -> bool:
	# Safe parent check that doesn't rely on engine convenience methods
	if not parent or not child:
		return false
	var cur: Node = child
	while cur:
		cur = cur.get_parent()
		if cur == parent:
			return true
	return false

func _print_debug(msg: String) -> void:
	print("[HumanSelector] ", msg)
