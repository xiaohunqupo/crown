/*
 * Copyright (c) 2012-2026 Daniele Bartolini et al.
 * SPDX-License-Identifier: MIT
 */

#include "core/date.h"

#if CROWN_PLATFORM_WINDOWS
	#ifndef WIN32_LEAN_AND_MEAN
		#define WIN32_LEAN_AND_MEAN
	#endif
	#include <windows.h>
#else
	#include <time.h>
#endif

namespace crown
{
namespace date
{
	void date(s32 &year, s32 &month, s32 &day)
	{
#if CROWN_PLATFORM_WINDOWS
		SYSTEMTIME now;
		GetLocalTime(&now);
		year  = now.wYear;
		month = now.wMonth;
		day   = now.wDay;
#else
		time_t t;
		struct tm now;
		::time(&t);
		localtime_r(&t, &now);
		year  = now.tm_year + 1900;
		month = now.tm_mon + 1;
		day   = now.tm_mday;
#endif
	}

	void utc_date(s32 &year, s32 &month, s32 &day)
	{
#if CROWN_PLATFORM_WINDOWS
		SYSTEMTIME now;
		GetSystemTime(&now);
		year  = now.wYear;
		month = now.wMonth;
		day   = now.wDay;
#else
		time_t t;
		struct tm now;
		::time(&t);
		gmtime_r(&t, &now);
		year  = now.tm_year + 1900;
		month = now.tm_mon + 1;
		day   = now.tm_mday;
#endif
	}

	void time(s32 &hour, s32 &minutes, s32 &seconds)
	{
#if CROWN_PLATFORM_WINDOWS
		SYSTEMTIME now;
		GetLocalTime(&now);
		hour    = now.wHour;
		minutes = now.wMinute;
		seconds = now.wSecond;
#else
		time_t t;
		struct tm now;
		::time(&t);
		localtime_r(&t, &now);
		hour    = now.tm_hour;
		minutes = now.tm_min;
		seconds = now.tm_sec;
#endif
	}

	void utc_time(s32 &hour, s32 &minutes, s32 &seconds)
	{
#if CROWN_PLATFORM_WINDOWS
		SYSTEMTIME now;
		GetSystemTime(&now);
		hour    = now.wHour;
		minutes = now.wMinute;
		seconds = now.wSecond;
#else
		time_t t;
		struct tm now;
		::time(&t);
		gmtime_r(&t, &now);
		hour    = now.tm_hour;
		minutes = now.tm_min;
		seconds = now.tm_sec;
#endif
	}

} // namespace date

} // namespace crown
