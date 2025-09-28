import psutil
from fabric import Application, Fabricator
from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.image import Image
from fabric.widgets.eventbox import EventBox
from fabric.widgets.datetime import DateTime
from fabric.widgets.centerbox import CenterBox
from fabric.system_tray.widgets import SystemTray
from fabric.widgets.circularprogressbar import CircularProgressBar
from fabric.widgets.wayland import WaylandWindow as Window
from fabric.hyprland.widgets import (
    HyprlandLanguage,
    HyprlandActiveWindow,
    HyprlandWorkspaces,
    WorkspaceButton,
)
from fabric.utils import FormattedString, get_relative_path, bulk_replace
from gi.repository import Gtk, GtkLayerShell  # type: ignore

AUDIO_WIDGET = True

if AUDIO_WIDGET is True:
    try:
        from fabric.audio.service import Audio
    except Exception as e:
        AUDIO_WIDGET = False
        print(e)


class PopupWindow(Window):
    def __init__(
        self,
        parent: Window,
        pointing_to: Gtk.Widget | None = None,
        margin: tuple[int, ...] | str = "0px 0px 0px 0px",
        **kwargs,
    ):
        super().__init__(**kwargs)
        self.exclusivity = "none"

        self._parent = parent
        self._pointing_widget = pointing_to
        self._base_margin = self.extract_margin(margin)
        self.margin = self._base_margin.values()

        self.connect("notify::visible", self.do_update_handlers)

    def get_coords_for_widget(self, widget: Gtk.Widget) -> tuple[int, int]:
        if not ((toplevel := widget.get_toplevel()) and toplevel.is_toplevel()):  # type: ignore
            return 0, 0
        allocation = widget.get_allocation()
        x, y = widget.translate_coordinates(toplevel, allocation.x, allocation.y) or (
            0,
            0,
        )
        return round(x / 2), round(y / 2)

    def set_pointing_to(self, widget: Gtk.Widget | None):
        if self._pointing_widget:
            try:
                self._pointing_widget.disconnect_by_func(self.do_handle_size_allocate)
            except Exception:
                pass
        self._pointing_widget = widget
        return self.do_update_handlers()

    def do_update_handlers(self, *_):
        if not self._pointing_widget:
            return

        if not self.get_visible():
            try:
                self._pointing_widget.disconnect_by_func(self.do_handle_size_allocate)
                self.disconnect_by_func(self.do_handle_size_allocate)
            except Exception:
                pass
            return

        self._pointing_widget.connect("size-allocate", self.do_handle_size_allocate)
        self.connect("size-allocate", self.do_handle_size_allocate)

        return self.do_handle_size_allocate()

    def do_handle_size_allocate(self, *_):
        return self.do_reposition(self.do_calculate_edges())

    def do_calculate_edges(self):
        move_axe = "x"
        parent_anchor = self._parent.anchor

        if len(parent_anchor) != 3:
            return move_axe

        if (
            GtkLayerShell.Edge.LEFT in parent_anchor
            and GtkLayerShell.Edge.RIGHT in parent_anchor
        ):
            # horizontal -> move on x-axies
            move_axe = "x"
            if GtkLayerShell.Edge.TOP in parent_anchor:
                self.anchor = "left top"
            else:
                self.anchor = "left bottom"
        elif (
            Gtk.GtkLayerShell.Edge.TOP in parent_anchor
            and GtkLayerShell.Edge.BOTTOM in parent_anchor
        ):
            # vertical -> move on y-axies
            move_axe = "y"
            if GtkLayerShell.Edge.RIGHT in parent_anchor:
                self.anchor = "top right"
            else:
                self.anchor = "top left"

        return move_axe

    def do_reposition(self, move_axe: str):
        parent_margin = self._parent.margin
        parent_x_margin, parent_y_margin = parent_margin[0], parent_margin[3]

        height = self.get_allocated_height()
        width = self.get_allocated_width()

        if self._pointing_widget:
            coords = self.get_coords_for_widget(self._pointing_widget)
            coords_centered = (
                round(coords[0] + self._pointing_widget.get_allocated_width() / 2),
                round(coords[1] + self._pointing_widget.get_allocated_height() / 2),
            )
        else:
            coords_centered = (
                round(self._parent.get_allocated_width() / 2),
                round(self._parent.get_allocated_height() / 2),
            )

        self.margin = tuple(
            a + b
            for a, b in zip(
                (
                    (
                        0,
                        0,
                        0,
                        round((parent_x_margin + coords_centered[0]) - (width / 2)),
                    )
                    if move_axe == "x"
                    else (
                        round((parent_y_margin + coords_centered[1]) - (height / 2)),
                        0,
                        0,
                        0,
                    )
                ),
                self._base_margin.values(),
            )
        )


