#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

use IO::Socket ();

use IO::SigGuard ();

use Errno;

plan tests => 2;

pipe my $r, my $w;
close $r;

$SIG{'PIPE'} = 'IGNORE';

my $got = IO::SigGuard::syswrite($w, 'abcabc');
my $err = $!;

is( 0 + $err, Errno::EPIPE(), 'expected syswrite() failure' ) or do {
    local $! = $err;
    diag "$!";
};

is( $got, undef, 'undef is returned' );
