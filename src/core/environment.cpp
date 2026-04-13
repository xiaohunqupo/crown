/*
 * Copyright (c) 2012-2026 Daniele Bartolini et al.
 * SPDX-License-Identifier: MIT
 */

#include "core/environment.h"
#include "core/filesystem/path.h"
#include "core/os.h"
#include "core/platform.h"
#include "core/strings/dynamic_string.inl"

namespace crown
{
namespace environment
{
	void user_data_dir(DynamicString &path)
	{
#if CROWN_PLATFORM_WINDOWS
		const char *appdata = os::getenv("APPDATA");
		if (appdata == NULL) {
			path = "";
			return;
		}

		path = appdata;
#else
		const char *data_home = os::getenv("XDG_DATA_HOME");
		if (data_home != NULL) {
			path = data_home;
			return;
		}

		const char *home = os::getenv("HOME");
		if (home == NULL) {
			path = "";
			return;
		}

		path::join(path, home, ".local/share");
#endif // if CROWN_PLATFORM_WINDOWS
	}

	void tmp_dir(DynamicString &path)
	{
#if CROWN_PLATFORM_WINDOWS
		const char *tmp = os::getenv("TMP");
		if (tmp == NULL)
			tmp = os::getenv("TEMP");
#else
		const char *tmp = os::getenv("TMPDIR");
		if (tmp == NULL)
			tmp = "/tmp";
#endif // if CROWN_PLATFORM_WINDOWS

		if (tmp == NULL) {
			path = "";
			return;
		}

		path = tmp;
	}

} // namespace environment

} // namespace crown
