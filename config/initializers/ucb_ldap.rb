#
#	UCB LDAP does not appear to be being maintained
#	and is not ruby 1.9.3 compatible.
#	So ...
#

$LOAD_PATH << Rails.root.join('lib/ucb_ldap-1.4.2/lib').to_s

require 'ucb_ldap'


#	don't use ruby-net-ldap as is too old

#	remove require 'rubygems' as is old

#	correct TCPsocket typo (in ruby-net-ldap not ucb_ldap)
