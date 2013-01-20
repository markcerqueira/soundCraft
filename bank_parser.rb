require 'rubygems'
require 'nokogiri'
require 'osc'
require 'fssm'

include OSC

# OSC receiver address/port
SERVER_HOST = "localhost"
SERVER_PORT = 6449

# path to the folder containing all bank files created by Starcraft 2
BANK_PATH = '/Users/Mark/Library/Application Support/Blizzard/StarCraft II/Banks'

# given filename identified by bankName, sends all key-value pairs in the bank file via OSC
def sendBank( bankName )
  doc = Nokogiri::XML( open( BANK_PATH + '/' + bankName ) )
  conn = UDPSocket.new

  for key in doc.css('Key')
    keyName = key["name"]
    
    # parse as int first, then try parsing as string if that doesn't work
    value = key.css('Value').first['int']
    value = key.css('Value').first['string'] if value.nil?
    
    puts keyName + ' : ' + value
    
    if(value.nil?)
      puts "Nil value for key named: " + keyName
    else
      msg = Message.new( "/lorkCraft/" + bankName, "ss", keyName, value )
      conn.send msg.encode, 0, SERVER_HOST, SERVER_PORT
    end
  end  
  
  puts ""
end

# File System State Monitor trigger
FSSM.monitor( BANK_PATH, '**/*') do
  update {|basePath, bankName| sendBank( bankName ) }
  delete {|basePath, bankName| sendBank( bankName ) }
  create {|basePath, bankName| sendBank( bankName ) }
end
