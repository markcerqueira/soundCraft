require 'rubygems'
require 'nokogiri'
require 'osc'
require 'listen'

include OSC

# OSC receiver address/port
SERVER_HOST = "localhost"
SERVER_PORT = 6449

# path to the folder containing all bank files created by Starcraft 2
BANK_PATH = '/Users/Mark/Library/Application Support/Blizzard/StarCraft II/Banks'
POLLING_LATENCY_SECONDS = 0.05;

# given filename identified by bankName, sends all key-value pairs in the bank file via OSC
def sendBank(bankName)
  # special bank handling functions
  if(bankName == "unitsBuiltBank.SC2Bank")
    processUnitsBuiltBank(bankName)
    return
  end

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

def processUnitsBuiltBank(bankName)
  doc = Nokogiri::XML( open( BANK_PATH + '/' + bankName ) )
  conn = UDPSocket.new

  # hash to keep track of units, default to 0 so we don't need to check if the unit has already been added
  unitHash = Hash.new
  unitHash.default = 0;

  # construct the hash
  for key in doc.css('Key')
    # note: we don't care about the "name" here as it's just an arbitrary unique integer

    unitName = key.css('Value').first['string']

    # remove the common prefix from the unit name passed
    unitName.gsub!("Unit/Name/", "")

    unitHash[unitName] = unitHash[unitName] + 1
  end

  unitHash.each_pair do |unitName, unitCount|
    puts "#{unitName} : #{unitCount}"

    msg = Message.new( "/lorkCraft/" + bankName, "si", unitName, unitCount )
    conn.send msg.encode, 0, SERVER_HOST, SERVER_PORT
  end

  puts ""
end

Listen.to(BANK_PATH, :filter => /\.SC2Bank$/, :latency => POLLING_LATENCY_SECONDS, :force_polling => true) do |modified, added|
  String absolutePath = modified.inspect
  absolutePath = added.inspect if absolutePath.nil?

  # remove silly characters surrounding the path
  absolutePath.gsub!("[\"", "")
  absolutePath.gsub!("\"]", "")

  sendBank(File.basename(absolutePath))
end
