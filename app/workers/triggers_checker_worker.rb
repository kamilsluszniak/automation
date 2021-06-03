class TriggersCheckerWorker
  include Sneakers::Worker
  QUEUE_NAME = 'triggers_checker'
  from_queue QUEUE_NAME, arguments: { 'x-dead-letter-exchange': "#{QUEUE_NAME}-retry" }
  def work(msg)
    p msg
    ack!
  end
end