# THINGS IN HERE
- from Intro to Ruby on Rails 7 Fullstack Tutorial - https://www.youtube.com/watch?v=TlgSp2XPCY4&list=PL3mtAHT_eRezB9fnoIcKS4vYFjm23vddb

## GIT NOTES
- git clone https://github.com/Deanout/blog_application.git
- git branch -a (to see all the different branches)
- git checkout Episode-3 (to see each episode)
- git checkout -b styling (create a new branch)
- git checkout master ( to go to master)
- git merge styling (to merge changes from the styling branch)

## GEMS

```
group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'better_errors'
  gem 'binding_of_caller'  
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end
gem 'devise'
gem "noticed"
gem "ransack"
gem "friendly_id"
gem "bullet"
gem "activerecord-import"
gem "wicked"

gem "stripe", "~> 7.1"
gem "pay", "~> 5.0"

gem "ahoy_matey", "~> 4.1"

gem "groupdate", "~> 6.1"

gem "chartkick", "~> 4.2"

gem "acts_as_list", "~> 1.0"

gem "whenever", "~> 1.0"

```

### ADDING STRIPE

- editing the credentials

```
EDITOR="subl --wait" rails credentials:edit

stripe:
  secret_key: sk_test_...
  public_key: pk_test_...
  webhook_secret: whsec_...
```

## OTHER
- how to create a local network for the app

```
- creating a local network: rails server -b 0.0.0.0 -p 8000
```


## STEPS

### VIDEO 1
- rails new blog_demo
- controller pages home about
- updated root page
- changed about path to get 'about', to: 'pages#about'
- cdn bootstrap
- created navbar partial
- rails g scaffold Post title body:text
- explained what views/model/controllers are based on posts

### VIDEO 2 devise/posts
- seeded posts
- added views:integer to posts
- updated the views in the posts show controller
- added devise and rails 7 turbo update: https://dev.to/efocoder/how-to-use-devise-with-turbo-in-rails-7-9n9
- added an alerts partial
- devise User
- created session manager partial for devise links
- authenticate post
- add users to post
- rails g migration add_user_to_posts user:belongs_to
- (there would be errors if posts are already created, just drop and start again)
- added a seed file
- rails g migration AddNameToUser name
- rails g devise:views
- added the name to the new/edit registrations forms
- added current user to posts in post controller
- rails g devise:controllers users
- updated the routes

```
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
```

- updated the users/registrations_controller to allow the name field
- rails g controller users profile
- updated the profile method to update users views
- and updated the routes

```
  get 'users/profile'
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  get '/u/:id', to: 'users#profile', as: 'user'

```

- rails g migration AddViewsToUser views:integer (default: 0 in the migration file)
- posts order by created at desc

### VIDEO 3 - action text/comments/

- rails g model Comment post:belongs_to user:belongs_to
- rails action_text:install
- created comments folder/form
- comments nested route in routes
- comments controller
- added comments to show action in post controller
- added comments form and show to bottome of post show page
- updated the comments/post/user models with validations, has rich text and associations

### VIDEO 4 - updating comments with stimulus
- added second account to seeds
- seeds search https://ninjadevel.com/seeding-database-ruby-on-rails/
- seeding csv https://blog.devgenius.io/how-to-seed-with-ruby-on-rails-%EF%B8%8F-1d2dceda3e7d
- added edit options to the comments and updated at and created at times based on creation or edit
- the edit button displays a form using stimulus controller/comments controller
- updated the post show page to use stimulus
- updated the comment form

### VIDEO 5 - adding comment notification with noticed gem and stimulus updates
- add 'noticed' gem
- rails g noticed:model
- update user model
- rails g noticed:notification CommentNotification
- update posts with notification
- update comments with the notification logic

```
  after_create_commit :notify_recipient
  before_destroy :cleanup_notifications
  has_noticed_notifications model_name: 'Notification'

  private

  def notify_recipient
    CommentNotification.with(comment: self, post: post).deliver_later(post.user)
  end

  def cleanup_notifications
    notifications_as_comment.destroy_all
  end
end
```

