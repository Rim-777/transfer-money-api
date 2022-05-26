## Transfer Money Api
Ruby-on-Rails [JSON:API](https://jsonapi.org/) application with ActiveRecord, Dry-rb, RSpec
### Dependencies:
- Ruby 2.7.6
- PostgreSQL

### Installation:
- Clone poject
- Run bundler:

 ```shell
 $ bundle install
 ```
- Copy database.yml:
```shell
$ cp config/database.yml.sample config/database.yml
```

- Create and migrate database:

```shell
 $ bundle exec rails db:create
 $ bundle exec rails db:migrate
```

- Populate the database:

```shell
 $ bundle exec rails db:seed
```

- Run application:

 ```shell
 $ rails server
 ```

##### Tests:
To execute tests, run following commands:

```shell
 $ bundle exec rake db:migrate RAILS_ENV=test #(the first time only)
 $ bundle exec rspec
```

### Explanation of the approach:
DDD Service-based app design with step-based operations

#### Common logic:
The light edition that allows users to transfer money to their accounts.

Detailed documentation on [SwaggerHub](https://app.swaggerhub.com/apis-docs/Rim-777/Easy-Money-Transfer-API/1.0.0)


### License

The software is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
