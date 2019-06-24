import salt.exceptions
import subprocess
import os


def _sh(cmd, env=None):
    if not env:
        env = {}
    proc_env = os.environ.copy()
    proc_env.update(env)
    p = subprocess.Popen(cmd, env=proc_env, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = p.communicate()
    if p.returncode != 0:
        return stdout.encode('utf-8'), stderr.encode('utf-8'), False
    else:
        return stdout.encode('utf-8'), stderr.encode('utf-8'), True


def install_pyenv(name, prefix, makedirs=True):
    res = {
        'name': name,
        'changes': {},
        'result': False,
        'comment': '',
    }

    if not os.path.exists(prefix):
        if makedirs:
            os.makedirs(prefix, exist_ok=True)
        else:
            res['comment'] = 'prefix {} does not exist'.format(prefix)
            return res

    if not os.path.isdir(prefix):
        res['comment'] = 'prefix {} is not a directory'.format(prefix)
        return res

    install_dir = os.path.join(prefix, '.pyenv')

    already_installed = any([
        os.path.exists(install_dir),
    ])

    if already_installed:
        res['result'] = True
        res['comment'] = 'System already in the correct state'
        return res

    stdout, stderr, success = _sh(['git', 'clone', 'https://github.com/pyenv/pyenv.git', install_dir])
    if not success:
        res['comment'] = 'stdout: {}\nstderr: {}'.format(stdout, stderr)
        return res


    res['result'] = True
    res['comment'] = 'Pyenv was installed at {}'.format(install_dir)
    res['changes'] = {
        'old': 'missing',
        'new': 'installed',
    }

    return res


def installed(name, pyenv):
    res = {
        'name': name,
        'changes': {},
        'result': False,
        'comment': '',
    }

    if any([
            not os.path.isdir(pyenv), 
            not os.path.isfile(os.path.join(pyenv, 'bin', 'pyenv'))
    ]):
        res['comment'] = 'pyenv does not exist at {}'.format(pyenv)
        return res
    if os.path.isdir(os.path.join(pyenv, 'versions')):
        installed_versions = os.listdir(os.path.join(pyenv, 'versions'))
    else:
        installed_versions = []

    install_name = name
    if install_name.startswith('python-'):
        install_name = install_name[7:]

    if install_name in installed_versions:
        res['result'] = True
        res['comment'] = 'Python version {} already installed'.format(name)
        return res

    stdout, stderr, success = _sh([os.path.join(pyenv, 'bin', 'pyenv'), 'install', install_name], env={'PYENV_ROOT': pyenv})
    if not success:
        res['comment'] = 'stdout: {}\nstderr: {}'.format(stdout, stderr)
        return res

    res['result'] = True
    res['comment'] = 'Python version {} installed'.format(install_name)
    res['changes'] = {
        'old': '',
        'new': install_name,
    }

    return res


def ensure_venv(name, pip_bin):
    res = {
        'name': name,
        'changes': {},
        'result': False,
        'comment': '',
    }

    if not os.path.isfile(pip_bin):
        res['comment'] = 'No pip binary at {}'.format(pip_bin)
        return res

    _, _, pkg_exists = _sh([pip_bin, 'show', 'virtualenv'])
    if pkg_exists:
        res['result'] = True
        res['comment'] = 'Virtualenv already installed'
        return res

    stdout, stderr, success = _sh([pip_bin, 'install', 'virtualenv'])
    if not success:
        res['comment'] = 'stdout: {}\nstderr: {}'.format(stdout, stderr)
        return res

    res['result'] = True
    res['comment'] = 'Virtualenv installed'
    res['changes'] = {
        'old': 'Not installed',
        'new': 'Installed',
    }

    return res
