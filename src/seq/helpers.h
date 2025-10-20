
#ifndef _SEQ_HELPERS_H
#define _SEQ_HELPERS_H

#include "misc/cppwrap.h"

struct seq_config;

extern long get_slices(const struct seq_config* seq);

extern void set_loop_dims_and_sms(struct seq_config* seq, long partitions, long total_slices, long radial_views,
	long frames, long echoes, long phy_phases, long averages);

extern void set_fov_pos(int N, int M, const float* shifts, struct seq_config* seq);


#include "misc/cppwrap.h"

#endif // _SEQ_HELPERS_H
