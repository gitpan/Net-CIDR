# Net::CIDR
#
# Copyright 2001 Sam Varshavchik.
#
# with contributions from David Cantrell.
#
# This program is free software; you can redistribute it
# and/or modify it under the same terms as Perl itself.
#
# $Revision: 1.11 $

package Net::CIDR;

require 5.000;
#use strict;
#use warnings;

require Exporter;
# use AutoLoader qw(AUTOLOAD);
use Carp;

use Math::BigInt;

@ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Net::CIDR ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
%EXPORT_TAGS = ( 'all' => [ qw( range2cidr
				    cidr2range
				    cidr2octets
				    cidradd
				    cidrlookup
				    cidrvalidate
				    addr2cidr
				    ) ] );

@EXPORT_OK = ( qw( range2cidr
		       cidr2range
		       cidr2octets
		       cidradd
		       cidrlookup
		       cidrvalidate
		       addr2cidr
		       ));

@EXPORT = qw(
	
);

$VERSION = "0.04";

1;


=pod

=head1 NAME

Net::CIDR - Manipulate IPv4/IPv6 netblocks in CIDR notation

=head1 SYNOPSIS

    use Net::CIDR;

    use Net::CIDR ':all';

    print join("\n",
          Net::CIDR::range2cidr("192.68.0.0-192.68.255.255",
		                "10.0.0.0-10.3.255.255"))
	       . "\n";
    #
    # Output from above:
    #
    # 192.68.0.0/16
    # 10.0.0.0/14

    print join("\n",
          Net::CIDR::range2cidr(
		"dead:beef::-dead:beef:ffff:ffff:ffff:ffff:ffff:ffff"))
               . "\n";

    #
    # Output from above:
    #
    # dead:beef::/32

    print join("\n",
	     Net::CIDR::range2cidr("192.68.1.0-192.68.2.255"))
                  . "\n";
    #
    # Output from above:
    #
    # 192.68.1.0/24
    # 192.68.2.0/24

    print join("\n", Net::CIDR::cidr2range("192.68.0.0/16")) . "\n";
    #
    # Output from above:
    #
    # 192.68.0.0-192.68.255.255

    print join("\n", Net::CIDR::cidr2range("dead::beef::/46")) . "\n";
    #
    # Output from above:
    #
    # dead:beef::-dead:beef:3:ffff:ffff:ffff:ffff:ffff

    @list=("192.68.0.0/24");
    @list=Net::CIDR::cidradd("192.68.1.0-192.68.1.255", @list);

    print join("\n", @list) . "\n";
    #
    # Output from above:
    #
    # 192.68.0.0/23

    print join("\n", Net::CIDR::cidr2octets("192.68.0.0/22")) . "\n";
    #
    # Output from above:
    #
    # 192.68.0
    # 192.68.1
    # 192.68.2
    # 192.68.3

    print join("\n", Net::CIDR::cidr2octets("dead::beef::/46")) . "\n";
    #
    # Output from above:
    #
    # dead:beef:0000
    # dead:beef:0001
    # dead:beef:0002
    # dead:beef:0003

    @list=("192.68.0.0/24");
    print Net::CIDR::cidrlookup("192.68.0.12", @list);
    #
    # Output from above:
    #
    # 1

    @list = Net::CIDR::addr2cidr("192.68.0.31");
    print join("\n", @list);
    #
    # Output from above:
    #
    # 192.68.0.31/32
    # 192.68.0.30/31
    # 192.68.0.28/30
    # 192.68.0.24/29
    # 192.68.0.16/28
    # 192.68.0.0/27
    # 192.68.0.0/26
    # 192.68.0.0/25
    # 192.68.0.0/24
    # 192.68.0.0/23
    # [and so on]

=head1 DESCRIPTION

The Net::CIDR package contains functions that manipulate lists of IP
netblocks expressed in CIDR notation.
The Net::CIDR functions handle both IPv4 and IPv6 addresses.

=head2 @cidr_list=Net::CIDR::range2cidr(@range_list);

