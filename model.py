###################################################### README #############################################################
# ILP formulation for compressor tree synthesis for different inputs.
###########################################################################################################################

import argparse, random, csv, timeit, re, os
from pulp import *
import pandas as pd

# Change this path to suit your machine
CPLEX_PATH = "/opt/ibm/ILOG/CPLEX_Studio129/cplex/bin/x86-64_linux/cplex"
CPLEX_TIMEOUT = 300 # None or set value in seconds
CPLEX_QUICKSEARCH_TIMEOUT = 30 # None or set value in seconds

parser = argparse.ArgumentParser(description='ILP Solver based on pulp library')

parser.add_argument('--inputs_file', metavar='INPUTS_FILE', default='tests/all_tests.csv', help='input file with test cases')
parser.add_argument('--gpc_file', metavar='GPC_FILE', default='GPCs/Intel/Baseline.csv', help='compressors file')
parser.add_argument('--i_heuristic', default=10000, type=int, metavar='N', help='constant i in the heuristic model')
parser.add_argument('--l_heuristic', default=10000, type=int, metavar='N', help='constant l in the heuristic model')
parser.add_argument('--max_stages', default=8, type=int, metavar='N', help='maximum number of stages for solving')
parser.add_argument('--arch_name', metavar='ARCH_NAME', default='xilinx', help='architecture name (xilinx/intel), default = xilinx')
parser.add_argument('--iterate_ds', metavar='ITERATE_DS', default='False', help='find solution by iterating d_i = 1, default = False')
parser.add_argument('--use_cplex', metavar='USE_CPLEX', default='False', help='find solution using cplex solver, default = False')
parser.add_argument('--expr_name', metavar='EXPR_NAME', default='opt_model', help='unique name to give to experiment to help identify/differentiate results in results dir. default = opt_model')

VERBOSE = False

