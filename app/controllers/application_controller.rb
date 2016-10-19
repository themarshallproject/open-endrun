class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  force_ssl if Rails.env.production?

  include Skylight::Helpers

  before_filter :calculate_queue_time
  def calculate_queue_time
    if request.env["HTTP_X_REQUEST_START"].present?
      request_start_micros = (request.env["HTTP_X_REQUEST_START"] || 0).to_i
      @request_queue_time = (1_000*Time.now.to_f - request_start_micros).to_i
    end
  end

  before_filter :csp_report_filter
  def csp_report_filter
    if params.keys.include?('cspreport')
      report_uri = "/_/csp_report?path=#{request_path}"
      request_path = URI.escape(request.path, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
      response.headers['Content-Security-Policy-Report-Only'] = "default-src 'self'; script-src 'self' 'unsafe-inline'; report-uri #{report_uri}"
    end
  end

  before_filter :strict_transport_security
  def strict_transport_security
    if request.ssl?
      response.headers['Strict-Transport-Security'] = "max-age=31536000; includeSubDomains;"
    end
  end

  after_filter :inject_public_cache_headers
  def inject_public_cache_headers
    if current_user == false and @inject_public_cache_control == true
      ttl = (ENV['PUBLIC_CC_MAXAGE'] || 15).to_i

      # 86400 (secs) is 24 hours
      response.headers['Cache-Control'] = "public, max-age=0, s-maxage=#{ttl}, stale-while-revalidate=86400, stale-if-error=86400"
      request.session_options[:skip] = true
    end
  end

  after_filter :log_post_requests
  def log_post_requests
    return unless current_user.present?

    ignore_methods = ['GET', 'HEAD']
    ignore_controllers = ['post_locks']

    if !ignore_methods.include?(request.method) and !ignore_controllers.include?(params[:controller])
      puts "LOG_USER_POST: email=#{current_user.email} method=#{request.method} path=#{request.path} params=#{params.to_json}"
    end
  rescue
    puts "LOG_USER_POST: hotfix, rescuing error!" # TODO
  end

    rescue_from Exception, with: :send_error_email
    # TODO: move to worker
  def send_error_email exception
      begin
      data = {
        path: request.path,
        current_user: current_user.try(:email),
        referer: request.referer,
        params: params,
        exception: exception.inspect,
        user_agent: request.user_agent,
        http_accept: request.env['HTTP_ACCEPT'],
        ip: request.ip,
        backtrace: exception.backtrace
      }

      if Rails.env.production?
        DebugEmailWorker.perform_async({
          from: 'ivong@themarshallproject.org',
          to: 'ivong+exception@themarshallproject.org',
          subject: "[#{ENV['RACK_ENV']}] EndRun Exception",
          text_body: JSON.pretty_generate(data)
        })
      end
      rescue
      logger.error "Error while reporting error! Not reported! #{$!.inspect}" # this happens if the API call fails.
      end

      raise # reraise the initial error
  end

  # before_filter :reject_banned_users
  # def reject_banned_users
  #   email = current_user.try(:email)
  #   if email.present?
  #     if email.include?('@') and (ENV['BANNED_ADMIN_EMAILS'] || '').split(",").include?(email)
  #       raise "Banned User: #{email}"
  #     end
  #   end
  # end

  private

    # `User` – all are Marshall Project staff
    helper_method :current_user
    def current_user
      # replace this with your logic
      @current_user = User.where(name: "Test", email: "test@test.com").first_or_create do |user|
        user.password = "test"
        user.save
      end
      cookies.signed[:user_id] = { value: @current_user.id, expires: 5.days.from_now, httponly: true }

      return @current_user
    end

    helper_method :verify_current_user_present
    def verify_current_user_present
      if current_user == false
        cookies.signed[:user_id] = nil
        redirect_to(login_with_token_path+"?return=#{request.path}", alert: 'Not authorized.')
        return
      end
    end

    helper_method :run_public_analytics?
    def run_public_analytics?
      if Rails.env.production?
        return !@current_user.present?
      else
        if params[:analytics_prod] == 'true'
          return !@current_user.present?
        else
          return true
        end
      end
    end

    helper_method :ensure_permanent_token
    def ensure_permanent_token
      if cookies.permanent.signed[:t].nil?
        @permanent_cookie_token = "#{Time.now.utc.to_i}|p|#{SecureRandom.base64(32)}"
        cookies.permanent.signed[:t] = @permanent_cookie_token
        cookies.permanent[:uid]      = @permanent_cookie_token

        logger.info "cookies.permanent.signed[:user_token] = #{cookies.permanent.signed[:t]}"
        $stdout.puts("count#app.cookie_created=1")
      else
        @permanent_cookie_token = cookies.permanent.signed[:t]
        $stdout.puts("count#app.cookie_present=1")
      end

      if cookies.permanent[:uid].nil?
        # upgrade cookies without un-encrypted token
        cookies.permanent[:uid] = @permanent_cookie_token
      end

      @permanent_cookie_token
    end

    helper_method :feature_active_for_user?
    def feature_active_for_user?(slug)
      current_user.present? and cookies.permanent["_uff_#{slug}"] == 't'
    rescue
      puts "feature_active_for_user? failed for: #{slug}"
      false
    end

end
