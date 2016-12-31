module Crystalla
  def check_is_fitted(estimator, attributes, msg=nil, all_or_any=all)
    if msg.nil
      msg = "This instance is not fitted yet. Call 'fit' with appropriate arguments before using this method."
    end

    if !estimator.responds_to?(:fit)
      raise TypeError.new("#{estimator} is not an estimator")
    end

    attributes.each do |attribute|
      if !estimator.responds_to?(:attribute)
        raise NotFittedError.new(msg)
      end
    end
  end
end
