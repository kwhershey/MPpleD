#!/usr/bin/env python
# configure.py: the youtube2mp3 Makefile generator.
# Author: Benjamin Johnson <obeythepenguin@users.sf.net>
# Date: 2011/01/29

# This script is intended primarily for internal use in youtube2mp3
# and my other open source projects, but feel free to use and adapt
# it for any purpose.  No additional permission is required.

# Basic documentation is available at
# http://youtube2mp3.sourceforge.net/buildsystem.html

# XXX Editing this script?
# XXX Don't forget to update version number in optparse.OptionParser!

import re, os, sys


#
# global variables
#

# configure.py options
cfg_quiet = False

# default target (note: define this for your app in Build.ini)
cfg_default = ''

# installation prefix
if sys.platform == 'win32': cfg_prefix='_install'
else: cfg_prefix = '/usr/local'
cfg_libsuffix = ''

# Qt directory
if 'QTDIR' in os.environ: cfg_qtdir = os.environ['QTDIR']
elif sys.platform.count('openbsd'): cfg_qtdir = '/usr/local/lib/qt3'
else: cfg_qtdir = '/usr/lib/qt'

# compilers and flags
if 'CC' in os.environ: cfg_cc = os.environ['CC']
else: cfg_cc = 'gcc'
if 'CXX' in os.environ: cfg_cxx = os.environ['CXX']
else: cfg_cxx = 'g++'
if 'CFLAGS' in os.environ: cfg_cflags = os.environ['CFLAGS']
else: cfg_cflags = '-Os'
if 'CXXFLAGS' in os.environ: cfg_cxxflags = os.environ['CXXFLAGS']
else: cfg_cxxflags = '-Os'
if 'LDFLAGS' in os.environ: cfg_ldflags = os.environ['LDFLAGS']
else: cfg_ldflags = ''

# Microsoft Windows
cfg_mingw32 = False

targets  = []	# available targets
langs    = {}	# compiler to use for each target
includes = {}	# additional includes; defined per-target
libpaths = {}	# additional library paths; defined per-target
libs     = {}	# additional libraries; defined per-target
sources  = {}	# program sources; defined per-target
windres  = {}	# Windows resource files; defined per-target
wsubsys  = {}	# Windows subsystem to use; defined per-target
nsifile  = {}	# NSIS installer scripts; defined per-target
instexe  = {}	# executables to install; defined per-target
install  = {}	# files to install; defined per-target
copylib  = {}	# libraries to copy after building; defined per-target
ccflags  = {}	# additional cflags/cxxflags; defined per-target
ldflags  = {}	# additional ldflags; defined per-target

cleanup  = []	# additional files to make clean
nsideps  = []	# extra things to build before running NSIS

# miscellaneous
extra_makefiles = []
cfg_debug = False
used_sources = []


#
# Build.ini field parsers
#

def parse_field(value):
	if not value.count(' ') and not value.count(':'): return value

	default = ''
	for choice in value.split(' '):
		if choice.count(':'):
			field = choice.split(':')[0]
			value = choice.split(':')[1]
			if sys.platform == field: return value
		else: default = choice

	return default

def parse_install(value):
	fields = value.split(' ')
	source = fields[0]

	if len(fields) > 1: dest = fields[1]
	else: dest = os.path.join('$(BINDIR)', os.path.basename(source))

	if len(fields) > 2: perm = fields[2]
	else: perm = '0755'

	return (source, dest, perm)


#
# parse Build.ini
#

