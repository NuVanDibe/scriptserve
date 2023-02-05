##### Generated in part by ChatGPT
# ScriptServe - A Dynamic Nginx Reverse Proxy

ScriptServe is a dynamic Nginx reverse proxy that allows you to serve multiple scripts through a single Nginx instance. Simply add your scripts to the `/etc/scriptserve/scripts` directory as mounted by a volume, and they will be automatically added to Nginx, allowing you to access them by subdomain.

## But why?
Short answer, I want to be able to curl scripts off a local server more easily. If I want my custom arch setup script, I just need to type `curl archsetup.script | bash` and the rest just goes.

Long answer, aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabecause why not?

## Features

- Automatic detection of new scripts
- Automatic creation of Nginx server blocks for each script
- Automatic reloading of Nginx when changes are detected
- Support for multiple scripts running on a single Nginx instance

## Requirements

- Docker
- A DNS server to forward `http://*.script/` queries to the machine running this container.

## Getting Started

1. Clone this repository to your local machine
2. Run `docker build .` against the included Dockerfile to build the image
3. Add your scripts to the `/etc/scriptserve/scripts` directory
4. Start the container
5. Access your scripts by subdomain, with the format `{script_name}.script`

## Contributing

We welcome contributions from the community! If you have an idea for a new feature or a bug fix, please open a pull request.

## License

ScriptServe is released under the [MIT License](https://opensource.org/licenses/MIT).
