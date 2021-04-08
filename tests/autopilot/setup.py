#!/usr/bin/python3

# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
# Copyright 2013, 2014 Canonical
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.


import setuptools


setuptools.setup(
    name='lomiri-system-settings',
    version='0.1',
    description='Lomiri System Settings autopilot tests.',
    url='https://gitlab.com/ubports/core/lomiri-system-settings',
    license='GPLv3',
    packages=setuptools.find_packages(),
    package_dir={
        'lomiri_system_settings': './lomiri_system_settings'},
    package_data={
        'lomiri_system_settings': ['background_images/*.jpg'],
    }
)
