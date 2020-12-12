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

my $kDfile = "${dir}/koff/koff_${outfile}.txt";

say $kDfile;
say "";

#my @lines = ();

open(my $xyzfh,'<',$file) or die;

#  in xyz file

my $traj = 0;

my $N1 = 0; # if bound
my $N0 = 0; # if unbound

my $time = 0.0;
my $ave_time = 0.0;

my @x1 = ();
my @y1 = ();
my @z1 = ();

my @x2 = ();
my @y2 = ();
my @z2 = ();


my $on_prev = 0;
my $on_now = 0;

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

		    $on_now = 1;
		}

		last if($on_now);

		$j++;
	    }

	    
	    last if($on_now);
	    $i++;
	}

	if($on_now && $on_prev){
	    $time += 1;
	} elsif($on_now && !$on_prev){
	    $ave_time += $time;
	    $time = 0;
	    $N1 += 1;
	}

	@x1 = ();
	@y1 = ();
	@z1 = ();
	
	@x2 = ();
	@y2 = ();
	@z2 = ();

	
	$on_prev=$on_now;
	$on_now = 0;
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

$ave_time /= $N1;

$dt = 1.71*10**(-9)*0.002*10000; # time of simulation (see Phys. Rev. E 101, 022420 for the reasoning behing the numerical factor , 0.002 sim timestep, 10000 = # of trajs between spitting out xyz
# 1000 = conversion from nano secs to micro secs)

my $koff = 1/($ave_time*$dt);

open($kdout,'>',$kDfile) or die;

print $kdout "$tokens[0]\t${koff}";

close($kdout);


