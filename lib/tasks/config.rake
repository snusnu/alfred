desc "Generate a sample config"
file "config.yml" => "config.yml.sample" do |t|
  sh "cp #{t.prerequisites.first} #{t.name}"
end
