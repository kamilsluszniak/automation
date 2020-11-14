# frozen_string_literal: true

namespace :deploy do
  desc 'uploads docker compose to production server'
  task upload_compose: :environment do
    exec 'scp ./docker-compose.yml ubuntu@18.221.177.239:/home/deploy'
  end

  desc 'runs compose'
  task run_compose: :environment do
    exec 'DOCKER_HOST="ssh://ubuntu@18.221.177.239" docker-compose restart'
  end
end
