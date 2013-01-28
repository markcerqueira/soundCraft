require 'rubygems'

require 'listen'
require 'nokogiri'
require 'osc'

include OSC

# global scope - OSC destination address/port
$serverHost
$serverPort

# global scope hash so when units/buildings complete we can indicate that to listeners by sending a 0 for the count
# e.g. when a Spawning Pool finishes, we will continue to send 'Spawning Pool', 0
$aggregateProductionHash = Hash.new()

# when true prints out all data parsed out of XML
PRINT_DATA = true

# path to the root folder that contains subdirectories that should contain our bank files
BANK_PATH = File.expand_path('~/Library/Application Support/Blizzard/StarCraft II/')

# polling latency for guard/listen to check for changes to bank files (in seconds)
POLLING_LATENCY_SECONDS = 0.05

# every OSC message is prefixed by this, followed by the bank name
OSC_ADDRESS_PREFIX = '/lorkCraft/'

# used for debug print messages
START_TIME = Time.now

# helper method to get seconds since program started executing (returned as a float)
def secondsSinceStart()
  (Time.now - START_TIME).to_f
end

# given filename identified by bankName, sends all key-value pairs in the bank file via OSC
def sendBank(absolutePath, bankName)
  # special bank handling functions
  if(bankName == 'unitsBuiltBank.SC2Bank')
    processUnitsBuiltBank(absolutePath, bankName)
    return
  elsif(bankName == 'abilitiesUsedBank.SC2Bank')
    processAbilityUsedBank(absolutePath, bankName)
    return
  elsif(bankName == 'cameraBank.SC2Bank')
    processCameraFocusBank(absolutePath, bankName)
    return
  elsif(bankName == 'unitProductionBank.SC2Bank' or bankName == 'buildingProductionBank.SC2Bank')
    processProductionBank(absolutePath, bankName)
    return
  end

  doc = Nokogiri::XML(open(absolutePath))

  for key in doc.css('Key')
    keyName = key['name']

    # parse as int first, then try parsing as string, then trying parsing as fixed/floating point
    value = key.css('Value').first['int']
    valueType = "i"

    if value.nil?
      value = key.css('Value').first['string'] if value.nil?
      valueType = "s"
    end

    if value.nil?
      value = key.css('Value').first['fixed'] if value.nil?
      valueType = "f"
    end

    sendOSCMessage(OSC_ADDRESS_PREFIX + bankName, keyName, 's', value, valueType)
  end

  puts '' if PRINT_DATA # makes logs a bit easier to digest
end

# special processor for camera bank
def processCameraFocusBank(absolutePath, bankName)
  doc = Nokogiri::XML(open(absolutePath))

  xCoor = -1.0;
  yCoor = -1.0;

  for key in doc.css('Key')
    keyName = key['name']

    if(keyName == 'cameraFocusX')
       xCoor = key.css('Value').first['fixed']
    elsif(keyName == 'cameraFocusY')
      yCoor = key.css('Value').first['fixed']
    else
      puts "ERROR: unexpected name in XML: #{keyName}"
    end
  end

  sendOSCMessage(OSC_ADDRESS_PREFIX + bankName, xCoor, 'f', yCoor, 'f')

  puts '' if PRINT_DATA # makes logs a bit easier to digest
end

# special processor for abilities used bank
def processAbilityUsedBank(absolutePath, bankName)
  doc = Nokogiri::XML(open(absolutePath))

  for key in doc.css('Key')
    unitName = key['name']

    abilityUsed = key.css('Value').first['string']

    # remove the common prefix from the unit name passed
    unitName.gsub!('Unit/Name/', '')

    sendOSCMessage(OSC_ADDRESS_PREFIX + bankName, unitName, 's', abilityUsed, 's')
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
      sendOSCMessage(OSC_ADDRESS_PREFIX + bankName, unitName, 's', unitCount, 'i')
  end

  puts '' if PRINT_DATA # makes logs a bit easier to digest
end

# special processor function for the units and building production banks
def processProductionBank(absolutePath, bankName)
  doc = Nokogiri::XML(open(absolutePath))

  # hash to keep track of progress of units/buildings being built
  productionProgressHash = Hash.new
  productionProgressHash.default = 0.0;

  # construct the hash getting the unit/building name and build progress
  for key in doc.css('Key')
    # "name" is a unique integer + Unit/Name/ + name of the unit/building
    unitName = key['name']
    unitName.gsub!('Unit/Name/', '')

    buildProgress = key.css('Value').first['fixed']

    productionProgressHash[unitName] = buildProgress
  end

  # clear the aggregateProductionHash before we check on what's still building
  # things that were previously building but no longer building will be accurately reported as "0" in progress with this
  $aggregateProductionHash.each_pair do |name, count|
    $aggregateProductionHash[name] = 0
  end

  if (productionProgressHash.size > 0)
    productionProgressHash.each_pair do |name, buildProgress|
      sendOSCMessage(OSC_ADDRESS_PREFIX + bankName, name, 's', buildProgress, 'f')

      # after sending the build progress for this unit/building, increment the number of units/buildings of this type
      # being tracked in the aggregate production hash
      nameWithoutId = name.gsub(/.*?(?=-)/im, '').gsub('-', '') # '1-Pylon' to just 'Pylon'
      $aggregateProductionHash[nameWithoutId] = $aggregateProductionHash[nameWithoutId] + 1
    end

    puts '' if PRINT_DATA # makes logs a bit easier to digest
  else
    if (bankName == 'unitProductionBank.SC2Bank')
      sendOSCMessage(OSC_ADDRESS_PREFIX + bankName, 'no_unit_production', 's', '0.0', 'f')
    else
      sendOSCMessage(OSC_ADDRESS_PREFIX + bankName, 'no_structure_production', 's', '0.0', 'f')
    end
  end

  # now send our aggregate production data
  $aggregateProductionHash.each_pair do |name, count|
    sendOSCMessage(OSC_ADDRESS_PREFIX + bankName, name, 's', count, 'i')
  end

  puts '' if PRINT_DATA # makes logs a bit easier to digest
end

# sends OSC message to address with 2 values: key and value. valueType defines value's type for OSC message tags; and
# keyType defines key's type
def sendOSCMessage(address, key, keyType, value, valueType)
  conn = UDPSocket.new

  # not sure why the OSC pack method does not handle this conversion for us...
  if valueType == 'i'
    value = Integer(value)
  end

  msg = Message.new(address, keyType + valueType, key, value)
  conn.send(msg.encode, 0, $serverHost, $serverPort)

  puts '%.3f' % secondsSinceStart() + ': ' + address + ' (' + msg.tags.gsub!(',', '') + '): ' + "#{key}, #{value}" if PRINT_DATA
end

# main file system listener function
def listenForBankUpdates()
  Listen.to(BANK_PATH, :filter => /\.SC2Bank$/, :latency => POLLING_LATENCY_SECONDS, :force_polling => true) do |modified, added|
    filesChanged = Set.new

    # add modified and add files to our set
    modified.each { |modifiedPath| filesChanged.add(modifiedPath) }
    added.each { |addedPath| filesChanged.add(addedPath) }

    # parse banks for each bank file
    filesChanged.each { |absolutePath| sendBank(absolutePath, File.basename(absolutePath)) }
  end
end

#
# "main" function
#

# quit unless our script gets the OSC destination address and port
unless ARGV.length == 2
  puts "USAGE: ruby bank_parser.rb OSCDestinationAddress OSCDestinationPort\n"
  exit
end

$serverHost = ARGV[0]
$serverPort = ARGV[1]

$aggregateProductionHash.default = 0;

listenForBankUpdates()
