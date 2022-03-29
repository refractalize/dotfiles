from kitty import keys
from kitty.fast_data_types import encode_key_for_tty
from kitty.key_encoding import parse_shortcut, KeyEvent, encode_key_event
import re
from kitty.conf.utils import python_string

def main():
    pass

def is_nvim_process(p):
    return re.search('n?vim', p['cmdline'][0], re.I)

def encode_key_mapping(key_mapping):
    mods, key = parse_shortcut(key_mapping)
    event = KeyEvent(
        mods=mods,
        key=key,
        shift=bool(mods & 1),
        alt=bool(mods & 2),
        ctrl=bool(mods & 4),
        super=bool(mods & 8),
        hyper=bool(mods & 16),
        meta=bool(mods & 32),
    ).as_window_system_event()

    print(
        event.key,
        event.shifted_key,
        event.alternate_key,
        event.mods,
        event.action
    )

    return encode_key_for_tty(
        event.key, event.shifted_key, event.alternate_key, event.mods, event.action
    )

def handle_result(args, result, target_window_id, boss):
    window = boss.window_id_map.get(target_window_id)

    if window is None:
        return

    has_nvim_foreground_process = next(filter(is_nvim_process, window.child.foreground_processes), None)

    if has_nvim_foreground_process and not window.text_for_selection():
        text = encode_key_mapping(args[2])
        window.write_to_child(text)
    elif args[1] == 'copy':
        boss.active_window.copy_to_clipboard()
    elif args[1] == 'paste':
        boss.paste_from_clipboard()

handle_result.no_ui = True
