require "./faktory_worker/**"
require "logger"
module Faktory
  VERSION = "0.1.0"

  ## TODO(Jack): these can be lazy and not exposed to nil
  #              Maybe another wat to handle this Config class?
  @@log : Logger?
  @@producer : Producer?
  @@provider : String?
  @@url : String?

  protected def self.create_logger : Logger
    logger = Logger.new(STDOUT)
    logger.level = Logger::INFO
    logger.progname = "faktory.cr"
    logger.formatter = Logger::Formatter.new do |severity, datetime, progname, message, io|
      label = severity.unknown? ? "ANY" : severity.to_s
      io << label[0] << ", [" << datetime.to_utc << " #" << Process.pid << "] "
      io << label.rjust(5) << " -- " << progname << ": " << message
    end
    return logger
  end

  protected def self.log : Logger
    @@log ||= self.create_logger
  end

  protected def self.producer : Producer
    @@producer ||= Producer.new
  end

  def self.provider : String
    begin
      @@provider ||= ENV["FAKTORY_PROVIDER"] || "FAKTORY_URL"
      return @@provider.as(String)
    rescue
      Faktory.log.fatal("Missing FAKTORY_PROVIDER environment variable")
      raise "MissingProviderError"
    end
  end

  def self.url : String
    begin
      @@url ||= ENV[Faktory.provider || "tcp://localhost:7419"]
      return @@url.as(String)
    rescue
      Faktory.log.fatal("Unable to extract Faktory server URL from environment variable #{Faktory.provider}")
      raise "MissingURLError"
    end
  end

  def self.info : String
    Faktory.producer.info
  end

  def self.flush
    Faktory.producer.flush
  end

  def self.version : String
    Faktory::VERSION
  end
end
