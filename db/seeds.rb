# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)   
User.delete_all
u = User.create(:email => "admin@gecos.com", :password => "admin..", :password_confirmation => "admin..")
u.admin = true
u.save
User.create(:email => "soporte@gecos.com", :password => "soporte..", :password_confirmation => "soporte..")