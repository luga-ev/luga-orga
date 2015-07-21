#!/usr/bin/perl

use warnings;
use strict;

#system("iconv --from-code=ISO-8859-1 --to-code=UTF-8 mg.txt > list.txt");
system("rm -rf output");
system("mkdir output");

open my $fh,'<', "liste.csv" ;


my @file = <$fh>;

close $fh;

my $i = 1;

for my $line (@file) {
  print "$i... ";
  system("rm -rf temp/");
  system("mkdir temp");
  system("cd temp && unzip ../orig.odt >/dev/null");

  # whitespace entfernen
  $line =~ s/^\s+//;
  $line =~ s/\s+$//;

  $line =~ s/&/&amp;/g;

  my @parts = split /\t/, $line;

  my $name   = "$parts[1] $parts[0]";
  $name =~ s/^\s+//;
  my $plz    = $parts[3];
  my $ort    = $parts[4];
  my $street = $parts[2];

  my $anrede;
  my $dusie;
  if($name =~ m/GmbH/)
  {
      $anrede = "Sehr geehrte Damen und Herren";
      $dusie = "Sie";
  }
  else
  {
      my ($vorname, $nachname) = split /\s+/, $name;
      $anrede = "Hallo $vorname";
      $dusie = "Dich";
  }

  system("perl -pi -e 's#XXXXX#$name#' temp/content.xml;");
  system("perl -pi -e 's#YYYYY#$street#' temp/content.xml;");
  system("perl -pi -e 's#ZZZZZ#$plz $ort#'  temp/content.xml;");
  system("perl -pi -e 's#ANREDE#$anrede#'  temp/content.xml;");
  system("perl -pi -e 's#DUSIE#$dusie#'  temp/content.xml;");
  print($name, "\n");

  system(sprintf "cd temp && zip -r ../output/%02d.odt * > /dev/null", $i);

  system("rm -r temp");

  $i++;
}
