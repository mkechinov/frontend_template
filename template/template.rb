# Simple wrapper to replace Gemfile completely and add readability
# @param [Block] block
# @return Replaces Gemfile contents with new one from the block
def gemfile(&block)
  run 'echo "" > Gemfile'
  yield
end

gemfile do
  add_source 'https://rubygems.org'

  append_file 'Gemfile', "\n\# Last stable rails gem", verbose: false
  gem 'rails', version: '4.2.1'

  append_file 'Gemfile', "\n\n\# Database gem", verbose: false
  gem 'pg'

  unless no? 'Use ActiveAdmin? [Yn]'
    run 'echo "" >> Gemfile'
    append_file 'Gemfile', "\n\n\# Authentication", verbose: false
    @activeadmin = true
    gem 'devise'
    gem 'activeadmin', github: 'activeadmin'
  end

  append_file 'Gemfile', "\n\n\# Frontend gems", verbose: false
  gem 'autoprefixer-rails'
  gem 'coffee-rails'
  gem 'jquery-rails'
  gem 'sass'
  gem 'sass-rails'
  gem 'slim-rails'

  append_file 'Gemfile', "\n\n\# Developer gems", verbose: false
  gem_group :development do
    gem 'better_errors'
    gem 'binding_of_caller'
    gem 'capistrano'
    gem 'capistrano-bundler'
    gem 'capistrano-rails'
    gem 'capistrano-rvm'
    gem 'capistrano-sidekiq'
    gem 'jazz_hands', github: 'nixme/jazz_hands', branch: 'bring-your-own-debugger'
    gem 'letter_opener_web'
    gem 'quiet_assets'
    gem 'spring'
    gem 'thin'
    gem 'yard'
  end
end

say 'Setting up application config (config/application.rb)..'
application do
    "# Setup generators
    config.generators do |generate|
      generate.orm :active_record
      generate.helper false
      generate.assets false
      generate.test_framework false
    end
"
end

application do
  "# Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run 'rake -D time' for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = \'Moscow\'
"
end

application do
  '# Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths += %W(#{config.root}/lib)
'
end

say 'Setting up application environments (config/environments/*.rb)..'
environment nil, env: 'development' do
  "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  config.action_mailer.delivery_method = :letter_opener_web
"
end

say 'Setting up locale config for Russian (config/initializers/locale.rb)..'
initializer 'locale.rb' do
"I18n.enforce_available_locales = false
I18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
I18n.default_locale = :ru
"
end


after_bundle do
  # Readme.md
  say 'Using GitHub markdown for Readme file..'
  run 'rm README.rdoc && touch README.md'

  # .gitignore
  say 'Updating .gitignore file..'
  run 'curl -o .gitignore https://raw.githubusercontent.com/mkechinov/frontend_template/master/.gitignore'

  inside 'config' do
    # Add bower task to capistrano
    run "echo \"\nnamespace :deploy do
  desc 'install assets dependencies with bower'
  task :prepare_assets_dependencies do
    on roles(:web) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bower, :install
        end
      end
    end
  end
  before 'deploy:updated', 'deploy:prepare_assets_dependencies'
end\" >> deploy.rb"

    say 'Replacing database.yml with its example..'
    run 'curl -o database.yml.example https://raw.githubusercontent.com/mkechinov/frontend_template/master/template/database.yml.example'
    run 'cp database.yml.example database.yml'

    say 'Adding bower folders to asset paths..'
    inside 'initializers' do
      run "echo \"\n# Add paths to shorten manifests\' links to files\nRails.application.config.assets.paths << Rails.root.join\(\'vendor\', \'assets\', \'components\'\)\" >> assets.rb"
    end
  end

  inside 'app/assets' do
    inside 'stylesheets' do
      run 'mkdir includes'
      inside 'includes' do
        run 'echo "// Set all variables here" > _variables.sass'
        run 'echo "// Set all fonts here" > _fonts.sass'
        run 'echo "// This is a mini-manifest file to be included into every file in project\n// It imports all variables and mixins\n@import \"sass-mediaqueries/media-queries\"\n@import \"variables\"\n@import \"fonts\" " > mixins.sass'
      end

      run 'mkdir project && echo "@import \"includes/mixins\"\n\n// All helper-classes should start with \'h-\' prefix, i.e. h-text-center" > project/_helpers.sass'
      run 'mkdir third-party'

      run 'echo "/*\n *= require_tree ./third-party\n *= require_tree ./project\n */" > application.css'
    end

    inside 'javascripts' do
      run 'echo "//= require jquery\n//= require jquery_ujs" > application.js'
    end
  end

  # Setup activeadmin
  if @activeadmin
    run 'spring stop'
    devise_model_name = ask("What would you like the user model to be called? [User]")
    devise_model_name = 'User' if devise_model_name.blank?
    generate 'devise:install'
    generate 'devise', devise_model_name.camelize

    activeadmin_model_name = ask("What would you like the admin_user model to be called? [AdminUser]")
    activeadmin_model_name = 'AdminUser' if activeadmin_model_name.blank?
    generate "active_admin:install #{activeadmin_model_name.camelize}"
  end

  # Setup Capistrano
  run 'bundle exec cap install'

  # Setup bower
  run 'curl -o bower.json https://raw.githubusercontent.com/mkechinov/frontend_template/master/template/bower.json'
  run "echo '{\n  \"directory\": \"vendor/assets/components\"\n}' > .bowerrc"
  run 'bower install'

  # Setup Git
  # Use git flow for (develop -> staging) and (master -> production) deploys
  say 'Setting git up..'
  git :init
  git checkout: '-b develop'
  git add: '--all'
  git commit: "-m 'Initial commit'"
  repo = ask('Введите адрес git-репозитория: ').strip
  git remote: "add origin #{repo}"
  # git push: '-u origin develop'

  say "\n\nNew application constructed."

  if @activeadmin
    say "\n\nMake sure all migrations are correct and then run"
    say "\tbundle exec rake db:migrate"
    say "over your database"
  end

  say "\n\nDon't forget to set fixed versions for all gems!"

  say "\n\nRemember to configure Capistrano (Capfile, config/deploy.rb, config/deploy/*.rb)"
end
