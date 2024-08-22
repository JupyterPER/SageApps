import lmfit
import numpy as np

def f_eval_list(f, l):
    ivar = f.variables()[0]
    return np.array([f.subs(ivar==i) for i in l])

def fit_model_fun(f, data, params, var_varfit):
    vars_list = list(var_varfit.keys())
    pd = params.valuesdict()
    subs_vals = [v==pd[var_varfit[v]] for v in vars_list]
    subs_vals_f = f.subs(subs_vals)
    vals = f_eval_list(subs_vals_f,data[:,0])
    return vals

def lmfit_fun(f, data, output, *params_data):
    params = lmfit.Parameters()
    var_varfit = {}
    for par_data in params_data:
        name = str(par_data[0]) + '_fit'
        var_varfit[par_data[0]] = name
        par_min = float(par_data[1])
        par_max = float(par_data[2])
        par_vary = par_data[-1]
        if len(par_data)==5:
            par_init = float(par_data[3])
            params.add(name, min=par_min, max=par_max, value=par_init, vary=par_vary)
        else:
            params.add(name, min=par_min, max=par_max, vary=par_vary)
    fcn = lambda params: (fit_model_fun(f, data, params, var_varfit) - data[:,1]).astype(float)
    estim = lmfit.minimize(fcn, params, method='least_squares') 
    if output=='report':
        print(lmfit.fit_report(estim))
    elif output=='params':
        vars_list = list(var_varfit.keys())
        fit_pars = estim.params
        fit_pars_dict = {v:fit_pars[var_varfit[v]].value for v in vars_list}
        return fit_pars_dict
    elif output=='raw':
        return estim


def fit_model_1ode(model, dvars, ivar, ics, n, data, params, var_varfit):
    vars_list = list(var_varfit.keys())
    pd = params.valuesdict()
    subs_vals = [v==pd[var_varfit[v]] for v in vars_list]        
    subs_vals_model = [eq.subs(subs_vals) for eq in model]
    tmin= data[0,0]
    tmax= data[-1,0]
    dt = data[1,0] - data[0,0]
    if n==1:
        sol = desolve_odeint(subs_vals_model, dvars=dvars, ivar=ivar, ics=ics, times=data[:,0])
    else:
        sol = n_sol(subs_vals_model, dvars, ivar, ics, tmin, tmax, dt, n)
    return sol

# n_sol returns solution for n-times more computed points
def n_sol(eqs, dvars, ivar, ics, tmin, tmax, dt, n=1):
    ndt = dt/n
    times = [tmin, tmin+ndt .. tmax]
    n_sol = desolve_odeint(eqs, times=times, dvars=dvars, ivar=ivar, ics=ics)
    return n_sol[0::n,:]
    


def lmfit_1ode(model, dvars, ivar, ics, n, data, fit_dvar, output, *params_data):
    '''
    model - list of right hand sides of the system of separated 1st order differential equations
    dvars - list of dependent variables
    ivar - an independent variable
    ics - list of initial conditions
    n - number indicating the precision of model evaluation
    data - fitted data in a form [[t_0,x_0], [t_1,x_1], ...]
    fit_dvar - fitted dependent variable
    output - 'report' to obtain fit report or 'params' to obtain dictionary of found parameters
    *params_data - tuples in a form:
        (param_a, min_val, max_val, init_val, vary)
        param_a - symbolic variable coresponding to fitted parameter
        min_val  - lower bound for value of the parameter
        max_val  - upper bound for value of the parameter
        init_val - initial value of the parameter (optional)
        vary     - boolean, whether the parameter is varied during a fit 
        
    '''
    params = lmfit.Parameters()
    var_varfit = {}
    for par_data in params_data:
        name = str(par_data[0]) + '_fit'
        var_varfit[par_data[0]] = name
        par_min = float(par_data[1])
        par_max = float(par_data[2])
        par_vary = par_data[-1]
        if len(par_data)==5:
            par_init = float(par_data[3])
            params.add(name, min=par_min, max=par_max, value=par_init, vary=par_vary)
        else:
            params.add(name, min=par_min, max=par_max, vary=par_vary) 
    
    column = dvars.index(fit_dvar)
    fcn = lambda params: fit_model_1ode(model, dvars, ivar, ics, n, data, params, var_varfit)[:,column].flatten() - data[:,1]#.flatten()
    estim = lmfit.minimize(fcn,params,method='least_squares') 
    if output=='report':
        print(lmfit.fit_report(estim))
        
    elif output=='params':
        vars_list = list(var_varfit.keys())
        fit_pars = estim.params
        fit_pars_dict = {v:fit_pars[var_varfit[v]].value for v in vars_list}
        return fit_pars_dict
    elif output=='raw':
        return estim