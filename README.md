# neotest-phpunit

This plugin is a fork of [neotest-phpunit](https://github.com/olimorris/neotest-phpunit),
which allows to run PHPUnit tests in Docker environment.

Refer to it's documentation for general usage information.

## Installation

Same as parent repository, just replace `nvim-neotest/neotest` with `sauromates/neotest-phpunit`.

## Usage

In order to run tests in Docker containers, one need to create `.neotest.json` file
in the project root.

```json
{
  "enabled": true,
  "container_name": "<full-name-of-php-container>",
  "container_path": "<working-dir-oh-php-container",
  "cmd": "<phpunit-binary>",
  "output": "<junit-reports-output-dir>"
}
```

Some of configuration fields have default parameters:

- `container_name` defaults to `php`
- `container_path` defaults to `/var/www/html`
- `cmd` defaults to `vendor/bin/phpunit`
- `output` defaults to `.phpunit`

The plugin depends on JUnit XML reports. When Docker is enabled via configuration
file, the plugin would expect a report to parse in `<output>/results.xml`.

## General considerations

This fork relies heavily on valid mappings between host system and Docker container.
That's why it's important to use volume mapping between those to allow the plugin
to read test result files on the host system.
