#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Deep;

use IO::SigGuard ();

use Errno;

plan tests => 2;

pipe my $r, my $w;
$r->blocking(0);

my $got = IO::SigGuard::sysread($r, my $buf, 512);
my $err = $!;

cmp_deeply(
    0 + $err,
    any( Errno::EAGAIN(), Errno::EWOULDBLOCK() ),
    'expected sysread() failure'
) or do {
    local $! = $err;
    diag "$!";
};

is( $got, undef, 'undef is returned' );