Each element in the @range_list is a string "start-finish", where
"start" is the first IP address and "finish" is the last IP address.
range2cidr() converts each range into an equivalent CIDR netblock.
It returns a list of netblocks except in the case where it is given
only one parameter and is called in scalar context.

For example:

    @a=Net::CIDR::range2cidr("192.68.0.0-192.68.255.255");

The result is a one-element array, with $a[0] being "192.68.0.0/16".
range2cidr() processes each "start-finish" element in @range_list separately.
But if invoked like so:

    $a=Net::CIDR::range2cidr("192.68.0.0-192.68.255.255");

The result is a scalar "192.68.0.0/16".

Where each element cannot be expressed as a single CIDR netblock
range2cidr() will generate as many CIDR netblocks as are necessary to cover
the full range of IP addresses.  Example:

    @a=Net::CIDR::range2cidr("192.68.1.0-192.68.2.255");

The result is a two element array: ("192.68.1.0/24","192.68.2.0/24");

    @a=Net::CIDR::range2cidr(
		   "d08c:43::-d08c:43:ffff:ffff:ffff:ffff:ffff:ffff");

The result is an one element array: ("d08c:43::/32") that reflects this
IPv6 netblock in CIDR notation.

range2cidr() does not merge adjacent or overlapping netblocks in
@range_list.

=head2 @range_list=Net::CIDR::cidr2range(@cidr_list);

The cidr2range() functions converts a netblock list in CIDR notation
to a list of "start-finish" IP address ranges:

    @a=Net::CIDR::cidr2range("10.0.0.0/14", "192.68.0.0/24");

The result is a two-element array: 
("10.0.0.0-10.3.255.255", "192.68.0.0-192.68.0.255").

    @a=Net::CIDR::cidr2range("d08c:43::/32");

The result is a one-element array:
("d08c:43::-d08c:43:ffff:ffff:ffff:ffff:ffff:ffff").

cidr2range() does not merge adjacent or overlapping netblocks in
@cidr_list.

=head2 @netblock_list = Net::CIDR::addr2cidr($address);

The addr2cidr function takes an IP address and returns a list of all
the CIDR netblocks it might belong to:

    @a=Net::CIDR::addr2range('192.68.0.31');

The result is a thirtythree-element array:
('192.68.0.31/32', '192.68.0.30/31', '192.68.0.28/30', '192.68.0.24/29',
 [and so on])
consisting of all the possible subnets containing this address from
0.0.0.0/0 to address/32.

Any addresses supplied to addr2range after the first will be ignored.
It works similarly for IPv6 addresses, returning a list of one hundred
and twenty nine elements.

=cut

# CIDR to start-finish

