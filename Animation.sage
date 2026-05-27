print("Downloading the package Animation...")

from PIL import Image
import os
import tempfile
import io
from IPython.display import HTML, display
import base64
from datetime import datetime
import resource

def load_cloud(url, filename):
    """
    Načíta Sage/Python súbor z cloudovej URL adresy.

    Podporované:
        - Dropbox
        - OneDrive / SharePoint links of the form .../:u:/g/personal/.../SHARE_ID?e=...
        - OneDrive Personal links of the form onedrive.live.com/embed?...
        - other direct URLs

    Parameters:
        url (str): cloud URL
        filename (str): názov súboru, napr. 'model_kyvadla.sage'
    """

    # Dropbox
    if "dropbox.com" in url:
        if "dl=0" in url:
            url = url.replace("dl=0", "raw=1")
        elif "dl=1" in url:
            url = url.replace("dl=1", "raw=1")
        elif "raw=1" not in url:
            sep = "&" if "?" in url else "?"
            url = url + sep + "raw=1"

    # OneDrive / SharePoint, e.g.
    # https://upjs-my.sharepoint.com/:u:/g/personal/jozef_hanc_upjs_sk/SHARE_ID?e=...
    elif "sharepoint.com" in url and "/:u:/g/personal/" in url:
        base = url.split("/:u:/g/")[0]
        path = url.split("/:u:/g/")[1].split("?")[0]

        parts = path.split("/")
        personal_path = "/".join(parts[:2])   # personal/jozef_hanc_upjs_sk
        share_id = parts[-1]

        url = base + "/" + personal_path + "/_layouts/15/download.aspx?share=" + share_id

    # OneDrive Personal
    elif "onedrive.live.com" in url:
        if "embed?" in url:
            url = url.replace("embed?", "download?")
        elif "redir?" in url:
            url = url.replace("redir?", "download?")
        elif "download?" not in url:
            sep = "&" if "?" in url else "?"
            url = url + sep + "download=1"

    # Sage must visibly see .sage or .py at the end of the URL
    url = url + "#" + filename

    load(url)

def generate_gif(frame_generator, num_frames, duration=100, 
                 show_progress=True, progress_step=10, loop=0, save=False, filename=None):
    """
    Generates an animated GIF from a function that generates individual plots.
    
    Parameters:
    ----------
    frame_generator : function
        Function that takes index i (from 0 to num_frames-1) and returns a SageMath Graphics object
    num_frames : int
        Number of frames in the animation
    duration : int
        Time between frames in milliseconds (default 100ms)
    show_progress : bool
        Whether to display progress messages (default True)
    progress_step : int
        Display progress message every N frames (default 10)
    loop : int
        Number of repetitions (0 = infinite loop, 1 = play once, etc., default 0)
    save : bool
        Whether to save the GIF to a file (default False)
    filename : str or None
        Filename to save the GIF (default None generates a timestamped filename)
    
    Returns:
    -------
    BytesIO
        Buffer containing the GIF data
    
    Example usage:
    -------------
    def my_frame(i):
        phase = 2 * pi * i / 30
        y(t) = sin(t + phase)
        return plot(y, (t, 0, 4*pi), color='blue')
    
    gif_buffer = generate_gif(my_frame, num_frames=30, duration=50)
    """
    
    frames = []
    
    if show_progress:
        print("Generated frames: ", end="")
    
    for i in range(num_frames):
        # Get plot from generator
        p = frame_generator(i)
        
        # Save to temporary file and load immediately
        with tempfile.NamedTemporaryFile(suffix='.png', delete=False) as tmp:
            tmp_name = tmp.name
        
        p.save(tmp_name, figsize=[10, 6])
        img = Image.open(tmp_name)
        frames.append(img.copy())
        img.close()
        os.remove(tmp_name)
        
        # Progress message
        if show_progress and (i + 1) % progress_step == 0:
            print(f"{i+1}/{num_frames}", end=' ... ')
    
    
    # Create GIF in memory
    gif_buf = io.BytesIO()
    frames[0].save(
        gif_buf,
        format='GIF',
        save_all=True,
        append_images=frames[1:],
        duration=duration,
        loop=loop
    )
    gif_buf.seek(0)
    
    if show_progress:
        print("GIF is finished.")
        
    if save:
        if filename is None:
            filename = f"animation_{datetime.now().strftime('%Y%m%d_%H%M%S')}.gif"
        gif_buf.seek(0)
        with open(filename, 'wb') as f:
            f.write(gif_buf.read())
        if show_progress:
            print(f"Saved to {filename}")
        gif_buf.seek(0)
    
    return gif_buf


