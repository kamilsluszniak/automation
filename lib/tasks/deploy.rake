# frozen_string_literal: true

namespace :deploy do
  desc 'uploads docker compose to production server'
  task upload_compose: :environment do
    exec 'scp ./docker-compose.yml ubuntu@18.221.177.239:/home/deploy'
  end

  # task run_compose: :environment do
  #   require 'net/ssh'
  #   Net::SSH.start('18.221.177.239', 'ubuntu') do |ssh|
  #     home    = '/usr/local'
  #     binary  = File.join(home, 'bin', 'docker-compose')
  #     command = "#{binary} -f /home/deploy/docker-compose.yml up -d"
  #     output = ssh.exec! 'aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 252636471646.dkr.ecr.us-east-2.amazonaws.com'
  #     puts output
  #     ssh.exec! 'cd /home/deploy/'
  #     output = ssh.exec!(command)
  #     puts output
  #   end
  # end
end
