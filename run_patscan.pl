#!/usr/bin/perl -w
# program to submit a list of sequences to patscan and output the locations of the hits
# usage: run_patscan.pl query.fa database.fa #mismatches #deletions #insertions outfile
# assumes that patscan ("scan_for_matches") is installed 

$FASTAfile=$ARGV[0]; #i.e. list of miRNAs
$DB=$ARGV[1]; # genome or other database to search
$mismatches=$ARGV[2];# tolerated mismatches
$deletions=$ARGV[3]; # tolerated deletions. Note that I find patscan unreliable for this
$insertions=$ARGV[4];# tolerated deletions. Note that I find patscan unreliable for this
$outfile = $ARGV[5]; # name of output file

if (not($outfile)){print "usage: simple_patscan.pl query.fa database.fa mismatches deletions insertions outfile\n";exit;}

my @FASTA_data = get_file_data($FASTAfile);
($names,$sequences)=Parse_FASTA(@FASTA_data);
my $size=@$names;
open (O,">$outfile");

$a=0;
foreach (@$names){
    chomp(@$names[$a]);
    chomp(@$sequences[$a]);
    open(PATFILE,">$outfile\_pattern");
    print PATFILE "@$sequences[$a]\[$mismatches,$deletions,$insertions\]";
    close(PATFILE);

    system("touch $outfile\_hits; rm $outfile\_hits");
    system("scan_for_matches  -c $outfile\_pattern < $DB > $outfile\_hits"); 
    print("scan_for_matches  -c  @$names[$a]_pattern < $DB > @$names[$a]\_hits\n"); #displays progress of search 

    $hitfile="$outfile\_hits";
    @hits=get_file_data($hitfile);
    foreach $hit (@hits){
	if ($hit =~ /^>/){
	    $hit =~ /^>(\S+):\[(\d+),(\d+)/;
	    $chr=$1;
	    $beg=$2;
	    $end=$3;
	    if ($end > $beg) {$sense="sense";}
	    else {$sense="antisense";}
	}
	else{
	    chomp($hit);
	    print O "query:@$names[$a] qseq:@$sequences[$a] hit:$chr sense:$sense beg:$beg end:$end hseq:$hit\n";
	}
   }
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

