#!/usr/bin/perl
#
# Convert an article written with math.se math markup 
# to something that might produce the same result when
# pasted into WordPress's article dialog

local $/ = "";
print "[mathjax]\n\n";
while (<>) {
  s{\\}{\\\\}g;
  s{\$\$(.*?)\$\$}{BEGINDISPLAY $1 ENDDISPLAY}gs;
  s{\$(.*?)\$}{[latex] $1 \[/latex]}gs;
  s/(BEGIN|END)DISPLAY/\$\$/g;
  print;
}
