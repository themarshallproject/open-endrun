Dotenv.load if Rails.env.development?
    
class Document < ActiveRecord::Base
    include HTTParty
    format :json
    base_uri "https://www.documentcloud.org"
    #debug_output $stdout
    serialize :dc_data, JSON

    after_create {
        PullDocumentCloud.perform_async(self.id)
    }

    def self.potential_documents
        HTTParty.get("https://www.documentcloud.org/api/search.json?q=group:marshallproject&per_page=50")['documents']
    end

    def published?
        self.published == true
    end

    def pull_data
        return nil unless self.dc_id.present?
        self.dc_data = self.class.get("/api/documents/#{self.dc_id}.json")
        self.dc_published_url = self.dc_data['document']['resources']['published_url']
        save
    end

    def title
        (read_attribute(:title) || dc_data['document']['title']) rescue 'Untitled'
    end

    def source 
        self.dc_data['document']['source'] rescue nil
    end

    def has_tmp_published_url?
        (self.dc_published_url || "").include?("themarshallproject.org")
    end

    def async_update_published_url
        UpdateDocumentPublishedURL.perform_async(self.id)
    end

    def pdf_url
        self.dc_data['document']['resources']['pdf']
    rescue
        ''
    end

    def update_published_url
        self.class.put("/api/documents/#{self.dc_id}.json", 
            basic_auth: {
                username: ENV['DOCUMENTCLOUD_USERNAME'], 
                password: ENV['DOCUMENTCLOUD_PASSWORD']
            },
            body: {
                "published_url" => "https://www.themarshallproject.org/documents/#{self.dc_id}"
            }
        )
        self.pull_data()
    end

    def self.resolve_slug(slug)
        document = Document.find_by(dc_id: slug)
        if document.present?
            return document
        else
            dc_id_root = slug.split('-').first
            return Document.find_by("dc_id @@ :id", id: dc_id_root)
        end
    end
end