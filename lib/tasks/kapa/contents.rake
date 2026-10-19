namespace :kapa do
  namespace :contents do

    desc 'Overwrite contents in the database with db/fixtures/contents.yml, i.e., rake kapa:contents:load codes=advising,hours_log_digest (all registered codes by default; force=yes in production)'
    task :load do
      # Checked before loading the app, so nothing connects to a production database without force=yes.
      if Rails.env.production? and ENV['force'] != "yes"
        abort "This replaces contents staff edited in production. Run with force=yes to continue."
      end
      Rake::Task[:environment].invoke
      codes = ENV['codes'].present? ? ENV['codes'].split(/,\s*/) : nil
      unknown = Array(codes) - Kapa::Content.registry_types.flat_map { |type| Kapa::Content.registry(type).keys }
      abort "Not in config/content.yml: #{unknown.join(", ")}" if unknown.any?

      results = Kapa::Content.load_defaults!(codes)
      results.each { |code, status| puts "#{status.to_s.ljust(9)} #{code}" }
      puts "#{results.count {|_, status| status != :unchanged}} of #{results.size} contents changed."
    end

    desc 'Dump all contents in the database to db/fixtures/contents.yml, i.e., rake kapa:contents:dump file=tmp/contents.yml'
    task :dump => :environment do
      file = ENV['file'].present? ? ENV['file'] : Rails.root.join("db/fixtures/contents.yml")
      File.write(file, Kapa::Content.to_fixtures)
      puts "Wrote #{Kapa::Content.count} contents to #{file}."
    end

  end
end
