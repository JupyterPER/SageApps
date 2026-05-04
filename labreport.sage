print("Downloading the package labreport...")

# nacitanie kniznic
import numpy as np
import pandas as pd

import metrolopy as uc
import sigfig as sf
import sys
import os
import tempfile
import zipfile
import urllib.request
import warnings
import lmfit

# Disable DeprecationWarnings
warnings.filterwarnings("ignore", category=DeprecationWarning)
warnings.filterwarnings("ignore", category=FutureWarning)  # Also helpful for some packages
warnings.filterwarnings("ignore", category=SyntaxWarning)  # Do not show No syntax problems

def np_zip(list1, list2):
    return np.column_stack((list1, list2))

def sum_of_squares(arr1, arr2):
    return np.sum(np.square(np.ravel(arr1) - np.ravel(arr2)))

from IPython.display import YouTubeVideo
from numpy import array as v
sv = lambda zoznam: vector(zoznam)
from numpy import float64 as dc
from scipy.stats import sem as stsem
from numpy import mean as npmean
from numpy import std as npstd
from IPython.display import IFrame

std = lambda x: npstd(x,ddof=1).item()
mean = lambda x: npmean(x).item()
sem = lambda x: stsem(x).item()

def import_github_package(github_repo_url, module_name, branch='master'):
    """
    Downloads a GitHub repository as a zip file, extracts it,
    adds it to sys.path, and imports the specified module.

    Parameters:
      github_repo_url (str): The URL of the GitHub repository.
      module_name (str): The name of the package/module to import.
      branch (str): The branch to download (default is 'master').

    Returns:
      module: The imported module.
    """
    # Create a temporary directory
    temp_dir = tempfile.mkdtemp()

    # Construct the zip file URL (assumes the repository is public)
    zip_url = f"{github_repo_url}/archive/refs/heads/{branch}.zip"
    zip_path = os.path.join(temp_dir, f"{module_name.lower()}.zip")
    urllib.request.urlretrieve(zip_url, zip_path)

    # Extract the zip file
    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        zip_ref.extractall(temp_dir)

    # The extracted folder usually has a name like "{module_name}-{branch}"
    extracted_dir = None
    for item in os.listdir(temp_dir):
        if os.path.isdir(os.path.join(temp_dir, item)) and item.startswith(module_name + "-"):
            extracted_dir = os.path.join(temp_dir, item)
            break

    if extracted_dir is None:
        raise Exception("Failed to locate the extracted package directory.")

    # Add the extracted directory to sys.path
    sys.path.insert(0, extracted_dir)

    # Import and return the module
    imported_module = __import__(module_name.lower())
    return imported_module

# Sigfig package
# repo = "https://github.com/drakegroup/sigfig" 
# module = "sigfig"
# package = import_github_package(repo, module)
# import sigfig as sf

# Metrolopy package
# repo = "https://github.com/nrc-cnrc/MetroloPy" 
# module = "MetroloPy"
# package = import_github_package(repo, module)
#import metrolopy as uc

uc.gummy.style = '+-'
from functools import wraps
from sigfig import round as sigfig_round

@wraps(sigfig_round)
def sfround(*args, **kwargs):
    kwargs.setdefault("cutoff", 99)
    return sigfig_round(*args, **kwargs)

