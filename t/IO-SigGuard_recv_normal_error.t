#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

use IO::File ();

use IO::SigGuard ();

use Errno;

plan tests => 2;

pipe my $r, my $w;
$r->blocking(0);

my $got = IO::SigGuard::recv($r, my $buf, 123, 0);
my $err = $!;

is( 0 + $err, Errno::ENOTSOCK(), 'expected recv() failure' ) or do {
    local $! = $err;
    diag "$!";
};

is( $got, undef, 'undef is returned' );
