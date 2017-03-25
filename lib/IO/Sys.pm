package IO::Sys;

=encoding utf-8

=head1 NAME

IO::Sys - Signal protection for sysread/syswrite

=cut

use strict;
use warnings;

#As light as possible …

my $read;

sub read {
  READ: {
        $read = ( (@_ == 3) ? sysread( $_[0], $_[1], $_[2] ) : (@_ == 4) ? sysread( $_[0], $_[1], $_[2], $_[3] ) : die "Wrong args count! (@_)" ) or do {
            if ($!) {
                redo READ if $!{'EINTR'};
            }
        };
    }

    return $read;
}

my $wrote;

sub write {
    $wrote = 0;

  WRITE: {
        $wrote += syswrite( $_[0], $_[1], length($_[1]) - $wrote, $wrote ) || do {
            if ($!) {
                redo WRITE if $!{'EINTR'};  #EINTR => file pointer unchanged
                return undef;
            }

            die "empty write without error??";  #unexpected!
        };
    }

    return $wrote;
}

1;