class AudioWidget(Box):
    def __init__(self, **kwargs):
        super().__init__(
            # type_hint="normal",
            # visible=False,
            # all_visible=True,
            children=[Button(label="test label")],
            **kwargs,
        )


class VolumeWidget(Box):
    def __init__(self, **kwargs):
        self.progress_bar = CircularProgressBar(
            name="volume-progress-bar",
            pie=True,
            child=Image(icon_name="audio-speakers-symbolic", icon_size=12),
            size=24,
        )

        self.audio = Audio(notify_speaker=self.on_speaker_changed)

        super().__init__(
            children=EventBox(
                events="scroll", child=self.progress_bar, on_scroll_event=self.on_scroll
            ),
            **kwargs,
        )

    def on_scroll(self, _, event):
        match event.direction:
            case 0:
                self.audio.speaker.volume += 8
            case 1:
                self.audio.speaker.volume -= 8
        return

    def on_speaker_changed(self):
        if not self.audio.speaker:
            return

        self.progress_bar.value = self.audio.speaker.volume / 100
        return self.audio.speaker.bind(
            "volume", "value", self.progress_bar, lambda _, v: v / 100
        )


class StatusBar(Window):
    def __init__(
        self,
    ):
        super().__init__(
            name="bar",
            layer="top",
            anchor="left top right",
            margin="10px 10px -2px 10px",
            exclusivity="auto",
            visible=False,
        )

        volume_widget = VolumeWidget() if AUDIO_WIDGET else None
        audio_popup = (
            PopupWindow(
                parent=self,
                name="audio-popup",
                child=AudioWidget(),
            )
            if AUDIO_WIDGET
            else None
        )

        self.system_status = Box(
            name="system-status",
            spacing=4,
            orientation="h",
            children=[
                # a progress bar (ram) has a child of a progress bar (cpu) that which has a child (the icon)
                CircularProgressBar(
                    name="ram-progress-bar",
                    pie=True,
                    child=CircularProgressBar(
                        name="cpu-progress-bar",
                        pie=True,
                        child=Image(icon_name="cpu-symbolic", icon_size=12),
                        size=24,
                    ).build(
                        lambda progres: Fabricator(
                            interval=1000,
                            poll_from=lambda f: psutil.cpu_percent() / 100,
                            on_changed=lambda _, value: progres.set_value(value),
                        )
                    ),
                    size=24,
                ).build(
                    lambda progres: Fabricator(
                        interval=1000,
                        poll_from=lambda f: psutil.virtual_memory().percent / 100,
                        on_changed=lambda _, value: progres.set_value(value),
                    )
                )
            ]
            # create a volume widget if enabled
            + (
                [
                    Button(
                        child=volume_widget,
                        on_clicked=lambda *_: audio_popup.show()
                        if not audio_popup.is_visible()
                        else audio_popup.hide(),
                    )
                ]
                if AUDIO_WIDGET
                else []
            ),
        )

        audio_popup.set_pointing_to(volume_widget)

        self.children = CenterBox(
            name="bar-inner",
            start_children=Box(
                name="start-container",
                children=HyprlandWorkspaces(
                    name="workspaces",
                    spacing=4,
                    buttons_factory=lambda ws_id: WorkspaceButton(id=ws_id, label=None),
                ),
            ),
            center_children=Box(
                name="center-container",
                children=HyprlandActiveWindow(name="hyprland-window"),
            ),
            end_children=Box(
                name="end-container",
                spacing=4,
                orientation="h",
                children=[
                    self.system_status,
                    SystemTray(name="system-tray", spacing=4),
                    DateTime(name="date-time"),
                    HyprlandLanguage(
                        name="hyprland-window",
                        formatter=FormattedString(
                            "{replace_lang(language)}",
                            replace_lang=lambda lang: bulk_replace(
                                lang,
                                (r".*Eng.*", r".*Ar.*"),
                                ("ENG", "ARA"),
                                regex=True,
                            ),
                        ),
                    ),
                ],
            ),
        )

        return self.show_all()


def main():
    bar = StatusBar()
    app = Application("bar", bar)
    app.set_stylesheet_from_file(get_relative_path("style.css"))

    app.run()
