/*
 * Copyright (c) 2012-2026 Daniele Bartolini et al.
 * SPDX-License-Identifier: MIT
 */

#include "config.h"
#include "core/containers/array.inl"
#include "core/filesystem/file.h"
#include "core/json/json_object.inl"
#include "core/json/sjson.h"
#include "core/memory/temp_allocator.inl"
#include "device/user_config.h"
#include "device/log.h"
#include "resource/render_config_resource.h"

LOG_SYSTEM(USER_CONFIG, "user_config")

namespace crown
{
UserConfig::UserConfig(Allocator &a)
	: render_settings(a)
{
}

bool UserConfig::parse(const char *json)
{
	TempAllocator4096 ta;
	JsonObject cfg(ta);
	sjson::parse(cfg, json);

	if (json_object::has(cfg, "render_settings"))
		render_settings::parse(render_settings, cfg["render_settings"]);

	return true;
}

bool UserConfig::load(File *file)
{
	TempAllocator4096 ta;
	Buffer json(ta);

	if (!file->is_open())
		return false;

	file->read_all(json);
	array::push_back(json, '\0');
	return parse(array::begin(json));
}

} // namespace crown
