require 'find'
require 'fileutils'
namespace :db do

  desc "Load schema and data from a local sql file named like abc.sql.gz . Usage: rake db:restore file=abc.sql.gz . File is picked up from tmp directory."
  task :restore => :environment do
    puts "Usage: rake db:restore file=2010-09-10-14-04-23.sql"
    restore_file = File.join(RAILS_ROOT, 'tmp', ENV['file'])

    database, user, password = retrieve_db_info("#{RAILS_ROOT}/config/database.yml")

    if restore_file =~ /\.gz/
      puts "decompressing backup"
      result = system("gzip -d #{restore_file}" )
      raise("backup decompression failed. msg: #{$?}" ) unless result
    end

    if password.blank?
      cmd = "mysql -u#{user} #{database} < #{restore_file.gsub('.gz','')}"
    else
      cmd = "mysql -u#{user}  -p#{password} #{database} < #{restore_file.gsub('.gz','')}"
    end
    puts cmd
    result = system(cmd)
    puts "database has been restored"
  end


  desc "This task backups the database to a file. It will keep a maximum of 10 backed up copies. The files are backed up at shared directory."
  task :backup => [:environment] do
    timestamp = ENV['timestamp'] || Time.zone.now.strftime("%Y-%m-%d-%H-%M-%S")
    MAX_BACKUPS = 10
    file_name = "#{timestamp}.sql"
    backup_dir = File.join (RAILS_ROOT,'..','..','shared','db_backups')

    backup_file = File.join(backup_dir, "#{file_name}.gz")

    FileUtils.mkdir_p(backup_dir) unless File.exists?(backup_dir) && File.directory?(backup_dir)

    database, user, password = retrieve_db_info("#{RAILS_ROOT}/config/database.yml")
    command = "mysqldump --opt --skip-add-locks -u#{user} #{database} >> #{file_name}"
    system(command)

    #-c --stdout write on standard output, keep original files unchanged
    #-q  quite
    #-9 best compression
    sh "gzip -q9 #{file_name}"
    sh "mv #{file_name}.gz  #{backup_file}"
    puts "Backup done at #{File.expand_path(backup_file)}"

    all_backups = Dir.glob(File.join(backup_dir,"*.gz"))

    # Dir.glob(File.join(backup_dir,"*.gz")).sort cannot be used because in some cases
    # timestamp is being passed from capistrano. Since capistrano does not support Time.zone.now
    # file names are not 100% reliable means to ensure the order in which files were created.
    all_backups_sorted = all_backups.sort {|a,b| File.new(a).mtime <=> File.new(b).mtime}
    all_backups_sorted = all_backups_sorted.reverse

    if all_backups_sorted.size > MAX_BACKUPS
      unwanted_backups = all_backups_sorted[MAX_BACKUPS..-1  ] || []
      unwanted_backups.each {|file| FileUtils.rm_rf(file); puts "deleted file #{file}";}
    end
  end

  desc "Copy production database to staging database"
  task :dev2staging => :environment  do
    file_name = "#{Rails.root}/tmp/production.data"
    config_file =  "#{Rails.root}/config/database.yml"

    db_config = YAML.load_file(config_file)

    prod_user = db_config['development']['username']
    prod_password = db_config['development']['password']
    prod_database =  db_config['development']['database']
    prod_params = "-Q --add-drop-table -O add-locks=FALSE -O lock-tables=FALSE"

    cmd = "mysqldump -u #{prod_user} -p#{prod_password} #{prod_params} #{prod_database} > #{file_name} "
    puts cmd
    system  cmd

    staging_user = db_config['production']['username']
    staging_password = db_config['production']['password']
    staging_database =  db_config['production']['database']

    cmd = "mysql -u #{staging_user} -p#{staging_password} #{staging_database} < #{file_name}"
    puts cmd
    system cmd

    puts "staging database has been restored with production database"
  end


  private
  def retrieve_db_info(database_yml_file)
    config = YAML.load_file(database_yml_file)
    return [
      config[RAILS_ENV]['database'],
      config[RAILS_ENV]['username'],
      config[RAILS_ENV]['password']
    ]
  end

  def mysql_execute(username, password, sql)
    system("/usr/bin/env mysql -u #{username} -p'#{password}' --execute=\"#{sql}\"")
  end

end
