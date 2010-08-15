namespace :db do
  desc "remote backup and download the MySQL database"
  task :backup, :roles => :db do
    backup_rb ||= "#{current_path}/lib/backup.rb"
    run "mkdir -p #{deploy_to}/etc"
    run "if [ -f #{backup_rb} ]; then ruby #{backup_rb} backup #{deploy_to} ; fi"
    get "#{deploy_to}/etc/dump.tar.gz", "#{stage}-#{application}-#{Time.now.strftime('%Y%m%d%H%M%S').to_s}.tar.gz"
    run "rm #{deploy_to}/etc/dump.tar.gz"
  end

  desc "upload and restore of remote MySQL database"
  task :restore, :roles => :db do
    unless File.exists?("dump.tar.gz")
      puts "Backup dump.tar.gz not found"
      exit 0
    end
    backup_rb ||= "#{current_path}/lib/backup.rb"
    run "mkdir -p #{deploy_to}/etc"
    upload "dump.tar.gz", "#{deploy_to}/etc/dump.tar.gz"
    run "if [ -f #{backup_rb} ]; then ruby #{backup_rb} restore #{deploy_to} ; fi"
  end

  desc "drop and create a empty database"
  task :recreate, :roles => :db do
    allowed_stages = [:homologacao, :desenvolvimento]
    raise "Não é permitido recriar a base no ambiente de #{stage}" unless allowed_stages.include?(stage.to_sym)

    rails_env = fetch(:rails_env, "production")
    rake = fetch(:rake, "rake")

    run "cd #{current_release}; #{rake} RAILS_ENV=#{rails_env} db:drop; #{rake} RAILS_ENV=#{rails_env} db:create;"
  end
end

before "db:restore", "db:recreate"