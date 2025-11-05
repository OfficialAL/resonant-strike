# Headless helper: print nodes and skeleton bone names from imported human scene
var imported_path := "res://.godot/imported/human.blend-738fbf7b85a13f54d00c9db65cf59296.scn"
# Headless helper: print nodes and skeleton bone names from imported human scene
var imported_path: String = "res://.godot/imported/human.blend-738fbf7b85a13f54d00c9db65cf59296.scn"

func walk(node: Node, indent: int = 0) -> void:
	var pad: String = "".pad_left(indent * 2)
	print("%s- %s : %s" % [pad, node.name, node.get_class()])
	if node is Skeleton3D:
		var sk: Skeleton3D = node as Skeleton3D
		print("%s  Bones: %d" % [pad, sk.get_bone_count()])
		for i in range(sk.get_bone_count()):
			print("%s    - [%d] %s" % [pad, i, sk.get_bone_name(i)])
	for c in node.get_children():
		if c is Node:
			walk(c, indent + 1)

func _run() -> void:
	print("[PrintHumanNodes] Loading: %s" % imported_path)
	var ps = load(imported_path)
	if not ps:
		printerr("Failed to load PackedScene: %s" % imported_path)
		OS.exit(1)
	var root = ps.instantiate()
	if not root:
		printerr("Failed to instantiate scene")
		OS.exit(1)

	walk(root)
	print("[PrintHumanNodes] Done")
	OS.exit(0)

# When run as script (godot --headless --script), entry is _run
_run()

