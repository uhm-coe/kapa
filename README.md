# KAPA

KAPA provides consolidated information tools to organize office records including personal information, electronic documents, calendars, tasks, messaging/notifications, etc....  Tools are distributed as [Rails Engine](http://guides.rubyonrails.org/engines.html) so that developers can easily customize designs and functions to fit your organizational needs.

## Features
- Identity Management with LDAP support
- Electronic Documents (file attachments, forms, and text documents)
- User and Task Management
- System Administration
- Calendars and Events (Under development)
- Messaging and Notifications (Under development)
- Data Visualization (Under development)

### Getting Started with KAPA App

  1. Install Rails 4.2.x and create a new Ruby on Rails Application.
  ```
  gem install rails -v 4.2.5 --no-rdoc --no-ri
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
  rake kapa:db:setup
  ``` 

  4. Go to KAPA Admin Console to start applocation development.

  Open your browser and go to ```application_root/kapa```.
  You can find default username and password in db/seed.rb

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

###License

Licensed under the GNU GPL v3.
Copyright: College of Education, University of Hawaiʻi at Mānoa