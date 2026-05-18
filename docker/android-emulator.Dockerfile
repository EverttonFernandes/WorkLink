FROM budtmo/docker-android:emulator_11.0

USER root

RUN python3 - <<'PY'
from pathlib import Path

path = Path("/home/androidusr/docker-android/cli/src/device/emulator.py")
source = path.read_text()
old = """    def change_permission(self) -> None:
        kvm_path = "/dev/kvm"
        if os.path.exists(kvm_path):
            cmds = (f"sudo chown 1300:1301 {kvm_path}",
                    "sudo sed -i '1d' /etc/passwd")
            for c in cmds:
                subprocess.check_call(c, shell=True)
            self.logger.info("KVM permission is granted!")
        else:
            raise RuntimeError("/dev/kvm cannot be found!")
"""
new = """    def change_permission(self) -> None:
        kvm_path = "/dev/kvm"
        if not os.path.exists(kvm_path):
            raise RuntimeError("/dev/kvm cannot be found!")

        cmds = (f"sudo chown 1300:1301 {kvm_path}",
                "sudo sed -i '1d' /etc/passwd")
        for c in cmds:
            result = subprocess.call(c, shell=True)
            if result != 0:
                self.logger.warning(
                    f"Command '{c}' failed with exit code {result}; continuing with current permissions")

        self.logger.info("KVM permission step finished!")
"""
if old not in source:
    raise SystemExit("Patch target not found in emulator.py")
path.write_text(source.replace(old, new))
PY
