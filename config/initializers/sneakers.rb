require 'sneakers'

Sneakers.configure(
  connection: Bunny.new(
    addresses: ENV['BUNNY_AMQP_ADDRESSES']&.split(',') || 'localhost:5672',
    username:  ENV['BUNNY_AMQP_USER'] || 'guest',
    password:  ENV['BUNNY_AMQP_PASSWORD'] || 'guest',
    vhost:     ENV['BUNNY_AMQP_VHOST'] || '/',
    automatically_recover: true,
    connection_timeout: 2,
    continuation_timeout: (ENV['BUNNY_CONTINUATION_TIMEOUT'] || 10_000).to_i,
    logger:  Rails.logger
  ),
  durable: true,
  workers: ENV.fetch('SNEAKERS_PROCESSES', 4),
  threads: ENV.fetch('SNEAKERS_THREADS', 10),
  prefetch: ENV.fetch('SNEAKERS_THREADS', 10), # this is not a typo: the doc says it's good to match prefetch and threads values
  timeout_job_after: 60,
  share_threads: true, # both options are supported by `after_hook` hereafter
  hooks: {
    before_fork: -> {
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.connection_pool.disconnect!
        Sneakers.logger.info('Disconnected from ActiveRecord')
      end
    },
    after_fork: -> {
      def determine_db_pool_size
        worker_classes     = Sneakers::Utils.parse_workers(ENV["WORKERS"]).first
        threads_per_worker = ENV.fetch('SNEAKERS_THREADS', 10)

        if Sneakers.const_get(:CONFIG)[:share_threads]
          3 + worker_classes.count * 3 + threads_per_worker
        else
          3 + worker_classes.count * 3 + worker_classes.count * threads_per_worker
        end
      end

      def reconnect_default_database(db_pool_size)
        ActiveRecord::Base.establish_connection(
          Rails.application.config.database_configuration[Rails.env].merge("pool" => db_pool_size)
        )
      end

      ActiveSupport.on_load(:active_record) do
        db_pool_size = determine_db_pool_size
        reconnect_default_database(db_pool_size)
        Sneakers.logger.info("Connected to ActiveRecord")
      end
    }
  }
)