def parse_build_ini(filename):
	try: lines = open(filename, 'r').read().split('\n')
	except (IOError):
		print >>sys.stderr, 'Failed to open ' + \
			'configuration file "%s"! Exiting.' % (filename)
		exit(1)

	prog_name = ''
	for line in lines:
		line = re.sub(r'\s*[#;].*$', '', line)	# remove comments
		if not line: continue			# skip blank lines

		mobj = re.match(r'^\[(.*)\]$', line)
		if mobj is not None:
			global targets
			prog_name = mobj.group(1)
			targets  += [prog_name]

			langs[prog_name]    = 'c++'
			includes[prog_name] = []
			libpaths[prog_name] = []
			libs[prog_name]     = []
			sources[prog_name]  = []
			windres[prog_name]  = ''
			wsubsys[prog_name]  = ''
			nsifile[prog_name]  = ''
			instexe[prog_name]  = []
			install[prog_name]  = []
			copylib[prog_name]  = []
			ccflags[prog_name]  = []
			ldflags[prog_name]  = []

			if sys.platform.count('openbsd'):
				# include local and X11 shared libraries
				libpaths[prog_name] += ['/usr/X11R6/lib']
				libpaths[prog_name] += ['/usr/local/lib']

			continue

		if line.count('='):
			field = line.split('=')[0]
			value = line.split('=')[1]

			# global fields
			if field == 'default':
				global cfg_default
				cfg_default = value
			elif field == 'addfile':
				global extra_makefiles
				extra_makefiles += [value]
			elif field == 'cleanup':
				global cleanup
				cleanup += [parse_field(value)]
			elif field == 'nsideps':
				global nsideps
				nsideps += [value]

			# target-specific fields
			if not prog_name: continue
			elif field == 'compile':
				langs[prog_name] = value
			elif field == 'include':
				includes[prog_name] += [parse_field(value)]
			elif field == 'libpath':
				libpaths[prog_name] += [parse_field(value)]
			elif field == 'library':
				libs[prog_name] += [parse_field(value)]
			elif field == 'windres':
				windres[prog_name] = os.path.normpath(value)
			elif field == 'windows':
				wsubsys[prog_name] = value
			elif field == 'nsifile':
				nsifile[prog_name] = value
			elif field == 'instexe':
				instexe[prog_name] += [parse_install(value)]
			elif field == 'install':
				install[prog_name] += [parse_install(value)]
			elif field == 'copylib':
				copylib[prog_name] += [parse_field(value)]
			elif field == 'ccflags':
				ccflags[prog_name] += [value]
			elif field == 'ldflags':
				ldflags[prog_name] += [value]

			continue

		if not prog_name: continue
		filename = os.path.normpath(line)
		if path_exists(filename): sources[prog_name] += [filename]


#
# test if a path exists
#

def path_exists(path):
	return os.access(os.path.normpath(path), os.R_OK)

def have_exe_in_path(exe_name):
	path_separator = ':'
	if sys.platform == 'win32':
		path_separator = ';'	# native %PATH% overrides MSYS $PATH
		exe_name += '.exe'	# FIXME: unless maybe MSYS sh script?

	if not 'PATH' in os.environ: return False
	for exe_dir in os.environ['PATH'].split(path_separator):
		exe_path = os.path.join(os.path.normpath(exe_dir), exe_name)
		if os.access(os.path.normpath(exe_path), os.X_OK): return True

	return False


#
# file naming rules
#

def filename_header(source):
	return os.path.splitext(source)[0] + '.h'

def filename_moc(source):
	return os.path.splitext(source)[0] + '.moc'

def filename_output(target):
	if sys.platform == 'win32': return target + '.exe'
	else: return target

def filename_object(source):
	if sys.platform == 'win32': extension = '.obj'
	else: extension = '.o'
	return os.path.splitext(source)[0] + extension

def filename_windres(windres):
	return os.path.splitext(windres)[0] + '.res'


#
# write rules for each target
#

