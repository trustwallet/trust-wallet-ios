module Fastlane
  module Actions

    class GetItunesMetadataFromLokaliseAction < Action
      def self.run(params)
        require 'net/http'

        token = params[:api_token]
        project_identifier = params[:project_identifier]
        destination = params[:destination]
        clean_destination = params[:clean_destination]

        request_data = {
          api_token: token,
          id: project_identifier,
          keys: ["itunes.title", "itunes.description", "itunes.changelog", "itunes.keywords"].to_json,
          platform_mask: 16
        }

        languages = params[:languages]
        if languages.kind_of? Array then
          request_data["langs"] = languages.to_json
        end

        uri = URI("https://lokalise.co/api/string/list")
        request = Net::HTTP::Post.new(uri)
        request.set_form_data(request_data)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        response = http.request(request)


        jsonResponse = JSON.parse(response.body)
        raise "Bad response 🉐\n#{response.body}".red unless jsonResponse.kind_of? Hash
        if jsonResponse["response"]["status"] == "success" && jsonResponse["strings"].kind_of?(Hash) then
          Helper.log.info "Metadata downloaded 📦".green
          if clean_destination then
            Helper.log.info "Cleaning destination folder ♻️".green
            FileUtils.remove_dir(destination)
            FileUtils.mkdir_p(destination)
          end
          strings = jsonResponse["strings"]
          errors = Array.new
          strings.each { |lang_code, translations|
            title = translations.select { |translation| translation["key"] == "itunes.title" || translation["key_other"] == "itunes.title" }
            description = translations.select { |translation| translation["key"] == "itunes.description" || translation["key_other"] == "itunes.description" }
            changelog = translations.select { |translation| translation["key"] == "itunes.changelog" || translation["key_other"] == "itunes.changelog" }
            keywords = translations.select { |translation| translation["key"] == "itunes.keywords" || translation["key_other"] == "itunes.keywords" }
            errors.concat(save_data_for_lang(destination, lang_code, title, description, changelog, keywords))
          }
          unless errors.empty? then
            errorsString = errors.join("\n\t\t")
            raise "Errors while creating metadata ⚠️\n\t\t#{errorsString}".red
          end
          Helper.log.info "Metadata created at #{destination} 📗 📕 📘".green
        elsif jsonResponse["response"]["status"] == "error"
          code = jsonResponse["response"]["code"]
          message = jsonResponse["response"]["message"]
          raise "Response error code #{code} (#{message}) 📟".red
        else
          raise "Bad response 🉐\n#{jsonResponse}".red
        end
      end

      def self.save_data_for_lang(destination, lang_code, title, description, changelog, keywords) 
        data = {
          "title" => title,
          "description" => description,
          "changelog" => changelog,
          "keywords" => keywords
        }
        filename_map = {
          "title" => "name",
          "description" => "description",
          "changelog" => "release_notes",
          "keywords" => "keywords"
        }
        language_map  = {
          "de" => "de-DE",
          "en" => "en-US",
          "es" => "es-ES",
          "fr" => "fr-FR",
          "pt" => "pt-BR",
          "pt" => "pt-PT",
          "ru" => "ru",
          "tr" => "tr"
        }
        errors = Array.new
        data.each { |key, value|
          raise "Invalid translation #{value} for #{key} in #{lang_code}".red unless value.kind_of?(Array) || value[0].kind_of?(Hash)
          translation = value[0]["translation"]
          if translation.empty? then
              errors << "No #{key} for #{lang_code}"
              next
          end
          if key == "keywords" then
            translation.gsub!(/ +?,/, ',')
            translation.gsub!(/, +?/, ',')
          end
          filename = filename_map[key]
          language = language_map[lang_code]
          if !language then 
            language = lang_code
          end
          FileUtils.mkdir_p("#{destination}/#{language}")
          File.open("#{destination}/#{language}/#{filename}.txt", 'w') { |file| file.write(translation) }
        }
        return errors
      end



      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Gets iTunes metadata from lokalise"
      end

      def self.available_options
        # Define all options your action supports. 
        
        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "LOKALISE_API_TOKEN",
                                       description: "API Token for Lokalise",
                                       verify_block: proc do |value|
                                          raise "No API token for Lokalise given, pass using `api_token: 'token'`".red unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :project_identifier,
                                       env_name: "LOKALISE_PROJECT_ID",
                                       description: "Create a development certificate instead of a distribution one",
                                       verify_block: proc do |value|
                                          raise "No Project Identifier for Lokalise given, pass using `project_identifier: 'identifier'`".red unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :destination,
                                       description: "Export destination",
                                       verify_block: proc do |value|
                                          raise "Things are pretty bad".red unless (value and not value.empty?)
                                          raise "Directory you passed is in your imagination".red unless File.directory?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :clean_destination,
                                       description: "Clean destination folder",
                                       optional: true,
                                       is_string: false,
                                       default_value: false,
                                       verify_block: proc do |value|
                                          raise "Clean destination should be true or false".red unless [true, false].include? value
                                       end),
          FastlaneCore::ConfigItem.new(key: :languages,
                                       description: "Languages to download",
                                       optional: true,
                                       is_string: false,
                                       verify_block: proc do |value|
                                          raise "Language codes should be passed as array".red unless value.kind_of? Array
                                       end)
        ]
      end

      def self.authors
        ["Fedya-L"]
      end

      def self.is_supported?(platform)
        true
      end

    end
    
  end
end