/*
 * Copyright (c) 2012-2026 Daniele Bartolini et al.
 * SPDX-License-Identifier: MIT
 */

#pragma once

#include "core/filesystem/types.h"
#include "core/strings/string_id.h"
#include "core/types.h"
#include "core/value.h"

namespace crown
{
/// User configuration.
///
/// @ingroup Device
struct UserConfig
{
	HashMap<StringId32, Value> render_settings;

	///
	explicit UserConfig(Allocator &a);

	///
	bool parse(const char *json);

	///
	bool load(File *file);
};

} // namespace crown
