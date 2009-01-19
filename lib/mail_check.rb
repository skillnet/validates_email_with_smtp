require 'resolv'
require 'net/smtp'

class MailCheck < Net::SMTP

	def self.run(addr, server = nil)
		server = get_mail_server(addr[(addr.index('@')+1)..-1]) if server.nil?
		ret = nil
		MailCheck.start(server) do |smtp|
		        ret = smtp.check_mail_addr(addr)
		end
		return ret
	end

	def check_mail_addr( to_addrs , from_addr = "root@localhost" )
		raise IOError, 'closed session' unless @socket
		raise ArgumentError, 'mail destination not given' if to_addrs.empty?
		
		mailfrom from_addr
		res = Array.new
		begin
			to_addrs.each do |to|
				rcptto to 
			end
		rescue Net::SMTPFatalError => e
			if e.to_s[0..2] == "550"
				return false
			end
			return nil
		end
		return true
	end

	def self.get_mail_server(host)
		res = Resolv::DNS.new.getresources(host, Resolv::DNS::Resource::IN::MX)
		unless res.empty?
			return res.sort {|x,y| x.preference <=> y.preference}.first.exchange.to_s
		end
		nil
	end

end

