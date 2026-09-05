from kitty.tab_bar import (
    draw_title,
    as_rgb,
)

def draw_tab(
    draw_context,
    tab,
    is_last,
    max_title_length,
    index,
    extra_data,
):
    # No leading space anywhere
    if index == 1:
        label = f"{tab.title}"
    else:
        label = f"{index}: {tab.title}"

    # background styling
    if tab.is_active:
        bg = as_rgb(0x2d3442)
    else:
        bg = as_rgb(0x242a33)

    draw_context.set_bg(bg)

    draw_title(
        draw_context,
        label,
        max_title_length=max_title_length,
    )

    # separator (optional)
    if not is_last:
        draw_context.draw(" │ ")
