#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;

MAIN:
{
	# define variables
	my %opt;
	$opt{i}=0;
	my %suspicious;

	my $result = GetOptions(
                "in=s" 	=> \$opt{in},
		"suspicious=s"  => \$opt{suspicious}
        );
        die "ERROR: $! " if (!$result);

	#############################################

        my (@samples,%samples,%snp,%count);

	if($opt{suspicious})
        {
                open(IN,$opt{suspicious}) or die "ERROR: $!";
                while(<IN>)
                {
                        my @F=split;
                        $suspicious{$F[0]}=1 if(@F);
                }
                close(IN)
        }

        open(IN,$opt{in}) or die "ERROR1: $!";
        while(<IN>)
        {
                chomp;
                next if(/^#/ or /^$/);
                my @F=split;
		next if($suspicious{$F[0]});
                push @samples,$F[0];
                $samples{$F[0]}=1;
        }
	close(IN);

	############################################

	while(<>)
	{
		next if(/^#/);
		my @F=split;
		$F[7]=~/SM=(.+?);/ or $F[7]=~/SM=(.+)$/ or /\tSM\t(\S+)$/ or die "ERROR:$_";
		my $sample=$1;
		defined($samples{$sample}) or die "ERROR: $_";

		if(!$snp{$sample}{$F[1]})
		{
			$count{$sample}{A}++;

			if($F[-1]=~/.+:1$/)
			{
				$count{$sample}{H}++ ;
				if($F[7]!~/;INDEL/)  { $count{$sample}{S}++ } else { $count{$sample}{I}++ }
			}
			else
			{
				$count{$sample}{h}++ ;
				if($F[7]!~/;INDEL/)  { $count{$sample}{s}++ } else { $count{$sample}{i}++ }
			}

			#if($F[7]!~/;HP/)
			if($F[7]!~/;Homopolymer/)
			{
	        	        if($F[-1]=~/.+:1$/)
        	        	{
                	       	 	$count{$sample}{Hp}++ ;
                        		if($F[7]!~/;INDEL/)  { $count{$sample}{Sp}++ } else { $count{$sample}{Ip}++ }
	                	}
        	        	else
                		{
	                        	$count{$sample}{hp}++ ;
        	                	if($F[7]!~/;INDEL/)  { $count{$sample}{sp}++ } else { $count{$sample}{ip}++ }
	                	}
			}

			$snp{$sample}{$F[1]}=1;
		}
	}

	#########################################################

	print join "\t",("Run","H","h","S","s","I","i","Hp","hp","Sp","sp","Ip","ip","A"); print "\n";

	foreach my $i (1..@samples)
        {
		my $sample=$samples[$i-1];
		my @counts=();

		foreach ("H","h","S","s","I","i","Hp","hp","Sp","sp","Ip","ip","A")
		{
			 push @counts,($count{$sample}{$_})?$count{$sample}{$_}:0;
		}

		print join "\t",($sample,@counts); print "\n";
	}

	################################################################
}

