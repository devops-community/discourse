# Discourse

Build and deploy a simple setup of [Discourse](http://www.discourse.org) on [devo.ps](http://devo.ps).

## Install

Simply use the link below:

[![Fork on devo.ps](https://app.devo.ps/assets/images/fork.png)](https://app.devo.ps/#/fork?git_url=https://github.com/devops-community/discourse)

Once you've forked the repository, open it in devo.ps and you will be prompted for a few settings, including:
- **git URL**; in case you have forked the original repository
- **admin emails**; the email addresses of your admins (comma separated)
- **domain**; the domain name you want your Discourse setup to reply to
- **provider details**; which provider and size of cloud instance you want
- **SMTP details**; Discourse make extensive use of emails for registration, notification, etc. Better provide details for a [Mandrill account](https://mandrillapp.com)

Once the information entered, the server will automatically start to be deployed - and on completion the Discourse application be deployed.

## What's in the box?

This setup contains one server (`nodes/discourse.yml`) with **Nginx**, **Ruby**, **Redis**, **Nodejs**, **PostgreSQL** (with a "discourse" user and a "discourse_prod" database)

We have included as well a task (`tasks/install-discourse.yml`) that:

1. Clone the discourse app from GitHub (set to [official Discourse GitHub repository](https://github.com/discourse/discourse) by default).
1. Install all your application dependencies via bundle
1. Run a config script (`scripts/prepare_discourse_config.sh`) that will:
  1. Write the Discourse configuration file (to connect it to PostgreSQL, and SMTP details)
  1. Prepare the Nginx Vhost config file
1. Prepare the database
1. Setup the Supervisord applications ([Rails](http://rubyonrails.org/) and [Sidekiq](http://sidekiq.org))

The current repo provides a production ready setup of Discourse. Hack at will!

## Where are the logs?

May you want to investigate possible issues, you may want to dig in the following logs on the server you have created:

- `/var/www/discourse/log/production.log`; for the RoR / Discourse logs (internals)
- `/var/log/supervisor/discourse-std*`; for the RoR / Discourse logs
- `/var/log/supervisor/sidekiq-std*`; for the Sidekiq logs
- `/var/log/nginx/access.log` and `/var/log/nginx/error.log`; for the basic web logs

## Questions?

If you have any question, come ask us on the [devo.ps chat](https://www.hipchat.com/gyHEHtsXZ) or shoot us an email at [help@devo.ps](mailto:help@devo.ps) (though, you should really just [ask us in the chat](https://www.hipchat.com/gyHEHtsXZ)).

# Reference

- [Nodes in devo.ps](http://docs.devo.ps/manual/nodes)
- [Tasks in devo.ps](http://docs.devo.ps/manual/tasks)
    
