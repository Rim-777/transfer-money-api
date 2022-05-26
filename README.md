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
- Run application:

 ```shell
 $ rails server
 ```

##### Tests:
To execute automation tests, run following commands:

```shell
 $ bundle exec rake db:migrate RAILS_ENV=test #(the first time only)
 $ bundle exec rspec
```

NOTE:
For using JWT access on test and development environments
you need to define the ENV variable ```JWT_KEY```, then generate and assign a private key to it. 

Please follow steps:
 1) Add the file ```.env``` to the root of the project.
 2) Run the rails console and generate a private key by the following commands:

```shell
 $ bundle exec rails console
 $ private_key = OpenSSL::PKey::EC.new('secp384r1').generate_key
 $ private_key.to_pem
```

 3) Copy the outputted key and past it to the ```.env``` file like in the following example:

  ```
  export JWT_KEY=<...the outputted key...>
  ```

### Explanation of the approach:
DDD Service-based app design with step-based operations

#### Common logic:
The light edition that allows users to transfer money to their accounts.

Detailed documentation on [SwaggerHub](https://app.swaggerhub.com/apis-docs/Rim-777/Easy-Money-Transfer-API/1.0.0)


### License

The software is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
