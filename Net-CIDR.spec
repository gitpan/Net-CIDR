
Summary: Net::CIDR Perl module
Name: perl-net-cidr
Version: 0.04
Release: 1
Source0: Net-CIDR-%{version}.tar.gz
License: Perl
Group: Development/Languages
BuildRoot: %{_tmppath}/%{name}-root

%description
The Net::CIDR perl module manipulates IPv4/IPv6 netblocks in CIDR notation

%prep
%setup -q -n Net-CIDR-%{version}
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
* Fri Nov  2 2001 Mr. Sam <mrsam@courier-mta.com>
- Changed package name to perl-net-cidr

* Tue Jun 26 2001 Mr. Sam <mrsam@courier-mta.com>
- Initial build.



