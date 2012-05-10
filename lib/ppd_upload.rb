module PPDUpload
  def self.save(host,incoming, make)
    if !incoming.nil? and incoming.size > 0
      basename = sanitized_basename(incoming.original_filename)
      filename = disk_filename("/var/www/files/ppds/", basename, make)
      write_file(filename, incoming)
      basename
    end
  end

  def self.ppd_uri(host,basename, make)
    
    [ host,'ppds',
      sanitized_filename(make),
      sanitized_basename(basename) ].join "/"
  end

  private

  def self.sanitized_filename(value)
    value.gsub(/[\/\?\%\*\:\|\"\'<>]+/, '_')
  end

  def self.sanitized_basename(value)
    sanitized_filename(value.gsub(/^.*(\\|\/)/, ''))
  end

  def self.disk_filename(basedir,basename, make)
    File.join(basedir,
              sanitized_filename(make),
              sanitized_basename(basename))
  end

  def self.write_file(filename, incoming)
    FileUtils.makedirs(File.dirname(filename))
    File.open(filename, "wb") do |f|
      buffer = ""
      while (buffer = incoming.read(8192))
        f.write(buffer)
      end
    end
  end
end
