import os
import tempfile
import shutil
import base64
from PIL import Image
from sage.misc.html import html
from IPython.display import display, HTML

try:
    from tqdm.auto import tqdm
except Exception:
    tqdm = None


# ---------------------------------------------------------
# Helper
# ---------------------------------------------------------
def _as_tuple(x):
    if x is None:
        return tuple()
    if isinstance(x, tuple):
        return x
    if isinstance(x, list):
        return tuple(x)
    return (x,)


# ---------------------------------------------------------
# 1. General 2D motion frame
# ---------------------------------------------------------
def motion_frame(
    it,
    solutions,
    x_fun,
    y_fun,
    cols=(0, 2),
    fun_args=(),
    fun_kwargs=None,
    x_args=None,
    y_args=None,
    x_kwargs=None,
    y_kwargs=None,
    axis_limits=None,
    anchor=(0, 0),
    show_connector=True,
    show_start=True,
    show_end=True,
    show_trajectory=True,
    trajectory_style=":",
    trajectory_thickness=1,
    connector_thickness=2,
    connector_color="green",
    start_color="orange",
    end_color="red",
    point_size=200,
    frame=True,
    gridlines=True,
    axes_labels=(r'$x~\mathrm{[m]}$', r'$y~\mathrm{[m]}$'),
    title=None
):
    """
    General frame for planar motion.

    Parameters
    ----------
    it : int
        Index of the solution in solutions.

    solutions : list
        List/database of numerical solutions.

    x_fun, y_fun : functions
        Functions generating x and y coordinates.

        They are called as:

            x_fun(*(x_args + selected_columns), **x_kwargs)
            y_fun(*(y_args + selected_columns), **y_kwargs)

        If x_args/y_args are not given, fun_args is used for both.

    cols : tuple
        Columns from the solution used as arguments of x_fun and y_fun.

    axis_limits : tuple or None
        If given, use (xmin, xmax, ymin, ymax).
        If None, limits are estimated from the trajectory.

    anchor : tuple
        Starting point of connector line, e.g. spring support point.

    Returns
    -------
    Sage graphics object.
    """

    it = int(it)

    if fun_kwargs is None:
        fun_kwargs = {}

    if x_args is None:
        x_args = fun_args
    if y_args is None:
        y_args = fun_args

    if x_kwargs is None:
        x_kwargs = fun_kwargs
    if y_kwargs is None:
        y_kwargs = fun_kwargs

    x_args = _as_tuple(x_args)
    y_args = _as_tuple(y_args)

    sol = solutions[it]

    selected_columns = tuple(sol[:, c] for c in cols)

    x_values = x_fun(*(x_args + selected_columns), **x_kwargs)
    y_values = y_fun(*(y_args + selected_columns), **y_kwargs)

    xy_values = list(zip(x_values, y_values))

    if axis_limits is None:
        xs = [p[0] for p in xy_values] + [anchor[0]]
        ys = [p[1] for p in xy_values] + [anchor[1]]

        xmin = min(xs)
        xmax = max(xs)
        ymin = min(ys)
        ymax = max(ys)

        dx = xmax - xmin
        dy = ymax - ymin

        if dx == 0:
            dx = 1
        if dy == 0:
            dy = 1

        xmin = xmin - 0.05*dx
        xmax = xmax + 0.05*dx
        ymin = ymin - 0.05*dy
        ymax = ymax + 0.05*dy
    else:
        xmin, xmax, ymin, ymax = axis_limits

    G = plot(
        [],
        xmin=xmin, xmax=xmax,
        ymin=ymin, ymax=ymax,
        frame=frame,
        gridlines=gridlines,
        axes_labels=list(axes_labels),
        title=title
    )

    if show_trajectory:
        G += line(
            xy_values,
            xmin=xmin, xmax=xmax,
            ymin=ymin, ymax=ymax,
            linestyle=trajectory_style,
            thickness=trajectory_thickness
        )

    if show_connector:
        G += line(
            [anchor, xy_values[-1]],
            thickness=connector_thickness,
            color=connector_color
        )

    if show_start:
        G += points(
            xy_values[0],
            color=start_color,
            size=point_size,
            zorder=5
        )

    if show_end:
        G += points(
            xy_values[-1],
            color=end_color,
            size=point_size,
            zorder=10
        )

    return G