- add notification and notifications partials to layouts folder
- add render layouts notifications to navbar partial
- set default notifications to application controller
- updated the notifications/comment_notifications file
- (for postgresql database, the json should be jsonb)

```
class CreateNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications do |t|
      t.references :recipient, polymorphic: true, null: false
      t.string :type, null: false
      t.jsonb :params
      t.datetime :read_at

      t.timestamps
    end
    add_index :notifications, :read_at
  end
end
```

- update posts controller show to update the notification
- added font bootstrap via cdn to the layout application
- in the notifications he did an or erb statement

```
<%= @unread.count >= 9 ? "9+" : @unread.count %> 
```

- updated the edit button to say cancel in the comments form with stimulus

### VIDEO 6 - adding ransack (he has an advanced version on youtube on ransack search and sort)
- add gem "ransack", "~> 2.5"
- rails g controller search index
- update the index action in the search controller
- update the search index view
- create the search form partial in the search folder
- update the routes
- add the search form to the navbar
- add the set query method to the application controller

### VIDEO 7 - admin dashboard/improve searches
- rails g migration add_role_to_user role:integer
- rails g migration remove_body_from_post
- update the migration to remove body, because we are using action text

```
remove_column :posts, :body, :text
```

- update user model with enum for admin

```
  enum role: %i[user admin]
  after_initialize :set_default_role, if: :new_record?


  private

  def set_default_role
    self.role ||= :user
  end
```

- updated the seed file
- updated post model with has_rich_text :body, since we removed it up top
- get rid of and length requirements on validates body, because it will interfere with images or large text entered in the rich text
- and added a content, this is because has_rich_text would make the search as post.body.body, so this only does one

```
has_rich_text :body
  has_one :content, class_name: 'ActionText::RichText', as: :record, dependent: :destroy
```
- update the form to include the 'content'

```
<%= search_form_for(@query, url: search_path, method: :get, class:'d-flex') do |f| %>
  <%= f.search_field :title_or_content_body_or_user_email_or_user_name_i_cont_any,
   placeholder: "Search...",
   class: "form-control me-2" %>
  <%= f.submit "Search!", class:"btn btn-outline-success" %>
<% end %>
```

- update the search index because body doesnt have truncate now, so make it plain text

```
<td><%= post.body.to_plain_text.truncate_words(25) %></td>
```

- update post form partial to have rich text body

```
<%= form.rich_text_area :body %>
```

