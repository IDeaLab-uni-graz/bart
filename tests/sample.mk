
# tests for very small gmm peaks (1 and -1) if abs(sample) - 1 < 0.01 for real and imag part
tests/test-sample-gmm1d_mean: sample ones zeros join cabs calc scale ones nrmse
	set -e; mkdir $(TESTS_TMP) ; cd $(TESTS_TMP)						;\
	$(TOOLDIR)/ones 2 1 1 t.ra								;\
	$(TOOLDIR)/scale 1+1i t.ra t1.ra							;\
	$(TOOLDIR)/scale -- -1-1i t.ra t2.ra							;\
	$(TOOLDIR)/join 3 t1.ra t2.ra mu.ra							;\
	$(TOOLDIR)/ones 16 1 1 1 2 1 1 1 1 1 1 1 1 1 1 1 1 vars.ra				;\
	$(TOOLDIR)/scale 0.0001 vars.ra vars.ra							;\
	$(TOOLDIR)/ones 16 1 1 1 2 1 1 1 1 1 1 1 1 1 1 1 1 ws.ra				;\
	$(TOOLDIR)/scale 0.5 ws.ra ws.ra							;\
	$(TOOLDIR)/sample --sigma max=10,min=0.01 -N50 -K20 --gmm mean=mu.ra,var=vars.ra,w=ws.ra --gamma=0.1 -S1 out.ra	;\
	$(TOOLDIR)/calc zreal out.ra out_real.ra						;\
	$(TOOLDIR)/cabs out_real.ra out_real.ra							;\
	$(TOOLDIR)/calc zimag out.ra out_imag.ra						;\
	$(TOOLDIR)/cabs out_imag.ra out_imag.ra							;\
	$(TOOLDIR)/ones 1 1 o.ra								;\
	$(TOOLDIR)/nrmse -t 0.01 out_real.ra o.ra						;\
	$(TOOLDIR)/nrmse -t 0.01 out_imag.ra o.ra						;\
	rm *.ra; cd .. ; rmdir $(TESTS_TMP)
	touch $@

# tests for correct weighting of the sampled gaussians in the gmm (0.7 (for mean 0) to 0.3 (for mean 1) -> -0.3 on average) fo real and imag part; abs value due to scaling issue
tests/test-sample-gmm1d_weigthing: sample cabs calc avg zeros join ones scale nrmse
	set -e; mkdir $(TESTS_TMP) ; cd $(TESTS_TMP)						;\
	$(TOOLDIR)/ones 2 1 1 t.ra								;\
	$(TOOLDIR)/scale 1+1i t.ra t.ra								;\
	$(TOOLDIR)/zeros 2 1 1 t1.ra								;\
	$(TOOLDIR)/join 3 t.ra t1.ra mu.ra							;\
	$(TOOLDIR)/ones 16 1 1 1 2 1 1 1 1 1 1 1 1 1 1 1 1 vars.ra				;\
	$(TOOLDIR)/scale 0.0001 vars.ra vars.ra							;\
	$(TOOLDIR)/ones 16 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 w1.ra				;\
	$(TOOLDIR)/scale 0.5 w1.ra w1.ra							;\
	$(TOOLDIR)/ones 16 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 w2.ra				;\
	$(TOOLDIR)/scale 0.5 w2.ra w2.ra							;\
	$(TOOLDIR)/join 3 w1.ra w2.ra ws.ra							;\
	$(TOOLDIR)/sample --sigma max=10.,min=0.001 -N50 -K20 -s100 --gmm mean=mu.ra,var=vars.ra,w=ws.ra --gamma=0.05 -S1000 out.ra	;\
	$(TOOLDIR)/avg 32768 out.ra o_avg.ra							;\
	$(TOOLDIR)/ones 1 1 o.ra								;\
	$(TOOLDIR)/scale 0.5 o.ra o.ra								;\
	$(TOOLDIR)/calc zreal o_avg.ra o_avg_real.ra						;\
	$(TOOLDIR)/calc zimag o_avg.ra o_avg_imag.ra						;\
	$(TOOLDIR)/cabs o_avg_real.ra o_avg_real.ra						;\
	$(TOOLDIR)/cabs o_avg_imag.ra o_avg_imag.ra						;\
	$(TOOLDIR)/nrmse -t 0.05 o_avg_real.ra o.ra						;\
	$(TOOLDIR)/nrmse -t 0.05 o_avg_imag.ra o.ra						;\
	rm *.ra; cd .. ; rmdir $(TESTS_TMP)
	touch $@

