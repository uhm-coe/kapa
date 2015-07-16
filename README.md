#KAPA

KAPA provides consolidated information tools to organize student academic records including advising, courses,
transition points, field placements, electronic documents, etc....  Tools are distributed as [Rails Engine](http://guides.rubyonrails.org/engines.html) so that developers can easily customize designs and functions to fit your organizational needs.

##Features
- Demographic information
- Academic programs and transition points (i.e., admission, qualifying exam, proposal defense, graduation)
- Advising records
- Course registrations
- Field placements
- Documents (file attachments, test scores, forms)
- Assessments

### Getting Started with KAPA App
  1. Create a new Ruby on Rails Application.
  ```
  rails new your_app
  ```

  12. Add following lines to your ```Gemfile```
  ```
  gem 'kapa', :github => "https://github.com/uhm-coe/kapa.git"
  gem 'twitter-bootstrap-rails', :git => 'git://github.com/seyhunak/twitter-bootstrap-rails.git', :branch => 'bootstrap3'
  gem 'rails-csv-fixtures', :git => 'https://github.com/bfolkens/rails-csv-fixtures.git'
  ```
  Don't forget to run ```bundle update``` to update your gems!

  2. Install configuration files

  Run the following command to install required files to run the application.
  ```
  rails g kapa:install
  ``` 

  3. Setup MySQL database
 
  Current KAPA engine requires MySQL 5.5.  Update your config/database and run ```rake db:setup``` to generate database.

  4. Go to KAPA Admin Console to configure the application.

  Open your browser and go to ```localhost:3000/kapa```.  
  You can find default username and password in db/schema.rb

### Customizing KAPA App
  Any code in KAPA Engine including controllers, models, and views can be modified/extended in your application.   We provide ```rails g kapa:cp``` command to copy engine source code to your application.

  1. Customizing views

  When Rails renders a view, it will first look in the app/views directory of your application. If it cannot find the view there, it will check in the app/views directories of KAPA engine.  Therefore, to customize views, you simply need to copy a view file from the engine to your app and start editing from there.  

  For example, the following command will copy the main layout file from the engine and place in the corresponding directory.
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