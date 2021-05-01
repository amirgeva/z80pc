import subprocess as sp


def run(cmd: str, work_dir: str, output_widget) -> bool:
    try:
        res = sp.run(cmd.split(), stdout=sp.PIPE, stderr=sp.STDOUT, cwd=work_dir, check=False)
        if res.returncode == 0:
            text = res.stdout.decode('utf-8')
            output_widget.setText(text)
            return True
    except sp.CalledProcessError:
        output_widget.setText('Failed')
    return False
