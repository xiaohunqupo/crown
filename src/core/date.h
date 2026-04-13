/*
 * Copyright (c) 2012-2026 Daniele Bartolini et al.
 * SPDX-License-Identifier: MIT
 */

#pragma once

#include "core/types.h"

namespace crown
{
namespace date
{
	///
	void date(s32 &year, s32 &month, s32 &day);

	///
	void utc_date(s32 &year, s32 &month, s32 &day);

	///
	void time(s32 &hour, s32 &minutes, s32 &seconds);

	///
	void utc_time(s32 &hour, s32 &minutes, s32 &seconds);

} // namespace date

} // namespace crown
