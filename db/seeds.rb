# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)   
User.delete_all
u = User.create(:email => "gecos@guadalinex.org", :password => "gecos", :password_confirmation => "gecos", :username => "admin")
u.admin = true
u.save
User.create(:email => "soporte@gecos.com", :password => "gecos", :password_confirmation => "gecos", :username => "soporte")