# tests for very small gmm peaks using a 2x2 matrix with mean1 = [1,1;1,1] and mean2 = [0,0;0,0]
# output should be x_mmse = [0.5,0.5;0.5,0.5] and var = [0.5,0.5;0.5,0.5] (here: small dimension test)
tests/test-sample-gmm2d: sample reshape calc cabs avg ones scale zeros join nrmse fmac var
	set -e; mkdir $(TESTS_TMP) ; cd $(TESTS_TMP)						;\
	$(TOOLDIR)/ones 2 2 2 t.ra								;\
	$(TOOLDIR)/scale 1+1i t.ra t.ra								;\
	$(TOOLDIR)/zeros 2 2 2 t1.ra								;\
	$(TOOLDIR)/join 3 t.ra t1.ra mu.ra							;\
	$(TOOLDIR)/ones 16 1 1 1 2 1 1 1 1 1 1 1 1 1 1 1 1 vars.ra				;\
	$(TOOLDIR)/scale 0.0001 vars.ra vars.ra							;\
	$(TOOLDIR)/ones 16 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 w1.ra				;\
	$(TOOLDIR)/scale 0.5 w1.ra w1.ra							;\
	$(TOOLDIR)/ones 16 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 w2.ra				;\
	$(TOOLDIR)/scale 0.5 w2.ra w2.ra							;\
	$(TOOLDIR)/join 3 w1.ra w2.ra ws.ra							;\
	$(TOOLDIR)/sample --sigma max=10.,min=0.001 -N50 -K20 -s100 --gmm mean=mu.ra,var=vars.ra,w=ws.ra --gamma=0.025 -S1000 out.ra ;\
	$(TOOLDIR)/reshape 3 4 1 out.ra out.ra							;\
	$(TOOLDIR)/calc zimag out.ra out_imag.ra						;\
	$(TOOLDIR)/calc zreal out.ra out_real.ra						;\
	$(TOOLDIR)/avg 32768 out_real.ra out_avg_real.ra					;\
	$(TOOLDIR)/avg 32768 out_imag.ra out_avg_imag.ra					;\
	$(TOOLDIR)/var 32768 out.ra out_var.ra							;\
	$(TOOLDIR)/cabs out_avg_imag.ra out_avg_imag.ra						;\
	$(TOOLDIR)/ones 2 4 1 o.ra								;\
	$(TOOLDIR)/scale 0.5 o.ra o_avg.ra							;\
	$(TOOLDIR)/scale 0.5 o.ra o_var.ra							;\
	$(TOOLDIR)/nrmse -t 0.05 out_avg_real.ra o_avg.ra					;\
	$(TOOLDIR)/nrmse -t 0.05 out_avg_imag.ra o_avg.ra					;\
	$(TOOLDIR)/nrmse -t 0.05 out_var.ra o_var.ra						;\
	rm *.ra; cd .. ; rmdir $(TESTS_TMP)
	touch $@

