/*
 * Copyright (c) 2012-2026 Daniele Bartolini et al.
 * SPDX-License-Identifier: MIT
 */

#include "config.h"
#include "core/json/json_object.inl"
#include "core/json/sjson.h"
#include "core/memory/temp_allocator.inl"
#include "core/platform.h"
#include "core/strings/dynamic_string.inl"
#include "core/strings/string_id.inl"
#include "device/boot_config.h"
#include "device/log.h"
#include "resource/render_config_resource.h"

LOG_SYSTEM(BOOT_CONFIG, "boot_config")

namespace crown
{
BootConfig::BootConfig(Allocator &a)
	: boot_script_name(a)
	, boot_package_name(u64(0))
	, render_config_name(u64(0))
	, window_title(a)
	, save_dir(a)
	, user_config(a)
	, window_w(CROWN_DEFAULT_WINDOW_WIDTH)
	, window_h(CROWN_DEFAULT_WINDOW_HEIGHT)
	, device_id(0)
	, aspect_ratio(-1.0f)
	, vsync(true)
	, fullscreen(false)
	, physics_settings({ 60, 4 })
	, render_settings(a)
{
}

static void parse_physics(PhysicsSettings *settings, const char *json)
{
	TempAllocator1024 ta;
	JsonObject obj(ta);
	sjson::parse(obj, json);

	auto cur = json_object::begin(obj);
	auto end = json_object::end(obj);
	for (; cur != end; ++cur) {
		JSON_OBJECT_SKIP_HOLE(obj, cur);

		if (cur->first == "step_frequency") {
			settings->step_frequency = sjson::parse_int(cur->second);
		} else if (cur->first == "max_substeps") {
			settings->max_substeps = sjson::parse_int(cur->second);
		} else {
			logw(BOOT_CONFIG, "Unknown physics property '%s'", cur->second);
		}
	}
}

static void parse_renderer_settings(BootConfig *config, const char *json)
{
	TempAllocator1024 ta;
	JsonObject renderer(ta);
	sjson::parse(renderer, json);

	if (json_object::has(renderer, "resolution")) {
		JsonArray resolution(ta);
		sjson::parse_array(resolution, renderer["resolution"]);
		config->window_w = sjson::parse_int(resolution[0]);
		config->window_h = sjson::parse_int(resolution[1]);
	}
	if (json_object::has(renderer, "aspect_ratio"))
		config->aspect_ratio = sjson::parse_float(renderer["aspect_ratio"]);
	if (json_object::has(renderer, "device_id")) {
		DynamicString hex(ta);
		sjson::parse_string(hex, renderer["device_id"]);
		s64 id;
		from_hex(id, hex.c_str());
		config->device_id = (u16)id;
	}
	if (json_object::has(renderer, "vsync"))
		config->vsync = sjson::parse_bool(renderer["vsync"]);
	if (json_object::has(renderer, "fullscreen"))
		config->fullscreen = sjson::parse_bool(renderer["fullscreen"]);
}

static void parse_platform_settings(BootConfig *config, const char *json)
{
	TempAllocator4096 ta;
	JsonObject platform(ta);
	sjson::parse(platform, json);

	if (json_object::has(platform, "save_dir"))
		sjson::parse_string(config->save_dir, platform["save_dir"]);

	if (json_object::has(platform, "renderer"))
		parse_renderer_settings(config, platform["renderer"]);

	if (json_object::has(platform, "render_settings"))
		render_settings::parse(config->render_settings, platform["render_settings"]);
}

bool BootConfig::parse(const char *json)
{
	TempAllocator4096 ta;
	JsonObject cfg(ta);
	sjson::parse(cfg, json);

	// General configs
	sjson::parse_string(boot_script_name, cfg["boot_script"]);
	boot_package_name = sjson::parse_resource_name(cfg["boot_package"]);

	if (json_object::has(cfg, "window_title"))
		sjson::parse_string(window_title, cfg["window_title"]);

	if (json_object::has(cfg, "render_config")) {
		render_config_name = sjson::parse_resource_name(cfg["render_config"]);
	} else {
		render_config_name = STRING_ID_64("core/renderer/default", UINT64_C(0x1b92f3ff7ca4157c));
	}

	if (json_object::has(cfg, "physics"))
		parse_physics(&physics_settings, cfg["physics"]);

	if (json_object::has(cfg, "render_settings"))
		render_settings::parse(render_settings, cfg["render_settings"]);

	if (json_object::has(cfg, "user_config"))
		sjson::parse_string(user_config, cfg["user_config"]);

	// Platform-specific configs.
	if (json_object::has(cfg, CROWN_PLATFORM_NAME))
		parse_platform_settings(this, cfg[CROWN_PLATFORM_NAME]);

	return true;
}

} // namespace crown