def write_rules(makefile, target):
	global used_sources
	if not cfg_quiet: print 'Configuring %s:' % (target)

	makefile.write('%s:' % (filename_output(target)))
	for source in sources[target]:
		makefile.write(' ' + filename_object(source))
	if sys.platform == 'win32' and windres[target]:
		makefile.write(' ' + filename_windres(windres[target]))
	makefile.write('\n')

	lang = langs[target]
	if lang == 'c':
		compiler = '$(CC)'
		compflag = '$(CFLAGS)'
	elif lang == 'c++':
		compiler = '$(CXX)'
		compflag = '$(CXXFLAGS)'
	else:	# assume C++
		compiler = '$(CXX)'
		compflag = '$(CXXFLAGS)'

	# add additional target-specific flags
	for flag in ccflags[target]:
		if flag: compflag += ' ' + flag

	makefile.write('\t@echo "  [LINK] $@"\n')
	makefile.write('\t@%s -o $@ $? $(LDFLAGS)' % (compiler))
	for libpath in libpaths[target]:
		if libpath: makefile.write(' -L' + libpath)
	for lib in libs[target]:
		if lib: makefile.write(' -l' + lib)
	for flag in ldflags[target]:
		if flag: makefile.write(' ' + flag)
	if sys.platform == 'win32' and wsubsys[target]:
		makefile.write(' -Wl,-subsystem,' + wsubsys[target])
	if sys.platform.count('openbsd'):	# XXX not always a
		makefile.write(' -pthread')	# XXX safe assumption?
	makefile.write('\n')

	if not cfg_debug:
		makefile.write('\t@strip --strip-unneeded $@\n')

	# Nasty kludge so we can copy qt-mt3.dll and mingwm10.dll
	# to the build directory on Windows. (This lets us test the
	# app, and lets our NSIS scripts avoid mucking with $MINGW.)
	if sys.platform == 'win32' and cfg_mingw32: cp = 'copy'
	else: cp = 'cp'
	for lib in copylib[target]:
		if not lib: continue
		bn = os.path.basename(lib)
		makefile.write('\t@echo "  [COPY] %s"\n' % (bn))
		makefile.write('\t@%s %s %s\n' % (cp, lib, bn))
	makefile.write('\n')

	# object files
	src_current = 1		# used only for displaying progress
	src_total = len(sources[target])
	for source in sources[target]:
		# prevent redundant Makefile rules
		if source in used_sources: continue

		# display build progress as percentage
		progress = float(src_current) / float(src_total)
		pr = '[%3s%%]' % (str(int(progress * 100)))
		if not cfg_quiet: print '  %s %s' % (pr, source)

		makefile.write('%s:' % (filename_object(source)))
		makefile.write(' ' + source)
		if path_exists(filename_header(source)):
			makefile.write(' ' + filename_header(source))

		# a very simplistic dependency tracker
		fh = os.path.normpath(filename_header(source))
		try: lines = open(fh, 'r').read()
		except IOError: lines = ''
		for line in lines.split('\n'):
			mobj = re.match('^#include "(.*)"$', line)
			if mobj is None: continue
			hn = mobj.group(1)
			fn = os.path.join(os.path.dirname(fh), hn)
			fn = os.path.normpath(fn)
			if path_exists(fn): makefile.write(' ' + fn)

		# run Qt's moc preprocessor?
		if lines.count('Q_OBJECT'):
			m = '$(QTDIR)/bin/moc'
			o = filename_moc(source)
			makefile.write('\n\t@%s -o %s %s' % (m, o, fh))

		makefile.write('\n\t@%s %s' % (compiler, compflag))
		for include in includes[target]:
			if include: makefile.write(' -I' + include)
		makefile.write(' -c -o $@ $<\n')
		makefile.write('\t@echo "  %s %s"\n\n' % (pr, source))

		src_current += 1
		used_sources += [source]

	# Windows resource files
	if sys.platform == 'win32' and windres[target]:
		rc = filename_windres(windres[target])
		makefile.write('%s: %s\n' % (rc, windres[target]))
		makefile.write('\t@windres -O coff -o $@ $<\n\n')

	if not cfg_quiet: print


#
# generate the Makefile
#

