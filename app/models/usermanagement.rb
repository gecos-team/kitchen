class Usermanagement < ChefBase

  API_ROUTE = "/data/users"

  def initialize(attributes = {})
    attributes.each_pair { |key, value|
         metaclass.send :attr_accessor, key.gsub("?","")
         send "#{key.gsub("?","")}=".to_sym, value
       }
     @@attributes = attributes


     attributes.keys.each do |attr|
       if send(attr).class.name == "Hash"

         send(attr).keys.each do |subattr|
            metaclass.send(:define_method, "#{attr}_#{subattr}") do
              send(attr)[subattr]
            end
         end
       end


     end

  end

  def name
    id
  end

  def name=(value)
    self.id = value
   end

  def self.find_or_create(id)

    md5 = Digest::MD5.hexdigest(id)

    user = Usermanagement.find(md5)

    if user.blank?
      skel = Usermanagement.find("user_skel").to_json
      skel["id"] = md5
      skel["username"] = id
      ChefAPI.post("/data/users", skel)
    end

     Usermanagement.find(md5)
  end

  def self.find_or_default(id)

    md5 = Digest::MD5.hexdigest(id)

    user = Usermanagement.find(md5)

     user.blank? ? Usermanagement.find("user_skel") : user

  end


end