class Solver(object) :
    def __init__(self, args, use_xilinx) :

        self.args = args
        self.use_xilinx = use_xilinx
        self.use_cplex = args['use_cplex']
        self.num_max_columns = args['num_max_columns']
        self.num_compressors = args['num_compressors']
        self.max_stages = args['max_stages']
        self.I = args['I']
        self.L = args['L']
        self.M_e = args['M_e']
        self.K_e = args['K_e']
        self.M_e_c = args['M_e_c']
        self.K_e_c = args['K_e_c']
        self.Cost_e = args['Cost_e']
        self.c_names = args['c_names']
        self.iterate_ds = args['iterate_ds']

    def create_base_model(self, iterate_ds = False, ds_id = None) :

        # easy local variable handles
        num_max_columns = self.num_max_columns
        num_compressors = self.num_compressors
        max_stages = self.max_stages
        I = self.I
        L = self.L
        M_e = self.M_e
        K_e = self.K_e
        M_e_c = self.M_e_c
        K_e_c = self.K_e_c
        Cost_e = self.Cost_e
        c_names = self.c_names

        opt_model = LpProblem(name="ILP Model for Compressor Tree Synthesis")

        # N_s_c_variables
        N_s_c_vars = {}
        for s in range(max_stages) :
            for c in range(num_max_columns) :
                N_s_c_vars[(s,c)] = LpVariable(str("N_%d_%d" % (s,c)),0,None,LpInteger)

        # K_s_e_c variables
        k_s_e_c_vars = {}
        for s in range(max_stages) :
            for e in range(num_compressors) :
                for c in range(num_max_columns) :
                    k_s_e_c_vars[(s,e,c)] = LpVariable(str("k_%d_%d_%d" % (s,e,c)),0,None,LpInteger)

        # Ds variables (for C4)
        d_vars = {s : LpVariable(str("d_%d" % (s)),0,1,LpInteger) for s in range(max_stages)}

        # C_s_c variables
        C_s_c_vars = {}
        for s in range(max_stages) :
            for c in range(num_max_columns) :
                C_s_c_vars[(s,c)] = LpVariable(str("C_%d_%d" % (s,c)),None,None,LpInteger)

        ########## build and add constraints to model ##########
        # add constraints to first row in N_s_c_vars, as they are inputs
        for c in range(num_max_columns) :
            opt_model += N_s_c_vars[(0,c)] == self.args['Nsc_inputs'][c], str("input_%d" % (c))

        # C1' constraints
        for s in range(1,max_stages) :
            for c in range(num_max_columns) :
                sum_terms = []
                sm1 = s-1
                for e in range(num_compressors) :
                    for cp in range(M_e[e]) :
                        if c - cp >= 0 :
                            sum_terms.append( M_e_c[(e,cp)] * k_s_e_c_vars[(sm1,e,(c-cp))] )
                opt_model += lpSum(sum_terms) - N_s_c_vars[(sm1,c)] >= 0, str("C1_%d_%d" % (sm1,c))

        # C2 constraints
        for s in range(1,max_stages) :
            for c in range(num_max_columns) :
                sum_terms = []
                sm1 = s - 1
                for e in range(num_compressors) :
                    for cp in range(K_e[e]) :
                        if c < cp :
                            continue
                        sum_terms.append( K_e_c[(e,cp)] * k_s_e_c_vars[(sm1,e,(c-cp))] )
                opt_model += lpSum(sum_terms) - N_s_c_vars[(s,c)] == 0, str("C2_%d_%d" % (s,c))

        # C4 constraint
        sum_terms = []
        for s in range(1,max_stages) :
            sum_terms.append(d_vars[s])
        opt_model += lpSum(sum_terms) == 1, "constraint_C4"

        # C5 constraints (on carry-ins)
        for s in range(max_stages) :
            opt_model += C_s_c_vars[(s,0)] == 0, str("cin_input_%d_%d" % (s,0))
        for s in range(max_stages) :
            for c in range(1,num_max_columns) :
                opt_model += C_s_c_vars[(s,c)] - 0.5*C_s_c_vars[(s,c-1)] - 0.5*N_s_c_vars[(s,c-1)] + 0.999 >= 0, str("cin_input_%d_%d_ge" % (s,c))
                opt_model += C_s_c_vars[(s,c)] - 0.5*C_s_c_vars[(s,c-1)] - 0.5*N_s_c_vars[(s,c-1)] <= 0, str("cin_input_%d_%d_le" % (s,c))

        if self.use_xilinx :
            self.add_relaxed_termination_constraints(opt_model, N_s_c_vars, d_vars, C_s_c_vars, iterate_ds, ds_id)
        else :
            self.add_termination_constraints(opt_model, N_s_c_vars, d_vars, iterate_ds = iterate_ds, ds_id = ds_id)

        # define objective
        sum_terms = []
        for s in range(max_stages) :
            for c in range(num_max_columns) :
                for e in range(num_compressors) :
                    sum_terms.append(Cost_e[e]*k_s_e_c_vars[(s,e,c)])
            if not iterate_ds :
                sum_terms.append(s*L*d_vars[s])
        objective = lpSum(sum_terms)

        # add objective to model
        opt_model.sense = LpMinimize
        opt_model.setObjective(objective)
        if VERBOSE :
            opt_model.writeLP("model.lp")

        return opt_model, k_s_e_c_vars, d_vars

    def add_termination_constraints(self, opt_model, N_s_c_vars, d_vars, iterate_ds = False, ds_id = None) :

        print("Termination constraints used: 3-input VMA in last stage.")

        max_stages = self.max_stages
        num_max_columns = self.num_max_columns
        I = self.I

        # C3' constraints (from Kumm and Zipf paper)
        if iterate_ds :
            for s in range(1,max_stages) :
                for c in range(num_max_columns) :
                    if s == ds_id :
                        opt_model += 3 - N_s_c_vars[(s,c)] >= 0, str("C3_%d_%d" % (s,c))
        else :
            for s in range(1,max_stages) :
                for c in range(num_max_columns) :
                    opt_model += 3 + (1 - d_vars[s])*I - N_s_c_vars[(s,c)] >= 0, str("C3_%d_%d" % (s,c))

    def add_relaxed_termination_constraints(self, opt_model, N_s_c_vars, d_vars, C_s_c_vars, iterate_ds = False, ds_id = None) :

        print("Termination constraints used: Relaxed carry-chain in last stage.")

        max_stages = self.max_stages
        num_max_columns = self.num_max_columns
        I = self.I

        # new C3' constraints to define termination point based on carries (two versions, based on whether iterate_ds is true or not)
        if iterate_ds :
            for s in range(1,max_stages) :
                for c in range(num_max_columns) :
                    if s == ds_id :
                        opt_model += 5 - N_s_c_vars[(s,c)] - C_s_c_vars[(s,c)] >= 0, str("C3.1_%d_%d" % (s,c))
                        opt_model += 4 - N_s_c_vars[(s,c)] >= 0, str("C3.2_%d_%d" % (s,c))
                        opt_model += 2 - C_s_c_vars[(s,c)] >= 0, str("C3.3_%d_%d" % (s,c))
                    # else evaluation not needed -- no use constraining intermediate stages
        else :
            for s in range(1,max_stages) :
                for c in range(num_max_columns) :
                    opt_model += 5 + (1 - d_vars[s])*I - N_s_c_vars[(s,c)] - C_s_c_vars[(s,c)] >= 0, str("C3.1_%d_%d" % (s,c))
                    opt_model += 4 + (1 - d_vars[s])*I - N_s_c_vars[(s,c)] >= 0, str("C3.2_%d_%d" % (s,c))
                    opt_model += 2 + (1 - d_vars[s])*I - C_s_c_vars[(s,c)] >= 0, str("C3.3_%d_%d" % (s,c))

    def build_and_run_model(self, output_file = "opt_soln.csv") :

        # easy local variable handles
        num_max_columns = self.num_max_columns
        num_compressors = self.num_compressors
        max_stages = self.max_stages
        I = self.I
        L = self.L
        M_e = self.M_e
        K_e = self.K_e
        M_e_c = self.M_e_c
        K_e_c = self.K_e_c
        Cost_e = self.Cost_e
        c_names = self.c_names
        iterate_ds = self.iterate_ds

        # solve model iteratively or once
        if iterate_ds :
            status = 'Infeasible'
            current_di = 1
            while status != 'Optimal' and current_di < max_stages :

                start = timeit.default_timer()
                print("\t ---------------- Trying by setting d_vars[%d] == 1 ----------------" % (current_di))
                for i in range(current_di) :
                    seed = random.randint(0,1000000000)
                    seed_worked = False
                    opts = [str("set randomseed %d" % (seed))]
                    # create base model and add force_d_i constraint
                    opt_model, k_s_e_c_vars, d_vars = self.create_base_model(iterate_ds = True, ds_id = current_di)
                    for j in range(1,max_stages) :
                        if j == current_di :
                            opt_model += d_vars[current_di] == 1, str("force1_d_%d" % (current_di))
                        else :
                            opt_model += d_vars[j] == 0, str("force0_d_%d" % (j))

                    # solve the model with a multi-stage quicksearch approach
                    if self.use_cplex :
                        if CPLEX_TIMEOUT is None :
                            opt_model.solve(CPLEX())
                        else :
                            opt_model.solve(CPLEX_CMD(path=CPLEX_PATH,timelimit=CPLEX_QUICKSEARCH_TIMEOUT,options=opts))
                    else :
                        opt_model.solve()

                    # update status and current_di heuristic
                    status = LpStatus[opt_model.status]

                    if self.use_cplex and CPLEX_TIMEOUT != None and status == "Optimal" : # re-run with longer timeout
                        print("\t\tFound optimal with quick-search, running with longer timeout (%d)" % (CPLEX_TIMEOUT))
                        opt_model.solve(CPLEX_CMD(path=CPLEX_PATH,timelimit=CPLEX_TIMEOUT,options=opts))

                    elapsed = timeit.default_timer() - start

                    print("\t\t[Try %d] Time Elapsed = %f, Status = %s" % (i+1,elapsed,status))

                    if status == "Optimal" :
                        break

                current_di += 1
        else :
            opt_model, k_s_e_c_vars, _ = self.create_base_model()
            # solve the model
            if self.use_cplex :
                if CPLEX_TIMEOUT is None :
                    opt_model.solve(CPLEX())
                else :
                    opt_model.solve(CPLEX_CMD(path=CPLEX_PATH,timelimit=CPLEX_QUICKSEARCH_TIMEOUT))
            else :
                opt_model.solve()
            status = LpStatus[opt_model.status]

        # some helpful prints
        print("Final Model-Solve Status: %s." % (status))
        soln_d = -1
        for v in opt_model.variables():
            if 'd' in v.name :
                print("%s = %d" % (v.name,v.varValue))
                if v.varValue == 1 :
                    soln_d = int(re.sub("d_","",v.name))

        assert soln_d != -1 and status == "Optimal"
        
        opt_df = pd.DataFrame.from_dict(k_s_e_c_vars,orient="index",columns=["variable_object"])
        opt_df.index = pd.MultiIndex.from_tuples(opt_df.index,names=["column_s","column_e","column_c"])
        opt_df.reset_index(inplace=True)
        opt_df["solution_value"] = opt_df["variable_object"].apply(lambda item: item.varValue)
        opt_df.drop(columns=["variable_object"],inplace=True)
        opt_df = opt_df[(opt_df.column_s < soln_d) & (opt_df.solution_value > 0)]
        opt_df.to_csv(output_file)

        total_stages = -1
        running_cost = -1
        if status == "Optimal" :
            print("-------------------------------- Solution ----------------------------------")
            running_cost = 0
            for index, row in opt_df.iterrows() :
                s = int(row['column_s'])
                e = int(row['column_e'])
                c = int(row['column_c'])
                v = int(round(float(row['solution_value'])))
                running_cost += v*Cost_e[e]
                print("[Stage %d] Compressor %s x %d in column %d. Running cost = %f." % (s,c_names[e],v,c,running_cost))
            total_stages = s
            print("\nFinal total LUT cost = %d. Total stages = %d." % (running_cost,total_stages))
            print("-----------------------------------------------------------------------------")
            print("Model solution for k_s_e_c variables stored in '%s'" % (output_file))
            print("-----------------------------------------------------------------------------")
        else :
            print("Model infeasible, not saving/showing outcome.")

        # return value(opt_model.objective), total_stages
        return running_cost, total_stages

