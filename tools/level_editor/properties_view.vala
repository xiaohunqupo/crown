/*
 * Copyright (c) 2012-2025 Daniele Bartolini et al.
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Crown
{
public class TransformPropertyGrid : PropertyGrid
{
	public TransformPropertyGrid(Database db)
	{
		base(db);

		PropertyDefinition[] properties =
		{
			PropertyDefinition()
			{
				type = PropertyType.VECTOR3,
				name = "data.position",
			},
			PropertyDefinition()
			{
				type = PropertyType.QUATERNION,
				name = "data.rotation",
			},
			PropertyDefinition()
			{
				type = PropertyType.VECTOR3,
				name = "data.scale",
				min = VECTOR3_ZERO,
				deffault = VECTOR3_ONE,
			},
		};

		add_object_type(properties);
	}
}

public class MeshRendererPropertyGrid : PropertyGrid
{
	public MeshRendererPropertyGrid(Database db)
	{
		base(db);

		PropertyDefinition[] properties =
		{
			PropertyDefinition()
			{
				type = PropertyType.STRING,
				name = "data.mesh_resource",
				label = "Scene",
				editor = PropertyEditorType.RESOURCE,
				resource_type = OBJECT_TYPE_MESH,
			},
			PropertyDefinition()
			{
				type = PropertyType.STRING,
				name = "data.geometry_name",
				label = "Node",
				editor = PropertyEditorType.ENUM,
				enum_property = "data.mesh_resource",
				enum_callback = node_name_enum_callback,
			},
			PropertyDefinition()
			{
				type = PropertyType.STRING,
				name = "data.material",
				editor = PropertyEditorType.RESOURCE,
				resource_type = OBJECT_TYPE_MATERIAL,
			},
			PropertyDefinition()
			{
				type = PropertyType.BOOL,
				name = "data.visible",
			},
			PropertyDefinition()
			{
				type = PropertyType.BOOL,
				name = "data.cast_shadows",
			},
		};

		add_object_type(properties);
	}
}

public void node_name_enum_callback(InputField enum_property, InputEnum combo, Project project)
{
	try {
		string path = ResourceId.path(OBJECT_TYPE_MESH, (string)enum_property.union_value());
		Mesh mesh = Mesh.load_from_path(project, path);

		combo.clear();
		foreach (var node in mesh._nodes)
			combo.append(node, node);

		combo.value = combo.any_valid_id();
	} catch (JsonSyntaxError e) {
		loge(e.message);
	}
}

public class SpriteRendererPropertyGrid : PropertyGrid
{
	public SpriteRendererPropertyGrid(Database db)
	{
		base(db);

		PropertyDefinition[] properties =
		{
			PropertyDefinition()
			{
				type = PropertyType.STRING,
				name = "data.sprite_resource",
				label = "Sprite",
				editor = PropertyEditorType.RESOURCE,
				resource_type = OBJECT_TYPE_SPRITE,
			},
			PropertyDefinition()
			{
				type = PropertyType.STRING,
				name = "data.material",
				editor = PropertyEditorType.RESOURCE,
				resource_type = OBJECT_TYPE_MATERIAL,
			},
			PropertyDefinition()
			{
				type = PropertyType.DOUBLE,
				name = "data.layer",
				min = 0.0,
				max = 7.0,
			},
			PropertyDefinition()
			{
				type = PropertyType.DOUBLE,
				name = "data.depth",
				min = 0.0,
				max = (double)uint32.MAX,
			},
			PropertyDefinition()
			{
				type = PropertyType.BOOL,
				name = "data.visible",
			},
		};

		add_object_type(properties);
	}
}

public class LightPropertyGrid : PropertyGrid
{
	public LightPropertyGrid(Database db)
	{
		base(db);

		PropertyDefinition[] properties =
		{
			PropertyDefinition()
			{
				type = PropertyType.STRING,
				name = "data.type",
				editor = PropertyEditorType.ENUM,
				enum_values = { "directional", "omni", "spot" },
			},
			PropertyDefinition()
			{
				type = PropertyType.DOUBLE,
				name =  "data.range",
				min = 0.0,
			},
			PropertyDefinition()
			{
				type = PropertyType.DOUBLE,
				name = "data.intensity",
				min = 0.0,
			},
			PropertyDefinition()
			{
				type = PropertyType.DOUBLE,
				name = "data.spot_angle",
				editor = PropertyEditorType.ANGLE,
				min = 0.0,
				max = 90.0,
			},
			PropertyDefinition()
			{
				type = PropertyType.VECTOR3,
				name =  "data.color",
				editor = PropertyEditorType.COLOR,
				min = VECTOR3_ZERO,
				max = VECTOR3_ONE,
			},
			PropertyDefinition()
			{
				type = PropertyType.DOUBLE,
				name = "data.shadow_bias",
				min =  0.0,
				max =  1.0,
				deffault = 0.0001,
			},
			PropertyDefinition()
			{
				type = PropertyType.BOOL,
				name =  "data.cast_shadows",
				deffault = true,
			},
		};

		add_object_type(properties);
	}
}

public class CameraPropertyGrid : PropertyGrid
{
	public CameraPropertyGrid(Database db)
	{
		base(db);

		PropertyDefinition[] properties =
		{
			PropertyDefinition()
			{
				type = PropertyType.STRING,
				name = "data.projection",
				editor = PropertyEditorType.ENUM,
				enum_values = { "orthographic", "perspective" },
			},
			PropertyDefinition()
			{
				type = PropertyType.DOUBLE,
				name = "data.fov",
				label = "FOV",
				editor = PropertyEditorType.ANGLE,
				min = 0.0,
				max = 90.0
			},
			PropertyDefinition()
			{
				type = PropertyType.DOUBLE,
				name = "data.near_range",
				deffault = 0.1,
			},
			PropertyDefinition()
			{
				type = PropertyType.DOUBLE,
				name = "data.far_range",
				deffault = 1000.0,
			},
		};

		add_object_type(properties);
	}
}

public class ColliderPropertyGrid : PropertyGrid
{
	public ColliderPropertyGrid(Database db)
	{
		base(db);

		PropertyDefinition[] properties =
		{
			PropertyDefinition()
			{
				type = PropertyType.STRING,
				name = "data.source",
				editor = PropertyEditorType.ENUM,
				enum_values = { "mesh", "inline" },
			},
			PropertyDefinition()
			{
				type = PropertyType.STRING,
				name = "data.scene",
				editor = PropertyEditorType.RESOURCE,
				resource_type = OBJECT_TYPE_MESH,
				enum_property = "data.source",
				resource_callback = scene_resource_callback
			},
			PropertyDefinition()
			{
				type = PropertyType.STRING,
				name = "data.name",
				label = "Node",
				editor = PropertyEditorType.ENUM,
				enum_property = "data.scene",
				enum_callback = node_name_enum_callback,
			},
			PropertyDefinition()
			{
				type = PropertyType.STRING,
				name = "data.shape",
				editor = PropertyEditorType.ENUM,
				enum_values = { "sphere", "capsule", "box", "convex_hull", "mesh" },
				enum_property = "data.source",
				enum_callback = shape_resource_callback,
			},
			PropertyDefinition()
			{
				type = PropertyType.VECTOR3,
				name = "data.collider_data.position",
			},
			PropertyDefinition()
			{
				type = PropertyType.QUATERNION,
				name = "data.collider_data.rotation",
			},
			PropertyDefinition()
			{
				type = PropertyType.VECTOR3,
				name = "data.collider_data.half_extents", // Box only.
				min = VECTOR3_ZERO,
				deffault = Vector3(0.5, 0.5, 0.5),
			},
			PropertyDefinition()
			{
				type = PropertyType.DOUBLE,
				name = "data.collider_data.radius", // Sphere and capsule only.
				min = 0.0,
				deffault = 0.5,
			},
			PropertyDefinition()
			{
				type = PropertyType.DOUBLE,
				name = "data.collider_data.height", // Capsule only.
				min = 0.0,
				deffault = 1.0,
			},
		};

		add_object_type(properties);
	}

	public void scene_resource_callback(InputField enum_property, InputResource chooser, Project project)
	{
		if (enum_property.union_value() == "mesh")
			chooser.set_union_value("core/units/primitives/cube");
	}

	public void shape_resource_callback(InputField enum_property, InputEnum combo, Project project)
	{
		if (enum_property.union_value() == "inline")
			combo.set_union_value("box");
	}
}

public class ActorPropertyGrid : PropertyGrid
{
	public ActorPropertyGrid(Database db)
	{
		base(db);

		PropertyDefinition[] properties =
		{
			PropertyDefinition()
			{
				type = PropertyType.STRING,
				name = "_global_physics_config",
				deffault = "global",
				editor = PropertyEditorType.RESOURCE,
				resource_type = "physics_config",
				hidden = true,
			},
			PropertyDefinition()
			{
				type = PropertyType.STRING,
				name = "data.class",
				editor = PropertyEditorType.ENUM,
				enum_property = "_global_physics_config",
				enum_callback = class_enum_callback
			},
			PropertyDefinition()
			{
				type = PropertyType.STRING,
				name = "data.collision_filter",
				editor = PropertyEditorType.ENUM,
				enum_property = "_global_physics_config",
				enum_callback = collision_filter_enum_callback
			},
			PropertyDefinition()
			{
				type = PropertyType.STRING,
				name = "data.material",
				editor = PropertyEditorType.ENUM,
				enum_property = "_global_physics_config",
				enum_callback = material_enum_callback
			},
			PropertyDefinition()
			{
				type = PropertyType.DOUBLE,
				name = "data.mass",
				min = 0.0,
				deffault = 1.0,
			},
			PropertyDefinition()
			{
				type = PropertyType.BOOL,
				name = "data.lock_translation_x",
			},
			PropertyDefinition()
			{
				type = PropertyType.BOOL,
				name = "data.lock_translation_y",
			},
			PropertyDefinition()
			{
				type = PropertyType.BOOL,
				name = "data.lock_translation_z",
			},
			PropertyDefinition()
			{
				type = PropertyType.BOOL,
				name = "data.lock_rotation_x",
			},
			PropertyDefinition()
			{
				type = PropertyType.BOOL,
				name = "data.lock_rotation_y",
			},
			PropertyDefinition()
			{
				type = PropertyType.BOOL,
				name = "data.lock_rotation_z",
			},
		};

		add_object_type(properties);
	}

	private void class_enum_callback(InputField property_enum, InputEnum combo, Project project)
	{
		try {
			string path = ResourceId.path("physics_config", "global");
			Hashtable global = SJSON.load_from_path(project.absolute_path(path));

			string prev_enum = combo.value;
			combo.clear();
			if (global.has_key("actors")) {
				Hashtable obj = (Hashtable)global["actors"];
				foreach (var e in obj)
					combo.append(e.key, e.key);
			}
			combo.value = prev_enum;
		} catch (JsonSyntaxError e) {
			loge(e.message);
		}
	}

	private void collision_filter_enum_callback(InputField property_enum, InputEnum combo, Project project)
	{
		try {
			string path = ResourceId.path("physics_config", "global");
			Hashtable global = SJSON.load_from_path(project.absolute_path(path));

			string prev_enum = combo.value;
			combo.clear();
			if (global.has_key("collision_filters")) {
				Hashtable obj = (Hashtable)global["collision_filters"];
				foreach (var e in obj)
					combo.append(e.key, e.key);
			}
			combo.value = prev_enum;
		} catch (JsonSyntaxError e) {
			loge(e.message);
		}
	}

	private void material_enum_callback(InputField property_enum, InputEnum combo, Project project)
	{
		try {
			string path = ResourceId.path("physics_config", "global");
			Hashtable global = SJSON.load_from_path(project.absolute_path(path));

			string prev_enum = combo.value;
			combo.clear();
			if (global.has_key("materials")) {
				Hashtable obj = (Hashtable)global["materials"];
				foreach (var e in obj)
					combo.append(e.key, e.key);
			}
			combo.value = prev_enum;
		} catch (JsonSyntaxError e) {
			loge(e.message);
		}
	}
}

public class ScriptPropertyGrid : PropertyGrid
{
	public ScriptPropertyGrid(Database db)
	{
		base(db);

		PropertyDefinition[] properties =
		{
			PropertyDefinition()
			{
				type = PropertyType.STRING,
				name = "data.script_resource",
				label = "Script",
				editor = PropertyEditorType.RESOURCE,
				resource_type = "lua"
			},
		};

		add_object_type(properties);
	}
}

public class AnimationStateMachine : PropertyGrid
{
	public AnimationStateMachine(Database db)
	{
		base(db);

		PropertyDefinition[] properties =
		{
			PropertyDefinition()
			{
				type = PropertyType.STRING,
				name = "data.state_machine_resource",
				label = "State Machine",
				editor = PropertyEditorType.RESOURCE,
				resource_type = OBJECT_TYPE_ANIMATION_STATE_MACHINE
			},
		};

		add_object_type(properties);
	}
}

public class UnitView : PropertyGrid
{
	// Widgets
	private InputResource _prefab;
	private Gtk.MenuButton _component_add;
	private Gtk.Box _components;
	private Gtk.Popover _add_popover;

	public static GLib.Menu component_menu(string object_type)
	{
		GLib.Menu menu = new GLib.Menu();
		GLib.MenuItem mi;

		mi = new GLib.MenuItem("Remove Component", null);
		mi.set_action_and_target_value("app.unit-remove-component", new GLib.Variant.string(object_type));
		menu.append_item(mi);

		return menu;
	}

	public UnitView(Database db)
	{
		base(db);

		// Widgets
		_prefab = new InputResource("unit", db);
		_prefab._selector.sensitive = false;

		// List of component types.
		const string components[] =
		{
			OBJECT_TYPE_TRANSFORM,
			OBJECT_TYPE_LIGHT,
			OBJECT_TYPE_CAMERA,
			OBJECT_TYPE_MESH_RENDERER,
			OBJECT_TYPE_SPRITE_RENDERER,
			OBJECT_TYPE_COLLIDER,
			OBJECT_TYPE_ACTOR,
			OBJECT_TYPE_SCRIPT,
			OBJECT_TYPE_ANIMATION_STATE_MACHINE
		};

		// Construct 'add components' button.
		GLib.Menu menu_model = new GLib.Menu();
		GLib.MenuItem mi;

		for (int cc = 0; cc < components.length; ++cc) {
			mi = new GLib.MenuItem(camel_case(components[cc]), null);
			mi.set_action_and_target_value("app.unit-add-component"
				, new GLib.Variant.string(components[cc])
				);
			menu_model.append_item(mi);
		}
		_add_popover = new Gtk.Popover.from_model(null, menu_model);

		_component_add = new Gtk.MenuButton();
		_component_add.label = "Add Component";
		_component_add.set_popover(_add_popover);

		_components = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 6);
		_components.homogeneous = true;
		_components.pack_start(_component_add);

		add_row("Prefab", _prefab);
		add_row("Components", _components);
	}

	public override void update()
	{
		if (_db.has_property(_id, "prefab")) {
			_prefab.value = _db.get_property_string(_id, "prefab");
		} else {
			_prefab.value = "<none>";
		}
	}
}

public class SoundSourcePropertyGrid : PropertyGrid
{
	public SoundSourcePropertyGrid(Database db)
	{
		base(db);

		PropertyDefinition[] properties =
		{
			PropertyDefinition()
			{
				type = PropertyType.VECTOR3,
				name = "position",
			},
			PropertyDefinition()
			{
				type = PropertyType.QUATERNION,
				name = "rotation",
			},
			PropertyDefinition()
			{
				type = PropertyType.STRING,
				name = "name",
				editor = PropertyEditorType.RESOURCE,
				resource_type = OBJECT_TYPE_SOUND,
			},
			PropertyDefinition()
			{
				type = PropertyType.DOUBLE,
				name = "range",
				min = 0.0,
				deffault = 10.0,
			},
			PropertyDefinition()
			{
				type = PropertyType.DOUBLE,
				name = "volume",
				min = 0.0,
				max = 1.0,
				deffault = 1.0,
			},
			PropertyDefinition()
			{
				type = PropertyType.BOOL,
				name = "loop",
			},
			PropertyDefinition()
			{
				type = PropertyType.STRING,
				name = "group",
				deffault = "music",
			},
		};

		add_object_type(properties);
	}
}

public class PropertiesView : Gtk.Stack
{
	public struct ComponentEntry
	{
		string type;
		int position;
	}

	// Data
	private Database _db;
	private Gee.HashMap<string, Expander> _expanders;
	private Gee.HashMap<string, bool> _expander_states;
	private Gee.HashMap<string, PropertyGrid> _objects;
	private Gee.ArrayList<ComponentEntry?> _entries;
	private Gee.ArrayList<Guid?>? _selection;

	// Widgets
	private Gtk.Label _nothing_to_show;
	private Gtk.Label _unknown_object_type;
	private Gtk.Viewport _viewport;
	private Gtk.ScrolledWindow _scrolled_window;
	private PropertyGridSet _object_view;

	[CCode (has_target = false)]
	public delegate GLib.Menu ContextMenu(string object_type);

	public PropertiesView(Database db)
	{
		// Data
		_db = db;

		_expanders = new Gee.HashMap<string, Expander>();
		_expander_states = new Gee.HashMap<string, bool>();
		_objects = new Gee.HashMap<string, PropertyGrid>();
		_entries = new Gee.ArrayList<ComponentEntry?>();
		_selection = null;

		// Widgets
		_object_view = new PropertyGridSet();
		_object_view.margin_bottom
			= _object_view.margin_end
			= _object_view.margin_start
			= _object_view.margin_top
			= 6
			;

		// Unit
		register_object_type("Unit",                    "name",                              0, new UnitView(_db));
		register_object_type("Transform",               OBJECT_TYPE_TRANSFORM,               0, new TransformPropertyGrid(_db),      UnitView.component_menu);
		register_object_type("Light",                   OBJECT_TYPE_LIGHT,                   1, new LightPropertyGrid(_db),          UnitView.component_menu);
		register_object_type("Camera",                  OBJECT_TYPE_CAMERA,                  2, new CameraPropertyGrid(_db),         UnitView.component_menu);
		register_object_type("Mesh Renderer",           OBJECT_TYPE_MESH_RENDERER,           3, new MeshRendererPropertyGrid(_db),   UnitView.component_menu);
		register_object_type("Sprite Renderer",         OBJECT_TYPE_SPRITE_RENDERER,         3, new SpriteRendererPropertyGrid(_db), UnitView.component_menu);
		register_object_type("Collider",                OBJECT_TYPE_COLLIDER,                3, new ColliderPropertyGrid(_db),       UnitView.component_menu);
		register_object_type("Actor",                   OBJECT_TYPE_ACTOR,                   3, new ActorPropertyGrid(_db),          UnitView.component_menu);
		register_object_type("Script",                  OBJECT_TYPE_SCRIPT,                  3, new ScriptPropertyGrid(_db),         UnitView.component_menu);
		register_object_type("Animation State Machine", OBJECT_TYPE_ANIMATION_STATE_MACHINE, 3, new AnimationStateMachine(_db),      UnitView.component_menu);
		register_object_type("Sound",                   OBJECT_TYPE_SOUND_SOURCE,            0, new SoundSourcePropertyGrid(_db));

		_nothing_to_show = new Gtk.Label("Select an object to start editing");
		_unknown_object_type = new Gtk.Label("Unknown object type");

		_viewport = new Gtk.Viewport(null, null);
		_viewport.add(_object_view);

		_scrolled_window = new Gtk.ScrolledWindow(null, null);
		_scrolled_window.add(_viewport);

		this.add(_nothing_to_show);
		this.add(_scrolled_window);
		this.add(_unknown_object_type);

		this.get_style_context().add_class("properties-view");

		db._project.project_reset.connect(on_project_reset);
	}

	private void register_object_type(string label, string object_type, int position, PropertyGrid cv, ContextMenu? context_menu = null)
	{
		Expander expander = _object_view.add_property_grid(cv, label);
		if (context_menu != null) {
			Gtk.GestureMultiPress _controller_click = new Gtk.GestureMultiPress(expander);
			_controller_click.set_button(0);
			_controller_click.released.connect((n_press, x, y) => {
					if (_controller_click.get_current_button() == Gdk.BUTTON_SECONDARY) {
						Gtk.Popover menu = new Gtk.Popover.from_model(null, context_menu(object_type));
						menu.set_relative_to(expander);
						menu.set_pointing_to({ (int)x, (int)y, 1, 1 });
						menu.set_position(Gtk.PositionType.BOTTOM);
						menu.popup();
					}
				});
		}

		_objects[object_type] = cv;
		_expanders[object_type] = expander;
		_entries.add({ object_type, position });
	}

	public void show_unit(Guid id)
	{
		foreach (var entry in _entries) {
			Expander expander = _expanders[entry.type];
			_expander_states[entry.type] = expander.expanded;
		}
		this.set_visible_child(_scrolled_window);

		foreach (var entry in _entries) {
			Expander expander = _expanders[entry.type];
			bool was_expanded = _expander_states.has_key(entry.type) ? _expander_states[entry.type] : false;

			Unit unit = Unit(_db, id);
			Guid component_id;
			Guid owner_id;
			if (unit.has_component_with_owner(out component_id, out owner_id, entry.type) || entry.type == "name") {
				PropertyGrid cv = _objects[entry.type];
				cv._id = id;
				cv._component_id = component_id;
				cv.update();

				if (id == owner_id)
					expander.get_style_context().remove_class("inherited");
				else
					expander.get_style_context().add_class("inherited");

				expander.show();
				expander.expanded = was_expanded;
			} else {
				expander.hide();
			}
		}
	}

	public void show_sound_source(Guid id)
	{
		foreach (var entry in _entries) {
			Expander expander = _expanders[entry.type];
			_expander_states[entry.type] = expander.expanded;
		}

		this.set_visible_child(_scrolled_window);

		foreach (var entry in _entries) {
			Expander expander = _expanders[entry.type];

			if (entry.type == OBJECT_TYPE_SOUND_SOURCE) {
				bool was_expanded = _expander_states.has_key(entry.type) ? _expander_states[entry.type] : false;

				PropertyGrid cv = _objects[entry.type];
				cv._id = id;
				cv.update();

				expander.show();
				expander.expanded = was_expanded;
			} else {
				expander.hide();
			}
		}
	}

	public void show_or_hide_properties()
	{
		if (_selection == null || _selection.size != 1) {
			this.set_visible_child(_nothing_to_show);
			return;
		}

		Guid id = _selection[_selection.size - 1];
		if (!_db.has_object(id))
			return;

		if (_db.object_type(id) == OBJECT_TYPE_UNIT)
			show_unit(id);
		else if (_db.object_type(id) == OBJECT_TYPE_SOUND_SOURCE)
			show_sound_source(id);
		else
			this.set_visible_child(_unknown_object_type);
	}

	public void on_selection_changed(Gee.ArrayList<Guid?> selection)
	{
		_selection = selection;
		show_or_hide_properties();
	}

	public override void map()
	{
		base.map();
		show_or_hide_properties();
	}

	public void on_project_reset()
	{
		foreach (var obj in _objects) {
			PropertyGrid cv = obj.value;
			cv._id = GUID_ZERO;
			cv._component_id = GUID_ZERO;
		}
	}
}

} /* namespace Crown */
