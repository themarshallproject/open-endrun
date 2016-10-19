class SendTTIN
  include Sidekiq::Worker
 
  def perform
    Process.kill("TTIN", Process.pid)
  end
  
end