sub cidr2range {
    my @cidr=@_;

    my @r;

    while ($#cidr >= 0)
    {
	my $cidr=shift @cidr;

	$cidr =~ s/\s//g;

	unless ($cidr =~ /(.*)\/(.*)/)
	{
	    push @r, $cidr;
	    next;
	}

	my ($ip, $pfix)=($1, $2);

	my $isipv6;
	($isipv6, $ip)=_ipv6to4($ip);

	my @ips= split (/\.+/, $ip);

	grep {
	    croak unless $_ >= 0 && $_ <= 255 && $_ =~ /^[0-9]+$/;
	} @ips;

	croak unless $pfix >= 0 && $pfix <= ($#ips+1) * 8 && $pfix =~ /^[0-9]+$/;

	my @rr=_cidr2iprange($pfix, @ips);

	while ($#rr >= 0)
	{
	    my $a=shift @rr;
	    my $b=shift @rr;

	    $a =~ s/\.$//;
	    $b =~ s/\.$//;

	    if ($isipv6)
	    {
		$a=_ipv4to6($a);
		$b=_ipv4to6($b);
	    }

	    push @r, "$a-$b";
	}
    }

    return @r;
}

#
# If the input is an IPv6-formatted address, convert it to an IPv4 decimal
# format, since the other functions know how to deal with it.  The hexadecimal
# IPv6 address is represented in dotted-decimal form, like IPv4.
#

sub _ipv6to4 {
    my $ipv6=shift;

    return (undef, $ipv6) unless $ipv6 =~ /:/;

    croak "Syntax error: $ipv6"
	unless $ipv6 =~ /^[a-fA-F0-9:\.]+$/;

    my $ip4_suffix="";

    ($ipv6, $ip4_suffix)=($1, $2)
	if $ipv6 =~ /^(.*:)([0-9]+\.[0-9\.]+)$/;

    $ipv6 =~ s/([a-fA-F0-9]+)/_h62d($1)/ge;

    my $ipv6_suffix="";

    if ($ipv6 =~ /(.*)::(.*)/)
    {
	($ipv6, $ipv6_suffix)=($1, $2);
	$ipv6_suffix .= ".$ip4_suffix";
    }
    else
    {
	$ipv6 .= ".$ip4_suffix";
    }

    my @p=grep (/./, split (/[^0-9]+/, $ipv6));

    my @s=grep (/./, split (/[^0-9]+/, $ipv6_suffix));

    push @p, 0 while $#p + $#s < 14;

    my $n=join(".", @p, @s);

#    return (undef, $1)
#	if $n =~ /^0\.0\.0\.0\.0\.0\.0\.0\.0\.0\.255\.255\.(.*)$/;

    return (1, $n);
}

# Let's go the other way around

sub _ipv4to6 {
    my @octets=split(/[^0-9]+/, shift);

    croak "Internal error in _ipv4to6"
	unless $#octets == 15;

    my @dummy=@octets;

    return ("::ffff:" . join(".", $octets[12], $octets[13], $octets[14], $octets[15]))
	if join(".", splice(@dummy, 0, 12)) eq "0.0.0.0.0.0.0.0.0.0.255.255";

    my @words;

    my $i;

    for ($i=0; $i < 8; $i++)
    {
	$words[$i]=sprintf("%x", $octets[$i*2] * 256 + $octets[$i*2+1]);
    }

    my $ind= -1;
    my $indlen= -1;

    for ($i=0; $i < 8; $i++)
    {
	next unless $words[$i] eq "0";

	my $j;

	for ($j=$i; $j < 8; $j++)
	{
	    last if $words[$j] ne "0";
	}

	if ($j - $i > $indlen)
	{
	    $indlen= $j-$i;
	    $ind=$i;
	    $i=$j-1;
	}
    }

    return "::" if $indlen == 8;

    return join(":", @words) if $ind < 0;

    my @s=splice (@words, $ind+$indlen);

    return join(":", splice (@words, 0, $ind)) . "::"
	. join(":", @s);
}
    
sub _h62d {
    my $h=shift;

    $h=hex("0x$h");

    return ( int($h / 256) . "." . ($h % 256));
}

sub _cidr2iprange {
    my @ips=@_;
    my $pfix=shift @ips;

    if ($pfix == 0)
    {
	grep { $_=0 } @ips;

	my @ips2=@ips;

	grep { $_=255 } @ips2;

	return ( join(".", @ips), join(".", @ips2));
    }

    if ($pfix >= 8)
    {
	my $octet=shift @ips;

	@ips=_cidr2iprange($pfix - 8, @ips);

	grep { $_="$octet.$_"; } @ips;
	return @ips;
    }

    my $octet=shift @ips;

    grep { $_=0 } @ips;

    my @ips2=@ips;

    grep { $_=255 } @ips2;

    my @r= _cidr2range8(($octet, $pfix));

    $r[0] = join (".", ($r[0], @ips));
    $r[1] = join (".", ($r[1], @ips2));

    return @r;
}

#
# ADDRESS to list of CIDR netblocks
#

sub addr2cidr {
	my(@blocks, $address, $bitmask, $net, $octetstash) = ();
	my($isIPv6, $addr) = _ipv6to4(shift);
	my $bitsInAddress = ($isIPv6)?128:32;

	# create BigInts if necessary.  Straight assignment of ints to
	# BigInts breaks BigInt-ness hence the bizarre subtractions later.
	if($isIPv6) {
		$address = new Math::BigInt 0;
		$bitmask = new Math::BigInt 0;
		$net = new Math::BigInt 0;
		$octetstash = new Math::BigInt 0;
	} else { ($address, $bitmask, $net, $octetstash) = 0; }

	# convert dotted-octets into an int (or BigInt)
	do { $address = $address << 8; $address = $address + $_ }
		for split(/\./, $addr);

	foreach my $bits (reverse 0..$bitsInAddress) {
		$octetstash = $octetstash - $octetstash + 255;
		$bitmask = $bitmask - $bitmask;
		for(1 .. $bits) { $bitmask = ($bitmask << 1) + 1; }
		$bitmask = $bitmask << ($bitsInAddress - $bits);
		
		$net = $address & $bitmask;
		push @blocks, (map { $_ =~ s/\+//; (($isIPv6)?_ipv4to6($_):$_) }
		    join('.', reverse map {
			my $temp = ($octetstash & $net) >> ($_ * 8);
			$octetstash = $octetstash << 8;
			$temp;
		    } (0 .. $bitsInAddress / 8 - 1)
		))[0]."/$bits";
	}
	return @blocks;
}

#
# START-FINISH to CIDR list
#

sub range2cidr {
    my @r=@_;

    my $i;

    my @c;

    for ($i=0; $i <= $#r; $i++)
    {
	$r[$i] =~ s/\s//g;

	if ($r[$i] =~ /\//)
	{
	    push @c, $r[$i];
	    next;
	}

	$r[$i]="$r[$i]-$r[$i]" unless $r[$i] =~ /(.*)-(.*)/;

	$r[$i] =~ /(.*)-(.*)/;

	my ($a,$b)=($1,$2);

	my $isipv6_1;
	my $isipv6_2;

	($isipv6_1, $a)=_ipv6to4($a);
	($isipv6_2, $b)=_ipv6to4($b);

	if ($isipv6_1 || $isipv6_2)
	{
	    croak "Invalid netblock range: $r[$i]"
		unless $isipv6_1 && $isipv6_2;
	}

	my @a=split(/\.+/, $a);
	my @b=split(/\.+/, $b);

	croak unless $#a == $#b;

	my @cc=_range2cidr(\@a, \@b);

	while ($#cc >= 0)
	{
	    $a=shift @cc;
	    $b=shift @cc;

	    $a=_ipv4to6($a) if $isipv6_1;

	    push @c, "$a/$b";
	}
    }
    return @c unless(1==@r && 1==@c && !wantarray());
    return $c[0];
}

sub _range2cidr {
    my $a=shift;
    my $b=shift;

    my @a=@$a;
    my @b=@$b;

    $a=shift @a;
    $b=shift @b;

    return _range2cidr8($a, $b) if $#a < 0; # Least significant octet pair.

    croak unless $a >= 0 && $a <= 255 && $a =~ /^[0-9]+$/;
    croak unless $b >= 0 && $b <= 255 && $b =~ /^[0-9]+$/ && $b >= $a;

    my @c;

    if ($a == $b) # Same start/end octet
    {
	my @cc= _range2cidr(\@a, \@b);

	while ($#cc >= 0)
	{
	    my $c=shift @cc;

	    push @c, "$a.$c";

	    $c=shift @cc;
	    push @c, $c+8;
	}
	return @c;
    }

    my $start0=1;
    my $end255=1;

    grep { $start0=0 unless $_ == 0; } @a;
    grep { $end255=0 unless $_ == 255; } @b;

    if ( ! $start0 )
    {
	my @bcopy=@b;

	grep { $_=255 } @bcopy;

	my @cc= _range2cidr(\@a, \@bcopy);

	while ($#cc >= 0)
	{
	    my $c=shift @cc;

	    push @c, "$a.$c";

	    $c=shift @cc;
	    push @c, $c + 8;
	}

	++$a;
    }

    if ( ! $end255 )
    {
	my @acopy=@a;

	grep { $_=0 } @acopy;

	my @cc= _range2cidr(\@acopy, \@b);

	while ($#cc >= 0)
	{
	    my $c=shift @cc;

	    push @c, "$b.$c";

	    $c=shift @cc;
	    push @c, $c + 8;
	}

	--$b;
    }

    if ($a <= $b)
    {
	grep { $_=0 } @a;

	my $pfix=join(".", @a);

	my @cc= _range2cidr8($a, $b);

	while ($#cc >= 0)
	{
	    my $c=shift @cc;

	    push @c, "$c.$pfix";

	    $c=shift @cc;
	    push @c, $c;
	}
    }
    return @c;
}

sub _range2cidr8 {

    my @c;

    my @r=@_;

    while ($#r >= 0)
    {
	my $a=shift @r;
	my $b=shift @r;

	croak unless $a >= 0 && $a <= 255 && $a =~ /^[0-9]+$/;
	croak unless $b >= 0 && $b <= 255 && $b =~ /^[0-9]+$/ && $b >= $a;

	++$b;

	while ($a < $b)
	{
	    my $i=0;
	    my $n=1;

	    while ( ($n & $a) == 0)
	    {
		++$i;
		$n <<= 1;
		last if $i >= 8;
	    }

	    while ($i && $n + $a > $b)
	    {
		--$i;
		$n >>= 1;
	    }

	    push @c, $a;
	    push @c, 8-$i;

	    $a += $n;
	}
    }

    return @c;
}

sub _cidr2range8 {

    my @c=@_;

    my @r;

    while ($#c >= 0)
    {
	my $a=shift @c;
	my $b=shift @c;

	croak unless $a >= 0 && $a <= 255 && $a =~ /^[0-9]+$/;
	croak unless $b >= 0 && $b <= 8 && $b =~ /^[0-9]+$/;

	my $n= 1 << (8-$b);

	$a &= ($n-1) ^ 255;

	push @r, $a;
	push @r, $a + ($n-1);
    }
    return @r;
}

sub _ipcmp {
    my $aa=shift;
    my $bb=shift;

    my $isipv6_1;
    my $isipv6_2;

    ($isipv6_1, $aa)=_ipv6to4($aa);
    ($isipv6_2, $bb)=_ipv6to4($bb);

    if ($isipv6_1 || $isipv6_2)
    {
	croak "Invalid netblock: $aa-$bb"
	    unless $isipv6_1 && $isipv6_2;
    }

    my @a=split (/\./, $aa);
    my @b=split (/\./, $bb);

    croak unless $#a == $#b;

    while ($#a >= 0 && $a[0] == $b[0])
    {
	shift @a;
	shift @b;
    }

    return 0 if $#a < 0;

    return $a[0] <=> $b[0];
}


=pod

=head2 @octet_list=Net::CIDR::cidr2octets(@cidr_list);

cidr2octets() takes @cidr_list and returns a list of leading octets
representing those netblocks.  Example:

    @octet_list=Net::CIDR::cidr2octets("10.0.0.0/14", "192.68.0.0/24");

The result is the following five-element array:
("10.0", "10.1", "10.2", "10.3", "192.68.0").

For IPv6 addresses, the hexadecimal words in the resulting list are
zero-padded:

    @octet_list=Net::CIDR::cidr2octets("::dead:beef:0:0/110");

The result is a four-element array:
("0000:0000:0000:0000:dead:beef:0000",
"0000:0000:0000:0000:dead:beef:0001",
"0000:0000:0000:0000:dead:beef:0002",
"0000:0000:0000:0000:dead:beef:0003").
Prefixes of IPv6 CIDR blocks should be even multiples of 16 bits, otherwise
they can potentially expand out to a 32,768-element array, each!

=cut

sub cidr2octets {
    my @cidr=@_;

    my @r;

    while ($#cidr >= 0)
    {
	my $cidr=shift @cidr;

	$cidr =~ s/\s//g;

	croak unless ($cidr =~ /(.*)\/(.*)/);

	my ($ip, $pfix)=($1, $2);

	my $isipv6;

	($isipv6, $ip)=_ipv6to4($ip);

	my @ips= split (/\.+/, $ip);

	grep {
	    croak unless $_ >= 0 && $_ <= 255 && $_ =~ /^[0-9]+$/;
	} @ips;

	croak unless $pfix >= 0 && $pfix <= ($#ips+1) * 8 && $pfix =~ /^[0-9]+$/;

	my $i;

	for ($i=0; $i <= $#ips; $i++)
	{
	    last if $pfix - $i * 8 < 8;
	}

	my @msb=splice @ips, 0, $i;

	my $bitsleft= $pfix - $i * 8;

	if ($#ips < 0 || $bitsleft == 0)
	{
	    if ($isipv6)
	    {
		_push_ipv6_octets(\@r, \@msb);
	    }
	    else
	    {
		push @r, join(".", @msb);
	    }
	    next;
	}

	my @rr=_cidr2range8(($ips[0], $bitsleft));

	while ($#rr >= 0)
	{
	    my $a=shift @rr;
	    my $b=shift @rr;

	    grep {
		if ($isipv6)
		{
		    push @msb, $_;
		    _push_ipv6_octets(\@r, \@msb);
		    pop @msb;
		}
		else
		{
		    push @r, join(".", (@msb, $_));
		}
	    } ($a .. $b);
	}
    }

    return @r;
}

sub _push_ipv6_octets {
    my $ary_ref=shift;
    my $octets=shift;

    if ( ($#{$octets} % 2) == 0)	# Odd number of octets
    {
	foreach (0 .. 255)
	{
	    push @$octets, $_;
	    _push_ipv6_octets($ary_ref, $octets);
	    pop @$octets;
	}
	return;
    }

    my $i;
    my $s="";

    for ($i=0; $i <= $#{$octets}; $i += 2)
    {
	$s .= ":" if $s ne "";
	$s .= sprintf("%02x%02x", $$octets[$i], $$octets[$i+1]);
    }
    push @$ary_ref, $s;
}

=pod

=head2 @cidr_list=Net::CIDR::cidradd($block, @cidr_list);

The cidradd() functions allows a CIDR list to be built one CIDR netblock
at a time, merging adjacent and overlapping ranges.
$block is a single netblock, expressed as either "start-finish", or
"address/prefix".
Example:

    @cidr_list=Net::CIDR::range2cidr("192.68.0.0-192.68.0.255");
    @cidr_list=Net::CIDR::cidradd("10.0.0.0/8", @cidr_list);
    @cidr_list=Net::CIDR::cidradd("192.68.1.0-192.68.1.255", @cidr_list);
				  
The result is a two-element array: ("10.0.0.0/8", "192.68.0.0/23").
IPv6 addresses are handled in an analogous fashion.

=cut

sub cidradd {
    my @cidr=@_;

    my $ip=shift @cidr;

    $ip="$ip-$ip" unless $ip =~ /[-\/]/;

    unshift @cidr, $ip;

    @cidr=cidr2range(@cidr);

    my @a;
    my @b;

    grep {
	croak unless /(.*)-(.*)/;
	push @a, $1;
	push @b, $2;
    } @cidr;

    my $lo=shift @a;
    my $hi=shift @b;

    my $i;

    for ($i=0; $i <= $#a; $i++)
    {
	last if _ipcmp($lo, $hi) > 0;

	next if _ipcmp($b[$i], $lo) < 0;
	next if _ipcmp($hi, $a[$i]) < 0;

	if (_ipcmp($a[$i],$lo) <= 0 && _ipcmp($hi, $b[$i]) <= 0)
	{
	    $lo=_add1($hi);
	    last;
	}

	if (_ipcmp($a[$i],$lo) <= 0)
	{
	    $lo=_add1($b[$i]);
	    next;
	}

	if (_ipcmp($hi, $b[$i]) <= 0)
	{
	    $hi=_sub1($a[$i]);
	    next;
	}

	$a[$i]=undef;
	$b[$i]=undef;
    }

    unless (_ipcmp($lo, $hi) > 0)
    {
	push @a, $lo;
	push @b, $hi;
    }

    @cidr=();

    @a=grep ( (defined $_), @a);
    @b=grep ( (defined $_), @b);

    for ($i=0; $i <= $#a; $i++)
    {
	push @cidr, "$a[$i]-$b[$i]";
    }

    @cidr=sort {
	$a =~ /(.*)-/;

	my $c=$1;

	$b =~ /(.*)-/;

	my $d=$1;

	my $e=_ipcmp($c, $d);
	return $e;
    } @cidr;

    $i=0;

    while ($i < $#cidr)
    {
	$cidr[$i] =~ /(.*)-(.*)/;

	my ($k, $l)=($1, $2);

	$cidr[$i+1] =~ /(.*)-(.*)/;

	my ($m, $n)=($1, $2);

	if (_ipcmp( _add1($l), $m) == 0)
	{
	    splice @cidr, $i, 2, "$k-$n";
	    next;
	}
	++$i;
    }

    return range2cidr(@cidr);
}


sub _add1 {
    my $n=shift;

    my $isipv6;

    ($isipv6, $n)=_ipv6to4($n);

    my @ip=split(/\./, $n);

    my $i=$#ip;

    while ($i >= 0)
    {
	last if ++$ip[$i] < 256;
	$ip[$i]=0;
	--$i;
    }

    return undef if $i < 0;

    $i=join(".", @ip);
    $i=_ipv4to6($i) if $isipv6;
    return $i;

}

sub _sub1 {
    my $n=shift;

    my $isipv6;

    ($isipv6, $n)=_ipv6to4($n);

    my @ip=split(/\./, $n);

    my $i=$#ip;

    while ($i >= 0)
    {
	last if --$ip[$i] >= 0;
	$ip[$i]=255;
	--$i;
    }

    return undef if $i < 0;

    $i=join(".", @ip);
    $i=_ipv4to6($i) if $isipv6;
    return $i;
}

=pod

=head2 $found=Net::CIDR::cidrlookup($ip, @cidr_list);

Search for $ip in @cidr_list.  $ip can be a single IP address, or a
netblock in CIDR or start-finish notation.
lookup() returns 1 if $ip overlaps any netblock in @cidr_list, 0 if not.

=cut

sub cidrlookup {
    my @cidr=@_;

    my $ip=shift @cidr;

    $ip="$ip-$ip" unless $ip =~ /[-\/]/;

    unshift @cidr, $ip;

    @cidr=cidr2range(@cidr);

    my @a;
    my @b;

    grep {
	croak unless /(.*)-(.*)/;
	push @a, $1;
	push @b, $2;
    } @cidr;

    my $lo=shift @a;
    my $hi=shift @b;

    my $i;

    for ($i=0; $i <= $#a; $i++)
    {
	next if _ipcmp($b[$i], $lo) < 0;
	next if _ipcmp($hi, $a[$i]) < 0;
	return 1;
    }

    return 0;
}

=pod

=head2 $ip=Net::CIDR::cidrvalidate($ip);

Validate whether $ip is a valid IPv4 or IPv6 address.
Returns its argument or undef.
Spaces are removed, and IPv6 hexadecimal address are converted to lowercase.

=cut

sub cidrvalidate {
    my $v=shift;

    $v =~ s/\s//g;

    $v=lc($v);

    if ($v =~ /^([0-9\.]+)$/ || $v =~ /^::ffff:([0-9\.]+)$/ ||
	$v =~ /^:([0-9\.]+)$/)
    {
	my $n=$1;

	return undef if $n =~ /^\./ || $n =~ /\.$/ || $n =~ /\.\./;

	my @o= split(/\./, $n);

	return undef if $#o != 3;

	foreach (@o)
	{
	    return if /^0/;
	    return if $_ < 0 || $_ > 255;
	}
	return $v;
    }

    return undef unless $v =~ /^[0-9a-f:]+$/;

    return undef if $v =~ /:::/ || $v =~ /^:[^:]/ || $v =~ /[^:]:$/
	|| $v =~ /::.*::/;

    my @o=grep (/./, split(/:/, $v));

    return undef if $#o >= 8;

    foreach (@o)
    {
	return undef if length ($_) > 4;
    }

    return $v;
}

=pod

=head1 BUGS

Garbage in, garbage out.
Always use validate() before doing anything with untrusted input.
Otherwise,
"slightly" invalid input will work (extraneous whitespace
is generally OK),
but the functions will croak if you're totally off the wall.

=head1 AUTHOR

Sam Varshavchik <sam@email-scan.com>

With some contributions from David Cantrell <david@cantrell.org.uk>

=cut

__END__
