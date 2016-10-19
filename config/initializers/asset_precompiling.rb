Rails.application.config.assets.precompile += %w( public.css )
Rails.application.config.assets.precompile += %w( public.js )
Rails.application.config.assets.precompile += %w( react_admin.js )

Rails.application.config.assets.paths << Rails.root.join("app", "assets", "fonts")