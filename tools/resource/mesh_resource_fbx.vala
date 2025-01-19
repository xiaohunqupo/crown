/*
 * Copyright (c) 2012-2025 Daniele Bartolini et al.
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Crown
{
public static int get_destination_file(out GLib.File destination_file
	, string destination_dir
	, GLib.File source_file
	)
{
	string path = Path.build_filename(destination_dir, source_file.get_basename());
	destination_file = File.new_for_path(path);
	return 0;
}

public static int get_resource_name(out string resource_name
	, GLib.File destination_file
	, Project project
	)
{
	string resource_filename = project.resource_filename(destination_file.get_path());
	string resource_path = ResourceId.normalize(resource_filename);
	resource_name = ResourceId.name(resource_path);
	return 0;
}

public static Vector3 vector3(ufbx.Vec3 v)
{
	return Vector3(v.x, v.y, v.z);
}

public static Quaternion quaternion(ufbx.Quat q)
{
	return Quaternion(q.x, q.y, q.z, q.w);
}

public static string light_type(ufbx.LightType ufbx_type)
{
	switch (ufbx_type) {
	case ufbx.LightType.DIRECTIONAL:
		return "directional";
	case ufbx.LightType.SPOT:
		return "spot";
	case ufbx.LightType.AREA:
		return "area";
	case ufbx.LightType.VOLUME:
		return "volume";
	case ufbx.LightType.POINT:
	default:
		return "omni";
	}
}

public static string projection_type(ufbx.ProjectionMode ufbx_mode)
{
	switch (ufbx_mode) {
	case ufbx.ProjectionMode.ORTHOGRAPHIC:
		return "orthographic";
	case ufbx.ProjectionMode.PERSPECTIVE:
	default:
		return "perspective";
	}
}

[Compact]
public class FBXImportOptions
{
	public CheckBox import_lights;
	public CheckBox import_cameras;
	public CheckBox import_textures;
	public CheckBox create_textures_folder;
	public CheckBox import_materials;
	public CheckBox create_materials_folder;
	public CheckBox import_skeleton;
	public CheckBox import_animations;
	public CheckBox create_animations_folder;

	public FBXImportOptions()
	{
		import_lights = new CheckBox();
		import_lights.value = true;
		import_cameras = new CheckBox();
		import_cameras.value = true;
		import_textures = new CheckBox();
		import_textures.value = true;
		create_textures_folder = new CheckBox();
		create_textures_folder.value = true;
		import_materials = new CheckBox();
		import_materials.value = true;
		create_materials_folder = new CheckBox();
		create_materials_folder.value = true;
		import_skeleton = new CheckBox();
		import_skeleton.value = false;
		import_animations = new CheckBox();
		import_animations.value = false;
		create_animations_folder = new CheckBox();
		create_animations_folder.value = true;
	}

	public void decode(Hashtable json)
	{
		json.foreach((g) => {
				if (g.key == "import_lights")
					import_lights.value = (bool)g.value;
				else if (g.key == "import_cameras")
					import_cameras.value = (bool)g.value;
				else if (g.key == "import_textures")
					import_textures.value = (bool)g.value;
				else if (g.key == "create_textures_folder")
					create_textures_folder.value = (bool)g.value;
				else if (g.key == "import_materials")
					import_materials.value = (bool)g.value;
				else if (g.key == "create_materials_folder")
					create_materials_folder.value = (bool)g.value;
				else if (g.key == "import_skeleton")
					import_skeleton.value = (bool)g.value;
				else if (g.key == "import_animations")
					import_animations.value = (bool)g.value;
				else if (g.key == "create_animations_folder")
					create_animations_folder.value = (bool)g.value;
				else
					logw("Unknown option '%s'".printf(g.key));

				return true;
			});
	}

	public Hashtable encode()
	{
		Hashtable obj = new Hashtable();

		obj.set("import_lights", import_lights.value);
		obj.set("import_cameras", import_cameras.value);
		obj.set("import_textures", import_textures.value);
		obj.set("create_textures_folder", create_textures_folder.value);
		obj.set("import_materials", import_materials.value);
		obj.set("create_materials_folder", create_materials_folder.value);
		obj.set("import_skeleton", import_skeleton.value);
		obj.set("import_animations", import_animations.value);
		obj.set("create_animations_folder", create_animations_folder.value);

		return obj;
	}
}

public class FBXImportDialog : Gtk.Window
{
	public Project _project;
	public string _destination_dir;
	public Gee.ArrayList<string> _filenames;
	public unowned Import _import_result;

	public string _options_path;
	public FBXImportOptions _options;

	public PropertyGridSet _general_set;
	public Gtk.Box _box;

	public Gtk.Button _import;
	public Gtk.Button _cancel;
	public Gtk.HeaderBar _header_bar;

	public FBXImportDialog(Project project, string destination_dir, GLib.SList<string> filenames, Import import_result)
	{
		_project = project;
		_destination_dir = destination_dir;
		_filenames = new Gee.ArrayList<string>();
		foreach (var f in filenames)
			_filenames.add(f);
		_import_result = import_result;

		_general_set = new PropertyGridSet();
		_general_set.border_width = 12;

		_options = new FBXImportOptions();
		GLib.File file_dst;
		string resource_name;
		get_destination_file(out file_dst, destination_dir, File.new_for_path(_filenames[0]));
		get_resource_name(out resource_name, file_dst, _project);
		_options_path = _project.absolute_path(resource_name) + ".importer_settings";
		try {
			_options.decode(SJSON.load_from_path(_options_path));
		} catch (JsonSyntaxError e) {
			// No-op.
		}

		PropertyGrid cv;
		cv = new PropertyGrid();
		cv.column_homogeneous = true;
		cv.add_row("Import Lights", _options.import_lights);
		cv.add_row("Import Cameras", _options.import_cameras);
		cv.add_row("Import Textures", _options.import_textures);
		cv.add_row("Create Textures Folder", _options.create_textures_folder);
		cv.add_row("Import Materials", _options.import_materials);
		cv.add_row("Create Materials Folder", _options.create_materials_folder);
		_general_set.add_property_grid(cv, "Nodes");

#if 0
		cv = new PropertyGrid();
		cv.column_homogeneous = true;
		cv.add_row("Import Skeleton", _options.import_skeleton);
		cv.add_row("Import Animations", _options.import_animations);
		cv.add_row("Create Animations Folder", _options.create_animations_folder);
		_general_set.add_property_grid(cv, "Skeleton and Animations");
#endif

		_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		_box.pack_start(_general_set, false, false);

		_cancel = new Gtk.Button.with_label("Cancel");
		_cancel.clicked.connect(() => {
				close();
			});
		_import = new Gtk.Button.with_label("Import");
		_import.get_style_context().add_class("suggested-action");
		_import.clicked.connect(() => {
				import();
			});

		_header_bar = new Gtk.HeaderBar();
		_header_bar.title = "Import FBX...";
		_header_bar.show_close_button = true;
		_header_bar.pack_start(_cancel);
		_header_bar.pack_end(_import);

		this.set_titlebar(_header_bar);
		this.add(_box);
	}

	void import()
	{
		ImportResult res = FBXImporter.do_import(_options, _project, _destination_dir, _filenames);
		if (res == ImportResult.SUCCESS) {
			try {
				SJSON.save(_options.encode(), _options_path);
			} catch (JsonWriteError e) {
				res = ImportResult.ERROR;
			}
		}
		_import_result(res);
		close();
	}
}

public class FBXImporter
{
	public static void unit_create_components(FBXImportOptions options
		, Database db
		, Guid parent_unit_id
		, Guid unit_id
		, string resource_name
		, ufbx.Node node
		, Gee.HashMap<unowned ufbx.Material, string> imported_materials
		)
	{
		Vector3 pos = vector3(node.local_transform.translation);
		Quaternion rot = quaternion(node.local_transform.rotation);
		Vector3 scl = vector3(node.local_transform.scale);

		// Create mesh_renderer.
		if (node.mesh != null) {
			Unit unit = Unit(db, unit_id);
			db.create(unit_id, OBJECT_TYPE_UNIT);

			// Create transform.
			{
				Guid component_id;
				if (!unit.has_component(out component_id, OBJECT_TYPE_TRANSFORM)) {
					component_id = Guid.new_guid();
					db.create(component_id, OBJECT_TYPE_TRANSFORM);
					db.add_to_set(unit_id, "components", component_id);
				}

				unit.set_component_property_vector3   (component_id, "data.position", pos);
				unit.set_component_property_quaternion(component_id, "data.rotation", rot);
				unit.set_component_property_vector3   (component_id, "data.scale", scl);
			}

			if (node.mesh.num_faces > 0) {
				// Create mesh_renderer.
				{
					Guid component_id;
					if (!unit.has_component(out component_id, OBJECT_TYPE_MESH_RENDERER)) {
						component_id = Guid.new_guid();
						db.create(component_id, OBJECT_TYPE_MESH_RENDERER);
						db.add_to_set(unit_id, "components", component_id);
					}

					unowned ufbx.Material mesh_instance_material = node.materials.data[0];
					string material_name = "core/fallback/fallback";
					if (imported_materials.has_key(mesh_instance_material))
						material_name = imported_materials[mesh_instance_material];

					unit.set_component_property_string(component_id, "data.geometry_name", (string)node.name.data);
					unit.set_component_property_string(component_id, "data.material", material_name);
					unit.set_component_property_string(component_id, "data.mesh_resource", resource_name);
					unit.set_component_property_bool  (component_id, "data.visible", true);
				}

				// Create collider.
				{
					Guid component_id;
					if (!unit.has_component(out component_id, OBJECT_TYPE_COLLIDER)) {
						component_id = Guid.new_guid();
						db.create(component_id, OBJECT_TYPE_COLLIDER);
						db.add_to_set(unit_id, "components", component_id);
					}

					unit.set_component_property_string(component_id, "data.shape", "mesh");
					unit.set_component_property_string(component_id, "data.scene", resource_name);
					unit.set_component_property_string(component_id, "data.name", (string)node.name.data);
				}

				// Create actor.
				{
					Guid component_id;
					if (!unit.has_component(out component_id, OBJECT_TYPE_ACTOR)) {
						component_id = Guid.new_guid();
						db.create(component_id, OBJECT_TYPE_ACTOR);
						db.add_to_set(unit_id, "components", component_id);
					}

					unit.set_component_property_string(component_id, "data.class", "static");
					unit.set_component_property_string(component_id, "data.collision_filter", "default");
					unit.set_component_property_double(component_id, "data.mass", 1.0);
					unit.set_component_property_string(component_id, "data.material", "default");
				}
			}
		} else if (node.light != null) {
			if (!options.import_lights.value)
				return;

			Unit unit = Unit(db, unit_id);
			unit.create("core/units/light", pos, rot, scl);

			Guid component_id;
			if (unit.has_component(out component_id, OBJECT_TYPE_LIGHT)) {
				unit.set_component_property_string (component_id, "data.type", light_type(node.light.type));
				unit.set_component_property_double (component_id, "data.range", 10.0);
				unit.set_component_property_double (component_id, "data.intensity", (double)node.light.intensity);
				unit.set_component_property_double (component_id, "data.spot_angle", 0.5 * (double)node.light.outer_angle * (Math.PI/180.0));
				unit.set_component_property_vector3(component_id, "data.color", vector3(node.light.color));
			}
		} else if (node.camera != null) {
			if (!options.import_cameras.value)
				return;

			Unit unit = Unit(db, unit_id);
			unit.create("core/units/camera", pos, rot, scl);

			Guid component_id;
			if (unit.has_component(out component_id, OBJECT_TYPE_CAMERA)) {
				unit.set_component_property_string(component_id, "data.projection", projection_type(node.camera.projection_mode));
				unit.set_component_property_double(component_id, "data.fov", (double)node.camera.field_of_view_deg.y * (Math.PI/180.0));
				unit.set_component_property_double(component_id, "data.far_range", (double)node.camera.far_plane);
				unit.set_component_property_double(component_id, "data.near_range", (double)node.camera.near_plane);
			}
		} else if (node.bone != null) {
			if (!options.import_skeleton.value)
				return;
		} else {
			Unit unit = Unit(db, unit_id);
			db.create(unit_id, OBJECT_TYPE_UNIT);

			// Create transform.
			Guid component_id;
			if (!unit.has_component(out component_id, OBJECT_TYPE_TRANSFORM)) {
				component_id = Guid.new_guid();
				db.create(component_id, OBJECT_TYPE_TRANSFORM);
				db.add_to_set(unit_id, "components", component_id);
			}

			unit.set_component_property_vector3   (component_id, "data.position", pos);
			unit.set_component_property_quaternion(component_id, "data.rotation", rot);
			unit.set_component_property_vector3   (component_id, "data.scale", scl);
		}

		if (parent_unit_id != GUID_ZERO)
			db.add_to_set(parent_unit_id, "children", unit_id);

		for (size_t i = 0; i < node.children.data.length; ++i) {
			unit_create_components(options
				, db
				, unit_id
				, Guid.new_guid()
				, resource_name
				, node.children.data[i]
				, imported_materials
				);
		}
	}

	public static ImportResult do_import(FBXImportOptions options, Project project, string destination_dir, Gee.ArrayList<string> filenames)
	{
		foreach (string filename_i in filenames) {
			string resource_name;
			GLib.File file_dst;
			GLib.File file_src = File.new_for_path(filename_i);
			if (get_destination_file(out file_dst, destination_dir, file_src) != 0)
				return ImportResult.ERROR;
			if (get_resource_name(out resource_name, file_dst, project) != 0)
				return ImportResult.ERROR;

			// Copy FBX file.
			try {
				file_src.copy(file_dst, FileCopyFlags.OVERWRITE);
			} catch (Error e) {
				loge(e.message);
				return ImportResult.ERROR;
			}

			// Keep in sync with mesh_fbx.cpp!
			ufbx.LoadOpts load_opts = {};
			load_opts.target_camera_axes =
			{
				ufbx.CoordinateAxis.POSITIVE_X,
				ufbx.CoordinateAxis.POSITIVE_Z,
				ufbx.CoordinateAxis.NEGATIVE_Y
			};
			load_opts.target_light_axes =
			{
				ufbx.CoordinateAxis.POSITIVE_X,
				ufbx.CoordinateAxis.POSITIVE_Y,
				ufbx.CoordinateAxis.POSITIVE_Z
			};
			load_opts.target_axes = ufbx.CoordinateAxes.RIGHT_HANDED_Z_UP;
			load_opts.target_unit_meters = 1.0f;
			load_opts.space_conversion = ufbx.SpaceConversion.TRANSFORM_ROOT;

			// Load FBX file.
			ufbx.Error error = {};
			ufbx.Scene? scene = ufbx.Scene.load_file(filename_i, load_opts, ref error);

			Database db = new Database(project);
			Gee.HashMap<unowned ufbx.Texture, string> imported_textures = new Gee.HashMap<unowned ufbx.Texture, string>();
			Gee.HashMap<unowned ufbx.Material, string> imported_materials = new Gee.HashMap<unowned ufbx.Material, string>();

			// Import textures.
			if (options.import_textures.value) {
				// Create 'textures' folder.
				string directory_name = "textures";
				string textures_path = destination_dir;
				if (options.create_textures_folder.value && scene.textures.data.length != 0) {
					GLib.File textures_file = File.new_for_path(Path.build_filename(destination_dir, directory_name));
					try {
						textures_file.make_directory();
					} catch (GLib.IOError.EXISTS e) {
						// Ignore.
					} catch (GLib.Error e) {
						loge(e.message);
						return ImportResult.ERROR;
					}

					textures_path = textures_file.get_path();
				}

				// Extract embedded texture data or copy external
				// texture files into textures_path.
				for (size_t i = 0; i < scene.textures.data.length; ++i) {
					unowned ufbx.Texture texture = scene.textures.data[i];

					string source_image_filename = Path.build_filename(textures_path, (string)texture.name.data + ".png");
					GLib.File source_image_file  = GLib.File.new_for_path(source_image_filename);
					string source_image_path     = source_image_file.get_path();

					string texture_resource_filename = project.resource_filename(source_image_path);
					string texture_resource_path     = ResourceId.normalize(texture_resource_filename);
					string texture_resource_name     = ResourceId.name(texture_resource_path);

					if (texture.content.data.length > 0) {
						// Extract embedded PNG data.
						FileStream fs = FileStream.open(source_image_path, "wb");
						if (fs == null) {
							loge("Failed to open texture '%s'".printf(source_image_path));
							return ImportResult.ERROR;
						}

						size_t num_written = fs.write((uint8[])texture.content.data);
						if (num_written != texture.content.data.length) {
							loge("Failed to write texture '%s'".printf(source_image_path));
							return ImportResult.ERROR;
						}
					} else {
						// Copy external texture file.
					}

					// Create .texture resource.
					Guid texture_id = Guid.new_guid();
					// FIXME: detect texture type.
					TextureResource texture_resource = TextureResource.color_map(db
						, texture_id
						, texture_resource_name + ".png"
						);
					texture_resource.save(project, texture_resource_name);
					imported_textures.set(texture, texture_resource_name);
				}
			}

			// Import materials.
			if (options.import_materials.value) {
				// Create 'materials' folder.
				string directory_name = "materials";
				string materials_path = destination_dir;
				if (options.create_materials_folder.value && scene.materials.data.length != 0) {
					GLib.File materials_file = File.new_for_path(Path.build_filename(destination_dir, directory_name));
					try {
						materials_file.make_directory();
					} catch (GLib.IOError.EXISTS e) {
						// Ignore.
					} catch (GLib.Error e) {
						loge(e.message);
						return ImportResult.ERROR;
					}

					materials_path = materials_file.get_path();
				}

				// Extract materials.
				for (size_t i = 0; i < scene.materials.data.length; ++i) {
					unowned ufbx.Material material = scene.materials.data[i];

					string material_filename = Path.build_filename(materials_path, (string)material.name.data + ".png");
					GLib.File material_file  = GLib.File.new_for_path(material_filename);
					string material_path     = material_file.get_path();

					string material_resource_filename = project.resource_filename(material_path);
					string material_resource_path     = ResourceId.normalize(material_resource_filename);
					string material_resource_name     = ResourceId.name(material_resource_path);

					// Create .texture resource.
					Guid material_id = Guid.new_guid();
					db.create(material_id, "material");

					string shader = "mesh";

					for (int mm = 0; mm < ufbx.MaterialFbxMap.MAP_COUNT; ++mm) {
						unowned ufbx.MaterialMap material_map = material.fbx.maps[mm];

						switch (mm) {
						case ufbx.MaterialFbxMap.DIFFUSE_COLOR: {
								string uniform_name = "u_diffuse";
								db.set_property_string(material_id
									, "uniforms.%s.type".printf(uniform_name)
									, "vector3"
									);
								db.set_property_vector3(material_id
									, "uniforms.%s.value".printf(uniform_name)
									, vector3(material_map.value_vec3)
									);

								if (material_map.texture_enabled
									&& material_map.texture != null
									&& imported_textures.has_key(material_map.texture)
									) {
									// Lookup matching imported texture.
									string texture_resource_name = imported_textures[material_map.texture];
									shader += "+DIFFUSE_MAP";
									db.set_property_string(material_id
										, "textures.u_albedo"
										, texture_resource_name
										);
								}

								break;
						}
						case ufbx.MaterialFbxMap.SPECULAR_COLOR: {
							string uniform_name = "u_specular";
							db.set_property_string(material_id
								, "uniforms.%s.type".printf(uniform_name)
								, "vector3"
								);
							db.set_property_vector3(material_id
								, "uniforms.%s.value".printf(uniform_name)
								, vector3(material_map.value_vec3)
								);
							break;
						}
						case ufbx.MaterialFbxMap.AMBIENT_COLOR: {
							string uniform_name = "u_ambient";
							db.set_property_string(material_id
								, "uniforms.%s.type".printf(uniform_name)
								, "vector3"
								);
							db.set_property_vector3(material_id
								, "uniforms.%s.value".printf(uniform_name)
								, vector3(material_map.value_vec3)
								);
							break;
						}
						default:
							break;
						}
					}

					db.set_property_string(material_id, "shader", shader);
					db.save(project.absolute_path(material_resource_name) + ".material", material_id);
					imported_materials.set(material, material_resource_name);
				}
			}

			// Generate or modify existing .unit.
			Guid unit_id = Guid.new_guid();
			unit_create_components(options
				, db
				, GUID_ZERO
				, unit_id
				, resource_name
				, scene.root_node
				, imported_materials
				);

			db.save(project.absolute_path(resource_name) + ".unit", unit_id);

			Guid mesh_id = Guid.new_guid();
			db.create(mesh_id, OBJECT_TYPE_MESH);
			db.set_property_string(mesh_id, "source", resource_name + ".fbx");
			db.save(project.absolute_path(resource_name) + ".mesh", mesh_id);
		}

		return ImportResult.SUCCESS;
	}

	public static ImportResult import(Project project, string destination_dir, GLib.SList<string> filenames, Import import_result)
	{
		FBXImportDialog dialog = new FBXImportDialog(project, destination_dir, filenames, import_result);
		dialog.show_all();
		dialog.present();
		return ImportResult.CALLBACK;
	}
}

} /* namespace Crown */