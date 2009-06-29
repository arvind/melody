#!/usr/bin/perl -w

# Movable Type (r) Open Source (C) 2001-2009 Six Apart, Ltd.
# This program is distributed under the terms of the
# GNU General Public License, version 2.
#
# $Id$

use strict;
BEGIN { 
    unshift @INC, ($0 =~ m!(.*[/\\])! ? ( $1 . 'lib', $1 . '../../lib', $1 . '../../extlib' ) : ( 'lib', '../../lib', '../../extlib'));
    $ENV{MT_HOME} = '../../';
};

use MT::Bootstrap App => 'MT::App::Trackback';
