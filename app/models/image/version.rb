class Image < ActiveRecord::Base
  class Version < ActiveRecord::Base
    RATIOS = [
      Rational(16,9) => %w(1280x720 1920x1080),
      Rational(16,10) => %w(1920x1200),
      Rational(3,2) => %w()
    ]

    self.table_name = 'image_versions'

    has_attached_file :asset

    validates_attachment :asset, presence: true

    before_save :set_ratio

    class << self
      def with_ratio(*args)
        ratio = case args.length
        when 1 then args.first.to_r
        when 2 then Rational(args.first, args.second)
        else raise ArgumentError, 'invalid number of arguments'
        end
        where(ratio_numerator: ratio.numerator, ratio_denominator: ratio.denominator)
      end
    end



    private
    def set_ratio
      self.ratio_numerator = ratio.numerator
      self.ratio_denominator = ratio.denominator
    end

  end
end