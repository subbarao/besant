server '173.230.129.162', :app, :web, :db, :primary => true

namespace :dragonfly do
  desc "Symlink the Rack::Cache files"
  task :symlink, :roles => [:app] do
    run "mkdir -p #{shared_path}/tmp/dragonfly && ln -nfs #{shared_path}/tmp/dragonfly #{release_path}/tmp/dragonfly"
  end
end

namespace :rake do
  desc "Run a task on a remote server."
  # run like: cap staging rake:invoke task=a_certain_task
  task :invoke do
    run("cd #{deploy_to}/current; /usr/bin/rake #{ENV['task']} RAILS_ENV=#{rails_env}")
  end
end

namespace :db do
  desc 'will create a backup on the server and then will download and will insert the data in local database'
  task :restore_local do
    timestamp = Time.now.strftime("%Y-%m-%d-%H-%M-%S")
    run("cd #{current_path} && /usr/bin/rake db:backup timestamp=#{timestamp} RAILS_ENV=#{rails_env} ")
    get "#{deploy_to}/shared/db_backups/#{timestamp}.sql.gz","tmp/#{timestamp}.sql.gz"
    system("rake db:restore file='#{timestamp}.sql.gz'")
  end

  desc 'will create a backup of the database'
  task :backup do
    run("cd #{current_path} && /usr/bin/rake db:backup RAILS_ENV=#{rails_env} ")
  end
end



#before 'deploy:update_code', 'db:backup'
#after 'deploy:update_code', 'dragonfly:symlink'
#require 'config/boot'
#require 'hoptoad_notifier/capistrano'
