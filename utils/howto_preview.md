## How to use the EndRun Preview Tool


"Preview" is an alpha-quality tool to push developer HTML into the layout of the production CMS. The API is uses is not stable and may change at any time. The pages generated are ephemeral, but can be viewed by anyone with the URL (they must also be authenticated in EndRun.) It's possible to run the tool locally by changing the endpoint in the config file, but the developer must maintain the local API keys for this to work.

1. Create a file called `.endrun_config` in the root of the EndRun repo. This file is in `.gitignore`. The contents of the file: (replace with your API key)

```
api_v1_post_preview_endpoint: https://www.themarshallproject.org/admin/preview/api/post
api_v1_post_preview_api_key:  XXXXXXX
```

2. Create the symlink (optional, but recommended)

	`utils/preview_alias` contains an alias -- put this in your bash/zsh/whatever startup scripts.

3. Run the command. The first argument is an HTML file (you'll need to inline JS/CSS as of May 2015). The second argument is optional, but specifies the template to render into. The default is 'base'

	`preview project.html freeform`