def budget(gvel, gnames, form = 'final', notation='', transpose = True):
    indirect = gnames[0]
    direct = gnames[1:]
    table = gvel[0].budget(gvel[1:], xnames = direct)
    Unit = gvel[0].budget(gvel[1:], xnames = direct, uunit='%').df['Unit']
    if form != 'final':
        db = table.df.astype(float, errors='ignore')
        if not 'Unit' in db.columns:
            db.insert(1r, 'Unit', Unit)
        db.set_index(['Component'], inplace=True)
        db = db.reindex(direct+[indirect])
        db.drop(columns='s', inplace=True)
        dydx = db['|dy/dx|']
        db.drop(columns='|dy/dx|', inplace=True)
        db['rel. u %'] = db['u']/db['Value']*100
        db['|dy/dx|'] = dydx 
        db['|dy/dx|.u'] = db['u']*db['|dy/dx|']
        db['vars'] = (db['u']*db['|dy/dx|'])**2
        db.loc[indirect,'vars'] = db['vars'].sum() 
        db.loc[indirect,'|dy/dx|'] = 1 
        db.loc[indirect,'u'] = np.sqrt(db.loc[indirect,'vars'])
        db.loc[indirect,'rel. u %'] = db.loc[indirect,'u']/db.loc[indirect,'Value']*100
        db.loc[indirect,'|dy/dx|.u'] = db.loc[indirect,'u']
        db['rel. vars %'] = db['vars']/db.loc[indirect,'u']**2*100
        db['s'] = np.sqrt(db['rel. vars %'])/10
        db.set_index(['Unit'], append=True, inplace=True)
        if notation == 'decimal':
            table = db.fillna('').astype(str)
        elif notation == 'scientific':
            table = db.applymap(lambda x: f"{float(x):.2e}" if isinstance(x, (int, float)) else x)
        else:
            table = db.fillna('')
        if transpose:
            table = table.transpose()
    return table

def ipyurl(url, storage='google', medium = 'image'):
    if medium == 'image':
        if storage=='google':
            url = url.replace('file/d/','uc?id=').replace('/view?usp=sharing', '')
        else:
            url = url.replace('?dl=0','?raw=1')
    if medium == 'table':
            url = url.replace('edit','preview')
    return url

def frame_wrapping(df, fillna=True):
    def format_line_break(value):
        if isinstance(value, str):
            value = value.replace('\n', '<br>')
        return value
    
    if fillna:
        # Replace column names containing 'Unnamed' with empty strings
        df.columns = [col if 'Unnamed' not in col else '' for col in df.columns]
    
        # Replace NaN values with empty strings
        df = df.fillna('')
    
    wrapped_df  = df.style.format(formatter=format_line_break)
    return wrapped_df 

from IPython.display import display, HTML
display(HTML("<style>.container { width:100% !important; }</style>"))

# from googletrans import Translator
# translator = Translator()
# trENGSK = lambda text:translator.translate(text, src='en', dest='sk').text.replace('.','. ')

# from molmass import Formula as vzorec
# from mendeleev import element as prvok
# from scipy.constants import R as Rv, zero_Celsius as Z0, N_A as NA
# from scipy.constants import find, physical_constants as konst

print('The contents of the package have been loaded successfully.')

def showURL(url, ht=424):

    '''shortcut for IFrame displaying various media at given url address;
       for interactive SageMath worksheets it is appropriate height 424 and width 100%
    '''
    from IPython.display import IFrame
    return IFrame(url, width='100%', height=ht)

def read_google_table(url):
    """
    Read data from a Google Sheets URL and return it as a pandas DataFrame.

    Parameters:
    - url (str): The URL of the Google Sheets document.
                 The URL should be in one of the following formats:
                 - 'https://docs.google.com/spreadsheets/d/{id}/edit#gid={gid}' (copied from address bar, document must be in a publicly accessible folder)
                 - 'https://docs.google.com/spreadsheets/d/{id}/edit?gid={gid}...' (copied from address bar, document must be in a publicly accessible folder)
                 - 'https://docs.google.com/spreadsheets/d/{id}/preview#gid={gid}'
                 - 'https://docs.google.com/spreadsheets/d/{id}/edit?usp=sharing' (obtained through the Share option)

    Returns:
    - pandas.DataFrame: A DataFrame containing the data from the Google Sheets document.
                        If the URL is not valid, returns an error message string.

    Example usage:
    >>> url = 'https://docs.google.com/spreadsheets/d/1WF2bZoDZhYQWek2tSNjB-Lg6EeD78sUfTENOdCGJyIA/edit#gid=1118323065'
    >>> df = read_google_table(url)
    >>> print(df.head())

    Note:
    - The Google Sheets document must be publicly accessible.
    - The function assumes that the data in the Google Sheets document is in a format compatible with CSV export.
    """
    if 'edit#' in url:
        URL = url.replace('edit#', 'export?format=csv&')
    elif 'edit?' in url:
        URL = url.replace('edit?', 'export?format=csv&')
    elif 'preview?' in url:
        URL = url.replace('preview?', 'export?format=csv&')
    elif 'preview#' in url:
        URL = url.replace('preview#', 'export?format=csv&')
    elif 'edit?usp=sharing' in url:
        URL = url.replace('edit?usp=sharing', 'export?format=csv')
    else:
        return "Not valid URL, see 'help(read_google_table)'."
    gdf = pd.read_csv(URL)
    gdf = gdf.replace('\n',' ', regex=True)
    gdf.columns = [col.replace('\n', ' ') for col in gdf.columns]
    return gdf

