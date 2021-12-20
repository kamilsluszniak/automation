class TriggersCheckerWorker
  include Sneakers::Worker
  QUEUE_NAME = 'triggers_checker'
  from_queue QUEUE_NAME, arguments: { 'x-dead-letter-exchange': "#{QUEUE_NAME}-retry" }

  def work(msg)
    parsed = JSON.parse(msg)
    ActiveRecord::Base.connection_pool.with_connection do
      user = User.find(parsed['user_id'])
      Triggers::Checker.new(user).call
    end
    ack!
  end
end