# frontend_template
Болванка проекта с примерами методологии верстки

## Template
Папка ```template``` содержит файлы для создания приложения с помощью генератора. Внутри содержится пример для файлов ```database.yml``` и ```bower.json```, которые копируются в проект.

Для создания приложения с помощью этого шаблона нужно передать ему опцию ```-m``` с путём до файла шаблона, где бы он ни находился:
```ruby
rails new new_application -m https://raw.githubusercontent.com/mkechinov/frontend_template/master/template/template.rb
```


Требования:

1. ```ruby```, ```rubygems```
2. ```bower```
3. ```curl```


Будет создано приложение ```NewApplication```, настроены некоторые конфиги:

1. Отключены генераторы для тестов, стилей и скриптов
2. Задан часовой пояс
3. Задан путь для подгрузки файлов из lib/
4. Настроен ```action_mailer.delivery_method``` для окружения разработки
5. Задана локаль для русского языка и прописаны пути для подгрузки всех файлов переводов из ```config/locales```


Подключены и установлены все необходимые гемы:

1. rails 4.2.1 (пока так, ```edge``` не прокатил, потому что что-то с зависимостями ```arel```)
2. pg (PostgreSQL)
3. autoprefixer-rails (для работы с вендорными префиксами в CSSS)
4. coffee-rails
5. jquery-rails
6. sass
7. sass-rails
8. slim-rails
9. development
  1. capistrano 3.*
  2. jazz_hands (development)
  3. letter_opener_web (development)
  4. quiet_assets (development)
  5. spring (development)
  6. thin (development)
  7. yard (development -- для документов)

Сессия полуинтерактивная, задаётся пока только один вопрос -- использовать ли ```ActiveAdmin```, в зависимости от этого ставятся он сам и ```devise``` с последующими вопросами по названиям моделей или нет.


Кроме того:

1. README.rdoc меняется на README.md
2. Полностью заменяется [.gitignore](https://raw.githubusercontent.com/mkechinov/frontend_template/master/.gitignore)
3. Настраивается ```bower```
4. Добавляется [config/database.yml.example](https://raw.githubusercontent.com/mkechinov/frontend_template/master/template/database.yml.example) и копируется в ```database.yml```
5. Создаётся структура для ассетов в ```app/assets```
6. Первично настраивается ```Capistrano```, в том числе добавляется рецепт для ```bower``` (```prepare_assets_dependencies```)
7. Инициализируется ```git```-репозиторий с основной веткой ```develop```, заданием адреса для ```origin``` и делается первый коммит с именем 'Initial commit'
8. После всего этого выводятся напоминания:
  1. Не забыть проверить и провести миграции, если устанавливался active_admin
  2. Поставить жёстко версии для гемов в ```Gemfile```
  3. Настроить ```Capistrano```

После этого можно запускать проект:
```ruby
bundle exec rails s
```

Пример того, что генерирует этот шаблон можно найти [тут](https://github.com/victorpolko/template_tester).
