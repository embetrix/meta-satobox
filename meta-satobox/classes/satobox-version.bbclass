def distro_version(d):
    import subprocess
    project_path = d.getVar('SATOBOX_BASE', True)
    cmd = "git describe --tags --always --dirty"
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True, cwd=project_path)
    out, err =  proc.communicate()
    return out.decode("utf-8").rstrip()

SATOBOX_DISTRO_VERSION := "${@distro_version(d)}"