# ============================================================
# lmfit tools for SageMath
# Explicit symbolic models and first-order ODE models
# Always return full result dictionary
# Automatically print available dictionary keys
# Includes approximate confidence bands for ODE fits
# ============================================================

import lmfit
import numpy as np


# ============================================================
# Internal helper: print available keys
# ============================================================

def _print_fit_keys(result):
    """
    Print available keys in the fit result dictionary.
    """
    print("Available fit dictionary keys:")
    for key in result.keys():
        print("  fit['" + key + "']")


# ============================================================
# Internal helper: add lmfit parameters
# ============================================================

def _add_lmfit_parameter(params, var_varfit, par_data):
    """
    Add one parameter to lmfit.Parameters.

    Accepted forms:

        (param, min_val, max_val, init_val, vary)

    or

        (param, min_val, max_val, vary)

    If init_val is not given, the midpoint of finite bounds is used.
    """
    if len(par_data) not in [4, 5]:
        raise ValueError(
            "Parameter data must have the form "
            "(param, min_val, max_val, vary) or "
            "(param, min_val, max_val, init_val, vary)."
        )

    par = par_data[0]
    name = str(par) + '_fit'
    var_varfit[par] = name

    par_min = float(par_data[1])
    par_max = float(par_data[2])
    par_vary = bool(par_data[-1])

    if len(par_data) == 5:
        par_init = float(par_data[3])
    else:
        # Automatic initial value if not supplied
        if np.isfinite(par_min) and np.isfinite(par_max):
            par_init = (par_min + par_max) / 2
        elif np.isfinite(par_min):
            par_init = par_min + 1.0
        elif np.isfinite(par_max):
            par_init = par_max - 1.0
        else:
            par_init = 1.0

    params.add(
        name,
        min=par_min,
        max=par_max,
        value=par_init,
        vary=par_vary
    )


# ============================================================
# Basic fitting of explicit symbolic functions
# ============================================================

def f_eval_list(f, l):
    """
    Evaluate a one-variable Sage symbolic expression f on a list/array l.
    """
    f = SR(f)
    ivar = f.variables()[0]
    return np.array([f.subs(ivar == i) for i in l])


def fit_model_fun(f, data, params, var_varfit):
    """
    Evaluate an explicit symbolic model f after substituting fitted parameters.
    """
    f = SR(f)

    vars_list = list(var_varfit.keys())
    pd = params.valuesdict()

    subs_vals = [v == pd[var_varfit[v]] for v in vars_list]
    subs_vals_f = f.subs(subs_vals)

    vals = f_eval_list(subs_vals_f, data[:, 0])
    return vals


# ============================================================
# Helper: collect all useful lmfit outputs
# ============================================================

