# config/unicorn.rb
worker_processes 4
timeout 300
preload_app true

before_fork do |server, worker|

  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|

  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to sent QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end

app_name = "rest-ldap"
home_dir = "/home/rails"
working_directory "/home/rails/deploy/#{app_name}"
listen "#{home_dir}/sockets/rails-#{app_name}.sock"

user 'rails', 'rails'
pid "#{home_dir}/pids/rails-#{app_name}.pid"

log_path = "#{home_dir}/logs"
stderr_path "#{log_path}/unicorn-#{app_name}.stderr.log"
stdout_path "#{log_path}/unicorn-#{app_name}.stdout.log"
