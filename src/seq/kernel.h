#ifndef __SEQ_KERNEL_H
#define __SEQ_KERNEL_H

#include <complex.h>

#include "misc/cppwrap.h"

#include "seq/event.h"



long block_end(int N, const struct seq_event ev[__VLA(N)]);

long block_end_flat(int N, const struct seq_event ev[__VLA(N)]);

long block_rdt(int N, const struct seq_event ev[__VLA(N)]);

void seq_compute_moment0(int M, float moments[__VLA(M)][3], double dt, int N, const struct seq_event ev[__VLA(N)]);
void seq_compute_adc_samples(int D, const long adc_dims[__VLA(D)], _Complex float* adc, int N, const struct seq_event ev[__VLA(N)]);
void seq_compute_gradients(int M, double gradients[__VLA(M)][3], double dt, int N, const struct seq_event ev[__VLA(N)]);
void seq_gradients_support(int M, double gradients[__VLA(M)][6], int N, const struct seq_event ev[__VLA(N)]);

#include "misc/cppwrap.h"

#endif // __SEQ_KERNEL_H
