require File.dirname(__FILE__) + '/mail_check'

module ValidatesEmailWithSmtp
  def self.included(base)
    base.class_eval do
      extend ClassMethods
    end
  end

  module ClassMethods
    def validates_email_with_smtp(*attrs)
      validates_each(attrs) do |record,attr,value|
        if MailCheck.run(value).invalid?
          record.errors.add(attr,:invalid, :value => value)
        end
      end
    end
  end
end

class ActiveRecord::Base
  include ValidatesEmailWithSmtp
end