def generate_makefile(filename):
	try: makefile = open(filename, 'w')
	except (IOError):
		print >>sys.stderr, 'Failed to open ' + \
			'"%s" for writing! Exiting.' % (filename)
		exit(1)

	global target, extra_makefiles

	makefile.write('# Automatically generated by configure.py.\n')
	makefile.write('# Please do not edit this file manually!\n\n')

	if not cfg_default:
		print >>sys.stderr, 'No default target found! Exiting.'
		exit(1)

	# default target
	makefile.write('.PHONY: all\n.DEFAULT: all\n')
	makefile.write('all: %s\n\n' % (filename_output(cfg_default)))

	# additional Makefiles
	if extra_makefiles:
		for file in extra_makefiles:
			makefile.write('include %s\n' % (file))
		makefile.write('\n')

	# compiler and flags
	# NOTE! We have to hardcode our preferred compiler
	# to override make's implicit definition.  Ugly...
	#makefile.write('CC ?= %s\nCXX ?= %s\n' %(cfg_cc, cfg_cxx))
	makefile.write('CC = %s\nCXX = %s\n' %(cfg_cc, cfg_cxx))
	makefile.write('CFLAGS ?= %s\n' % (cfg_cflags))
	makefile.write('CXXFLAGS ?= %s\n' % (cfg_cxxflags))
	makefile.write('LDFLAGS ?= %s\n' % (cfg_ldflags))
	makefile.write('QTDIR ?= %s\n\n' % (cfg_qtdir))

	# additional hard-coded compiler flags:
	# debugging, compiler output, optimizations...
	for var in ['CFLAGS', 'CXXFLAGS']:
		makefile.write('%s += ' % (var))
		if cfg_debug: makefile.write('-g -DSHOWDEBUG')
		else: makefile.write('-w')
		makefile.write(' -pipe\n')
	makefile.write('\n')

	# installation prefix
	makefile.write('PREFIX  ?= %s\n' % (cfg_prefix))
	makefile.write('BINDIR  ?= $(PREFIX)/bin\n')
	makefile.write('LIBDIR  ?= $(PREFIX)/lib%s\n' % (cfg_libsuffix))
	makefile.write('DATADIR ?= $(PREFIX)/share\n')
	makefile.write('MANDIR  ?= $(PREFIX)/man\n')

	# compile targets
	for target in targets:
		if not sources[target]: continue
		write_rules(makefile, target)

	# we may need these now
	if sys.platform == 'win32' and cfg_mingw32: rm = 'del /Q /F /S'
	else: rm = 'rm -rf'

	# install target
	makefile.write('install:')
	for target in targets:
		if not instexe[target] and not install[target]: continue
		makefile.write(' ' + filename_output(target))
	makefile.write('\n')
	for target in targets:
		if not instexe[target] and not install[target]: continue
		if sys.platform.count('openbsd'): i = '@install'
		else: i = '@install -D'		# this is assuming GNU install
		for (s, d, m) in instexe[target]:
			s = filename_output(s)
			d = '$(DESTDIR)' + d
			makefile.write('\t@echo "  [INST] %s"\n' % (s))
			makefile.write('\t%s -m %s %s %s\n' % (i, m, s, d))
		for (s, d, m) in install[target]:
			d = '$(DESTDIR)' + d
			makefile.write('\t@echo "  [INST] %s"\n' % (s))
			makefile.write('\t%s -m %s %s %s\n' % (i, m, s, d))
	makefile.write('\n')

	# uninstall target
	makefile.write('uninstall:\n')
	for target in targets:
		if not install[target]: continue
		for (s, d, m) in instexe[target] + install[target]:
			d = '$(DESTDIR)' + d
			makefile.write('\t@echo "  [UNINST] %s"\n' % (d))
			makefile.write('\t@%s %s\n' % (rm, d))
	makefile.write('\n')

	# clean target
	makefile.write('clean:\n')
	for target in targets:
		makefile.write('\t@echo "  [CLEAN] %s"\n' % target)
		makefile.write('\t@%s %s\n' % (rm, filename_output(target)))
		for s in sources[target]:
			makefile.write('\t@%s %s\n' % (rm, filename_object(s)))
			makefile.write('\t@%s %s\n' % (rm, filename_moc(s)))
		if sys.platform == 'win32' and windres[target]:
			rc = filename_windres(windres[target])
			makefile.write('\t@%s %s\n' % (rm, rc))
	for file in cleanup:
		if file: makefile.write('\t@%s %s\n' % (rm, file))
	makefile.write('\n')

	# distclean target
	makefile.write('distclean: clean\n')
	makefile.write('\t@%s %s\n' % (rm, filename))

	# NSIS scripts
	if sys.platform == 'win32' and nsifile:
		nsis = '"$(PROGRAMFILES)/NSIS/makensis.exe"'
		makefile.write('\nsetup:')
		for target in targets:
			nsi = nsifile[target]
			if nsi: makefile.write(' ' + filename_output(target))
		for nsidep in nsideps:
			if nsidep: makefile.write(' ' + nsidep)
		makefile.write('\n')
		for target in targets:
			n = nsifile[target]
			if n: makefile.write('\t@echo "  [NSIS] %s"\n' % (n))
			if n: makefile.write('\t@%s %s\n' % (nsis, n))

	if not cfg_quiet:
		print 'Configuration finished. Type \'make\' to build.\n'
	makefile.close()


