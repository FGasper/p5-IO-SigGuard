#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

use IO::Socket ();

use IO::SigGuard ();

use Errno;

plan tests => 2;

pipe my $r, my $w;

my $got = IO::SigGuard::send($w, 'abcabc', 0);
my $err = $!;

is( 0 + $err, Errno::ENOTSOCK(), 'expected send() failure' ) or do {
    local $! = $err;
    diag "$!";
};

is( $got, undef, 'undef is returned' );
