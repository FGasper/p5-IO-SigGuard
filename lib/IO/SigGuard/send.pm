package IO::SigGuard;

sub send {
  SEND: {
        $result = ( (@_ == 3) ? CORE::send( $_[0], $_[1], $_[2] ) : (@_ == 4) ? CORE::send( $_[0], $_[1], $_[2], $_[3] ) : die "Wrong args count! send(@_)" ) || do {

            #EINTR means the file pointer is unchanged.
            redo SEND if $! == Errno::EINTR();
        };
    }

    return $result;
}

1;
