#!/usr/bin/perl

use v5.10;
use POSIX qw/ceil/;
use File::Basename;
use Cwd;
use Math::Trig ':pi';

my $dir = "./";

my $file = $ARGV[0];
my $atomtype1 = $ARGV[1];
my $atomtype2 = $ARGV[2];
my $cutoff = $ARGV[3];
my $bl = $ARGV[4];
my $Napb= $ARGV[5];
my $npatches = $ARGV[6];

chomp($file);

#say $file;

#say "at1: $atomtype1";
#say "at2: $atomtype2";
#say "cutoff: $cutoff";
#say "bl: $bl";

my $outfile = basename($file,".xyz");

# getting N_FG

my $N_FG = 0; 

my @tokens = split('_',$outfile);

my $toklength = length($tokens[0]);

if($toklength == 5){
    
    my @letters = split(//,$tokens[0]);

    $N_FG = $letters[-1];
		   
} elsif($toklength==6){
    
    my @letters = split(//,$tokens[0]);

    for my $letter (@letters){

	if($letter =~ m/F/){
	    $N_FG++;
	}
    }

}

say "$outfile";
say "N_FG = $N_FG";

my $kDfile = "${dir}/kDs/kD_${outfile}.txt";

say $kDfile;
say "";

#my @lines = ();

open(my $xyzfh,'<',$file) or die;

#  in xyz file

my $traj = 0;

my $on = 0; # switch if in contact

my $N1 = 0; # if bound
my $N0 = 0; # if unbound

my @x1 = ();
my @y1 = ();
my @z1 = ();

my @x2 = ();
my @y2 = ();
my @z2 = ();

while (my $line = <$xyzfh>){
    
    chomp $line;
    my @linedata = split /\s+/, $line;
    
    if($linedata[0] eq 'Atoms.'){

	my $len1 = @x1;
	my $len2 = @x2;
	
	my $i = 0;
	
	while($i < $len1){
	    my $j = 0;
	    while($j < $len2){
		
		my $dx = $x1[$i] - $x2[$j];
		my $dy = $y1[$i] - $y2[$j];
		my $dz = $z1[$i] - $z2[$j];


		if($dx > $bl*0.5){
		    $dx -= $bl;
		} elsif($dx <= -$bl*0.5){
		    $dx += $bl;
		}
		
		if($dy > $bl*0.5){
		    $dy -= $bl;
		} elsif($dy <= -$bl*0.5){
		    $dy += $bl;
		}
		
		if($dz > $bl*0.5){
		    $dz -= $bl;
		} elsif($dz <= -$bl*0.5){
		    $dz += $bl;
		}

		my $r = sqrt($dx*$dx + $dy*$dy + $dz*$dz);

		if($r <= $cutoff){

		    $on = 1;
		}

		last if($on);

		$j++;
	    }

	    
	    last if($on);
	    $i++;
	}

	if($on){
	    $N1 += 1;
	} else {
	    $N0 += 1;
	}

	@x1 = ();
	@y1 = ();
	@z1 = ();
	
	@x2 = ();
	@y2 = ();
	@z2 = ();

	$on = 0;
	$traj++;

    } elsif($linedata[0]==$atomtype1){

	push(@x1,$linedata[1]);
	push(@y1,$linedata[2]);
	push(@z1,$linedata[3]);

    } elsif($linedata[0]==$atomtype2){

	push(@x2,$linedata[1]);
	push(@y2,$linedata[2]);
	push(@z2,$linedata[3]);

    }
    
}

close($xyzfh);

say $N1;

my $V = ${bl}**3;

my $Vd =(4/3)*pi*(2.0*(${cutoff})**3 + $Napb*$N_FG*(${cutoff})**3);
#my $Vd =(4/3)*pi*($npatches*(${cutoff})**3 + $Napb*$N_FG*(${cutoff})**3); # uniform sphere

my $kD = (10.0*$N0)/(6.02214086*($V-$Vd)*$N1);

open($kdout,'>',$kDfile) or die;

print $kdout "$tokens[0]\t${kD}";

close($kdout);



