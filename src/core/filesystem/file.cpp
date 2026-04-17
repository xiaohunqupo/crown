/*
 * Copyright (c) 2012-2026 Daniele Bartolini et al.
 * SPDX-License-Identifier: MIT
 */

#include "core/containers/array.inl"
#include "core/filesystem/file.h"

namespace crown
{
void File::read_all(Buffer &buf)
{
	CE_ASSERT(is_open(), "File is not open");

	const u32 file_size = size();
	array::resize(buf, file_size);
	if (file_size != 0)
		read(array::begin(buf), file_size);
}

namespace file
{
	u32 copy(File &output, File &input, u32 input_size)
	{
		u8 chunk[4096];
		u32 to_read = input_size;
		u32 num_written = 0;

		while (num_written != input_size) {
			u32 num_read = input.read(chunk, min(u32(sizeof(chunk)), to_read));
			num_written += output.write(chunk, num_read);
			to_read -= num_read;
		}

		return num_written;
	}

} // namespace file

} // namespace crown