- SETTING UP THE ADMIN
- added the admin link to user/session manager navbar partial
- rails g controller admin index posts comments users show_post
- update the routes with the admin authenticated user route if logged in, if user is admin the root path changes (the cool thing is that if you go to /admin and not logged in, it'll appear like that page doesnt even exist)

```
  authenticated :user, ->(user) { user.admin? } do
    get 'admin', to: 'admin#index'
    get 'admin/posts'
    get 'admin/comments'
    get 'admin/users'
    get 'admin/post/:id', to: 'admin#show_post', as: 'admin_post'
  end
```

- update the admin controller 
- uses includes so it only hits the data base once

```
  def posts
    @posts = Post.all.includes(:user, :comments)
  end
```

- updated the admin views
- cool link tricks here

```
_nav_links.html.erb
<div class="container text-center">
  <p>
    <%= link_to "Admin", admin_path %><%= " > #{params[:action].capitalize}" unless params[:action].eql?("index") %>
  </p>
  <div class="btn-group">
    <%= render "admin/link", resource: Post %>
    <%= render "admin/link", resource: Comment %>
    <%= render "admin/link", resource: User %>
  </div>
</div>

_link.html.erb
<%= link_to resource.name.capitalize, url_for([:admin, resource]), class:'btn btn-primary' %>
```

### VIDEO 8 - SEO Friendly URLs with Friendly ID Gem
- add the gem gem "friendly_id", "~> 5.4"
- rails g migration AddSlugToPosts slug:uniq
- rails g friendly_id
- add freindly id to post
- added a method to update posts that were already there instead of doing it through rails console
- updated each post in rails c
```
Post.find_each(&:save)
```

- updated the post with history and the post controller for redirects in case the friendly id changes at some point

```
friendly_id :title, use: %i[slugged history finders]
  def set_post
    @post = Post.friendly.find(params[:id])
    # If an old id or a numeric id was used to find the record, then
    # the request slug will not match the current slug, and we should do
    # a 301 redirect to the new path
    redirect_to @post, status: :moved_permanently if params[:id] != @post.slug    
  end
```

- update the post.rb with 'finders', so you don't have to put Post.friendly.find everywhere

```
friendly_id :title, use: %i[slugged history finders]
```

### VIDEO 9 - N+1 Query And Performance Optimizations
- add gem "bullet"
- rails g bullet:install
- go to homepage, error on the search query
- add includes to application controller
- go to blog index, get errors, update posts controller index

```
@posts = Post.includes(:user, :rich_text_body).all.order(created_at: :desc)
```

- go to post show page, error, update posts controller show

```
@comments = @post.comments.includes(:user, :rich_text_body).order(created_at: :desc)
```

- go to admin page, click posts, error, update admin controller
```
@posts = Post.all.includes(:user)
```

- counter cache error, update comment.rb
```
belongs_to :post, counter_cache: true
```

- need to create a migration for the counter cache: rails g migration AddCommentCounterCacheToPosts comments_count:integer
- we need to populate the comments counter with a migration: rails g migration PopulatePostCommentsCount --force
- update the migration

```
  def change
    Post.all.each do |post|
      Post.reset_counters(post.id, :comments)
    end
  end
```

- refresh the admin page/posts
- i did the admin show post one myself
- he then deleted the database and seeded it with 100 posts, to benchmark what we have been doing
- he updated the seed file, with a way to import records quicker, with the gem: gem "activerecord-import", "~> 1.3"

```
# using: gem "activerecord-import", "~> 1.3"

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
User.create(email: 'dean@example.com',
            password: 'password',
            password_confirmation: 'password',
            name: 'Dean',
            role: User.roles[:admin])
User.create(email: 'john@doe.com',
            password: 'password',
            password_confirmation: 'password',
            name: 'John Doe')

posts = []
comments = []

elapsed = Benchmark.measure do
  1000.times do |x|
    puts "Creating post #{x}"
    post = Post.new(title: "Title #{x}",
                    body: "Body #{x} Words go here Idk",
                    user_id: User.first.id)
    posts.push(post)
    10.times do |y|
      puts "Creating comment #{y} for post #{x}"
      comment = post.comments.new(body: "Comment #{y}",
                                  user_id: User.second.id)
      comments.push(comment)
    end
  end
end

Post.import(posts)
Comment.import(comments)

puts "Elapsed time is #{elapsed.real} seconds"

```

### VIDEO 10 - Switch To PostgreSQL In Rails And Nested N+1 Query Fixes 
- setup postgresql
- https://www.digitalocean.com/community/tutorials/how-to-install-postgresql-on-ubuntu-20-04-quickstart
- update from sqlite to postgresql
- https://gorails.com/episodes/rails-6-db-system-change-command
- because switching to postgresql he had to change the 'notifications' migration to 'jsonb'
- updated the comment.rb file because the notifications were being sent even if the user commented on his own post
```
  def notify_recipient
    return if post.user == user

    CommentNotification.with(comment: self, post: post).deliver_later(post.user)
  end
```

- updated the admin show post, doing a nested include, not how I did it

```
  def show_post
    @post = Post.includes(:user, comments: [:user, :rich_text_body]).find(params[:id])
  end
```

### VIDEO 11 - Devise Onboarding With Wicked Gem

- add the gem "wicked"
- rails g migration AddNamesToUser first_name last_name
- rails g model address street city state zip:integer country user:references
- update the migration: 

```
t.references :user, foreign_key: true
```

- rails g migration AddAddressToUser address:references
- update migration
```
    add_reference :users, :address, foreign_key: true

```
- rails g migration RemoveNameFromUser name
- UPDATING THE SEEDS WITH FILES
- updated the seed files and added the folder
- didnt work because of the .import
- added gem "activerecord-import"
- rails db:reset
- updated the search form with user first and last name

```
<%= f.search_field :title_or_content_body_or_user_email_or_user_first_name_or_user_last_name_i_cont_any,
   placeholder: "Search...",
   class: "form-control me-2" %>
```

- update session manager

```
<%= current_user.full_name %>
```

- add the method to user.rb

```
  def full_name
    "#{first_name.capitalize unless first_name.nil?} #{last_name.capitalize unless last_name.nil?}"
  end
```

- update post partial: full_name
- update comment partial: user.email to full_name
- update admin show-post: full_name
- update admin posts: full_name
- update profile page: full_name
- INTEGRATING WICKED GEM
- website he referenced: https://www.joshmcarthur.com/2014/12/23/rails-multistep-forms.html
- create after_signup controller
- update user.rb a lot of steps
- update users/registrations controller
- add the after_signup to views/
- update the devise/regi/new
- add the routes: resources :after_signup
- update devise/reg/edit to include address and name
- updated the home page with address info
- rails s and test it out, it worked

### VIDEO 12 - Your First Real Ticket As A Software Developer
- gave the info to add categories to the app

### VIDEO 13 - Implementing Your First Ticket
- rails g scaffold Category name display_in_nav:boolean
- rails g migration AddCategoryToPosts category:belongs_to
- update the migration file

```
t.boolean :display_in_nav, default: false
```
- update the seed file
- rails drop/create/migrate/seed
- updated the search/index with full_name
- updated search controller index action

```
@query = Post.includes(:user, :rich_text_body).ransack(params[:q])
```

- ADDING CATEGORIES TO THE NAVBAR
- add categories partial to navbar

```
<%= render "layouts/categories", categories: @nav_categories %>
```

- create the categories partial

```
<div id="<%= dom_id category %>">
  <h2>
    <% target = action_name.eql?("show") ? categories_path : category %>
    <%= link_to category.name, target %>
  </h2>
  <% category.posts.includes(:user, :rich_text_body).each do |post| %>
    <%= render "posts/post", post: post %>
  <% end %>
</div>
```

- set the categories in the application controller
- update categories controller with admin
- update app controller with admin
- updated the categories views
- add the link to session manager
- added to categories controller

```
before_action :is_admin?, except: %i[show index]
```

- add to app controller

```
  def is_admin?
    unless current_user&.admin?
      flash[:alert] = 'You are not authorized to perform this action.'
      redirect_to root_path
    end
  end  

```

- added the post form, category

```
<%= form.select :category_id, options_for_select(Category.all.order(name: :desc).collect { |cat| [cat.name, cat.id]})%>
```

- updated the search form adding category name

```
<%= search_form_for(@query, url: search_path, method: :get, class:'d-flex') do |f| %>
  <%= f.search_field :title_or_content_body_or_user_email_or_user_first_name_or_user_last_name_or_category_name_i_cont_any,
   placeholder: "Search...",
   class: "form-control me-2" %>
  <%= f.submit "Search!", class:"btn btn-outline-success" %>
<% end %>
```

- update the search index to add categories to the results
- udpate post params in post controller to add category

```
  def post_params
    params.require(:post).permit(:title, :body, :category_id)
  end
```

- refresh and test out

### VIDEO 14 - Creating User Profile Pages For Blog Authors
- adding user avatar
- add to user.rb: has_one_attached :avatar
- update userrevistrations controller

```
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:email,
                                                              :avatar,
                                                              :first_name,
                                                              :last_name,
                                                              :password,
                                                              :password_confirmation,
                                                              :current_password,
                                                              { address: %i[street city state zip country] }])
  end

```
- update the registration view

```
  <div class="field">
    <%= f.label :avatar %><br />
    <%= f.file_field :avatar %>
  </div>
```

- update the user profile page
- update profile method in uusers controller and the views count

```
  def profile
    @user.update(views: @user.views + 1)
    @posts = @user.posts.includes(:rich_text_body).order(created_at: :desc)
    @total_views = 0

    @posts.each do |post|
      @total_views += post.views
    end
  end
```

### VIDEO 15 - Payments With Stripe And Pay Gem
- https://stripe.com/docs/stripe-cli
- https://dashboard.stripe.com/login?redirect=%2Ftest%2Fapikeys
- https://github.com/pay-rails/pay
- first start with the cli installing
- stripe listen --forward-to localhost:3000/pay/webhooks/stripe
- editing the credentials

```
EDITOR="subl --wait" rails credentials:edit

development:
  stripe:
    # publication key:
    public_key: ***
    # secret key:
    private_key: ***
    signing_secret: ***
```

- bundle add stripe pay
- rails pay:install:migrations
- add to config/app.rb

```
# config/application.rb
config.action_mailer.default_url_options = { host: "example.com" }
```

- add the routes

```
  get 'checkout', to: 'checkouts#show'
  get 'checkout/success', to: 'checkouts#success'
  get 'billing', to: 'billing#show'
```

- rails g controller checkouts
- update the user.rb file with stripe code
- update the checkouts controller with the code and the product (need to see how to add an item list, he just did one)
- add the views/checkouts show and success pages
- rails g migration AddBillingLocationToUser city country (theres a customer info object that can be done cleaner)
- added a link to the home page to the checkout page
- add the javascript to the layout app html file

```
    <script src="https://js.stripe.com/v3/"></script>
```

- refresh and click the button
- IT WORKED, even though we didnt put the Rais.env.public_key thing anywhere
- adding a portal session for the user
- update the home page with the link

```
    <%= link_to "Manage Billing", @portal_session.url %>
```

### VIDEO 16 - Monthly Subscriptions With Stripe And Pay Gem
- https://stripe.com/docs/api/subscriptions
- rails g migration AddCustomerInfoToUser subscription_status subscription_end_date:datetime subscription_start_date:datetime
- create a models/subscription_concern.rb
- update user.rb 

```
include SubscriptionConcern
```

- rails g controller members dashboard
- update the home page how the checkout button works, and link to portal session
- update checkout controller to receive the parameters being sent
- udated pages controller with portal sessions logic

```
had an error, had to save this at stripe
https://dashboard.stripe.com/test/settings/billing/portal
```

- added the members path on the navbar
- refresh, try it, IT WORKED

### VIDEO 17 - The VSCode Rails Extensions Used In This Series
- nothing i need, not using vscode

```
Timestamps
0:00 Emmett And How It Works
2:27 GitHub Copilot!
3:19 GitLens! See Your Commit History
5:00 Prettier!
5:23 Ruby!
5:32 Ruby Extension Pack
5:45 Ruby Solargraph!
6:25 Ruby Test Explorer
6:39 Rubocop!
7:40 TabNine (Free Version) Is A Good CoPilot Simulator
8:43 YAML Extension
9:04 Vue Extensions
9:54 React Extensions
10:37 Additional Flavor Rails Extensions
```

### VIDEO 18 - Overview Of GitHub And Rails 7
- HOW TO USE GITHUB 
- actions/pull requests/issues etc.

### VIDEO 19 - Live Coding A Beginner Portfolio Project
- rails g scaffold project title link 
- add the link to navbar
- add is admin to projects controller
- update projects index
- update session manager with new project link
- update project.rb with

```
has_rich_text :body
```

- update project controller params

```
    params.require(:project).permit(:title, :link, :body)
```

- add body text area field to project form
- update project partial
- using current user and admin in same line
- udpate project show page 

```
if current_user&.admin?
```

### VIDEO 20 - Procedural Terrain Generation Beginner Portfolio Project
- I didnt do it

### VIDEO 21 - Track And Graph Monthly Views
- bundle add ahoy_matey (to use with graph for tracking views)
- rails g ahoy:install
- SOME OF THIS DATA MAY NOT BE GDPR COMPLIANT, PROTECTING PEOPLES DATA
- rails db:migrate
- add to post controller show method

```
    ahoy.track 'Viewed Post', post_id: @post.id
```

- bundle add groupdate
- update post.rb with the views_by_day methods
- bundle add chartkick
- add to importmap.rb

```
pin 'chartkick', to: 'chartkick.js'
pin 'Chart.bundle', to: 'Chart.bundle.js'

```
- add to app.js

```
import "chartkick";
import "Chart.bundle";

```

- add the area_chart to admin/show_post
- add partial to admin/index

```
<%= render partial: 'admin/total_daily_views' %>
```

- create the admin/ total daily views partial
- update the seed file
- REALLY COOL SEED TECHNIQUES
- used rand(1..5)
- rails db:reset
- it worked

### VIDEO 22 - Drag And Drop With Stimulus JS
- its gonna be with projects
- create a few projects
- update project controller

```
@projects = Project.all.includes([:rich_text_body]).order(position: :asc)
```

- bundle add acts_as_list
- rails g controller drag
- rails g stimulus drag
- rails g migration AddPositionToProjects position:integer
- update the migration

```
  def change
    add_column :projects, :position, :integer
    Project.order(:updated_at).each.with_index(1) do |project, index|
      project.update_column :position, index
    end
  end
```

- the update is if you had projects or data already in the database, if not then its not needed
- update projects/index with the draggable partial
- create the draggable partial
- update drag controller
- update the js/controller/drag controller
- update the routes with

```
patch 'drag/project'
```

- update project.rb

```
acts_as_list
```
- refresh and test out, IT WORKED

### VIDEO 23 - Schedule Background Tasks With The Whenever Gem

- sudo apt install cron (in terminal to install cron)
- had to install java
- I dont think i needed to do that, apt is linux
- bundle add whenever
- bundle exec wheneverize .
- updated config/schedule

```
every 1.minutes do
  # runner 'puts Time.now'
  # runner 'puts Rails.env'
  runner "puts 'Hello, world'"
  # runner 'Category.scheduled_category'
end
```

- in terminal: crontab -r
- whenever --update-crontab
- whenever (to see whats in there)
- rails s (but we cant see the output so we have to do something for it to happen)
- update the schedule code

```
set :output, './log/cron.log'
every 1.minutes do
  # runner 'puts Time.now'
  # runner 'puts Rails.env'
  runner "puts 'Hello, world'"
  # runner 'Category.scheduled_category'
end

```
- in terminal: crontab -r
- whenever --update-crontab
- rails s
- check in app/log/cron.log and it worked
- this only runs in production, so we need to run it in development
- whenever --update-crontab --set environment='development'
- update schedule.rb

```
# Clear cron: crontab -r
# update cron: whenever --update-crontab
# update cron development: whenever --update-crontab --set environment='development'
# to see whats in there: whenever

set :output, './log/cron.log'

every 1.minutes do
  runner 'puts Time.now'
  runner 'puts Rails.env'
  runner "puts 'Hello, world'"
  runner 'Category.scheduled_category'
end
```

- https://www.freeformatter.com/cron-expression-generator-quartz.html
- to find different cron jobs
- he used: https://crontab.guru/
- update category.rb

```
  def self.scheduled_category
    Category.create(name: "Scheduled at #{Time.now}",
                    display_in_nav: true)
  end
```
- so the cron job will be creating one of those
- crontab -r
- whenever --update-crontab --set environment='development'
- refresh and rails s
- test it out, IT WORKED

### VIDEO 24 - Debugging And Logging
- add to the environment.rb

```
Rails.logger = Logger.new("log/#{Rails.env}.log")
Rails.logger.level = Logger::INFO

Rails.logger.datetime_format = '%Y-%m-%d %H:%M:%S'
Rails.logger.formatter = proc do |severity, datetime, progname, msg|
  "|#{datetime}|#{severity}|#{progname}|#{msg}\n"
end
Rails.logger.info("Environment: #{Rails.env}") do
  'Started The Rails App!'
end

```

- update pages_controller

```
  def home
    Rails.logger.info('pages#home') do
      'Rendered the homepage'
    end    
    return unless current_user
    return if current_user.payment_processor.nil?

    @portal_session = current_user.payment_processor.billing_portal
  end
```

- rails s
- delete log/development.log content
- refresh the homepage
- checkout log/development.log content, it should be updated
- added to the gemfile, development group

```
group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'better_errors'
  gem 'binding_of_caller'  
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end
```

- in the view to see whats going on

```
<%= debug(current_user) %>
```

### VIDEO 25 - Debugging Ruby On Rails with VSCode BREAKPOINTS
- i didnt do it since its on vscode

```
0:00 Debugging A Rails 7 Application
3:08 Creating The launch.json File
5:14 Adding Your First Breakpoint To Rails 7!
5:48 Inspect Local Variables During Runtime!
6:22 How I Use A Debugger To Learn A New App At Work
9:51 Debug Different Ports, Environments, And IP Bindings
14:20 Use Debugger To See Source Code Of Rails And Gems
16:46 How To Stop Unresponsive Rails 7 App From Terminal
```
- installed a few apps: debase, ruby-debug-ide

```
group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mingw x64_mingw]

  ## These are for the debugger
  gem 'debase', '~> 0.2.4'
  gem 'ruby-debug-ide', '~> 0.7.3'
  ## End debugger gems
end
```

### VIDEO 26 - Rails Commands You Don't Know!
- rails db:prepare (if there is no database created, and postgres i think, it creates but it nots rails db:setup)
- rails db:seed:replant (it reseeds the database without dropping it)
- rails middleware (to see whats being used in the app)
- rails initializers (to see the initializers)
```
rails initializers | grep pay
rails initializers | grep devise
```

- rails stats (shows how many lines of code)
```
code LOC: shows the number of lines
test LOC: shows how many are being tested
```

- rails runner (to see things in the app without going to rails console)
```
rails runner 'puts "#{Post.count}"'
```

- rails time:zones (to see all the time zones available)
- just type: rails (to see all these commands)

### VIDEO 27 - Extend Action Text With An Emoji Popup Picker
- https://picmojs.com/docs/getting-started/overview/
- in terminal: bin/importmap pin picmo
- in terminal: bin/importmap pin @picmo/popup-picker
- rails g stimulus emoji-picker
- update the javascript/cont/emoji picker.js
- update post form partial with the picker code
- create the folder javascript/classes
- create the file RichText.js
- refresh and test, IT WORKED

### VIDEO 28 - Drag And Drop Active Storage Uploads With Dropzone
- rails g stimulus dropzone
- update the dropzone controller
- bin/importmap pin dropzone
- bin/importmap pin @rails/activestorage
- add the css link to layout/app
- add to post.rb
```
  # Single image upload
  # has_one_attached :image
  # Multiple images upload
  has_many_attached :images
```

- he did has_one_attached first
- update post controller params

```
params.require(:post).permit(:title, :body, :category_id, :image)
```

- add to post form partial

```
<%= render "posts/image_form", form: form %>
```

- create the posts/image_form partial
- create the folder javascript/helpers
- create the file dropzone.js
- updated to multiple images
- refresh and test, IT WORKED (except the multiple imgages get erased when set to multiple)

### VIDEO 29 - Access Localhost From Other Devices (MOBILE)
- used ngrok to create a server