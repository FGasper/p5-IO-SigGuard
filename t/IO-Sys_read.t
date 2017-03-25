#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

use IO::Sys ();

plan tests => 1;

#NB: not 'IGNORE'
$SIG{'USR1'} = sub {};

my ($pr, $cw);

pipe( $pr, $cw ) or die $!;

my $pid = fork;
die $! if !defined $pid;
$pid or do {
    close $pr;

    my $ppid = getppid;

    $cw->blocking(0);

    my $rin = q<>;
    vec( $rin, fileno($cw), 1 ) = 1;

    my $rout;

    while (1) {
        if ( select undef, $rout = $rin, undef, undef ) {
            syswrite( $cw, ('x' x 65536) ) or die $!;
        }
        kill 'USR1', $ppid or die $!;
    }

    exit;
};

close $cw or die $!;

my $start = time;

my $secs = 8;

note "Thrashing IPC for $secs seconds to test EINTR resistance …";

while (time - $start < $secs) {
    IO::Sys::read( $pr, my $buf, 65536 ) or die $!;
}

kill 'TERM', $pid or die $!;

ok 1;
