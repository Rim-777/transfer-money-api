# frozen_string_literal: true

module BaseOperation
  module ClassMethods
    def call(*args)
      new(*args).call
    end
  end

  def self.prepended(base)
    # See https://dry-rb.org/gems/dry-initializer/3.0/skip-undefined/
    base.extend Dry::Initializer[undefined: false]
    base.extend ClassMethods
  end

  %i[
    Interruption
  ].each { |exception| const_set(exception, Class.new(Exception)) }

  attr_reader :errors

  def initialize(*args)
    super(*args)
    @errors = []
  end

  def call
    super
    self
  rescue Interruption
    self
  end

  def success?
    !failure?
  end

  def failure?
    @errors.any?
  end

  private

  def fail!(messages, interrupt: false)
    @errors += Array(messages)
    interrupt! if interrupt
    self
  end

  def interrupt!
    raise Interruption
  end

  def interrupt_with_errors!(messages)
    fail!(messages, interrupt: true)
  end
end
