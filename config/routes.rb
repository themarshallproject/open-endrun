require 'sidekiq/web'

Rails.application.routes.draw do

  root to: 'public#home'
  get '/'     => 'public#home', as: :home
  get '/_preview_home' => 'public#preview_home'

  get '/rss/recent.rss' => 'rss#home', format: 'rss'
  get '/rss/newsbank.rss' => 'rss#newsbank', format: 'rss'
  get '/rss/yahoo.rss' => 'rss#yahoo', format: 'rss', as: :yahoo_rss
  get '/rss/tag/:slug.rss' => 'rss#tag', format: 'rss'
  get '/sitemap.xml' => 'sitemap#index', format: 'xml'

  get '/pixel.js' => 'public#pixel_ping_js'
  get '/pixel/iframe' => 'public#pixel_ping_iframe'
  get '/pixel/setup' => 'public#pixel_setup'

  get  '/subscribe/hello' => 'public#email_details', as: :email_details
  get  '/subscribe/already-subscribed' => 'public#email_already_exists', as: :email_already_exists
  post '/subscribe/update-details'     => 'public#process_email_details', as: :process_email_details
  get  '/subscribe/update-details/thank-you' => 'public#email_details_thanks', as: :email_details_thanks

  get '/:year/:month/:day/:slug' => 'public#post', constraints: { year: /20[0-9][0-9]/ }, as: :public_post # must be a 20XX number for year
  get '/print-post/:year/:month/:day/:slug' => 'public#print_post', constraints: { year: /20[0-9][0-9]/ }, as: :public_print_post # must be a 20XX number for year.
  get '/_amp/:id' => 'public#amp_post'

  get '/staff/:slug' => 'public#author', as: :author
  get '/staff/:slug/gpg' => 'public#user_public_key'
  get '/staff/:slug/pgp' => 'public#user_public_key', as: :user_public_key

  get '/tag/:slug' => 'public#tag', as: :public_tag

  get '/justice-lab' => 'public#tag_alias'
  get '/news'        => 'public#tag_alias'
  get '/feature'     => 'public#tag_alias'
  get '/commentary'  => 'public#tag_alias'
  get '/the-ask'     => 'public#tag_alias'
  get '/the-lowdown' => 'public#tag_alias'

  get  '/donate' => 'donate#form', as: :donate
  post '/donate' => 'donate#charge', as: :process_donation

  get '/unbelievable' => 'landing_page#victim' # 'VICTIM landing page'

  get '/justice-lab/methodology' => 'public#static_page'
  get '/about/in-the-news' => 'public#about_in_the_news'
  get '/about/privacy' => 'public#static_privacy'
  get '/about/thurgood-marshall' => 'public#static_marshall'
  get '/about(/:section)' => 'public#static_page' # must be after "privacy" and "thurgood-marshall"
  get '/people'     => 'public#static_page'

  get '/jobs'       => 'public#static_page'
  get '/jobs/:slug' => 'public#static_page'
  get '/jobs/intern' => 'public#static_page'
  get '/jobs/photo-video-editor' => 'public#static_page'

  get '/funders'    => 'public#static_page'
  get '/board'      => 'public#static_page'
  get '/contact'    => 'public#static_page'
  get '/press'      => 'public#static_page'
  get '/thank-you'  => 'public#static_page'
  get '/press-releases/(:slug)' => 'public#static_page'

  get '/submit-letter/thank-you'  => 'public#static_page'
  get '/submit-letter/(:post_id)' => 'public#submit_letter', as: :submit_letter # this must be BELOW /submit-letter/thank-you
  post '/submit-letter'         => 'public#process_new_letter', as: :process_new_letter

  get '/letters' => 'public#letters_index', as: :letters_index
  get '/letters/:letter_id' => 'public#view_letter', as: :view_letter

  get '/documents/:dc_id' => 'public#document', as: :public_document
  get '/opening-statement' => 'public#opening_statement_index', as: :opening_statement_index
  get '/opening-statement/:id' => 'public#opening_statement', as: :opening_statement

  post '/api/v2/email/subscribe' => 'public#v2_email_subscribe', as: :v2_email_subscribe
  post '/api/v3/email/subscribe' => 'public#v3_email_subscribe', as: :v3_email_subscribe
  match '/api/v1/mailchimp-webhook' => 'public#api_v1_mailchimp_webhook', via: [:get, :post]

  get '/partials/featured-block-test' => 'public#featured_block_test'

  get '/not-found' => 'public#not_found', as: :not_found

  get '/api/v1/post_html/:id' => 'public#post_html_partial_v1'#, as: :post_html_partial_v1
  get '/api/v1/recognize-post-url' => 'public#recognize_post_url_v1'

  get '/api/v1/stream/(:end_date)' => 'public#stream_partials'
  get '/api/v1/stream-topshelf' => 'public#stream_topshelf'
  get '/api/v1/search/posts' => 'public#search_posts_api_v1'
  get '/api/v1/tags/:id/posts' => 'public#posts_tagged_by_slug'

  get '/api/v2/token' => 'public#token_v2' # json blob, includes hash
  get '/api/v1/published_urls.json' => 'public#v1_published_urls'
  get '/api/v1/whoami' => 'public#whoami'
  get '/api/v2/decode' => 'public#api_v2_decode', as: :api_v2_decode

  get  '/subscribe' => 'public#subscribe', as: :subscribe
  post '/subscribe' => 'public#process_subscribe', as: :process_subscribe

  get '/search/(:q)' => 'public#search_v1'

  get '/live' => 'collections#live'

  scope 'records' do

    get '/caeffd2d6817a626c0a275e5707' => 'collections#magic_preview_link'

    get '/'    => 'collections#index', as: :collections_index

    get '/:id' => 'collections#show',  as: :collections_show


    scope 'api' do
      scope 'v1' do
        # get '/index/:slice' => 'collections#api_v1_index_tags'
        get '/' => 'collections#api_v1_items'
        get 'all-tags' => 'collections#api_v1_all_tags'
        get 'search' => 'collections#api_v1_search'
        get 'tag-photo' => 'collections#api_v1_tag_photo'
        post 'report-link' => 'collections#api_v1_report_link'
      end
    end
  end

  scope 'partner' do
    match 'check-pixel' => 'public_partner#check_pixel', via: [:get, :post]
    get 'outcome-tracker/3ab3c41924e8a' => 'public_partner#outcome_tracker'
  end

  ## Mounted News Apps
  get '/next-to-die/TKTK'                   => 'project_router#next_to_die_tktk_hotfix'
  get '/next-to-die/embed'                  => 'project_router#next_to_die_embed'
  get '/next-to-die/embed/:fragment'        => 'project_router#next_to_die_embed'
  get '/next-to-die/:state_slug/:case_slug' => 'project_router#next_to_die_case'
  get '/next-to-die/:fragment'              => 'project_router#next_to_die'
  get '/next-to-die'                        => 'project_router#next_to_die'

  get '/books' => 'project_router#books'

  post '/_/csp_report' => 'public#csp_report'
  get '/embed/v1/email' => 'embed#v1_email'

  #####################
  #####################
  ## Public above here
  #####################
  #####################

  resources :links

  scope '/admin' do

    resources :documents do
      get  'potential', on: :collection
      post 'download',  on: :member, as: :download
      post 'ingest',    on: :member, as: :ingest
      post 'update_published_url', on: :member, as: :update_published_url
      post 'async_update_published_url', on: :member, as: :async_update_published_url
    end

    scope 'freeform-email' do
      post '/' => 'admin#freeform_email', as: :freeform_email
      get '/editor' => 'admin#freeform_email_editor'
    end

    scope 'amicus' do
      scope 'api' do
        get 'post/:id' => 'amicus#api_post'
      end
      get 'edit/:id' => 'amicus#edit'
    end

    get 'link-reports-tsv' => 'admin#link_reports_tsv'
    get 'email-signup-tsv' => 'admin#email_signup_tsv'

    scope 'weedwacker' do
      get '/' => 'weedwacker#index'

      scope 'api/v1' do
        get 'total' => 'weedwacker#api_v1_total'
      end
    end

    get  'quick-s3-upload' => 'admin#quick_s3_upload'
    post 'quick-s3-upload' => 'admin#process_quick_s3_upload', as: :process_quick_s3_upload

    resources :yahoo_posts
    get 'yahoo_renderer/:id' => 'admin#yahoo_renderer', as: :yahoo_renderer


    scope 'quizbuilder' do
      get '/' => 'admin#quizbuilder_index', as: :quizbuilder_index
      get 'edit' => 'admin#quizbuilder_edit'
      get 'preview/:asset_file_id' => 'admin#quizbuilder_preview'
    end

    scope 'google-forms' do
      get '/' => 'admin#google_forms_index'
    end

    get 'feedback' => 'admin#feedback'

    scope 'graphics' do
      resources :asset_files
    end

    resources :freeform_stream_promos do
      get 'preview', on: :member
    end

    get 'post-snapshot-v1/:post_id' => 'admin#post_snapshot_v1', as: :post_snapshot_v1
    get 'email-signup' => 'admin#email_signup'
    get 'post_delegate_paths' => 'admin#post_delegate_paths'
    get 'analytics/posts.csv' => 'admin#posts_csv'
    get 'analytics/links.csv' => 'admin#links_csv'
    get 'analytics/posts-days.csv' => 'admin#posts_days_csv'

    resources :partners
    resources :partner_pageviews

    resources :graphics do
        post 'rotate_deploy_token', on: :member
    end

    resources :members
    resources :static_pages
    resources :featured_blocks do
      post 'activate', on: :member
      post 'dupe', on: :member
      get  'activation_events', on: :collection
    end
    resources :letters do
      get 'preview_promo'  => 'admin#preview_promo_lte', on: :member, as: :preview_promo_iframe
      get 'preview_letter' => 'admin#preview_letter_lte', on: :member, as: :preview_letter_iframe
    end

    get 'features/'              => 'user_features#all', as: :all_features
    get 'features/enable/:slug'  => 'user_features#enable', as: :enable_feature
    get 'features/disable/:slug' => 'user_features#disable', as: :disable_feature

    resources :post_shareables

    resources :newsletters do
      get 'raw-html' => "newsletters#raw_html", on: :member, as: :raw_html
    end

    resources :weekly_newsletters do
      post 'update_assignments' => "weekly_newsletters#update_assignments", as: :update_weekly_newsletter_assignments
      get  'sort' => "weekly_newsletters#sort", as: :sort_weekly_newsletter
      get  'build' => "weekly_newsletters#build", as: :build
      get  'build_text' => "weekly_newsletters#build_text", as: :build_text_weekly_newsletter

      post '/weekly_newsletters/:newsletter_id/attach_to/:model_name/:model_id' => "weekly_newsletters#attach_to_taggable", as: :attach_weekly_newsletter_to_taggable
      post '/weekly_newsletters/:newsletter_id/remove_from/:model_name/:model_id' => "weekly_newsletters#remove_from_taggable", as: :remove_taggable_from_weekly_newsletter
      post '/weekly_newsletters/:id/sync_to_mailchimp' => 'weekly_newsletters#sync_to_mailchimp', as: :sync_weekly_newsletter_to_mailchimp
    end

    resources :users do
      get 'last_seen.json' => 'admin#users_last_seen', on: :collection
      get 'sessions.json' => 'admin#user_sessions_json', on: :collection
      get 'sessions' => 'admin#user_sessions', on: :collection
    end

    resources :sessions
    resources :photos
    resources :post_locks do
      post 'touch',  on: :member
      get  'actives_widget', on: :collection
    end

    get 'search/queries' => 'admin#search_queries'

    get 'email_signups' => 'email_signup#index', as: :email_signups

    get 'header_debug' => 'admin#header_debug'
    get  'ops/dynos'  => 'admin#ops_dynos', as: :admin_ops_dynos
    post 'ops/dynos/restart/:dyno_id' => 'admin#ops_restart_dyno', as: :admin_ops_restart_dyno

    get '/ingress/google_drive/auth'     => 'admin_google_doc#redirect_to_login'
    get '/ingress/g_oauth_callback' => 'admin_google_doc#oauth_callback'
    get '/ingress/google_drive/all' => 'admin_google_doc#all_google_docs', as: :admin_all_google_docs
    get '/ingress/google_drive/unset_token' => 'admin_google_doc#unset_token', as: :admin_google_doc_unset_token
    get '/ingress/google_drive/parse_file/:id' => 'admin_google_doc#parse_doc', as: :admin_parse_doc
    get '/ingress/google_drive/parse_url' => 'admin_google_doc#extract_id_from_url'

    get '/ingress/google_drive/parse_file_v2/:id' => 'admin_google_doc#parse_doc_v2', as: :admin_parse_doc_v2
    get '/ingress/google_drive/parse_url_v2' => 'admin_google_doc#extract_id_from_url_v2'

    get '/ingress/google_drive/all_spreadsheets' => 'admin_google_doc#all_spreadsheets', as: :admin_all_spreadsheets
    get '/ingress/google_drive/spreadsheet/:id' => 'admin_google_doc#parse_spreadsheet', as: :admin_parse_spreadsheet

    get 'sidekiq-ttin' => 'admin#sidekiq_ttin'

    get 'external_service_responses' => 'admin#external_service_responses'
    get 'link-decode-events' => 'admin#link_decode_events'
    get 'analytics_all_posts_v1' => 'admin#analytics_all_posts_v1'

    get '/story-list' => 'admin#story_list'
    get '/style-guide' => 'admin#style_guide'
    get '/branding' => 'admin#branding'
    get '/product' => 'admin#product'

    resources :post_deploy_tokens
    post '/api/v1/update-post'    => 'post_deploy_tokens#api_v1_update'
    post '/api/v1/update-graphic' => 'graphics#api_v1_update'

    scope 'analytics' do
      get '/' => 'admin_analytics#home'
      get 'json/weekly' => 'admin_analytics#json_weekly'
      get 'partners_nojs' => 'admin_analytics#partners_nojs'
      get 'referers' => 'admin_analytics#referers'
      get 'mailchimp-webhooks' => 'admin_analytics#mailchimp_webhooks'
      scope 'google' do
        get 'test' => 'admin_analytics#ga_test'
        get 'today' => 'admin_analytics#today'
        get 'yesterday' => 'admin_analytics#yesterday'
        get 'ref' => 'admin_analytics#event_ref'
        get 'edu' => 'admin_analytics#edu'
        get 'edu-total' => 'admin_analytics#edu_total'
      end
      scope 'lovestory' do
        get 'total' => 'admin_analytics#lovestory_total'
      end
      get 'gator_domains' => 'admin_analytics#gator_domains'
      get 'mailchimp_merge' => 'admin_analytics#mailchimp_merge'
    end

    scope '/audit' do
      get '/every-link' => 'admin#every_link'
      get '/tag-bot(/:id)' => 'admin#tag_bot', as: :admin_audit_tag_bot
      get '/css' => 'admin#audit_css'
    end

    get '/sidekiq-stats' => 'admin#sidekiq_stats'

    scope '/static' do
      get '/201503-analytics' => 'admin#static_201503_analytics'
    end

    scope '/robots' do
      get '/weekly-links-facebook' => 'admin#robot_weekly_link_social'
      get '/daily-email' => 'admin_analytics#daily_email'
      get '/daily-email/send' => 'admin_analytics#send_daily_email'
    end

    get 'weekly-gator-report' => 'admin#weekly_gator_report'
    get '/update-tag-facebook-count/:id' => 'admin#update_tag_facebook_count'

    get '/debug-os-links' => 'admin#debug_os_links'

    get '/sprout-links' => 'admin#sprout_links'
    get '/outcome-tracker' => 'admin#outcome_tracker', as: :outcome_tracker
    get '/donation-sources' => 'admin#donation_sources'

    scope 'gator' do
      get '/activity' => 'admin_gator#activity'
      get '/' => 'admin_gator#index'
      get '/iframe' => 'admin_gator#iframe'
      get  '/link' => 'admin_gator#get_link'
      post '/link' => 'admin_gator#update_link'
      get '/search' => 'admin_gator#search_links'
      get '/suggest' => 'admin_gator#suggest'
      get '/post/:id' => 'admin_gator#post', as: :gator_post
      get '/post/json/:id' => 'admin_gator#post_json'
    end

    scope 'qa' do
      get 'all' => 'admin#qa_all'
    end

    scope 'tag-posts' do
      get '/' => 'admin#tag_post_index'
      get '/:post_id' => 'admin#tag_post_show', as: :tag_post
      post '/:post_id/update' => 'admin#tag_post_update', as: :tag_posts_update
      get '/:post_id/search' => 'admin#tag_post_search'
    end

    # scope 'project-repo' do
    #   get '/' => 'project_repos#index'
    #   get '/:repo' => 'project_repos#show'
    #   get '/:repo/:branch' => 'project_repos#branch'
    # end

    post 'v1/quizbuilder/create' => 'admin#v1_api_quizbuilder_create'

    get 'email-signups-per-day' => 'admin#email_signups_per_day'
    get 'email-signups-per-day-chart' => 'admin#email_signups_per_day_chart'
    get 'tmp-file-count' => 'admin#tmp_file_count'

  end

  get '/api/v1/external-preview' => 'public#external_preview'

  get "/admin/featured_block/preview/:id" => "featured_blocks#preview", as: :featured_block_preview

  get "/admin/preview-post/:id"  => "posts#preview", as: :admin_preview_post
  get "/admin/preview-promo/:id" => "posts#preview_promo", as: :admin_preview_promo
  get "/admin/inlined-photos/:id" => "admin#inlined_photos", as: :admin_inlined_photos
  get "/admin/json-post/:id"  => "posts#as_json"

  post "admin/preview/api/post" => 'admin_api_v1#preview_post_via_post'
  get  "admin/preview/api/gist/:gist_id" => 'admin_api_v1#preview_gist'
  get  "admin/preview/api/result/:uuid" => 'admin_api_v1#serve_result'

  get "/admin/preview-post-inject" => "admin#preview_post_inject"

  get "/admin/api/v1/cache_stats" => 'admin#cache_stats'

  get '/admin/stream-preview' => 'admin#stream_preview'

  get '/admin/feature-flags' => 'admin#feature_flags'
  get '/admin/email-signups' => 'admin#email_signups'

  get '/api/v1/content_minutes' => 'admin#api_v1_content_minutes'

  post '/newsletters/:id/update_assignments' => "newsletters#update_assignments", as: :update_newsletter_assignments
  get  '/newsletters/:id/sort' => "newsletters#sort", as: :sort_newsletter
  get  '/newsletters/:id/build' => "newsletters#build", as: :build_newsletter
  get  '/newsletters/:id/build_text' => "newsletters#build_text", as: :build_text_newsletter

  post '/newsletters/:newsletter_id/attach_to/:model_name/:model_id' => "newsletters#attach_to_taggable", as: :attach_newsletter_to_taggable
  post '/newsletters/:newsletter_id/remove_from/:model_name/:model_id' => "newsletters#remove_from_taggable", as: :remove_taggable_from
  post '/newsletters/:id/sync_to_mailchimp' => 'newsletters#sync_newsletter_to_mailchimp', as: :sync_newsletter_to_mailchimp

  get '/admin/links/recent' => 'admin#links_recent'

  post '/newsletters/update_email_contents' => "newsletters#update_email_contents", as: :update_newsletter_email_contents

  get '/admin/google/oauth2callback' => 'admin_google_doc#oauth_callback'

  get '/admin/mailchimp_lists' => 'admin#mailchimp_lists'

  post '/links/:id/approve' => 'links#approve', as: :approve_link
  post '/links/:id/reject'  => 'links#reject', as: :reject_link
  get '/links/html/partials_before' => 'links#partials_before', as: :link_partials_before

  # get '/signup', to: 'users#new', as: 'signup'
  get '/login', to: 'sessions#new', as: 'login'
  post '/logout', to: 'sessions#destroy', as: 'logout'
  get  '/login/with_token', to: 'sessions#new_with_token', as: :login_with_token
  post '/login/with_token', to: 'sessions#create_token',   as: :create_login_token
  get  '/login/with_token/:token', to: 'sessions#process_login_token', as: :process_login_token

  get  '/admin/photo-upload/new'      => 'photos#upload_form', as: :upload_photo
  post '/admin/photo-upload/complete' => "photos#upload_complete"
  get  '/admin/photos/v1/picker' => 'photos#v1_picker', as: :v1_picker

  get '/admin/danger/flushall_cache' => 'admin#flushall_cache'

  resources :posts do
    get 'content_hash', on: :member, as: :post_content_hash
  end
  # resources :post_threads

  resources :tags

  # not very rest, yuck TODO FIXME
  get '/admin' => 'admin#index', as: :admin
  get '/admin/posts'   => 'admin#posts_index',   as: :admin_posts_index
  get '/admin/posts/email' => 'admin#posts_email_index', as: :admin_posts_email_index
  get '/admin/tags'    => 'admin#tags_index',    as: :admin_tags_index
  get '/admin/threads' => 'admin#threads_index', as: :admin_threads_index
  get '/admin/links'   => 'admin#links',       as: :admin_links_index
  get '/admin/taggings' => 'admin#taggings',     as: :admin_taggings_index
  get '/admin/performance' => 'admin#performance'

  get '/admin/stream/main-debug' => 'admin#stream_main_debug'

  post '/admin/posts/api/destroy_user_post_assignment/:id' => 'posts#destroy_user_post_assignment', as: :destroy_user_post_assignment

  get '/admin/rattlecan/tags.json' => 'rattle_can#all_tags', as: :rattlecan_tags
  get '/admin/rattlecan' => 'rattle_can#app', as: :rattlecan
  get '/admin/rattlecan/model/:model_type/:model_id' => 'rattle_can#model_tags', as: :rattlecan_model_tags
  post '/admin/rattlecan/create_tag' => 'rattle_can#create_tag', as: :rattlecan_create_tag
  post '/admin/rattlecan/destroy_tag' => 'rattle_can#destroy_tag', as: :rattlecan_destroy_tag


  get '/admin/newsletter/search-archive' => 'email_newsletter#search_archive', as: :search_email_archive
  get '/admin/newsletter/preview' => 'email_newsletter#show', as: :preview_email
  get '/admin/newsletter/generate' => 'email_newsletter#generate', as: :generate_email
  get '/admin/ar_debug' => "admin#ar_debug"

  get  '/admin/links/bookmarklet.js'  => 'links#bookmarklet_app',  as: :bookmarklet_app
  get  '/admin/links/get_bookmarklet' => 'links#bookmarklet_link', as: :get_links_bookmarklet
  get  '/admin/links/iframe' => 'links#edit_link_in_iframe', as: :edit_link_in_iframe
  post '/admin/links/iframe' => 'links#iframe_update', as: :iframe_update
  post '/admin/links/api/v1/download_html/:link_id' => "links#download_html_v1", as: :download_html_for_link

  get '/admin/tags/leaderboard' => 'admin#tag_leaderboard'
  get '/admin/tags/most-used' => 'admin#frequent_tags'

  post '/admin/api/v1/posts'         => 'user_deploy_api#index'
  post '/admin/api/v1/post/create'   => 'user_deploy_api#create'
  post '/admin/api/v1/post/update'   => 'user_deploy_api#update'

  get '/admin/bench/tinytext' => 'admin#bench_tinytext'

  # get '/admin/email_content_domain_mappings' => 'admin#email_content_domain_mappings'

  get '/admin/report/generate_tag_report' => 'admin#generate_tag_report'
  get '/admin/report/v1/:id' => 'admin#report_v1', as: :report_v1
  get '/admin/thriller/social_snapshot' => 'admin#thriller_social_snapshot'

  mount Sidekiq::Web => '/admin/fdbd9135786739d1778fd73aba37bcc4/sidekiq'

  get '/admin/assets/(:slug)' => 'public#temp_admin_asset_rewrite' # June 22 2015 hack to fix asset path bug

  get '/admin/slack/incoming-slash-command' => 'admin_slack_bot#incoming_slash_command'

  get '/_status' => 'status#index'

end
