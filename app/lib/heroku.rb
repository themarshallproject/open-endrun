class Heroku
  
    def self.base_url
        "https://api.heroku.com/apps/#{ENV['HEROKU_APP_NAME']}" # probably should replace
    end
    
    def self.headers
        {
            "Accept" => "application/vnd.heroku+json; version=3",
            "Authorization" => "Bearer #{ENV['HEROKU_API_KEY']}"
        }
    end

    def self.dynos
        url = "#{self.base_url}/dynos"
        JSON.parse HTTParty.get(url, headers: self.headers).body
    end

    def self.restart_dyno(dyno_id)
        url = "#{self.base_url}/dynos/#{dyno_id}"
        JSON.parse HTTParty.delete(url, headers: self.headers).body
    end

    def self.select_dynos(name: nil)
        self.dynos.select{ |dyno| dyno['name'].include?(name) }        
    end

    def self.restart_dyno_subset(name: nil)
        self.select_dynos(name: name).map do |dyno|
            dyno['id']
        end.map do |dyno_id|
            puts "Restarting dyno_id=#{dyno_id} (name: #{name})"
            self.restart_dyno(dyno_id)
        end
    end

    def self.restart_sidekiq_dynos
        self.restart_dyno_subset(name: 'sidekiq')
    end

    def self.restart_web_dynos
        self.restart_dyno_subset(name: 'web')
    end

    def self.restart_random_web_dyno
        dyno = self.select_dynos(name: 'web').shuffle.first
        puts "(Random Restart): Restarting dyno=#{dyno}"
        self.restart_dyno(dyno['id'])
    end

end