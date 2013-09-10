require 'net/ldap'

class ApiController < ApplicationController
  before_filter :require_api_token
  skip_before_filter :verify_authenticity_token      
  respond_to :json      

  # POST /ldapsearch
  #   IN:
  #   api_token - token for application level access
  #   host
  #   port
  #   username
  #   password
  #   encryption
  #   base
  #   filter
  #
  #   OUT:
  #
  def ldapsearch
    ldap_settings = {
      :port => 389,
      :auth => { :method => :anonymous }
      
    }
    if params[:host].blank? or params[:filter].blank? or params[:base].blank?
      render :status=>400, :json=>{:message=>"Missing parameter"}
      return
    end
    ldap_settings[:host] = params[:host].to_s
    ldap_settings[:port] = params[:port].to_s unless params[:port].blank?
    unless params[:username].blank?
      ldap_settings[:auth] = {
        :method => :simple,
        :username => params[:username].to_s,
        :password => params[:password].to_s
      }
    end
    ldap_settings[:encryption] = :simple_tls if params[:encryption].to_s == 'simple_tls'

    begin
      ldap = Net::LDAP.new ldap_settings
      query_filter = Net::LDAP::Filter.construct params[:filter].to_s
      basedn = params[:base].to_s

      results = []
      ldap.search(:base => basedn, :filter => query_filter) do |entry|
        results << entry
        puts "DN: #{entry.dn}"
        entry.each do |attribute, values|
          puts "   #{attribute}:"
          values.each do |value|
            puts "      --->#{value}"
          end
        end
      end
    rescue Exception => e
      render :status=>400, :json => { message: e.message }
      return
    end

    puts ldap.get_operation_result

    render :status=>200, :json => results
  end

private
  def unauth(str)
    logger.info "UNAUTH: " + str
    return head(:unauthorized, :reason => str)
  end

  def require_api_token
    if (params[:api_token].blank?)
      return unauth('Invalid parameter: missing api token')
    end
    #logger.info "REQUIRE STD API TOKEN: #{params[:api_token]}"
    raise "no api token" if ENV['LDAP_JSON_PROXY_API_TOKEN'].blank?
    if params[:api_token] != ENV['LDAP_JSON_PROXY_API_TOKEN']
      return unauth('Invalid parameter: bad api token')
    end
  end
end
