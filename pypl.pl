#!/usr/bin/perl -w
use Text::ParseWords;

%array_flag = ();
%str_flag = ();
%hash_flag = ();

sub translate_single {

    ##translate single value, variable and operator, for example if it's number, print directly, 
    ##if it's variable, add leading $ sign,  if it's operator, print with leading and ending space.
    

    $var = $_[0];
    $var =~ s/^\s*//g;
    $var =~ s/\s*$//g;

    if($var =~ /^([0-9\.]+|\-[0-9\.,]+)$/) {
        
	###translate number

        return $var;


    } elsif($var =~ /^(\+\+\+|\+|\-|\*\*|\/\/|\%|\*|\(|\)|\[|\]|\||\^|&|<<|>>|~|<=|>=|!=|==|=|\/|>|<|\+\+\+\+|{|})$/) {
        	
	###translate operators and brackets

        if($var eq '//') {
        
            return ' / ';
        
	} elsif($var eq '+++') {

	    return ' . ';

	} elsif($var eq '++++') {
	
	    return ' .= ';
	    

	} 
	else{
   
            my $s = ' ' . $var . ' ';
            return $s;
        }

    } elsif($var =~ /^len\((.*)\)$/) {

	###translate len function

	my $group_1 = $1;

	if($array_flag{$group_1} and $array_flag{$group_1} == 1) {
	
	    my $s = '@' . $group_1;
	    return $s;

	} else {
	
	    if($group_1 =~ /^\s*\[(.*)\]\s*$/) {

		my @temp_array = parse_line(q{,}, 1, $group_1);
		
		my $size = @temp_array;
		
		return $size;

	    } else {
	
	        my $s = 'length ';
	        $s .= translate_expression($group_1);
	        return $s;    
	    }
	}
    
    } elsif($var =~ /^int$/) {

	##translate int function

        my $s = 'int';
        return $s;
    
    } elsif($var =~ /^sys\.stdin\.readline$/) {

	##translate sys.stdin.readline

	my $s = '<STDIN>';
	return $s;

    } elsif($var =~ /^\(\)$/) {

	##translate ()

	return "";

    } elsif($var =~ /^(.*)\[(.*)\]$/) {
   
	##translate []

        if($1 eq 'sys.argv') {
        
            my $s = '$';
            $s .= 'ARGV[';
            $s .= translate_expression($2);
            $s .= ' - 1]';
            return $s;
        
        } else {
            
            my $s = '$' . $1 . '[';
            $s .= translate_expression($2);
            $s .= ']';
            return $s;
        
        }

    } elsif($var =~ /^['"].*['"]$/) {

	    ##translate string with quotes

            my $s = $var;
            return $s;
    
    } elsif($var eq 'and') {

	    ##translate and

            return ' and ';
    
    } elsif($var eq 'or') {
	    
	    ##translate or

            return ' or ';

    } elsif($var eq 'not') {

	    ##translate not

            return ' not ';
   
    } elsif($var =~ /^(and|or|not)$/) {
		
	    my @split_list = split /\s+/, $var;
	    my $s = "";
            foreach my $i(@split_list) {
            	$s .= translate_single($i);
            }
	    return $s;
    
    } elsif($var =~ /^\s*$/) {

	    ##translate empty line

	    return "";

    } elsif($var =~ /^([\S]*)\.pop\((.*)\)$/) {


	##translate list pop

	my $group_1 = $1;
	my $group_2 = $2;

	if($group_2 =~ /^\s*$/) {
	    
	    $array_flag{$group_1} = 1;
	    my $s = 'pop @' . $group_1;
	    return $s;	
	
	} else {
	    $array_flag{$group_1} = 1;
	    my $s = 'splice @' . $group_1 . ', ' . translate_single($group_2) . ', ' .'1';
	    return $s;         
	
	}
    
    } elsif($var =~ /^([\S]*)\.append\((.*)\)$/) {

	##translate list append

	my $group_1 = $1;
	my $group_2 = $2;
	
	my $s = 'push @' . $group_1 . ', ';
	$s .= translate_expression($group_2);
	$array_flag{$group_1} = 1;
	return $s;



    } elsif($var =~ /^sorted\((.*)\)$/) {

	##translate sorted

	my $group_1 = $1;
	if($group_1 =~ /^\[(.*)\]$/) {

	    my @temp_array = parse_line(q{,}, 1, $group_1);

		
	    my $s = 'sort {$a <=> $b or $a cmp $b} (';
	    $s .= $group_1;
	    $s .= ')';
	    return $s;
	    
	
	} else {

	    my $s = 'sort {$a <=> $b or $a cmp $b} ';
	    $s .= translate_single($group_1); 
	    return $s;   

	}
    
    } else {
	
	##translate variable with $, array with @ or hash with %	

	if(exists($array_flag{$var}) and $array_flag{$var} == 1) {

	    my $s = '@' . $var;
	    return $s;	

	} elsif(exists($array_flag{$var}) and $array_flag{$var} == 0) {

	   # print $var, ', ',$array_flag{$var}, "No\n";
            my $s = '$' . $var;
	    $array_flag{$var} = 1;
            return $s;
      	
	}elsif(exists($hash_flag{$var}) and $hash_flag{$var} == 1) {
	
	    my $s = '%' . $var;
	    return $s;

	} elsif(exists($hash_flag{$var}) and $hash_flag{$var} == 0) {
	
	    my $s = '$' . $var;
	    $hash_flag{$var} = 1;
	    return $s;

	} else {
	
	    my $s = '$'. $var;
	    return $s;	
		
	}
    }

}


sub translate_expression_aid {

    ##translate each part in expressions

    my $expression = $_[0];

    $expression =~ s/^\s*//;

    @lst = split //, $expression;

    my @result = ();

    my $s = "";

    my $size = @lst;

    my $i = 0;

    $double_quote_flag = 0;
    $single_quote_flag = 0;

    while($i < $size) {
    
        if($lst[$i] =~ /^[\w\\\.,]$/) { 
        
        
            $s .= $lst[$i];
            $i++;
    
        } elsif($lst[$i] =~ /^\s*$/) {
        
            if($double_quote_flag == 1 or $single_quote_flag == 1) {
            
                $s .= $lst[$i];
                $i++;
            
            } else{
                push @result, $s;
                $s = "";
                $i++;
            }
        } elsif($lst[$i] =~ /^[\+|\-|\*\*|\/\/|\%|\*|\||\^|&|<<|>>|~|<=|>=|<|>|!=|==|=|\/|!|\(|\)|\[|\]]$/) {
    
        

            if($double_quote_flag == 1 or $single_quote_flag == 1) {
            
                $s .= $lst[$i];
                $i++;
        
            } else{
                
                if($i + 1 < $size and $lst[$i + 1] =~ /^[\+|\-|\*\*|\/\/|\%|\*|\||\^|&|<<|>>|~|<=|>=|<|>|!=|==|=|\/|!|\(|\)|\]|\[]$/) {

                    push @result, $s;
                    $s = "";
                    $s .= $lst[$i];
                    $s .= $lst[$i+1];
                    push @result, $s;
                    $s = "";
                    $i = $i + 2;
                
                } else {
                    push @result, $s;
                    push @result, $lst[$i];
                    $s = "";
                    $i++;
       
                }
            
            }
        } elsif($lst[$i] =~ /^"$/) {


	    if($single_quote_flag == 1) {
	
	        $s .= $lst[$i];
	        $i++;
	
	    } elsif($double_quote_flag == 1) {

	        if($lst[$i - 1] eq "\\") {
      
		    $s .= $lst[$i];
		    $i++;

 	        } else {

		    $s .= $lst[$i];
		    push @result, $s;
		    $s = "";
		    $i++;
		    $double_quote_flag = 0;

	        }

    	    } else {

	        $double_quote_flag = 1;
	        $s .= $lst[$i];
	        $i++;
	    }

        } elsif($lst[$i] =~ /^'$/) {
	
	    if($double_quote_flag == 1) {

	        $s .= $lst[$i];
	        $i++;	
	
	    } elsif($single_quote_flag == 1) {

	        if($lst[$i - 1] eq "\\") {

		    $s .= $lst[$i];
		    $i++;	

	        } else {

   		    $s .= $lst[$i];
		    push @result, $s;
		    $s = "";
		    $i++;
		    $single_quote_flag = 0;

	        }	
	
	    } else {


	        $single_quote_flag = 1;
	        $s .= $lst[$i];
	        $i++;
		    	
	    }


        }
    
        else {
    
            $i++;
        }
    

    }

    push @result, $s;

    @final = ();
    foreach my $exp(@result) {

        if($exp !~ /^\s*$/) {

	    push @final, $exp;

        }

    }

    return @final;

}



sub translate_expression {

    ##translate expression with the aid above, 
  

    my $expression = $_[0];
    my @w = translate_expression_aid($expression);

    my $size = @w;

    ##get array variable

    foreach my $i (0..$size - 1) {
	if(exists($array_flag{$w[$i]}) and $array_flag{$w[$i]} == 1 and $i + 1 < $size and $w[$i + 1] eq '[') {
		$array_flag{$w[$i]} = 0;

        }

	if(exists($hash_flag{$w[$i]}) and $hash_flag{$w[$i]} == 1 and $i + 1 < $size and $w[$i + 1] eq '[') {
		$hash_flag{$w[$i]} = 0;
		$w[$i + 1] = '{';
		my $n = $i;
		while($n < $size) {
		
		    if($w[$n] eq ']') {
		
			$w[$n] = '}';
			last;
		    }
		    $n++;
		}
        }
	
    }



    ##get string variable

    my $j = 0;
    while($j < $size) {

	if($j + 1 < $size and $w[$j] =~ /^\s*[\+]?=\s*$/ and $w[$j + 1] =~ /^\s*["'].*[."]\s*$/) {
	    $str_flag{$w[$j - 1]} = 1;
	
	} elsif($j + 1 < $size and $w[$j] =~ /^\s*[\+]?=\s*$/ and $str_flag{$w[$j + 1]}){

	    $str_flag{$w[$j - 1]} = 1;	

	}
	$j++;

    }


    ###translate concatenations operator

    $j = 0;
    while($j < $size) {

	if($j + 1 < $size and $w[$j] =~ /^\s*\+=\s*$/ and $w[$j + 1] =~ /^\s*["'].*["']\s*$/) {
	
	    $w[$j] = '++++';

	} elsif($j + 1 < $size and $w[$j] =~ /^\s*\+=\s*$/ and $str_flag{$w[$j + 1]}) {

	    $w[$j] = '++++';

	}
	$j++;
    }



    $j = 0;
    while($j < $size) {

	if($j - 1 >= 0 and $w[$j - 1] =~ /^\s*["'].*["']\s*$/ and $j + 1 < $size and $w[$j + 1] =~ /^\s*["'].*["']\s*$/ and $w[$j] =~ /^\s*\+\s*$/) {
	
	    $w[$j] = '+++';

	} elsif($j - 1 >= 0 and exists($str_flag{$w[$j - 1]}) and $j + 1 < $size and exists($str_flag{$w[$j + 1]}) and $w[$j] =~ /^\s*\+\s*$/) {

	    $w[$j] = '+++';
	
	}

	$j++;
    }



    ##get pop, append, len, sorted with parentheses

    my $i = 0;
    while($i < $size) {

        if($w[$i] =~ /^\s*[\S]*\.pop\s*$/ or $w[$i] =~ /^\s*[\S]*\.append\s*$/ or $w[$i] =~ /^\s*len\s*$/ or $w[$i] =~ /^\s*sorted\s*$/) {
    
            my $n = $i;
            while($n < $size) {
                if($w[$n] eq '()' or $w[$n] =~ /\)/) {
                    last;
                }    
                $n++;
            }
            my $new_element = $w[$i];
            foreach my $j($i+1..$n) {
                $new_element .= $w[$j];
                $w[$j] = "";
            }

            $w[$i] = $new_element;

            $i = $n;
        } else {
        
            $i++;
    
        }
    }



    my $result = "";

    foreach my $r (@w) {
    
        $result .= translate_single($r);

    }
    return $result;
}


sub translate_print {

    my $newline_flag = 1;
    my $last_char = "\n";

    ##translate print statement.

    my $print_statement = $_[0];
    
    $print_statement =~ s/print//;
    $print_statement =~ s/^\(//g;
    $print_statement =~ s/\)$//g;


    if($print_statement eq ""){
    
        my $s = 'print "\n";';
        return $s;
    }

    $print_statement =~ s/\(/"\(/g;
    $print_statement =~ s/\)/"\)/g;
	
    ##split the print content, regarding the , as delimiter.
    my @split_list = parse_line(q{,}, 1, $print_statement);
 
    my $line_count = 0;
    my $line_nb = @split_list;
    my $result = "";
    my $seperator = ' ';
   
    foreach my $expre(@split_list) {

        $expre =~ s/^\s*//g;
        $expre =~ s/\s*$//g;

	$expre =~ s/"\(/\(/g;
	$expre =~ s/"\)/\)/g;

	##get separator, default is ' '

	if($expre =~ /^\s*sep\s*=\s*['"](.*)['"]\s*$/) {
	    $seperator = $1;	
	}

    }

    ##translate each part in print, separated by ','

    foreach my $expre(@split_list) {
                   
        $expre =~ s/^\s*//g;
        $expre =~ s/\s*$//g;

        
        if($expre =~ /^['"].*['"]$/) {

	    ##if it's string with quotes, print directly
 
            $result .= $expre;
	    $result .= ", '$seperator', ";



        } elsif($expre =~ / *end=(.*)/) {
            
	    ##if end in print, get the last part to print

            $newline_flag = 0;
            $last_char = $1;

        } elsif($expre =~ /^["'].*["'] *% *.*$/) {

	    ##transte string format with %

            $result .= translate_string_format($expre);
            $result .= ", '$seperator', ";
        
	} elsif($expre =~ /^\s*sep *= *["'].*["']\s*$/) {

	    ;

	}
    
        else {

	    ##translate other expressions
            $result .= translate_expression($expre);
	    $result .= ", '$seperator', ";        
	
	}

    }
  
    ##deal with newline or not, if end appears in print statement

    if($newline_flag == 1) {
     
        $result =~ s/, *'$seperator', *$//g;
        my $final_print = 'print ';
        $final_print .= $result;

        $final_print .= ', "\n";';

        return $final_print;

    } else {
        
	my $last_remove = ", '$seperator', ";

	$result =~ s/ *, *$//;
	$result =~ s/'$//;
	$result =~ s/\Q$seperator\E$//;
	$result =~ s/, *'$//;

        my $final_print = 'print ';
        $final_print .= $result;
        $final_print .= ", ";
        $final_print .= $last_char;
        $final_print .= ';';
        
        return $final_print

    }
  
}




sub translate_string_format {

    ##translate string format with %

    my $string = $_[0];

    $string =~ s/"\(/\(/g;
    $string =~ s/"\)/\)/g;

    my @split_list = parse_line(q{%}, 1, $string);

    my $part_1 = $split_list[0];
    my $part_2 = $split_list[1];

    $part_1 =~ s/^\s*//g;
    $part_1 =~ s/\s*$//g;

    $part_2 =~ s/[\(\)]//g;
    
    my @part_2_split = split /, */, $part_2;

    foreach $var(@part_2_split) {
        
        $var =~ s/^\s*//g;
        $var =~ s/\s*$//g;
    
        my $sub_var = translate_expression($var);

        $part_1 =~ s/%[a-zA-Z]+/$sub_var/;
    }


    return $part_1;

}




sub translate_statement {

    ##translate statements

    my $statement = $_[0];
   
    $statement =~ s/^\s*//;
    $statement =~ s/\s*$//;
    
    if($statement =~ /^#!\/usr\/bin\/python/) {
    
	##translate the first line

        print "#!/usr/bin/perl -w\n";
	print "no warnings 'numeric';\n";
    
    } elsif($statement =~ /^#/) {
    
	##translate comments

        print $statement;
        print "\n";

    } elsif($statement =~ /import/) {
    
	##translate import

        print "\n";
    

    } elsif($statement =~ /^\s*$/) {

	##translate empty line

        print "\n";

    } elsif($statement =~ /^print(.*)$/) {
        
        ##translate print statement

        print translate_print($statement);
        print "\n";

    } elsif($statement =~ /^while *(.*):(.+)/) {
    
        ##translate single line while

        translate_single_line_while($statement);

    } elsif($statement =~ /^if *(.*):(.+)/) {
    
	##translate single line if

        translate_single_line_if($statement);
     
    } elsif($statement =~ /^break$/) {
    
	##translate break

        print 'last;';
        print "\n";

    } elsif($statement =~ /^continue$/) {
    
	##translate continue

        print 'next;';
        print "\n";
    
    } elsif($statement =~ /^while *(.*):$/) {
    
	##translate while

        print 'while (';

        print translate_expression($1);
        print ') {';
        print "\n";
    
    } elsif($statement =~ /^if *(.*):$/) {
    
	##translate if

        print 'if (';
        print translate_expression($1);
        print ') {';
        print "\n";
    
    } elsif($statement =~ /^for *([\S]*) *in *range\((.*)\):$/) {
    
	##translate for in range

        print 'foreach $', $1;
        print '(';

        my @split_list = split /, */, $2;

        if(@split_list == 1) {
            
            print '0..';
            print translate_expression($split_list[0]), ' - 1) {', "\n";
       
        } else {
        
            my $range_arg_1 = $split_list[0];
            my $range_arg_2 = $split_list[1];

            $range_arg_1 =~ s/^\s*//;
            $range_arg_2 =~ s/\s*$//;
    
            print translate_expression($range_arg_1), '..';
            print translate_expression($range_arg_2), ' - 1) {';

            print "\n";
        }
       
    } elsif($statement =~ /^sys\.stdout\.write\((.*)\)$/) {
    
	##translate sys.stdout.write
    
        print 'print ';

	my $group_1 = $1;
	if ($1 =~ /^['"].*['"]$/){

	    print $group_1;
	
	} else {
            print translate_expression($1);
	}
        print ';', "\n";
    
    } elsif($statement =~ /^elif *(.*):$/) {
    
	##translate elif

        print 'elsif (';
        print translate_expression($1);
        print ') {';
        print "\n";
  
    } elsif($statement =~ /^else:$/) {
    
	##translate else

        print 'else {', "\n";
    
    } elsif($statement =~ /^([\S]*) *= *\[(.*)\]$/) {

	##translate list definition and initiation

    	print '@', $1, ' = (', $2, ');';
	print "\n";
	my $group_1 = $1;
	$group_1 =~ s/\s*$//;
	$array_flag{$group_1} = 1;    

    } elsif($statement =~ /^([\S]*) *= *{(.*)}$/) {

	##translate dictionary definition and initiation

	print '%', $1;
	my $group_1 = $1;
	my $group_2 = $2;
	$group_2 =~ s/:/,/g;
	print ' = (';
	print $group_2, ');';
	print "\n";
	$hash_flag{$group_1} = 1;


    } elsif($statement =~ /^for *([\S]*) *in *sys\.stdin:$/) {

	##translate for in sys.stdin

        print 'foreach $', $1, ' (<STDIN>) {', "\n";

    } elsif($statement =~ /^([\S]*) =* *sorted\((.*)\)$/) {

	##translate sorted

	$array_flag{$1} = 1;
	print translate_expression($statement);
        print ';'; 
        print "\n"; 

    }

    elsif($statement =~ /^([\S]*) *= *sys\.stdin\.readlines\(\)$/) {
    
	##translate sys.stdin.readlines

        print '@', $1, ' = <STDIN>;', "\n";
	$array_flag{$1} = 1;
    
    } elsif($statement =~ /^for *([\S]*) *in *([\S]*):$/) {
    
	##translate for () in ()

       if($2 eq 'sys.argv[1:]') {
       
           print 'foreach $', $1, ' (@';
           print 'ARGV) {';
       
        } elsif($2 eq 'fileinput.input()') {
            
           print 'while ($', $1, ' = <>) {';  
       
        } else {
           
           print 'foreach $', $1, ' (@';
           print $2, ') {';

        }
        print "\n";    
    
    } elsif($statement =~ /^([\S]*) *= *re\.sub\((.*)\)$/) {
    
	##translate re sub

        print '$', $1, ' =~ s/';
        my @split_list = split /,(?=(?:[^"']*["'][^"']*["'])*[^"']*$)/, $2;

        my $part_1 = $split_list[0];
        my $part_2 = $split_list[1];

        $part_1 =~ s/^\s*//;
        $part_1 =~ s/\s*$//;
        $part_2 =~ s/^\s*//;
        $part_2 =~ s/\s*$//;

        $part_1 =~ s/r//;
        $part_1 =~ s/'//g;
        $part_2 =~ s/'//g;


        print $part_1, '/';

        
        if($part_2 eq "") {
        
            print '/g;';
        
        } else{
           
            print $part_2, '/g;';
        
        }
        print "\n";
    
    } 
    
   
    else {
	
	##translate expressions,not matched above

        print translate_expression($statement);
        print ';'; 
        print "\n";   
    }

}




sub translate_single_line_while {
    
    my $single_line = $_[0];

    $single_line =~ /^while *(.*):(.+)$/;

    print 'while (';
    print translate_expression($1);
    print ') {';

    print "\n";

    my @split_list = split /;(?=(?:[^"']*["'][^"']*["'])*[^"']*$)/, $2;

    foreach $state(@split_list) {
    
        print '    ';

        $state =~ s/^\s*//;
        $state =~ s/\s*$//;
        
        translate_statement($state);
      
    }

    print '}';
    print "\n";

}


sub translate_single_line_if {

    my $single_line = $_[0];

    $single_line =~ /^if *(.*):(.+)$/;

    print 'if (';
    print translate_expression($1);
    print ') {';
    print "\n";

    my @split_list = split /;(?=(?:[^"']*["'][^"']*["'])*[^"']*$)/, $2;

    foreach $state(@split_list) {
    
        print '    ';

        $state =~ s/^\s*//;
        $state =~ s/\s*$//;

        translate_statement($state);
    
    }

    print '}';
    print "\n";

}



sub translate_indent_and_curly_brackets {

    ##translate indent and curly brackets

    my $line = $_[0];
    my $last_indent = $_[1];
    my $current_line = $_[2];
    my $nb_of_lines = $_[3];

    $line =~ /^(\s*)/;

    my $current_indent = "$1";
    my $current_line_indent = length($1);

    my @temp_list1 = ();

    if($current_line_indent < $last_indent) {

	my @line_nb = keys %visited;
	
	foreach my $n1 (@line_nb){
	    if($n1 < $current_line) {
	        if($visited{$n1} == 0){
		    push @temp_list1, [$n1, $indentation{$n1}[0], $indentation{$n1}[1]];
	        }	
	    }
	}

    
	@temp_list1 = sort {$a->[1] <=> $b->[1]} @temp_list1;

	@temp_list1 = reverse @temp_list1;

	my $size = @temp_list1;

	foreach my $k(0..$size - 1) {
	    if ($temp_list1[$k][1] > $current_line_indent) {
		
		print " " x $temp_list1[$k][2];
		print '}';
		print "\n";
		$visited{$temp_list1[$k][0]} = 1;		

	    }	
	}
		
	print $current_indent;	

    } else {
    
        print $current_indent;

    }

}



@lines = <>;
$n = 0;
$nb_of_lines = @lines;

%indentation = ();
%visited = ();

foreach $line(@lines) {

    ##first deal with indent and brackets

    if($line =~ /^\s*while *.*:$/ or $line =~ /^\s*for *(.*) *in *range\(.*\):$/ or $line =~ /^\s*if.*:$/ or $line =~ /^\s*elif.*:$/ or $line =~ /^\s*else:$/ or $line =~ /^\s*for *(.*) *in *(.*):$/) {

	$line =~ /^(\s*)/;
	my $current_indent = length($1);
	
	my $j = $n;
	my $next_line = "";
	while($j <= $nb_of_lines) {
	    $next_line = $lines[$j + 1];
            if($next_line =~ /^\s*$/) {
	    	$j++;
                next;
      	    } else {
            	last;
	    }
	}

	$next_line =~ /^(\s*)/;
	my $next_indent = $1;
	my $next_indent_length = length($1);
	
	push @{$indentation{$n}}, $next_indent_length;
	push @{$indentation{$n}}, $current_indent;
	$visited{$n} = 0;

    }


    if($n == 0) {
    
        translate_indent_and_curly_brackets($line, 0, $n, $nb_of_lines);
        $n++;
    
    } else {
    
        my $last_line = $lines[$n - 1];
        
        $last_line =~ /^(\s*)/;
        
        my $last_indent = length($1); 
    
        if($last_line =~ /^\s*$/) {
        
            $last_indent = 0;

        }

        translate_indent_and_curly_brackets($line, $last_indent, $n, $nb_of_lines);
        $n++;
    }

    ###translate statement

    translate_statement($line);

    ##if last line, deal with left curly brackets and indent

    if($n == $nb_of_lines) {
	
	my @temp_list1 = ();
	my @line_nb = keys %visited;
	foreach my $n1 (@line_nb){
	    if($n1 < $n) {
	        if($visited{$n1} == 0){
		    push @temp_list1, [$n1, $indentation{$n1}[0], $indentation{$n1}[1]];
	        }	
	    }
	}

    
	@temp_list1 = sort {$a->[1] <=> $b->[1]} @temp_list1;

	@temp_list1 = reverse @temp_list1;

	my $size = @temp_list1;

	foreach my $k(0..$size - 1) {
	    
	    print " " x $temp_list1[$k][2];
	    print '}';
	    print "\n";
	    $visited{$temp_list1[$k][0]} = 1;	
	    	
	}
	
    }

}

