/*
 * Copyright (c) 2012-2026 Daniele Bartolini et al.
 * SPDX-License-Identifier: MIT
 */

#pragma once

#include "core/math/types.h"

namespace crown
{
///
///
/// @ingroup Core
struct Value
{
	enum Type
	{
		BOOL,
		FLOAT,
		UINT32,
		VECTOR2
	} type;

	union
	{
		bool b;
		f32 f;
		u32 u;
		Vector2 v2;
	} value;
};

} // namespace crown