def display_gif(gif_buffer, style='width:100%;'):
    """
    Displays an animated GIF in Jupyter notebook.
    
    Parameters:
    ----------
    gif_buffer : BytesIO
        Buffer containing GIF data (from generate_gif function)
    style : str
        CSS style string for the displayed image (default 'width:100%;')
    
    Example usage:
    -------------
    gif_buf = generate_gif(my_frame, num_frames=30)
    display_gif(gif_buf, style='max-width:800px; border:2px solid black;')
    """
    
    gif_buffer.seek(0)  # Make sure we're at the beginning
    gif_data = base64.b64encode(gif_buffer.read()).decode()
    html = f'<img src="data:image/gif;base64,{gif_data}" style="{style}" />'
    display(HTML(html))


def animation_gif(frame_generator, num_frames, duration=100, 
                  show_progress=True, progress_step=10, loop=0, style='width:100%;',
                  save=False, filename=None):
    """
    Creates and displays an animated GIF (convenience function).
    
    This is a wrapper that combines generate_gif() and display_gif().
    
    Parameters:
    ----------
    frame_generator : function
        Function that takes index i (from 0 to num_frames-1) and returns a SageMath Graphics object
    num_frames : int
        Number of frames in the animation
    duration : int
        Time between frames in milliseconds (default 100ms)
    show_progress : bool
        Whether to display progress messages (default True)
    progress_step : int
        Display progress message every N frames (default 10)
    loop : int
        Number of repetitions (0 = infinite loop, 1 = play once, etc., default 0)
    style : str
        CSS style string for the displayed image (default 'width:100%;')
    save : bool
        Whether to save the GIF to a file (default False)
    filename : str or None
        Filename to save the GIF (default None generates a timestamped filename)
    
    Example usage:
    -------------
    def my_frame(i):
        phase = 2 * pi * i / 30
        y(t) = sin(t + phase)
        return plot(y, (t, 0, 4*pi), color='blue')
    
    animation_gif(my_frame, num_frames=30, duration=50)
    """
    
    gif_buf = generate_gif(frame_generator, num_frames, duration, 
                          show_progress, progress_step, loop, save, filename)
    display_gif(gif_buf, style)
    
    
import resource

def cpu_time_info():
    """
    Get detailed CPU time information and print summary.
    
    Returns:
    -------
    dict
        Dictionary with CPU time details:
        - 'limit': CPU time limit in seconds (None if unlimited)
        - 'used': CPU time used so far in seconds
        - 'remaining': Remaining CPU time in seconds (None if unlimited)
        - 'percent': Percentage of limit used
        - 'user_time': User CPU time
        - 'system_time': System CPU time
    """
    # Get limits
    cpu_limit = resource.getrlimit(resource.RLIMIT_CPU)[0]
    
    # Get usage
    usage = resource.getrusage(resource.RUSAGE_SELF)
    user_time = usage.ru_utime
    system_time = usage.ru_stime
    cpu_used = user_time + system_time
    
    # Calculate remaining
    if cpu_limit == resource.RLIM_INFINITY or cpu_limit == -1:
        remaining = None
        percent = 0
        limit_display = None
    else:
        remaining = cpu_limit - cpu_used
        percent = (cpu_used / cpu_limit) * 100
        limit_display = cpu_limit
    
    # Create result dictionary
    result = {
        'limit': limit_display,
        'used': cpu_used,
        'remaining': remaining,
        'percent': percent,
        'user_time': user_time,
        'system_time': system_time
    }
    
    return result

print("The animation package was successfully loaded!!!")

