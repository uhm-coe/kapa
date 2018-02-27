# KAPA

KAPA is a framework to build office database system and provides tools to organize various office records including personal information, electronic documents, calendars, tasks, messaging/notifications, etc....  

This framework is distributed as [Rails Engine](http://guides.rubyonrails.org/engines.html) so that developers can easily customize designs and functions to fit your organizational needs.  

KAPA works as an essential codebase, and you can add business objects for your organization.  For example, academic institutions may want to add Course, Registration, and Assignment to keep track of assessments.  Please check [this page](https://dcdc.coe.hawaii.edu/kapa/) to see the examples of applications developed with KAPA.

## Features
- Identity Management with LDAP support
- Electronic Documents (file attachments, forms, and text documents)
- User and Task Management
- System Administration
- Calendars and Events (Under development)
- Messaging and Notifications (Under development)
- Data Visualization (Under development)

### Getting Started with KAPA App

  1. Install Rails 5.1.x and create a new Ruby on Rails Application with MySQL Support.
  ```
  gem install rails
  rails new your_app -d mysql
  ```

  2. Add the following line to your ```Gemfile```
  ```
  gem 'kapa', :github => "uhm-coe/kapa"
  ```
  Don't forget to run ```bundle update``` to update your gems!

  2. Install configuration files

  Run the following command to install required files to run the application.
  ```
  rails g kapa:install
  ``` 

  3. Setup MySQL database
 
  Current KAPA engine requires MySQL database.  Update your config/database.yml and run the following command to generate initial database schema.
  ```
  rake db:migrate
  rake db:seed
  ``` 

  4. Start webserver and login to the system.

  Start webserver and ppen your browser and go to applcaiton root, i.e.,  ```http://localhost:3000```.
  You should be able to login with username=admin, password=admin.  The default username and password is defined in db/seed.rb

### Customizing KAPA App
  Any code in KAPA Engine including controllers, models, and views can be modified/extended in your application.   You can use ```rails g kapa:cp``` command to copy engine source code to your application.

  1. Customizing views

  When Rails renders a view, it will first look in the app/views directory of your application. If it cannot find the view there, it will check in the app/views directories of KAPA engine.  Therefore, to customize views, you simply need to copy a view file from the engine to your app and start editing from there.  

  To simplify this process, we implemented kapa::cp generator, which copies a file from the engine and place in the corresponding directory in your app. For example, the following command will copy the main layout file from the engine and place in app/views/kapa/layouts/.
  ```
  rails g kapa:cp views/kapa/layouts/kapa.rb
  ``` 

  2. Overriding/Extending controllers/models

  ```ActiveSupport::Concern``` is used to implement controllers and models in KAPA. ```ActiveSupport::Concern``` manages load order of dependent modules and allow us to keep baseline code separate from custom code.  The following example shows how to override Kapa::Person model.

  Run ```rails g kapa:cp models/kapa/person.rb``` to copy ```person.rb``` to your application.
  Add new method in ```person.rb```
  ```
  #app/model/kapa/person.rb
  class Kapa::Person < Kapa::KapaModel
    include Kapa::PersonBase

    def new_method
      #do something
    end
  end
  ```

### License

Licensed under the GNU GPL v3.
Copyright: College of Education, University of Hawaiʻi at Mānoa