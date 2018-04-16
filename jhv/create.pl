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

  my @parts = split /;/, $line;

  my $name   = "$parts[1] $parts[2]";
  $name =~ s/^\s+//;
  my $plz    = $parts[5];
  my $ort    = $parts[6];
  my $street = $parts[3];

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
  die "zip failed. Have you installed the package zip?"
    if $? != 0;

  system(sprintf "unoconv -f pdf output/%02d.odt", $i);
  die "unoconv failed. Have you installed the package unoconv?"
    if $? != 0;

  system("rm -r temp");

  $i++;
}

print("Generiere einladungen.pdf...\n");
system("pdftk output/*.pdf cat output einladungen.pdf");

die "pdftk failed. Have you installed the package pdftk?"
    if $? != 0;
