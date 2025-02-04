require '~/.ruby_tools/simple_spec.rb'
require 'debug'
include Eddorre::SimpleSpec
using Eddorre::TerminalColors

class TokenBucket
  REFILL_RATE_PER_SECOND = 5

  attr_reader :identifier, :capacity, :refill_rate, :started, :tokens

  def initialize(identifier:, capacity:, refill_rate: nil)
    raise ArgumentError unless capacity.positive?

    @identifier = identifier
    @refill_rate = refill_rate || REFILL_RATE_PER_SECOND
    @capacity = capacity
    @started = false
    @tokens = @capacity
    @thread = nil
  end

  def start
    @started = true

    begin
      @thread = Thread.new do
        while @started do
          sleep(1)
          if tokens < capacity
            max_tokens = capacity - tokens
            tokens_to_refill = [refill_rate, max_tokens].min
            puts "\r\nBUCKET WITH #{tokens} EXISTING TOKENS BEING REFILLED WITH #{tokens_to_refill} MORE TOKENS"
            @tokens += tokens_to_refill
          end
        end
      end
    rescue StandardError => e
      puts "AN EXCEPTION OCCURRED #{e}"
    end
  end

  def stop
    @started = false
    @thread&.kill
    @thread = nil
  end

  def allow?
    return false unless @started
    return false unless tokens.positive?

    @tokens -= 1
    true
  end
end


bucket = TokenBucket.new(identifier: '192.168.1.1', capacity: 20)

test 'it should have a capacity of 20' do
  expect(bucket.capacity).to eq(20)
end

test 'it should not started by default' do
  expect(bucket.started).not_to be_truthy
end

test 'it should set the bucket to started' do
  bucket.start
  expect(bucket.started).to be_truthy
end

test 'it should set the bucket to not started' do
  bucket.stop
  expect(bucket.started).not_to be_truthy
end

test 'it should not allow if stopped' do
  bucket.stop
  expect(bucket.allow?).not_to be_truthy
end

test_bucket = TokenBucket.new(identifier: '192.168.1.1', capacity: 20)
test_bucket.start

counter = 0
max_run_time = 60 # in seconds
request = 0

while counter < max_run_time do
  number_of_requests = rand(30)
  puts "SENDING #{number_of_requests} REQUESTS"
  number_of_requests.times do
    request += 1
    allowed = test_bucket.allow?
    if allowed
      puts "REQUEST #{request} ALLOWED. NUMBER OF TOKENS #{test_bucket.tokens}."
    else
      puts "REQUEST #{request} DENIED. NUMBER OF TOKENS #{test_bucket.tokens}."
    end
  end
  
  time_to_sleep = sleep(rand(4))
  counter += time_to_sleep
end