def _collect_lmfit_output(estim, var_varfit, data):
    """
    Collect useful outputs from lmfit.MinimizerResult.

    In these wrappers the residual is defined as

        residual = model_values - data_values

    Therefore

        best_fit = data_values + residual

    This follows the naming convention of lmfit.ModelResult,
    where fitted model values are stored as best_fit.
    """
    t_values = np.array(data[:, 0], dtype=float).flatten()
    y_data = np.array(data[:, 1], dtype=float).flatten()

    residuals = np.array(estim.residual, dtype=float).flatten()

    # Since residual = model - data
    best_fit = y_data + residuals

    # Fitted parameter values
    fit_pars_dict = {
        v: estim.params[var_varfit[v]].value
        for v in var_varfit.keys()
    }

    # Standard errors of fitted parameters
    stderr_dict = {
        v: estim.params[var_varfit[v]].stderr
        for v in var_varfit.keys()
    }

    # Relative standard errors in percent
    rel_stderr_dict = {}

    for v in var_varfit.keys():
        lmfit_name = var_varfit[v]
        par = estim.params[lmfit_name]

        value = par.value
        stderr = par.stderr

        if stderr is None or value == 0:
            rel_stderr_dict[v] = None
        else:
            rel_stderr_dict[v] = abs(stderr / value) * 100

    # Detailed parameter summary
    param_summary = {}

    for v in var_varfit.keys():
        lmfit_name = var_varfit[v]
        par = estim.params[lmfit_name]

        param_summary[v] = {
            "lmfit_name": lmfit_name,
            "value": par.value,
            "stderr": par.stderr,
            "relative_stderr_percent": rel_stderr_dict[v],
            "min": par.min,
            "max": par.max,
            "vary": par.vary,
            "init_value": par.init_value
        }

    # Varying parameters in the order used by lmfit covariance matrix
    varying_lmfit_names = list(getattr(estim, "var_names", []))

    if len(varying_lmfit_names) == 0:
        varying_lmfit_names = [
            var_varfit[v]
            for v in var_varfit.keys()
            if estim.params[var_varfit[v]].vary
        ]

    lmfit_name_to_symbol = {
        var_varfit[v]: v
        for v in var_varfit.keys()
    }

    varying_symbols = [
        lmfit_name_to_symbol[name]
        for name in varying_lmfit_names
        if name in lmfit_name_to_symbol
    ]

    return {
        # Parameter information
        "params": fit_pars_dict,
        "stderr": stderr_dict,
        "relative_stderr_percent": rel_stderr_dict,
        "param_summary": param_summary,

        # Parameter ordering information
        "varying_params": varying_symbols,
        "varying_lmfit_names": varying_lmfit_names,

        # lmfit-style fitted values
        "best_fit": best_fit,

        # Alias
        "fit_values": best_fit,

        # Residuals
        "residuals": residuals,

        # Fit statistics
        "chisqr": estim.chisqr,
        "redchi": estim.redchi,
        "residual_standard_error": np.sqrt(estim.redchi),
        "aic": estim.aic,
        "bic": estim.bic,

        # Covariance matrix, if available
        "covar": estim.covar,

        # Report and raw object
        "report": lmfit.fit_report(estim),
        "raw": estim,

        # Original data
        "t": t_values,
        "y_data": y_data,

        # Useful two-column arrays
        "data_fit": np.column_stack((t_values, best_fit)),
        "data_residuals": np.column_stack((t_values, residuals))
    }


# ============================================================
# Main lmfit wrapper for explicit symbolic functions
# Always returns full result dictionary
# ============================================================

def lmfit_fun(f, data, *params_data):
    """
    Fit an explicit one-variable symbolic function.

    Always returns a dictionary with keys:

        "params"
        "stderr"
        "relative_stderr_percent"
        "param_summary"
        "varying_params"
        "varying_lmfit_names"
        "best_fit"
        "fit_values"
        "residuals"
        "chisqr"
        "redchi"
        "residual_standard_error"
        "aic"
        "bic"
        "covar"
        "report"
        "raw"
        "t"
        "y_data"
        "data_fit"
        "data_residuals"

    Parameter tuples have the form

        (param, min_val, max_val, init_val, vary)

    or

        (param, min_val, max_val, vary)

    Convention
    ----------
    residual = model - data
    """
    data = np.array(data, dtype=float)

    params = lmfit.Parameters()
    var_varfit = {}

    for par_data in params_data:
        _add_lmfit_parameter(params, var_varfit, par_data)

    fcn = lambda params: (
        fit_model_fun(f, data, params, var_varfit) - data[:, 1]
    ).astype(float)

    estim = lmfit.minimize(fcn, params, method='least_squares')

    result = _collect_lmfit_output(
        estim,
        var_varfit,
        data
    )

    _print_fit_keys(result)

    return result