# tests for 1D gauss variance and mean. mean=1, var=0.5,
tests/test-sample-gauss1d_mean_gpu: sample avg var cabs calc scale ones nrmse zeros
	set -e; mkdir $(TESTS_TMP) ; cd $(TESTS_TMP)						;\
	$(TOOLDIR)/ones 2 1 1 mu.ra								;\
	$(TOOLDIR)/scale 1+1i mu.ra mu.ra							;\
	$(TOOLDIR)/ones 16 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 vars.ra				;\
	$(TOOLDIR)/scale 0.5 vars.ra vars.ra						;\
	$(TOOLDIR)/sample --sigma max=10.,min=0.001 -g -N100 -K100 -s100 --gmm mean=mu.ra,var=vars.ra --gamma=0.001 -S1000 out.ra 	;\
	$(TOOLDIR)/calc zimag out.ra out_imag.ra						;\
	$(TOOLDIR)/calc zreal out.ra out_real.ra						;\
	$(TOOLDIR)/avg 32768 out_real.ra out_avg_real.ra					;\
	$(TOOLDIR)/avg 32768 out_imag.ra out_avg_imag.ra					;\
	$(TOOLDIR)/var 32768 out.ra out_var.ra 							;\
	$(TOOLDIR)/ones 1 1 o.ra								;\
	$(TOOLDIR)/scale 0+1i o.ra o_imag.ra							;\
	$(TOOLDIR)/nrmse -t 0.05 out_avg_real.ra o.ra						;\
	$(TOOLDIR)/nrmse -t 0.05 out_avg_imag.ra o_imag.ra					;\
	$(TOOLDIR)/nrmse -t 0.05 out_var.ra vars.ra						;\
	rm *.ra; cd .. ; rmdir $(TESTS_TMP)
	touch $@

# tests for 1D gauss variance and mean. mean=1, var=0.5, real-valued noise scale ends with same variance
tests/test-sample-gauss1d_mean_real_gpu: sample avg var cabs calc scale ones nrmse zeros
	set -e; mkdir $(TESTS_TMP) ; cd $(TESTS_TMP)						;\
	$(TOOLDIR)/ones 2 1 1 mu.ra								;\
	$(TOOLDIR)/scale 1+1i mu.ra mu.ra							;\
	$(TOOLDIR)/ones 16 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 vars.ra				;\
	$(TOOLDIR)/scale 0.5 vars.ra vars.ra							;\
	$(TOOLDIR)/sample --sigma max=10.,min=0.001 -g -N100 -K100 -s100 --gmm mean=mu.ra,var=vars.ra -r --gamma=0.001 -S1000 out.ra 	;\
	$(TOOLDIR)/calc zimag out.ra out_imag.ra						;\
	$(TOOLDIR)/calc zreal out.ra out_real.ra						;\
	$(TOOLDIR)/avg 32768 out_real.ra out_avg_real.ra					;\
	$(TOOLDIR)/avg 32768 out_imag.ra out_avg_imag.ra					;\
	$(TOOLDIR)/var 32768 out.ra out_var.ra 							;\
	$(TOOLDIR)/ones 1 1 o.ra								;\
	$(TOOLDIR)/scale 0+1i o.ra o_imag.ra							;\
	$(TOOLDIR)/nrmse -t 0.05 out_avg_real.ra o.ra						;\
	$(TOOLDIR)/nrmse -t 0.05 out_avg_imag.ra o_imag.ra					;\
	$(TOOLDIR)/nrmse -t 0.05 out_var.ra vars.ra						;\
	rm *.ra; cd .. ; rmdir $(TESTS_TMP)
	touch $@

# tests for 1D gauss variance and mean. mean=1, var=0.001, real-valued min noise scale = 5 -> sampled noise scale  
tests/test-sample-gauss1d_mean_real1_gpu: sample avg std cabs calc scale ones nrmse zeros
	set -e; mkdir $(TESTS_TMP) ; cd $(TESTS_TMP)						;\
	$(TOOLDIR)/ones 2 1 1 mu.ra								;\
	$(TOOLDIR)/scale 1+1i mu.ra mu.ra							;\
	$(TOOLDIR)/ones 16 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 vars.ra				;\
	$(TOOLDIR)/scale 0.001 vars.ra vars.ra							;\
	$(TOOLDIR)/sample --sigma max=100.,min=5 -g -N100 -K100 -s100 --gmm mean=mu.ra,var=vars.ra -r --gamma=0.0025 -S10000 out.ra 	;\
	$(TOOLDIR)/calc zimag out.ra out_imag.ra						;\
	$(TOOLDIR)/calc zreal out.ra out_real.ra						;\
	$(TOOLDIR)/avg 32768 out_real.ra out_avg_real.ra					;\
	$(TOOLDIR)/avg 32768 out_imag.ra out_avg_imag.ra					;\
	$(TOOLDIR)/std 32768 out.ra out_std.ra 							;\
	$(TOOLDIR)/ones 1 1 o.ra								;\
	$(TOOLDIR)/scale 5 o.ra o_std.ra							;\
	$(TOOLDIR)/scale 0+1i o.ra o_imag.ra							;\
	$(TOOLDIR)/nrmse -t 0.05 out_avg_real.ra o.ra						;\
	$(TOOLDIR)/nrmse -t 0.05 out_avg_imag.ra o_imag.ra					;\
	$(TOOLDIR)/nrmse -t 0.05 out_std.ra o_std.ra						;\
	rm *.ra; cd .. ; rmdir $(TESTS_TMP)
	touch $@

