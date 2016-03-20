#!/usr/bin/perl

use warnings;
use strict;

my @table;
my %details;

while(<>) {
  chomp;
  last unless $_;

  push @table, [split /\s+/, $_];
}

scalar <>;

while(<>) {
  /^=== (\w+)$/ or die;
  my $id = $1;

  <> =~ /^$/ or die;
  chomp($details{$id}{speaker}    = <>);
  chomp($details{$id}{shorttitle} = <>);
  chomp($details{$id}{longtitle}  = <>);

  $details{$id}{shorttitle} =~ s/^!// and $details{$id}{twoslots}++;

  <> =~ /^$/ or die;
  $details{$id}{abstract} = "";
  my $empty_lines = 1;

  while(<>) {
    chomp;
    if($_) { $empty_lines = 0 } else { $empty_lines++ }
    last if $empty_lines == 2;
    $details{$id}{abstract} .= "$_\n";
  }

  chomp($details{$id}{abstract});
  chomp($details{$id}{abstract});

  last if eof;
}


my @slots = qw< 10:45 11:45 13:15 14:15 15:15 16:15 >;
my @rooms = qw< A B C D E F >;
for(my $i = 0; $i < @slots; $i++) {
  if($i== 2) { print <<EOF }

  <tr>
    <td>12:45</td>
    <td colspan="6">Mittagspause: Brotzeitstand</td>
  </tr>
EOF

  print "\n  <tr>\n    <td>$slots[$i]</td>\n";

  for(my $j = 0; $j < @{ $table[$i] }; $j++) {
    my $id = $table[$i][$j];
    if($details{$id}) {
      my $rowspan = $details{$id}{twoslots} ? " rowspan=\"2\"" : "";
      print "    <td$rowspan><em>$details{$id}{speaker}</em><br><a href=\"abstracts.html#$id\">$details{$id}{shorttitle}</a></td>\n";
      $details{$id}{time} = $slots[$i];
      $details{$id}{room} = $rooms[$j];
    } else {
      print "    <td></td>\n";
    }
  }

  print "  </tr>\n";
}


open my $fh, ">", "abs.html" or die $!;

my @a = "keynote";
push @a, @$_ for @table;

$details{keynote}{time} = "09:45";
$details{keynote}{room} = $rooms[0];

for my $id (@a) {
  next unless $details{$id};
  my $abs = $details{$id}{abstract};
  $abs =~ s#\n\n#</p><p>#g;
  print $fh "<div id=\"$id\"><h3>$details{$id}{longtitle}</h3>\n";
  print $fh "<p><em>$details{$id}{speaker}</em>, $details{$id}{time} Uhr, Raum $details{$id}{room}. $abs</p></div>\n\n";
}
