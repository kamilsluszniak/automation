module Triggers
  class CheckerQueuePublisher
    DEFAULT_OPTIONS = { durable: true, auto_delete: false }.freeze
    QUEUE_NAME = 'triggers_checker'

    def initialize(user_id:)
      @user_id = user_id
    end
  
    def publish(options = {})
      channel = RabbitQueueService.connection.create_channel
      exchange = channel.exchange(
        'sneakers',
        type: :direct,
        durable: true,
      )

      exchange.publish(payload.to_json, routing_key: QUEUE_NAME)
    end
  
    private
  
    def payload
      {
        user_id: @user_id
      }
    end
  end
end