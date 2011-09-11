require 'rubygems'
require 'nokogiri'
require 'osc'
require 'fssm'

include OSC

# OSC receiver address/port
SERVER_HOST = "localhost"
SERVER_PORT = 6449

# path to the folder containing all bank files created by Starcraft 2
BANK_PATH = '/Users/Mark/Library/Application Support/Blizzard/StarCraft II/Accounts/65359401/1-S2-1-1685872/Banks'

# filenames of banks that are used
MINERAL_BANK = 'mineralBank.SC2Bank'
VESPENE_BANK = 'vespeneBank.SC2Bank'
SUPPLY_BANK = 'supplyBank.SC2Bank'

# given filename identified by bankName, sends all key-value pairs in the bank file via OSC
def sendBank( bankName )
  doc = Nokogiri::XML( open( BANK_PATH + '/' + bankName ) )
  conn = UDPSocket.new

  for key in doc.css('Key')
    puts key["name"].inspect + ' : ' + key.css('Value').first['int'].inspect
    msg = Message.new( "/lorkCraft/" + bankName, "ss", key["name"], key.css('Value').first['int'] )
    conn.send msg.encode, 0, SERVER_HOST, SERVER_PORT  
  end  
end

# File System State Monitor trigger
FSSM.monitor( BANK_PATH, '**/*') do
  update {|basePath, bankName| sendBank( bankName ) }
  delete {|basePath, bankName| sendBank( bankName ) }
  create {|basePath, bankName| sendBank( bankName ) }
end
