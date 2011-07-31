require 'rubygems'
require 'nokogiri'
require 'osc'
require 'fssm'

include OSC

SERVER_HOST = "localhost"
SERVER_PORT = 6449

BANK_PATH = '/Users/Mark/Library/Application Support/Blizzard/StarCraft II/Accounts/65359401/1-S2-1-1685872/Banks'

def sendEconomy
  doc = Nokogiri::XML( open( BANK_PATH + '/tutorialBank1.SC2Bank' ) )

  conn = UDPSocket.new

  for key in doc.css('Key')
    puts key["name"].inspect
    puts key.css('Value').first['int'].inspect

    msg = Message.new( "/plorkCraft/test", "ss", key["name"], key.css('Value').first['int'] )
    conn.send msg.encode, 0, SERVER_HOST, SERVER_PORT  
  end  
end

FSSM.monitor( BANK_PATH, 'tutorialBank1.SC2Bank') do
  update 
  { 
    |b, r| puts "Update in #{b} to #{r}"
    sendEconomy 
  }
  delete { |b, r| puts "Delete in #{b} to #{r}" }
  create { |b, r| puts "Create in #{b} to #{r}" }
end





