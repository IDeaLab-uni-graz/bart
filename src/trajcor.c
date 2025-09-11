/* Copyright 2024-2025. Institute of Biomedical Imaging. TU Graz.
 * All rights reserved. Use of this source code is governed by
 * a BSD-style license which can be found in the LICENSE file.
 *
 * Authors:
 * 2024-2025 Markus Huemer <huemer@tugraz.at>
 * 2025 Daniel Mackner <daniel.mackner@tugraz.at>
 */

#include <stdbool.h>
#include <complex.h>

#include "num/multind.h"
#include "num/flpmath.h"
#include "num/init.h"

#include "misc/mmio.h"
#include "misc/misc.h"
#include "misc/mri.h"
#include "misc/opts.h"

#include "noncart/radial.h"

#ifndef DIMS
#define DIMS 16
#endif

static const char help_str[] =
		"Correct delays for a given trajectory.\n";


int main_trajcor(int argc, char* argv[argc])
{
	const char* inputtraj_file = NULL;
	const char* outputtraj_file = NULL;

	float gdelays[3] = { 0., 0., 0. };
	bool transverse = false;

	const char* gdelays_file = NULL;

	struct arg_s args[] = {
		ARG_INFILE(true, &inputtraj_file, "traj"),
		ARG_OUTFILE(true, &outputtraj_file, "output traj"),
	};

	const struct opt_s opts[] = {
		OPT_FLVEC3('q', &gdelays, "delays", "gradient delays: y, x, xy"),
		OPT_INFILE('V', &gdelays_file, "file", "custom_gdelays"),
		OPT_SET('O', &transverse, "correct transverse gradient error for radial tajectories"),
	};

	cmdline(&argc, argv, ARRAY_SIZE(args), args, help_str, ARRAY_SIZE(opts), opts);

	num_init();


	int N = DIMS;

	long dimstraj[N];

	complex float* traj = load_cfl(inputtraj_file, N, dimstraj);

	if (!traj_is_radial(DIMS, dimstraj, traj))
		error("Trajectory is not radial with same dk!\n");

	complex float* outtraj = create_cfl(outputtraj_file, N, dimstraj);

	long gdmat_dims[DIMS];
	md_singleton_dims(N, gdmat_dims);
	gdmat_dims[0] = 3; // 3x3 matrix for gradient delays
	gdmat_dims[0] = 3; // 3x3 matrix for gradient delays

	long gdims[DIMS];
	complex float* delays = NULL;

	if (NULL != gdelays_file) {

		delays = load_cfl(gdelays_file, DIMS, gdims);

		assert((3 == gdims[0] || (6 == gdims[0])));
		assert(md_check_compat(DIMS - 1, ~0UL, dimstraj + 1, gdims + 1));

	} else {

		md_singleton_dims(DIMS, gdims);
		gdims[0] = 6;

		delays = anon_cfl(NULL, DIMS, gdims);
		md_clear(DIMS, gdims, delays, CFL_SIZE);

		for (int i = 0; i < 3; i++)
			delays[i] = gdelays[i];
	}

	long mat_dims[DIMS];
	md_copy_dims(N, mat_dims, gdims);
	mat_dims[0] = 3;
	mat_dims[1] = 3;
	complex float* mat = md_alloc_sameplace(DIMS, mat_dims, CFL_SIZE, traj);
	md_clear(DIMS, mat_dims, mat, CFL_SIZE);

	long slc_dims[DIMS];
	md_select_dims(DIMS, ~3UL, slc_dims, gdims);

	long mat_strs[DIMS];
	long gstrs[DIMS];
	md_calc_strides(DIMS, mat_strs, mat_dims, CFL_SIZE);
	md_calc_strides(DIMS, gstrs, gdims, CFL_SIZE);

	// explicite copy due to swapped definition y:x:xy
	md_copy2(DIMS, slc_dims, mat_strs, mat + (3 * 0 + 0), gstrs, delays + 1, CFL_SIZE);
	md_copy2(DIMS, slc_dims, mat_strs, mat + (3 * 1 + 1), gstrs, delays + 0, CFL_SIZE);
	md_copy2(DIMS, slc_dims, mat_strs, mat + (3 * 0 + 1), gstrs, delays + 2, CFL_SIZE);
	md_copy2(DIMS, slc_dims, mat_strs, mat + (3 * 1 + 0), gstrs, delays + 2, CFL_SIZE);
	md_copy2(DIMS, slc_dims, mat_strs, mat + (3 * 2 + 2), gstrs, delays + 3, CFL_SIZE);
	md_copy2(DIMS, slc_dims, mat_strs, mat + (3 * 0 + 2), gstrs, delays + 4, CFL_SIZE);
	md_copy2(DIMS, slc_dims, mat_strs, mat + (3 * 2 + 0), gstrs, delays + 4, CFL_SIZE);
	md_copy2(DIMS, slc_dims, mat_strs, mat + (3 * 1 + 2), gstrs, delays + 5, CFL_SIZE);
	md_copy2(DIMS, slc_dims, mat_strs, mat + (3 * 2 + 1), gstrs, delays + 5, CFL_SIZE);
	unmap_cfl(DIMS, gdims, delays);


	long dir_dims[N];
	md_select_dims(N, ~MD_BIT(1), dir_dims, dimstraj);

	complex float* dir = md_alloc_sameplace(N, dir_dims, CFL_SIZE, traj);
	traj_radial_direction(N, dir_dims, dir, dimstraj, traj);

	long tdir_dims[N];
	md_transpose_dims(N, 0, 1, tdir_dims, dir_dims);

	complex float* offset = md_alloc_sameplace(N, dir_dims, CFL_SIZE, traj);
	md_ztenmul(N, dir_dims, offset, mat_dims, mat, tdir_dims, dir);

	if (!transverse) {

		// project offset onto direction of spoke
		long ddims[N];
		md_select_dims(N, ~MD_BIT(0), ddims, dir_dims);
		complex float* delay = md_alloc_sameplace(DIMS, ddims, CFL_SIZE, dir);
		md_ztenmul(N, ddims, delay, dir_dims, dir, dir_dims, offset);
		md_ztenmul(N, dir_dims, offset, dir_dims, dir, ddims, delay);
		md_free(delay);
	}

	md_free(dir);
	md_zadd2(N, dimstraj, MD_STRIDES(N, dimstraj, CFL_SIZE), outtraj, MD_STRIDES(N, dimstraj, CFL_SIZE), traj, MD_STRIDES(N, dir_dims, CFL_SIZE), offset);

	md_free(offset);
	md_free(mat);

	unmap_cfl(N, dimstraj, traj);
	unmap_cfl(N, dimstraj, outtraj);

	return 0;
}

