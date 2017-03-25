#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

use IO::Sys ();

plan tests => 1;

#NB: not 'IGNORE'
$SIG{'USR1'} = sub {};

my ($cr, $pw);

pipe( $cr, $pw ) or die $!;

my $pid = fork;
die $! if !defined $pid;
$pid or do {
    close $pw or die;

    my $ppid = getppid;

    $cr->blocking(0);

    my $rin = q<>;
    vec( $rin, fileno($cr), 1 ) = 1;

    my $rout;

    while (1) {
        if ( select $rout = $rin, undef, undef, undef ) {
            sysread( $cr, my $buf, 65536 ) or die $!;
        }
        kill 'USR1', $ppid or die $!;
    }

    exit;
};

close $cr or die $!;

my $start = time;

my $secs = 8;

note "Thrashing IPC for $secs seconds to test EINTR resistance …";

while (time - $start < $secs) {
    IO::Sys::write( $pw, 'x' x 65536 ) or die $!;
}

kill 'TERM', $pid or die $!;

ok 1;