#################################################################################################################################################

def read_compressor_csv(fname) :
    num_compressors = 0
    c_names = {}
    Cost_e = {}
    M_e = {}
    K_e = {}
    M_e_c = {}
    K_e_c = {}
    max_Ke = 0
    max_Me = 0
    with open(fname, "r") as fp :
        reader = csv.reader(fp,delimiter=',')
        for row in reader :

            if not row: 
                continue
            if row[0][0] == '#':
                continue 

            M_e[num_compressors] = int(row[1])
            K_e[num_compressors] = int(row[2])
            max_Me = max(max_Me,int(row[1]))
            max_Ke = max(max_Ke,int(row[2]))
            for i in range(int(row[1])) :
                M_e_c[(num_compressors,i)] = int(row[3+i])
            for i in range(int(row[2])) :
                K_e_c[(num_compressors,i)] = int(row[3+int(row[1])+i])
            Cost_e[num_compressors] = float(row[3+int(row[1])+int(row[2])])
            c_names[num_compressors] = row[0]
            print("Loaded compressor %d: %s" % (num_compressors,row[0]))
            num_compressors += 1

    # pad M_e_c and K_e_c
    for e in range(num_compressors) :
        for i in range(K_e[e],max_Ke) :
            K_e_c[(e,i)] = 0
        for i in range(M_e[e],max_Me) :
            M_e_c[(e,i)] = 0

    return num_compressors, M_e, K_e, M_e_c, K_e_c, Cost_e, c_names

