#!/usr/bin/env python
# This file contains information about installed virtual environments 

import os
import sys
import importlib


opencmiss_libraries = ['zinc', 'iron']


virtualenvs = []
info_file_dir = os.path.dirname(os.path.realpath(__file__))
saved_working_directory = os.getcwd()


class VirtualEnvInfo(object):

    def __init__(self, env_info):
        self._env_info = env_info
        self._libraries_present = [env_info["library"]]

    def __getitem__(self, item):
        if item == "libraries_present":
            return self._libraries_present
        return self._env_info[item]

    def __eq__(self, other_env_info):
        equal  = False
        if self["library"] in opencmiss_libraries and other_env_info["library"] in opencmiss_libraries:
            equal = self["activate"] == other_env_info["activate"]

        return equal

    def merge(self, other_env_info):
        if self["library"] == "iron":
            self._libraries_present.append(other_env_info["library"])
        elif self["library"] == "zinc":
            self._libraries_present.append(other_env_info["library"])
            self._env_info["mpi"] = other_env_info["mpi"]
            self._env_info["compiler"] = other_env_info["compiler"]
        else:
            print("Not good can't match library: " + self["library"])


def register_environment(env_info):
    """Add env_info to virtualenvs database."""
    prospective_env_info = VirtualEnvInfo(env_info)
    for _env in virtualenvs:
        if _env == prospective_env_info:
            _env.merge(prospective_env_info)
        else:
            virtualenvs.append(prospective_env_info)

    if len(virtualenvs) == 0:
        virtualenvs.append(prospective_env_info)


os.chdir(info_file_dir)
try:
    sys.path.append(info_file_dir)
    for item in os.listdir(info_file_dir):
        if os.path.isfile(item) and item.startswith("bindings") and item.endswith('.py'):
            module_name = item[:-3]
            module = importlib.import_module(module_name)
            register_environment(module.info)
except Exception as e:
    print('boom')
    print(e)
finally:
    os.chdir(saved_working_directory)


def list():
    print("Available python environments:")
    print("Index -- Configuration")
    for index, venv in enumerate(virtualenvs):
        libs_present = ', '.join(venv["libraries_present"])
        print("{0: <5} -- libraries present: {5}, compiler: {1}, mpi: {2}, build type: {4}".format(index, venv["compiler"], venv["mpi"], venv["mpi_buildtype"], venv["buildtype"], libs_present))


def shell_source(script):
    """Sometime you want to emulate the action of "source" in bash,
    settings some environment variables. Here is a way to do it."""
    import subprocess, os
    pipe = subprocess.Popen(". %s; env" % script, stdout=subprocess.PIPE, shell=True)
    output = pipe.communicate()[0]
    env = dict((line.split("=", 1) for line in output.splitlines()))
    os.environ.update(env)


def activate(index):
    if 0 <= index < len(virtualenvs):
        print("source {0}".format(virtualenvs[index]["activate"]))
    else:
        print("Invalid index: " + str(index))
        list()


if __name__ == "__main__":
    if len(sys.argv) == 1:
        list()
    elif len(sys.argv) == 2:
        index = int(sys.argv[1])
        activate(index)

