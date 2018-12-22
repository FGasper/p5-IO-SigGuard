package IO::SigGuard;

sub recv {
    die "Wrong args count! recv(@_)" if @_ != 4;

    $result = CORE::recv( $_[0], $_[1], $_[2], $_[3] ) || do {
        goto &recv if $! == Errno::EINTR();
    };

    return $result;
}

1;