# ============================================================
# Helper for refined ODE evaluation
# ============================================================

def refined_times_from_data(data_times, n=1):
    """
    Create time points for ODE integration.

    If n = 1:
        return original data times.

    If n > 1:
        insert n-1 intermediate points between consecutive data times.

    This allows the ODE solver to compute on a finer time grid,
    while the fit is still compared only at the original measured times.
    """
    data_times = [float(t) for t in data_times]

    if n == 1:
        return data_times

    times = []

    for i in range(len(data_times) - 1):
        t_left = data_times[i]
        t_right = data_times[i + 1]

        interval_times = np.linspace(t_left, t_right, n + 1)

        if i == 0:
            times.extend(interval_times)
        else:
            times.extend(interval_times[1:])

    return [float(t) for t in times]


# ============================================================
# ODE model evaluation
# ============================================================

def fit_model_1ode(model, dvars, ivar, ics, n, data, params, var_varfit):
    """
    Evaluate a system of first-order ODEs after substituting fitted parameters.

    Examples
    --------

    One ODE:

        dv/dt = g

        model = [g]
        dvars = [v]
        ics = [v0]

    System of ODEs:

        dy/dt = v
        dv/dt = -g

        model = [v, -g]
        dvars = [y, v]
        ics = [y0, v0]

    Important
    ---------
    For one-dimensional ODEs this function internally adds a hidden
    dummy equation. Students can still write the natural model:

        model = [g]
        dvars = [v]
        ics = [v0]

    The dummy variable is only an implementation detail.
    """
    data = np.array(data, dtype=float)

    vars_list = list(var_varfit.keys())
    pd = params.valuesdict()

    subs_vals = [v == pd[var_varfit[v]] for v in vars_list]

    # SR(eq) makes the code robust also when some equation is plain 0.
    subs_vals_model = [SR(eq).subs(subs_vals) for eq in model]

    times = refined_times_from_data(data[:, 0], n)
    ics_num = [float(ic) for ic in ics]

    # ------------------------------------------------------------
    # Hidden dummy-variable trick for one-dimensional ODEs
    # ------------------------------------------------------------
    if len(dvars) == 1:
        dummy = SR.var('_lmfit_internal_dummy')

        augmented_model = [subs_vals_model[0], SR(0)]
        augmented_dvars = [dvars[0], dummy]
        augmented_ics = [ics_num[0], 0.0]

        sol = desolve_odeint(
            augmented_model,
            dvars=augmented_dvars,
            ivar=ivar,
            ics=augmented_ics,
            times=times
        )

        sol = np.array(sol, dtype=float)

        if n > 1:
            sol = sol[0::n, :]

        # Return only the original dependent variable.
        return sol[:, 0:1]

    # ------------------------------------------------------------
    # Genuine system of two or more first-order ODEs
    # ------------------------------------------------------------
    sol = desolve_odeint(
        subs_vals_model,
        dvars=dvars,
        ivar=ivar,
        ics=ics_num,
        times=times
    )

    sol = np.array(sol, dtype=float)

    if n > 1:
        sol = sol[0::n, :]

    return sol


# ============================================================
# Main lmfit wrapper for first-order ODE models
# Always returns full result dictionary
# ============================================================

