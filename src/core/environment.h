/*
 * Copyright (c) 2012-2026 Daniele Bartolini et al.
 * SPDX-License-Identifier: MIT
 */

#pragma once

#include "core/strings/types.h"

namespace crown
{
/// Environment functions.
///
/// @ingroup Core
namespace environment
{
	/// Returns the user data directory.
	void user_data_dir(DynamicString &path);

	/// Returns the temporary directory.
	void tmp_dir(DynamicString &path);

} // namespace environment

} // namespace crown
