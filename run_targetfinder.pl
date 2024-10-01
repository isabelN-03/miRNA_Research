use Getopt::Std;


$FASTAfile=$ARGV[0]; #i.e. list of miRNAs
$DB=$ARGV[1]; # genome or other database to search
$STRAND = $ARGV[2]; # whether to run on forward or reverse strand
$outfile = $ARGV[3]; # name of output file

if (not($outfile)){print "Usage:  run_targetfinder.pl query.fa database.fa strand outfile\n";exit;}

my @FASTA_data = get_file_data($FASTAfile);
($names,$sequences)=Parse_FASTA(@FASTA_data);
my $size=@$names;
my $strand;
open (O,">$outfile");
if ($STRAND == "reverse") {$strand = "-r";}
else ($strand = "";)

$a=0;
foreach (@$names){
    chomp(@$names[$a]);
    chomp(@$sequences[$a]);

    system("touch $outfile\_hits; rm $outfile\_hits");
    system("targetfinder.pl  -s @$sequence[$a] -d $DB $strand > $outfile\_hits"); 
    print("targetfinder.pl  -s @$sequence[$a] -d $DB $strand > $outfile\_hits\n"); #displays progress of search 

    $hitfile="$outfile\_hits";
    
    #@hits=get_file_data($hitfile);
    #foreach $hit (@hits){
	#if ($hit =~ /^>/){
	#    $hit =~ /^>(\S+):\[(\d+),(\d+)/;
	#    $chr=$1;
	#    $beg=$2;
	#    $end=$3;
	#    if ($end > $beg) {$sense="sense";}
	#    else {$sense="antisense";}
	#}
	#else{
	#    chomp($hit);
	#    print O "query:@$names[$a] qseq:@$sequences[$a] hit:$chr sense:$sense beg:$beg end:$end hseq:$hit\n";
	#}
   #}
    ++$a;

}
close(O);
exit;


########subroutines############



sub get_file_data{
    my($filename)= @_;
    my @filedata=();
    unless( open(GET_FILE_DATA, $filename)){
        print STDERR "Cannot open file \"$filename\"\n\n";
        exit;
    }
    @filedata = <GET_FILE_DATA>;
    close GET_FILE_DATA;
    return @filedata;
}

# A subroutine to parse a FASTA list into arrays of names and sequences
# input is an array of lines (FASTA entries)
# output is two arrays containing names and sequences

sub Parse_FASTA{
    my (@file)=@_;
    my (@names,@sequences);
    my ($current) = '';
    my ($name) = '';
    foreach my $line (@file){
        # discard blank lines
        if ($line =~ /^\s*$/){next;}
        #discard comment lines
        elsif ($line =~ /^\s*#/) {next;
	   }
	#start new entry if ">" is found, put $current into @sequence,
	# and reset $current
	elsif ($line =~/^>(\S+)/){
	    $name=$1;
            unless ($current eq ''){
                push (@sequences,$current);
                $current = '';
	    }
            push(@names,$name);
        }
	#add line to $current
	else {
	    chomp $current;
	    $current.=$line;
	}
    }
    unless ($current eq ''){
	push (@sequences,$current);
    }	
    return \@names,\@sequences;
}