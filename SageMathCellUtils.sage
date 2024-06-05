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
