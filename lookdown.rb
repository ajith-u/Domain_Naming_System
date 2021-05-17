# def get_command_line_argument
#   # ARGV is an array that Ruby defines for us,
#   # which contains all the arguments we passed to it
#   # when invoking the script from the command line.
#   # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
#   if ARGV.empty?
#     puts "Usage: ruby lookup.rb <domain>"
#     exit
#   end
#   ARGV.first
# end

# # `domain` contains the domain name we have to look up.
# domain = get_command_line_argument

# # File.readlines reads a file and returns an
# # array of string, where each element is a line
# # https://www.rubydoc.info/stdlib/core/IO:readlines
# dns_raw = File.readlines("zone")

# #parsing dns A and Cname with hashes.
# #The :A is key of A and :C is key of Cname.
# #Depends on record type the source stored in array type.
# # def parse_dns(dns_list)
# #   lists = { :A => [], :C => [] } #initialize a dns hash for this function.

# #   #send each line from Zone list using each
# #   dns_list.each { |list|
# #     #Delete the whitespace and \n from the line
# #     #Split the line by comma and store only source and destination.
# #     source = list.gsub(/\s/, "").split(",")[1..2]

# #     #If it A record type, then push into :A key.
# #     #else, it is Cname.so,push into :C key.
# #     lists[list[0].to_sym].push(source) if (list[0] == "A" || list[0] == "C")
# #   }
# #   lists  #return the hash
# # end

# def parse_dns(dns_raw)
#   dns_list = dns_raw.map { |list| list.gsub(/\s/, "").split(",") if list != "\n" }
#   dns_list.delete(nil)
#   dns_hashLists = {}
#   dns_list.each do |record_type, source, destination|
#     if (dns_hashLists.has_key?(record_type.to_sym))
#       dns_hashLists[record_type.to_sym].push([source, destination])
#     else
#       dns_hashLists[record_type.to_sym] = [[source, destination]]
#     end
#   end
#   dns_hashLists
# end

# #Find the Ipaddress.
# def resolve(dnsRecords, lookupChain, url)
#   #Check A record type have that domain.
#   destination = dnsRecords[:A].find { |src| (src[0] == url) if src }
#   if (destination != nil)
#     lookupChain.push(destination[1]) #if domain is in A type push into lookup chain, return nil.
#   else
#     #Check A record type have that domain.
#     destination = dnsRecords[:CNAME].find { |src| src[0] == url if src }
#     if (destination != nil)
#       #if domain is in Cname type push into lookup chain, return nil.
#       lookupChain.push(destination[1])
#       resolve(dnsRecords, lookupChain, destination[1])
#     else
#       #If there is nothing domain in that zone then retrun error
#       lookupChain = ["Error: record not found for " + url]
#     end
#   end
# end

# # To complete the assignment, implement `parse_dns` and `resolve`.
# # Remember to implement them above this line since in Ruby
# # you can invoke a function only after it is defined.
# dns_records = parse_dns(dns_raw)
# lookup_chain = [domain]
# # p dns_records
# lookup_chain = resolve(dns_records, lookup_chain, domain)
# puts lookup_chain.join(" => ")

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
def parse_dns(dns_list)
  lists = { :A => [], :C => [] } #initialize a dns hash for this function.

  #send each line from Zone list using each
  dns_list.each { |list|
    #Delete the whitespace and \n from the line
    #Split the line by comma and store only source and destination.
    source = list.gsub(/\s/, "").split(",")[1..2]

    #If it A record type, then push into :A key.
    #else, it is Cname.so,push into :C key.
    lists[list[0].to_sym].push(source) if (list[0] == "A" || list[0] == "C")
  }
  lists  #return the hash
end

#Find the Ipaddress.
def resolve(dnsRecords, lookupChain, url)
  #Check A record type have that domain.
  destination = dnsRecords[:A].find { |src| (src[0] == url) if src }
  if (destination != nil)
    lookupChain.push(destination[1]) #if domain is in A type push into lookup chain, return nil.
  else
    #Check A record type have that domain.
    destination = dnsRecords[:C].find { |src| src[0] == url if src }
    if (destination != nil)
      #if domain is in Cname type push into lookup chain, return nil.
      lookupChain.push(destination[1])
      resolve(dnsRecords, lookupChain, destination[1])
    else
      #If there is nothing domain in that zone then retrun error
      lookupChain = ["Error: record not found for " + url]
    end
  end
end

# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
