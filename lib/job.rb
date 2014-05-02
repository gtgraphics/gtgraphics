module Job
  extend ActiveSupport::Concern

  included do
    %w(before success error after failure).each do |method|
      instance_eval %{
        def #{method}(method_name = nil, &block)
          _add_callback(:#{method}, :push, method_name, &block)
        end

        def prepend_#{method}(method_name = nil, &block)
          _add_callback(:#{method}, :unshift, method_name, &block)
        end

        def skip_#{method}(method_name)
          _remove_callback(:#{method}, method_name)
        end
      }
    end
  end

  module ClassMethods
    def callbacks
      @callbacks ||= {}
    end

    def inherited(base)
      cloned_callbacks = callbacks.dup
      cloned_callbacks.each do |key, value|
        cloned_callbacks[key] = value.dup if value.respond_to?(:dup)
      end
      base.instance_variable_set("@callbacks", cloned_callbacks)
    end

    private
    def _add_callback(event, type, method_name, &block)
      callback = block_given? ? block : method_name
      callbacks[event.to_sym] ||= []
      callbacks[event.to_sym].send(type, callback)
    end

    def _remove_callback(event, method_name)
      callbacks[event.to_sym].reject! { |callback| callback.is_a?(Symbol) and callback == method_name.to_sym }
    end
  end

  def perform_with_callbacks
    before(self)
    begin
      perform
      success(self)
      after(self)
      true
    rescue Exception => exception
      error(self, exception)
      after(self)
      failure(self)
      false
    end
  end

  # TODO Copy callbacks on inheritance

  def before(job)
    _execute_callbacks(:before, job)
  end

  def success(job)
    _execute_callbacks(:success, job)
  end

  def error(job, exception)
    _execute_callbacks(:error, job, exception)
  end

  def after(job)
    _execute_callbacks(:after, job)
  end

  def failure(job)
    _execute_callbacks(:failure, job)
  end

  private
  def _execute_callbacks(event, job, *args)
    Array(self.class.callbacks[event.to_sym]).each do |callback|
      callback = method(callback) unless callback.is_a? Proc
      callback_args = args[0...callback.arity]
      job.instance_exec(*callback_args, &callback)
    end
  end
end
