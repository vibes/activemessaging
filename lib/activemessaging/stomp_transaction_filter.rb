class StompTransactionFilter < ActiveMessaging::Filter
  def process(message, details)
    case details[:direction]
    when :incoming
      set_transaction_id(message, details)
    when :outgoing
      if transaction_id = get_transaction_id(details)
        puts " ====== setting transaction id ======== "
        message.headers[:transaction] = transaction_id
      end
    else
      raise "I can't filter a message with direction #{details[:direction].inspect}"
    end
  end

  def set_transaction_id(message, details)
    if trans_id = message.headers[:transaction]
      transaction_ids[details[:destination].broker_name] = trans_id
    end
  end

  def get_transaction_id(details)
    transaction_ids[details[:destination].broker_name]
  end

  def transaction_ids
    Thread.current[:stomp_transaction_filter] ||= Hash.new
  end
end
