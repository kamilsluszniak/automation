class RabbitQueueService
  def self.logger
    Rails.logger.tagged('bunny') do
      @@_logger ||= Rails.logger
    end
  end

  def self.connection
    @@_connection ||= begin
      instance = Bunny.new(
        addresses: ENV['BUNNY_AMQP_ADDRESSES']&.split(',') || 'localhost:5672',
        username:  ENV['BUNNY_AMQP_USER'] || 'guest',
        password:  ENV['BUNNY_AMQP_PASSWORD'] || 'guest',
        vhost:     ENV['BUNNY_AMQP_VHOST'] || '/',
        automatically_recover: true,
        connection_timeout: 2,
        continuation_timeout: (ENV['BUNNY_CONTINUATION_TIMEOUT'] || 10_000).to_i,
        logger: RabbitQueueService.logger
      )
      instance.start
      instance
    end
  end

  ObjectSpace.define_finalizer(Automation::Application, proc { puts "Closing rabbitmq connections"; RabbitQueueService.connection&.close })
end