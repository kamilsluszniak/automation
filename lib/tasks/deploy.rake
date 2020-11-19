# frozen_string_literal: true

namespace :deploy do
  desc 'uploads docker compose to production server'
  task upload_compose: :environment do
    exec 'scp ./docker-compose.yml ubuntu@3.139.171.17:/home/deploy'
  end

  desc 'login to aws ecr'
  task ecr_login: :environment do
    cmd = 'aws ecr get-login-password --region us-east-2 | docker login '\
    '--username AWS --password-stdin 252636471646.dkr.ecr.us-east-2.amazonaws.com'
    exec cmd
  end

  desc 'runs compose'
  task run_compose: :environment do
    exec 'DOCKER_HOST="ssh://ubuntu@3.139.171.17" docker-compose restart'
  end

  desc 'generate task definition'
  task definition_gen: :environment do
    exec 'docker run --rm -v $(pwd):/data/ micahhausler/container-transform  docker-compose.yml'
  end

  desc 'upload ecs task'
  task definition_upload: :environment do
    exec 'aws ecs register-task-definition --cli-input-json file://task-definition.json'
  end
end
