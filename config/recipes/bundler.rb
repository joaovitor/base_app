namespace :bundle do
  desc "Install gems"
  task :install do
    bundle = fetch(:bundle, "bundle")
    run "cd #{release_path}; #{bundle} install --path #{fetch(:bundle_dir, "#{shared_path}/bundle")} --deployment --without development test"
  end
end