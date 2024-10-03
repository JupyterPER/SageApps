import pandas as pd

def read_google_table(url):
    """
    Read data from a Google Sheets URL and return it as a pandas DataFrame.

    Parameters:
    - url (str): The URL of the Google Sheets document.
                 The URL should be in one of the following formats:
                 - 'https://docs.google.com/spreadsheets/d/{id}/edit#gid={gid}' (copied from address bar, document must be in a publicly accessible folder)
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

def plot_errorbars(x_vals, y_vals, color_mean='blue', size_mean=30, marker_mean='o', legend_label_mean=None, color_std='red', thickness_std=1, rel_cap_width_std=0.01):
    """
    Create a plot with error bars showing mean and standard deviation.

    Parameters:
    x_vals (list): List of x-values
    y_vals (list): List of y-values
    color_mean (str): Color of the mean points (default: 'blue')
    size_mean (int): Size of the mean points (default: 30)
    marker_mean (str): Marker style for mean points (default: 'o')
    legen_label_mean (str): Legend label for mean points (default: None)
    color_std (str): Color of the error bars (default: 'red')
    thickness_std (int): Thickness of the error bars (default: 1)
    rel_cap_width_std (float): Relative width of error bar caps (default: 0.01)

    Returns:
    sage.plot.plot.Graphics: A Sage graphics object containing the plot
    """

    # Create a dictionary with x and y values
    data = {
        'x': x_vals,
        'y': y_vals
    }
    
    # Convert the dictionary to a pandas DataFrame
    df = pd.DataFrame(data)
    
    # Group by x-values and calculate mean and standard deviation
    stats = df.groupby('x')['y'].agg(['mean', 'std']).reset_index()
    x_st = stats['x']
    mean = stats['mean']
    std = stats['std']

    # Create a plot for mean values
    p = list_plot(list(zip(x_st, mean)), color=color_mean, marker=marker_mean, 
                  size=size_mean, legend_label=legend_label_mean)

    # Add error bars
    cap_width = rel_cap_width_std * max(x_st)  # Width of end caps, can be adjusted as needed
    for i in range(len(x_st)):
        lower = mean[i] - std[i]
        upper = mean[i] + std[i]
        
        # Vertical line for error bar
        p += line([(x_st[i], lower), (x_st[i], upper)], color=color_std, thickness=thickness_std)
        
        # Small horizontal lines at the ends (caps)
        p += line([(x_st[i] - cap_width, lower), (x_st[i] + cap_width, lower)], 
                  color=color_std, thickness=thickness_std)
        p += line([(x_st[i] - cap_width, upper), (x_st[i] + cap_width, upper)], 
                  color=color_std, thickness=thickness_std)

    return p