# ---------------------------------------------------------
# 2. Fully general GIF creator
# ---------------------------------------------------------
def create_gif(
    frame_function,
    frame_indices,
    *frame_args,
    output_dir="gif_output",
    gif_name="animation.gif",
    dpi=80,
    duration=100,
    keep_png_frames=False,
    loop=0,
    progress=True,
    **frame_kwargs
):
    """
    Creates a GIF from any frame function.

    The frame function is called as:

        frame_function(it, *frame_args, **frame_kwargs)

    If progress=True, a progress bar is shown in Jupyter when tqdm is available.
    """

    os.makedirs(output_dir, exist_ok=True)

    if keep_png_frames:
        frames_dir = os.path.join(output_dir, "frames")
        os.makedirs(frames_dir, exist_ok=True)
    else:
        frames_dir = tempfile.mkdtemp()

    frame_indices = list(frame_indices)

    if len(frame_indices) == 0:
        raise ValueError("No frames were created. Check frame_indices.")

    png_files = []

    iterator = enumerate(frame_indices)

    if progress and tqdm is not None:
        iterator = tqdm(
            iterator,
            total=len(frame_indices),
            desc="Creating PNG frames"
        )

    for k, it in iterator:
        filename = os.path.join(frames_dir, "frame_{:04d}.png".format(k))

        G = frame_function(it, *frame_args, **frame_kwargs)
        G.save(filename, dpi=dpi)

        png_files.append(filename)

    images = []

    image_iterator = png_files

    if progress and tqdm is not None:
        image_iterator = tqdm(
            png_files,
            total=len(png_files),
            desc="Loading frames"
        )

    for filename in image_iterator:
        with Image.open(filename) as img:
            images.append(img.convert("RGB"))

    gif_file = os.path.join(output_dir, gif_name)

    if progress:
        print("Saving GIF...")

    images[0].save(
        gif_file,
        save_all=True,
        append_images=images[1:],
        duration=duration,
        loop=loop
    )

    for img in images:
        img.close()

    if not keep_png_frames:
        shutil.rmtree(frames_dir, ignore_errors=True)

    if progress:
        print("GIF saved to:", gif_file)

    return gif_file

# ---------------------------------------------------------
# 3. Show existing GIF
# ---------------------------------------------------------
def show_gif(
    gif_file,
    max_width="100%",
    caption=None,
    show_path=False
):
    """
    Displays an existing GIF inline in Jupyter/SageMathCell using HTML.
    """

    with open(gif_file, "rb") as f:
        gif_base64 = base64.b64encode(f.read()).decode("ascii")

    caption_html = ""
    if caption is not None:
        caption_html = "<p><b>{}</b></p>".format(caption)

    path_html = ""
    if show_path:
        path_html = "<p>{}</p>".format(gif_file)

    html_code = """
    <div style="text-align:left;">
        {}
        {}
        <img src="data:image/gif;base64,{}" style="max-width:{};">
    </div>
    """.format(caption_html, path_html, gif_base64, max_width)

    display(HTML(html_code))



# ---------------------------------------------------------
# 4. Fully general create-and-show function
# ---------------------------------------------------------
def create_and_show_gif(
    frame_function,
    frame_indices,
    *frame_args,
    output_dir="gif_output",
    gif_name="animation.gif",
    dpi=80,
    duration=100,
    keep_png_frames=False,
    loop=0,
    max_width="100%",
    caption=None,
    show_path=False,
    **frame_kwargs
):
    """
    Creates a GIF from any frame function and displays it.
    """

    gif_file = create_gif(
        frame_function,
        frame_indices,
        *frame_args,
        output_dir=output_dir,
        gif_name=gif_name,
        dpi=dpi,
        duration=duration,
        keep_png_frames=keep_png_frames,
        loop=loop,
        **frame_kwargs
    )

    show_gif(
        gif_file,
        max_width=max_width,
        caption=caption,
        show_path=show_path
    )

    return gif_file