def lmfit_1ode(model, dvars, ivar, ics, n, data, fit_dvar, *params_data):
    """
    Fit a first-order ODE model using lmfit.

    Always returns a dictionary with keys:

        "params"
        "stderr"
        "relative_stderr_percent"
        "param_summary"
        "varying_params"
        "varying_lmfit_names"
        "best_fit"
        "fit_values"
        "residuals"
        "chisqr"
        "redchi"
        "residual_standard_error"
        "aic"
        "bic"
        "covar"
        "report"
        "raw"
        "t"
        "y_data"
        "data_fit"
        "data_residuals"

    Parameters
    ----------
    model :
        List of right-hand sides of separated first-order ODEs.

    dvars :
        List of dependent variables.

    ivar :
        Independent variable.

    ics :
        List of initial conditions.

    n :
        Refinement factor for model evaluation.

    data :
        Fitted data in the form

            [[t_0, y_0],
             [t_1, y_1],
             ...]

    fit_dvar :
        Dependent variable fitted to the second column of data.

    params_data :
        Parameter tuples of the form

            (param, min_val, max_val, init_val, vary)

        or

            (param, min_val, max_val, vary)

    Convention
    ----------
    residual = model - data

    Therefore

    best_fit = data + residual
    """
    data = np.array(data, dtype=float)

    params = lmfit.Parameters()
    var_varfit = {}

    for par_data in params_data:
        _add_lmfit_parameter(params, var_varfit, par_data)

    column = dvars.index(fit_dvar)

    fcn = lambda params: (
        fit_model_1ode(
            model,
            dvars,
            ivar,
            ics,
            n,
            data,
            params,
            var_varfit
        )[:, column].flatten()
        - data[:, 1]
    ).astype(float)

    estim = lmfit.minimize(fcn, params, method='least_squares')

    result = _collect_lmfit_output(
        estim,
        var_varfit,
        data
    )

    _print_fit_keys(result)

    return result


# ============================================================
# Evaluate ODE model at chosen parameter values
# ============================================================

def ode_best_fit_at_params(model, dvars, ivar, ics, n, data, fit_dvar, param_values):
    """
    Evaluate an ODE model at chosen parameter values.

    Parameters
    ----------
    param_values :
        Dictionary such as

            {g: 9.81}

        or

            {g: 9.81, k: 0.12}

    Returns
    -------
    NumPy array of fitted values for fit_dvar at the data time points.
    """
    data = np.array(data, dtype=float)

    params = lmfit.Parameters()
    var_varfit = {}

    for par, val in param_values.items():
        name = str(par) + '_fit'
        var_varfit[par] = name
        params.add(name, value=float(val), vary=False)

    column = dvars.index(fit_dvar)

    sol = fit_model_1ode(
        model,
        dvars,
        ivar,
        ics,
        n,
        data,
        params,
        var_varfit
    )

    return sol[:, column].flatten()


# ============================================================
# Approximate confidence band for ODE fit
# ============================================================

def ode_confidence_band(
    fit,
    model,
    dvars,
    ivar,
    ics,
    n,
    data,
    fit_dvar,
    sigma=2,
    rel_step=1e-6
):
    """
    Approximate pointwise confidence band for an ODE fit.

    The method uses finite-difference sensitivities and the covariance
    matrix from lmfit.

    Mathematical idea
    -----------------

    If theta is the vector of fitted parameters, then

        Var(y_hat(t_i)) approx J_i C J_i^T,

    where C is the covariance matrix of fitted parameters and J_i is the
    row of sensitivities

        dy(t_i)/dtheta_j.

    Parameters
    ----------
    fit :
        Result dictionary returned by lmfit_1ode.

    model, dvars, ivar, ics, n, data, fit_dvar :
        The same model specification as used in lmfit_1ode.

    sigma :
        Multiplier for the band.
        sigma = 2 is the usual approximate 95% rule.

    rel_step :
        Relative finite-difference step for parameter sensitivities.

    Returns
    -------
    Dictionary with keys:

        "se_fit"
        "lower"
        "upper"
        "data_lower"
        "data_upper"
        "data_band"
        "jacobian"

    Notes
    -----
    This is a pointwise approximate confidence band for the fitted mean model.
    It is not a full prediction interval for future measurements.
    """
    data = np.array(data, dtype=float)

    covar = fit["covar"]

    if covar is None:
        raise ValueError(
            "Covariance matrix is None. lmfit could not estimate parameter covariance."
        )

    params0 = fit["params"]

    # Use only parameters that were actually varied in lmfit.
    par_symbols = fit["varying_params"]

    if len(par_symbols) == 0:
        raise ValueError("No varying parameters found. Confidence band cannot be computed.")

    covar = np.array(covar, dtype=float)

    if covar.shape[0] != len(par_symbols):
        raise ValueError(
            "Covariance matrix size does not match the number of varying parameters."
        )

    y0 = np.array(fit["best_fit"], dtype=float).flatten()
    m = len(y0)
    p = len(par_symbols)

    J = np.zeros((m, p), dtype=float)

    for j, par in enumerate(par_symbols):
        val = float(params0[par])

        h = rel_step * max(abs(val), 1.0)

        params_plus = params0.copy()
        params_minus = params0.copy()

        params_plus[par] = val + h
        params_minus[par] = val - h

        y_plus = ode_best_fit_at_params(
            model,
            dvars,
            ivar,
            ics,
            n,
            data,
            fit_dvar,
            params_plus
        )

        y_minus = ode_best_fit_at_params(
            model,
            dvars,
            ivar,
            ics,
            n,
            data,
            fit_dvar,
            params_minus
        )

        J[:, j] = (y_plus - y_minus) / (2*h)

    # Pointwise variance:
    # Var(y_i) = J_i C J_i^T
    var_y = np.sum((J @ covar) * J, axis=1)

    # Numerical safety
    var_y = np.maximum(var_y, 0)

    se_fit = np.sqrt(var_y)

    lower = y0 - sigma * se_fit
    upper = y0 + sigma * se_fit

    return {
        "se_fit": se_fit,
        "lower": lower,
        "upper": upper,
        "data_lower": np.column_stack((data[:, 0], lower)),
        "data_upper": np.column_stack((data[:, 0], upper)),
        "data_band": np.column_stack((data[:, 0], lower, upper)),
        "jacobian": J
    }


