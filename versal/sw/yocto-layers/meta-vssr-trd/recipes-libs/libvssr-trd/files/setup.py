#****************************************************************************
#
# Copyright (C) 2019 - 2021 Xilinx, Inc. All rights reserved.
# Copyright (c) 2022 - 2025 Advanced Micro Devices, Inc.  ALL rights reserved.
#
#****************************************************************************

import os, sys

from distutils.core import setup, Extension
from distutils import sysconfig

cpp_args = ['-std=c++11']
link_args = ['-lapu-shmem']

ext_modules = [
    Extension(
    'vssr_trd',
        ['funcs.cpp', 'bind.cpp', 'vssr-design.cpp'],
        include_dirs=['pybind11/include'],
    language='c++',
    extra_compile_args = cpp_args,
    extra_link_args = link_args,
    ),
]

setup(
    name='vssr_trd',
    version='0.0.1',
    author='Pallav',
    description='vssr library Module',
    ext_modules=ext_modules,
)
