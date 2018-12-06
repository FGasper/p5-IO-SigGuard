package IO::SigGuard;

sub syswrite {
  WRITE: {
        $result = ( (@_ == 2) ? CORE::syswrite( $_[0], $_[1] ) : (@_ == 3) ? CORE::syswrite( $_[0], $_[1], $_[2] ) : (@_ == 4) ? CORE::syswrite( $_[0], $_[1], $_[2], $_[3] ) : die "Wrong args count! syswrite(@_)" ) || do {

            #EINTR means the file pointer is unchanged.
            redo WRITE if $! == Errno::EINTR();
        };
    }

    return $result;
}

1;
