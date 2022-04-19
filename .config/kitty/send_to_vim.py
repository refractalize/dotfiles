from kitty.key_encoding import (
    parse_shortcut,
    KeyEvent,
    SHIFT,
    ALT,
    CTRL,
    SUPER,
    HYPER,
    META
)
import re

def main():
    pass

def is_nvim_process(p):
    return re.search('n?vim', p['cmdline'][0], re.I)

def encode_key_mapping(key_mapping, window):
    mods, key = parse_shortcut(key_mapping)
    event = KeyEvent(
        mods=mods,
        key=key,
        shift=bool(mods & SHIFT),
        alt=bool(mods & ALT),
        ctrl=bool(mods & CTRL),
        super=bool(mods & SUPER),
        hyper=bool(mods & HYPER),
        meta=bool(mods & META),
    ).as_window_system_event()

    return window.encoded_key(event)

def handle_result(args, result, target_window_id, boss):
    window = boss.window_id_map.get(target_window_id)

    if window is None:
        return

    has_nvim_foreground_process = next(filter(is_nvim_process, window.child.foreground_processes), None)

    if has_nvim_foreground_process and not window.text_for_selection():
        text = encode_key_mapping(args[2], window)
        window.write_to_child(text)
    elif args[1] == 'copy':
        boss.active_window.copy_to_clipboard()
    elif args[1] == 'paste':
        boss.paste_from_clipboard()

handle_result.no_ui = True
