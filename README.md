```
 _____ _   _ ____  ____  _   _ _   _
| ____| \ | |  _ \|  _ \| | | | \ | |
|  _| |  \| | | | | |_) | | | |  \| |
| |___| |\  | |_| |  _ <| |_| | |\  |
|_____|_| \_|____/|_| \_\\___/|_| \_|
```

# EndRun

Over the past two years, The Marshall Project has pushed nearly 3,000 commits to EndRun, the Rails app that provides our CMS and website. We are incredibly excited to share this code with the world as an example of solving real-world problems on a small team.

This release is not intended to be used by others due to the complexity of operating it. Some assets have been removed as we can't distribute them, such as fonts and images.

EndRun was never designed to be a general purpose system, in fact it's quite the opposite – a custom set of tools for The Marshall Project's workflows and website.

Sadly, we cannot support any use of this code, in part or in whole.

We will continue to develop EndRun in our private repo and plan to periodically sync this repo.

## Motivation

In the spring of 2014, after careful consideration, we started work on a custom content management system (CMS) for The Marshall Project.

This system, a Ruby on Rails app we call EndRun, is how we publish stories, photos and interactives. It’s also how we build our email newsletters, how we automate analytics reporting, and how we curate links from around the web. It’s our ever-evolving toolbelt for building products and time-saving tools to help us do important, innovative journalism in a small newsroom that lacks the kind of robust tech teams more commonly seen at The New York Times, Buzzfeed and elsewhere. [We built it as a single, monolithic application. ][1]

We opted for a Rails-based system over common open source CMS’s for the control over the data model, the desire for a unified codebase (over a decoupled system), and a desire to build frontend and admin tools that were more natural to build outside of an opinionated framework. Having a unified codebase allows for simpler development, testing, refactoring and deployment, which was important for the very small team responsible for the project.

## Overview

EndRun stores posts internally as Markdown, with a series of shortcodes (much like WordPress) to embed other assets, such as photos, sidebars, annotations and graphics. We primarily generate server-rendered HTML with ERB-based view partials and templates.

We have some JavaScript-based enhancements. We have several HTTP JSON APIs used for graphics deployment, and other command line-based workflows.

We use Sidekiq (on Redis) for background jobs like email signup, and Elasticsearch for full-text search, and some analytics workloads.

## Quick Tour

app/models/post.rb

Every story we’ve published is represented internally as a Post, except for The Next to Die. This model is the most important model in the system.

app/lib/post\_renderer.rb

Posts are stored in a single text column as Markdown with shortcodes. Shortcodes are expanded into their respective frontend components in this step, creating HTML ready for our templates.

app/controllers/public\_controller.rb

Nearly all public-facing routes have their controller actions here. There are plenty of things that could be extracted.

app/lib/stream.rb

The reverse-chronological stream is core to our homepage and post pages – it’s lazy-loaded, polymorphic rendering makes it straightforward for us to introduce non-Post models into it, so long as they provide the interface. This is where the slicing happens.

app/models/link.rb

Early on, we built a link curation tool for our reports. These links are the basis of our daily email newsletter, as well as our recent product The Record.

app/lib/markdown\_google\_doc.rb

Our stories are edited in Google Docs, so we wanted a way to bring through links, bold, italic to our Markdown-based CMS. After looking at a few options, Ivar wrote this piece of code to try to convert the <span>-based HTML output from Google to something closer to Markdown.

app/lib/google\_analytics.rb

Checking Google Analytics by hand is time-consuming. We built a daily email that gives top-level summary traffic, which uses this small library to generate queries.

## Running in Production

We use Heroku exclusively for application hosting. Specifically, we use the Heroku Pipelines feature to deploy to production. All commits to the master branch run on CircleCI. Green builds (RSpec) deploy to staging, which is a near-mirror of production. Staging has production data synced to it.

When we’re happy with a build, we use the “Promote” feature to push the slug from staging to production. Having these steps centralized, along with easy rollback, has been boring. Boring is good.

We redirect apex traffic to the www subdomain with a Node.js app. The ‘www’ subdomain points at Fastly. We use Fastly’s SAN TLS cert of HTTPS. Fastly does some minor VCL, such as stripping cookies for some paths. Assets are pulled from the Heroku origin servers with year-long cache TTLs, as they’re fingerprinted. Most popular pages (homepage, post page) have ~30 second TTLs in Fastly, so high load doesn’t affect the origin servers very much. We could run without the CDN, but the TTFB is better with it.

## Running Locally On OS X

- Install [Postgres.app](http://postgresapp.com/)
- [Add postgres tools to your path](http://postgresapp.com/documentation/cli-tools.html)
- [Install the Heroku cli tools](https://devcenter.heroku.com/articles/heroku-command-line)

```
cd endrun

./os-x-setup.sh

# Start the server
heroku local

# All set!
```

We’ve changed the login system to force everyone to be logged in. Any deployment on the Internet should rewrite this part of the login system to have actual users.


[1]: https://m.signalvnoise.com/the-majestic-monolith-29166d022228#.xavmedkjj