# ============================================================
# Approximate prediction band for ODE fit
# ============================================================

def ode_prediction_band(
    fit,
    model,
    dvars,
    ivar,
    ics,
    n,
    data,
    fit_dvar,
    sigma=2,
    rel_step=1e-6
):
    """
    Approximate pointwise prediction band for future measured data.

    This adds residual scatter to the fitted-curve uncertainty:

        se_pred^2 = se_fit^2 + residual_standard_error^2

    This is still an approximation.
    """
    conf = ode_confidence_band(
        fit,
        model,
        dvars,
        ivar,
        ics,
        n,
        data,
        fit_dvar,
        sigma=1,
        rel_step=rel_step
    )

    data = np.array(data, dtype=float)

    y0 = np.array(fit["best_fit"], dtype=float).flatten()
    se_fit = conf["se_fit"]
    s_res = fit["residual_standard_error"]

    se_pred = np.sqrt(se_fit**2 + s_res**2)

    lower = y0 - sigma * se_pred
    upper = y0 + sigma * se_pred

    return {
        "se_pred": se_pred,
        "lower": lower,
        "upper": upper,
        "data_lower": np.column_stack((data[:, 0], lower)),
        "data_upper": np.column_stack((data[:, 0], upper)),
        "data_band": np.column_stack((data[:, 0], lower, upper)),
        "confidence_band": conf
    }


# ============================================================
# Sage plotting helper for bands
# ============================================================

def sage_band_plot(
    band,
    color='gray',
    fillcolor='gray',
    fillalpha=0.2,
    legend_label=None
):
    """
    Create a Sage plot of a confidence or prediction band.

    Input
    -----
    band :
        Dictionary returned by ode_confidence_band or ode_prediction_band.

    Returns
    -------
    Sage graphics object.
    """
    data_lower = band["data_lower"]
    data_upper = band["data_upper"]

    G_lower = spline(list(map(tuple, data_lower)))
    G_upper = spline(list(map(tuple, data_upper)))

    xmin = float(data_lower[0, 0])
    xmax = float(data_lower[-1, 0])

    G_band = plot(
        [G_lower, G_upper],
        fill={1: [0]},
        xmin=xmin,
        xmax=xmax,
        color=color,
        fillcolor=fillcolor,
        fillalpha=fillalpha
    )

    if legend_label is not None:
        # Dummy invisible-looking line for legend
        x0 = xmin
        x1 = xmin + 0.001*(xmax - xmin)
        y0 = float(np.min(data_lower[:, 1])) - 10.0

        G_legend = line(
            [(x0, y0), (x1, y0)],
            color=color,
            legend_label=legend_label
        )

        return G_band + G_legend

    return G_band
