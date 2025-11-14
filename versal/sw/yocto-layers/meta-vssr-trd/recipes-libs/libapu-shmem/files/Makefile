#****************************************************************************
#
# Copyright (C) 2019 - 2021 Xilinx, Inc. All rights reserved.
# Copyright (c) 2022 - 2025 Advanced Micro Devices, Inc.  ALL rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
#******************************************************************************

# Makefile to build libapu-shm library.
#
LIBSOURCES=*.c
OUTS = *.o
NAME := apu-shmem
MAJOR = 1.0
MINOR = 1
VERSION = $(MAJOR).$(MINOR)

all: lib$(NAME).so
lib$(NAME).so.$(VERSION): $(OUTS)
	$(CC) $(LDFLAGS) $(OUTS) -shared -Wl,-soname,lib$(NAME).so.$(MAJOR) -o lib$(NAME).so.$(VERSION) -lmetal
lib$(NAME).so: lib$(NAME).so.$(VERSION)
	rm -f lib$(NAME).so.$(MAJOR) lib$(NAME).so
	ln -s lib$(NAME).so.$(VERSION) lib$(NAME).so.$(MAJOR)
	ln -s lib$(NAME).so.$(MAJOR) lib$(NAME).so
%.o: %.c
	$(CC) $(CFLAGS) -c -fPIC $(LIBSOURCES)
clean:
	rm -rf *.o *.so *.so.*