def read_inputs(fname) :
    inputs = {}
    max_columns = {}
    num_inputs = 0
    with open(fname,"r") as fp :
        reader = csv.reader(fp,delimiter=',')

        for row in reader:
            
            if not row: 
                continue
            if row[0][0] == '#':
                continue    

            inp = []
            max_col = int(row[0])
            for i in range(int(row[1])) :
                inp.append(int(row[2+i]))
            for i in range(int(row[1]),max_col) : # pad
                inp.append(0)
            inputs[num_inputs] = inp
            max_columns[num_inputs] = max_col
            num_inputs += 1

    return num_inputs, max_columns, inputs

if __name__ == "__main__" :

    args = parser.parse_args()

    if (args.arch_name == 'xilinx'):
    	USE_XILINX = True
    elif (args.arch_name == 'intel'):
    	USE_XILINX = False
    else:
    	raise Exception('The inserted arch_name is not supported. please use xilinx/intel')

    if args.iterate_ds.lower() in ['t','true','1','y'] :
    	ITERATE_DS = True
    else :
    	ITERATE_DS = False

    if args.use_cplex.lower() in ['t','true','1','y'] :
    	USE_CPLEX = True
    else :
    	USE_CPLEX = False

    GPC_FILE = args.gpc_file
    INPUTS_FILE = args.inputs_file

    # currently unused due to corrections in model proposed by Kumm et.al
    I_HEURISTIC = args.i_heuristic # default: 10000   
    L_HEURISTIC = args.l_heuristic # default: 10000   
    MAX_STAGES = args.max_stages 		
    EXPR_NAME = args.expr_name

    num_compressors, M_e, K_e, M_e_c, K_e_c, Cost_e, c_names = read_compressor_csv(GPC_FILE)
    num_inputs, max_columns, inputs = read_inputs(INPUTS_FILE)
    TEST_NAME = os.path.splitext(os.path.basename(INPUTS_FILE))[0]

    for i in range(num_inputs) :

        # measuring the time 
        start = timeit.default_timer()

        print("\n------------------------------- %d -------------------------------" % ((i)))
        print("Solving with inputs %s." % (str(inputs[i])))
        print("Use Xilinx = %s." % (str(USE_XILINX)))
        args = dict(
            num_max_columns = max_columns[i], # i.e. maximum number of bits in input/output
            Nsc_inputs = inputs[i], # i.e. input to feed into the solver
            num_compressors = num_compressors, # i.e. number of unique compresors
            M_e = M_e, # i.e. number of columns consumed by each compressor 
            K_e = K_e, # i.e. number of columns output by each compressor 
            M_e_c = M_e_c, # i.e. number of dots consumed in each column by each compressor
            K_e_c = K_e_c, # i.e. number of dots output in each column by each compressor
            Cost_e = Cost_e, # i.e. cost of each compressor in LUTs
            c_names = c_names, # i.e. compressor names
            max_stages = MAX_STAGES, # i.e. max number of stages to try (kind of like a heuristic)
            I = I_HEURISTIC, # heuristic
            L = L_HEURISTIC, # heuristic
            iterate_ds = ITERATE_DS,
            use_cplex = USE_CPLEX
        )

        s = Solver(args,USE_XILINX)
        
        if not os.path.exists('./ilp_results'):
            os.makedirs('./ilp_results')
        if not os.path.exists('./results'):
            os.makedirs('./results')

        ilp_output_file = str("./ilp_results/%s_%s_%d.csv" % (EXPR_NAME,TEST_NAME,i))
        output_file = str("./results/%s_%s_%d.csv" % (EXPR_NAME,TEST_NAME,i))

        final_cost, stages = s.build_and_run_model(output_file = ilp_output_file)
        print("Model cost = %d LUTs, stages = %d" % (final_cost,stages))

        stop = timeit.default_timer()
        print('Time: ', stop - start)  

        with open(output_file,"w") as fp :
            fp.write("cost_luts,stages\n")
            fp.write("%d,%d\n" % (final_cost,stages))