#
# main loop
#

if __name__ == '__main__':
	import optparse
	parser = optparse.OptionParser(
		usage='Usage: %prog [options]',
		version='2011.01.29',
		conflict_handler='resolve',
	)

	parser.add_option('-h', '--help',
		action='help', help='print this help text and exit')
	parser.add_option('-v', '--version',
		action='version', help='print script version and exit')
	parser.add_option('-q', '--quiet',
		action='store_true', dest='quiet',
		help='don\'t print stupid status messages')

	instopts = optparse.OptionGroup(parser, 'Installation Options')
	instopts.add_option('--prefix',
		action='store', dest='prefix', metavar='PREFIX',
		help='installation prefix [%s]' % (cfg_prefix))
	instopts.add_option('--libsuffix',
		action='store', dest='libsuffix', metavar='SFX',
		help='shared library dir suffix [none]')
	parser.add_option_group(instopts)

	buildopts = optparse.OptionGroup(parser, 'Build Options')
	buildopts.add_option('--with-qt',
		action='store', dest='qtdir', metavar='QTDIR',
		help='location of Qt 3.3.x [%s]' % (cfg_qtdir))
	if sys.platform == 'win32': buildopts.add_option('--enable-mingw32',
		action='store_true', dest='mingw32',
		help='configure for mingw32-make [off]')
	buildopts.add_option('--enable-debug',
		action='store_true', dest='debug',
		help='enable debug build [off]')
	buildopts.add_option('--disable-ccache',
		action='store_false', dest='ccache',
		help='disable ccache [autodetect]', default=True)
	parser.add_option_group(buildopts)

	(opts, args) = parser.parse_args()
	if opts.quiet: cfg_quiet = opts.quiet
	if opts.prefix: cfg_prefix = opts.prefix
	if opts.libsuffix: cfg_libsuffix = opts.libsuffix
	if opts.qtdir: cfg_qtdir = opts.qtdir
	if sys.platform == 'win32' and opts.mingw32: cfg_mingw32 = opts.mingw32
	if opts.debug: cfg_debug = opts.debug

	# ccache can significantly speed up the build process,
	# but it's sometimes easy to forget to configure it...
	if opts.ccache and have_exe_in_path('ccache'):
		cfg_cc  = 'ccache ' + cfg_cc
		cfg_cxx = 'ccache ' + cfg_cxx

	parse_build_ini('Build.ini')
	generate_makefile('Makefile')
