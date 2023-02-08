# KAPA

KAPA is a [Rails Engine](http://guides.rubyonrails.org/engines.html) to build office database system and provides tools to organize various office records including personal information, electronic documents, calendars, tasks, messaging/notifications, etc....  

KAPA works as an essential codebase, and you can add business objects for your organization.  For example, academic institutions may want to add models such as Course, Registration, and Assignment to keep track of assessments.  Please check [this page](https://coe.hawaii.edu/assist/work/kapa/) to see the examples of applications developed with KAPA.

## Features
- Identity Management with LDAP support
- Electronic Documents (file attachments, forms, and letters)
- User and Task Management
- System Administration
- Calendars and Events (Under development)
- Messaging and Notifications (Under development)

### Getting Started with KAPA App

  1. Install Rails 5.1.x and create a new Ruby on Rails Application with MySQL Support.
  ```
  gem install rails
  rails new your_app --database=mysql --skip-turbolinks
  ```

  2. Add the following line to your ```Gemfile``` and run ```bundle install``` to isntall gems.
  ```
  gem 'kapa', :github => "uhm-coe/kapa"
  bundle install
  ```

  3. Install configuration files

  Run the following command to install required cofnigration to run KAPA application.
  ```
  rails g kapa:install
  ``` 

  4. Setup MySQL database
 
  KAPA engine requires MySQL database.  Update your config/database.yml and run the following command to generate initial database schema.
  ```
  rake db:migrate
  rake db:seed
  ``` 

  5. Start your web server and login to the system.

  Start web server and open your web browser to navigate to the applcaiton root, i.e.,  ```http://localhost:3000``` on your web browser.  You should see the the welcome screen of KAPA.
  Login with username=admin, password=admin (The default username and password are defined in db/seed.rb).

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
