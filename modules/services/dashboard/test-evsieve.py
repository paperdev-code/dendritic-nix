import os
import pwd
import select
import subprocess
import time

from evdev import AbsInfo, InputDevice, UInput, ecodes, list_devices

SERVICE = "dashboard-keybinds.service"
GAMEPAD_PATH = "/dev/input/by-id/test-gamepad"
KEYBOARD_NAME = "dashboard-keybinds"


def service_logs():
    subprocess.run(
        ["systemctl", "status", SERVICE, "--no-pager"], check=False
    )
    subprocess.run(
        ["journalctl", "-u", SERVICE, "-b", "--no-pager"], check=False
    )


def create_gamepad():
    capabilities = {
        ecodes.EV_KEY: [
            ecodes.BTN_SOUTH,
            ecodes.BTN_EAST,
            ecodes.BTN_NORTH,
            ecodes.BTN_WEST,
            ecodes.BTN_TL,
            ecodes.BTN_TR,
            ecodes.BTN_START,
            ecodes.BTN_SELECT,
        ],
        ecodes.EV_ABS: [
            (ecodes.ABS_HAT0X, AbsInfo(0, -1, 1, 0, 0, 0)),
            (ecodes.ABS_HAT0Y, AbsInfo(0, -1, 1, 0, 0, 0)),
        ],
    }

    gamepad = UInput(capabilities, name="dashboard-test-gamepad")
    subprocess.run(["udevadm", "settle"], check=True)

    os.makedirs("/dev/input/by-id", exist_ok=True)
    if os.path.lexists(GAMEPAD_PATH):
        os.unlink(GAMEPAD_PATH)
    os.symlink(gamepad.device.path, GAMEPAD_PATH)

    target = os.path.realpath(GAMEPAD_PATH)
    gid = pwd.getpwnam("dashboard").pw_gid
    os.chmod(target, 0o660)
    os.chown(target, 0, gid)

    return gamepad


def find_output(timeout=5):
    deadline = time.time() + timeout
    while time.time() < deadline:
        for path in list_devices():
            try:
                device = InputDevice(path)
            except OSError:
                continue

            if device.name == KEYBOARD_NAME:
                return device

            device.close()

        time.sleep(0.1)

    raise AssertionError(f"could not find virtual keyboard {KEYBOARD_NAME!r}")


def read_until(device, wanted, timeout=3):
    wanted = set(wanted)
    seen = set()
    deadline = time.time() + timeout

    while time.time() < deadline:
        remaining = max(0.0, deadline - time.time())
        ready, _, _ = select.select([device.fd], [], [], remaining)
        if not ready:
            break

        for event in device.read():
            if event.type != ecodes.EV_KEY:
                continue

            key = (event.code, event.value)
            if key in wanted:
                seen.add(key)
                if seen == wanted:
                    return

    raise AssertionError(f"timed out waiting for {wanted}, saw {seen}")


def press_button(gamepad, output, button, expected_keys):
    gamepad.write(ecodes.EV_KEY, button, 1)
    gamepad.syn()
    read_until(output, {(key, 1) for key in expected_keys})

    gamepad.write(ecodes.EV_KEY, button, 0)
    gamepad.syn()
    read_until(output, {(key, 0) for key in expected_keys})


def press_hat(gamepad, output, axis, value, expected_keys):
    gamepad.write(ecodes.EV_ABS, axis, value)
    gamepad.syn()
    read_until(output, {(key, 1) for key in expected_keys})

    gamepad.write(ecodes.EV_ABS, axis, 0)
    gamepad.syn()
    read_until(output, {(key, 0) for key in expected_keys})


def main():
    gamepad = create_gamepad()
    out = None

    try:
        subprocess.run(["systemctl", "reset-failed", SERVICE], check=False)
        subprocess.run(["systemctl", "start", SERVICE], check=True)

        out = find_output()
        subprocess.run(
            ["pgrep", "-u", "dashboard", "-x", "evsieve"], check=True
        )

        for button, keys in [
            (ecodes.BTN_SOUTH, [ecodes.KEY_ENTER]),
            (ecodes.BTN_EAST, [ecodes.KEY_ESC]),
            (ecodes.BTN_NORTH, [ecodes.KEY_TAB]),
            (ecodes.BTN_WEST, [ecodes.KEY_LEFTSHIFT, ecodes.KEY_TAB]),
        ]:
            press_button(gamepad, out, button, keys)

        for axis, value, keys in [
            (ecodes.ABS_HAT0Y, -1, [ecodes.KEY_LEFTALT, ecodes.KEY_K]),
            (ecodes.ABS_HAT0Y, 1, [ecodes.KEY_LEFTALT, ecodes.KEY_J]),
            (ecodes.ABS_HAT0X, -1, [ecodes.KEY_LEFTALT, ecodes.KEY_H]),
            (ecodes.ABS_HAT0X, 1, [ecodes.KEY_LEFTALT, ecodes.KEY_L]),
        ]:
            press_hat(gamepad, out, axis, value, keys)

        press_button(
            gamepad,
            out,
            ecodes.BTN_TL,
            [ecodes.KEY_LEFTALT, ecodes.KEY_1],
        )
        press_button(
            gamepad,
            out,
            ecodes.BTN_TR,
            [ecodes.KEY_LEFTALT, ecodes.KEY_2],
        )

        print("evsieve mapping test passed")
    except Exception:
        service_logs()
        raise
    finally:
        if out is not None:
            out.close()
        gamepad.close()


if __name__ == "__main__":
    main()
