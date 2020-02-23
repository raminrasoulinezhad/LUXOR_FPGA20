all : all_expr plots
	
all_expr :
	@./scripts/run.sh -g x,x_l,x_lp,i,i_l,i_lp -f ./tests/all_tests.csv

plots :
	@./scripts/check_all_present.sh && mkdir -p plots | Rscript scripts/make_plots.R

clean :
	@rm cplex.log

really_clean :
	@rm -rf ilp_results results

.PHONY : plots
