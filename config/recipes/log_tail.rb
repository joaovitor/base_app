namespace :log do
  desc "tail production log files"
  task :tail, :roles => :app do
    run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
      puts # para uma linha extra
      puts "#{channel[:host]}: #{data}"
      break if stream == :err
    end
  end
end