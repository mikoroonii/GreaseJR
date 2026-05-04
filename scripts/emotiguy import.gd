@tool
extends EditorScenePostImport

func _post_import(scene: Node) -> Object:
	_process_node(scene)
	return scene

func _process_node(node: Node) -> void:
	if node is AnimationPlayer:
		_filter_animations(node)
		
	for child: Node in node.get_children():
		_process_node(child)

func _filter_animations(anim_player: AnimationPlayer) -> void:
	var anim_list: PackedStringArray = anim_player.get_animation_list()
	var anim_root: Node
	
	if anim_player.has_node(anim_player.root_node):
		anim_root = anim_player.get_node(anim_player.root_node)
	else:
		anim_root = anim_player.get_parent()
	
	for anim_name: String in anim_list:
		var anim: Animation = anim_player.get_animation(anim_name)
		var track_count: int = anim.get_track_count()
		
		for i: int in range(track_count - 1, -1, -1):
			var track_type: int = anim.track_get_type(i)
			
			if track_type == Animation.TYPE_BLEND_SHAPE:
				anim.remove_track(i)
				continue
				
			var path: NodePath = anim.track_get_path(i)
			var node_path_str: String = str(path).split(":")[0]
			
			if node_path_str.is_empty():
				continue
				
			var target_node: Node = anim_root.get_node_or_null(NodePath(node_path_str))
			
			if target_node == null or not target_node.is_class("Skeleton3D"):
				anim.remove_track(i)
