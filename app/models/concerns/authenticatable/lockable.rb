module Authenticatable::Lockable
  extend ActiveSupport::Concern

  FAILED_SIGN_IN_LOCK_TIME = 5.minutes
  MAX_FAILED_SIGN_IN_ATTEMPTS = 5

  included do
    state_machine :lock_state, initial: :unlocked do
      state :locked_permanently
      state :locked_temporarily
      state :unlocked

      event :lock_permanently do
        transition all => :locked_permanently
      end
      event :lock_temporarily do
        transition all => :locked_temporarily
      end
      event :unlock do
        transition all => :unlocked
      end

      after_transition on: any - :locked_temporarily, do: :clear_locked_until, unless: :locked_temporarily?
      after_transition any => :locked_temporarily do |lockable, transition|
        lock_time = transition.args.first || raise(ArgumentError, 'you need to specify the lock duration')
        if lock_time.is_a?(DateTime)
          raise ArgumentError, 'lock time must not be in past' if lock_time.past?
          lockable.update_column(:locked_until, lock_time)
        else
          lockable.update_column(:locked_until, DateTime.now + lock_time)
        end
      end
    end

    before_save :clear_locked_until, unless: :locked_temporarily?

    scope :locked, -> { with_lock_states(:locked_permanently, :locked_temporarily) }
    scope :unlocked, -> { with_lock_state(:unlocked) }
  end

  module ClassMethods
    def remove_expired_locks!(options = {})
      options.reverse_merge!(expired_at: DateTime.now, lock_state: :unlocked)
      with_lock_state(:locked_temporarily).where(arel_table[:locked_until].lt(options[:expired_at])).update_all(lock_state: options[:lock_state], locked_until: nil)
    end
  end

  def fail_sign_in
    if failed_sign_in_attempts.next == MAX_FAILED_SIGN_IN_ATTEMPTS
      self.state = 'locked_temporarily'
      self.locked_until = DateTime.now + FAILED_SIGN_IN_LOCK_TIME
      self.failed_sign_in_attempts = 0
    else
      self.failed_sign_in_attempts += 1
    end
  end

  def fail_sign_in!
    if failed_sign_in_attempts.next == MAX_FAILED_SIGN_IN_ATTEMPTS
      transaction do
        lock_temporarily!(FAILED_SIGN_IN_LOCK_TIME)
        update_column(:failed_sign_in_attempts, 0)
      end
    else
      increment!(:failed_sign_in_attempts)
    end
  end

  def locked?
    lock_state?(:locked_permanently) or lock_state?(:locked_temporarily)
  end

  def remove_expired_lock!
    if temporary_lock_expired?
      unlock!
    else
      false
    end
  end

  def succeed_sign_in
    self.failed_sign_in_attempts = 0
  end

  def succeed_sign_in!
    update_attribute(:failed_sign_in_attempts, 0)
  end

  def temporary_lock_expired?
    if lock_state?(:locked_temporarily)
      locked_until.past?
    else
      true
    end
  end

  private
  def clear_locked_until
    self.locked_until = nil
  end
end