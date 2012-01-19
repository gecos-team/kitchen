module PPDUpload
  def self.save(incoming, make, model)
    if !incoming.nil? and incoming.size > 0
      basename = sanitized_basename(incoming.original_filename)
      filename = disk_filename(basename, make, model)
      write_file(filename, incoming)
      basename
    end
  end

  def self.ppd_uri(basename, make, model)
    [ ChefAPI.configuration["ppd_uri_base"],
      sanitized_filename(make),
      sanitized_filename(model),
      sanitized_basename(basename) ].join "/"
  end

  private

  def self.sanitized_filename(value)
    value.gsub(/[\/\?\%\*\:\|\"\'<>]+/, '_')
  end

  def self.sanitized_basename(value)
    sanitized_filename(value.gsub(/^.*(\\|\/)/, ''))
  end

  def self.disk_filename(basename, make, model)
    File.join(ChefAPI.configuration["ppd_directory"],
              sanitized_filename(make),
              sanitized_filename(model),
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