# tests for 1D gauss variance and mean. mean=1, var=0.5, ancestral
tests/test-sample-gauss1d_mean_ancestral: sample avg var cabs calc scale ones nrmse zeros
	set -e; mkdir $(TESTS_TMP) ; cd $(TESTS_TMP)						;\
	$(TOOLDIR)/ones 2 1 1 mu.ra								;\
	$(TOOLDIR)/scale 1+1i mu.ra mu.ra							;\
	$(TOOLDIR)/ones 1 1 vars.ra				;\
	$(TOOLDIR)/scale 0.5 vars.ra vars.ra						;\
	$(TOOLDIR)/sample --sigma max=10.,min=0.001 -N1000 -a -s111 --gmm mean=mu.ra,var=vars.ra -S1000 out.ra 	;\
	$(TOOLDIR)/calc zimag out.ra out_imag.ra						;\
	$(TOOLDIR)/calc zreal out.ra out_real.ra						;\
	$(TOOLDIR)/avg 32768 out_real.ra out_avg_real.ra					;\
	$(TOOLDIR)/avg 32768 out_imag.ra out_avg_imag.ra					;\
	$(TOOLDIR)/var 32768 out.ra out_var.ra 							;\
	$(TOOLDIR)/ones 1 1 o.ra								;\
	$(TOOLDIR)/scale 0+1i o.ra o_imag.ra							;\
	$(TOOLDIR)/nrmse -t 0.05 out_avg_real.ra o.ra						;\
	$(TOOLDIR)/nrmse -t 0.05 out_avg_imag.ra o_imag.ra					;\
	$(TOOLDIR)/nrmse -t 0.05 out_var.ra vars.ra						;\
	rm *.ra; cd .. ; rmdir $(TESTS_TMP)
	touch $@

# tests for 1D gauss variance and mean. mean=1, var=0.5, pc
tests/test-sample-gauss1d_mean_pc: sample avg var cabs calc scale ones nrmse zeros
	set -e; mkdir $(TESTS_TMP) ; cd $(TESTS_TMP)						;\
	$(TOOLDIR)/ones 2 1 1 mu.ra								;\
	$(TOOLDIR)/scale 1+1i mu.ra mu.ra							;\
	$(TOOLDIR)/ones 16 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 vars.ra				;\
	$(TOOLDIR)/scale 0.5 vars.ra vars.ra						;\
	$(TOOLDIR)/sample --sigma max=10.,min=0.001 -N50 -K20 -p -s111 --gamma=0.0025 --gmm mean=mu.ra,var=vars.ra -S1000 out.ra 	;\
	$(TOOLDIR)/calc zimag out.ra out_imag.ra						;\
	$(TOOLDIR)/calc zreal out.ra out_real.ra						;\
	$(TOOLDIR)/avg 32768 out_real.ra out_avg_real.ra					;\
	$(TOOLDIR)/avg 32768 out_imag.ra out_avg_imag.ra					;\
	$(TOOLDIR)/var 32768 out.ra out_var.ra 							;\
	$(TOOLDIR)/ones 1 1 o.ra								;\
	$(TOOLDIR)/scale 0+1i o.ra o_imag.ra							;\
	$(TOOLDIR)/nrmse -t 0.05 out_avg_real.ra o.ra						;\
	$(TOOLDIR)/nrmse -t 0.05 out_avg_imag.ra o_imag.ra					;\
	$(TOOLDIR)/nrmse -t 0.05 out_var.ra vars.ra						;\
	rm *.ra; cd .. ; rmdir $(TESTS_TMP)
	touch $@

