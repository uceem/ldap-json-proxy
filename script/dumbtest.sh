#!/bin/sh

# Uses the same settings as net/ldap
# settings = {
#   :host => ENV['AD_HOSTNAME'].nil? ? 'uceemad.hq.uceem.com' : ENV['AD_HOSTNAME'],
#   :base => 'dc=pksft,dc=net',
#   :port => 389,
# #    :port => 636,
# #    :encryption => :simple_tls,
#   :auth => {
#     :method => :simple,
#     :username => "cn=doug w,cn=users,dc=pksft,dc=net",
#     :password => "dougw"
#   }
# }

curl --silent -d api_token=hello \
	-d host=uceemad.hq.uceem.com -d base="dc=pksft,dc=net" -d port=389 \
	--data-urlencode "username=cn=doug w,cn=users,dc=pksft,dc=net" \
	--data-urlencode "password=dougw" \
	--data-urlencode "filter=(&(objectCategory=person)(objectClass=user))" \
	localhost:3000/ldapsearch


