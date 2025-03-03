/*
 * Copyright (c) 2012-2025 Daniele Bartolini et al.
 * SPDX-License-Identifier: MIT
 */

#pragma once

#include "core/murmur.h"
#include "core/functional.h"

namespace crown
{
template<typename T>
inline bool equal_to<T>::operator()(const T &a, const T &b) const
{
	return a == b;
}

template<typename T>
inline bool not_equal_to<T>::operator()(const T &a, const T &b) const
{
	return a != b;
}

template<typename T>
inline bool greater<T>::operator()(const T &a, const T &b) const
{
	return a > b;
}

template<typename T>
inline bool less<T>::operator()(const T &a, const T &b) const
{
	return a < b;
}

template<typename T>
inline bool greater_equal<T>::operator()(const T &a, const T &b) const
{
	return a >= b;
}

template<typename T>
inline bool less_equal<T>::operator()(const T &a, const T &b) const
{
	return a <= b;
}

inline u32 hash<bool>::operator()(const bool val) const
{
	return (u32)val;
}

inline u32 hash<s8>::operator()(const s8 val) const
{
	return (u32)val;
}

inline u32 hash<u8>::operator()(const u8 val) const
{
	return (u32)val;
}

inline u32 hash<s16>::operator()(const s16 val) const
{
	return (u32)val;
}

inline u32 hash<u16>::operator()(const u16 val) const
{
	return (u32)val;
}

inline u32 hash<s32>::operator()(const s32 val) const
{
	return (u32)val;
}

inline u32 hash<u32>::operator()(const u32 val) const
{
	return (u32)val;
}

inline u32 hash<s64>::operator()(const s64 val) const
{
	return (u32)val;
}

inline u32 hash<u64>::operator()(const u64 val) const
{
	return (u32)val;
}

inline u32 hash<f32>::operator()(const f32 val) const
{
	return val == 0.0f ? 0 : murmur32(&val, sizeof(val), 0);
}

inline u32 hash<f64>::operator()(const f64 val) const
{
	return val == 0.0 ? 0 : murmur32(&val, sizeof(val), 0);
}

template<typename T>
inline u32 hash<T *>::operator()(const T *val) const
{
	return (u32)(uintptr_t)val;
}

} // namespace crown
