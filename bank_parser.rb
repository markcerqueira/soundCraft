require 'rubygems'

require 'listen'
require 'nokogiri'
require 'osc'

include OSC

# OSC receiver address/port
SERVER_HOST = 'localhost'
SERVER_PORT = 6449

# when true prints out all data parsed out of XML
PRINT_DATA = true

# path to the root folder that contains subdirectories that should contain our bank files
BANK_PATH = File.expand_path('~/Library/Application Support/Blizzard/StarCraft II/')

# polling latency for guard/listen to check for changes to bank files (in seconds)
POLLING_LATENCY_SECONDS = 0.05

# every OSC message is prefixed by this, followed by the bank name
OSC_ADDRESS_PREFIX = '/lorkCraft/'

# given filename identified by bankName, sends all key-value pairs in the bank file via OSC
def sendBank(absolutePath, bankName)
  # special bank handling functions
  if(bankName == 'unitsBuiltBank.SC2Bank')
    processUnitsBuiltBank(absolutePath, bankName)
    return
  end

  doc = Nokogiri::XML(open(absolutePath))

  for key in doc.css('Key')
    keyName = key['name']

    # parse as int first, then try parsing as string, then trying parsing as fixed/floating point
    value = key.css('Value').first['int']
    value = key.css('Value').first['string'] if value.nil?
    value = key.css('Value').first['fixed'] if value.nil?

    sendOSCMessage(OSC_ADDRESS_PREFIX + bankName, keyName, value)
  end

  puts '' if PRINT_DATA # makes logs a bit easier to digest
end

# special processor function for the unitsBuiltBank
def processUnitsBuiltBank(absolutePath, bankName)
  doc = Nokogiri::XML(open(absolutePath))

  # hash to keep track of units, default to 0 so we don't need to check if the unit has already been added
  unitHash = Hash.new
  unitHash.default = 0;

  # construct the hash
  for key in doc.css('Key')
    # note: we don't care about the "name" here as it's just an arbitrary unique integer written to the bank

    unitName = key.css('Value').first['string']

    # remove the common prefix from the unit name passed
    unitName.gsub!('Unit/Name/', '')

    unitHash[unitName] = unitHash[unitName] + 1
  end

  unitHash.each_pair do |unitName, unitCount|
      sendOSCMessage(OSC_ADDRESS_PREFIX + bankName, unitName, unitCount)
  end

  puts '' if PRINT_DATA # makes logs a bit easier to digest
end

def sendOSCMessage(address, key, value)
  conn = UDPSocket.new

  msg = Message.new(address, nil, key, value)
  conn.send(msg.encode, 0, SERVER_HOST, SERVER_PORT)

  puts address + ' (' + msg.tags.gsub!(',', '') + '): ' + "#{key}, #{value}" if PRINT_DATA
end

Listen.to(BANK_PATH, :filter => /\.SC2Bank$/, :latency => POLLING_LATENCY_SECONDS, :force_polling => true) do |modified, added|
  filesChanged = Set.new

  # add modified and add files to our set
  modified.each { |modifiedPath| filesChanged.add(modifiedPath) }
  added.each { |addedPath| filesChanged.add(addedPath) }

  # parse banks for each bank file
  filesChanged.each { |absolutePath| sendBank(absolutePath, File.basename(absolutePath)) }
end
