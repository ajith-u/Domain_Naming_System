def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines
dns_raw = File.readlines("zone")

#parsing dns A and Cname with hashes.
#The :A is key of A and :C is key of Cname.
#Depends on record type the source stored in array type.

def parse_dns(raw)
  raw.
    reject { |line| line.empty? || line[0] == "#" }. #remove invalid character from zone
    map { |line| line.strip.split(", ") }. #split the line by ", "
    reject do |record| #reject if record less than 3 record.
    record.length < 3
  end.
    each_with_object({}) do |record, records| # create a hash and store the value
    records[record[1]] = {
      type: record[0],
      target: record[2],
    }
  end
end

#Find the Ipaddress.
def resolve(dns_records, lookup_chain, domain)
  record = dns_records[domain]
  if (!record) #if there is no record
    lookup_chain = ["Error: Record not found for " + domain]
    return lookup_chain
  elsif record[:type] == "CNAME" #If CNAME source,again call the resolve with target
    lookup_chain << record[:target]
    lookup_chain = resolve(dns_records, lookup_chain, record[:target])
  elsif record[:type] == "A" #If A record source, its a destination.So, return the Ip address along with via sources
    return lookup_chain << record[:target]
  else #if there is neither CNAME nor A source.It means its invalid source in this zone
    lookup_chain << "Invalid record type for " + domain
    return
  end
end

# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
