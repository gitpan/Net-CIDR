#$Revision: 1.2 $
do 'CIDR.pm';

open (X, ">Net-CIDR.spec") || die "$!\n";

while (<DATA>)
{
    s/\@VERSION\@/$Net::CIDR::VERSION/e;
    print X;
}
close(X);
__END__

Summary: Net::CIDR Perl module
Name: Net-CIDR
Version: @VERSION@
Release: 1
Source0: %{name}-%{version}.tar.gz
License: Perl
Group: Development/Languages
BuildRoot: %{_tmppath}/%{name}-root

%description
The Net::CIDR perl module manipulates IPv4/IPv6 netblocks in CIDR notation

%prep
%setup -q
%{__perl} Makefile.PL
%build
%{__make}

%install
rm -rf $RPM_BUILD_ROOT
%{__make} install PREFIX=$RPM_BUILD_ROOT%{_prefix}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%{_prefix}/lib/perl5/site_perl/*/Net
%{_mandir}/man3/*

%changelog
* Tue Jun 26 2001 Mr. Sam <mrsam@courier-mta.com>
- Initial build.



