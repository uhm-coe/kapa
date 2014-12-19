#KAPA

KAPA provides consolidated information tools to support academic program administration including Advising, Admission, Graduation, Praxis, and Field Placement.  Tools are distributed as [Rails Engine](http://guides.rubyonrails.org/engines.html) so that developers can easily customize designs and functions to fit your organizational needs.

##Features
- Transition Points (i.e., Admission, Declaration of Intent, Qualifying Exam, Proposal Defense, Graduation)
- Course-based Assessments
- Program-based Assessments
- Cohort tracking
- Advising records
- Scanned documents associated to student records
- Field placements
- Graduation auditing

##Development
This project is still in alpha stage, and there are many tasks we need to complete before releasing the initial version. Please let us know if you are interested in contributing this project.

Here is how to get started with KAPA development.

### Preparation
  1. Get familiarized yourself with Ruby on Rails (Current Kapa is based on Rails 3.1)
  2. Establish GitHub account.
  3. Install Git on your machine and set up your Git profile.
  
### Checkout Source Code
  1. Checkout source code.
  ```
  git clone https://github.com/uhm-coe/kapa.git
  ```

### Setup Development environment
  Current KAPA is being tested with Ubuntu 12.04 and Ruby 1.9.3.  We found that using vagrant is very useful for keeping consistent development environments.  While it is possible to set up your own development environment, we highly recommend to use vagrant.
 
  1. Follow [this instruction](http://docs.vagrantup.com/v2/installation/index.html) and install Virtual Box and Vagrant.
  2. Go to the application directory and start virtual machine. Please be aware that the initial launch of the virtual machine will take several minutes since the server provision script will download and install all necessary packages, i.e., Ruby, Apache, and MySQL to run a Ruby on Rails application.
  ```
  cd kapa
  vagrant up
  ```
  3. SSH to the virtual machine.
  ```
  vagrant ssh
  ```
  4. Go to the application directory in the virtual machine and run setup commands.
  ```
  cd /vagrant/test/dummy
  rake db:setup
  ```
  Now, you are running KAPA on your machine.  Open a web browser and try entering following URLs.
  ```
  http://localhost:8080
  ```
  
  5. Login with the following credential.
  ```
  uid: admin
  password: admin
  ```
