/*
 * Copyright (c) 2012-2026 Daniele Bartolini et al.
 * SPDX-License-Identifier: MIT
 */

#pragma once

#include "config.h"

#if CROWN_CAN_COMPILE
#include "resource/mesh.h"
#include "resource/types.h"

namespace crown
{
namespace obj
{
	///
	s32 parse(Mesh &m, Buffer &buf, CompileOptions &opts);

	///
	s32 parse(Mesh &m, const char *path, CompileOptions &opts);

} // namespace obj

} // namespace crown

#endif // if CROWN_CAN_COMPILE
