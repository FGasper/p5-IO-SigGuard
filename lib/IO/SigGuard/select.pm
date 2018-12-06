package IO::SigGuard;

#Set this in lieu of using Time::HiRes or built-in time().
our $TIME_CR;

my ($start, $last_loop_time, $os_error, $nfound, $timeleft, $timer_cr);

#pre-5.16 didn’t have \&CORE::time.
sub _time { time }

sub select {
    die( (caller 0)[3] . ' must have 4 arguments!' ) if @_ != 4;

    $os_error = $!;

    $timer_cr = $TIME_CR || Time::HiRes->can('time') || \&_time;

    $start = $timer_cr->();
    $last_loop_time = $start;

  SELECT: {
        ($nfound, $timeleft) = CORE::select( $_[0], $_[1], $_[2], $_[3] - $last_loop_time + $start );
        if ($nfound == -1) {

            #Use of %! will autoload Errno.pm,
            #which can affect the value of $!.
            my $select_error = $!;

            if ($! == Errno::EINTR()) {
                $last_loop_time = $timer_cr->();
                redo SELECT;
            }

            $! = $select_error;
        }
        else {

            #select() doesn’t set $! on success, so let’s not clobber what
            #value was there before.
            $! = $os_error;
        }

        return wantarray ? ($nfound, $timeleft) : $nfound;
    }
}

1;
