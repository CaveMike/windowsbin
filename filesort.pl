#-------------------------------------------------------------------------------
eval 'exec perl -S $0 ${1+"$@"}'
    if $running_under_some_shell;

#-------------------------------------------------------------------------------
use File::Find;
use Time::Local;
use Cwd;

# Initialize local variables.
$local_dir = ".";
$time_arg  = "0:0:0";
$date_arg  = "1/1/70";
$match_arg = ".*";
$sec       = 0;
$min       = 0;
$hour      = 0;
$mday      = 1;
$mon       = 0;
$year      = 70;
$debug     = 0;

# Print help if there are no options.
usage() if ($#ARGV < 0);

# Parse optional arguments.
while ($_ = $ARGV[0], /^-/)
{
    &usage() if (/-\?|-h$/);

    # When true, prints commands to screen but does nothing.
    /-x/      && ($debug = 1);
    /-t(.+)/  && ($time_arg  = $1);
    /-d(.+)/  && ($date_arg  = $1);
    /-m(.+)/  && ($match_arg = $1);
    shift;
}

# Parse mandatory arguments.
$local_dir = shift;
die "Error:  Expected directory name for first argument" if (!-d $local_dir);

# Dump arguments.
if ( $debug )
{
    print "local_dir = ${local_dir}\n";
    print "time_arg  = ${time_arg}\n";
    print "date_arg  = ${date_arg}\n";
    print "match_arg = ${match_arg}\n";
}

# Parse time_arg into pieces.
($hour, $min, $sec) = split /:/, $time_arg;

# Parse date_arg into pieces.
($mon, $mday, $year) = split /\//, $date_arg;
$mon--;

# Combine time and date pieces into an interal structure.
$minimum_time = timelocal($sec,$min,$hour,$mday,$mon,$year);
#printf( "%09d %02d/%02d/%02d %02d:%02d:%02d\n", $minimum_time, $mon+1, $mday, $year, $hour, $min, $sec );
#print $minimum_time, "\n";


find( \&wanted, $local_dir );
@list = sort @list;
for $i ( 0 .. $#list )
{
    ($etime, $date, $time, $path) = split / /, $list[$i];
    print $date, " ", $time, " ", $path;
}

#-------------------------------------------------------------------------------
sub wanted
{
    if ( -f $_ )
    {
        if ( $_ =~ /$match_arg/ )
        {
            ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat $_;
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($mtime);
            $dir = getcwd();
            if ( $mtime >= $minimum_time )
            {
                $line = sprintf( "%09d %02d/%02d/%02d %02d:%02d:%02d %s\\%s\n", $mtime, $mon+1, $mday, $year, $hour, $min, $sec, $dir, $_ );
                push @list, $line;
            }
        }
    }
}

#-------------------------------------------------------------------------------
sub usage
{
    print "usage:  filesort.pl [options] <directory>\n";
    print "\n";
    print "options:  -d\"mm/dd/yy\"\n";
    print "          -t\"hr:min:sec\"\n";
    print "          -m\"regex match\"   ex: -m\"(\\.cpp)|(\\.h)|(\\.c\$)\"\n";
    exit;
}

