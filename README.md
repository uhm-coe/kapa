# KAPA

A Rails engine for building institutional data management applications on top of an existing LDAP directory.

If your organization already has LDAP (universities, hospitals, government agencies, enterprises), KAPA bridges that identity source to a local person database and lets you attach structured data — forms, files, documents, and custom records — to those people. Access to records is controlled by department and role, matching how real organizations are structured.

```
LDAP (source of truth for identity)
    ↓  search / import via Person.lookup
Person (local mirror — name, contact info, ID)
    ↓  associations
Files · Forms · Letters · your own ActiveRecord models
```

KAPA handles the back-office plumbing so you can focus on your domain. Mount the engine, add your own models (courses, registrations, projects — whatever your organization needs), and inherit a working administrative portal with authentication, document management, and access control already in place.

Used in production at the [College of Education, University of Hawaiʻi at Mānoa](https://coe.hawaii.edu/assist/work/kapa/).

## What you get out of the box

**Person Registry**
Central record for people in your system — name, contact info, ID number, address normalization, and type classification. Each person record links to their documents, forms, files, and assigned users.

**Dynamic Forms**
Build form templates with custom fields through the admin UI. Forms are submitted, locked, and tracked against person records with full history. File attachments per form are supported.

**Document Generation**
Template-based letter and document generation. Define reusable text templates with merge fields, generate personalized documents, and attach them to person records.

**File Management**
File upload and attachment to any record — persons, forms, or your own custom models via polymorphic associations.

**Role-Based Access Control**
User accounts with department scoping, configurable access levels per feature area, and per-record user assignments. Supports local authentication (scrypt), LDAP, and CAS single sign-on.

**Configurable Property Tables**
Manage dropdown options and lookup values through the admin UI without code changes — statuses, types, terms, and any categorical data your organization uses.

**Notifications and Messaging**
Internal notification and messaging system for staff communication around records and tasks.

**Reports**
Built-in pivot table and C3 chart support for building tabular and visual reports against your data.

## Getting Started

### Requirements

- Ruby 3.x
- Rails 8.1
- MySQL

### Installation

1. Create a new Rails application:

   ```
   rails new your_app --database=mysql
   ```

2. Add KAPA to your `Gemfile` and run `bundle install`:

   ```ruby
   gem 'kapa', github: 'uhm-coe/kapa', branch: 'master'
   ```

3. Install configuration files:

   ```
   rails g kapa:install
   ```

4. Set up the database:

   ```
   rails db:migrate
   rails db:seed
   ```

5. Start the server and log in:

   Open `http://localhost:3000` in your browser. Log in with `admin` / `admin` (defined in `db/seeds.rb` — change this immediately in production).

### LDAP Configuration

Enable LDAP authentication and person lookup in `config/initializers/ldap.rb`:

```ruby
Rails.configuration.ldap_base = "ou=people,dc=example,dc=edu"
Rails.configuration.ldap_settings = {
  host: "ldap.example.edu",
  port: 389,
  encryption: { method: :simple_tls },
  auth: {
    username: Rails.application.credentials.ldap_username,
    password: Rails.application.credentials.ldap_password
  }
}
```

KAPA maps LDAP entry attributes to `Person` fields using sensible defaults. Override them if your directory uses different attribute names:

```ruby
Rails.configuration.ldap_person_attr_map = {
  uid:        "uid",           # default — login attribute used for authentication
  first_name: "givenName",     # default
  last_name:  "sn",            # default
  email:      "mail",          # default
  id_number:  "employeeNumber" # override — e.g. "uidNumber", "uhuuid", "employeeID"
}
```

With LDAP configured, `Kapa::Person.lookup(key)` searches the local database first, then falls back to LDAP automatically. The returned person is an unsaved `Person` record — your controller decides whether to persist it.

To authenticate users via LDAP, set `category: "ldap"` on the `User` record. Local password authentication remains available by setting `category: "local"`.

## Customization

KAPA is designed to be extended, not forked. All controllers, models, and views can be overridden in your application without touching the engine source.

### Generating a new resource

The scaffold generator creates a migration, model, controller, and Bootstrap views wired to KAPA's access control and form helpers:

```
rails g kapa:scaffold ProjectApplication title:string status:string note:text
```

This generates:

- A migration with the given columns plus `dept`, `yml`, `json`, and timestamps
- A model inheriting from `Kapa::KapaModel`
- A controller with full CRUD inheriting from `Kapa::KapaController`
- Bootstrap views: index (paginated table with search modal), show (tabbed form), new, and a reusable form partial
- A route entry in `config/routes.rb` and a permission entry in `config/initializers/kapa.rb`

After generating, restart the server and run `rake kapa:admin:user_role` to grant the admin role access to the new resource.

### Extending built-in models and controllers

KAPA uses `ActiveSupport::Concern` for all  built-in models and controllers, keeping the baseline separate from your customizations. To extend a model:

```
rails g kapa:cp models/kapa/person.rb
```

Then add your methods to the copied file:

```ruby
# app/models/kapa/person.rb
class Kapa::Person < Kapa::KapaModel
  include Kapa::PersonBase

  def full_name_with_id
    "#{full_name} (#{id_number})"
  end
end
```

The same pattern applies to controllers — copy the base controller and add or override actions as needed.

### Overriding built-in views

Rails checks your application's `app/views` before the engine. Copy any view file to the same relative path in your app and edit from there.

Use the `kapa:cp` generator to copy engine files into your app:

```
rails g kapa:cp views/kapa/layouts/kapa.html.erb
```

## License

Licensed under the GNU GPL v3.
Copyright: College of Education, University of Hawaiʻi at Mānoa