# tests for 1D gauss where min variance of diffusion process is set high
# gauss var = 1, min_var = 1, sampled var = 1 + 1 = 2
tests/test-sample-gauss1d_var_gpu: sample avg var cabs calc scale ones nrmse zeros
	set -e; mkdir $(TESTS_TMP) ; cd $(TESTS_TMP)						;\
	$(TOOLDIR)/ones 2 1 1 mu.ra								;\
	$(TOOLDIR)/scale 1+1i mu.ra mu.ra							;\
	$(TOOLDIR)/ones 16 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 vars.ra				;\
	$(TOOLDIR)/sample --sigma max=10.,min=1 -g -N500 -K100 -s100 --gmm mean=mu.ra,var=vars.ra --gamma=0.001 -S1000 out.ra 	;\
	$(TOOLDIR)/var 32768 out.ra out_var.ra 							;\
	$(TOOLDIR)/ones 1 1 o.ra								;\
	$(TOOLDIR)/scale 2 o.ra o_var.ra							;\
	$(TOOLDIR)/nrmse -t 0.05 out_var.ra o_var.ra						;\
	rm *.ra; cd .. ; rmdir $(TESTS_TMP)
	touch $@


# tests for very small gmm peaks using two different 128x128 phantom images for mean1 and mean2
# output should be either image1 or image2 (here: high dimension test)
tests/test-sample-gmm_img_gpu: phantom scale join ones sample nrmse
	set -e; mkdir $(TESTS_TMP) ; cd $(TESTS_TMP)						;\
	$(TOOLDIR)/phantom -s1 mean1.ra 							;\
	$(TOOLDIR)/phantom -s1 --BRAIN mean2.ra 						;\
	$(TOOLDIR)/scale 0.25 mean2.ra mean2.ra							;\
	$(TOOLDIR)/join 3 mean1.ra mean2.ra mu.ra						;\
	$(TOOLDIR)/ones 4 1 1 1 2 vars.ra							;\
	$(TOOLDIR)/scale 0.00001 vars.ra vars.ra					;\
	$(TOOLDIR)/ones 4 1 1 1 1 w1.ra								;\
	$(TOOLDIR)/scale 0.5 w1.ra w1.ra							;\
	$(TOOLDIR)/ones 4 1 1 1 1 w2.ra								;\
	$(TOOLDIR)/scale 0.5 w2.ra w2.ra							;\
	$(TOOLDIR)/join 3 w1.ra w2.ra ws.ra							;\
	$(TOOLDIR)/sample --sigma max=10,min=0.001 -g -N100 -K100 -s111 --gmm mean=mu.ra,var=vars.ra,w=ws.ra --gamma=0.01 -S1 out.ra											;\
	$(TOOLDIR)/nrmse -t 0.0001 mean1.ra out.ra						;\
	$(TOOLDIR)/sample --sigma max=10,min=0.001 -g -N100 -K100 -s111 --gmm mean=mu.ra,var=vars.ra,w=ws.ra --gamma=0.01 -S1 out.ra											;\
	$(TOOLDIR)/nrmse -t 0.0001 mean1.ra out.ra						;\
	rm *.ra; cd .. ; rmdir $(TESTS_TMP)
	touch $@

TESTS += tests/test-sample-gmm1d_mean tests/test-sample-gmm1d_weigthing tests/test-sample-gauss1d_mean_ancestral tests/test-sample-gauss1d_mean_pc tests/test-sample-gmm2d

TESTS_GPU += tests/test-sample-gauss1d_mean_gpu tests/test-sample-gauss1d_var_gpu tests/test-sample-gmm_img_gpu tests/test-sample-gauss1d_mean_real1_gpu tests/test-sample-gauss1d_mean_real_gpu

